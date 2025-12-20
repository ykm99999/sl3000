#!/bin/bash
set -e

ROOT_DIR="$(pwd)/immortalwrt"

echo "=== SL3000 ImmortalWrt 24.10 增强版自检开始 ==="

cd "$ROOT_DIR" || {
    echo "❌ 无法进入 ImmortalWrt 目录：$ROOT_DIR"
    exit 1
}

###############################################
# 1. 检查 DTS 文件
###############################################
DTS_FILE="target/linux/mediatek/dts/mt7981b-sl3000-emmc.dts"

if [ ! -f "$DTS_FILE" ]; then
    echo "❌ DTS 文件不存在：$DTS_FILE"
    exit 1
else
    echo "✅ DTS 文件存在"
fi

# DTS 语法检查
echo "→ 正在检查 DTS 语法..."
dtc -I dts -O dtb "$DTS_FILE" -o /tmp/sl3000.dtb 2>/tmp/dts_err || true
if [ -s /tmp/dts_err ]; then
    echo "❌ DTS 语法错误："
    cat /tmp/dts_err
    exit 1
else
    echo "✅ DTS 语法正常"
fi


###############################################
# 2. 检查 filogic.mk
###############################################
MK_FILE="target/linux/mediatek/image/filogic.mk"

if [ ! -f "$MK_FILE" ]; then
    echo "❌ filogic.mk 不存在"
    exit 1
fi

if grep -q "Device/sl3000_emmc" "$MK_FILE"; then
    echo "✅ filogic.mk 已包含 sl3000_emmc"
else
    echo "❌ filogic.mk 未包含 sl3000_emmc"
    exit 1
fi


###############################################
# 3. 检查 .config
###############################################
if grep -q "sl3000_emmc" .config; then
    echo "✅ .config 已启用 SL3000"
else
    echo "❌ .config 未启用 SL3000"
    exit 1
fi


###############################################
# 4. 检查 WiFi 驱动
###############################################
echo "→ 检查 WiFi 驱动..."

check_wifi() {
    local pkg="$1"
    if grep -q "$pkg" .config; then
        echo "✅ WiFi 驱动启用：$pkg"
    else
        echo "❌ WiFi 驱动缺失：$pkg"
        exit 1
    fi
}

check_wifi "CONFIG_PACKAGE_kmod-mt7915e"
check_wifi "CONFIG_PACKAGE_kmod-mt7981-firmware"
check_wifi "CONFIG_PACKAGE_kmod-mt7996e"
check_wifi "CONFIG_PACKAGE_kmod-mt7996-firmware"


###############################################
# 5. 检查 eMMC 驱动
###############################################
echo "→ 检查 eMMC 驱动..."

check_emmc() {
    local pkg="$1"
    if grep -q "$pkg" .config; then
        echo "✅ eMMC 驱动启用：$pkg"
    else
        echo "❌ eMMC 驱动缺失：$pkg"
        exit 1
    fi
}

check_emmc "CONFIG_PACKAGE_kmod-mmc"
check_emmc "CONFIG_PACKAGE_kmod-mmc-mtk"


###############################################
# 6. 检查 SPI 驱动
###############################################
echo "→ 检查 SPI 驱动..."

check_spi() {
    local pkg="$1"
    if grep -q "$pkg" .config; then
        echo "✅ SPI 驱动启用：$pkg"
    else
        echo "❌ SPI 驱动缺失：$pkg"
        exit 1
    fi
}

check_spi "CONFIG_PACKAGE_kmod-spi-dev"
check_spi "CONFIG_PACKAGE_kmod-spi-mt65xx"


###############################################
# 7. 检查 ITB 固件格式
###############################################
echo "→ 检查 ITB 固件格式..."

if grep -q "CONFIG_TARGET_ROOTFS_INITRAMFS=y" .config; then
    echo "✅ ITB initramfs 格式启用"
else
    echo "❌ ITB initramfs 格式未启用"
    exit 1
fi


###############################################
# 8. 检查 feeds 是否安装
###############################################
echo "→ 检查 feeds..."

if [ -d "package/feeds" ]; then
    echo "✅ feeds 已安装"
else
    echo "❌ feeds 未安装，请检查 workflow"
    exit 1
fi


###############################################
# 9. 检查 image 规则是否正确
###############################################
echo "→ 检查 image 输出规则..."

if grep -q "sysupgrade.itb" "$MK_FILE"; then
    echo "✅ sysupgrade.itb 输出规则正常"
else
    echo "❌ sysupgrade.itb 输出规则缺失"
    exit 1
fi


###############################################
# 10. 最终结果
###############################################
echo "=== ✅ SL3000 ImmortalWrt 24.10 增强版自检全部通过 ==="
exit 0
