################################################################################
#
# Common variables for the gcc-initial and gcc-final packages.
#
################################################################################

#
# Version, site and source
#

TARGET_GCC_VERSION = $(call qstrip,$(BR2_GCC_VERSION))

ifeq ($(BR2_arc),y)
TARGET_GCC_SITE = $(call github,foss-for-synopsys-dwc-arc-processors,gcc,$(TARGET_GCC_VERSION))
TARGET_GCC_SOURCE = gcc-$(TARGET_GCC_VERSION).tar.gz
else
ifeq ($(BR2_GCC_STABLE_SNAPSHOT),y)
TARGET_GCC_SITE = $(BR2_GCC_MIRROR:/=)/gcc/snapshots/$(TARGET_GCC_VERSION)
else
TARGET_GCC_SITE = $(BR2_GCC_MIRROR:/=)/gcc/gcc-$(TARGET_GCC_VERSION)
endif
endif

TARGET_GCC_SOURCE ?= gcc-$(TARGET_GCC_VERSION).tar.bz2

#
# Apply patches
#

ifeq ($(ARCH),powerpc)
ifneq ($(BR2_SOFT_FLOAT),)
define TARGET_GCC_APPLY_POWERPC_PATCH
	$(APPLY_PATCHES) $(@D) package/gcc/$(TARGET_GCC_VERSION) 1000-powerpc-link-with-math-lib.patch.conditional
endef
endif
endif

define TARGET_GCC_APPLY_PATCHES
	if test -d package/gcc/$(TARGET_GCC_VERSION); then \
	  $(APPLY_PATCHES) $(@D) package/gcc/$(TARGET_GCC_VERSION) \*.patch ; \
	fi;
	$(TARGET_GCC_APPLY_POWERPC_PATCH)
endef

#
# Custom extract command to save disk space
#

define TARGET_GCC_EXTRACT_CMDS
	$(call suitable-extractor,$(TARGET_GCC_SOURCE)) $(DL_DIR)/$(TARGET_GCC_SOURCE) | \
		$(TAR) $(TAR_STRIP_COMPONENTS)=1 -C $(@D) \
		--exclude='libjava/*' \
		--exclude='libgo/*' \
		--exclude='gcc/testsuite/*' \
		--exclude='libstdc++-v3/testsuite/*' \
		$(TAR_OPTIONS) -
	mkdir -p $(@D)/libstdc++-v3/testsuite/
	echo "all:" > $(@D)/libstdc++-v3/testsuite/Makefile.in
	echo "install:" >> $(@D)/libstdc++-v3/testsuite/Makefile.in
endef

#
# Create 'build' directory and configure symlink
#

define TARGET_GCC_CONFIGURE_SYMLINK
	mkdir -p $(@D)/build
	ln -sf ../configure $(@D)/build/configure
endef

#
# Common configuration options
#

TARGET_GCC_DEPENDENCIES = \
	binutils \
	gmp \
	mpfr \
	$(if $(BR2_BINFMT_FLAT),elf2flt)

TARGET_GCC_CONF_OPTS = \
	--host=$(GNU_TARGET_NAME) \
	--target=$(GNU_TARGET_NAME) \
	--disable-__cxa_atexit \
	--with-gnu-ld \
	--disable-libssp \
	--disable-multilib \
	--with-pkgversion="Buildroot $(BR2_VERSION_FULL)" \
	--with-bugurl="http://bugs.buildroot.net/"

# Don't build documentation. It takes up extra space / build time,
# and sometimes needs specific makeinfo versions to work
TARGET_GCC_CONF_ENV = \
	MAKEINFO=missing

# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=43810
# Workaround until it's fixed in 4.5.4 or later
ifeq ($(ARCH),powerpc)
ifeq ($(findstring x4.5.,x$(TARGET_GCC_VERSION)),x4.5.)
TARGET_GCC_CONF_OPTS += --disable-target-optspace
endif
else
TARGET_GCC_CONF_OPTS += --enable-target-optspace
endif

# libitm needs sparc V9+
ifeq ($(BR2_sparc_v8)$(BR2_sparc_leon3),y)
TARGET_GCC_CONF_OPTS += --disable-libitm
endif

# gcc 4.6.x quadmath requires wchar
ifneq ($(BR2_TOOLCHAIN_BUILDROOT_WCHAR),y)
TARGET_GCC_CONF_OPTS += --disable-libquadmath
endif

# libsanitizer requires wordexp, not in default uClibc config. Also
# doesn't build properly with musl.
ifeq ($(BR2_TOOLCHAIN_BUILDROOT_UCLIBC)$(BR2_TOOLCHAIN_BUILDROOT_MUSL),y)
TARGET_GCC_CONF_OPTS += --disable-libsanitizer
endif

ifeq ($(BR2_GCC_ENABLE_TLS),y)
TARGET_GCC_CONF_OPTS += --enable-tls
else
TARGET_GCC_CONF_OPTS += --disable-tls
endif

ifeq ($(BR2_GCC_ENABLE_LTO),y)
HOST_GCC_COMMON_CONF_OPTS += --enable-plugins --enable-lto
endif

ifeq ($(BR2_GCC_ENABLE_LIBMUDFLAP),y)
TARGET_GCC_CONF_OPTS += --enable-libmudflap
else
TARGET_GCC_CONF_OPTS += --disable-libmudflap
endif

ifeq ($(BR2_PTHREADS_NONE),y)
TARGET_GCC_CONF_OPTS += \
	--disable-threads \
	--disable-libitm \
	--disable-libatomic
else
TARGET_GCC_CONF_OPTS += --enable-threads
endif

ifeq ($(BR2_GCC_NEEDS_MPC),y)
TARGET_GCC_DEPENDENCIES += mpc
endif

ifeq ($(BR2_GCC_ENABLE_GRAPHITE),y)
TARGET_GCC_DEPENDENCIES += isl cloog
else
TARGET_GCC_CONF_OPTS += --without-isl --without-cloog
endif

ifeq ($(BR2_arc),y)
TARGET_GCC_DEPENDENCIES += flex bison
endif

ifeq ($(BR2_SOFT_FLOAT),y)
# only mips*-*-*, arm*-*-* and sparc*-*-* accept --with-float
# powerpc seems to be needing it as well
ifeq ($(BR2_arm)$(BR2_armeb)$(BR2_mips)$(BR2_mipsel)$(BR2_mips64)$(BR2_mips64el)$(BR2_powerpc)$(BR2_sparc),y)
TARGET_GCC_CONF_OPTS += --with-float=soft
endif
endif

ifeq ($(BR2_GCC_SUPPORTS_FINEGRAINEDMTUNE),y)
TARGET_GCC_CONF_OPTS += --disable-decimal-float
endif

# Determine arch/tune/abi/cpu options
ifneq ($(call qstrip,$(BR2_GCC_TARGET_ARCH)),)
TARGET_GCC_CONF_OPTS += --with-arch=$(BR2_GCC_TARGET_ARCH)
endif
ifneq ($(call qstrip,$(BR2_GCC_TARGET_ABI)),)
TARGET_GCC_CONF_OPTS += --with-abi=$(BR2_GCC_TARGET_ABI)
endif
# GCC doesn't support --with-cpu for bfin
ifeq ($(BR2_bfin),)
ifneq ($(call qstrip,$(BR2_GCC_TARGET_CPU)),)
ifneq ($(call qstrip,$(BR2_GCC_TARGET_CPU_REVISION)),)
TARGET_GCC_CONF_OPTS += --with-cpu=$(call qstrip,$(BR2_GCC_TARGET_CPU)-$(BR2_GCC_TARGET_CPU_REVISION))
else
TARGET_GCC_CONF_OPTS += --with-cpu=$(call qstrip,$(BR2_GCC_TARGET_CPU))
endif
endif
endif

TARGET_GCC_TARGET_FPU = $(call qstrip,$(BR2_GCC_TARGET_FPU))
ifneq ($(TARGET_GCC_TARGET_FPU),)
TARGET_GCC_CONF_OPTS += --with-fpu=$(TARGET_GCC_TARGET_FPU)
endif

TARGET_GCC_TARGET_FLOAT_ABI = $(call qstrip,$(BR2_GCC_TARGET_FLOAT_ABI))
ifneq ($(TARGET_GCC_TARGET_FLOAT_ABI),)
TARGET_GCC_CONF_OPTS += --with-float=$(TARGET_GCC_TARGET_FLOAT_ABI)
endif

TARGET_GCC_TARGET_MODE = $(call qstrip,$(BR2_GCC_TARGET_MODE))
ifneq ($(TARGET_GCC_TARGET_MODE),)
TARGET_GCC_CONF_OPTS += --with-mode=$(TARGET_GCC_TARGET_MODE)
endif

# Enable proper double/long double for SPE ABI
ifeq ($(BR2_powerpc_SPE),y)
TARGET_GCC_CONF_OPTS += \
	--enable-e500_double \
	--with-long-double-128
endif

TARGET_GCC_POST_PATCH_HOOKS += TARGET_GCC_APPLY_PATCHES

# gcc doesn't support in-tree build, so we create a 'build'
# subdirectory in the gcc sources, and build from there.
TARGET_GCC_SUBDIR = build

TARGET_GCC_PRE_CONFIGURE_HOOKS += TARGET_GCC_CONFIGURE_SYMLINK

define  TARGET_GCC_CONFIGURE_CMDS
	(cd $(TARGET_GCC_SRCDIR) && rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(TARGET_GCC_CONF_ENV) \
		./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--enable-static \
		$(QUIET) $(TARGET_GCC_CONF_OPTS) \
	)
endef


# Languages supported by the cross-compiler
TARGET_GCC_FINAL_CROSS_LANGUAGES-y = c
TARGET_GCC_FINAL_CROSS_LANGUAGES-$(BR2_INSTALL_LIBSTDCPP) += c++
TARGET_GCC_FINAL_CROSS_LANGUAGES = $(subst $(space),$(comma),$(TARGET_GCC_FINAL_CROSS_LANGUAGES-y))

TARGET_GCC_CONF_OPTS += \
	--enable-languages=$(TARGET_GCC_FINAL_CROSS_LANGUAGES) \
	$(DISABLE_LARGEFILE) \
	--with-build-time-tools=$(HOST_DIR)/usr/$(GNU_TARGET_NAME)/bin

# Disable shared libs like libstdc++ if we do static since it confuses linking
ifeq ($(BR2_STATIC_LIBS),y)
TARGET_GCC_CONF_OPTS += --disable-shared
else
TARGET_GCC_CONF_OPTS += --enable-shared
endif

ifeq ($(BR2_GCC_ENABLE_OPENMP),y)
TARGET_GCC_CONF_OPTS += --enable-libgomp
else
TARGET_GCC_CONF_OPTS += --disable-libgomp
endif

# End with user-provided options, so that they can override previously
# defined options.
TARGET_GCC_CONF_OPTS += \
	$(call qstrip,$(BR2_EXTRA_GCC_CONFIG_OPTIONS))

# Make sure we have 'cc'
define TARGET_GCC_CREATE_CC_SYMLINKS
	if [ ! -e $(TARGET_DIR)/usr/bin/$(GNU_TARGET_NAME)-cc ]; then \
		ln -snf $(GNU_TARGET_NAME)-gcc \
			$(TARGET_DIR)/usr/bin/$(GNU_TARGET_NAME)-cc; \
	fi
	if [ ! -e $(TARGET_DIR)/usr/$(GNU_TARGET_NAME)/bin/cc ]; then \
		ln -snf gcc $(TARGET_DIR)/usr/$(GNU_TARGET_NAME)/bin/cc; \
	fi
endef

TARGET_GCC_POST_INSTALL_HOOKS += TARGET_GCC_CREATE_CC_SYMLINKS

# Create <arch>-linux-<tool> symlinks
define TARGET_GCC_CREATE_SIMPLE_SYMLINKS
	(cd $(TARGET_DIR)/usr/bin; for i in $(GNU_TARGET_NAME)-*; do \
		ln -snf $$i $(ARCH)-linux$${i##$(GNU_TARGET_NAME)}; \
	done)
endef

TARGET_GCC_POST_INSTALL_HOOKS += TARGET_GCC_CREATE_SIMPLE_SYMLINKS

# In gcc 4.7.x, the ARM EABIhf library loader path for (e)glibc was not
# correct, so we create a symbolic link to make things work
# properly. eglibc installs the library loader as ld-linux-armhf.so.3,
# but gcc creates binaries that reference ld-linux.so.3.
ifeq ($(BR2_arm)$(BR2_ARM_EABIHF)$(BR2_GCC_VERSION_4_7_X)$(BR2_TOOLCHAIN_USES_GLIBC),yyyy)
define TARGET_GCC_LD_LINUX_LINK
	ln -sf ld-linux-armhf.so.3 $(TARGET_DIR)/lib/ld-linux.so.3
	ln -sf ld-linux-armhf.so.3 $(STAGING_DIR)/lib/ld-linux.so.3
endef
TARGET_GCC_POST_INSTALL_HOOKS += TARGET_GCC_LD_LINUX_LINK
endif

# Cannot use the TARGET_GCC_USR_LIBS mechanism below, because we want
# libgcc_s to be installed in /lib and not /usr/lib.
define TARGET_GCC_INSTALL_LIBGCC
	-cp -dpf $(TARGET_DIR)/usr/$(GNU_TARGET_NAME)/lib*/libgcc_s* \
		$(STAGING_DIR)/lib/
	-cp -dpf $(TARGET_DIR)/usr/$(GNU_TARGET_NAME)/lib*/libgcc_s* \
		$(TARGET_DIR)/lib/
endef

TARGET_GCC_POST_INSTALL_HOOKS += TARGET_GCC_INSTALL_LIBGCC

# Handle the installation of libraries in /usr/lib
TARGET_GCC_USR_LIBS =

ifeq ($(BR2_INSTALL_LIBSTDCPP),y)
TARGET_GCC_USR_LIBS += libstdc++
endif

ifeq ($(BR2_GCC_ENABLE_OPENMP),y)
TARGET_GCC_USR_LIBS += libgomp
endif

ifeq ($(BR2_GCC_ENABLE_LIBMUDFLAP),y)
ifeq ($(BR2_TOOLCHAIN_HAS_THREADS),y)
TARGET_GCC_USR_LIBS += libmudflapth
else
TARGET_GCC_USR_LIBS += libmudflap
endif
endif

ifneq ($(TARGET_GCC_USR_LIBS),)
define TARGET_GCC_INSTALL_STATIC_LIBS
for i in $(TARGET_GCC_USR_LIBS) ; do \
		cp -dpf $(HOST_DIR)/usr/$(GNU_TARGET_NAME)/lib*/$${i}.a \
			$(STAGING_DIR)/usr/lib/ ; \
	done
endef

ifeq ($(BR2_STATIC_LIBS),)
define TARGET_GCC_INSTALL_SHARED_LIBS
	for i in $(TARGET_GCC_USR_LIBS) ; do \
		cp -dpf $(TARGET_DIR)/usr/$(GNU_TARGET_NAME)/lib*/$${i}.so* \
			$(STAGING_DIR)/usr/lib/ ; \
		cp -dpf $(TARGET_DIR)/usr/$(GNU_TARGET_NAME)/lib*/$${i}.so* \
			$(TARGET_DIR)/usr/lib/ ; \
	done
endef
endif

define TARGET_GCC_INSTALL_USR_LIBS
	mkdir -p $(TARGET_DIR)/usr/lib
	$(TARGET_GCC_INSTALL_STATIC_LIBS)
	$(TARGET_GCC_INSTALL_SHARED_LIBS)
endef
TARGET_GCC_POST_INSTALL_HOOKS += TARGET_GCC_INSTALL_USR_LIBS
endif

$(eval $(autotools-package))
