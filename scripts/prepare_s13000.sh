#!/usr/bin/env bash
set -e

ROOT="/home/runner/immortalwrt"
CONFIG="$ROOT/.config"

echo "===== S13000 构建准备（最终修复版）====="

# ============================
# 1. 先复制 .config（必须最先做）
# ============================
echo "---- 复制 .config ----"

SRC_CONFIG="configs/s13000.config"

[ -f "$SRC_CONFIG" ] || { echo "❌ 源 config 不存在：$SRC_CONFIG"; exit 1; }
cp -f "$SRC_CONFIG" "$CONFIG"
echo "✅ .config 已复制 → $CONFIG"


# ============================
# 2. RootFS 依赖预检查（现在 .config 已存在）
# ============================
echo "---- RootFS 依赖预检查 ----"

# luci 主包检查
if ! grep -q "^CONFIG_PACKAGE_luci=y" "$CONFIG"; then
    echo "⚠️ 未启用 luci 主包 → 自动启用"
    echo "CONFIG_PACKAGE_luci=y" >> "$CONFIG"
fi

# default-settings 依赖 luci
if grep -q "^CONFIG_PACKAGE_default-settings=y" "$CONFIG"; then
    if ! grep -q "^CONFIG_PACKAGE_luci=y" "$CONFIG"; then
        echo "❌ default-settings 依赖 luci → 自动禁用 default-settings"
        sed -i "/CONFIG_PACKAGE_default-settings/d" "$CONFIG"
    fi
fi

# iStore 依赖 luci-base
if grep -q "CONFIG_PACKAGE_luci-app-store=y" "$CONFIG"; then
    if ! grep -q "CONFIG_PACKAGE_luci-base=y" "$CONFIG"; then
        echo "⚠️ iStore 缺少 luci-base → 自动补齐"
        echo "CONFIG_PACKAGE_luci-base=y" >> "$CONFIG"
    fi
fi

# 清理损坏的 staging_dir
if [ -d "$ROOT/staging_dir" ]; then
    echo "⚠️ 清理 staging_dir（避免 ABI 冲突）"
    rm -rf "$ROOT/staging_dir"
fi

# 清理损坏的 dl 包
if [ -d "$ROOT/dl" ]; then
    echo "⚠️ 清理损坏的 dl 包"
    find "$ROOT/dl" -size 0 -delete || true
fi

echo "---- RootFS 依赖预检查完成 ----"


# ============================
# 3. 复制 DTS/MK
# ============================
echo "---- DTS/MK 三件套 ----"

SRC_DTS="dts/mt7981b-s13000-emmc.dts"
DST_DTS="$ROOT/target/linux/mediatek/dts/mt7981b-s13000-emmc.dts"

[ -f "$SRC_DTS" ] || { echo "❌ 源 DTS 不存在：$SRC_DTS"; exit 1; }
cp -f "$SRC_DTS" "$DST_DTS"
echo "✅ DTS 已复制 → $DST_DTS"

SRC_MK="image/filogic.mk"
DST_MK="$ROOT/target/linux/mediatek/image/filogic.mk"

[ -f "$SRC_MK" ] || { echo "❌ 源 filogic.mk 不存在：$SRC_MK"; exit 1; }
cp -f "$SRC_MK" "$DST_MK"
echo "✅ filogic.mk 已复制"


# ============================
# 4. DTS/MK 检查
# ============================
[ -f "$DST_DTS" ] || { echo "❌ DTS 未成功复制"; exit 1; }
echo "✅ DTS 存在"

grep -q "DEVICE_DTS *:= *mt7981b-s13000-emmc" "$DST_MK" \
  || { echo "❌ filogic.mk 未对齐 DEVICE_DTS"; exit 1; }
echo "✅ filogic.mk 对齐正确"


# ============================
# 5. 自动注册 DTS
# ============================
MAKEFILE="$ROOT/target/linux/mediatek/Makefile"

if [ -f "$MAKEFILE" ]; then
    if ! grep -q "mt7981b-s13000-emmc.dtb" "$MAKEFILE"; then
        echo "dtb-y += mt7981b-s13000-emmc.dtb" >> "$MAKEFILE"
        echo "✅ 已自动注册 DTS 到 mediatek/Makefile"
    else
        echo "✅ DTS 已在 mediatek/Makefile 注册"
    fi
fi


# ============================
# 6. 清理无效包
# ============================
BAD_PKGS=(asterisk onionshare pysocks unidecode uw-imap)

for pkg in "${BAD_PKGS[@]}"; do
    sed -i "/$pkg/d" "$CONFIG"
done
echo "✅ .config 无效包已清理"


# ============================
# 7. 检查设备符号
# ============================
grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_s13000_emmc=y" "$CONFIG" \
  || { echo "❌ .config 未启用 S13000 设备"; exit 1; }
echo "✅ .config 已启用 S13000 设备"


# ============================
# 8. 清理构建缓存
# ============================
rm -rf $ROOT/tmp/* || true
rm -rf $ROOT/build_dir/* || true
echo "✅ 构建缓存已清理"

echo "===== S13000 构建准备完成（全部通过）====="
