################################################################################
#
# arch-install-scripts
#
################################################################################

ARCH_INSTALL_SCRIPTS_VERSION = 15
ARCH_INSTALL_SCRIPTS_SITE = https://projects.archlinux.org/arch-install-scripts.git/snapshot
#ARCH_INSTALL_SCRIPTS_SOURCES = pacman-$(ARCH_INSTALL_SCRIPTS_VERSION).tar.gz
ARCH_INSTALL_SCRIPTS_DEPENDENCIES = bash pacman util-linux
ARCH_INSTALL_SCRIPTS_LICENSE = GPLv2
ARCH_INSTALL_SCRIPTS_LICENSE_FILES = COPYING

define ARCH_INSTALL_SCRIPTS_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
endef

define ARCH_INSTALL_SCRIPTS_INSTALL_TARGET_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) install -C $(@D) PREFIX=/usr DESTDIR=$(TARGET_DIR)
endef

$(eval $(generic-package))
