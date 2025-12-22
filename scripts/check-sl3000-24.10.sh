#!/bin/sh
set -e

ROOT="/mnt/immortalwrt"
REPO="$GITHUB_WORKSPACE"

echo "=== Prepare S13000 triple-set ==="

# 1. DTS
cp -f "$REPO/dts/mt7981b-s13000-emmc.dts" \
  "$ROOT/target/linux/mediatek/dts/"

# 2. filogic.mk
cp -f "$REPO/image/filogic.mk" \
  "$ROOT/target/linux/mediatek/image/filogic.mk"

# 3. config
cp -f "$REPO/configs/s13000.config" \
  "$ROOT/.config"

# 4. 关闭 LTO（更稳）
echo "CONFIG_USE_LTO=n" >> "$ROOT/.config"

# 5. DTS Makefile 注册 dtb
DTS_MK="$ROOT/target/linux/mediatek/files-6.6/arch/arm64/boot/dts/mediatek/Makefile"
grep -q 'mt7981b-s13000-emmc.dtb' "$DTS_MK" || \
  echo 'dtb-$(CONFIG_TARGET_mediatek_filogic_DEVICE_s13000_emmc) += mt7981b-s13000-emmc.dtb' >> "$DTS_MK"

echo "[OK] S13000 triple-set prepared."
