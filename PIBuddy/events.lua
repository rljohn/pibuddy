local opt = PIBuddyConfig

-- Setup Slash Commands

function opt:PrintHelp()
	print('|cffFFF569PI|r Buddy Commands:')
	print(' /pibuddy request - Requests a PI immediately from your buddy (if set).')
	print(' /pibuddy set - Sets your current target as your PI Buddy.')
	print(' /pibuddy show - Shows the PI Buddy frame.')
	print(' /pibuddy hide - Hides the PI Buddy frame.')
	print(' /pibuddy lock - Locks the PI Buddy frame.')
	print(' /pibuddy unlock - Unlocks the PI Buddy frame.')
	print(' /pibuddy reset - Resets the PI Buddy addon.')
end

SLASH_PIBUDDY1 = '/pibuddy';
function SlashCmdList.PIBUDDY(msg, editbox)
 if (msg == "request") then
	opt:SendPiMeRequest()
 elseif (msg == "set") then
	opt:SetBuddyTarget()
 elseif (msg == "show") then
	opt:ForceUiUpdate()
 elseif (msg == "hide") then
	opt:ForceUiUpdate()
 elseif (msg == "lock") then
	opt:Lock()
 elseif (msg == "unlock") then
	opt:Unlock()
 elseif (msg == "sync") then
	opt:SyncInfo()
 elseif (msg == "reset") then
	opt:ResetAll()
 elseif (msg == "help") then
	opt:PrintHelp()
 else
	opt:Config()
 end
end


-- events
opt:RegisterEvent("PLAYER_LOGIN")
opt:RegisterEvent("PLAYER_LOGOUT")
opt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
opt:RegisterEvent("PLAYER_REGEN_DISABLED")
opt:RegisterEvent("PLAYER_REGEN_ENABLED")
opt:RegisterEvent("SPELL_UPDATE_COOLDOWN")
opt:RegisterEvent("GROUP_ROSTER_UPDATE")
opt:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
opt:RegisterEvent("TRAIT_CONFIG_UPDATED")
opt:RegisterEvent("PLAYER_FOCUS_CHANGED")
opt:RegisterEvent("PLAYER_DEAD")

-- Events

function opt:OnCombatEvent(...)

	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

	-- all events we care about will have a dest or source
	local is_from_player = (sourceGUID == opt.PlayerGUID)
	local is_targeting_player = (destGUID == opt.PlayerGUID)

	-- Spell Aura was Applied

	if (subevent == "SPELL_AURA_APPLIED") then
	
		-- Check if we gained power infusion or our DPS cooldown
		if (destGUID == opt.PlayerGUID) then
			local spell_id = select(12,...)
			if (spell_id == opt.PriestInfo.aura_id) then
				opt:OnGainPowerInfusion()
			elseif (spell_id == opt.DpsInfo.aura_id) then
				opt:OnGainDpsCooldown()
			end
		end

		-- In one-way mode, check if the DPS player gained their cooldown
		if (opt:IsOneWayEnabled()) then
			
			if (opt.IsPriest and destGUID == opt.DpsInfo.guid) then
				local spell_id = select(12,...)
				local default = DPSBuddyEstimates[spell_id]
				if (default) then

					if (default[4]) then
						opt:SetDpsSpellId(default[4])
					else
						opt:SetDpsSpellId(spell_id)
					end
					
					local query_duration = opt:GetAuraDuration(spell_id, opt.DpsInfo.unit_id)
					if (default[3] and query_duration < default[3]) then
						-- ignore, duration was too short
					elseif (query_duration > 0) then
						opt:OnReceivedDpsActivity(query_duration)
					else
						opt:OnReceivedDpsActivity(default[2])
					end
				end
			end
		end
	
	-- Spell Aura was Removed
	elseif (subevent == "SPELL_AURA_REMOVED") then
	
		-- Check if we lost power infusino or our DPS cooldown
		if (destGUID == opt.PlayerGUID) then
			local spell_id = select(12,...)
			if (spell_id == opt.PriestInfo.aura_id) then
				opt:OnLosePowerInfusion()
			elseif (spell_id == opt.DpsInfo.aura_id) then
				opt:OnLoseDpsCooldown()
			end
		end
	
	-- A spell was cast!
	elseif (subevent == "SPELL_CAST_SUCCESS") then

		-- We're the DPS player - check if we have a active-time override for this spell.
		if (sourceGUID == opt.PlayerGUID) then
			local spell_id = select(12,...)
			if (opt.IsPriest) then
				if (spell_id == opt.POWER_INFUSION) then
					opt:OnCastPowerInfusion()
				end
			else
				if (spell_id == opt.DpsInfo.spell_id) then
					local aura_timer = DPSBuddySpellActiveTime[spell_id]
					if (aura_timer) then
						opt:SimulateDpsCooldown(aura_timer)
					end
				end
			end
		end

		-- If we're in one-way mode, check if we should track this spell
		if (opt:IsOneWayEnabled()) then
			if (opt.IsPriest) then

				-- We're the priest, spell was cast by the DPS player
				if (sourceGUID == opt.DpsInfo.guid) then
					local spell_id = select(12,...)

					-- lookup the estimates for this spell
					local default = DPSBuddyEstimates[spell_id]

					-- if we found one, pretend like they just told us they cast this ability.
					-- use default timers for the time remaining
					if (default) then

						if (default[4]) then
							opt.DpsInfo.spell_id = default[4]
							opt:SetDpsSpellId(default[4])
						else
							opt.DpsInfo.spell_id = spell_id
							opt:SetDpsSpellId(spell_id)
						end

						opt:OnReceivedDpsCooldown(default[1])
						local query_duration = opt:GetAuraDuration(spell_id, opt.DpsInfo.unit_id)
						if (default[3] and query_duration < default[3]) then
							-- ignore, duration was too short
						elseif (query_duration > 0) then
							opt:OnReceivedDpsActivity(query_duration)
						else
							opt:OnReceivedDpsActivity(default[2])
						end
					end
				end
			else
				-- we're the DPS player - check if our chosen priest just cast power infusion
				if (sourceGUID == opt.PriestInfo.guid) then
					local spell_id = select(12,...)
					if (spell_id == opt.POWER_INFUSION) then
						opt:OnReceivedPICooldown(120)
					end
				end
			end
		end
	
	elseif (subevent == "UNIT_DIED") then
		opt:CheckBuddyDead(sourceGUID)
	end
end

function opt:OnEnterCombat()
	opt.InCombat = true
	opt:ForceUiUpdate()
end

function opt:OnLeaveCombat()
	opt.InCombat = false
	opt:ForceUiUpdate()
end

function opt:OnCooldownUpdate()

	if (opt.IsPriest) then
		opt:UpdatePowerInfusionCooldown(true)
	end
	
	if (not opt.IsPriest) then
		opt:UpdateDpsCooldown(true)
	end
end


-- Event Handlers

local function PIBuddy_EventHandler(self, event, ...)

	if (event == "PLAYER_LOGIN") then
		opt:OnLogin()
	elseif (event == "PLAYER_LOGOUT") then
		opt:OnLogout()
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		opt:OnCombatEvent(CombatLogGetCurrentEventInfo())
	elseif (event == "SPELL_UPDATE_COOLDOWN") then
		opt:OnCooldownUpdate()
	elseif (event == "PLAYER_REGEN_DISABLED") then
		opt:OnEnterCombat()
	elseif (event == "PLAYER_REGEN_ENABLED") then
		opt:OnLeaveCombat()
	elseif (event == "GROUP_ROSTER_UPDATE") then
		opt:OnGroupChanged()
	elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then
		opt:OnTalentsChanged()
	elseif (event == "PARTY_CONVERTED_TO_RAID") then
		opt:OnGroupChanged()
	elseif (event == "TRAIT_CONFIG_UPDATED") then
		opt:OnTalentsChanged()
	elseif (event == "PLAYER_FOCUS_CHANGED") then
		opt:OnPlayerFocusChanged()
	elseif (event == "PLAYER_DEAD") then
		opt:OnPlayerDied()
	end
end
opt:SetScript("OnEvent", PIBuddy_EventHandler)