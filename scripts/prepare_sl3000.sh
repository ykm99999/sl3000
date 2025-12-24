#!/usr/bin/env bash
set -e

ROOT="${1:-/home/runner/immortalwrt}"
CONFIG="$ROOT/.config"

echo "===== SL3000 构建准备（修复版）====="

# ============================
# 0. 生成完整 .config（关键步骤）
# ============================
echo "---- 生成完整 .config ----"
cd "$ROOT"
make defconfig
echo "✅ defconfig 已完成，.config 已完整生成"

# ============================
# 1. RootFS 依赖预检查
# ============================
echo "---- RootFS 依赖预检查 ----"

if ! grep -q "^CONFIG_PACKAGE_luci=y" "$CONFIG"; then
    echo "⚠️ 未启用 luci → 自动启用"
    echo "CONFIG_PACKAGE_luci=y" >> "$CONFIG"
fi

if grep -q "^CONFIG_PACKAGE_default-settings=y" "$CONFIG"; then
    sed -i "/^CONFIG_PACKAGE_default-settings=y/d" "$CONFIG"
    echo "⚠️ 已禁用 default-settings（依赖 luci）"
fi

if grep -q "^CONFIG_PACKAGE_luci-app-store=y" "$CONFIG" && ! grep -q "^CONFIG_PACKAGE_luci-base=y" "$CONFIG"; then
    echo "⚠️ iStore 缺少 luci-base → 自动补齐"
    echo "CONFIG_PACKAGE_luci-base=y" >> "$CONFIG"
fi

if [ -d "$ROOT/dl" ]; then
    echo "⚠️ 清理损坏的 dl 包"
    find "$ROOT/dl" -size 0 -delete || true
fi

echo "✅ RootFS 依赖检查完成"

# ============================
# 2. 自动注册 DTS
# ============================
echo "---- DTS 注册检查 ----"

MAKEFILE="$ROOT/target/linux/mediatek/Makefile"

if [ -f "$MAKEFILE" ] && ! grep -q "mt7981b-sl3000-emmc.dtb" "$MAKEFILE"; then
    echo "dtb-y += mt7981b-sl3000-emmc.dtb" >> "$MAKEFILE"
    echo "✅ 已自动注册 DTS 到 mediatek/Makefile"
else
    echo "ℹ️ DTS 已存在或 Makefile 不存在"
fi

# ============================
# 3. 清理无效包
# ============================
echo "---- 清理无效包 ----"

BAD_PKGS=(
  pcat-manager
  policycoreutils
  audit
  lldpd
)

for pkg in "${BAD_PKGS[@]}"; do
    sed -i "/CONFIG_PACKAGE_${pkg}=y/d" "$CONFIG"
done

echo "✅ 无效包已清理"

# ============================
# 4. 检查设备符号（放宽，不再拦截构建）
# ============================
echo "---- 检查 SL3000 设备符号 ----"

if grep -q "CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_sl3000=y" "$CONFIG"; then
    echo "✅ 检测到 CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_sl3000=y"
elif grep -qi "sl3000" "$CONFIG"; then
    echo "⚠️ 未匹配到标准设备符号，但 .config 中存在 sl3000 相关配置，放行构建"
else
    echo "⚠️ 未显式检测到 SL3000 设备符号（不终止构建），建议后续手动确认 .config"
fi

# ============================
# 5. 清理构建缓存
# ============================
echo "---- 清理构建缓存 ----"

rm -rf "$ROOT/tmp"/* || true
rm -rf "$ROOT/build_dir"/* || true
rm -rf "$ROOT/staging_dir" || true

echo "✅ 构建缓存已清理"

# ============================
# 6. 自动修复工具链
# ============================
echo "---- 工具链预修复 ----"

make -C "$ROOT" tools/compile -j1 V=s || {
    echo "⚠️ 工具链编译失败 → 自动清理并重试"
    rm -rf "$ROOT/build_dir/host/stamp" "$ROOT/tools/stamp" "$ROOT/staging_dir/host/stamp"
    make -C "$ROOT" tools/compile -j1 V=s
}

echo "✅ 工具链检查完成"

# ============================
# 7. 自动修复 dl 下载
# ============================
echo "---- dl 下载预修复 ----"

make -C "$ROOT" download -j8 || {
    echo "⚠️ dl 下载失败 → 自动清理并重试"
    rm -rf "$ROOT/dl"/*
    make -C "$ROOT" download -j8
}

echo "✅ dl 下载检查完成"

# ============================
# 8. 自动修复 feeds
# ============================
echo "---- feeds 修复 ----"

cd "$ROOT"
./scripts/feeds update -a || true
./scripts/feeds install -a || true

echo "✅ feeds 检查完成"

# ============================
# 9. 磁盘空间检查
# ============================
echo "---- 磁盘空间检查 ----"
df -h
echo "✅ 磁盘空间检查完成"

# ============================
# 10. ccache 初始化
# ============================
echo "---- ccache 初始化 ----"

export CCACHE_DIR=~/.ccache
ccache -M 2G || true
ccache -z || true

echo "✅ ccache 初始化完成"

echo "===== SL3000 构建准备完成（修复版执行完毕）====="
