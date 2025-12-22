#!/bin/sh
set -e

ROOT="/home/runner/immortalwrt"
REPO="$GITHUB_WORKSPACE"

echo "=== Prepare S13000 triple-set ==="

check() {
    if [ ! -f "$1" ]; then
        echo "❌ 缺少文件：$1"
        exit 1
    fi
}

check "$REPO/dts/mt7981b-s13000-emmc.dts"
check "$REPO/configs/s13000.config"
check "$REPO/image/filogic.mk"

cp -f "$REPO/dts/mt7981b-s13000-emmc.dts" \
  "$ROOT/target/linux/mediatek/dts/"

cp -f "$REPO/image/filogic.mk" \
  "$ROOT/target/linux/mediatek/image/filogic.mk"

cp -f "$REPO/configs/s13000.config" \
  "$ROOT/.config"
