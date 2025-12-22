#!/bin/bash
set -e

ROOT=/home/runner/immortalwrt

echo "=== [S13000] Apply DTS / MK / CONFIG ==="

# 1. 拷贝 DTS（你当前 DTS 名称）
mkdir -p $ROOT/target/linux/mediatek/dts
cp -f dts/mt7981b-s13000-emmc.dts \
    $ROOT/target/linux/mediatek/dts/

echo "[OK] DTS applied → mt7981b-s13000-emmc.dts"

# 2. 修复 filogic.mk（确保 DEVICE 定义存在且唯一）
MK=$ROOT/target/linux/mediatek/image/filogic.mk

# 删除旧的 s13000 定义（避免重复）
sed -i '/Device\/s13000-emmc/,+10d' $MK

# 追加新的定义
cat >> $MK << 'EOF'

define Device/s13000-emmc
  DEVICE_TITLE := S13000 (EMMC)
  DEVICE_DTS := mt7981b-s13000-emmc
  DEVICE_PACKAGES := \
    kmod-mt7981-firmware \
    kmod-mt76 \
    kmod-mt76-core \
    kmod-mt76-connac \
    kmod-leds-gpio \
    kmod-gpio-button-hotplug
endef
TARGET_DEVICES += s13000-emmc

EOF

echo "[OK] filogic.mk updated"

# 3. 应用 config（三件套之一）
cp -f configs/s13000.config $ROOT/.config
echo "[OK] .config applied"

# 4. 清理旧的编译缓存（避免脏缓存导致奇怪错误）
rm -rf $ROOT/tmp/*
rm -rf $ROOT/staging_dir/*
rm -rf $ROOT/build_dir/*

echo "[OK] Build cache cleaned"

echo "=== [S13000] prepare_s13000.sh 完成 ==="
