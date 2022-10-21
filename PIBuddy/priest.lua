local opt = PIBuddyConfig
local Glower = LibStub("LibCustomGlow-1.0")
local main

local PI_Active = false
local PI_Glowing = false
local PADDING = 16
local ICON_ZOOM = 0.08

-- pi me
local PiMeGlowTime = 0

-- WIDGETS

function opt:CreatePriestWidgets(m)

	-- PI texture
	main = m
	
	main.piSpellTexture = CreateFrame('FRAME', nil, main, "BackdropTemplate")
	main.piSpellTexture:SetPoint('LEFT', main, 'LEFT', 16, 0)
	main.piSpellTexture:SetWidth(opt.env.IconSize)
	main.piSpellTexture:SetHeight(opt.env.IconSize)
	main.piSpellTexture.texture = main.piSpellTexture:CreateTexture(nil, "ARTWORK")
	main.piSpellTexture.texture:SetTexture(GetSpellTexture(opt.POWER_INFUSION))
	main.piSpellTexture.texture:SetAllPoints(main.piSpellTexture)
	main.piSpellTexture.texture:SetTexCoord(ICON_ZOOM, 1-ICON_ZOOM, ICON_ZOOM, 1-ICON_ZOOM)

	main.piSpellTexture:SetScript('OnMouseUp', function(self, button, ...)

		-- stop dragging main
		if (button == "LeftButton") then 
			main:StopMovingOrSizing()
			return
		end
	end)

	main.piSpellTexture:SetScript('OnMouseDown', function(self, button, ...)

		-- click through to the main frame for drag
		if (button == "LeftButton") then 
			main:StartMoving()
			return
		end

		if (not opt.IsPriest and button=="RightButton") then
			opt:SetBuddyTarget()
		end
	end)

	-- priest name
	
	main.piPriestName = main.piSpellTexture:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	main.piPriestName:SetPoint('BOTTOM', main.piSpellTexture, 'TOP', 0, 2)
	main.piPriestName:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
	opt:SetPriestName(opt.PriestInfo.name)
	
	-- PI timer
	
	main.piTimer = main.piSpellTexture:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	main.piTimer:SetPoint('TOP', main.piSpellTexture, 'BOTTOM', 0, -2)
	main.piTimer:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
	main.piTimer:Hide()
	
	-- PI cooldown
	
	main.piCooldown = CreateFrame('Cooldown', nil, main.piSpellTexture, 'CooldownFrameTemplate')
	main.piCooldown:SetAllPoints()
	main.piCooldown:SetDrawEdge(false)
	main.piCooldown:SetSwipeTexture("")
	
	main.piCooldownText = main.piCooldown:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	main.piCooldownText:SetPoint('CENTER', main.piSpellTexture, 'CENTER')
	main.piCooldownText:Hide()
	
	opt:UpdatePIAlpha()
end

function opt:SetMainFramePriestVisible(visible)
	if (visible) then
		main.piSpellTexture:Show()
		main.piPriestName:Show()
	else
		main.piSpellTexture:Hide()
		main.piPriestName:Hide()
	end
end

function opt:SetMainFrameCheckPriestVisibility()
	if (not opt.env.ShowCooldownTimers) then
		main.piCooldown:Hide()
		main.piCooldownText:Hide()
	end

	if (not opt.env.ShowSpellTimers) then
		main.piTimer:Hide()
	end

	if (not opt.env.ShowSpellGlow) then
		if (PI_Glowing) then
			Glower.PixelGlow_Stop(main.piSpellTexture)
			PI_Glowing = false
		end
	end
end

function opt:SetPriestName(name)
	if (name == nil or name == "") then
		main.piPriestName:SetText(opt.titles.NoBuddy)
	else
		main.piPriestName:SetText(name)
	end
end

function opt:OnResizePriest()
	main.piSpellTexture:SetWidth(opt.env.IconSize)
	main.piSpellTexture:SetHeight(opt.env.IconSize)
end

function opt:ResetPriestUi()
	if (not main) then return end
	opt:OnReceivedPICooldown(0)
end

-----------------------------------
-- pi aura
-----------------------------------

-- We Gained Power Infusion
-- Hide everything except the Power Infusion icon while it is active.

function opt:OnGainPowerInfusion()

	if (Glower and opt.env.ShowSpellGlow) then
		Glower.PixelGlow_Start ( main.piSpellTexture, nil, nil, nil, nil, nil, 1, 1)
		PI_Glowing = true
	end
	
	PI_Active = true
	
	-- reset our timer text
	main.piTimer:Show()
	main.piCooldownText:Hide()

	opt:UpdatePIAlpha()
end

-- We Lost Power Infusion
function opt:OnLosePowerInfusion()

	if (PI_Glowing) then	
		Glower.PixelGlow_Stop(main.piSpellTexture)
		PI_Glowing = false
	end
	
	PI_Active = false
	main.piTimer:Hide()
	
	opt:UpdatePIAlpha()
end

function opt:UpdatePowerInfusionAura()
	
	if (PI_Active) then
			
		local aura = C_UnitAuras.GetPlayerAuraBySpellID(opt.PriestInfo.spell_id)
		
		if (aura) then
			local timeRemaining = aura.expirationTime - GetTime()
			
			if (timeRemaining < 0) then
				timeRemaining = 0
			end
				
			if (opt.env.ShowSpellTimers) then
				local text = string.format("%d", timeRemaining)
				main.piTimer:SetText(text)
			end
		end

	end
end

function opt:UpdatePIAlpha()
	if (opt.PriestInfo.spell_id > 0) then
		if (PI_Active) then
			main.piSpellTexture.texture:SetAlpha(1)
		else
			main.piSpellTexture.texture:SetAlpha(0.5)
		end
	else
		main.piSpellTexture.texture:SetAlpha(0.25)
	end
end

---------------------------------
-- pi me request
---------------------------------

function opt:OnReceivedPIRequest()
	if (PiMeGlowTime == 0) then
		Glower.PixelGlow_Start (main)
	end
	PiMeGlowTime = GetTime()
end

function opt:UpdatePiMeRequest()
	-- timeout the PIME pixel glow
	if (PiMeGlowTime > 0) then
		if (GetTime() - 5 > PiMeGlowTime) then
			Glower.PixelGlow_Stop(main)
			PiMeGlowTime = 0
		end
	end
end

---------------------------------
-- timers
---------------------------------

function opt:UpdatePriestTimers()
	opt:UpdatePiMeRequest()
	opt:UpdatePowerInfusionAura()
	opt:UpdatePowerInfusionCooldown()
end

-- update loop for dps players
function opt:UpdateRemotePriestTimers()
	opt:UpdatePowerInfusionAura()
	opt:UpdateRemotePowerInfusionCooldown()
end

---------------------------------
-- local timers
---------------------------------

local WAS_ON_COOLDOWN = false
function opt:UpdatePowerInfusionCooldown()
	
	-- early outs
	if (PI_Active) then 
		main.piCooldownText:Hide()
		main.piCooldown:Hide()
	end

	if (opt.PriestInfo.spell_id == 0) then return end

	-- get CD from API
	start, duration, enabled = GetSpellCooldown(opt.PriestInfo.spell_id);

	-- on CD behaviour
	local on_cooldown = (start > 0)
	if (on_cooldown) then
		-- check if we're actually on CD, or its the GCD
		gcd_start, gcd_duration, gcd_enable = GetSpellCooldown(61304)
		if (duration > 0 and duration == gcd_duration) then
			on_cooldown = false
		end
	end

	local notify = false
	-- if the spell is genuinely on cooldown
	if (on_cooldown) then

		-- calculate how long is remaining on our cooldown
		local endTime = start + duration
		local cd_remaining = endTime - GetTime()
		if (cd_remaining < 0) then cd_remaining = 0 end

		-- if our CD has changed significantly enough, let the dps player know
		if (WAS_ON_COOLDOWN) then
			if (math.abs(cd_remaining - opt.PriestInfo.cooldown_remaining) > 1) then
				notify = true
			end
		end
			
		-- update cached value
		opt.PriestInfo.cooldown_remaining = cd_remaining

		-- if we're running in DPS mode, we only update as the result of messages
		if (not PI_Active and opt.env.ShowCooldownTimers) then
			main.piCooldownText:Show()
			main.piCooldownText:SetText(string.format("%.1f", cd_remaining))
			main.piCooldown:SetCooldown(start, duration)
		end

	else

		-- spell is not on cooldown
		opt.PriestInfo.cooldown_remaining = 0

		-- if we're running in DPS mode, we only update as the result of messages
		main.piCooldown:SetCooldown(0, 0)
		main.piCooldownText:Hide()
	end

	-- if CD changed, let the dps player know
	if (on_cooldown ~= WAS_ON_COOLDOWN) then
		notify = true
	end

	if (notify) then
		opt:NotifyPICooldownChanged()
	end

	WAS_ON_COOLDOWN = on_cooldown
end

--------------------------
-- remote timers
--------------------------

local remote_startTime = 0
local remote_endTime = 0
local remote_duration = 0

-- we received a PI cooldown from our buddy
function opt:OnReceivedPICooldown(cooldown)

	local on_cooldown = (cooldown > 0)

	-- if spell is on CD, calculate how long our timer should be
	if (on_cooldown) then
		remote_startTime = GetTime()
		remote_duration = cooldown
		remote_endTime = remote_startTime + remote_duration
	else
		remote_startTime = 0
		remote_endTime = 0
		remote_duration = 0
	end

	opt:UpdateRemotePriestTimers()
end

-- power infusion cooldown as sent by the preist
-- when running in dps mode, this is sent by ourself
function opt:UpdateRemotePowerInfusionCooldown()

	if (PI_Active) then
		main.piCooldownText:Hide()
		main.piCooldown:Hide()
	end

	-- if we're tracking a CD atm
	local cd_remaining = 0
	if (remote_startTime > 0) then

		-- see how much time is left
		cd_remaining = remote_endTime - GetTime()
		if (cd_remaining < 0) then cd_remaining = 0 end
		opt.PriestInfo.cooldown_remaining = cd_remaining

		-- if the CD is over, wipe our timers
		if (cd_remaining == 0) then
			remote_startTime = 0
			remote_endTime = 0
			remote_duration = 0
		end
	end

	-- if on cooldown, display text
	-- if not, hide the cooldown text
	local on_cooldown = (cd_remaining > 0)
	if (on_cooldown and not PI_Active and opt.env.ShowCooldownTimers) then
		main.piCooldownText:Show()
		main.piCooldownText:SetText(string.format("%.1f", cd_remaining))
		main.piCooldown:SetCooldown(remote_startTime, remote_duration)
	else
		main.piCooldown:SetCooldown(0, 0)
		main.piCooldownText:Hide()
	end
end

