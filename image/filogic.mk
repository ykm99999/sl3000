# SL3000 EMMC device profile (MT7981B + MT7976CN)

define Device/sl3000_emmc
  DEVICE_VENDOR := Siluoxing
  DEVICE_MODEL := SL3000
  DEVICE_VARIANT := eMMC
  DEVICE_DTS := mt7981b-sl3000-emmc
  DEVICE_DTS_DIR := $(DTS_DIR)/mediatek

  # 1G RAM, 128G eMMC, 32M SPI NOR
  DEVICE_PACKAGES := kmod-mt7915e kmod-mt7981-firmware uboot-envtools

  # 24.10 风格镜像（参考 cmcc_rax3000m-emmc）
  KERNEL_INITRAMFS_SUFFIX := -initramfs-recovery.itb
  KERNEL_SUFFIX := -recovery.itb
  KERNEL := kernel-bin | fit
  IMAGES := sysupgrade.itb
  IMAGE/sysupgrade.itb := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += sl3000_emmc
