################################################################################
#
# mosh
#
################################################################################

MOSH_VERSION = 1.2.4
MOSH_SITE = http://mosh.mit.edu
MOSH_SOURCES = mosh-$(MOSH_VERSION).tar.gz
MOSH_DEPENDENCIES = host-protobuf-c ncurses openssh openssl perl protobuf zlib
MOSH_LICENSE = GPLv3+
MOSH_LICENSE_FILES = COPYING

$(eval $(autotools-package))
