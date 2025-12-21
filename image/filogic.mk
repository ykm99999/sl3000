define Device/sl3000_emmc
  DEVICE_VENDOR := SL
  DEVICE_MODEL := 3000
  DEVICE_VARIANT := eMMC
  DEVICE_DTS := mt7981b-sl3000-emmc
  DEVICE_PACKAGES := \
	kmod-mt7915e \
	kmod-mt7981-firmware \
	mt7981-wo-firmware \
	kmod-mediatek_hnat \
	kmod-mt7531 \
	block-mount \
	e2fsprogs \
	kmod-fs-ext4 \
	kmod-mmc \
	kmod-mmc-mtk \
	kmod-nft-offload \
	kmod-nft-core \
	kmod-nft-nat
endef
TARGET_DEVICES += sl3000_emmc
