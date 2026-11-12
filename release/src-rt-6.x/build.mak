build_all:
	@echo ""
	@echo "Building FreshTomato $(branch_rev) $(current_BUILD_USB) $(current_TOMATO_VER)$(beta)$(current_V2) $(current_BUILD_DESC) $(current_BUILD_NAME) with $(TOMATO_PROFILE_NAME) Profile"
	@echo ""
	@echo ""

	@-mkdir image
ifeq ($(EA6500V1),y)
	@grep -qx "CONFIG_EA6500V1=y" $(LINUXDIR)/.config && \
		grep -qx "CONFIG_NVRAM_64K=y" $(LINUXDIR)/.config && \
		grep -qx "CONFIG_MTD_NFLASH=y" $(LINUXDIR)/.config && \
		grep -qx "TCONFIG_EA6500V1=y" router/.config && \
		! grep -Eq '^TCONFIG_(JFFS2|JFFSV1|BRCM_NAND_JFFS2)=y$$' router/.config && \
		! grep -Eq '^CONFIG_(DUAL_TRX|FAILSAFE_UPGRADE)=y$$' $(LINUXDIR)/.config || \
		{ echo "ERROR: EA6500 v1 build configuration incomplete" >&2; exit 1; }
endif
	@$(MAKE) -C router all
	@$(MAKE) -C router install
	@$(MAKE) -C btools

	@echo "\033[41;1m   Creating image \033[0m\033]2;Creating image\007"

	@rm -f image/freshtomato-$(branch_rev)$(fn_BUILD_USB)$(fn_NVRAM_SIZE)-$(current_TOMATO_VER)$(beta)$(current_V2)-$(current_BUILD_DESC).trx
	@rm -f image/freshtomato-$(branch_rev)$(fn_BUILD_USB)$(fn_NVRAM_SIZE)-$(current_TOMATO_VER)$(beta)$(current_V2)-$(current_BUILD_DESC).bin
ifeq ($(EA6500V1),y)
	$(MAKE) -C ctools
	ctools/objcopy -O binary -R .reginfo -R .note -R .comment -R .mdebug -S $(LINUXDIR)/vmlinux ctools/piggy
	@echo "Creating Firmware for Linksys EA6500 v1 ..."
	$(call CREATE_INJECT_MODEL_EA6500V1,freshtomato-Linksys-EA6500V1-$(branch_rev)-$(current_TOMATO_VER)$(beta)$(current_V2)-$(current_BUILD_DESC).trx)
else

ifneq ($(ASUS_TRX),0)
 ifeq ($(ASUS_TRX),R6300V1)
	$(MAKE) -C ctools
	ctools/objcopy -O binary -R .reginfo -R .note -R .comment -R .mdebug -S $(LINUXDIR)/vmlinux ctools/piggy
	ctools/lzma_4k e ctools/piggy  ctools/vmlinuz-lzma
	@echo "Creating SDK6 Firmware for Netgear R6300 v1 ..."
	$(call CREATE_INJECT_MODEL_NETGEAR_SDK6,freshtomato-Netgear-R6300V1-$(branch_rev)-$(current_TOMATO_VER)$(beta)$(current_V2)-$(current_BUILD_DESC).chk,U12H218T00_NETGEAR)
	@rm -f image/linux-lzma.trx
	@echo ""
 else
  ifeq ($(ASUS_TRX),WNDR4500V1)
	$(MAKE) -C ctools
	ctools/objcopy -O binary -R .reginfo -R .note -R .comment -R .mdebug -S $(LINUXDIR)/vmlinux ctools/piggy
	ctools/lzma_4k e ctools/piggy  ctools/vmlinuz-lzma
	@echo "Creating SDK6 Firmware for Netgear WNDR4500 v1 ..."
	$(call CREATE_INJECT_MODEL_NETGEAR_SDK6,freshtomato-Netgear-WNDR4500V1-$(branch_rev)-$(current_TOMATO_VER)$(beta)$(current_V2)-$(current_BUILD_DESC).chk,U12H189T00_NETGEAR)
	@rm -f image/linux-lzma.trx
	@echo ""
  else
   ifeq ($(ASUS_TRX),WNDR4500V2)
	$(MAKE) -C ctools
	ctools/objcopy -O binary -R .reginfo -R .note -R .comment -R .mdebug -S $(LINUXDIR)/vmlinux ctools/piggy
	ctools/lzma_4k e ctools/piggy  ctools/vmlinuz-lzma
	@echo "Creating SDK6 Firmware for Netgear WNDR4500 v2 ..."
	$(call CREATE_INJECT_MODEL_NETGEAR_SDK6,freshtomato-Netgear-WNDR4500V2-$(branch_rev)-$(current_TOMATO_VER)$(beta)$(current_V2)-$(current_BUILD_DESC).chk,U12H224T00_NETGEAR)
	@rm -f image/linux-lzma.trx
	@echo ""
   else
	$(MAKE) -C ctools
	ctools/objcopy -O binary -R .reginfo -R .note -R .comment -R .mdebug -S $(LINUXDIR)/vmlinux ctools/piggy
	ctools/lzma_4k e ctools/piggy  ctools/vmlinuz-lzma
	@echo "Creating SDK6 Firmware for $(ASUS_TRX) ..."
	$(call CREATE_INJECT_MODEL_SDK6,freshtomato-$(ASUS_TRX)-$(branch_rev)-$(current_TOMATO_VER)$(beta)$(current_V2)-$(current_BUILD_DESC).trx,$(ASUS_TRX),3.0.0.4,$(FORCE_SN),$(FORCE_EN))
	@rm -f image/linux-lzma.trx
	@echo ""
   endif #WNDR4500V2
  endif  #WNDR4500V1
 endif   #R6300v1
endif    #ASUS_TRX

ifneq ($(WNDR),y)
 ifeq ($(ASUS_TRX),0)
	# Create generic TRX image
	@echo "Creating Generic TRX Firmware (RT-AC)"
	$(call CREATE_INJECT_MODEL_GEN,freshtomato$(if $(filter-out $(BUILD_FN),),$(shell echo -$(BUILD_FN)))-$(branch_rev)$(fn_BUILD_USB)$(fn_NVRAM_SIZE)-$(current_TOMATO_VER)$(beta)$(current_V2)-$(current_BUILD_DESC).trx)
 endif
endif
endif # EA6500V1
