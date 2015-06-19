################################################################################
#
# libffi
#
################################################################################

LIBFFI_VERSION = 3.1
LIBFFI_SITE = ftp://sourceware.org/pub/libffi
LIBFFI_LICENSE = MIT
LIBFFI_LICENSE_FILES = LICENSE
LIBFFI_INSTALL_STAGING = YES
LIBFFI_AUTORECONF = YES

$(eval $(autotools-package))
$(eval $(host-autotools-package))
