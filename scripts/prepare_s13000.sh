#!/usr/bin/env bash
set -e

echo "===== S13000 构建前检查脚本（自动检测 + fail-fast）====="

ROOT="/home/runner/immortalwrt"

CONFIG_FILE="$ROOT/.config"
DTS_FILE="$ROOT/target/linux/mediatek/dts/mt7981b-s13000-emmc.dts"
MK_FILE="$ROOT/target/linux/mediatek/image/filogic.mk"
DTS_MAKEFILE="$ROOT/target/linux/mediatek/dts/Makefile"

echo "[1] 检查 DTS 文件..."
if [ ! -f "$DTS_FILE" ]; then
    echo "❌ DTS 缺失：$DTS_FILE"
    exit 1
fi
echo "✅ DTS 存在：mt7981b-s13000-emmc.dts"

echo "[2] 检查 filogic.mk 中 DEVICE_DTS..."
if ! grep -q "DEVICE_DTS *:= *mt7981b-s13000-emmc" "$MK_FILE"; then
    echo "❌ filogic.mk 未对齐 DEVICE_DTS := mt7981b-s13000-emmc"
    echo "👉 按你的规则，这里不自动修改，请你手动修复 filogic.mk"
    exit 1
fi
echo "✅ filogic.mk DEVICE_DTS 对齐正确"

echo "[3] 检查 DTS Makefile 注册..."
if ! grep -q "mt7981b-s13000-emmc.dts" "$DTS_MAKEFILE"; then
    echo "❌ DTS Makefile 未注册 mt7981b-s13000-emmc.dts"
    echo "👉 按你的规则，这里不自动 append，请你手动在 DTS_MT7981 行补上"
    exit 1
fi
echo "✅ DTS 已在 DTS Makefile 注册"

echo "[4] 清理 .config 中无效包..."
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到 .config：$CONFIG_FILE"
    exit 1
fi

BAD_PKGS=(
  "asterisk"
  "onionshare"
  "pysocks"
  "unidecode"
  "uw-imap"
)

echo "将从 .config 中清理以下无效包："
printf '  - %s\n' "${BAD_PKGS[@]}"

for pkg in "${BAD_PKGS[@]}"; do
    sed -i "/$pkg/d" "$CONFIG_FILE"
done

echo "验证清理结果..."
for pkg in "${BAD_PKGS[@]}"; do
    if grep -q "$pkg" "$CONFIG_FILE"; then
        echo "❌ 清理失败：仍然存在 $pkg"
        exit 1
    fi
done
echo "✅ .config 已完成清理"

echo "[5] 检查目标设备符号..."
if ! grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_s13000_emmc=y" "$CONFIG_FILE"; then
    echo "❌ .config 未启用 S13000 设备：CONFIG_TARGET_mediatek_filogic_DEVICE_s13000_emmc=y"
    exit 1
fi
echo "✅ .config 已启用 S13000 设备"

echo "===== 所有检查通过，S13000 构建环境已准备完毕 ====="
