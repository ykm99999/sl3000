define Device/sl3000
  DEVICE_VENDOR := SL
  DEVICE_MODEL := 3000
  DEVICE_DTS := mt7981-sl3000
  DEVICE_PACKAGES := kmod-usb3 kmod-usb2 kmod-mt7981-firmware \
                     kmod-leds-gpio kmod-gpio-button-hotplug
endef
TARGET_DEVICES += sl3000
