define Device/sl3000_emmc
  DEVICE_VENDOR := Siluoxing
  DEVICE_MODEL := SL3000
  DEVICE_VARIANT := eMMC
  DEVICE_DTS := mt7981b-sl3000-emmc
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek

  DEVICE_PACKAGES := \
        kmod-mt7915e kmod-mt7981-firmware \
        kmod-mt7996e kmod-mt7996-firmware \
        kmod-mmc kmod-mmc-mtk kmod-spi-dev \
        uboot-envtools block-mount

  IMAGES := sysupgrade.bin
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += sl3000_emmc
