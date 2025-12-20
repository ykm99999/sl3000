#!/bin/bash

# ================================
# ✅ 进入 openwrt 目录（关键修复）
# ================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENWRT_DIR="$SCRIPT_DIR/../openwrt"

cd "$OPENWRT_DIR" || {
    echo "❌ 无法进入 openwrt 目录：$OPENWRT_DIR"
    exit 1
}

echo "=== SL3000 环境自检开始 ==="

# ================================
# ✅ 1. 检查 mt7981.mk
# ================================
if [ ! -f "target/linux/mediatek/image/mt7981.mk" ]; then
    echo "❌ 缺少 mt7981.mk"
    echo "路径检查：$(pwd)/target/linux/mediatek/image/mt7981.mk"
    exit 1
else
    echo "✅ mt7981.mk 存在"
fi

# ================================
# ✅ 2. 检查 DTS
# ================================
DTS_FILE="target/linux/mediatek/files-5.15/arch/arm64/boot/dts/mediatek/mt7981b-sl3000-emmc.dts"

if [ ! -f "$DTS_FILE" ]; then
    echo "❌ DTS 文件不存在：$DTS_FILE"
    exit 1
else
    echo "✅ DTS 文件存在"
fi

# ================================
# ✅ 3. 检查 .config 是否启用 SL3000
# ================================
if grep -q "sl3000" .config; then
    echo "✅ .config 中已启用 SL3000"
else
    echo "❌ .config 中未启用 SL3000"
    exit 1
fi

echo "=== ✅ SL3000 环境自检通过 ==="
exit 0
