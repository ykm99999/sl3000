define Device/sl3000_emmc
  DEVICE_VENDOR := SL
  DEVICE_MODEL := SL3000
  DEVICE_VARIANT := eMMC
  DEVICE_DTS := mt7981b-sl3000-emmc
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek
  SUPPORTED_DEVICES += sl3000,emmc

  BLOCKSIZE := 128k
  PAGESIZE := 2k

  IMAGE_SIZE := 128m

  # 标准 tar+metadata sysupgrade
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
TARGET_DEVICES += sl3000_emmc
