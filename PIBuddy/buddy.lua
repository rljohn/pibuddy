local opt = PIBuddyConfig

opt.PriestInfo = {}
opt.DpsInfo = {}

-- reset functions


function opt:ResetInfo(buddy)
	buddy.guid = nil
	buddy.name = nil
	buddy.name_short = nil
	buddy.realm = nil
	buddy.connected = false
	buddy.unit_id = nil
	buddy.class_id = 0
	buddy.class_name = ""
	buddy.spec_id = 0
	buddy.spell_id = 0
	buddy.aura_id = 0
	buddy.cooldown_remaining = 0
	buddy.timer_remaining = -1
	buddy.cast_time = 0
	buddy.cooldown = 0
	buddy.is_syncing = false
	buddy.failed_sync = false
	buddy.is_synced = false
	buddy.player_declined = false

	if (buddy.is_dead) then
		opt.IsBuddyDead = false
	end
	buddy.is_dead = false
end

function opt:ResetPriestInfo()
	opt:ResetInfo(opt.PriestInfo)
	opt.PriestInfo.spell_id = opt.POWER_INFUSION
	opt.PriestInfo.aura_id = opt.POWER_INFUSION
end

function opt:ResetDpsInfo()
	opt:ResetInfo(opt.DpsInfo)
end

function opt:ResetBuddyInfo()
	opt:ResetPriestInfo()
	opt:ResetDpsInfo()
end

-- group events

function opt:OnGroupChanged()

	if (IsInGroup() or IsInRaid()) then
		opt.InGroup = true
	else
		-- if we leave a group, kill our info
		if (opt.InGroup) then
			if (opt.IsPriest) then
				opt:ResetDpsInfo()
			else
				opt:ResetPriestInfo()
			end
		end

		opt.InGroup = false
	end

	opt.InRaid = IsInRaid()
	opt:CheckMacros()
	opt:CheckPriestBuddy()
	opt:CheckDpsBuddy()
	opt:SyncInfo()
	opt:ForceUiUpdate()
end

function opt:ResetSyncInfo(buddy)
	buddy.is_syncing = false
	buddy.failed_sync = false
	buddy.is_synced = false
	buddy.player_declined = false
end


-- priest set functions

function opt:ResetAndResyncPriest()
	opt:ResetSyncInfo(opt.PriestInfo)
	opt:ResetPriestUi()
	opt:CheckPriestBuddy()
end

function opt:SetPriestBuddy(name)
	if (opt.PriestInfo.is_synced or opt.PriestInfo.is_syncing) then
		if (name ~= opt.env.PriestBuddy and opt.PriestInfo.connected) then
			opt:NotifyFriendshipTerminated(opt.env.PriestBuddy, "party", opt.PriestInfo.realm)
		end
	end
	opt.env.PriestBuddy = name
	if (not opt.InRaid) then
		opt:ResetAndResyncPriest()
	end
	opt:UpdatePriestBuddyUi()
	opt:UpdateBuddyStatusUi()
end

function opt:SetRaidPriestBuddy(name)
	-- If synced or syncing and our value changed
	if (opt.PriestInfo.is_synced or opt.PriestInfo.is_syncing) then
		if (name ~= opt.env.RaidPriestBuddy and opt.PriestInfo.connected) then
			opt:NotifyFriendshipTerminated(opt.env.RaidPriestBuddy, "raid", opt.PriestInfo.realm)
		end
	end
	opt.env.RaidPriestBuddy = name
	if (opt.InRaid) then
		opt:ResetAndResyncPriest()
	end
	opt:UpdatePriestBuddyUi()
	opt:UpdateBuddyStatusUi()
end

function opt:UpdatePriestBuddyUi()
	opt:SetPriestName(opt.PriestInfo.name_short)
	opt:UpdatePIAlpha()
end

function opt:SetPriestSpec(spec_id)
	opt.PriestInfo.spec_id = spec_id
end

function opt:OnPriestBuddyLost(name, mode)
	if (mode == "raid") then
		if (name == strlower(opt.env.RaidPriestBuddy)) then
			if (opt.InRaid) then
				opt:ResetPriestInfo()
				opt:ResetAndResyncPriest()
				opt.PriestInfo.player_declined = true
			end
			opt:ForceUiUpdate()
		end
	else
		if (name == strlower(opt.env.PriestBuddy)) then
			if (not opt.InRaid) then
				opt:ResetPriestInfo()
				opt:ResetAndResyncPriest()
				opt.PriestInfo.player_declined = true
			end
			opt:ForceUiUpdate()
		end
	end
end

-- dps set functions

function opt:SetDpsSpec(spec_id)
	opt.DpsInfo.spec_id = spec_id
end

function opt:ResetAndResyncDps()
	opt:ResetSyncInfo(opt.DpsInfo)
	opt:ResetDpsUi()
	opt:CheckDpsBuddy()
end

function opt:SetDpsBuddy(name)
	if (opt.DpsInfo.is_synced or opt.DpsInfo.is_syncing) then
		if (name ~= opt.env.DpsBuddy and opt.DpsInfo.connected) then
			opt:NotifyFriendshipTerminated(opt.env.DpsBuddy, "party", opt.DpsInfo.realm)
		end
	end
	
	local update_macro = false
	if (opt.IsPriest and opt.env.DpsBuddy ~= name) then
		update_macro = true
	end

	opt.env.DpsBuddy = name
	if (not opt.InRaid) then
		opt:ResetAndResyncDps()
	end
	opt:UpdateDpsBuddyUi()
	opt:UpdateBuddyStatusUi()

	if (update_macro) then
		opt:RefreshPIMacros(true)
	end
end

function opt:SetRaidDpsBuddy(name)
	if (opt.DpsInfo.is_synced or opt.DpsInfo.is_syncing) then
		if (name ~= opt.env.RaidDpsBuddy and opt.DpsInfo.connected) then
			opt:NotifyFriendshipTerminated(opt.env.RaidDpsBuddy, "raid", opt.DpsInfo.realm)
		end
	end

	local update_macro = false
	if (opt.IsPriest and opt.env.RaidDpsBuddy ~= name) then
		update_macro = true
	end

	opt.env.RaidDpsBuddy = name

	if (opt.InRaid) then
		opt:ResetAndResyncDps()
	end
	opt:UpdateDpsBuddyUi()
	opt:UpdateBuddyStatusUi()

	if (update_macro) then
		opt:RefreshPIMacros(false)
	end
end

function opt:UpdateBuddyDpsSpellId(spell_id)
	opt.DpsInfo.spell_id = spell_id
end

function opt:UpdateDpsBuddyUi()
	opt:SetDpsName(opt.DpsInfo.name_short)
	opt:UpdateDpsAlpha()
end

function opt:OnDpsBuddyLost(name, mode)
	if (mode == "raid") then
		if (name == strlower(opt.env.RaidDpsBuddy)) then
			if (opt.InRaid) then
				opt:ResetDpsInfo()
				opt:ResetAndResyncDps()
				opt.DpsInfo.player_declined = true
			end
			opt:ForceUiUpdate()
		end
	else
		if (name == strlower(opt.env.DpsBuddy)) then
			if (not opt.InRaid) then
				opt:ResetDpsInfo()
				opt:ResetAndResyncDps()
				opt.DpsInfo.player_declined = true
			end
			opt:ForceUiUpdate()
		end
	end
end

-- check functions

function opt:HasPriestBuddy()
	if (opt.PriestInfo.name == nil or opt.PriestInfo.name == "") then
		return false
	end
	
	return true
end

function opt:HasDpsBuddy()
	if (opt.DpsInfo.name == nil or opt.DpsInfo.name == "") then
		return false
	end
	
	return true
end


function opt:CheckPriestBuddy()
	
	local player

	if (opt.IsPriest) then
		player = opt:FindPlayer(opt.PlayerName)
	else
		if (opt.InRaid) then
			player = opt:FindPlayer(opt.env.RaidPriestBuddy)
		else
			player = opt:FindPlayer(opt.env.PriestBuddy)
		end
	end
	
	if (player) then
		opt.PriestInfo.unit_id = player
		opt.PriestInfo.guid = UnitGUID(player)
		opt.PriestInfo.name = opt:SpaceStripper(GetUnitName(player, true))
		opt.PriestInfo.name_short, opt.PriestInfo.realm = UnitName(player)
		opt.PriestInfo.realm = opt:SpaceStripper(opt.PriestInfo.realm)
		className, classFilename, classId = UnitClass(player)
		if (classId ~= 5) then
			-- nice try, but you need to link with a priest!
			opt:ResetPriestInfo()
			opt.PriestInfo.class_id = classId
			opt.PriestInfo.class_name = className
			return
		end
		opt.PriestInfo.class_id = classId
		opt.PriestInfo.class_name = className
		opt.PriestInfo.connected = UnitIsConnected(player)
		if (UnitIsDeadOrGhost(player)) then
			opt.PriestInfo.is_dead = true
			opt.IsBuddyDead = true
		end
	else
		opt:ResetPriestInfo()
		opt:ResetPriestUi()
	end
end

function opt:CheckDpsBuddy()

	local player
	if (not opt.IsPriest) then
		player = opt:FindPlayer(opt.PlayerName)
	else
		if (opt.InRaid) then
			player = opt:FindPlayer(opt.env.RaidDpsBuddy)
		else
			player = opt:FindPlayer(opt.env.DpsBuddy)
		end
	end
	
	-- reset the focus attriute to 'target'
	--opt:ChangeFocusTargetUnitId(nil)

	if (player) then
		opt.DpsInfo.unit_id = player
		opt.DpsInfo.guid = UnitGUID(player)
		opt.DpsInfo.name = opt:SpaceStripper(GetUnitName(player, true))
		opt.DpsInfo.name_short, opt.DpsInfo.realm = UnitName(player)
		opt.DpsInfo.realm = opt:SpaceStripper(opt.DpsInfo.realm)
		className, classFilename, classId = UnitClass(player)
		if (classId == 5) then
			-- nice try, but you can't link with another priest
			opt:ResetDpsInfo()
			opt:SetDpsSpellId(0)
			opt.DpsInfo.class_id = classId
			opt.DpsInfo.class_name = className
			return
		end

		-- set the focus attribute
		--opt:ChangeFocusTargetUnitId(player)

		opt.DpsInfo.class_id = classId
		opt.DpsInfo.class_name = className
		opt.DpsInfo.connected = UnitIsConnected(player)
		if (UnitIsDeadOrGhost(player)) then
			opt.DpsInfo.is_dead = true
			opt.IsBuddyDead = true
		end
	else
		opt:ResetDpsInfo()
		opt:SetDpsSpellId(0)
		opt:ResetDpsUi()
	end
end

-- Player Lookup

function opt:FindPlayer(n) 

	if (n == nil or n == "") then return nil end
	n = strlower(n)
	
	-- is it a local player
	
	local localPlayer = strlower(opt.PlayerName)
	if (localPlayer == n) then
		return "player"
	end
	
	-- check raid members, party members
	
	if (IsInRaid()) then
		for i = 1, MAX_RAID_MEMBERS do
			name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(i)
			if (name) then
				name = strlower(name)
				local unitId = "raid" .. i
				if (name == n) then
					return unitId
				end
			end
		end
	elseif (IsInGroup()) then
		for i = 1, 4 do
			local unitId = "party" .. i
			local name = GetUnitName(unitId, true)
			if (name) then
				if (strlower(name) == n) then
					return unitId
				end
			end
		end
	end
	
	return nil
end

-- Updated DPS Info from Messaging

function opt:SetDpsInfo(class_id, spec_id, spell_id)
	opt.DpsInfo.class_id = class_id
	opt.DpsInfo.spec_id = spec_id
	opt.DpsInfo.spell_id = spell_id
	opt.DpsInfo.is_synced = true
	opt.DpsInfo.failed_sync = false
	opt.DpsInfo.is_syncing = false
	opt.DpsInfo.player_declined = false
	
	-- update UI
	opt:SetDpsSpellId(spell_id)
end

-- Updated Priest Info from Messaging

function opt:SetPriestInfo(class_id, spec_id, spell_id)
	opt.PriestInfo.class_id = class_id
	opt.PriestInfo.spec_id = spec_id
	opt.PriestInfo.is_synced = true
	opt.PriestInfo.failed_sync = false
	opt.PriestInfo.is_syncing = false
	opt.PriestInfo.player_declined = false
end

-- Sync Info with players

function opt:SyncInfo()

	if (opt.IsPriest) then
		if (not opt.DpsInfo.is_synced and opt.DpsInfo.name and opt.DpsInfo.name ~= "" and opt.DpsInfo.connected) then
			
			opt.DpsInfo.is_syncing = true
			opt:SendDpsInfoRequest()

			-- time out after 5 seconds, failed the sync
			C_Timer.After(5, function() 
				if (not opt.DpsInfo.is_synced) then
					opt.DpsInfo.failed_sync = true
					opt.DpsInfo.is_syncing = false
					opt:ForceUiUpdate()
				end
			end)
		end
	else
		if (not opt.PriestInfo.is_synced and opt.PriestInfo.name and opt.PriestInfo.name ~= "" and opt.PriestInfo.connected) then
			
			opt.PriestInfo.is_syncing = true
			opt:SendPriestInfoRequest()

			-- time out after 5 seconds, failed the sync
			C_Timer.After(5, function() 
				if (not opt.PriestInfo.is_synced) then
					opt.PriestInfo.failed_sync = true
					opt.PriestInfo.is_syncing = false
					opt:ForceUiUpdate()
				end
			end)
		end
	end
		
end

-- Command line

function opt:SetBuddyTarget()

	local target = GetUnitName("target", true)

	-- must have a valid player target (who isn't us!)
	if (not target) then return end
	if (not UnitIsPlayer("target")) then return end
	if (target == opt.PlayerName) then return end

	className, classFilename, classId = UnitClass("target")

	if (opt.IsPriest) then

		-- Priests can only set non-priests
		if (classId == 5) then return end

		if (opt.InRaid) then
			opt:SetRaidDpsBuddy(target)
			opt.ui.raid_dpsEditBox:SetText(target)
			opt.ui.raid_dpsEditBox:SetCursorPosition(0)
		else
			opt:SetDpsBuddy(target)
			opt.ui.dpsEditBox:SetText(target)
			opt.ui.dpsEditBox:SetCursorPosition(0)
		end
	else
		if (classId ~= 5) then return end

		if (opt.InRaid) then
			opt:SetRaidPriestBuddy(target)
			opt.ui.raid_priestEditBox:SetText(target)
			opt.ui.raid_priestEditBox:SetCursorPosition(0)
		else
			opt:SetPriestBuddy(target)
			opt.ui.priestEditBox:SetText(target)
			opt.ui.priestEditBox:SetCursorPosition(0)
		end
	end

	opt:SyncInfo()
	opt:ForceUiUpdate()
end


-- we update every 0.1s, so check every 5 updates (0.5s)
local FRAME_INTERVAL = 5
local FRAME_SINCE_LAST_UPDATE = 0
function opt:UpdateDeadBuddy(elapsed)
	
	FRAME_SINCE_LAST_UPDATE = FRAME_SINCE_LAST_UPDATE + 1
	if FRAME_SINCE_LAST_UPDATE < FRAME_INTERVAL then return end
	FRAME_SINCE_LAST_UPDATE = 0

	local BuddyInfo = nil
	if (opt.IsPriest) then
		BuddyInfo = opt.DpsInfo
	else
		BuddyInfo = opt.PriestInfo
	end

	if (not BuddyInfo) then return end

	local player = opt:FindPlayer(BuddyInfo.name)
	if (player) then
		if (not UnitIsDeadOrGhost(player)) then
			BuddyInfo.is_dead = false
			opt.IsBuddyDead = false
			opt:ForceUiUpdate()
		end
	end
end

function opt:CheckBuddyDead(sourceGUID)

	if (opt.IsPriest) then
		BuddyInfo = opt.DpsInfo
	else
		BuddyInfo = opt.PriestInfo
	end
	
	if (not BuddyInfo.guid) then return end

	local player = opt:FindPlayer(BuddyInfo.name)
	if (player) then
		if (UnitIsDeadOrGhost(player)) then
			BuddyInfo.is_dead = true
			opt.IsBuddyDead = true
			opt:ForceUiUpdate()
		end
	end
end