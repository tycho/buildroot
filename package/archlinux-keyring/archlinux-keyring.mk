################################################################################
#
# arch-install-scripts
#
################################################################################

ARCHLINUX_KEYRING_VERSION = 20150212
ARCHLINUX_KEYRING_SITE = https://sources.archlinux.org/other/archlinux-keyring
ARCHLINUX_KEYRING_LICENSE = GPLv2

define ARCHLINUX_KEYRING_INSTALL_TARGET_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) install -C $(@D) PREFIX=/usr DESTDIR=$(TARGET_DIR)
endef

$(eval $(generic-package))
