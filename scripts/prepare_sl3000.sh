#!/usr/bin/env bash
set -e

ROOT="/home/runner/immortalwrt"
CONFIG="$ROOT/.config"

echo "===== SL3000 构建准备（简化修复版）====="

# 1. 生成 .config（只写目标）
cat > "$CONFIG" <<'EOF'
CONFIG_TARGET_MEDIATEK=y
CONFIG_TARGET_MEDIATEK_FILOGIC=y
CONFIG_TARGET_MEDIATEK_FILOGIC_DEVICE_sl3000=y
CONFIG_TARGET_ROOTFS_SQUASHFS=y
EOF
echo "✅ .config 已生成 → $CONFIG"

# 2. 清理缓存
[ -d "$ROOT/staging_dir" ] && rm -rf "$ROOT/staging_dir"
[ -d "$ROOT/tmp" ] && rm -rf "$ROOT/tmp/*"
[ -d "$ROOT/build_dir" ] && rm -rf "$ROOT/build_dir/*"
echo "✅ 构建缓存已清理"

# 3. 检查设备符号
grep -q "CONFIG_TARGET_MEDIATEK_FILOGIC_DEVICE_sl3000=y" "$CONFIG" \
  || { echo "❌ .config 未启用 SL3000 设备"; exit 1; }
echo "✅ .config 已启用 SL3000 设备"

echo "===== SL3000 构建准备完成（全部通过）====="
