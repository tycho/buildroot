################################################################################
#
# shadow
#
################################################################################

SHADOW_VERSION = 4.2.1
SHADOW_SITE = http://pkg-shadow.alioth.debian.org/releases/
SHADOW_SOURCE = shadow-$(SHADOW_VERSION).tar.xz
SHADOW_LICENSE = BSD-3c
SHADOW_LICENSE_FILES = LICENCE
SHADOW_AUTORECONF = YES
SHADOW_CONF_OPTS = \
	--sysconfdir=/etc \
	--enable-subordinate-ids=yes \
	--with-libpam \
	--with-group-name-max-length=32 \
	--without-selinux
SHADOW_DEPENDENCIES = acl linux-pam util-linux

define SHADOW_INSTALL_PAMFILES
	$(INSTALL) -m 0644 package/shadow/chgpasswd.pam \
		$(TARGET_DIR)/etc/pam.d/chgpasswd
	$(INSTALL) -m 0644 package/shadow/chpasswd.pam \
		$(TARGET_DIR)/etc/pam.d/chpasswd
	$(INSTALL) -m 0644 package/shadow/newusers.pam \
		$(TARGET_DIR)/etc/pam.d/newusers
	$(INSTALL) -m 0644 package/shadow/passwd.pam \
		$(TARGET_DIR)/etc/pam.d/passwd
endef
SHADOW_POST_INSTALL_TARGET_HOOKS += SHADOW_INSTALL_PAMFILES

define SHADOW_PERMISSIONS
	/usr/bin/chage f 4755 0 0 - - - - -
	/usr/bin/expiry f 4755 0 0 - - - - -
	/usr/bin/gpasswd f 4755 0 0 - - - - -
	/usr/bin/newgidmap f 4755 0 0 - - - - -
	/usr/bin/newuidmap f 4755 0 0 - - - - -
	/usr/bin/passwd f 4755 0 0 - - - - -
	/usr/bin/newgrp f 4755 0 0 - - - - -
endef

$(eval $(autotools-package))
