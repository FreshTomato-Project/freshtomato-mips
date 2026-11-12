# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# To rebuild everything and all configurations:
#  make distclean
#  make V1=whatever V2=sub-whatever VPN=vpn3.6 X
#
# The 1st "whatever" would be the build number - use only when you want the build number to be added 
# to the tomato version; the sub-whatever would be the version note (both optional).
#
# Example:
# make V1=8516 V2="my_build" X
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


export ac_cv_func_malloc_0_nonnull=yes
export SRCBASE := $(shell pwd)
export SRCBASEDIR := $(shell pwd | sed 's/.*release\///g')
RELEASEDIR := $(shell (cd $(SRCBASE)/.. && pwd -P))
CC_LINUX_DIR  ?= $(abspath ../../tools/brcm/hndtools-mipsel-linux/bin/)
CC_UCLIBC_DIR ?= $(abspath ../../tools/brcm/hndtools-mipsel-uclibc/bin/)
export PATH := $(RELEASEDIR)/tools:$(PATH):$(CC_LINUX_DIR):$(CC_UCLIBC_DIR)

include target.mak

export TPROFILE := N
V1 ?= "--def"
VPN ?= "VPN"
PPTPD ?= "n"
KERN_SIZE_OPT ?= y

# Asus firmware version in the TRX header (prevents downgrading to an incompatible firmware at AsusWRT)
FORCE_SN = 386
FORCE_EN = 40000

ifeq ($(NVRAM_SIZE),)
 NVRAM_SIZE = 0
endif

ifeq ($(ASUS_TRX),)
 ASUS_TRX = 0
endif

ifeq ($(WNR3500LV2),)
 WNR3500LV2 = 0
else
 WNRTOOL=$(SRCBASE)/wnrtool
 BOARD_FILE=$(WNRTOOL)/comp-wnr3500lv2.txt
 fw_cfg_file := $(WNRTOOL)/ambitCfg-wnr3500lv2.h
endif

ifeq ($(NVRAM_64K),y)
 EXTRA_64KDESC = ' -64K'
 EXTRA_64KCFLAG = '-DTCONFIG_NVRAM_64K'
else
 EXTRA_64KDESC = ''
 EXTRA_64KCFLAG = ''
endif

-include tomato_profile.mak

# This could be simpler by just using $(TOMATO_PROFILE_NAME) like it used to be,
# but that's fragile.  If you make one certain innocuous change elsewhere in the
# makefile(s), the build will silently be wrong. This way it works properly every time.
current_BUILD_NAME = $(strip $(shell grep "^TOMATO_BUILD_NAME" tomato_profile.mak | cut -d"=" -f2))
current_BUILD_DESC = $(strip $(shell grep "^TOMATO_BUILD_DESC" tomato_profile.mak | cut -d"=" -f2 | sed -e "s/ //g"))
current_BUILD_USB  = $(strip $(shell grep "^TOMATO_BUILD_USB"  tomato_profile.mak | cut -d"=" -f2 | sed -e "s/ //g"))
current_TOMATO_VER = $(strip $(shell grep "TOMATO_MAJOR" router/shared/tomato_version.h | cut -d"\"" -f2)).$(strip $(shell grep "TOMATO_MINOR" router/shared/tomato_version.h | cut -d"\"" -f2))$(if $(filter $(V1),"--def"),,.$(strip $(shell grep -w "TOMATO_BUILD" router/shared/tomato_version.h | cut -d"\"" -f2)))

uppercase_N = $(shell echo $(N) | tr a-z A-Z)
lowercase_N = $(shell echo $(N) | tr A-Z a-z)
uppercase_B = $(shell echo $(B) | tr a-z A-Z)
lowercase_B = $(shell echo $(B) | tr A-Z a-z)

beta = $(if $(filter $(TOMATO_EXPERIMENTAL),1),-beta,)

revision = $(if $(filter $(MIPS32),r2),R2,R1)
branch_rev = K26MIPS$(revision)_$(TARGET_VARIANT)

ifneq ($(V2),)
	current_V2 = $(shell echo -$(V2))
else
	current_V2 = ""
endif

# Macro to inject firmware name and package the firmware (Default: Asus Header)
define CREATE_INJECT_MODEL_SDK6
	# 1. Prepare environment: Create target directory and remove old artifacts
	mkdir -p router/mipsel-uclibc/target/rom/filename
	rm -rf router/mipsel-uclibc/target/rom/filename/*
	rm -f image/linux-lzma.trx
	rm -f fpkg.log
	@echo "" >>fpkg.log
	@echo "***********************" `date` "************************" >>fpkg.log
	@cat router/shared/tomato_version >>fpkg.log
	@echo "" >>fpkg.log

	# 2. Sanitize the model name: Remove quotes and store in a variable
	$(eval SAN_IMAGE := $(shell echo $(1) | tr -d '"' | tr -d "'"))

	# 3. Create a placeholder file with the sanitized name inside the target folder
	printf "" > router/mipsel-uclibc/target/rom/filename/$(SAN_IMAGE)

	# 4. Generate the SquashFS filesystem from the target directory
	ctools/mksquashfs router/mipsel-uclibc/target ctools/target.squashfs -noappend -all-root

	# 5. Build the standard TRX image
	ctools/trx -o image/linux-lzma.trx ctools/vmlinuz-lzma ctools/target.squashfs | tee -a fpkg.log

	# 6. Add ASUS-specific headers and create the final flashable image
	ctools/trx_asus -i image/linux-lzma.trx -r $(2),$(3),$(4),$(5),image/$(SAN_IMAGE) | tee -a fpkg.log

	# 7. Cleanup and archiving
	cp fpkg.log image/fpkg_$(SAN_IMAGE).log
endef

define CREATE_INJECT_MODEL_NETGEAR_SDK6
	# 1. Prepare environment, create target directory and remove old artifacts
	mkdir -p router/mipsel-uclibc/target/rom/filename
	rm -rf router/mipsel-uclibc/target/rom/filename/*
	rm -f image/linux-lzma.trx
	rm -f fpkg.log
	@echo "" >>fpkg.log
	@echo "***********************" `date` "************************" >>fpkg.log
	@cat router/shared/tomato_version >>fpkg.log
	@echo "" >>fpkg.log

	# 2. Sanitize the model name: Remove quotes and store in a variable
	$(eval SAN_IMAGE := $(shell echo $(1) | tr -d '"' | tr -d "'"))

	# 3. Create a placeholder file with the sanitized name inside the target folder
	printf "" > router/mipsel-uclibc/target/rom/filename/$(SAN_IMAGE)

	# 4. Generate the SquashFS filesystem from the target directory
	ctools/mksquashfs router/mipsel-uclibc/target ctools/target.squashfs -noappend -all-root

	# 5. Build the standard TRX image
	ctools/trx -o image/linux-lzma.trx ctools/vmlinuz-lzma ctools/target.squashfs | tee -a fpkg.log

	# 6. Add Netgear-specific headers and create the final flashable image
	$(SRCBASE)/wnrtool/mkchkimg -o image/$(SAN_IMAGE) \
	-k image/linux-lzma.trx \
	-b $(2) -r 2 2>&1 | tee -a fpkg.log

	# 7. Cleanup and archiving
	cp fpkg.log image/fpkg_$(SAN_IMAGE).log
endef

# Macro to inject firmware name and package the firmware
define CREATE_INJECT_MODEL_GEN
	# 1. Prepare environment, create target directory and remove old artifacts
	mkdir -p router/mipsel-uclibc/target/rom/filename
	rm -rf router/mipsel-uclibc/target/rom/filename/*
	rm -f router/mipsel-uclibc/target.image
	rm -f fpkg.log
	@echo "" >>fpkg.log
	@echo "***********************" `date` "************************" >>fpkg.log
	@cat router/shared/tomato_version >>fpkg.log
	@echo "" >>fpkg.log

	# 2. Sanitize the model name: Remove quotes and store in a variable
	$(eval SAN_IMAGE := $(shell echo $(1) | tr -d '"' | tr -d "'"))

	# 3. Create a placeholder file with the sanitized name inside the target folder
	printf "" > router/mipsel-uclibc/target/rom/filename/$(SAN_IMAGE)

	# 4. Generate the SquashFS filesystem from the target directory
	$(LINUXDIR)/scripts/squashfs/mksquashfs-lzma router/mipsel-uclibc/target router/mipsel-uclibc/target.image -all-root -noappend -no-duplicates | tee router/target.info
	cat router/target.info >>fpkg.log

	# 5. Build Generic TRX using fpkg
	btools/fpkg -i lzma-loader/loader.gz \
		-i $(LINUXDIR)/arch/mips/brcm-boards/bcm947xx/compressed/vmlinuz \
		-a 1024 \
		-i router/mipsel-uclibc/target.image \
		-t image/$(SAN_IMAGE) | tee -a fpkg.log

	# 6. Cleanup and archiving
	cp fpkg.log image/fpkg_$(SAN_IMAGE).log
	rm -f router/target.info
endef

define CREATE_INJECT_MODEL_WNR3500LV2
	# 1. Prepare environment, create target directory and remove old artifacts
	mkdir -p router/mipsel-uclibc/target/rom/filename
	rm -rf router/mipsel-uclibc/target/rom/filename/*
	rm -f router/mipsel-uclibc/target.image
	rm -f fpkg.log
	@echo "" >>fpkg.log
	@echo "***********************" `date` "************************" >>fpkg.log
	@cat router/shared/tomato_version >>fpkg.log
	@echo "" >>fpkg.log

	# 2. Sanitize the model name: Remove quotes and store in a variable
	$(eval SAN_IMAGE := $(shell echo $(1) | tr -d '"' | tr -d "'"))

	# 3. Create a placeholder file with the sanitized name inside the target folder
	printf "" > router/mipsel-uclibc/target/rom/filename/$(SAN_IMAGE)

	# 4. Generate the SquashFS filesystem from the target directory
	$(LINUXDIR)/scripts/squashfs/mksquashfs-lzma router/mipsel-uclibc/target router/mipsel-uclibc/target.image -all-root -noappend -no-duplicates | tee router/target.info
	cat router/target.info >>fpkg.log

	# 5. Build the standard TRX image
	$(WNRTOOL)/trx -o image/freshtomato-wnr3500lv2.trx image/vmlinux.lzma router/mipsel-uclibc/target.image | tee -a fpkg.log

	# 6. Cleanup and archiving
	rm -f image/vmlinux.bin image/vmlinux.lzma
	cp fpkg.log image/fpkg_$(SAN_IMAGE).log
	rm -f router/target.info
endef

define CREATE_INJECT_MODEL_WNDR
	# 1. Prepare environment, create target directory and remove old artifacts
	mkdir -p router/mipsel-uclibc/target/rom/filename
	rm -rf router/mipsel-uclibc/target/rom/filename/*
	rm -f router/mipsel-uclibc/target.image
	rm -f image/linux-lzma.trx
	rm -f fpkg.log
	@echo "" >>fpkg.log
	@echo "***********************" `date` "************************" >>fpkg.log
	@cat router/shared/tomato_version >>fpkg.log
	@echo "" >>fpkg.log

	# 2. Sanitize the model name: Remove quotes and store in a variable
	$(eval SAN_IMAGE := $(shell echo $(1) | tr -d '"' | tr -d "'"))

	# 3. Create a placeholder file with the sanitized name inside the target folder
	printf "" > router/mipsel-uclibc/target/rom/filename/$(SAN_IMAGE)

	# 4. Generate the SquashFS filesystem from the target directory
	$(LINUXDIR)/scripts/squashfs/mksquashfs-lzma router/mipsel-uclibc/target router/mipsel-uclibc/target.image -all-root -noappend -no-duplicates | tee router/target.info
	cat router/target.info >>fpkg.log

	# 5. Build Generic TRX using fpkg
	btools/fpkg -i lzma-loader/loader.gz \
		-i $(LINUXDIR)/arch/mips/brcm-boards/bcm947xx/compressed/vmlinuz \
		-a 1024 \
		-i router/mipsel-uclibc/target.image \
		-t image/linux-lzma.trx | tee -a fpkg.log

	# 6. Add Netgear-specific headers and create the final flashable image
	$(SRCBASE)/wnrtool/mkchkimg -o image/$(SAN_IMAGE) \
	-k image/linux-lzma.trx \
	-b $(2) -r 2 2>&1 | tee -a fpkg.log

	# 7. Cleanup and archiving
	cp fpkg.log image/fpkg_$(SAN_IMAGE).log
	rm -f router/target.info
endef

define CREATE_INJECT_MODEL_LINKSYS
	$(if $(filter -l -m,$(2)),,$(error ERROR: Argument 2 must be '-l' or '-m' but was '$(2)'))
	# 1. Prepare environment, create target directory and remove old artifacts
	mkdir -p router/mipsel-uclibc/target/rom/filename
	rm -rf router/mipsel-uclibc/target/rom/filename/*
	rm -f router/mipsel-uclibc/target.image
	rm -f fpkg.log
	@echo "" >>fpkg.log
	@echo "***********************" `date` "************************" >>fpkg.log
	@cat router/shared/tomato_version >>fpkg.log
	@echo "" >>fpkg.log

	# 2. Sanitize the model name: Remove quotes and store in a variable
	$(eval SAN_IMAGE := $(shell echo $(1) | tr -d '"' | tr -d "'"))

	# 3. Create a placeholder file with the sanitized name inside the target folder
	printf "" > router/mipsel-uclibc/target/rom/filename/$(SAN_IMAGE)

	# 4. Generate the SquashFS filesystem from the target directory
	$(LINUXDIR)/scripts/squashfs/mksquashfs-lzma router/mipsel-uclibc/target router/mipsel-uclibc/target.image -all-root -noappend -no-duplicates | tee router/target.info
	cat router/target.info >>fpkg.log

	# 5. Build Linksys image using fpkg
	btools/fpkg -i lzma-loader/loader.gz \
		-i $(LINUXDIR)/arch/mips/brcm-boards/bcm947xx/compressed/vmlinuz \
		-a 1024 \
		-i router/mipsel-uclibc/target.image \
		$(2) $(3),image/$(SAN_IMAGE) | tee -a fpkg.log

	# 6. Cleanup and archiving
	cp fpkg.log image/fpkg_$(SAN_IMAGE).log
	rm -f router/target.info
endef

define CREATE_INJECT_MODEL_BELKIN
	# 1. Prepare environment, create target directory and remove old artifacts
	mkdir -p router/mipsel-uclibc/target/rom/filename
	rm -rf router/mipsel-uclibc/target/rom/filename/*
	rm -f router/mipsel-uclibc/target.image
	rm -f fpkg.log
	@echo "" >>fpkg.log
	@echo "***********************" `date` "************************" >>fpkg.log
	@cat router/shared/tomato_version >>fpkg.log
	@echo "" >>fpkg.log

	# 2. Sanitize the model name: Remove quotes and store in a variable
	$(eval SAN_IMAGE := $(shell echo $(1) | tr -d '"' | tr -d "'"))

	# 3. Create a placeholder file with the sanitized name inside the target folder
	printf "" > router/mipsel-uclibc/target/rom/filename/$(SAN_IMAGE)

	# 4. Generate the SquashFS filesystem from the target directory
	$(LINUXDIR)/scripts/squashfs/mksquashfs-lzma router/mipsel-uclibc/target router/mipsel-uclibc/target.image -all-root -noappend -no-duplicates | tee router/target.info
	cat router/target.info >>fpkg.log

	# 5. Build Linksys image using fpkg
	btools/fpkg -i lzma-loader/loader.gz \
		-i $(LINUXDIR)/arch/mips/brcm-boards/bcm947xx/compressed/vmlinuz \
		-a 1024 \
		-i router/mipsel-uclibc/target.image \
		-b $(2),image/$(SAN_IMAGE) | tee -a fpkg.log

	# 6. Cleanup and archiving
	cp fpkg.log image/fpkg_$(SAN_IMAGE).log
	rm -f router/target.info
endef

# EA6500 v1 stock CFE expects a raw gzip kernel followed by the SDK6 SquashFS.
define CREATE_INJECT_MODEL_EA6500V1
	$(eval SAN_IMAGE := $(shell echo $(1) | tr -d '"' | tr -d "'"))
	mkdir -p router/mipsel-uclibc/target/rom/filename
	rm -rf router/mipsel-uclibc/target/rom/filename/*
	printf "" > router/mipsel-uclibc/target/rom/filename/$(SAN_IMAGE)
	rm -f image/$(SAN_IMAGE) image/$(SAN_IMAGE).tmp ctools/piggy.gz ctools/target.squashfs
	@echo "Creating Linksys EA6500 v1 firmware" > fpkg.log
	@cat router/shared/tomato_version >> fpkg.log
	ctools/mksquashfs router/mipsel-uclibc/target ctools/target.squashfs -noappend -all-root
	gzip -9 -n -c ctools/piggy > ctools/piggy.gz
	gzip -t ctools/piggy.gz
	@set -e; \
		trap 'rm -f image/$(SAN_IMAGE).tmp' EXIT; \
		btools/fpkg -i ctools/piggy.gz -a 1024 -i ctools/target.squashfs -t image/$(SAN_IMAGE).tmp >> fpkg.log; \
		size=$$(wc -c < image/$(SAN_IMAGE).tmp); \
		if [ "$$size" -gt 25000000 ]; then \
			echo "ERROR: EA6500 v1 image exceeds conservative 25 MB stock UI limit ($$size bytes)" >&2; \
			exit 1; \
		fi; \
		mv image/$(SAN_IMAGE).tmp image/$(SAN_IMAGE)
	cp fpkg.log image/fpkg_$(SAN_IMAGE).log
	@cat fpkg.log
	rm -f ctools/piggy.gz
endef

# prepare variables for filename
fn_BUILD_USB = $(if $(filter $(current_BUILD_USB),"USB"),$(shell echo -$(current_BUILD_USB)))
fn_NVRAM_SIZE = $(if $(filter $(NVRAM_SIZE),0),,$(shell echo -NVRAM$(NVRAM_SIZE)K))

tomato_ver:
	@echo ""
	@btools/uversion.pl --gen $(V1) $(branch_rev) $(beta) $(V2) $(current_BUILD_USB) $(current_BUILD_DESC)

include build.mak

all: tomato_ver build_all
	@echo ""
	@echo "-----------------"
	@echo `cat router/shared/tomato_version` " ready"
	@echo "-----------------"
	@echo "\033[41;1m   FreshTomato build done! \033[0m\033]2;FreshTomato build done!\007"

clean:
	@touch router/.config
	@rm -f router/config_[a-z]
	@rm -f router/busybox/config_[a-z]
	@$(MAKE) -C router $@
	@-rmdir router/mipsel-uclibc

cleanimage:
	@rm -f fpkg.log
	@rm -fr image/*
	@rm -f router/.config
	@touch router/.config 
	@-mkdir image

cleantools:
	@$(MAKE) -C $(LINUXDIR)/scripts/squashfs clean
	@$(MAKE) -C btools clean

cleankernel:
	@cd $(LINUXDIR) && \
	mv .config save-config && \
	$(MAKE) distclean || true; \
	cp -p save-config .config || true

kernel:
	@$(MAKE) -C router kernel
	@ls -l $(LINUXDIR)/arch/mips/brcm-boards/bcm947xx/compressed/zImage

distclean: clean cleanimage cleankernel cleantools
ifneq ($(INSIDE_MAK),1)
	@$(MAKE) -C router $@ INSIDE_MAK=1
endif
	mv router/busybox/.config busybox-saved-config || true
	@$(MAKE) -C router/busybox distclean
	@rm -f router/busybox/config_current
	@cp -p busybox-saved-config router/busybox/.config || true
	@cp -p router/busybox/.config  router/busybox/config_current || true
	@rm -f router/config_current
	@rm -f router/.config.cmd router/.config.old router/.config
	@rm -f router/libfoo_xref.txt
	@rm -f tomato_profile.mak router/shared/tomato_profile.h
	@touch tomato_profile.mak
	@touch router/shared/tomato_profile.h

prepk:
	@cd $(LINUXDIR) ; \
		rm -f config_current ; \
		ln -s config_base config_current ; \
		cp -f config_current .config
	$(MAKE) -C $(LINUXDIR) oldconfig

what:
	@echo ""
	@echo "$(current_BUILD_DESC)-$(current_BUILD_NAME)-$(TOMATO_PROFILE_NAME) Profile"
	@echo ""

# The methodology for making the different builds is to
# copy the "base" config file to the "target" config file and
# replace boolean TCONFIG values in place. Every TCONFIG symbol
# changed by RouterOptions must already exist in config_base as
# either "TCONFIG_x=y" or "# TCONFIG_x is not set".

# Common options for "make bin":
# BUILD_DESC (Std|Lite|Ext|...)
# KERN_SIZE_OPT
# USB ("USB"|"")
# JFFSv1 | NO_JFFS
# NO_CIFS NO_SAMBA NO_HTTPS NO_ADBLOCK NO_DMZ NO_DMZMAC NO_XXTP NO_L7 NO_L7PAT NO_LIBOPT NO_FTP NO_USBAPP NO_KEYGEN
# FTPSSL OPENVPN IPV6SUPP EBTABLES NTFS UFSD MEDIASRV BBEXTRAS USBEXTRAS BCM57 SLIM NOCAT NGINX NANO PROXY
# NFS BTCLIENT BTGUI TR_EXTRAS SNMP HFS UPS DNSCRYPT DNSSEC STUBBY PPTPD TOR TINC IPSEC RAID MICROSD USBAP IPERF
# KEYGEN HAVEGED CTF BRCM_NAND_JFFS2 MDNS ROAM OPENSSL11 OPENSSL30 WOLFSSL WOLFSSLMIN QRCODE AIO MWAN_MAX BRIDGE_COUNT
# NAND NVRAM_64K NVRAM_SIZE
# MIPS-specific options:
# MIPS32 (r2|r1)
# WNR3500LV2 (0|1)
# KERN_SIZE_OPT_MORE NO_ZEBRA OPTIMIZE_SIZE_MORE BCMNAT SDHC TERMLIB ADVTHEMES BONDING
# AC66U R6300V1 WNDR4500V1 WNDR4500V2 EA6500V1 FULL_EXTRAS

define RouterOptions
	@( \
	config_y() { \
		grep -q -e "^$$1=y$$" -e "^# $$1 is not set$$" $(1) || { echo "ERROR: $$1 missing from $(1)" >&2; exit 1; }; \
		sed -i "s/^# $$1 is not set$$/$$1=y/" $(1); \
	}; \
	config_n() { \
		grep -q -e "^$$1=y$$" -e "^# $$1 is not set$$" $(1) || { echo "ERROR: $$1 missing from $(1)" >&2; exit 1; }; \
		sed -i "s/^$$1=y$$/# $$1 is not set/" $(1); \
	}; \
	config_value() { \
		grep -q "^$$1=" $(1) || { echo "ERROR: $$1 missing from $(1)" >&2; exit 1; }; \
		sed -i "s/^$$1=.*/$$1=$$2/" $(1); \
	}; \
	config_range() { \
		case "$$2" in ''|*[!0-9]*) echo "ERROR: $$1 must be an integer in range $$3..$$4" >&2; exit 1;; esac; \
		if [ "$$2" -lt "$$3" ] || [ "$$2" -gt "$$4" ]; then echo "ERROR: $$1=$$2 outside supported range $$3..$$4" >&2; exit 1; fi; \
		config_value "$$1" "$$2"; \
	}; \
	if [ -n "$(MWAN_MAX)" ]; then \
		config_range TCONFIG_MWAN_MAX "$(MWAN_MAX)" 1 8; \
	elif [ "$(TARGET_PLATFORM)" = "MIPS" ]; then \
		if [ "$(NVRAM_64K)" = "y" ] || [ "$(NVRAM_SIZE)" = "60" ] || [ "$(NVRAM_SIZE)" = "64" ]; then \
			config_range TCONFIG_MWAN_MAX "4" 1 8; \
		else \
			config_range TCONFIG_MWAN_MAX "2" 1 8; \
		fi; \
	elif [ "$(TARGET_PLATFORM)" = "ARM" ]; then \
		if [ "$(NVRAM_64K)" = "y" ] || [ "$(NVRAM_128K)" = "y" ] || [ "$(NVRAM_SIZE)" = "60" ] || [ "$(NVRAM_SIZE)" = "64" ]; then \
			config_range TCONFIG_MWAN_MAX "4" 1 8; \
		else \
			config_range TCONFIG_MWAN_MAX "2" 1 8; \
		fi; \
	fi; \
	if [ -n "$(BRIDGE_COUNT)" ]; then \
		config_range TCONFIG_BRIDGE_COUNT "$(BRIDGE_COUNT)" 1 16; \
	fi; \
	config_n TCONFIG_BCMARM; \
	config_n TCONFIG_BCM7; \
	config_n TCONFIG_BCM714; \
	config_n TCONFIG_MIPS_RT; \
	config_n TCONFIG_MIPS_RTN; \
	config_n TCONFIG_MIPS_RTAC; \
	case "$(TARGET_PLATFORM):$(TARGET_VARIANT)" in \
		ARM:SDK6) config_y TCONFIG_BCMARM ;; \
		ARM:SDK7) config_y TCONFIG_BCMARM; config_y TCONFIG_BCM7 ;; \
		ARM:SDK714) config_y TCONFIG_BCMARM; config_y TCONFIG_BCM7; config_y TCONFIG_BCM714 ;; \
		MIPS:RT) config_y TCONFIG_MIPS_RT ;; \
		MIPS:RTN) config_y TCONFIG_MIPS_RTN ;; \
		MIPS:RTAC) config_y TCONFIG_MIPS_RTAC ;; \
		*) echo "ERROR: unsupported target platform '$(TARGET_PLATFORM):$(TARGET_VARIANT)'" >&2; exit 1 ;; \
	esac; \
	if [ "$(AIO)" = "y" ]; then \
		config_y TCONFIG_AIO; \
	fi; \
	if [ "$(TARGET_PLATFORM)" = "MIPS" ]; then \
		if [ "$(AIO)" = "y" ]; then \
			config_n TCONFIG_OPTIMIZE_SIZE; \
		else \
			config_y TCONFIG_OPTIMIZE_SIZE; \
		fi; \
	elif [ "$(DO_OPTIMIZE_SIZE)" = "y" ]; then \
		config_y TCONFIG_OPTIMIZE_SIZE; \
	fi; \
	if [ "$(SLIM)" = "y" ]; then \
		config_n TCONFIG_EMF; \
	else \
		config_y TCONFIG_EMF; \
	fi; \
	if [ "$(JFFSv1)" = "y" ]; then \
		config_y TCONFIG_JFFSV1; \
	else \
		config_n TCONFIG_JFFSV1; \
	fi; \
	if [ "$(IPSEC)" = "y" ]; then \
		config_y TCONFIG_IPSEC; \
	else \
		config_n TCONFIG_IPSEC; \
	fi; \
	if [ "$(RAID)" = "y" ]; then \
		config_y TCONFIG_RAID; \
	else \
		config_n TCONFIG_RAID; \
	fi; \
	if [ "$(MIPS32)" = "r2" ]; then \
		config_y TCONFIG_MIPSR2; \
	else \
		config_n TCONFIG_MIPSR2; \
	fi; \
	if [ "$(USB)" = "USB" ]; then \
		config_y TCONFIG_USB; \
		if [ "$(USBEXTRAS)" = "y" ]; then \
			config_y TCONFIG_USB_EXTRAS; \
		fi; \
		if [ "$(NTFS)" = "y" ]; then \
			config_y TCONFIG_NTFS; \
		fi; \
		if [ "$(UFSD)" = "y" ]; then \
			config_y TCONFIG_UFSD; \
		elif [ "$(UFSD)" = "ASUS" ]; then \
			config_y TCONFIG_UFSDA; \
		fi; \
		if [ "$(TUXERA)" = "y" ]; then \
			config_y TCONFIG_TUXERA; \
		fi; \
		if [ "$(TUXERA_HFS)" = "y" ]; then \
			config_y TCONFIG_TUX_HFS; \
		fi; \
		if [ "$(ZFS)" = "y" ]; then \
			config_y TCONFIG_ZFS; \
		fi; \
		if [ "$(HFS)" = "y" ]; then \
			config_y TCONFIG_HFS; \
		fi; \
		if [ "$(MEDIASRV)" = "y" ]; then \
			config_y TCONFIG_MEDIA_SERVER; \
		fi; \
	else \
		config_n TCONFIG_USB; \
	fi; \
	if [ "$(NO_SAMBA)" = "y" ]; then \
		config_n TCONFIG_SAMBASRV; \
	fi; \
	if [ "$(NO_ZEBRA)" = "y" ]; then \
		config_n TCONFIG_ZEBRA; \
	fi; \
	if [ "$(NO_JFFS)" = "y" ]; then \
		config_n TCONFIG_JFFS2; \
	fi; \
	if [ "$(NO_CIFS)" = "y" ]; then \
		config_n TCONFIG_CIFS; \
	fi; \
	if [ "$(NO_HTTPS)" = "y" ]; then \
		config_n TCONFIG_HTTPS; \
	fi; \
	if [ "$(NO_ADBLOCK)" = "y" ]; then \
		config_n TCONFIG_ADBLOCK; \
	fi; \
	if [ "$(NO_DMZ)" = "y" ]; then \
		config_n TCONFIG_DMZ; \
	elif [ "$(NO_DMZMAC)" = "y" ]; then \
		config_n TCONFIG_DMZMAC; \
	fi; \
	if [ "$(NO_XXTP)" = "y" ]; then \
		config_n TCONFIG_L2TP; \
		config_n TCONFIG_PPTP; \
	fi; \
	if [ "$(NO_L7)" = "y" ]; then \
		config_n TCONFIG_L7; \
	elif [ "$(NO_L7PAT)" = "y" ]; then \
		config_n TCONFIG_L7PAT; \
	fi; \
	if [ "$(NO_LIBOPT)" = "y" ]; then \
		config_n TCONFIG_OPTIMIZE_SHARED_LIBS; \
	fi; \
	if [ "$(EBTABLES)" = "y" ]; then \
		config_y TCONFIG_EBTABLES; \
	fi; \
	if [ "$(IPV6SUPP)" = "y" ]; then \
		config_y TCONFIG_IPV6; \
	fi; \
	if [ "$(NOCAT)" = "y" ]; then \
		config_y TCONFIG_NOCAT; \
	fi; \
	if [ "$(NGINX)" = "y" ]; then \
		config_y TCONFIG_NGINX; \
	fi; \
	if [ "$(FTPSSL)" = "y" ] && [ "$(NO_FTP)" = "y" ]; then \
		echo "ERROR: FTPSSL requires FTP; remove NO_FTP or FTPSSL" >&2; \
		exit 1; \
	fi; \
	if [ "$(FTPSSL)" = "y" ] && { [ "$(WOLFSSL)" = "y" ] || [ "$(WOLFSSLMIN)" = "y" ]; }; then \
		echo "ERROR: FTPSSL is not supported with WOLFSSL/WOLFSSLMIN" >&2; \
		exit 1; \
	fi; \
	if [ "$(FTPSSL)" = "y" ]; then \
		config_y TCONFIG_FTP_SSL; \
	fi; \
	if [ "$(OPENVPN)" = "y" ]; then \
		config_y TCONFIG_OPENVPN; \
	fi; \
	if [ "$(NO_FTP)" = "y" ]; then \
		config_n TCONFIG_FTP; \
		config_n TCONFIG_FTP_SSL; \
	fi; \
	if [ "$(WIREGUARD)" = "y" ]; then \
		config_y TCONFIG_WIREGUARD; \
	fi; \
	if [ "$(PPTPD)" = "y" ]; then \
		config_y TCONFIG_PPTPD; \
	fi; \
	if [ "$(BTCLIENT)" = "y" ]; then \
		config_y TCONFIG_BT; \
		config_y TCONFIG_BBT; \
	fi; \
	if [ "$(BTGUI)" = "y" ]; then \
		config_y TCONFIG_BT; \
	fi; \
	if [ "$(TR_EXTRAS)" = "y" ]; then \
		config_y TCONFIG_TR_EXTRAS; \
	fi; \
	if [ "$(NFS)" = "y" ]; then \
		config_y TCONFIG_NFS; \
	fi; \
	if [ "$(SNMP)" = "y" ]; then \
		config_y TCONFIG_SNMP; \
	fi; \
	if [ "$(SDHC)" = "y" ]; then \
		config_y TCONFIG_SDHC; \
	fi; \
	if [ "$(DNSSEC)" = "y" ]; then \
		config_y TCONFIG_DNSSEC; \
	fi; \
	if [ "$(UPS)" = "y" ]; then \
		config_y TCONFIG_UPS; \
	fi; \
	if [ "$(NANO)" = "y" ]; then \
		config_y TCONFIG_NANO; \
	fi; \
	if [ "$(DNSCRYPT)" = "y" ]; then \
		config_y TCONFIG_DNSCRYPT; \
	fi; \
	if [ "$(STUBBY)" = "y" ]; then \
		config_y TCONFIG_STUBBY; \
	fi; \
	if [ "$(NVRAM_64K)" = "y" ]; then \
		config_y TCONFIG_NVRAM_64K; \
	fi; \
	if [ "$(NVRAM_128K)" = "y" ]; then \
		config_y TCONFIG_NVRAM_128K; \
	fi; \
	if [ "$(DRAM_512M)" = "y" ]; then \
		config_y TCONFIG_DRAM_512M; \
	fi; \
	if [ "$(TOR)" = "y" ]; then \
		config_y TCONFIG_TOR; \
	fi; \
	if [ "$(MICROSD)" = "y" ]; then \
		config_y TCONFIG_MICROSD; \
	fi; \
	if [ "$(USBAP)" = "y" ]; then \
		config_y TCONFIG_USBAP; \
		if [ "$(NO_USBAPP)" = "y" ]; then \
			config_y TCONFIG_REMOVE_USBAPP; \
		fi; \
	fi; \
	model_flags=0; \
	[ "$(AC66U)" = "y" ] && model_flags=$$((model_flags + 1)); \
	[ "$(R6300V1)" = "y" ] && model_flags=$$((model_flags + 1)); \
	[ "$(WNDR4500V1)" = "y" ] && model_flags=$$((model_flags + 1)); \
	[ "$(WNDR4500V2)" = "y" ] && model_flags=$$((model_flags + 1)); \
	[ "$(EA6500V1)" = "y" ] && model_flags=$$((model_flags + 1)); \
	if [ "$$model_flags" -gt 1 ]; then \
		echo "ERROR: select only one RT-AC model discriminator (AC66U, R6300V1, WNDR4500V1, WNDR4500V2 or EA6500V1)" >&2; \
		exit 1; \
	fi; \
	if [ "$$model_flags" -gt 0 ] && [ "$(TARGET_VARIANT)" != "RTAC" ]; then \
		echo "ERROR: RT-AC model discriminators require the RT-AC target family" >&2; \
		exit 1; \
	fi; \
	if [ "$(EA6500V1)" = "y" ]; then \
		if [ "$(MIPS32)" != "r2" ] || [ "$(NVRAM_64K)" != "y" ] || [ "$(NAND)" != "y" ] || [ "$(NVRAM_SIZE)" != "0" ] || [ "$(ASUS_TRX)" != "0" ]; then \
			echo "ERROR: EA6500V1 requires MIPS R2, 64K NVRAM, NAND and no ASUS_TRX" >&2; \
			exit 1; \
		fi; \
		config_y TCONFIG_EA6500V1; \
	else \
		config_n TCONFIG_EA6500V1; \
	fi; \
	if [ "$(AC66U)" = "y" ]; then \
		config_y TCONFIG_AC66U; \
	fi; \
	if [ "$(R6300V1)" = "y" ]; then \
		config_y TCONFIG_R6300V1; \
	fi; \
	if [ "$(WNDR4500V1)" = "y" ]; then \
		config_y TCONFIG_WNDR4500V1; \
	fi; \
	if [ "$(WNDR4500V2)" = "y" ]; then \
		config_y TCONFIG_WNDR4500V2; \
	fi; \
	if [ "$(CTF)" = "y" ]; then \
		config_y TCONFIG_CTF; \
	fi; \
	if [ "$(NAND)" = "y" ]; then \
		config_y TCONFIG_NAND; \
	fi; \
	if [ "$(AC3200)" = "y" ]; then \
		config_y TCONFIG_AC3200; \
	fi; \
	if [ "$(AC5300)" = "y" ]; then \
		config_y TCONFIG_AC5300; \
	fi; \
	if [ "$(BSD)" = "y" ]; then \
		config_y TCONFIG_BCMBSD; \
	fi; \
	if [ "$(ROAM)" = "y" ]; then \
		config_y TCONFIG_ROAM; \
	fi; \
	if [ "$(BCMNAT)" = "y" ]; then \
		config_y TCONFIG_BCMNAT; \
	fi; \
	if [ "$(BCMSMP)" = "y" ]; then \
		config_y TCONFIG_BCMSMP; \
	fi; \
	if [ "$(PROXYSTA)" = "y" ]; then \
		config_y TCONFIG_PROXYSTA; \
	fi; \
	if [ "$(DPSTA)" = "y" ]; then \
		config_y TCONFIG_DPSTA; \
	fi; \
	if [ "$(GRO)" = "y" ]; then \
		config_y TCONFIG_GROCTRL; \
	fi; \
	if [ "$(BCMFA)" = "y" ]; then \
		config_y TCONFIG_BCMFA; \
	fi; \
	if [ "$(TINC)" = "y" ]; then \
		config_y TCONFIG_TINC; \
	fi; \
	ssl_providers=0; \
	[ "$(OPENSSL11)" = "y" ] && ssl_providers=$$((ssl_providers + 1)); \
	[ "$(OPENSSL30)" = "y" ] && ssl_providers=$$((ssl_providers + 1)); \
	if [ "$(WOLFSSL)" = "y" ] || [ "$(WOLFSSLMIN)" = "y" ]; then ssl_providers=$$((ssl_providers + 1)); fi; \
	if [ "$$ssl_providers" -gt 1 ]; then \
		echo "ERROR: select only one TLS/SSL provider (OPENSSL11, OPENSSL30 or WOLFSSL/WOLFSSLMIN)" >&2; \
		exit 1; \
	fi; \
	if [ "$(OPENSSL11)" = "y" ]; then \
		config_y TCONFIG_OPENSSL11; \
	fi; \
	if [ "$(OPENSSL30)" = "y" ]; then \
		config_y TCONFIG_OPENSSL30; \
	fi; \
	if [ "$(WOLFSSL)" = "y" ]; then \
		config_y TCONFIG_WOLFSSL; \
	fi; \
	if [ "$(WOLFSSLMIN)" = "y" ]; then \
		config_y TCONFIG_WOLFSSL; \
		config_y TCONFIG_WOLFSSLMIN; \
	fi; \
	if [ "$(IPERF)" = "y" ]; then \
		config_y TCONFIG_IPERF; \
	fi; \
	if [ "$(KEYGEN)" = "y" ] && [ "$(NO_KEYGEN)" = "" ]; then \
		config_y TCONFIG_KEYGEN; \
	fi; \
	if [ "$(TERMLIB)" = "y" ]; then \
		config_y TCONFIG_TERMLIB; \
	fi; \
	if [ "$(ADVTHEMES)" = "y" ]; then \
		config_y TCONFIG_ADVTHEMES; \
	fi; \
	if [ "$(NVRAM_SIZE)" = "32" ]; then \
		config_y TCONFIG_NVRAM_32K; \
	fi; \
	if [ "$(BRCM_NAND_JFFS2)" = "y" ]; then \
		config_y TCONFIG_BRCM_NAND_JFFS2; \
	fi; \
	if [ "$(BONDING)" = "y" ]; then \
		config_y TCONFIG_BONDING; \
	fi; \
	if [ "$(MDNS)" = "y" ]; then \
		config_y TCONFIG_MDNS; \
	fi; \
	if [ "$(PROXY)" = "y" ]; then \
		config_y TCONFIG_PROXY; \
	fi; \
	if [ "$(QRCODE)" = "y" ]; then \
		config_y TCONFIG_QRCODE; \
	fi; \
	if [ "$(FANCTRL)" = "y" ]; then \
		config_y TCONFIG_FANCTRL; \
	fi; \
	if [ "$(OPTIMIZE_SIZE_MORE)" = "y" ]; then \
		config_y TCONFIG_OPTIMIZE_SIZE_MORE; \
	fi; \
	if [ "$(CONNTRACK_TOOL)" = "y" ]; then \
		config_y TCONFIG_CONNTRACK_TOOL; \
	fi; \
	if [ "$(IRQBALANCE)" = "y" ]; then \
		config_y TCONFIG_IRQBALANCE; \
	fi; \
	if [ "$(NO_TRXKEY)" = "y" ]; then \
		config_n TCONFIG_TRXKEY; \
	fi; \
	if [ "$(EXTSW)" = "y" ]; then \
		config_y TCONFIG_EXTSW; \
	fi; \
	if [ "$(HAVEGED)" = "y" ]; then \
		config_y TCONFIG_HAVEGED; \
	fi; \
	)
endef

define BusyboxOptions
	@( \
	if [ "$(NO_CIFS)" = "y" ]; then \
		sed -i "/CONFIG_FEATURE_MOUNT_CIFS/d" $(1); \
		echo "# CONFIG_FEATURE_MOUNT_CIFS is not set" >>$(1); \
	fi; \
	if [ "$(BBEXTRAS)" = "y" ]; then \
		sed -i "/CONFIG_SENDMAIL/d" $(1); \
		echo "CONFIG_SENDMAIL=y" >>$(1); \
		sed -i "/CONFIG_WHOIS/d" $(1); \
		echo "CONFIG_WHOIS=y" >>$(1); \
		sed -i "/CONFIG_FEATURE_SORT_BIG/d" $(1); \
		echo "CONFIG_FEATURE_SORT_BIG=y" >>$(1); \
		sed -i "/CONFIG_CLEAR/d" $(1); \
		echo "CONFIG_CLEAR=y" >>$(1); \
		sed -i "/CONFIG_NICE/d" $(1); \
		echo "CONFIG_NICE=y" >>$(1); \
		sed -i "/CONFIG_SETCONSOLE/d" $(1); \
		echo "CONFIG_SETCONSOLE=y" >>$(1); \
		if [ "$(TARGET_VARIANT)" != "RT" ]; then \
			sed -i "/CONFIG_MKFIFO/d" $(1); \
			echo "CONFIG_MKFIFO=y" >>$(1); \
		fi; \
		sed -i "/CONFIG_SEQ/d" $(1); \
		echo "CONFIG_SEQ=y" >>$(1); \
		sed -i "/CONFIG_STTY/d" $(1); \
		echo "CONFIG_STTY=y" >>$(1); \
	fi; \
	if [ "$(USB)" = "USB" ]; then \
		if [ "$(USBEXTRAS)" = "y" ]; then \
			sed -i "/CONFIG_FDISK/d" $(1); \
			echo "CONFIG_FDISK=y" >>$(1); \
			sed -i "/CONFIG_FEATURE_FDISK_WRITABLE/d" $(1); \
			echo "CONFIG_FEATURE_FDISK_WRITABLE=y" >>$(1); \
			sed -i "/CONFIG_FDISK_SUPPORT_LARGE_DISKS/d" $(1); \
			echo "CONFIG_FDISK_SUPPORT_LARGE_DISKS=y" >>$(1); \
			sed -i "/CONFIG_FEATURE_GPT_LABEL/d" $(1); \
			echo "CONFIG_FEATURE_GPT_LABEL=y" >>$(1); \
			sed -i "/CONFIG_MKFS_VFAT/d" $(1); \
			echo "CONFIG_MKFS_VFAT=y" >>$(1); \
			sed -i "/CONFIG_MKSWAP/d" $(1); \
			echo "CONFIG_MKSWAP=y" >>$(1); \
			sed -i "/CONFIG_FEATURE_MKSWAP_UUID/d" $(1); \
			echo "CONFIG_FEATURE_MKSWAP_UUID=y" >>$(1); \
			sed -i "/CONFIG_FSYNC/d" $(1); \
			echo "CONFIG_FSYNC=y" >>$(1); \
			sed -i "/CONFIG_LSUSB/d" $(1); \
			echo "CONFIG_LSUSB=y" >>$(1); \
			sed -i "/CONFIG_FEATURE_WGET_STATUSBAR/d" $(1); \
			echo "CONFIG_FEATURE_WGET_STATUSBAR=y" >>$(1); \
			sed -i "/CONFIG_FEATURE_VERBOSE_USAGE/d" $(1); \
			echo "CONFIG_FEATURE_VERBOSE_USAGE=y" >>$(1); \
		fi; \
	else \
		sed -i "/CONFIG_FEATURE_MOUNT_LOOP/d" $(1); \
		echo "# CONFIG_FEATURE_MOUNT_LOOP is not set" >>$(1); \
		sed -i "/CONFIG_FEATURE_MOUNT_LABEL/d" $(1); \
		echo "# CONFIG_FEATURE_MOUNT_LABEL is not set" >>$(1); \
		sed -i "/CONFIG_FEATURE_MOUNT_FSTAB/d" $(1); \
		echo "# CONFIG_FEATURE_MOUNT_FSTAB is not set" >>$(1); \
		sed -i "/CONFIG_VOLUMEID/d" $(1); \
		echo "# CONFIG_VOLUMEID is not set" >>$(1); \
		sed -i "/CONFIG_BLKID/d" $(1); \
		echo "# CONFIG_BLKID is not set" >>$(1); \
		sed -i "/CONFIG_SWAPON/d" $(1); \
		echo "# CONFIG_SWAPON is not set" >>$(1); \
		sed -i "/CONFIG_SWAPOFF/d" $(1); \
		echo "# CONFIG_SWAPOFF is not set" >>$(1); \
		sed -i "/CONFIG_CHROOT/d" $(1); \
		echo "# CONFIG_CHROOT is not set" >>$(1); \
		sed -i "/CONFIG_PIVOT_ROOT/d" $(1); \
		echo "# CONFIG_PIVOT_ROOT is not set" >>$(1); \
		sed -i "/CONFIG_TRUE/d" $(1); \
		echo "# CONFIG_TRUE is not set" >>$(1); \
	fi; \
	if [ "$(IPV6SUPP)" = "y" ]; then \
		sed -i "/CONFIG_FEATURE_IPV6/d" $(1); \
		echo "CONFIG_FEATURE_IPV6=y" >>$(1); \
		sed -i "/CONFIG_FEATURE_PREFER_IPV4_ADDRESS/d" $(1); \
		echo "CONFIG_FEATURE_PREFER_IPV4_ADDRESS=y" >>$(1); \
		sed -i "/CONFIG_PING6/d" $(1); \
		echo "CONFIG_PING6=y" >>$(1); \
		sed -i "/CONFIG_TRACEROUTE6/d" $(1); \
		echo "CONFIG_TRACEROUTE6=y" >>$(1); \
	fi; \
	if [ "$(SLIM)" = "y" ]; then \
		sed -i "/CONFIG_AWK/d" $(1); \
		echo "# CONFIG_AWK is not set" >>$(1); \
		sed -i "/CONFIG_BASENAME/d" $(1); \
		echo "# CONFIG_BASENAME is not set" >>$(1); \
		sed -i "/CONFIG_FEATURE_DEVFS/d" $(1); \
		echo "# CONFIG_FEATURE_DEVFS is not set" >>$(1); \
		sed -i "/CONFIG_BLKID/d" $(1); \
		echo "# CONFIG_BLKID is not set" >>$(1); \
		sed -i "/CONFIG_TELNET=y/d" $(1); \
		echo "# CONFIG_TELNET is not set" >>$(1); \
		sed -i "/CONFIG_ARPING/d" $(1); \
		echo "# CONFIG_ARPING is not set" >>$(1); \
		sed -i "/CONFIG_FEATURE_LS_COLOR/d" $(1); \
		echo "# CONFIG_FEATURE_LS_COLOR is not set" >>$(1); \
		sed -i "/CONFIG_CHOWN/d" $(1); \
		echo "# CONFIG_CHOWN is not set" >>$(1); \
	else \
		sed -i "/CONFIG_FEATURE_LS_COLOR/d" $(1); \
		echo "CONFIG_FEATURE_LS_COLOR=y" >>$(1); \
		sed -i "/CONFIG_FEATURE_LS_COLOR_IS_DEFAULT/d" $(1); \
		echo "CONFIG_FEATURE_LS_COLOR_IS_DEFAULT=y" >>$(1); \
	fi; \
	if [ "$(FULL_EXTRAS)" = "y" ]; then \
		sed -i "s/# CONFIG_TIME is not set/CONFIG_TIME=y/g" $(1); \
		sed -i "s/# CONFIG_GETOPT is not set/CONFIG_GETOPT=y/g" $(1); \
		sed -i "s/# CONFIG_FEATURE_GETOPT_LONG is not set/CONFIG_FEATURE_GETOPT_LONG=y/g" $(1); \
		sed -i "s/# CONFIG_DIFF is not set/CONFIG_DIFF=y/g" $(1); \
		sed -i "s/# CONFIG_LSOF is not set/CONFIG_LSOF=y/g" $(1); \
	fi; \
	)
endef

define KernelConfig
	@( \
	sed -i "/CONFIG_NVRAM_SIZE/d" $(1); \
	echo "CONFIG_NVRAM_SIZE="$(NVRAM_SIZE) >>$(1); \
	if [ "$(TARGET_VARIANT)" = "RTAC" ]; then \
		sed -i "/^CONFIG_EA6500V1=/d; /^# CONFIG_EA6500V1 is not set$$/d" $(1); \
		if [ "$(EA6500V1)" = "y" ]; then \
			echo "CONFIG_EA6500V1=y" >>$(1); \
		else \
			echo "# CONFIG_EA6500V1 is not set" >>$(1); \
		fi; \
	fi; \
	sed -i "/CONFIG_CC_OPTIMIZE_FOR_SIZE/d" $(1); \
	if [ "$(KERN_SIZE_OPT)" = "y" ]; then \
		echo "CONFIG_CC_OPTIMIZE_FOR_SIZE=y" >>$(1); \
	else \
		echo "# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set" >>$(1); \
	fi; \
	if [ "$(KERN_SIZE_OPT_MORE)" = "y" ]; then \
		sed -i "/CONFIG_BUG=y/d" $(1); \
		echo "# CONFIG_BUG is not set" >>$(1); \
	else \
		sed -i "/# CONFIG_BUG is not set/d" $(1); \
		echo "CONFIG_BUG=y" >>$(1); \
	fi; \
	if [ "$(MIPS32)" = "r2" ]; then \
		sed -i "/CONFIG_CPU_MIPS32_R1/d" $(1); \
		echo "# CONFIG_CPU_MIPS32_R1 is not set" >>$(1); \
		sed -i "/CONFIG_CPU_MIPS32_R2/d" $(1); \
		echo "CONFIG_CPU_MIPS32_R2=y" >>$(1); \
		sed -i "/CONFIG_CPU_MIPSR1/d" $(1); \
		echo "CONFIG_CPU_MIPSR2=y" >>$(1); \
		if [ "$(NAND)" = "y" ]; then \
			sed -i "/CONFIG_MTD_NFLASH/d" $(1); \
			echo "CONFIG_MTD_NFLASH=y" >>$(1); \
			sed -i "/CONFIG_MTD_NAND/d" $(1); \
			echo "CONFIG_MTD_NAND=y" >>$(1); \
			echo "CONFIG_MTD_NAND_IDS=y" >>$(1); \
			echo "# CONFIG_MTD_NAND_VERIFY_WRITE is not set" >>$(1); \
			echo "# CONFIG_MTD_NAND_ECC_SMC is not set" >>$(1); \
			echo "# CONFIG_MTD_NAND_MUSEUM_IDS is not set" >>$(1); \
			echo "# CONFIG_MTD_NAND_DISKONCHIP is not set" >>$(1); \
			echo "# CONFIG_MTD_NAND_CAFE is not set" >>$(1); \
			echo "# CONFIG_MTD_NAND_NANDSIM is not set" >>$(1); \
			echo "# CONFIG_MTD_NAND_PLATFORM is not set" >>$(1); \
			echo "# CONFIG_MTD_NAND_ONENAND is not set" >>$(1); \
			sed -i "/CONFIG_MTD_BRCMNAND/d" $(1); \
			echo "CONFIG_MTD_BRCMNAND=y" >>$(1); \
		fi; \
		if [ "$(WNR3500LV2)" = "1" ]; then \
			sed -i "/CONFIG_MTD_NFLASH/d" $(1); \
			echo "CONFIG_MTD_NFLASH=y" >>$(1); \
		fi; \
	fi; \
	if [ "$(UPS)" = "y" ]; then \
		sed -i "/CONFIG_USB_HIDDEV=m/d" $(1); \
		echo "CONFIG_USB_HIDDEV=y" >>$(1); \
		sed -i "/CONFIG_USB_DEVICEFS=m/d" $(1); \
		echo "CONFIG_USB_DEVICEFS=y" >>$(1); \
	fi; \
	if [ "$(USB)" = "" ]; then \
		sed -i "/CONFIG_EFI_PARTITION/d" $(1); \
		echo "# CONFIG_EFI_PARTITION is not set" >>$(1); \
	fi; \
	if [ "$(IPV6SUPP)" = "y" ]; then \
		sed -i "/CONFIG_IPV6 is not set/d" $(1); \
		echo "CONFIG_IPV6=y" >>$(1); \
		sed -i "/CONFIG_IP6_NF_IPTABLES/d" $(1); \
		echo "CONFIG_IP6_NF_IPTABLES=y" >>$(1); \
		sed -i "/CONFIG_IP6_NF_MATCH_RT/d" $(1); \
		echo "CONFIG_IP6_NF_MATCH_RT=y" >>$(1); \
		sed -i "/CONFIG_IP6_NF_FILTER/d" $(1); \
		echo "CONFIG_IP6_NF_FILTER=m" >>$(1); \
		sed -i "/CONFIG_IP6_NF_TARGET_LOG/d" $(1); \
		echo "CONFIG_IP6_NF_TARGET_LOG=m" >>$(1); \
		sed -i "/CONFIG_IP6_NF_TARGET_REJECT/d" $(1); \
		echo "CONFIG_IP6_NF_TARGET_REJECT=m" >>$(1); \
		sed -i "/CONFIG_IP6_NF_MANGLE/d" $(1); \
		echo "CONFIG_IP6_NF_MANGLE=m" >>$(1); \
		sed -i "/CONFIG_NF_CONNTRACK_IPV6/d" $(1); \
		echo "CONFIG_NF_CONNTRACK_IPV6=m" >>$(1); \
		sed -i "/CONFIG_NETFILTER_XT_MATCH_HL/d" $(1); \
		echo "CONFIG_NETFILTER_XT_MATCH_HL=m" >>$(1); \
		sed -i "/CONFIG_IPV6_ROUTER_PREF/d" $(1); \
		echo "CONFIG_IPV6_ROUTER_PREF=y" >>$(1); \
		sed -i "/CONFIG_IPV6_SIT/d" $(1); \
		echo "CONFIG_IPV6_SIT=m" >>$(1); \
		sed -i "/CONFIG_IPV6_SIT_6RD/d" $(1); \
		echo "CONFIG_IPV6_SIT_6RD=y" >>$(1); \
		sed -i "/CONFIG_IPV6_MULTIPLE_TABLES/d" $(1); \
		echo "CONFIG_IPV6_MULTIPLE_TABLES=y" >>$(1); \
		sed -i "/CONFIG_IP6_NF_RAW/d" $(1); \
		echo "CONFIG_IP6_NF_RAW=m" >>$(1); \
		sed -i "/CONFIG_IPV6_OPTIMISTIC_DAD/d" $(1); \
		echo "CONFIG_IPV6_OPTIMISTIC_DAD=y" >>$(1); \
		sed -i "/CONFIG_IPV6_MROUTE/d" $(1); \
		echo "CONFIG_IPV6_MROUTE=y" >>$(1); \
		sed -i "/CONFIG_IP6_NF_TARGET_ROUTE/d" $(1); \
		echo "CONFIG_IP6_NF_TARGET_ROUTE=m" >>$(1); \
		sed -i "/CONFIG_INET6_XFRM_TUNNEL/d" $(1); \
		echo "CONFIG_INET6_XFRM_TUNNEL=m" >>$(1); \
		sed -i "/CONFIG_INET6_AH/d" $(1); \
		echo "CONFIG_INET6_AH=m" >>$(1); \
		sed -i "/CONFIG_INET6_ESP/d" $(1); \
		echo "CONFIG_INET6_ESP=m" >>$(1); \
		sed -i "/CONFIG_INET6_IPCOMP/d" $(1); \
		echo "CONFIG_INET6_IPCOMP=m" >>$(1); \
		sed -i "/CONFIG_INET6_XFRM_MODE_TRANSPORT/d" $(1); \
		echo "CONFIG_INET6_XFRM_MODE_TRANSPORT=m" >>$(1); \
		sed -i "/CONFIG_INET6_XFRM_MODE_TUNNEL/d" $(1); \
		echo "CONFIG_INET6_XFRM_MODE_TUNNEL=m" >>$(1); \
		sed -i "/CONFIG_INET6_XFRM_MODE_BEET/d" $(1); \
		echo "CONFIG_INET6_XFRM_MODE_BEET=m" >>$(1); \
	fi; \
	sed -i "/CONFIG_BCM57XX/d" $(1); \
	if [ "$(BCM57)" = "y" ]; then \
		echo "CONFIG_BCM57XX=m" >>$(1); \
	else \
		echo "# CONFIG_BCM57XX is not set" >>$(1); \
	fi; \
	if [ "$(TARGET_VARIANT)" != "RT" ]; then \
		if [ "$(USBAP)" = "y" ]; then \
			sed -i "s/# CONFIG_WL_USBAP is not set/CONFIG_WL_USBAP=y/g" $(1); \
			sed -i "s/CONFIG_WL_APSTA=\"wlconfig_lx_router_apsta\"/CONFIG_WL_APSTA=\"wlconfig_lx_router_high\"/g" $(1); \
			sed -i "/CONFIG_USB_USBNET/d" $(1); \
			echo "# CONFIG_USB_USBNET is not set" >>$(1); \
			sed -i "/CONFIG_USB_NET_CDCETHER/d" $(1); \
			echo "# CONFIG_USB_NET_CDCETHER is not set" >>$(1); \
			sed -i "/CONFIG_USB_NET_CDC_NCM/d" $(1); \
			echo "# CONFIG_USB_NET_CDC_NCM is not set" >>$(1); \
			sed -i "/CONFIG_USB_NET_HUAWEIETHER/d" $(1); \
			echo "# CONFIG_USB_NET_HUAWEIETHER is not set" >>$(1); \
			sed -i "/CONFIG_USB_NET_QMI_WWAN/d" $(1); \
			echo "# CONFIG_USB_NET_QMI_WWAN is not set" >>$(1); \
			sed -i "/CONFIG_USB_IPHETH/d" $(1); \
			echo "# CONFIG_USB_IPHETH is not set" >>$(1); \
			sed -i "/CONFIG_USB_NET_RNDIS_HOST/d" $(1); \
			echo "# CONFIG_USB_NET_RNDIS_HOST is not set" >>$(1); \
			sed -i "/CONFIG_USB_WDM/d" $(1); \
			echo "# CONFIG_USB_WDM is not set" >>$(1); \
			sed -i "/CONFIG_USB_ACM/d" $(1); \
			echo "# CONFIG_USB_ACM is not set" >>$(1); \
		fi; \
	else \
		sed -i "s/# CONFIG_WL_USBAP is not set//g" $(1); \
		sed -i "s/CONFIG_WL_APSTA=\"wlconfig_lx_router_apsta\"//g" $(1); \
	fi; \
	if [ "$(EBTABLES)" = "y" ]; then \
		sed -i "/CONFIG_BRIDGE_NF_EBTABLES/d" $(1); \
		echo "CONFIG_BRIDGE_NF_EBTABLES=m" >>$(1); \
		if [ "$(IPV6SUPP)" = "y" ]; then \
			sed -i "/CONFIG_BRIDGE_EBT_IP6/d" $(1); \
			echo "CONFIG_BRIDGE_EBT_IP6=m" >>$(1); \
		fi; \
	fi; \
	if [ "$(TARGET_VARIANT)" != "RT" ]; then \
		if [ "$(NVRAM_64K)" = "y" ]; then \
			sed -i "s/# CONFIG_NVRAM_64K is not set/CONFIG_NVRAM_64K=y/g" $(1); \
		fi; \
	else \
		sed -i "s/# CONFIG_NVRAM_64K is not set//g" $(1); \
	fi; \
	if [ "$(TARGET_VARIANT)" != "RT" ]; then \
		if [ "$(FULL_EXTRAS)" = "y" ]; then \
			sed -i "s/# CONFIG_NETFILTER_XT_MATCH_STATISTIC is not set/CONFIG_NETFILTER_XT_MATCH_STATISTIC=m/g" $(1); \
			sed -i "s/# CONFIG_NETFILTER_XT_MATCH_COMMENT is not set/CONFIG_NETFILTER_XT_MATCH_COMMENT=y/g" $(1); \
		fi; \
	fi; \
	if [ "$(BONDING)" = "y" ]; then \
		sed -i "s/# CONFIG_BONDING is not set/CONFIG_BONDING=m/g" $(1); \
	fi; \
	)
endef


bin:
ifeq ($(B),)
	@echo $@" is not a valid target!"
	@false
endif
	@cp router/config_base router/config_$(lowercase_B)
	@cp router/busybox/config_base router/busybox/config_$(lowercase_B)
	@cp $(LINUXDIR)/config_base $(LINUXDIR)/config_$(lowercase_B)

	$(call RouterOptions, router/config_$(lowercase_B))
	$(call KernelConfig, $(LINUXDIR)/config_$(lowercase_B))
	$(call BusyboxOptions, router/busybox/config_$(lowercase_B))

	@$(MAKE) setprofile N=$(TPROFILE) B=$(B) DESC="$(BUILD_DESC)" USB="$(USB)"
ifneq ($(CONFIG_ONLY),y)
ifeq ($(CONFIG_SHARED_ONLY),y)
	@$(MAKE) -C router busybox
	@$(MAKE) -C router shared
else
	@$(MAKE) all
endif
endif

include targets.mak

setprofile:
	echo '#ifndef TOMATO_PROFILE' > router/shared/tomato_profile.h
	echo '#define TOMATO_$(N) 1' >> router/shared/tomato_profile.h
	echo '#define PROFILE_G 1' >> router/shared/tomato_profile.h
	echo '#define PROFILE_N 2' >> router/shared/tomato_profile.h
	echo '#define TOMATO_PROFILE PROFILE_$(N)' >> router/shared/tomato_profile.h
	echo '#define TOMATO_PROFILE_NAME "$(N)"' >> router/shared/tomato_profile.h
	echo '#define TOMATO_BUILD_NAME "$(B)"' >> router/shared/tomato_profile.h
	echo '#define TOMATO_BUILD_DESC "$(DESC)$(EXTRA_64KDESC)"' >> router/shared/tomato_profile.h
	echo '#ifndef CONFIG_NVRAM_SIZE' >> router/shared/tomato_profile.h
	echo '#define CONFIG_NVRAM_SIZE $(NVRAM_SIZE)' >> router/shared/tomato_profile.h
	echo '#endif' >> router/shared/tomato_profile.h
	echo '#endif' >> router/shared/tomato_profile.h

	echo 'TOMATO_$(N) = 1' > tomato_profile.mak
	echo 'PROFILE_G = 1' >> tomato_profile.mak
	echo 'PROFILE_N = 2' >> tomato_profile.mak
	echo 'TOMATO_PROFILE = $$(PROFILE_$(N))' >> tomato_profile.mak
	echo 'TOMATO_PROFILE_NAME = "$(N)"' >> tomato_profile.mak
	echo 'TOMATO_BUILD = "$(B)"' >> tomato_profile.mak
	echo 'TOMATO_BUILD_NAME = "$(B)"' >> tomato_profile.mak
	echo 'TOMATO_BUILD_DESC = "$(DESC)$(EXTRA_64KDESC)"' >> tomato_profile.mak
	echo 'TOMATO_PROFILE_L = $(lowercase_N)' >> tomato_profile.mak
	echo 'TOMATO_PROFILE_U = $(uppercase_N)' >> tomato_profile.mak
	echo 'TOMATO_BUILD_USB = "$(USB)"' >> tomato_profile.mak

	echo 'export EXTRACFLAGS := $(EXTRA_CFLAGS) -DBCMWPA2 -funit-at-a-time -Wno-pointer-sign $(if $(filter $(MIPS32),r2),-march=mips32r2 -mips32r2 -mtune=mips32r2,-march=mips32 -mips32 -mtune=mips32) $(if $(filter $(NVRAM_SIZE),0),,-DCONFIG_NVRAM_SIZE=$(NVRAM_SIZE)) $(EXTRA_64KCFLAG)' >> tomato_profile.mak

# Note that changes to variables in tomato_profile.mak don't
# get propogated to this invocation of make!
	@echo ""
	@echo "Using $(N) profile, $(B) build config."
	@echo ""

	@cd $(LINUXDIR) ; \
		rm -f config_current ; \
		ln -s config_$(lowercase_B) config_current ; \
		cp -f config_current .config

	@cd router/busybox && \
		rm -f config_current ; \
		ln -s config_$(lowercase_B) config_current ; \
		cp config_current .config

	@cd router ; \
		rm -f config_current ; \
		ln -s config_$(lowercase_B) config_current ; \
		cp config_current .config

	@$(MAKE) -C router oldconfig
	@cp -f $(LINUXDIR)/.config $(LINUXDIR)/config_current
	@cp -f router/busybox/.config router/busybox/config_current
	@cp -f router/.config router/config_current

include help.mak

help: help_main
	@echo ""
	@echo "..etc.. - other build configs"
	@echo " clean          -C router clean"
	@echo " cleanimage     rm -rf image"
	@echo " cleantools     clean btools, mksquashfs"
	@echo " cleankernel    -C Linux distclean (but preserves .config)"
	@echo " distclean      distclean of Linux & busybox (but preserve .configs)"
	@echo " prepk          -C Linux oldconfig dep"

.PHONY: all clean distclean cleanimage cleantools cleankernel prepk what setprofile help
.PHONY: a b c d m nc Makefile allversions tomato_profile.mak
