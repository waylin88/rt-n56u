#!/usr/bin/env python3
"""
Padavan WebUI 本地开发服务器
- Mock<% nvram_xxx %>之类的 ASP 模板标签
- 静态资源 (CSS/JS/IMG) 直接返回
- 文件变更自动通知浏览器刷新 (live-reload)
- 监听 0.0.0.0:8080，局域网内可访问

用法:
  python3 dev_server.py <web根目录> [端口]
"""
import http.server
import socketserver
import re
import sys
import os
import time
import threading
import hashlib
import base64
from pathlib import Path

ROOT = Path(sys.argv[1] if len(sys.argv) > 1 else
            "/opt/rt-n56u/trunk/user/www/n56u_ribbon_fixed").resolve()
PORT = int(os.environ.get("PORT",
                          sys.argv[2] if len(sys.argv) > 2 else 8080))

# ---- Mock 数据 ---------------------------------------------------------
MOCK_NVRAM = {
    "sw_mode":            "1",
    "wan_route_x":        "0",
    "wan_proto":          "dhcp",
    "lan_proto_x":        "0",
    "log_float_ui":       "1",
    "x_Setting":          "1",
    "wl0_country_code":   "CN",
    "wl1_country_code":   "CN",
    "lan_ipaddr":         "192.168.1.1",
}
MOCK_SYSINFO = ('{"sys":"Mock","cpu_usage":12,"memory_usage":34,'
                '"jffs_total":12345,"jffs_used":6789}')
MOCK_UPTIME  = ("Mon Jan  1 00:00:00 2024 up 1 day,  1:00, "
                "load average: 0.00, 0.00, 0.00")

# ---- ASP 模板处理 ------------------------------------------------------
def mock_asp(content: str) -> str:
    content = re.sub(
        r'<%\s*nvram_get_x\s*\([^)]*\)\s*;?\s*%>',
        lambda m: f'"{MOCK_NVRAM.get("sw_mode","")}"',
        content)
    content = re.sub(r'<%\s*json_system_status\s*\(\s*\)\s*;?\s*%>',
                     MOCK_SYSINFO, content)
    content = re.sub(r'<%\s*uptime\s*\(\s*\)\s*;?\s*%>',
                     MOCK_UPTIME, content)
    content = re.sub(r'<%\s*nvram_(?:match|char)_x?\s*\([^)]*\)\s*;?\s*%>',
                     '', content)
    content = re.sub(r'<%\s*select_channel\([^)]*\)\s*;?\s*%>', '', content)
    content = re.sub(r'<%[^%]*%>', '', content)
    return content

# ---- Live reload 注入 --------------------------------------------------
LR_SNIPPET = (
    "\n<script>\n"
    "(function(){\n"
    "  function connect(){\n"
    "    var ws = new WebSocket((location.protocol==='https:'?'wss':'ws')"
    "+'://'+location.host+'/ws');\n"
    "    ws.onmessage = function(e){ if(e.data==='reload') location.reload(); };\n"
    "    ws.onclose  = function(){ setTimeout(connect, 1500); };\n"
    "  }\n"
    "  connect();\n"
    "})();\n"
    "</script>\n"
    "</body>\n"
)

# ---- HTTP Handler ------------------------------------------------------
class Handler(http.server.SimpleHTTPRequestHandler):
    clients = set()
    clients_lock = threading.Lock()

    def __init__(self, *a, **kw):
        super().__init__(*a, directory=str(ROOT), **kw)

    def log_message(self, fmt, *args):
        msg = "[%s] %s\n" % (self.log_date_time_string(), fmt % args)
        sys.stderr.write(msg)
        sys.stderr.flush()

    def do_GET(self):
        # 1. WebSocket 升级
        if self.path.startswith("/ws"):
            self._ws_handshake()
            return

        # 2. .asp 处理
        rel = self.path.lstrip("/").split("?")[0]
        try:
            target = (ROOT / rel).resolve()
            target.relative_to(ROOT)
        except (ValueError, OSError):
            self.send_error(403)
            return

        if target.is_dir():
            target = target / "index.asp"

        if target.suffix == ".asp" and target.is_file():
            try:
                body = mock_asp(target.read_text(encoding="utf-8",
                                                 errors="ignore"))
            except Exception as e:
                self.send_error(500, str(e))
                return
            body = body.replace("</body>", LR_SNIPPET)
            data = body.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
            return

        # 3. 其它 (CSS/JS/IMG) → 普通静态
        return super().do_GET()

    def _ws_handshake(self):
        key = self.headers.get("Sec-WebSocket-Key", "")
        if not key:
            self.send_error(400)
            return
        accept = base64.b64encode(
            hashlib.sha1((key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
                         .encode()).digest()
        ).decode()
        self.send_response(101)
        self.send_header("Upgrade", "websocket")
        self.send_header("Connection", "Upgrade")
        self.send_header("Sec-WebSocket-Accept", accept)
        self.end_headers()

        with self.clients_lock:
            self.clients.add(self.wfile)
        try:
            while True:
                data = self.request.recv(1024)
                if not data:
                    break
        except Exception:
            pass
        finally:
            with self.clients_lock:
                self.clients.discard(self.wfile)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store, must-revalidate")
        super().end_headers()

# ---- 文件变更监听 → 通知所有 WS 客户端 -------------------------------
def watch_and_notify():
    last_mtime = {}
    while True:
        time.sleep(0.5)
        changed = False
        for p in ROOT.rglob("*"):
            if not p.is_file():
                continue
            if p.suffix not in (".css", ".js", ".html", ".asp"):
                continue
            try:
                mt = p.stat().st_mtime
            except OSError:
                continue
            if last_mtime.get(p) == mt:
                continue
            if p in last_mtime:
                changed = True
            last_mtime[p] = mt
        if changed:
            print("[live-reload] 文件变更，广播刷新")
            payload = b"\x81\x06reload"  # WS 文本帧 "reload"
            with Handler.clients_lock:
                dead = []
                for w in list(Handler.clients):
                    try:
                        w.write(payload)
                        w.flush()
                    except Exception:
                        dead.append(w)
                for w in dead:
                    Handler.clients.discard(w)

# ---- 启动 -------------------------------------------------------------
class ThreadedServer(socketserver.ThreadingMixIn,
                     http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

if __name__ == "__main__":
    print(f"[dev] root  = {ROOT}")
    print(f"[dev] serve = http://0.0.0.0:{PORT}/  "
          f"(LAN: http://<ubuntu-ip>:{PORT}/)")
    print(f"[dev] Ctrl-C to stop")
    threading.Thread(target=watch_and_notify, daemon=True).start()
    srv = ThreadedServer(("0.0.0.0", PORT), Handler)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        print("\n[dev] bye")