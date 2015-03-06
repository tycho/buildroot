################################################################################
#
# gmp
#
################################################################################

GMP_VERSION = 6.0.0a
GMP_SITE = $(BR2_GNU_MIRROR)/gmp
GMP_SOURCE = gmp-$(GMP_VERSION).tar.xz
GMP_INSTALL_STAGING = YES
GMP_LICENSE = LGPLv3+
GMP_LICENSE_FILES = COPYING.LESSERv3
GMP_DEPENDENCIES = host-m4

ifeq ($(BR2_X32_ABI),y)
GMP_CONF_OPTS += ABI="x32"
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
