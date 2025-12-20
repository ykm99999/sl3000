#!/bin/bash
set -e

echo "=== SL3000 eMMC 23.05 自检开始 ==="

###############################################
# 1. 检查三件套文件是否存在
###############################################
check_file() {
    if [ ! -f "$1" ]; then
        echo "❌ 缺少文件：$1"
        exit 1
    fi
}

check_file "target/linux/mediatek/dts/mt7981b-sl3000-emmc.dts"
check_file "target/linux/mediatek/image/filogic.mk"
check_file ".config"

echo "✅ 三件套文件存在"

###############################################
# 2. DTS 关键字段检查
###############################################
DTS="target/linux/mediatek/dts/mt7981b-sl3000-emmc.dts"

grep -q "compatible" "$DTS" || { echo "❌ DTS 缺少 compatible"; exit 1; }
grep -q "model" "$DTS" || { echo "❌ DTS 缺少 model"; exit 1; }
grep -q "&eth" "$DTS" || { echo "❌ DTS 缺少 &eth"; exit 1; }
grep -q "&mdio" "$DTS" || { echo "❌ DTS 缺少 &mdio"; exit 1; }
grep -q "&mmc0" "$DTS" || { echo "❌ DTS 缺少 &mmc0"; exit 1; }

echo "✅ DTS 关键字段正常"

###############################################
# 3. mk 文件检查（是否注册设备）
###############################################
MK="target/linux/mediatek/image/filogic.mk"

grep -q "Device/sl3000_emmc" "$MK" || { echo "❌ mk 未定义 Device/sl3000_emmc"; exit 1; }
grep -q "TARGET_DEVICES += sl3000_emmc" "$MK" || { echo "❌ mk 未注册 sl3000_emmc"; exit 1; }

echo "✅ mk 注册正常"

###############################################
# 4. config 检查（是否启用设备）
###############################################
grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_sl3000_emmc=y" .config || {
    echo "❌ .config 未启用 SL3000 eMMC"
    exit 1
}

echo "✅ .config 设备启用正常"

###############################################
# 5. DTS 语法检查（非致命）
###############################################
echo "→ 尝试 DTS 语法检查（缺少 SoC dtsi 将跳过）..."

DTS_DIR="$(pwd)/target/linux/mediatek/dts"
GENERIC_DIR="$(pwd)/target/linux/generic/files/include"
INC_DIR="$(pwd)/include"

dtc -I dts -O dtb \
  -i "$DTS_DIR" \
  -i "$GENERIC_DIR" \
  -i "$INC_DIR" \
  "$DTS" \
  -o /tmp/sl3000.dtb 2>/tmp/dts_err || true

if grep -q "Couldn't open \"mt7981.dtsi\"" /tmp/dts_err 2>/dev/null; then
    echo "⚠️ 跳过 DTS 强校验（内核未解压）"
elif [ -s /tmp/dts_err ]; then
    echo "❌ DTS 语法错误："
    cat /tmp/dts_err
    exit 1
else
    echo "✅ DTS 语法正常"
fi

echo "=== ✅ SL3000 eMMC 23.05 自检全部通过 ==="
exit 0
