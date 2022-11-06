local opt = PIBuddyConfig
local main
local PADDING = 16

function opt:CreateMainFrame()

	-- main frame
		
	main = CreateFrame('FRAME', 'PIBuddy', UIParent, "BackdropTemplate")
	main:SetFrameStrata("BACKGROUND")
	main:SetWidth(2 * opt.env.IconSize + (3*PADDING))
	main:SetHeight(opt.env.IconSize + (2*PADDING))
	
	if (opt.env.FrameX > 0 and opt.env.FrameY > 0) then
		main:SetPoint("TOPLEFT","UIParent","BOTTOMLEFT",opt.env.FrameX,opt.env.FrameY)
	else
		main:SetPoint("CENTER","UIParent","CENTER")
	end
	
	-- background
	
	main:SetBackdrop(
	{
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 3,
		insets = { left = 1, right = 1, top = 1, bottom = 1 },
	})
	opt:SetMainFrameBackgroundVisible(opt.env.ShowBackground)
	
	-- mouse
	main:SetClampedToScreen(true)
	main:RegisterForDrag("LeftButton")
	
	if (opt.env.LockButton == false) then
		opt:UnlockMainFrame()
	end
	
	-- add text
	
	main.header = main:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	main.header:SetText(opt.titles.PIBuddy)
	main.header:SetPoint('TOPLEFT', main, 'TOPLEFT', 6, 14)
	opt:SetMainFrameTitleVisible(opt.env.ShowTitle)
	
	-- widgets
	
	opt:CreatePriestWidgets(main)
	opt:CreateDpsWidgets(main)
	
	-- warnings

	opt:CreateWarningWidgets()

	-- pi me
	
	main.pime = CreateFrame("Button", "PiMeButton", main, "UIPanelButtonTemplate")
	main.pime:SetPoint('TOP', main, 'BOTTOM', 0, -4)
	main.pime:SetWidth(64)
	main.pime:SetHeight(28)
	main.pime:SetText(opt.titles.RequestPI)
	main.pime:SetScript("OnClick", function(self, arg1)
		if (opt:HasPriestBuddy()) then
			opt:SendPiMeRequest()
		end
	end)

	--[[
	-- focus me
	local ICON_ZOOM = 0.08
	main.focusme = CreateFrame("Button", "PIFocusMeButton", main, "SecureActionButtonTemplate,UIPanelButtonTemplate");
	main.focusme:SetPoint('TOP', main, 'BOTTOM', 0, -4)
	main.focusme:SetWidth(72)
	main.focusme:SetHeight(28)
	main.focusme:SetText(opt.titles.SetFocusText)
	main.focusme:RegisterForClicks("AnyDown", "AnyUp")
	main.focusme:SetAttribute("type", "focus")
	main.focusme.no_glow = true
	]]--

	opt:AdjustWarningSpacing()
	main:SetPoint("CENTER",0,0)	
	opt.main = main
	
	if (opt.IsPriest) then
		main.pime:Hide()
		--opt:ChangeFocusTargetUnitId(opt.DpsInfo.unit_id)
	else
		--main.focusme:Hide()
	end

	-- Tick

	local ONUPDATE_INTERVAL = 0.1
	local TimeSinceLastUpdate = 0
	main:SetScript("OnUpdate", function(self, elapsed)
		TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
		if TimeSinceLastUpdate >= ONUPDATE_INTERVAL then
			TimeSinceLastUpdate = 0
			opt:OnUpdate(elapsed)
		end
	end)

end

--[[
function opt:ChangeFocusTargetUnitId(unitId)
	if (opt.main) then
		if (unitId) then
			opt.main.focusme:SetAttribute("unit", unitId)
		else
			opt.main.focusme:SetAttribute("unit", "target")
		end
	end
end
]]--

function opt:ShowMainFrame()
	main:Show()
end

function opt:HideMainFrame()
	main:Hide()
end

function opt:UnlockMainFrame()

	if (main == nil) then
		return
	end

	main:EnableMouse(true)
	main:SetMovable(true)
	
	main:SetScript ("OnDragStart", function() 
		main:StartMoving() 
	end)
	
	main:SetScript ("OnDragStop", function() 
		main:StopMovingOrSizing() 
		local x, y = main:GetLeft(), main:GetTop()
		opt.env.FrameX = x
		opt.env.FrameY = y
	end)

end

function opt:LockMainFrame()
	if (main == nil) then
		return
	end
	
	main:EnableMouse(false)
	main:SetMovable(false)
	main:SetScript("OnDragStart", nil)
	main:SetScript("OnDragStop", nil)
end

function opt:OnResize()
	if (main == nil) then
		return
	end
	
	local width = PADDING
	if (opt.env.ShowPriest) then 
		width = width + opt.env.IconSize
		width = width + PADDING
	end
	if (opt.env.ShowDps) then 
		width = width + opt.env.IconSize
		width = width + PADDING
	end
	
	main:SetWidth(width)
	main:SetHeight(opt.env.IconSize + (2*PADDING))
	opt:OnResizePriest()
	opt:OnResizeDps()
end

function opt:SetMainFrameBackgroundVisible(visible)
	if (visible) then
		main:SetBackdropColor(0, 0, 0, .4)
		main:SetBackdropBorderColor(1, 1, 1, 0.4)
	else
		main:SetBackdropColor(0, 0, 0, 0)
		main:SetBackdropBorderColor(0, 0, 0, 0)
	end
end

function opt:SetMainFrameTitleVisible(visible)

	if (visible) then
		main.header:Show()
	else
		main.header:Hide()
	end
end

function opt:SetMainFramePiMeButton(visible)

	if (visible and not opt.IsPriest) then
		main.pime:Show()
	else
		main.pime:Hide()
	end
end

function opt:SetMainFrameFocusMeButton(visible)

	local show = false

	if (visible and opt.IsPriest) then

		-- no focus
		if (not opt.HasFocus) then
			show = true
		else

			-- wrong focus - not synced
			if (opt.DpsInfo.name == nil or opt.DpsInfo.name == "") then
				if (opt.InRaid) then
					show = (opt.env.RaidDpsBuddy ~= opt.FocusName)
				else
					show = (opt.env.DpsBuddy ~= opt.FocusName)
				end
			else
				-- wrong focus
				show = (opt.DpsInfo.name ~= opt.FocusName)
			end
		end
	end

	if (show) then
		main.focusme:Show()
	else
		main.focusme:Hide()
	end
end

function opt:CreateWarningWidgets()

	main.noBuddyWarning = main:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	main.noBuddyWarning:SetText(opt.titles.WarningTextNoFocus)
	main.noBuddyWarning:SetPoint('TOP', main, 'BOTTOM', 0, -12)
	opt:SetMainFrameNoBuddyWarningVisible(opt.env.WarnNoBuddy)

	main.noFocusWarning = main:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	main.noFocusWarning:SetText(opt.titles.WarningTextNoFocus)
	main.noFocusWarning:SetPoint('TOP', main, 'BOTTOM', 0, -12)
	opt:SetMainFrameNoFocusWarningVisible(opt.env.WarnNoFocus)

	main.noPIWarning = main:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	main.noPIWarning:SetText(opt.titles.WarningTextNoPI)
	main.noPIWarning:SetPoint('TOP', main, 'BOTTOM', 0, -12)
	opt:SetMainFrameNoPIWarningVisible(opt.env.WarnNoPowerInfusion)

	main.noTwinsWarning = main:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	main.noTwinsWarning:SetText(opt.titles.WarningTextNoTwins)
	main.noTwinsWarning:SetPoint('TOP', main, 'BOTTOM', 0, -12)
	opt:SetMainFrameNoTwinsWarningVisible(opt.env.WarnNoTwins)

end

function opt:SetMainFrameNoBuddyWarningVisible(visible)
		
	-- early out - warning was disabled
	if (not visible) then
		main.noBuddyWarning:Hide()
		return
	end

	if (opt.IsPriest) then
		
		-- your buddy is the wrong class
		if (opt.DpsInfo.class_id and opt.DpsInfo.class_id == 5) then
			main.noBuddyWarning:SetText(opt.titles.WarningTextDpsBuddyIsAPriest)
			main.noBuddyWarning:Show()
			return
		end

		-- early out, we have a dps buddy
		if (opt.DpsInfo.name) then
					
			if (opt.DpsInfo.spec_id == 0 and opt.DpsInfo.spell_id == 0) then
				main.noBuddyWarning:SetText(string.format(opt.titles.WarningTextNoBuddySync, opt.DpsInfo.name))
				main.noBuddyWarning:Show()
			elseif (opt.DpsInfo.is_dead) then
				main.noBuddyWarning:SetText(string.format(opt.titles.WarningTextBuddyDead, opt.DpsInfo.name))
				main.noBuddyWarning:Show()
			else
				main.noBuddyWarning:Hide()
			end

			return
		end

		-- check if we configured a raid buddy
		if (opt.InRaid) then
			if (opt.env.RaidDpsBuddy == nil or opt.env.RaidDpsBuddy == "") then
				main.noBuddyWarning:SetText(opt.titles.WarningTextNoBuddyRaid)
				main.noBuddyWarning:Show()
			else
				main.noBuddyWarning:SetText(string.format(opt.titles.WarningTextNoBuddyAtTheMomentRaid, opt.env.RaidDpsBuddy))
				main.noBuddyWarning:Show()
			end
		else
			if (opt.env.DpsBuddy == nil or opt.env.DpsBuddy == "") then
				main.noBuddyWarning:SetText(opt.titles.WarningTextNoBuddy)
				main.noBuddyWarning:Show()
			else
				main.noBuddyWarning:SetText(string.format(opt.titles.WarningTextNoBuddyAtTheMomentParty, opt.env.DpsBuddy))
				main.noBuddyWarning:Show()
			end
		end
		
	else

		-- your priest buddy is not a priest!
		if (opt.PriestInfo.class_id and opt.PriestInfo.class_id > 0 and opt.PriestInfo.class_id ~= 5) then
			main.noBuddyWarning:SetText(string.format(opt.titles.WarningTextPriestBuddyIsntPriest, opt.PriestInfo.class_name))
			main.noBuddyWarning:Show()
			return
		end

		-- early out, we have a priest buddy
		if (opt.PriestInfo.name) then
			if (opt.PriestInfo.spec_id == 0 or opt.PriestInfo.spell_id == 0) then
				main.noBuddyWarning:SetText(string.format(opt.titles.WarningTextNoBuddySync, opt.PriestInfo.name))
				main.noBuddyWarning:Show()
			elseif (opt.PriestInfo.is_dead) then
				main.noBuddyWarning:SetText(string.format(opt.titles.WarningTextBuddyDead, opt.PriestInfo.name))
				main.noBuddyWarning:Show()
			else
				main.noBuddyWarning:Hide()
			end

			return
		end

		-- check if we configured a raid buddy
		if (opt.InRaid) then
			if (opt.env.RaidPriestBuddy == nil or opt.env.RaidPriestBuddy == "") then
				main.noBuddyWarning:SetText(opt.titles.WarningTextNoBuddyRaid)
				main.noBuddyWarning:Show()
			else
				main.noBuddyWarning:SetText(string.format(opt.titles.WarningTextNoBuddyAtTheMomentRaid, opt.env.RaidPriestBuddy))
				main.noBuddyWarning:Show()
			end
		else
			if (opt.env.PriestBuddy == nil or opt.env.PriestBuddy == "") then
				main.noBuddyWarning:SetText(opt.titles.WarningTextNoBuddy)
				main.noBuddyWarning:Show()
			else
				main.noBuddyWarning:SetText(string.format(opt.titles.WarningTextNoBuddyAtTheMomentParty, opt.env.PriestBuddy))
				main.noBuddyWarning:Show()
			end
		end

	end

end

function opt:SetMainFrameNoFocusWarningVisible(visible)
	visible = visible and not opt.HasFocus and opt.IsPriest
	if (visible) then
		main.noFocusWarning:Show()
	else
		main.noFocusWarning:Hide()
	end
end

function opt:SetMainFrameNoPIWarningVisible(visible)
	visible = visible and not opt.HasPI and opt.IsPriest
	if (visible) then
		main.noPIWarning:Show()
	else
		main.noPIWarning:Hide()
	end
end

function opt:SetMainFrameNoTwinsWarningVisible(visible)
	
	visible = visible and not opt.HasTwins and opt.IsPriest
	if (visible) then
		main.noTwinsWarning:Show()
	else
		main.noTwinsWarning:Hide()
	end
end

function opt:AdjustWarningSpacing()

	local noBuddyOffset = 0
	local noFocusOffset = 0
	local piWarningOffset = 0
	local twinsWarningOffset = 0

	if (main.noBuddyWarning:IsVisible()) then noBuddyOffset = 18 end
	if (main.noFocusWarning:IsVisible()) then noFocusOffset = 18 end
	if (main.noPIWarning:IsVisible()) then piWarningOffset = 18 end
	if (main.noTwinsWarning:IsVisible()) then twinsWarningOffset = 18 end

	local offset = -8
	main.noBuddyWarning:SetPoint('TOP', main, 'BOTTOM', 0, offset)
	main.noFocusWarning:SetPoint('TOP', main, 'BOTTOM', 0, offset - noBuddyOffset)
	main.noPIWarning:SetPoint('TOP', main, 'BOTTOM', 0, offset - noBuddyOffset - noFocusOffset)
	main.noTwinsWarning:SetPoint('TOP', main, 'BOTTOM', 0, offset  - noBuddyOffset - noFocusOffset - piWarningOffset)
	main.pime:SetPoint('TOP', main, 'BOTTOM', 0, offset - noBuddyOffset - noFocusOffset - piWarningOffset - twinsWarningOffset)
	--main.focusme:SetPoint('TOP', main, 'BOTTOM', 0, offset - noBuddyOffset - noFocusOffset - piWarningOffset - twinsWarningOffset)
end
