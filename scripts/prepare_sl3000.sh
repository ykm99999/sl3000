#!/usr/bin/env bash
set -e

ROOT="/home/runner/immortalwrt"
CONFIG="$ROOT/.config"

echo "===== SL3000 构建准备（最终修复版）====="

# ============================
# 1. 生成 .config（直接写入内容）
# ============================
echo "---- 生成 .config ----"

cat > "$CONFIG" <<'EOF'
CONFIG_TARGET_MEDIATEK=y
CONFIG_TARGET_MEDIATEK_FILOGIC=y
CONFIG_TARGET_MEDIATEK_FILOGIC_DEVICE_sl3000=y

# LuCI + 中文
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-base=y
CONFIG_PACKAGE_luci-mod-admin-full=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-app-opkg=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y

# 网络
CONFIG_PACKAGE_dnsmasq-full=y
CONFIG_PACKAGE_ppp-mod-pppoe=y

# WiFi（MT7981 内置）
CONFIG_PACKAGE_kmod-mt7981-firmware=y
CONFIG_PACKAGE_kmod-mt76=y
CONFIG_PACKAGE_kmod-mt76-core=y
CONFIG_PACKAGE_kmod-mt76-connac=y

# LED / 按键
CONFIG_PACKAGE_kmod-leds-gpio=y
CONFIG_PACKAGE_kmod-gpio-button-hotplug=y

# EMMC / 文件系统
CONFIG_PACKAGE_block-mount=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-mmc=y
CONFIG_PACKAGE_kmod-mmc-mtk=y

# 使用 squashfs
CONFIG_TARGET_ROOTFS_SQUASHFS=y
EOF

echo "✅ .config 已生成 → $CONFIG"


# ============================
# 2. RootFS 依赖预检查
# ============================
echo "---- RootFS 依赖预检查 ----"

if ! grep -q "^CONFIG_PACKAGE_luci=y" "$CONFIG"; then
    echo "⚠️ 未启用 luci → 自动启用"
    echo "CONFIG_PACKAGE_luci=y" >> "$CONFIG"
fi

if grep -q "^CONFIG_PACKAGE_default-settings=y" "$CONFIG"; then
    if ! grep -q "^CONFIG_PACKAGE_luci=y" "$CONFIG"; then
        echo "❌ default-settings 依赖 luci → 自动禁用"
        sed -i "/CONFIG_PACKAGE_default-settings/d" "$CONFIG"
    fi
fi

if grep -q "CONFIG_PACKAGE_luci-app-store=y" "$CONFIG"; then
    if ! grep -q "CONFIG_PACKAGE_luci-base=y" "$CONFIG"; then
        echo "⚠️ iStore 缺少 luci-base → 自动补齐"
        echo "CONFIG_PACKAGE_luci-base=y" >> "$CONFIG"
    fi
fi

[ -d "$ROOT/staging_dir" ] && { echo "⚠️ 清理 staging_dir"; rm -rf "$ROOT/staging_dir"; }
[ -d "$ROOT/dl" ] && { echo "⚠️ 清理损坏的 dl 包"; find "$ROOT/dl" -size 0 -delete || true; }

echo "---- RootFS 依赖预检查完成 ----"


# ============================
# 3. 复制 DTS/MK
# ============================
echo "---- DTS/MK 三件套 ----"

SRC_DTS="dts/mt7981b-sl3000-emmc.dts"
DST_DTS="$ROOT/target/linux/mediatek/dts/mt7981b-sl3000-emmc.dts"

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

grep -q "DEVICE_DTS *:= *mt7981b-sl3000-emmc" "$DST_MK" \
  || { echo "❌ filogic.mk 未对齐 DEVICE_DTS"; exit 1; }
echo "✅ filogic.mk 对齐正确"


# ============================
# 5. 自动注册 DTS
# ============================
MAKEFILE="$ROOT/target/linux/mediatek/Makefile"

if [ -f "$MAKEFILE" ]; then
    if ! grep -q "mt7981b-sl3000-emmc.dtb" "$MAKEFILE"; then
        echo "dtb-y += mt7981b-sl3000-emmc.dtb" >> "$MAKEFILE"
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
grep -q "CONFIG_TARGET_MEDIATEK_FILOGIC_DEVICE_sl3000=y" "$CONFIG" \
  || { echo "❌ .config 未启用 SL3000 设备"; exit 1; }
echo "✅ .config 已启用 SL3000 设备"


# ============================
# 8. 清理构建缓存
# ============================
rm -rf $ROOT/tmp/* || true
rm -rf $ROOT/build_dir/* || true
echo "✅ 构建缓存已清理"

echo "===== SL3000 构建准备完成（全部通过）====="
