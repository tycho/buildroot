################################################################################
#
# pacman
#
################################################################################

PACMAN_VERSION = 4.2.1
PACMAN_SITE = https://sources.archlinux.org/other/pacman
PACMAN_SOURCES = pacman-$(PACMAN_VERSION).tar.gz
PACMAN_DEPENDENCIES = bash gnupg2 libarchive libcurl libgpgme openssl
PACMAN_LICENSE = GPLv2
PACMAN_LICENSE_FILES = COPYING

PACMAN_CONF_ENV += BASH_SHELL=/bin/bash

$(eval $(autotools-package))
