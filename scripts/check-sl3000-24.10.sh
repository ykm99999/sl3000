#!/bin/bash

echo "=== SL3000 24.10 自检开始 ==="

check() {
    if [ ! -f "$1" ]; then
        echo "[缺失] $1"
        exit 1
    else
        echo "[OK] $1"
    fi
}

check target/linux/mediatek/dts/mt7981b-sl3000-emmc.dts
check target/linux/mediatek/image/filogic.mk
check .config

grep -q "kmod-mt7531" .config \
  && echo "[OK] 交换机驱动已启用" \
  || echo "[缺失] 交换机驱动未启用"

echo "=== 自检通过 ==="
exit 0
