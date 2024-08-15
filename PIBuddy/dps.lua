local opt = PIBuddyConfig
local Glower = LibStub("LibCustomGlow-1.0")

local DPS_CD_Active = false
local DPS_CD_Glowing = false
local aura_override_time = 0

local PADDING = 16
local ICON_ZOOM = 0.08
local main

function opt:CreateDpsWidgets(m)

	main = m

	-- other player
	
	main.coolDownSpellTexture = CreateFrame('FRAME', nil, main, "BackdropTemplate")
	main.coolDownSpellTexture:SetPoint('RIGHT', main, 'RIGHT', -16, 0)
	main.coolDownSpellTexture:SetWidth(opt.env.IconSize)
	main.coolDownSpellTexture:SetHeight(opt.env.IconSize)
	main.coolDownSpellTexture.texture = main.coolDownSpellTexture:CreateTexture(nil, "ARTWORK")
	opt:SetDpsSpellId(opt.DpsInfo.spell_id)
	main.coolDownSpellTexture.texture:SetAllPoints(main.coolDownSpellTexture)
	main.coolDownSpellTexture.texture:SetTexCoord(ICON_ZOOM, 1-ICON_ZOOM, ICON_ZOOM, 1-ICON_ZOOM)

	main.coolDownSpellTexture:SetScript('OnMouseUp', function(self, button, ...)

		-- stop dragging main
		if (button == "LeftButton") then 
			main:StopMovingOrSizing()
			local x, y = main:GetLeft(), main:GetTop()
			opt.env.FrameX = x
			opt.env.FrameY = y
			return
		end
	end)

	main.coolDownSpellTexture:SetScript('OnMouseDown', function(self, button, ...)

		-- click through to the main frame for drag
		if (button == "LeftButton" and opt.env.LockButton == false) then 
			main:StartMoving()
			return
		end

		if (opt.IsPriest and button == "RightButton") then
			opt:SetBuddyTarget()
		end
	end)
	
	-- dps player name
	
	main.dpsName = main.coolDownSpellTexture:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	main.dpsName:SetPoint('BOTTOM', main.coolDownSpellTexture, 'TOP', 0, 2)
	main.dpsName:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
	opt:SetDpsName(opt.DpsInfo.name_short)

	-- DPS timer

	main.dpsTimer = main.coolDownSpellTexture:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	main.dpsTimer:SetPoint('TOP', main.coolDownSpellTexture, 'BOTTOM', 0, -2)
	main.dpsTimer:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
	main.dpsTimer:Hide()
	
	-- DPS cooldown
	
	main.dpsCooldown = CreateFrame('Cooldown', nil, main.coolDownSpellTexture, 'CooldownFrameTemplate')
	main.dpsCooldown:SetAllPoints()
	main.dpsCooldown:SetDrawEdge(false)
	main.dpsCooldown:SetSwipeTexture("")
	
	main.dpsCooldownText = main.dpsCooldown:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	main.dpsCooldownText:SetPoint('CENTER', main.coolDownSpellTexture, 'CENTER')
	main.dpsCooldownText:Hide()
	
end

function opt:SetMainFrameCheckDpsVisibility()

	if (not opt.env.ShowCooldownTimers) then
		main.dpsCooldownText:Hide()
	end

	if (not opt.env.ShowSpellTimers) then
		main.dpsTimer:Hide()
	end

	if (not opt.env.ShowSpellGlow) then
		if (DPS_CD_Glowing) then
			Glower.PixelGlow_Stop(main.coolDownSpellTexture)
			DPS_CD_Glowing = false
		end
	end
end

function opt:SetMainFrameDpsVisible(visible)
	if (visible) then
		main.coolDownSpellTexture:Show()
		main.dpsName:Show()
	else
		main.coolDownSpellTexture:Hide()
		main.dpsName:Hide()
	end
end

function opt:SetDpsName(name)
	if (name == nil or name == "") then
		main.dpsName:SetText(opt.titles.NoBuddy)
	else
		main.dpsName:SetText(name)
	end
end

function opt:OnResizeDps()
	main.coolDownSpellTexture:SetWidth(opt.env.IconSize)
	main.coolDownSpellTexture:SetHeight(opt.env.IconSize)
end

function opt:ResetDpsUi()
	if (not main) then return end
	main.coolDownSpellTexture.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
	opt:OnReceivedDpsActivity(-1)
	opt:OnReceivedDpsCooldown(0)
end

function opt:ClearDpsCooldown()

	opt:OnLoseDpsCooldown()

	local aura = C_UnitAuras.GetPlayerAuraBySpellID(opt.DpsInfo.aura_id)
	if (aura) then
		opt:OnGainDpsCooldown()
	end
end

function opt:SetDpsSpellId(spell_id)

	if (not main) then return end
	
	if (spell_id == 0) then
		main.coolDownSpellTexture.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
		opt.DpsInfo.aura_id = 0
	else
		main.coolDownSpellTexture.texture:SetTexture(C_Spell.GetSpellTexture(opt.DpsInfo.spell_id))
		
		local aura_id = DPSBuddySpellAuras[opt.DpsInfo.spell_id]
		if (aura_id) then
			opt.DpsInfo.aura_id = aura_id
		else
			opt.DpsInfo.aura_id = spell_id
		end
	end

	opt:UpdateDpsAlpha()
end

function opt:UpdateDpsAlpha()

	if (not main.coolDownSpellTexture) then return end
	
	if (opt.DpsInfo.is_dead) then
		main.coolDownSpellTexture.texture:SetAlpha(0.25)
	elseif (opt.DpsInfo.spell_id > 0) then
		if (DPS_CD_Active) then
			main.coolDownSpellTexture.texture:SetAlpha(1)
		else
			main.coolDownSpellTexture.texture:SetAlpha(0.8)
		end
	else
		main.coolDownSpellTexture.texture:SetAlpha(0.25)
	end
end

-----------------------------------
-- dps aura
-----------------------------------

function opt:OnGainDpsCooldown()

	if (Glower and opt.env.ShowSpellGlow and not DPS_CD_Glowing) then
		Glower.PixelGlow_Start ( main.coolDownSpellTexture, nil, nil, nil, nil, nil, 1, 1)
		DPS_CD_Glowing = true
	end
	
	if (not DPS_CD_Active) then
		DPS_CD_Active = true

		local aura = C_UnitAuras.GetPlayerAuraBySpellID(opt.DpsInfo.aura_id)
		if (aura) then

			if (aura.expirationTime == 0) then
				timeRemaining = 0
			else
				timeRemaining = aura.expirationTime - GetTime()
			end
			
			if (timeRemaining < 0) then
				timeRemaining = -1
			end

			opt.DpsInfo.timer_remaining = timeRemaining
		else
			opt.DpsInfo.timer_remaining = -1
		end

		if (not opt.IsPriest) then
			opt:NotifyDpsActiveChanged()
		end
	end

	-- reset our timer text
	if (opt.env.ShowSpellTimers) then
		main.dpsTimer:Show()
	end

	main.dpsCooldown:Hide()
	main.dpsCooldownText:Hide()

	opt:UpdateDpsAlpha()
end

function opt:SimulateDpsCooldown(duration)
	opt:OnGainDpsCooldown()
	aura_override_time = GetTime() + duration
end

function opt:OnLoseDpsCooldown()

	if (DPS_CD_Glowing) then
		Glower.PixelGlow_Stop(main.coolDownSpellTexture)
		DPS_CD_Glowing = false
	end

	DPS_CD_Active = false

	if (opt.main) then
		opt.main.dpsTimer:Hide()
	end

	opt:UpdateDpsAlpha()
	aura_override_time = 0
	opt.DpsInfo.timer_remaining = -1

	if (not opt.IsPriest and opt.PriestInfo.is_synced) then
		opt:NotifyDpsActiveChanged()
	end
end

function opt:UpdateDpsAura()

	local notify = false
	local timeRemaining = -1

	if (DPS_CD_Active) then
			
		-- check override first
		if aura_override_time > 0 then

			timeRemaining = aura_override_time - GetTime()

			if (timeRemaining < 0) then
				timeRemaining = -1
				aura_override_time = -1
				opt:OnLoseDpsCooldown()
			end

			if (opt.env.ShowSpellTimers and timeRemaining > 0) then
				local text = string.format("%.1f", timeRemaining)
				main.dpsTimer:Show()
				main.dpsTimer:SetText(text)
			end

		else

			-- check aura 

			local aura = C_UnitAuras.GetPlayerAuraBySpellID(opt.DpsInfo.aura_id)
			if (aura) then

				if (aura.expirationTime == 0) then
					timeRemaining = 0
				else
					timeRemaining = aura.expirationTime - GetTime()
				end
				
				if (timeRemaining < 0) then
					timeRemaining = -1
				end
					
				if (opt.env.ShowSpellTimers and timeRemaining > 0) then
					local text = string.format("%.1f", timeRemaining)
					main.dpsTimer:Show()
					main.dpsTimer:SetText(text)
				end
			else
				timeRemaining = -1
			end
		end

	end

	-- different of >= 1 second since last active time, update
	if (opt.DpsInfo.timer_remaining > 0 and math.abs(timeRemaining - opt.DpsInfo.timer_remaining) >= 1) then
		notify = true
	end

	opt.DpsInfo.timer_remaining = timeRemaining

	if (notify) then
		opt:NotifyDpsActiveChanged()
	end
end


---------------------------------
-- timers
---------------------------------

local WAS_ON_COOLDOWN = false
function opt:UpdateDpsTimers()
	opt:UpdateDpsAura()
	opt:UpdateDpsCooldown()
end

function opt:UpdateRemoteDpsTimers()
	opt:UpdateRemoteDpsActivity()
	opt:UpdateRemoteDpsCooldown()
end

---------------------------------
-- local timers
---------------------------------

local WAS_ON_COOLDOWN = false
function opt:UpdateDpsCooldown()
	
	-- early outs
	if (DPS_CD_Active) then 
		main.dpsCooldownText:Hide()
		main.dpsCooldown:Hide()
	end

	if (opt.DpsInfo.spell_id == 0) then return end

	-- get CD from API
	local spell_id = opt.DpsInfo.spell_id
	local spellCooldownInfo = C_Spell.GetSpellCooldown(spell_id);
	local start = spellCooldownInfo.startTime
	local duration = spellCooldownInfo.duration
	local enabled = spellCooldownInfo.isEnabled

	-- on CD behaviour
	local on_cooldown = (start > 0)
	if (on_cooldown) then
		-- check if we're actually on CD, or its the GCD
		local gcdInfo = C_Spell.GetSpellCooldown(61304);
		local gcd_duration = gcdInfo.duration
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
			if (math.abs(cd_remaining - opt.DpsInfo.cooldown_remaining) > 1) then
				notify = true
			end
		end
			
		-- update cached value
		opt.DpsInfo.cooldown_remaining = cd_remaining

		-- if we're running in DPS mode, we only update as the result of messages
		if (not DPS_CD_Active) then
			if (opt.env.ShowCooldownTimers) then
				main.dpsCooldownText:Show()
				main.dpsCooldownText:SetText(string.format("%.1f", cd_remaining))
			end
			main.dpsCooldown:SetCooldown(start, duration)
		end
	else

		opt.DpsInfo.cooldown_remaining = 0

		-- if we're running in DPS mode, we only update as the result of messages
		if (not opt.IsPriest) then
			main.dpsCooldown:SetCooldown(0, 0)
			main.dpsCooldownText:Hide()
		end
	end

	if (on_cooldown ~= WAS_ON_COOLDOWN) then
		notify = true
	end

	if (notify) then
		opt:NotifyDpsCooldownChanged()
	end

	WAS_ON_COOLDOWN = on_cooldown
end

--------------------------
-- remote timers
--------------------------

local remote_startTime = 0
local remote_endTime = 0
local remote_duration = 0

local remote_active_start = -1
local remote_active_end = -1
local remote_active_duration = -1

local media = LibStub("LibSharedMedia-3.0")

function opt:OnReceivedDpsActivity(active_time)
	local active = (active_time >= 0)

	-- if spell is on CD, calculate how long our timer should be
	if (active) then
		remote_active_start = GetTime()
		remote_active_duration = active_time
		remote_active_end = remote_active_start + remote_active_duration
		opt:OnGainDpsCooldown()

		-- don't play a sound if we're well on cooldown
		local playSound = (opt.PriestInfo.cooldown_remaining <= 5)
		if (playSound) then
			if (opt.env.DpsCooldownAudio and opt.env.DpsCooldownAudio ~= "None") then
				if (opt.env.DpsCooldownAudio == "Power Infusion") then
					PlaySound(170678, "Master")
				else
					local soundFile = media:Fetch("sound", opt.env.DpsCooldownAudio)
					if (soundFile) then
						PlaySoundFile(soundFile, "Master")
					end
				end
			end

			opt:BeginPiMeGlow(false)
		end

	else
		remote_active_start = -1
		remote_active_end = -1
		remote_active_duration = -1
		opt:OnLoseDpsCooldown()
	end

	opt:UpdateRemoteDpsActivity()
end

function opt:UpdateRemoteDpsActivity()

	-- if we're tracking a CD atm
	local time_remaining = 0

	-- spells with duration=0 must rely on a notification that it was lost
	if (remote_active_start >= 0 and remote_active_duration > 0) then

		-- see how much time is left
		time_remaining = remote_active_end - GetTime()
		if (time_remaining < 0) then time_remaining = -1 end
		opt.DpsInfo.timer_remaining = time_remaining

		-- if the CD is over, wipe our timers
		if (time_remaining < 0) then
			remote_active_start = -1
			remote_active_end = -1
			remote_active_duration = -1
			opt:OnLoseDpsCooldown()
		end
	end
	
	local active = (time_remaining > 0)
	if (active and DPS_CD_Active and opt.env.ShowSpellTimers) then
		main.dpsTimer:Show()
		main.dpsTimer:SetText(string.format("%.1f", time_remaining))
	else
		main.dpsTimer:Hide()
	end
end

-- cooldown

function opt:OnReceivedDpsCooldown(cooldown)
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

	opt:UpdateRemoteDpsCooldown()
end

function opt:UpdateRemoteDpsCooldown()

	-- early outs
	if (DPS_CD_Active) then 
		main.dpsCooldownText:Hide()
		main.dpsCooldown:Hide()
	end

	-- if we're tracking a CD atm
	local cd_remaining = 0
	if (remote_startTime > 0) then

		-- see how much time is left
		cd_remaining = remote_endTime - GetTime()
		if (cd_remaining < 0) then cd_remaining = 0 end
		opt.DpsInfo.cooldown_remaining = cd_remaining

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
	if (on_cooldown and not DPS_CD_Active) then
		if (opt.env.ShowCooldownTimers) then
			main.dpsCooldownText:Show()
			main.dpsCooldownText:SetText(string.format("%.1f", cd_remaining))
		end
		main.dpsCooldown:SetCooldown(remote_startTime, remote_duration)
	else
		main.dpsCooldown:SetCooldown(0, 0)
		main.dpsCooldownText:Hide()
	end
end