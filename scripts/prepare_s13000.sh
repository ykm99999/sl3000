#!/usr/bin/env bash
set -e

ROOT="/home/runner/immortalwrt"

echo "===== S13000 构建准备 + 检查（最终版）====="

# ============================
# 1. 复制 DTS
# ============================
SRC_DTS="dts/mt7981b-s13000-emmc.dts"
DST_DTS="$ROOT/target/linux/mediatek/dts/mt7981b-s13000-emmc.dts"

[ -f "$SRC_DTS" ] || { echo "❌ 源 DTS 不存在：$SRC_DTS"; exit 1; }
cp -f "$SRC_DTS" "$DST_DTS"
echo "✅ DTS 已复制 → $DST_DTS"

# ============================
# 2. 复制 MK
# ============================
SRC_MK="image/filogic.mk"
DST_MK="$ROOT/target/linux/mediatek/image/filogic.mk"

[ -f "$SRC_MK" ] || { echo "❌ 源 filogic.mk 不存在：$SRC_MK"; exit 1; }
cp -f "$SRC_MK" "$DST_MK"
echo "✅ filogic.mk 已复制"

# ============================
# 3. 复制 CONFIG
# ============================
SRC_CONFIG="configs/s13000.config"
DST_CONFIG="$ROOT/.config"

[ -f "$SRC_CONFIG" ] || { echo "❌ 源 config 不存在：$SRC_CONFIG"; exit 1; }
cp -f "$SRC_CONFIG" "$DST_CONFIG"
echo "✅ .config 已复制"

# ============================
# 4. 检查 DTS 是否存在
# ============================
[ -f "$DST_DTS" ] || { echo "❌ DTS 未成功复制：$DST_DTS"; exit 1; }
echo "✅ DTS 存在"

# ============================
# 5. 检查 filogic.mk DEVICE_DTS
# ============================
grep -q "DEVICE_DTS *:= *mt7981b-s13000-emmc" "$DST_MK" \
  || { echo "❌ filogic.mk 未对齐 DEVICE_DTS"; exit 1; }
echo "✅ filogic.mk 对齐正确"

# ============================
# 6. 自动注册 DTS 到 mediatek/Makefile
# ============================
MAKEFILE="$ROOT/target/linux/mediatek/Makefile"

if [ -f "$MAKEFILE" ]; then
    if ! grep -q "mt7981b-s13000-emmc.dtb" "$MAKEFILE"; then
        echo "dtb-y += mt7981b-s13000-emmc.dtb" >> "$MAKEFILE"
        echo "✅ 已自动注册 DTS 到 mediatek/Makefile"
    else
        echo "✅ DTS 已在 mediatek/Makefile 注册"
    fi
else
    echo "⚠️ mediatek/Makefile 不存在，跳过注册检查"
fi

# ============================
# 7. 清理 .config 中无效包
# ============================
BAD_PKGS=(asterisk onionshare pysocks unidecode uw-imap)

for pkg in "${BAD_PKGS[@]}"; do
    sed -i "/$pkg/d" "$DST_CONFIG"
done
echo "✅ .config 无效包已清理"

# ============================
# 8. 检查设备符号
# ============================
grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_s13000_emmc=y" "$DST_CONFIG" \
  || { echo "❌ .config 未启用 S13000 设备"; exit 1; }
echo "✅ .config 已启用 S13000 设备"

# ============================
# 9. 清理构建缓存（安全）
# ============================
rm -rf $ROOT/tmp/* || true
rm -rf $ROOT/build_dir/* || true
echo "✅ 构建缓存已清理"

echo "===== S13000 构建准备完成（全部通过）====="
