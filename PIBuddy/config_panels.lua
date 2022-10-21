local opt = PIBuddyConfig
local ADDON_VERSION = "1.02"

function opt:CreateWidgets()

	local HEADER_OFFSET = -32

	-- version
	
	local version = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	version:SetFontObject("GameFontNormalSmall")
	version:SetTextColor(1,1,1,0.5)
	version:SetPoint('TOPRIGHT', -5, 0)
	version:SetText(string.format("PIBuddy (%s) by rljohn", ADDON_VERSION))
	
	-- frame panel
		
	opt.ui.main = opt:CreatePanel(opt, "MainFrame", 580, 200)
	opt.ui.main:SetPoint('TOPLEFT', opt, 'TOPLEFT', 25, -48)
	
	opt.ui.controlsTitle = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	opt.ui.controlsTitle:SetText(opt.titles.Controls)
	opt.ui.controlsTitle:SetPoint('TOPLEFT', opt.ui.main, 'TOPLEFT', 0, 32)
	
	opt.ui.showOptionsLabel = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	opt.ui.showOptionsLabel:SetText(opt.titles.ShowText)
	opt.ui.showOptionsLabel:SetPoint('TOPLEFT', opt.ui.main, 'TOPLEFT', 8, -8)
		
	opt.ui.showOptions = CreateFrame("Frame", name, opt.ui.main, "UIDropDownMenuTemplate")
	opt.ui.showOptions:SetPoint('TOPLEFT', opt.ui.showOptionsLabel, 'BOTTOMLEFT', -8, -8)
	UIDropDownMenu_Initialize(opt.ui.showOptions, function(self, level, menuList)
	
		local info = UIDropDownMenu_CreateInfo()
		info.func = function(self, arg1, arg2, checked)
			UIDropDownMenu_SetSelectedValue(opt.ui.showOptions, arg1)
			opt.env.ShowButton = arg1
			opt:ForceUiUpdate()
		end
		
		info.text, info.value, info.arg1, info.arg2 = "Show Always", 1, 1, "Show Always"
		UIDropDownMenu_AddButton(info)

		info.text, info.value, info.arg1, info.arg2 = "Combat Only", 2, 2, "Combat Only"
		UIDropDownMenu_AddButton(info)
		
		info.text, info.value, info.arg1, info.arg2 = "Group Only", 3, 3, "Group Only"
		UIDropDownMenu_AddButton(info)
		
		info.text, info.value, info.arg1, info.arg2 = "Never", 4, 4, "Never"
		UIDropDownMenu_AddButton(info)
		
		UIDropDownMenu_SetSelectedValue(opt.ui.showOptions, opt.env.ShowButton)
	end)
	opt:AddTooltip(opt.ui.showOptionsLabel, opt.titles.ShowText, opt.titles.ShowTextTooltip)
	opt:AddTooltip(opt.ui.showOptions, opt.titles.ShowText, opt.titles.ShowTextTooltip)
	
	-- lock button

	opt.ui.lock = opt:CreateCheckBox(opt, 'LockButton')
	opt.ui.lock:SetPoint("TOPLEFT", opt.ui.showOptionsLabel, "TOPLEFT", 0, -58)
	opt.ui.lock:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			if (self:GetChecked()) then
				opt:Lock()
			else
				opt:Unlock()
			end
		end)
	opt:AddTooltip(opt.ui.lock, opt.titles.LockButtonHeader, opt.titles.LockButtonTooltip)
	
	-- show background
	
	opt.ui.showBackground = opt:CreateCheckBox(opt, 'ShowBackground')
	opt.ui.showBackground:SetPoint("TOPLEFT", opt.ui.lock, "TOPLEFT", 0, -25)
	opt.ui.showBackground:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.showBackground, opt.titles.ShowBackgroundHeader, opt.titles.ShowBackgroundTooltip)
	
	-- show title
	
	opt.ui.showTitle = opt:CreateCheckBox(opt, 'ShowTitle')
	opt.ui.showTitle:SetPoint("TOPLEFT", opt.ui.showBackground, "TOPLEFT", 0, -25)
	opt.ui.showTitle:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.showTitle, opt.titles.ShowTitleHeader, opt.titles.ShowTitleTooltip)
	
	-- show priest
	
	opt.ui.showPriest = opt:CreateCheckBox(opt, 'ShowPriest')
	opt.ui.showPriest:SetPoint("TOPLEFT", opt.ui.showTitle, "TOPLEFT", 0, -25)
	opt.ui.showPriest:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.showPriest, opt.titles.ShowPriestHeader, opt.titles.ShowPriestTooltip)
	
	-- show priest
	
	opt.ui.showDps = opt:CreateCheckBox(opt, 'ShowDps')
	opt.ui.showDps:SetPoint("TOPLEFT", opt.ui.showPriest, "TOPLEFT", 0, -25)
	opt.ui.showDps:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.showDps, opt.titles.ShowDpsHeader, opt.titles.ShowDpsTooltip)
	
	------------------------------
	
	opt.ui.showMinimap = opt:CreateCheckBox(opt, 'ShowMinimapIcon')
	opt.ui.showMinimap:SetPoint("TOPLEFT", opt.ui.main, "TOPLEFT", 200, -70)
	opt.ui.showMinimap:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:MinimapUpdate()
		end)
	opt:AddTooltip(opt.ui.showMinimap, opt.titles.ShowMinimapHeader, opt.titles.ShowMinimapTooltip)

	opt.ui.showPIMe = opt:CreateCheckBox(opt, 'ShowPiMe')
	opt.ui.showPIMe:SetPoint("TOPLEFT", opt.ui.showMinimap, "TOPLEFT", 0, -25)
	opt.ui.showPIMe:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)
	if (opt.IsPriest) then
		opt.ui.showPIMe:Disable()
		opt.ui.showPIMe.label:SetAlpha(0.5)
		opt:AddTooltip(opt.ui.showPIMe, opt.titles.TooltipUnavailable, opt.titles.DpsOnlyTooltip)
	else
		opt:AddTooltip(opt.ui.showPIMe, opt.titles.ShowPiMeHeader, opt.titles.ShowPiMeTooltip)
	end
	
		
	opt.ui.showCdTimers = opt:CreateCheckBox(opt, 'ShowCooldownTimers')
	opt.ui.showCdTimers:SetPoint("TOPLEFT", opt.ui.showPIMe, "TOPLEFT", 0, -25)
	opt.ui.showCdTimers:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.showCdTimers, opt.titles.ShowCooldownTimersHeader, opt.titles.ShowCooldownTimersTooltip)

	opt.ui.showSpellTimers = opt:CreateCheckBox(opt, 'ShowSpellTimers')
	opt.ui.showSpellTimers:SetPoint("TOPLEFT", opt.ui.showCdTimers, "TOPLEFT", 0, -25)
	opt.ui.showSpellTimers:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.showSpellTimers, opt.titles.ShowSpellTimersHeader, opt.titles.ShowSpellTimersTooltip)

	opt.ui.showSpellGlow = opt:CreateCheckBox(opt, 'ShowSpellGlow')
	opt.ui.showSpellGlow:SetPoint("TOPLEFT", opt.ui.showSpellTimers, "TOPLEFT", 0, -25)
	opt.ui.showSpellGlow:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.showSpellGlow, opt.titles.ShowSpellGlowHeader, opt.titles.ShowSpellGlowTooltip)


	------------------------------

	opt.ui.warnNoBuddy = opt:CreateCheckBox(opt, 'WarnNoBuddy')
	opt.ui.warnNoBuddy:SetPoint("TOPLEFT", opt.ui.main, "TOPLEFT", 400, -90)
	opt.ui.warnNoBuddy:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.warnNoBuddy, opt.titles.WarnNoBuddyHeader, opt.titles.WarnNoBuddyTooltip)

	opt.ui.warnNoFocus = opt:CreateCheckBox(opt, 'WarnNoFocus')
	opt.ui.warnNoFocus:SetPoint("TOPLEFT", opt.ui.warnNoBuddy, "TOPLEFT", 0, -25)
	opt.ui.warnNoFocus:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)

	opt.ui.warnNoPI = opt:CreateCheckBox(opt, 'WarnNoPowerInfusion')
	opt.ui.warnNoPI:SetPoint("TOPLEFT", opt.ui.warnNoFocus, "TOPLEFT", 0, -25)
	opt.ui.warnNoPI:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)	

	opt.ui.warnNoTwins = opt:CreateCheckBox(opt, 'WarnNoTwins')
	opt.ui.warnNoTwins:SetPoint("TOPLEFT", opt.ui.warnNoPI, "TOPLEFT", 0, -25)
	opt.ui.warnNoTwins:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)

	if (opt.IsPriest) then
		opt:AddTooltip(opt.ui.warnNoFocus, opt.titles.WarnNoFocusHeader, opt.titles.WarnNoFocusTooltip)
		opt:AddTooltip(opt.ui.warnNoPI, opt.titles.WarnNoPowerInfusionHeader, opt.titles.WarnNoPowerInfusionTooltip)
		opt:AddTooltip(opt.ui.warnNoTwins, opt.titles.WarnNoTwinsHeader, opt.titles.WarnNoTwinsTooltip)
	else
		opt.ui.warnNoFocus:Disable()
		opt.ui.warnNoFocus.label:SetAlpha(0.5)
		opt.ui.warnNoPI:Disable()
		opt.ui.warnNoPI.label:SetAlpha(0.5)
		opt.ui.warnNoTwins:Disable()
		opt.ui.warnNoTwins.label:SetAlpha(0.5)
		opt:AddTooltip(opt.ui.warnNoFocus, opt.titles.TooltipUnavailable, opt.titles.PriestOnlyTooltip)
		opt:AddTooltip(opt.ui.warnNoPI, opt.titles.TooltipUnavailable, opt.titles.PriestOnlyTooltip)
		opt:AddTooltip(opt.ui.warnNoTwins, opt.titles.TooltipUnavailable, opt.titles.PriestOnlyTooltip)
	end

	------------------------------
	
	-- size
	
	opt.ui.iconSize = opt:CreateSlider(opt, 'IconSize', 48, 128, 16, 140)
	opt.ui.iconSize:SetPoint("TOPLEFT", opt.ui.main, "TOPLEFT", 210, -30)
	opt.ui.iconSize:SetScript("OnValueChanged", function(self, value, ...)
			opt:OnSliderValueChanged(self, value)
			opt:OnResize()
		end)
	opt:AddTooltip(opt.ui.iconSize, opt.titles.IconSize, opt.titles.IconSizeTooltip)
		
	opt:CreatePartyConfig()
	opt:CreateRaidConfig()
	opt:CreateCooldownConfig()

	opt.ui.allowOneWay = opt:CreateCheckBox(opt, 'AllowOneWay')
	opt.ui.allowOneWay:SetPoint("TOPLEFT", opt.ui.raidConfig, "BOTTOMLEFT", -8, -16)
	opt.ui.allowOneWay:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
		end)
	opt:AddTooltip(opt.ui.allowOneWay, opt.titles.AllowOneWayHeader, opt.titles.AllowOneWayTooltip)

end

function opt:CreatePartyConfig()
	
	-- party config
		
	opt.ui.partyConfig = opt:CreatePanel(opt, "ConfigFrame", 258, 90)
	opt.ui.partyConfig:SetPoint('TOPLEFT', opt.ui.main, 'BOTTOMLEFT', 0, -64)

	opt.ui.partyConfigTitle = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	opt.ui.partyConfigTitle:SetText(opt.titles.PartyConfig)
	opt.ui.partyConfigTitle:SetPoint('TOPLEFT', opt.ui.partyConfig, 'TOPLEFT', 0, 32)

	if (opt.IsPriest) then
		opt:CreatePartyDpsBuddy()
	else
		opt:CreatePartyPriestBuddy()
	end
end

local EDITBOX_OFFSET = 58
local EDITBOX_WIDTH = 144
local BUTTON_HEIGHT = 22
local STATUS_OFFSET = -48
local COPY_TARGET_OFFSET_Y = -4

function opt:OnBuddyRequestButton(editbox, button, mode)

	-- don't send a buddy request to yourself
	if (strlower(editbox:GetText()) == strlower(opt.PlayerName)) then
		editbox:SetText('')
		editbox:SetCursorPosition(0)
	else
		local name = editbox:GetText()
		if (name and name ~= "") then
			opt:SendPIBuddyRequest(name, mode)
			button:Disable()
			C_Timer.After(3, function() 
				if (editbox:GetText() ~= "") then
					button:Enable()
				end
			end)
		end
	end
end

function opt:OnBuddyEditChanged(box, buddy, submit_button, request_button)
	if (box:GetText() == buddy) then
		submit_button:Disable()
	else
		submit_button:Enable()
	end

	if (box:GetText() == "") then
		request_button:Disable()
	else
		request_button:Enable()
	end
end

function opt:UpdatePartyStatusUi(frame, is_raid)

	if (not frame) then
		return
	end

	local buddy_setting = ""
	local BuddyInfo = nil

	if (opt.IsPriest) then
		if (is_raid) then buddy_setting = opt.env.RaidDpsBuddy else buddy_setting = opt.env.DpsBuddy end
		BuddyInfo = opt.DpsInfo
	else
		if (is_raid) then buddy_setting = opt.env.RaidPriestBuddy else buddy_setting = opt.env.PriestBuddy end
		BuddyInfo = opt.PriestInfo
	end

	if (not buddy_setting or buddy_setting == "") then
		frame:SetText(opt.titles.StatusNotSet)
		opt:ReplaceTooltip(frame, opt.titles.StatusNotSet, opt.titles.StatusNotSetTooltip)
	elseif (opt.IsPriest and BuddyInfo.class_id == 5) then
		frame:SetText(opt.titles.StatusPriestDps)
		opt:ReplaceTooltip(frame, opt.titles.StatusPriestDps, opt.titles.StatusPriestDpsTooltip)
	elseif (not opt.IsPriest and BuddyInfo.class_id > 0 and BuddyInfo.class_id ~= 5) then
		frame:SetText(opt.titles.StatusNotAPriest)
		opt:ReplaceTooltip(frame, opt.titles.StatusNotAPriest, opt.titles.StatusNotAPriestTooltip)
	elseif (is_raid and not opt.InRaid) then
		frame:SetText(opt.titles.StatusNoRaid)
		opt:ReplaceTooltip(frame, opt.titles.StatusNoRaid, opt.titles.StatusNoRaidTooltip)
	elseif (not is_raid and (opt.InRaid or not opt.InGroup)) then
		frame:SetText(opt.titles.StatusNoParty)
		opt:ReplaceTooltip(frame, opt.titles.StatusNoParty, opt.titles.StatusNoPartyTooltip)
	elseif (not BuddyInfo or not BuddyInfo.name or BuddyInfo.name == "") then
		frame:SetText(opt.titles.StatusNotInGroup)
		opt:ReplaceTooltip(frame, opt.titles.StatusNotInGroup, opt.titles.StatusNotInGroupTooltip)
	elseif (not BuddyInfo.connected) then
		frame:SetText(opt.titles.StatusNotOnline)
		opt:ReplaceTooltip(frame, opt.titles.StatusNotOnline, opt.titles.StatusNotOnlineTooltip)
	elseif (BuddyInfo.player_declined) then
		frame:SetText(opt.titles.StatusSyncDeclined)
		opt:ReplaceTooltip(frame, opt.titles.StatusSyncDeclined, opt.titles.StatusSyncDeclinedTooltip)
	elseif (BuddyInfo.is_syncing) then
		frame:SetText(opt.titles.StatusSyncing)
		opt:ReplaceTooltip(frame, opt.titles.StatusSyncing, opt.titles.StatusSyncingTooltip)
	elseif (BuddyInfo.failed_sync) then
		frame:SetText(opt.titles.StatusSyncFailed)
		opt:ReplaceTooltip(frame, opt.titles.StatusSyncFailed, opt.titles.StatusSyncFailedTooltip)
	else
		frame:SetText(opt.titles.StatusDefault)
		opt:ReplaceTooltip(frame, opt.titles.StatusReady, opt.titles.StatusReadyTooltip)
	end
end

function opt:UpdateBuddyStatusUi()
	if (not opt.IsPriest) then
		opt:UpdatePartyStatusUi(opt.ui.priestPartyStatus, false)
		opt:UpdatePartyStatusUi(opt.ui.raid_priestPartyStatus, true)
	else
		opt:UpdatePartyStatusUi(opt.ui.dpsPartyStatus, false)
		opt:UpdatePartyStatusUi(opt.ui.raid_dpsPartyStatus, true)
	end
end

function opt:ApplyBuddy(frame, button, is_dps, is_raid)
	if (strlower(frame:GetText()) == strlower(opt.PlayerName)) then
		frame:SetText('')
	else
		if (is_dps) then
			if (is_raid) then
				opt:SetRaidDpsBuddy(frame:GetText())
			else
				opt:SetDpsBuddy(frame:GetText())
			end
		else
			if (is_raid) then
				opt:SetRaidPriestBuddy(frame:GetText())
			else
				opt:SetPriestBuddy(frame:GetText())
			end
		end

		frame:ClearFocus()
		button:Disable()

		local resync = false
		if (opt.InRaid) then
			resync = is_raid
		elseif (opt.InGroup) then
			resync = not is_raid
		else
			resync = true
		end

		if (resync) then
			opt:SyncInfo()
			opt:ForceUiUpdate()
		end
	end
end

function opt:CreatePartyDpsBuddy()

	opt.ui.dpsTitle = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	opt.ui.dpsTitle:SetText(opt.titles.DPSBuddy)
	opt.ui.dpsTitle:SetPoint('TOPLEFT', opt.ui.partyConfig, 'TOPLEFT', 8, -8)
	
	opt.ui.dpsEditBox = opt:CreateEditBox(opt, 'DpsEditBox', 64, EDITBOX_WIDTH, 32)
	opt.ui.dpsEditBox:SetPoint('TOPLEFT', opt.ui.dpsTitle, 'TOPLEFT', EDITBOX_OFFSET, 9)
	opt.ui.dpsEditBox:SetText(opt.env.DpsBuddy)
	opt.ui.dpsEditBox:SetCursorPosition(0)
	opt.ui.dpsEditBox:SetScript('OnEnterPressed', function(self)
		opt.ui.dpsSubmitBtn:Click()
		end)
	opt.ui.dpsEditBox:SetScript('OnEscapePressed', function(self)
			opt.ui.dpsEditBox:ClearFocus()
		end)
	opt:AddTooltip(opt.ui.dpsEditBox, opt.titles.PartyConfig, opt.titles.PartyBuddyDps)
		
	-- apply btn
	opt.ui.dpsSubmitBtn = CreateFrame("Button", "DpsApplyButton", opt, "UIPanelButtonTemplate")
	opt.ui.dpsSubmitBtn:SetPoint('LEFT', opt.ui.dpsEditBox, 'RIGHT', 8, 0)
	opt.ui.dpsSubmitBtn:SetWidth(60)
	opt.ui.dpsSubmitBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.dpsSubmitBtn:SetText(opt.titles.ApplyBtn)
	opt.ui.dpsSubmitBtn:SetScript("OnClick", function(self, arg1)
		opt:ApplyBuddy(opt.ui.dpsEditBox, opt.ui.dpsSubmitBtn, true, false)
	end)
	opt.ui.dpsSubmitBtn:Disable()
	opt:AddTooltip(opt.ui.dpsSubmitBtn, opt.titles.ApplyBtnHeader, opt.titles.ApplyBtnTooltip)

	-- copy target btn

	opt.ui.dpsSetTargetBtn = CreateFrame("Button", "DpsSetTargetButton", opt, "UIPanelButtonTemplate")
	opt.ui.dpsSetTargetBtn:SetPoint('TOPLEFT', opt.ui.dpsEditBox, 'BOTTOMLEFT', -8, COPY_TARGET_OFFSET_Y)
	opt.ui.dpsSetTargetBtn:SetWidth(100)
	opt.ui.dpsSetTargetBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.dpsSetTargetBtn:SetText(opt.titles.SetAsTargetBtn)
	opt.ui.dpsSetTargetBtn:SetScript("OnClick", function(self, arg1)
		if (UnitIsPlayer("target") and UnitName("target") and UnitName("target") ~= opt.PlayerName) then
			opt.ui.dpsEditBox:SetText(UnitName("target"))
			opt.ui.dpsEditBox:SetCursorPosition(0)
		end
	end)
	opt:AddTooltip(opt.ui.dpsSetTargetBtn, opt.titles.SetAsTargetBtn, opt.titles.CopyTargetTooltip)

	-- request buddy button

	opt.ui.dpsRequestBuddyBtn = CreateFrame("Button", "DpsRequestBuddyButton", opt, "UIPanelButtonTemplate")
	opt.ui.dpsRequestBuddyBtn:SetPoint('LEFT', opt.ui.dpsSetTargetBtn, 'RIGHT', 4, 0)
	opt.ui.dpsRequestBuddyBtn:SetWidth(116)
	opt.ui.dpsRequestBuddyBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.dpsRequestBuddyBtn:SetText(opt.titles.RequestBuddy)
	opt.ui.dpsRequestBuddyBtn:SetScript("OnClick", function(self, arg1)
		opt:ApplyBuddy(opt.ui.dpsEditBox, opt.ui.dpsSubmitBtn, true, false)
		opt:OnBuddyRequestButton(opt.ui.dpsEditBox, opt.ui.dpsRequestBuddyBtn, "party")
	end)
	opt:AddTooltip(opt.ui.dpsRequestBuddyBtn, opt.titles.RequestBuddyHeader, opt.titles.CopyTargetTooltip)

	-- text event handlers

	opt.ui.dpsEditBox:SetScript('OnTextChanged', function(self)
		opt:OnBuddyEditChanged(opt.ui.dpsEditBox, opt.env.DpsBuddy, opt.ui.dpsSubmitBtn, opt.ui.dpsRequestBuddyBtn)
	end)

	-- status

	local status = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	status:SetPoint('TOPLEFT', opt.ui.dpsTitle, 'BOTTOMLEFT', 0, STATUS_OFFSET)
	status:SetText('Status: ')

	opt.ui.dpsPartyStatus = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	opt.ui.dpsPartyStatus:SetPoint('LEFT', status, 'RIGHT', 8, 0)
	opt:AddTooltip(opt.ui.dpsPartyStatus, opt.titles.StatusDefault, opt.titles.StatusDefaultTooltip)
end

function opt:CreatePartyPriestBuddy()
	opt.ui.priestTitle = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	opt.ui.priestTitle:SetText(opt.titles.PriestBuddy)
	opt.ui.priestTitle:SetPoint('TOPLEFT', opt.ui.partyConfig, 'TOPLEFT', 8, -8)
	
	opt.ui.priestEditBox = opt:CreateEditBox(opt, 'PriestEditBox', 64, EDITBOX_WIDTH, 32)
	opt.ui.priestEditBox:SetText(opt.env.PriestBuddy)
	opt.ui.priestEditBox:SetCursorPosition(0)
	opt.ui.priestEditBox:SetPoint('TOPLEFT', opt.ui.priestTitle, 'TOPLEFT', EDITBOX_OFFSET, 9)
	opt.ui.priestEditBox:SetScript('OnEnterPressed', function(self)
		opt.ui.priestSubmitBtn:Click()
		end)
	opt.ui.priestEditBox:SetScript('OnEscapePressed', function(self)
			opt.ui.priestEditBox:ClearFocus()
		end)
	opt:AddTooltip(opt.ui.priestEditBox, opt.titles.PartyConfig, opt.titles.PartyBuddyPriest)
		
	-- apply button
	
	opt.ui.priestSubmitBtn = CreateFrame("Button", "PriestApplyButton", opt, "UIPanelButtonTemplate")
	opt.ui.priestSubmitBtn:SetPoint('LEFT', opt.ui.priestEditBox, 'RIGHT', 8, 0)
	opt.ui.priestSubmitBtn:SetWidth(60)
	opt.ui.priestSubmitBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.priestSubmitBtn:SetText(opt.titles.ApplyBtn)
	opt.ui.priestSubmitBtn:SetScript("OnClick", function(self, arg1)
		opt:ApplyBuddy(opt.ui.priestEditBox, opt.ui.priestSubmitBtn, false, false)
	end)
	opt.ui.priestSubmitBtn:Disable()

	-- copy target button

	opt.ui.priestSetTargetBtn = CreateFrame("Button", "DpsSetTargetButton", opt, "UIPanelButtonTemplate")
	opt.ui.priestSetTargetBtn:SetPoint('TOPLEFT', opt.ui.priestEditBox, 'BOTTOMLEFT', -8, COPY_TARGET_OFFSET_Y)
	opt.ui.priestSetTargetBtn:SetWidth(100)
	opt.ui.priestSetTargetBtn:SetHeight(20)
	opt.ui.priestSetTargetBtn:SetText(opt.titles.SetAsTargetBtn)
	opt.ui.priestSetTargetBtn:SetScript("OnClick", function(self, arg1)
		if (UnitIsPlayer("target") and UnitName("target") and UnitName("target") ~= opt.PlayerName) then
			opt.ui.priestEditBox:SetText(UnitName("target"))
			opt.ui.priestEditBox:SetCursorPosition(0)
		end
	end)

	-- request buddy button

	opt.ui.priestRequestBuddyBtn = CreateFrame("Button", "DpsRequestBuddyButton", opt, "UIPanelButtonTemplate")
	opt.ui.priestRequestBuddyBtn:SetPoint('LEFT', opt.ui.priestSetTargetBtn, 'RIGHT', 4, 0)
	opt.ui.priestRequestBuddyBtn:SetWidth(116)
	opt.ui.priestRequestBuddyBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.priestRequestBuddyBtn:SetText(opt.titles.RequestBuddy)
	opt.ui.priestRequestBuddyBtn:SetScript("OnClick", function(self, arg1)
		opt:ApplyBuddy(opt.ui.priestEditBox, opt.ui.priestSubmitBtn, false, false)
		opt:OnBuddyRequestButton(opt.ui.priestEditBox, opt.ui.priestRequestBuddyBtn, "party")
	end)
	opt:AddTooltip(opt.ui.priestRequestBuddyBtn, opt.titles.RequestBuddyHeader, opt.titles.CopyTargetTooltip)
	
	
	opt.ui.priestEditBox:SetScript('OnTextChanged', function(self)
		opt:OnBuddyEditChanged(opt.ui.priestEditBox, opt.env.PriestBuddy, opt.ui.priestSubmitBtn, opt.ui.priestRequestBuddyBtn)
	end)

	-- status

	local status = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	status:SetPoint('TOPLEFT', opt.ui.priestTitle, 'BOTTOMLEFT', 0, STATUS_OFFSET)
	status:SetText('Status: ')

	opt.ui.priestPartyStatus = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	opt.ui.priestPartyStatus:SetPoint('LEFT', status, 'RIGHT', 8, 0)
	opt:AddTooltip(opt.ui.priestPartyStatus, opt.titles.StatusDefault, opt.titles.StatusDefaultTooltip)

end

function opt:CreateRaidConfig()
	
	-- raid config
		
	opt.ui.raidConfig = opt:CreatePanel(opt, "ConfigFrame", 258, 90)
	opt.ui.raidConfig:SetPoint('TOPLEFT', opt.ui.partyConfig, 'BOTTOMLEFT', 0, -54)

	opt.ui.raidConfigTitle = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	opt.ui.raidConfigTitle:SetText(opt.titles.RaidConfig)
	opt.ui.raidConfigTitle:SetPoint('TOPLEFT', opt.ui.raidConfig, 'TOPLEFT', 0, 32)
	
	if (opt.IsPriest) then
		opt:CreateRaidDpsBuddy()
	else
		opt:CreateRaidPriestBuddy()
	end
	
end

function opt:CreateRaidDpsBuddy() 

	opt.ui.raid_dpsTitle = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	opt.ui.raid_dpsTitle:SetText(opt.titles.DPSBuddy)
	opt.ui.raid_dpsTitle:SetPoint('TOPLEFT', opt.ui.raidConfig, 'TOPLEFT', 8, -8)
	
	opt.ui.raid_dpsEditBox = opt:CreateEditBox(opt, 'DpsEditBox', 64, EDITBOX_WIDTH, 32)
	opt.ui.raid_dpsEditBox:SetPoint('TOPLEFT', opt.ui.raid_dpsTitle, 'TOPLEFT', EDITBOX_OFFSET, 9)
	opt.ui.raid_dpsEditBox:SetText(opt.env.RaidDpsBuddy)
	opt.ui.raid_dpsEditBox:SetCursorPosition(0)
	opt.ui.raid_dpsEditBox:SetScript('OnEnterPressed', function(self)
		opt.ui.raid_dpsSubmitBtn:Click()
		end)
	opt.ui.raid_dpsEditBox:SetScript('OnEscapePressed', function(self)
			opt.ui.raid_dpsEditBox:ClearFocus()
		end)
	opt:AddTooltip(opt.ui.raid_dpsEditBox, opt.titles.PartyConfig, opt.titles.RaidBuddyDps)
	
	opt.ui.raid_dpsSubmitBtn = CreateFrame("Button", "DpsApplyButton", opt, "UIPanelButtonTemplate")
	opt.ui.raid_dpsSubmitBtn:SetPoint('LEFT', opt.ui.raid_dpsEditBox, 'RIGHT', 8, 0)
	opt.ui.raid_dpsSubmitBtn:SetWidth(60)
	opt.ui.raid_dpsSubmitBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.raid_dpsSubmitBtn:SetText(opt.titles.ApplyBtn)
	opt.ui.raid_dpsSubmitBtn:SetScript("OnClick", function(self, arg1)
		opt:ApplyBuddy(opt.ui.raid_dpsEditBox, opt.ui.raid_dpsSubmitBtn, true, true)
	end)
	
	opt.ui.raid_dpsSubmitBtn:Disable()
	opt:AddTooltip(opt.ui.raid_dpsSubmitBtn, opt.titles.ApplyBtnHeader, opt.titles.ApplyBtnTooltip)

	-- copy target btn

	opt.ui.raid_dpsSetTargetBtn = CreateFrame("Button", "DpsSetTargetButton", opt, "UIPanelButtonTemplate")
	opt.ui.raid_dpsSetTargetBtn:SetPoint('TOPLEFT', opt.ui.raid_dpsEditBox, 'BOTTOMLEFT', -8, COPY_TARGET_OFFSET_Y)
	opt.ui.raid_dpsSetTargetBtn:SetWidth(100)
	opt.ui.raid_dpsSetTargetBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.raid_dpsSetTargetBtn:SetText(opt.titles.SetAsTargetBtn)
	opt.ui.raid_dpsSetTargetBtn:SetScript("OnClick", function(self, arg1)
		if (UnitIsPlayer("target") and UnitName("target") and UnitName("target") ~= opt.PlayerName) then
			opt.ui.raid_dpsEditBox:SetText(UnitName("target"))
			opt.ui.raid_dpsEditBox:SetCursorPosition(0)
		end
	end)
	opt:AddTooltip(opt.ui.raid_dpsSetTargetBtn, opt.titles.SetAsTargetBtn, opt.titles.CopyTargetTooltip)

	-- request buddy button

	opt.ui.raid_dpsRequestBuddyBtn = CreateFrame("Button", "DpsRequestBuddyButton", opt, "UIPanelButtonTemplate")
	opt.ui.raid_dpsRequestBuddyBtn:SetPoint('LEFT', opt.ui.raid_dpsSetTargetBtn, 'RIGHT', 4, 0)
	opt.ui.raid_dpsRequestBuddyBtn:SetWidth(116)
	opt.ui.raid_dpsRequestBuddyBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.raid_dpsRequestBuddyBtn:SetText(opt.titles.RequestBuddy)
	opt.ui.raid_dpsRequestBuddyBtn:SetScript("OnClick", function(self, arg1)
		opt:ApplyBuddy(opt.ui.raid_dpsEditBox, opt.ui.raid_dpsSubmitBtn, true, true)
		opt:OnBuddyRequestButton(opt.ui.raid_dpsEditBox, opt.ui.raid_dpsRequestBuddyBtn, "raid")
	end)
	opt:AddTooltip(opt.ui.raid_dpsRequestBuddyBtn, opt.titles.RequestBuddyHeader, opt.titles.CopyTargetTooltip)

	opt.ui.raid_dpsEditBox:SetScript('OnTextChanged', function(self)
		opt:OnBuddyEditChanged(opt.ui.raid_dpsEditBox, opt.env.RaidDpsBuddy, opt.ui.raid_dpsSubmitBtn, opt.ui.raid_dpsRequestBuddyBtn)
	end)

	-- status

	local status = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	status:SetPoint('TOPLEFT', opt.ui.raid_dpsTitle, 'BOTTOMLEFT', 0, STATUS_OFFSET)
	status:SetText('Status: ')

	opt.ui.raid_dpsPartyStatus = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	opt.ui.raid_dpsPartyStatus:SetPoint('LEFT', status, 'RIGHT', 8, 0)
	opt:AddTooltip(opt.ui.raid_dpsPartyStatus, opt.titles.StatusDefault, opt.titles.StatusDefaultTooltip)
end

function opt:CreateRaidPriestBuddy()

	opt.ui.raid_priestTitle = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	opt.ui.raid_priestTitle:SetText(opt.titles.PriestBuddy)
	opt.ui.raid_priestTitle:SetPoint('TOPLEFT', opt.ui.raidConfig, 'TOPLEFT', 8, -8)
	
	opt.ui.raid_priestEditBox = opt:CreateEditBox(opt, 'PriestEditBox', 64, EDITBOX_WIDTH, 32)
	opt.ui.raid_priestEditBox:SetText(opt.env.RaidPriestBuddy)
	opt.ui.raid_priestEditBox:SetCursorPosition(0)
	opt.ui.raid_priestEditBox:SetPoint('TOPLEFT', opt.ui.raid_priestTitle, 'TOPLEFT', EDITBOX_OFFSET, 9)
	opt.ui.raid_priestEditBox:SetScript('OnEnterPressed', function(self)
		opt.ui.raid_priestSubmitBtn:Click()
		end)
	opt.ui.raid_priestEditBox:SetScript('OnEscapePressed', function(self)
			opt.ui.raid_priestEditBox:ClearFocus()
		end)
	opt:AddTooltip(opt.ui.raid_priestEditBox, opt.titles.PartyConfig, opt.titles.RaidBuddyPriest)

	-- apply target
	
	opt.ui.raid_priestSubmitBtn = CreateFrame("Button", "PriestApplyButton", opt, "UIPanelButtonTemplate")
	opt.ui.raid_priestSubmitBtn:SetPoint('LEFT', opt.ui.raid_priestEditBox, 'RIGHT', 8, 0)
	opt.ui.raid_priestSubmitBtn:SetWidth(60)
	opt.ui.raid_priestSubmitBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.raid_priestSubmitBtn:SetText(opt.titles.ApplyBtn)
	opt.ui.raid_priestSubmitBtn:SetScript("OnClick", function(self, arg1)
		opt:ApplyBuddy(opt.ui.raid_priestEditBox, opt.ui.raid_priestSubmitBtn, false, true)
	end)
	opt.ui.raid_priestSubmitBtn:Disable()

	-- copy target
		
	opt.ui.raid_priestSetTargetBtn = CreateFrame("Button", "DpsSetTargetButton", opt, "UIPanelButtonTemplate")
	opt.ui.raid_priestSetTargetBtn:SetPoint('TOPLEFT', opt.ui.raid_priestEditBox, 'BOTTOMLEFT', -8, COPY_TARGET_OFFSET_Y)
	opt.ui.raid_priestSetTargetBtn:SetWidth(100)
	opt.ui.raid_priestSetTargetBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.raid_priestSetTargetBtn:SetText(opt.titles.SetAsTargetBtn)
	opt.ui.raid_priestSetTargetBtn:SetScript("OnClick", function(self, arg1)
		if (UnitIsPlayer("target") and UnitName("target") and UnitName("target") ~= opt.PlayerName) then
			opt.ui.raid_priestEditBox:SetText(UnitName("target"))
			opt.ui.raid_priestEditBox:SetCursorPosition(0)
		end
	end)

	-- request buddy button

	opt.ui.raid_priestRequestBuddyBtn = CreateFrame("Button", "DpsRequestBuddyButton", opt, "UIPanelButtonTemplate")
	opt.ui.raid_priestRequestBuddyBtn:SetPoint('LEFT', opt.ui.raid_priestSetTargetBtn, 'RIGHT', 4, 0)
	opt.ui.raid_priestRequestBuddyBtn:SetWidth(116)
	opt.ui.raid_priestRequestBuddyBtn:SetHeight(BUTTON_HEIGHT)
	opt.ui.raid_priestRequestBuddyBtn:SetText(opt.titles.RequestBuddy)
	opt.ui.raid_priestRequestBuddyBtn:SetScript("OnClick", function(self, arg1)
		opt:ApplyBuddy(opt.ui.raid_priestEditBox, opt.ui.raid_priestSubmitBtn, false, true)
		opt:OnBuddyRequestButton(opt.ui.raid_priestEditBox, opt.ui.raid_priestRequestBuddyBtn, "raid")
	end)
	opt:AddTooltip(opt.ui.raid_priestRequestBuddyBtn, opt.titles.RequestBuddyHeader, opt.titles.CopyTargetTooltip)
	
	opt.ui.raid_priestEditBox:SetScript('OnTextChanged', function(self)
		opt:OnBuddyEditChanged(opt.ui.raid_priestEditBox, opt.env.RaidPriestBuddy, opt.ui.raid_priestSubmitBtn, opt.ui.raid_priestRequestBuddyBtn)
	end)

	-- status

	local status = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	status:SetPoint('TOPLEFT', opt.ui.raid_priestTitle, 'BOTTOMLEFT', 0, STATUS_OFFSET)
	status:SetText('Status: ')

	opt.ui.raid_priestPartyStatus = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	opt.ui.raid_priestPartyStatus:SetPoint('LEFT', status, 'RIGHT', 8, 0)
	opt:AddTooltip(opt.ui.raid_priestPartyStatus, opt.titles.StatusDefault, opt.titles.StatusDefaultTooltip)

end

function opt:CreateCooldownConfig()

	opt.ui.cooldownConfig = opt:CreatePanel(opt, "ConfigFrame", 258, 264)
	opt.ui.cooldownConfig:SetPoint('TOPLEFT', opt.ui.partyConfig, 'TOPRIGHT', 64, 0)
	
	opt.ui.cooldownConfigTitle = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	opt.ui.cooldownConfigTitle:SetText(opt.titles.CooldownConfig)
	opt.ui.cooldownConfigTitle:SetPoint('TOPLEFT', opt.ui.cooldownConfig, 'TOPLEFT', 0, 32)
	
	local info_text = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	info_text:SetWordWrap(true)
	info_text:SetWidth(258)
	info_text:SetJustifyH('LEFT')
	info_text:SetText(opt.titles.CooldownConfigInfo)
	info_text:SetPoint('TOPLEFT', opt.ui.cooldownConfig, 'TOPLEFT', 4, -4)
	
	local classCooldowns = opt:GetClassInfo(opt.PlayerClass)
	if (classCooldowns) then
		
		local prevAnchor = opt.ui.cooldownConfig
		
		local i = 0
		for spec_id,spec_cds in opt:pairsByKeys ( classCooldowns ) do
			local id, name, description, icon, background, role, class = GetSpecializationInfoByID(spec_id)
			
			local label = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
			label:SetText(name)
			
			if (i == 0) then
				label:SetPoint('TOPLEFT', info_text, 'BOTTOMLEFT', 0, -16)
			else
				label:SetPoint('TOPLEFT', prevAnchor, 'BOTTOMLEFT', 0, -40)
			end
			
			local hasCooldowns = false
			local cooldownSelection = CreateFrame("Frame", name, opt.ui.cooldownConfig, "UIDropDownMenuTemplate")
			cooldownSelection:SetPoint('TOPLEFT', label, 'BOTTOMLEFT', -20, -8)
			UIDropDownMenu_Initialize(cooldownSelection, function(self, level, menuList)
			
				for index,cooldown in opt:pairsByKeys ( spec_cds ) do
					local spell_id = cooldown[1]
					local spell_name = GetSpellInfo(spell_id)
					
					local spell_id2 = cooldown[2]
					if (spell_id2) then
						local spell_name2 = GetSpellInfo(spell_id2)
						spell_name = string.format("%s / %s", spell_name, spell_name2)
					end
					
					local info = UIDropDownMenu_CreateInfo()
					
					info.text = spell_name
					info.arg1 = spell_id
					info.arg2 = spell_id2
					info.value = spell_id
					
					info.func = function(self, arg1, arg2, checked)
						UIDropDownMenu_SetSelectedID(cooldownSelection, self:GetID())
						opt.env.Cooldowns[spec_id] = arg1
						opt:CheckDpsCooldownInfo()
						opt:ClearDpsCooldown()
						opt:NotifyDpsInfoChanged()
					end
					UIDropDownMenu_AddButton(info)
					hasCooldowns = true
				end
			end)
			
			UIDropDownMenu_SetWidth(cooldownSelection, 256)
			
			if (not hasCooldowns) then
				UIDropDownMenu_SetText(cooldownSelection, "N/A")
			elseif (opt.env.Cooldowns[spec_id]) then
				UIDropDownMenu_SetSelectedValue(cooldownSelection, opt.env.Cooldowns[spec_id])
			else
				UIDropDownMenu_SetSelectedID(cooldownSelection, 1)
			end
			
			prevAnchor = label
			i = i + 1
		end
	end
end

-- Widget Visiblility

function opt:ForceUiUpdate()

	if (opt.main == nil) then return end

	if (opt.env.ShowButton == 4) then
		opt:HideMainFrame()
	elseif (not opt.env.ShowPriest and not opt.env.ShowDps) then
		opt:HideMainFrame()
	elseif (not opt.InCombat and opt.env.ShowButton == 2) then
		opt:HideMainFrame()
	elseif (not opt.InGroup and opt.env.ShowButton == 3) then
		opt:HideMainFrame()
	else
		opt:ShowMainFrame()
	end
	
	opt:SetMainFrameBackgroundVisible(opt.env.ShowBackground)
	opt:SetMainFrameTitleVisible(opt.env.ShowTitle)
	opt:SetMainFramePriestVisible(opt.env.ShowPriest)
	opt:SetMainFrameDpsVisible(opt.env.ShowDps)
	opt:SetMainFramePiMeButton(opt.env.ShowPiMe)
	opt:SetMainFrameCheckDpsVisibility()
	opt:SetMainFrameNoBuddyWarningVisible(opt.env.WarnNoBuddy)
	opt:SetMainFrameNoFocusWarningVisible(opt.env.WarnNoFocus)
	opt:SetMainFrameNoPIWarningVisible(opt.env.WarnNoPowerInfusion)
	opt:SetMainFrameNoTwinsWarningVisible(opt.env.WarnNoTwins)
	opt:AdjustWarningSpacing()
	opt:OnResize()
		
	if (opt.IsPriest) then
		opt:UpdateDpsBuddyUi()
	else
		opt:UpdatePriestBuddyUi()
	end

	opt:UpdateBuddyStatusUi()
end
