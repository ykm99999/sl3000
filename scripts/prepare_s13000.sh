#!/usr/bin/env bash
set -e

ROOT="/home/runner/immortalwrt"

echo "=== [S13000] Apply DTS / MK / CONFIG ==="

# 1. DTS
SRC_DTS="dts/mt7981b-s13000-emmc.dts"
DST_DTS="$ROOT/target/linux/mediatek/dts/mt7981b-s13000-emmc.dts"

if [ ! -f "$SRC_DTS" ]; then
    echo "❌ 源 DTS 不存在：$SRC_DTS"
    exit 1
fi

cp -f "$SRC_DTS" "$DST_DTS"
echo "[OK] DTS applied → $DST_DTS"

# 2. MK
SRC_MK="image/filogic.mk"
DST_MK="$ROOT/target/linux/mediatek/image/filogic.mk"

if [ ! -f "$SRC_MK" ]; then
    echo "❌ 源 filogic.mk 不存在：$SRC_MK"
    exit 1
fi

cp -f "$SRC_MK" "$DST_MK"
echo "[OK] filogic.mk updated"

# 3. CONFIG
SRC_CONFIG="configs/s13000.config"
DST_CONFIG="$ROOT/.config"

if [ ! -f "$SRC_CONFIG" ]; then
    echo "❌ 源 config 不存在：$SRC_CONFIG"
    exit 1
fi

cp -f "$SRC_CONFIG" "$DST_CONFIG"
echo "[OK] .config applied"

# 4. 清理构建缓存（安全，不动 dl/staging_dir）
rm -rf $ROOT/tmp/*
rm -rf $ROOT/build_dir/*

echo "[OK] Build cache cleaned"
echo "=== [S13000] prepare_s13000.sh 完成 ==="
