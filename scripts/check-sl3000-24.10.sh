#!/bin/sh

echo "=== SL3000 Pre-check ==="

ROOT="$1"

if [ -z "$ROOT" ]; then
    echo "用法: $0 <immortalwrt 根目录>"
    exit 1
fi

DTS_FILE="$ROOT/target/linux/mediatek/dts/mt7981b-sl3000-emmc.dts"
MK_FILE="$ROOT/target/linux/mediatek/image/filogic.mk"
CONFIG_FILE="$GITHUB_WORKSPACE/configs/sl3000.config"

# 1. 检查 DTS
if [ ! -f "$DTS_FILE" ]; then
    echo "❌ DTS 文件缺失: $DTS_FILE"
    exit 1
else
    echo "✅ DTS 文件存在"
fi

# 2. 检查 filogic.mk
if [ ! -f "$MK_FILE" ]; then
    echo "❌ filogic.mk 缺失: $MK_FILE"
    exit 1
else
    echo "✅ filogic.mk 存在"
fi

# 3. 检查 config 是否启用设备
if ! grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_sl3000_emmc=y" "$CONFIG_FILE"; then
    echo "❌ sl3000.config 未启用 SL3000 设备"
    exit 1
else
    echo "✅ sl3000.config 已启用 SL3000 设备"
fi

# 4. 检查 DTS Makefile 是否包含 dtb
DTS_MK="$ROOT/target/linux/mediatek/files-6.6/arch/arm64/boot/dts/mediatek/Makefile"
if ! grep -q "mt7981b-sl3000-emmc.dtb" "$DTS_MK"; then
    echo "❌ DTS Makefile 未注册 dtb"
    exit 1
else
    echo "✅ DTS Makefile 已注册 dtb"
fi

# 5. 检查 image Makefile 是否包含设备
IMAGE_MK="$ROOT/target/linux/mediatek/image/Makefile"
if ! grep -q "sl3000_emmc" "$IMAGE_MK"; then
    echo "❌ image Makefile 未注册设备"
    exit 1
else
    echo "✅ image Makefile 已注册设备"
fi

echo "✅ 所有 SL3000 检查通过"
exit 0
