#!/bin/bash
# =========================================================
# Printer 模块自动安装脚本 (printer-diy.sh)
# 将 patches/pd-Printer 下的子模块拷贝到 trunk/user/
# =========================================================

set -e

REPO_DIR="${GITHUB_WORKSPACE}/build-repo"
SRC_DIR="${GITHUB_WORKSPACE}/padavan-src"
MAKEFILE_PATH="${SRC_DIR}/trunk/user/Makefile"
PRINTER_PATCH_DIR="${REPO_DIR}/patches/pd-Printer"
RC_C_PATH="${SRC_DIR}/trunk/user/rc/rc.c"

echo "=========================================="
echo ">>> Printer 模块安装脚本"
echo ">>> Actions 仓库路径: ${REPO_DIR}"
echo ">>> Padavan 源码路径: ${SRC_DIR}"
echo "=========================================="

# 1. 拷贝三个模块到 trunk/user/
echo ">>> 拷贝 printer-script"
mkdir -p "${SRC_DIR}/trunk/user/printer-script"
cp -rf "${PRINTER_PATCH_DIR}/printer-script"/. "${SRC_DIR}/trunk/user/printer-script/"

echo ">>> 拷贝 virtualhere"
mkdir -p "${SRC_DIR}/trunk/user/virtualhere"
cp -rf "${PRINTER_PATCH_DIR}/virtualhere"/. "${SRC_DIR}/trunk/user/virtualhere/"

echo ">>> 拷贝 vn-link-cli"
mkdir -p "${SRC_DIR}/trunk/user/vn-link-cli"
cp -rf "${PRINTER_PATCH_DIR}/vn-link-cli"/. "${SRC_DIR}/trunk/user/vn-link-cli/"


# 3. 注入编译项到 user/Makefile
echo ">>> 添加 printer 模块编译项到 Makefile"
sed -i '/^all:/i dir_y\t\t+= vn-link-cli' "${MAKEFILE_PATH}"
sed -i '/^all:/i dir_y\t\t+= virtualhere' "${MAKEFILE_PATH}"
sed -i '/^all:/i dir_y\t\t+= printer-script' "${MAKEFILE_PATH}"

grep '^dir_y.*printer-script\|^dir_y.*virtualhere\|^dir_y.*vn-link-cli' "${MAKEFILE_PATH}" | head -5

echo "=========================================="
echo ">>> Printer 模块安装完成 ✅"
echo "=========================================="

python3 - "$RC_C_PATH" << 'PYEOF'
import sys

rc_path = sys.argv[1]

with open(rc_path, 'r') as f:
    lines = f.readlines()

# Step 1: 删除原位置的 MMC / USB / ATA 加载块（每个 3 行: #if / load / #endif）
BLOCK_PATTERNS = [
    ('#if defined (USE_MMC_SUPPORT)', 'load_mmc_modules'),
    ('#if defined (USE_USB_SUPPORT)', 'load_usb_modules'),
    ('#if defined (USE_ATA_SUPPORT)', 'load_ata_modules'),
]

for if_line, load_fn in BLOCK_PATTERNS:
    i = 0
    while i < len(lines):
        if if_line in lines[i]:
            if i + 2 < len(lines) and load_fn in lines[i+1] and '#endif' in lines[i+2]:
                del lines[i:i+3]
                continue
        i += 1

# Step 2: 在 restart_crond(); 所在 if 块的闭合 } 之后插入 MMC → USB → ATA
INSERT_BLOCKS = [
    ['#if defined (USE_MMC_SUPPORT)\n', '\tload_mmc_modules();\n', '#endif\n'],
    ['#if defined (USE_USB_SUPPORT)\n', '\tload_usb_modules();\n', '#endif\n'],
    ['#if defined (USE_ATA_SUPPORT)\n', '\tload_ata_modules();\n', '#endif\n'],
]

crond_idx = None
for i, line in enumerate(lines):
    if 'restart_crond();' in line:
        crond_idx = i
        break

if crond_idx is None:
    print('ERROR: restart_crond(); not found in rc.c!')
    sys.exit(1)

insert_after = crond_idx + 1
offset = insert_after + 1
for block in INSERT_BLOCKS:
    for j, bline in enumerate(block):
        lines.insert(offset + j, bline)
    offset += len(block)

with open(rc_path, 'w') as f:
    f.writelines(lines)

# 打印验证
for i, line in enumerate(lines, 1):
    if any(x in line for x in ['restart_crond', 'load_mmc_modules', 'load_usb_modules', 'load_ata_modules']):
        print(f'  {i}: {line.rstrip()}')
PYEOF
