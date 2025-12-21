#!/bin/bash

echo "=== SL3000 24.10 自检开始 ==="

check_file() {
    local f="$1"
    if [ ! -f "$f" ]; then
        echo "[缺失] $f"
        exit 1
    else
        echo "[OK] $f"
    fi
}

echo "[步骤1] 检查三件套文件是否存在"

check_file target/linux/mediatek/dts/mt7981b-sl3000-emmc.dts
check_file target/linux/mediatek/image/filogic.mk
check_file .config

echo "[步骤2] 检查 .config 中关键选项"

grep -q "CONFIG_TARGET_mediatek_filogic_DEVICE_sl3000_emmc=y" .config \
  && echo "[OK] 目标设备已启用" \
  || echo "[警告] 未找到 CONFIG_TARGET_mediatek_filogic_DEVICE_sl3000_emmc=y"

grep -q "kmod-mt7531" .config \
  && echo "[OK] 交换机驱动已启用(kmod-mt7531)" \
  || echo "[警告] 未找到 kmod-mt7531，请确认交换机相关配置"

echo "=== SL3000 24.10 自检结束 ==="
exit 0
