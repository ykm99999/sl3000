# SPDX-License-Identifier: GPL-2.0-or-later
#
# Copyright (C) 2023 ImmortalWrt

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

DEFAULT_PACKAGES += \
	kmod-leds-gpio kmod-gpio-button-hotplug \
	kmod-usb3 kmod-usb2 kmod-usb-ledtrig-usbport

define Device/Default
  PROFILES := Default
  DEVICE_DTS_DIR := mediatek
  DEVICE_DTS := $(1)
  DEVICE_PACKAGES := \
	kmod-mt7981-firmware kmod-mt7915e kmod-mt7531 swconfig
endef

# ============================
# ✅ SL3000 eMMC（你的设备）
# ============================
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

# ============================
# ✅ 官方 filogic 设备（保持原样）
# ============================

define Device/mt7981-spim-nand
  DEVICE_TITLE := MediaTek MT7981 RFB (SPI-NAND)
  DEVICE_DTS := mt7981-spim-nand
  DEVICE_PACKAGES := kmod-mt7981-firmware kmod-mt7915e kmod-mt7531 swconfig
endef
TARGET_DEVICES += mt7981-spim-nand

define Device/mt7981-spim-nor
  DEVICE_TITLE := MediaTek MT7981 RFB (SPI-NOR)
  DEVICE_DTS := mt7981-spim-nor
  DEVICE_PACKAGES := kmod-mt7981-firmware kmod-mt7915e kmod-mt7531 swconfig
endef
TARGET_DEVICES += mt7981-spim-nor

define Device/mt7981-emmc
  DEVICE_TITLE := MediaTek MT7981 RFB (eMMC)
  DEVICE_DTS := mt7981-emmc
  DEVICE_PACKAGES := kmod-mt7981-firmware kmod-mt7915e kmod-mt7531 swconfig
endef
TARGET_DEVICES += mt7981-emmc

# ============================
# ✅ 其他官方设备保持不动
# ============================

include $(SUBTARGET).mk
$(eval $(call BuildImage))
