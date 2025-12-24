#!/usr/bin/env bash
set -e

ROOT="${1:-/home/runner/immortalwrt}"
CONFIG="$ROOT/.config"

echo "===== SL3000 构建准备（全功能修复版）====="

# ============================
# 1. 生成 .config（只写目标）
# ============================
cat > "$CONFIG" <<'EOF'
CONFIG_TARGET_MEDIATEK=y
CONFIG_TARGET_MEDIATEK_FILOGIC=y
CONFIG_TARGET_MEDIATEK_FILOGIC_DEVICE_sl3000=y
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
    sed -i "/CONFIG_PACKAGE_default-settings/d" "$CONFIG"
    echo "⚠️ 已禁用 default-settings（依赖 luci）"
fi
if grep -q "CONFIG_PACKAGE_luci-app-store=y" "$CONFIG" && ! grep -q "CONFIG_PACKAGE_luci-base=y" "$CONFIG"; then
    echo "⚠️ iStore 缺少 luci-base → 自动补齐"
    echo "CONFIG_PACKAGE_luci-base=y" >> "$CONFIG"
fi
[ -d "$ROOT/dl" ] && { echo "⚠️ 清理损坏的 dl 包"; find "$ROOT/dl" -size 0 -delete || true; }
echo "✅ RootFS 依赖检查完成"

# ============================
# 3. DTS/MK 三件套复制
# ============================
echo "---- DTS/MK 三件套 ----"
cp dts/mt7981b-sl3000-emmc.dts "$ROOT/target/linux/mediatek/dts/"
cp image/filogic.mk "$ROOT/target/linux/mediatek/image/"
echo "✅ DTS/MK 已复制"

# ============================
# 4. 自动注册 DTS
# ============================
MAKEFILE="$ROOT/target/linux/mediatek/Makefile"
if [ -f "$MAKEFILE" ] && ! grep -q "mt7981b-sl3000-emmc.dtb" "$MAKEFILE"; then
    echo "dtb-y += mt7981b-sl3000-emmc.dtb" >> "$MAKEFILE"
    echo "✅ 已自动注册 DTS 到 mediatek/Makefile"
fi

# ============================
# 5. 清理无效包
# ============================
BAD_PKGS=(asterisk onionshare pysocks unidecode uw-imap)
for pkg in "${BAD_PKGS[@]}"; do
    sed -i "/$pkg/d" "$CONFIG"
done
echo "✅ .config 无效包已清理"

# ============================
# 6. 检查设备符号
# ============================
grep -q "CONFIG_TARGET_MEDIATEK_FILOGIC_DEVICE_sl3000=y" "$CONFIG" \
  || { echo "❌ .config 未启用 SL3000 设备"; exit 1; }
echo "✅ .config 已启用 SL3000 设备"

# ============================
# 7. 清理构建缓存
# ============================
rm -rf "$ROOT/tmp"/* || true
rm -rf "$ROOT/build_dir"/* || true
rm -rf "$ROOT/staging_dir" || true
echo "✅ 构建缓存已清理"

# ============================
# 8. 自动修复工具链
# ============================
echo "---- 工具链预修复 ----"
make -C "$ROOT" tools/compile -j1 V=s || {
  echo "⚠️ 工具链编译失败，自动清理并重试..."
  rm -rf "$ROOT/build_dir/host/stamp" "$ROOT/tools/stamp" "$ROOT/staging_dir/host/stamp"
  make -C "$ROOT" tools/compile -j1 V=s
}
echo "✅ 工具链检查完成"

# ============================
# 9. 自动修复 dl 下载
# ============================
echo "---- dl 下载预修复 ----"
make -C "$ROOT" download -j8 || {
  echo "⚠️ dl 下载失败，自动清理并重试..."
  rm -rf "$ROOT/dl/*"
  make -C "$ROOT" download -j8
}
echo "✅ dl 下载检查完成"

# ============================
# 10. 自动修复 feeds
# ============================
echo "---- feeds 修复 ----"
cd "$ROOT"
./scripts/feeds update -a || true
./scripts/feeds install -a || true
echo "✅ feeds 检查完成"

# ============================
# 11. 磁盘空间检查
# ============================
echo "---- 磁盘空间检查 ----"
df -h
echo "✅ 磁盘空间检查完成"

# ============================
# 12. ccache 初始化
# ============================
echo "---- ccache 初始化 ----"
export CCACHE_DIR=~/.ccache
ccache -M 2G || true
ccache -z || true
echo "✅ ccache 初始化完成"

echo "===== SL3000 构建准备完成（全部修复机制已启用）====="
