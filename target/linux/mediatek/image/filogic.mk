define Device/sl3000
  DEVICE_VENDOR := SL
  DEVICE_MODEL := 3000
  DEVICE_DTS := mt7981b-sl3000-emmc
  SUPPORTED_DEVICES := sl3000
  IMAGE_SIZE := 268435456

  DEVICE_PACKAGES := \
    kmod-mt7981-firmware \
    kmod-mt76 \
    kmod-mt76-core \
    kmod-mt76-connac \
    wpad-basic-mbedtls \
    iwinfo \
    kmod-leds-gpio \
    kmod-gpio-button-hotplug \
    kmod-mediatek_eth \
    kmod-mediatek_hnat \
    kmod-mt7531 \
    block-mount \
    kmod-fs-ext4 \
    kmod-mmc \
    kmod-mmc-mtk \
    e2fsprogs \
    kmod-nls-base \
    dnsmasq-full \
    ppp \
    ppp-mod-pppoe \
    uhttpd \
    uhttpd-mod-ubus \
    libustream-mbedtls \
    rpcd \
    rpcd-mod-rrdns \
    luci \
    luci-base \
    luci-mod-admin-full \
    luci-theme-bootstrap \
    luci-app-opkg \
    luci-ssl \
    luci-i18n-base-zh-cn
endef

TARGET_DEVICES += sl3000
