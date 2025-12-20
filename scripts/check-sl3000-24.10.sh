#!/bin/bash
set -e

echo "=== SL3000 ImmortalWrt 24.10 增强版自检开始 ==="

###############################################
# 进入 ImmortalWrt 源码目录
###############################################
cd immortalwrt || {
    echo "❌ 无法进入 immortalwrt 目录"
    exit 1
}

###############################################
# 1. DTS 文件存在性检查
###############################################
DTS_FILE="target/linux/mediatek/dts/mt7981b-sl3000-emmc.dts"

if [ ! -f "$DTS_FILE" ]; then
    echo "❌ DTS 文件不存在：$DTS_FILE"
    exit 1
else
    echo "✅ DTS 文件存在"
fi

###############################################
# 2. DTS 关键字段检查（轻量 sanity check）
###############################################
echo "→ 正在检查 DTS 关键字段..."

grep -q "compatible" "$DTS_FILE" || {
    echo "❌ DTS 缺少 compatible 字段"
    exit 1
}

grep -q "model" "$DTS_FILE" || {
    echo "❌ DTS 缺少 model 字段"
    exit 1
}

grep -q "&eth" "$DTS_FILE" || {
    echo "❌ DTS 缺少以太网节点 (&eth)"
    exit 1
}

grep -q "&mdio" "$DTS_FILE" || {
    echo "❌ DTS 缺少 MDIO 节点 (&mdio)"
    exit 1
}

echo "✅ DTS 关键字段正常"

###############################################
# 3. 尝试 DTS 语法检查（非致命）
###############################################
echo "→ 正在尝试 DTS 语法检查（缺少 SoC dtsi 将跳过）..."

# 计算绝对路径
DTS_DIR="$(pwd)/target/linux/mediatek/dts"
GENERIC_DIR="$(pwd)/target/linux/generic/files/include"
INC_DIR="$(pwd)/include"

dtc -I dts -O dtb \
  -i "$DTS_DIR" \
  -i "$GENERIC_DIR" \
  -i "$INC_DIR" \
  "$DTS_FILE" \
  -o /tmp/sl3000.dtb 2>/tmp/dts_err || true

# 如果是 SoC dtsi 缺失 → 跳过
if grep -q "Couldn't open \"mt7981.dtsi\"" /tmp/dts_err 2>/dev/null; then
    echo "⚠️ 警告：dtc 无法打开 mt7981.dtsi（内核 SoC dtsi 尚未解压）"
    echo "⚠️ 已跳过 DTS 语法强校验，真实 DTS 错误将在 make 阶段暴露"
elif [ -s /tmp/dts_err ]; then
    echo "❌ DTS 语法错误："
    cat /tmp/dts_err
    exit 1
else
    echo "✅ DTS 语法正常"
fi

echo "=== ✅ SL3000 ImmortalWrt 24.10 自检全部通过（方案 B） ==="
exit 0
