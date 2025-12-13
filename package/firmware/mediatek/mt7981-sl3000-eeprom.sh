chmod +x mt7981-sl3000-eeprom.sh
#!/bin/sh
#
# SL3000 WiFi EEPROM extract script
# MT7976CN 校准数据从 eMMC factory 分区读取
#

FACTORY="/dev/mmcblk0p2"

EEPROM_2G="/lib/firmware/mediatek/mt7976_eeprom_2g.bin"
EEPROM_5G="/lib/firmware/mediatek/mt7976_eeprom_5g.bin"

echo "[SL3000] Extracting WiFi EEPROM from factory partition..."

# 2.4G 校准数据（前 4KB）
dd if=$FACTORY of=$EEPROM_2G bs=1 skip=0 count=4096 2>/dev/null

# 5G 校准数据（后 4KB）
dd if=$FACTORY of=$EEPROM_5G bs=1 skip=4096 count=4096 2>/dev/null

echo "[SL3000] EEPROM extract done."

exit 0
