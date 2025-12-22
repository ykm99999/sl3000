define Device/s13000_emmc
  DEVICE_VENDOR := S
  DEVICE_MODEL := S13000
  DEVICE_VARIANT := eMMC
  DEVICE_DTS := mt7981b-s13000-emmc
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek
  SUPPORTED_DEVICES += s13000,emmc

  BLOCKSIZE := 128k
  PAGESIZE := 2k
  IMAGE_SIZE := 128m

  IMAGES := sysupgrade.bin
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata

  DEVICE_PACKAGES := \
    kmod-mt7915e \
    kmod-mt7531 \
    kmod-mmc \
    kmod-mmc-mtk \
    kmod-mediatek_hnat \
    block-mount \
    kmod-fs-ext4 \
    e2fsprogs
endef
TARGET_DEVICES += s13000_emmc
