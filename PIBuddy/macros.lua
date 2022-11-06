local opt = PIBuddyConfig

-- PI Macros

function opt:CheckMacros()
    opt.ExportMacrosRaid = opt.InRaid and opt.env.GenerateMacroRaid
    opt.ExportMacros = opt.InGroup and opt.env.GenerateMacroParty
end

function opt:UpdateMacros()
    if (opt.InCombat) then return end
    if (not opt.IsPriest) then return end

    local text = nil
    if (opt.ExportMacrosRaid) then
        text = opt:GetMacroText(false)
    elseif (opt.ExportMacros) then
        text = opt:GetMacroText(true)
    end

    if (text == nil) then return end

    opt.ExportMacros = false
    opt.ExportMacrosRaid = false

    local index = GetMacroIndexByName("PIBUDDY");
    if (index == 0) then
        CreateMacro("PIBUDDY", "135939", text, false)
    else
        EditMacro(index, "PIBUDDY", "135939", text)
    end
end

function opt:CreatePIMacroPanel(party, parent, x, y)

	-- macro panel

	macro_panel = CreateFrame('Frame', nil, parent, "BackdropTemplate")
	macro_panel:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
	macro_panel:SetSize(360, 220)
	macro_panel:SetBackdrop({
		bgFile = [[Interface\Buttons\WHITE8x8]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		edgeSize = 14,
		insets = {left = 3, right = 3, top = 3, bottom = 3},
	})
	macro_panel:SetBackdropColor(0, 0, 0)
	macro_panel:SetBackdropBorderColor(0.3, 0.3, 0.3)
	macro_panel:EnableMouse(true)

	-- title

	local title = macro_panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	title:SetPoint('TOPLEFT', macro_panel, 'TOPLEFT', 0, 32)
	if (party) then
		title:SetText(opt.titles.MacroConfig)
	else
		title:SetText(opt.titles.MacroConfigRaid)
	end

	-- edit box
	
	local editBox = CreateFrame("EditBox", nil, macro_panel)
	editBox:SetPoint("TOP")
	editBox:SetPoint("LEFT")
	editBox:SetPoint("RIGHT")
	editBox:SetFontObject('ChatFontNormal')
	editBox:SetMultiLine(true)
	editBox:SetSize(360, 200)
	editBox:SetMaxLetters(1024)
	editBox:SetCursorPosition(0)
	editBox:SetAutoFocus(false)
	editBox:SetJustifyH("LEFT")
	editBox:SetJustifyV("CENTER")
	editBox:SetTextInsets(10, 10, 10, 10)

	editBox:SetScript('OnEscapePressed', function(self)
		editBox:ClearFocus()
		editBox:HighlightText(0,0)
	end)

	macro_panel:SetScript("OnMouseDown", function(self)
		editBox:SetFocus()
		editBox:HighlightText()
	end)

	-- focus

	local use_focus
	if (party) then use_focus = opt:CreateCheckBox(parent, 'PIFocusParty') else use_focus = opt:CreateCheckBox(parent, 'PIFocusRaid') end
	use_focus:SetPoint("TOPLEFT", macro_panel, "TOPRIGHT", 8, 0)
	use_focus:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:RefreshPIMacros(party)
		end)
	opt:AddTooltip(use_focus, opt.titles.PIFocusParty, opt.titles.PIFocusTooltip)

	local use_friendly
	if (party) then use_friendly = opt:CreateCheckBox(parent, 'PIFriendlyParty') else use_friendly = opt:CreateCheckBox(parent, 'PIFriendlyRaid') end
	use_friendly:SetPoint("TOPLEFT", use_focus, "BOTTOMLEFT", 0, -8)
	use_friendly:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:RefreshPIMacros(party)
		end)
	opt:AddTooltip(use_friendly, opt.titles.PIFriendlyParty, opt.titles.PIFriendlyTooltip)

	
	-- trinket 1

	local trinket1, trinket2
	if (party) then trinket1 = opt:CreateCheckBox(parent, 'Trinket1Party') else trinket1 = opt:CreateCheckBox(parent, 'Trinket1Raid') end
	trinket1:SetPoint("TOPLEFT", use_friendly, "BOTTOMLEFT", 0, -8)
	trinket1:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:RefreshPIMacros(party)
		end)
	opt:AddTooltip(trinket1, opt.titles.Trinket1Party, opt.titles.Trinket1Tooltip)

	-- trinket 2

	if (party) then trinket2 = opt:CreateCheckBox(parent, 'Trinket2Party') else trinket2 = opt:CreateCheckBox(parent, 'Trinket2Raid') end
	trinket2:SetPoint("TOPLEFT", trinket1, "BOTTOMLEFT", 0, -8)
	trinket2:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:RefreshPIMacros(party)
		end)
	opt:AddTooltip(trinket2, opt.titles.Trinket2Party, opt.titles.Trinket2Tooltip)

	-- target last target

	local tlt
	if (party) then tlt = opt:CreateCheckBox(parent, 'PITargetLastTargetParty') else tlt = opt:CreateCheckBox(parent, 'PITargetLastTargetRaid') end
	tlt:SetPoint("TOPLEFT", trinket2, "BOTTOMLEFT", 0, -8)
	tlt:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:RefreshPIMacros(party)
		end)
	opt:AddTooltip(tlt, opt.titles.PITargetLastTargetParty, opt.titles.PITargetLastTargetTooltip)

	-- auto generate
	
	local autogenerate
	if (party) then autogenerate = opt:CreateCheckBox(parent, 'GenerateMacroParty') else autogenerate = opt:CreateCheckBox(parent, 'GenerateMacroRaid') end
	autogenerate:SetPoint("TOPLEFT", tlt, "BOTTOMLEFT", 0, -8)
	autogenerate:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			if (self:GetChecked()) then
				if (party) then
					opt.ExportMacros = true
				else
					opt.ExportMacrosRaid = true
				end
			end
		end)
	opt:AddTooltip(autogenerate, opt.titles.GenerateMacroParty, opt.titles.GenerateMacroPartyTooltip)

	-- cache the boxes

	if (party) then
		opt.ui.macroEditBox = editBox
	else
		opt.ui.macroEditBoxRaid = editBox
	end
	
	opt:RefreshPIMacros(party)
end

function opt:GetMacroText(party)
    local text = '#showtooltip Power Infusion'
	
    -- trinkets

	if (party) then
		if (opt.env.Trinket1Party) then
			text = text .. '\n/use 13'
		end

		if (opt.env.Trinket2Party) then
			text = text .. '\n/use 14'
		end
	else
		if (opt.env.Trinket1Raid) then
			text = text .. '\n/use 13'
		end

		if (opt.env.Trinket2Raid) then
			text = text .. '\n/use 14'
		end
	end

	-- buddy

	if (party) then
		if (opt.env.DpsBuddy and opt.env.DpsBuddy ~= "") then
			text = text .. string.format('\n/cast [@%s,help,nodead] Power Infusion', opt.env.DpsBuddy)
            text = text .. string.format('\n/stopmacro [@%s,help,nodead]', opt.env.DpsBuddy)
		end
	else
		if (opt.env.RaidDpsBuddy and opt.env.RaidDpsBuddy ~= "") then
			text = text .. string.format('\n/cast [@%s,help,nodead] Power Infusion', opt.env.RaidDpsBuddy)
            text = text .. string.format('\n/stopmacro [@%s,help,nodead]', opt.env.RaidDpsBuddy)
		end
	end

	-- focus

		if ((party and opt.env.PIFocusParty) or (not party and opt.env.PIFocusRaid)) then
			text = text .. '\n/cast [focus,help,nodead] Power Infusion'
		end

	-- friendly

	if ((party and opt.env.PIFriendlyParty) or (not party and opt.env.PIFriendlyRaid)) then
		text = text .. '\n/targetfriendplayer [nohelp]'
		text = text .. '\n/cast [help] Power Infusion'

		if ((party and opt.env.PITargetLastTargetParty) or (not party and opt.env.PITargetLastTargetRaid)) then
			text = text .. '\n/targetlasttarget [help]'
		end
	end

	-- self

	text = text .. '\n/cast [@player] Power Infusion'

    return text
end

function opt:RefreshPIMacros(party)

    if (not opt.IsPriest) then return end
    local text = opt:GetMacroText(party)
	if (not text) then return end

	if (party) then
		opt.ui.macroEditBox:SetText(text)
	else
		opt.ui.macroEditBoxRaid:SetText(text)
	end

    opt:CheckMacros()
end