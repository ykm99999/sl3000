#!/bin/sh

echo "[SL3000] Checking DTS..."
test -f target/linux/mediatek/files-6.12/arch/arm64/boot/dts/mediatek/mt7981-sl3000.dts || {
    echo "ERROR: DTS missing"
    exit 1
}

echo "[SL3000] Checking image.mk..."
grep -q "sl3000" target/linux/mediatek/image/mt7981.mk || {
    echo "ERROR: image.mk missing device entry"
    exit 1
}

echo "[SL3000] Checking WiFi EEPROM script..."
test -f package/firmware/mediatek/mt7981-sl3000-eeprom.sh || {
    echo "ERROR: WiFi EEPROM script missing"
    exit 1
}

echo "[SL3000] All checks passed."
exit 0
