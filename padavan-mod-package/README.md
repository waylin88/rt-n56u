# Padavan 路由器 Web 界面修改说明

> 基准版本: `9398ba4450` (git commit)
> 修改范围: `trunk/user/www/n56u_ribbon_fixed/` 目录下的 Web UI 文件
> 打包时间: 2026-09-13

---

## 一、修改概述

### 修改目标

本次修改对 Padavan 固件 Web 管理界面进行了以下调整：

1. **移除 2.4G/5G 切换按钮** — 无线设置系列页面底部原有的 "GO 5G" / "GO 2G" 按钮已删除，Apply 按钮居中显示
2. **删除 Guest 网络时间调度** — 移除"启用日期/时间段(工作日)"和"启用日期/时间段(周末)"字段，以及相关 hidden input
3. **保留 Guest 加密字段控制** — 在 Guest 网络禁用时，加密相关字段（row_guest_11/12）正确隐藏
4. **精简 WEP 相关代码** — 加密模式下拉框仅保留 Open System / WPA-Personal / WPA2-Personal / WPA-Auto-Personal
5. **清理 device-map 页面** — router.asp / router2g.asp 大量删除已不使用的 WEP/WPA-Enterprise 分支逻辑
6. **修复 IPv6/WAN 连接类型文案** — 去除冗余的 "BOP_ctype_ipoe: " 前缀
7. **移除 WOL MAC Vendor 外部 API** — 原有的 macvendorlookup.com 调用已废弃，仅使用 localStorage 本地缓存
8. **JavaScript 防御性修复** — 为 `free_options`、`inputCtrl`、`automode_hint`、`enableExtChRows` 等函数添加 null 检查，修复 hidden input 上调用 `.options` 的 TypeError 隐患
9. **tabtitle/tablink 数组更新** — state.js 中为 tablink[0]/[1] 补回 ACL 页面引用

### 修改统计

| 指标 | 数值 |
|------|------|
| 变更文件数 | **21 个** |
| 新增行 | 221 |
| 删除行 | 619 |
| 净减少 | **398 行** |

---

## 二、目录结构

```
padavan-mod-package/
├── README.md                      ← 本文件
├── padavan-ui-modifications.diff  ← 全部变更的 unified diff
├── modified/                      ← 修改后的完整文件（保留原始目录结构）
│   └── trunk/user/www/n56u_ribbon_fixed/
│       ├── Advanced_*.asp  (19 个)
│       ├── device-map/
│       │   ├── internet.asp
│       │   ├── router.asp
│       │   └── router2g.asp
│       ├── state.js
│       ├── wireless.js
│       └── wireless_2g.js
├── original/                      ← 基准版本对应文件（便于对比）
│   └── (同上结构)
└── diffs/                         ← 逐文件 diff（21 个 .diff 文件）
```

### 快速使用

```bash
# 应用修改（直接使用 modified 目录覆盖源码）
cp -r modified/trunk/user/www/n56u_ribbon_fixed/* \
      trunk/user/www/n56u_ribbon_fixed/

# 恢复原始版本
cp -r original/trunk/user/www/n56u_ribbon_fixed/* \
      trunk/user/www/n56u_ribbon_fixed/

# 查看总体 diff
less padavan-ui-modifications.diff

# 查看某个文件的变更
less diffs/wireless.js.diff
```

---

## 三、逐文件修改详情

### 1. JavaScript 核心文件（3 个）

#### 1.1 `state.js` (+13 -5)

| 改动点 | 说明 |
|--------|------|
| `tabtitle[0]` / `tabtitle[1]` | 恢复 `menu5_1_4`（ACL）tab 标题 |
| `tablink[0]` / `tablink[1]` | 恢复 `Advanced_ACL2g_Content.asp` / `Advanced_ACL_Content.asp` |
| `free_options()` | 增加 `selectObj.options == null` 检查，防止 hidden input 触发 TypeError |
| `inputCtrl()` | 增加 `obj == null` 检查 |
| `set_display(id, val)` | **新增**。替代直接 `$().style.display`，内部做 null 安全 |

#### 1.2 `wireless.js` (+53 -53) — 5GHz 无线通用

| 改动点 | 说明 |
|--------|------|
| `automode_hint()` | 增加 hint 元素 null 检查（5G 部分页面无此元素） |
| `nmode_limitation()` | 删除 4 处 alert 弹窗（WEP/RADIUS/TKIP 限制），仅保留自动修正逻辑 |
| `wl_wep_change()` | 所有 `$("row_xxx").style.display` 改为 `set_display("row_xxx", ...)`；`change_key_des()` 调用改为 typeof 检查 |
| `change_wep_type()` | **新增** hidden input 提前返回分支（`wl_wep_x.options == null`），绕过 free_options 对 hidden input 的 TypeError |
| `wl_auth_mode_change()` | 末尾 `wl_key` 重建逻辑包入 `wl_key.options != null` 条件 |

#### 1.3 `wireless_2g.js` (+58 -57) — 2.4GHz 无线通用

| 改动点 | 说明 |
|--------|------|
| `automode_hint()` | 同 wireless.js，加 null 检查 |
| `nmode_limitation()` | 同 wireless.js，删除 alert |
| `enableExtChRows()` | `row_protect` 检查加 null 保护；`row_HT_BW` / `row_HT_EXTCHA` 加 null 保护 |
| `insertExtChannelOption()` | 开头增加 `rt_HT_EXTCHA` / `rt_HT_EXTCHA.options` 存在性检查 |
| `rt_wep_change()` | 同 `wl_wep_change()`，set_display + typeof change_key_des |
| `change_wep_type()` | 同 wireless.js，hidden input 提前返回 |
| `rt_auth_mode_change()` | 同 wireless.js，`rt_key.options != null` 条件包裹 |

---

### 2. 无线设置页面（6 个 ASP）

#### 2.1 `Advanced_Wireless2g_Content.asp` / `Advanced_Wireless_Content.asp`

**主要改动：**
- 删除 2G↔5G 切换按钮（`goto5` / `GO 2G`）及相关 `support_5g_radio()` 适配代码
- Apply 按钮所在 `<td>` 增加 `text-align: center`
- 总计：每个文件 **+1 -9（2G）/ +1 -4（5G）**

#### 2.2 `Advanced_WMode2g_Content.asp` / `Advanced_WMode_Content.asp`

**主要改动：** 同上，删除切换按钮 + 按钮居中。

#### 2.3 `Advanced_WAdvanced2g_Content.asp` / `Advanced_WAdvanced_Content.asp`

**主要改动：** 同上，删除切换按钮 + 按钮居中。

#### 2.4 `Advanced_WSecurity2g_Content.asp` / `Advanced_WSecurity_Content.asp`

**主要改动：** 同上，删除切换按钮 + 按钮居中。

#### 2.5 `Advanced_ACL2g_Content.asp` / `Advanced_ACL_Content.asp`

**主要改动：** 同上，删除切换按钮 + 按钮居中。

---

### 3. Guest 网络页面（2 个 ASP）

#### 3.1 `Advanced_WGuest2g_Content.asp` (+8 -13)

| 改动点 | 说明 |
|--------|------|
| 删除切换按钮 | 同无线设置页面 |
| 删除 hidden input | 移除 `rt_guest_date_x` / `rt_guest_time_x` / `rt_guest_time2_x` 三个时间调度相关 hidden 字段 |
| `change_guest_enabled()` | **新增 else 分支**：Guest 禁用时显式调用 `showhide_div('row_guest_11', 0)` / `showhide_div('row_guest_12', 0)` 隐藏加密字段 |
| `change_guest_auth_mode()` | **新增 Guest 启用检查**：函数开头判断 `rt_guest_enable[0].checked`，未启用时直接 return，避免对禁用 Guest 的残留加密状态误操作 |
| Apply 按钮居中 | 同上 |

#### 3.2 `Advanced_WGuest_Content.asp` (+8 -7)

与 2G 版本一致，使用 `wl_guest_*` 前缀。

---

### 4. 其他设置页面（4 个 ASP）

#### 4.1 `Advanced_IPv6_Content.asp` (+3 -3)

- WAN 连接类型说明：`<#BOP_ctype_ipoe#>: <#BOP_ctype_title5#>` → `<#BOP_ctype_title5#>` （去除冗余前缀）
- `<#BOP_ctype_ipoe#>: <#BOP_ctype_title1#>` → `<#BOP_ctype_title1#>`（同上）
- `PPTP` → `<#BOP_ctype_pppoe#>` 统一多语言键

#### 4.2 `Advanced_WAN_Content.asp` (+2 -2)

- 同 IPv6 页面，WAN 连接类型下拉框去除 `BOP_ctype_ipoe:` 前缀
- `PPPoE` 选项保留（原已是正确写法）

#### 4.3 `Advanced_WOL_Content.asp` (+2 -26)

- **删除 macvendorlookup.com AJAX**：原有的外部 API 调用（`http://www.macvendorlookup.com/api/v2/...`）已废弃，改为仅依赖 `findVendorInLocalStorage()` 的 localStorage 本地缓存
- 大幅减少网络依赖和外部请求

#### 4.4 `device-map/internet.asp` (+2 -5)

- WAN 状态显示中的连接类型文案去重同 IPv6/WAN
- 下拉选择框中移除 DDNS / VPN 选项（保持精简）

---

### 5. 设备图页面（2 个 ASP，改动最大）

#### 5.1 `device-map/router.asp` (+31 -193)

**主要清理：**
- `wl_auth_mode_change()`：删除 WPA-Enterprise (Radius) 分支的 crypto 重建、删除 `wl_key` 重建逻辑（均为 WEP/Enterprise 专用）
- `wl_wep_change()`：删除大量 `all_related_wep` / `all_wep_key` / `asus_wep_key` DOM 操作
- `change_auth_mode()`：删除 `wpa`（Enterprise）分支、删除 `shared` 分支的 `show_key()` 调用，保留纯 Personal 模式
- `change_wep_type()` / `change_wlweptype()`：加 hidden input 提前返回；加 null 安全

#### 5.2 `device-map/router2g.asp` (+31 -190)

与 router.asp 对称，使用 `rt_*` 前缀。

---

## 四、发现的原有 Bug（防御性修复的依据）

### Bug: `free_options()` 在 hidden input 上报 TypeError

**位置**: `wireless.js` / `wireless_2g.js` 中的 `change_wep_type()` 调用链

**根因**: 原代码假设 `rt_wep_x` / `wl_wep_x` 是 `<select>` 元素，但实际上它们是 `<input type="hidden">`，没有 `.options` 属性。

```
原来的执行路径（bug）：
  initial() → rt_auth_mode_change() → change_wep_type()
    → free_options(document.form.rt_wep_x)
        → selectObj.options.length   ← undefined.length → TypeError! 💥
```

**后果**：`rt_auth_mode_change()` 函数在执行到一半时中断，后续 `wl_wep_change()` / `rt_wep_change()` 的所有 DOM 操作**永远不会被执行**。页面虽然看起来正常（因为 row_wep1-7 在无线设置页面本来就不存在），但初始化路径不完整。

**本次修复**：
1. `free_options()` 增加 `options == null` 检查 → hidden input 安全跳过
2. `change_wep_type()` 开头增加 hidden input 提前返回分支 → 不再尝试重建选项
3. `change_wep_type()` 末尾调用的 `change_wlweptype()` 在 wireless_2g.js 中也加了 `.options == null` 检查
4. `wl_auth_mode_change()` / `rt_auth_mode_change()` 末尾的 `wl_key` / `rt_key` 重建也加了 `.options != null` 条件

### 隐藏的关联 Bug: `change_key_des()` 在无线设置页面未定义

**位置**: `wireless.js` / `wireless_2g.js` 的 `wl_wep_change()` / `rt_wep_change()` 末尾

**根因**: `change_key_des()` 函数只在 `device-map/router.asp` / `router2g.asp` 中定义。无线设置页面（Advanced_Wireless*）引用了 wireless.js/2g.js 但没有该函数。

**原来的执行路径**: 由于 `free_options` 的 TypeError 让流程中断，`change_key_des()` 永远没有被调用到。修复 free_options 后，`wl_wep_change()` 会完整执行到末尾，此时就会触发 `change_key_des is not defined`。

**本次修复**: 两处改为 `if (typeof change_key_des == 'function') change_key_des();`

---

## 五、操作注意事项

1. **applyRule() 中的 guest_enable 检查**：Guest 页面的表单提交依赖 `rt_guest_enable[0].checked`，但它是 radio 组而非 checkbox，确认固件后端能正确解析为隐藏的 fake checkbox（`rt_guest_enable_fake`）同步更新

2. **JS 文件加载顺序**：所有页面都按 `state.js → general.js → wireless.js/2g.js → 页面内嵌脚本` 顺序加载，`set_display()` / `inputCtrl()` 等工具函数定义在 state.js，wireless.js/2g.js 调用时已就绪

3. **路由页面可能的卡顿**：原有的 TypeError 让 `wl_wep_change()` / `rt_wep_change()` 从未在无线设置页面的 initial 中完整执行过。本次修复后这些函数会完整执行（虽然大多是对不存在的 DOM 元素做 null 检查跳过）。在 MIPS 低性能路由器上，执行路径从"报错中断"变成"完整执行"可能带来可感知的初始化延迟

4. **tabtitle/tablink 数组恢复**：之前修改可能误删了 5G/2G ACL tab 的引用，本次恢复。如果你的固件编译过程中 tabtitle[0][4] / tabtitle[1][4] 被其他逻辑覆盖，需要确认 ACL tab 是否正常显示

---

## 六、Git 参考

```bash
# 基准 commit
BASE=9398ba4450

# 生成完整 diff
git diff $BASE..HEAD -- trunk/user/www/n56u_ribbon_fixed/

# 查看本次所有涉及的 commit
git log $BASE..HEAD --oneline
```

### Commit 列表

```
42e59943b0 feat: 找到网页底部版权相关文字
bb550a26b4 feat: 找到网页底部版权相关文字
...
```

（中间多个 commit 主要做逐步推进，实际最终变更量如上统计。）
