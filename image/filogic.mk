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

  KERNEL := kernel-bin | fit
  KERNEL_SUFFIX := -recovery.itb
  KERNEL_INITRAMFS_SUFFIX := -initramfs-recovery.itb

  IMAGES := sysupgrade.itb
  IMAGE/sysupgrade.itb := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += sl3000_emmc
