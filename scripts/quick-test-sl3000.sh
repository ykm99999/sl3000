#!/bin/sh

echo "=== SL3000 QUICK TEST START ==="

# 1. DTS
echo -n "[1] Checking DTS... "
if [ -f target/linux/mediatek/files-6.12/arch/arm64/boot/dts/mediatek/mt7981-sl3000.dts ]; then
    echo "OK"
else
    echo "MISSING"
    exit 1
fi

# 2. image.mk
echo -n "[2] Checking image.mk device entry... "
if grep -q "sl3000" target/linux/mediatek/image/mt7981.mk; then
    echo "OK"
else
    echo "MISSING"
    exit 1
fi

# 3. EEPROM script
echo -n "[3] Checking EEPROM script... "
if [ -f package/firmware/mediatek/mt7981-sl3000-eeprom.sh ]; then
    echo "OK"
else
    echo "MISSING"
    exit 1
fi

# 4. Network config
echo -n "[4] Checking 02_network... "
if grep -q "sl3000" target/linux/mediatek/base-files/etc/board.d/02_network; then
    echo "OK"
else
    echo "MISSING"
    exit 1
fi

# 5. LED config
echo -n "[5] Checking 01_leds... "
if grep -q "sl3000" target/linux/mediatek/base-files/etc/board.d/01_leds; then
    echo "OK"
else
    echo "MISSING"
    exit 1
fi

# 6. Keys config
echo -n "[6] Checking 01_gpio_keys... "
if grep -q "sl3000" target/linux/mediatek/base-files/etc/board.d/01_gpio_keys; then
    echo "OK"
else
    echo "MISSING"
    exit 1
fi

# 7. Make sure profile appears in menuconfig
echo "[7] Checking Target Profile..."
make menuconfig | grep -q "SL3000"
if [ $? -eq 0 ]; then
    echo "OK (profile detected)"
else
    echo "NOT FOUND (image.mk may be wrong)"
    exit 1
fi

echo "=== ALL SL3000 TESTS PASSED ==="
exit 0
