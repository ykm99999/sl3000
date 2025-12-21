define Device/sl3000_emmc
  DEVICE_TITLE := SL3000 eMMC
  DEVICE_DTS := mt7981b-sl3000-emmc
  DTS_DIR := mediatek/
  DEVICE_PACKAGES := \
        kmod-mt7981-firmware \
        kmod-mt7915e \
        kmod-mt7531 \
        swconfig \
        kmod-usb3 \
        kmod-usb2 \
        kmod-usb-ledtrig-usbport
endef
TARGET_DEVICES += sl3000_emmc
