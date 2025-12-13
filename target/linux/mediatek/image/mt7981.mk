define Device/sl3000
  DEVICE_VENDOR := Siluo
  DEVICE_MODEL := SL3000
  DEVICE_DTS := mt7981-sl3000
  DEVICE_PACKAGES := kmod-mt7981-firmware kmod-mt76 kmod-mt7915e
endef
TARGET_DEVICES += sl3000
