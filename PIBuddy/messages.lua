local opt = PIBuddyConfig
local ignore_list = {}
local ALLOW_TEST_FUNCTIONS=false

-- API version appended to initial sync messages
-- Usage: Identifies a user on an older client
local CURRENT_VERSION = 1

-- dps info
local DPS_INFO_REQUEST = 100
local DPS_INFO_REPLY = 101
local NOTIFY_DPS_INFO_CHANGED = 102

-- priest info
local PRIEST_INFO_REQUEST = 200
local PRIEST_INFO_REPLY = 201
local NOTIFY_PRIEST_INFO_CHANGED = 202

-- power infusion
local NOTIFY_PI_COOLDOWN_CHANGED = 300
local PI_COOLDOWN_REQUEST = 301
local PI_COOLDOWN_REPLY = 302

-- dps cooldown
local NOTIFY_DPS_COOLDOWN_CHANGED = 400
local DPS_COOLDOWN_REQUEST = 401
local DPS_COOLDOWN_REPLY = 402

-- dps active
local NOTIFY_DPS_ACTIVE_CHANGED = 500

-- pi me
local REQUEST_PIME = 600

-- request buddy
local REQUEST_BUDDY = 700
local REQUEST_BUDDY_ACCEPT = 701
local REQUEST_BUDDY_DECLINE = 702

-- friendship over
local BUDDY_CHANGED = 800

-----------------------------------
-- Debug Print
-----------------------------------
function opt:PrintMessageId(id)
	local table = 
	{
		-- dps info
		[DPS_INFO_REQUEST] = "DPS_INFO_REQUEST",
		[DPS_INFO_REPLY] = "DPS_INFO_REPLY",
		[NOTIFY_DPS_INFO_CHANGED] = "NOTIFY_DPS_INFO_CHANGED",

		-- priest info
		[PRIEST_INFO_REQUEST] = "PRIEST_INFO_REQUEST",
		[PRIEST_INFO_REPLY] = "PRIEST_INFO_REPLY",
		[NOTIFY_PRIEST_INFO_CHANGED] = "NOTIFY_PRIEST_INFO_CHANGED",

		-- power infusion cooldown
		[NOTIFY_PI_COOLDOWN_CHANGED] = "NOTIFY_PI_COOLDOWN_CHANGED",
		[PI_COOLDOWN_REQUEST] = "PI_COOLDOWN_REQUEST",
		[PI_COOLDOWN_REPLY] = "PI_COOLDOWN_REPLY",
	
		-- dps cooldown
		[NOTIFY_DPS_COOLDOWN_CHANGED] = "NOTIFY_DPS_COOLDOWN_CHANGED",
		[DPS_COOLDOWN_REQUEST] = "DPS_COOLDOWN_REQUEST",
		[DPS_COOLDOWN_REPLY] = "DPS_COOLDOWN_REPLY",

		-- dps active
		[NOTIFY_DPS_ACTIVE_CHANGED] = "NOTIFY_DPS_ACTIVE_CHANGED",

		-- pi me!!
		[REQUEST_PIME] = "REQUEST_PIME",

		-- buddy request
		[REQUEST_BUDDY] = "REQUEST_BUDDY",
		[REQUEST_BUDDY_ACCEPT] = "REQUEST_BUDDY_ACCEPT",
		[REQUEST_BUDDY_DECLINE] = "REQUEST_BUDDY_DECLINE",

		-- buddy changed
		[BUDDY_CHANGED] = "BUDDY_CHANGED"

	}

	return table[id] or 'UNKNOWN MESSAGE'
end

-----------------------------------
-- Dps Info Sync
-----------------------------------

-- request info from the dps player

function opt:SendDpsInfoRequest()
	local message = { }
	message.id = DPS_INFO_REQUEST
	message.version = CURRENT_VERSION
	opt:SendMessage(message, opt.DpsInfo.name)
end

-- received dps info request from priest

function opt:OnDpsInfoRequest(message)
	opt:SendDpsInfoReply()
	opt:SyncInfo()
end

-- send dps info back to the priest
 
function opt:SendDpsInfoReply()
	local message = { }
	message.id = DPS_INFO_REPLY
	message.version = CURRENT_VERSION
	message.class_id = opt.PlayerClass
	message.spec_id = opt.PlayerSpec
	message.spell_id = opt.DpsInfo.spell_id
	
	opt:SendMessage(message, opt.PriestInfo.name)
end

-- received info from the dps

function opt:OnDpsInfoReply(message)
	opt:SetDpsInfo(message.class_id, message.spec_id, message.spell_id)
	opt:ForceUiUpdate()
	opt:SendDpsCooldownRequest()
end

-- notify the priest my DPS info changed

function opt:NotifyDpsInfoChanged()
	local message = { }
	message.id = NOTIFY_DPS_INFO_CHANGED
	message.class_id = opt.PlayerClass
	message.spec_id = opt.PlayerSpec
	message.spell_id = opt.DpsInfo.spell_id

	opt:SendMessage(message, opt.PriestInfo.name)
end

-----------------------------------
-- Priest Info Sync
-----------------------------------

-- request info from the priest

function opt:SendPriestInfoRequest()
	local message = { }
	message.id = PRIEST_INFO_REQUEST
	message.version = CURRENT_VERSION
	opt:SendMessage(message, opt.PriestInfo.name)
end

-- received priest info request from dps

function opt:OnPriestInfoRequest(message)
	opt:SendPriestInfoReply()
	opt:SyncInfo()
end

-- send priest info back to the dps
 
function opt:SendPriestInfoReply()
	local message = { }
	message.id = PRIEST_INFO_REPLY
	message.version = CURRENT_VERSION
	message.class_id = opt.PlayerClass
	message.spec_id = opt.PlayerSpec
	message.spell_id = opt.PriestInfo.spell_id
	opt:SendMessage(message, opt.DpsInfo.name)
end

-- received info from the priest

function opt:OnPriestInfoReply(message)
	opt:SetPriestInfo(message.class_id, message.spec_id, message.spell_id)
	opt:ForceUiUpdate()
	opt:SendPICooldownRequest()
end

-- notify the dps that my priest info has changed

function opt:NotifyPriestInfoChanged()
	local message = { }
	message.id = NOTIFY_PRIEST_INFO_CHANGED
	message.class_id = opt.PlayerClass
	message.spec_id = opt.PlayerSpec
	message.spell_id = opt.PriestInfo.spell_id
	opt:SendMessage(message, opt.DpsInfo.name)
end

-----------------------------------
-- PI Cooldown Messages
-----------------------------------

function opt:SendPICooldownRequest()
	local message = { }
	message.id = PI_COOLDOWN_REQUEST
	opt:SendMessage(message, opt.PriestInfo.name)
end

function opt:OnPICooldownRequest()
	opt:UpdatePriestTimers()

	local message = { }
	message.id = PI_COOLDOWN_REPLY
	message.spell_id = opt.PriestInfo.spell_id
	message.cooldown_remaining = opt.PriestInfo.cooldown_remaining
	opt:SendMessage(message, opt.DpsInfo.name)
end

function opt:OnPICooldownReply(message)
	opt.PriestInfo.cooldown_remaining = message.cooldown_remaining
	opt:OnReceivedPICooldown(message.cooldown_remaining)
end

function opt:NotifyPICooldownChanged()
	local message = { }
	message.id = NOTIFY_PI_COOLDOWN_CHANGED
	message.spell_id = opt.PriestInfo.spell_id
	message.cooldown_remaining = opt.PriestInfo.cooldown_remaining
	opt:SendMessage(message, opt.DpsInfo.name)
end

-----------------------------------
-- dps cooldown messages
-----------------------------------

function opt:SendDpsCooldownRequest()
	local message = { }
	message.id = DPS_COOLDOWN_REQUEST
	opt:SendMessage(message, opt.DpsInfo.name)
end

function opt:OnDpsCooldownRequest()
	opt:UpdateDpsTimers()

	local message = { }
	message.id = DPS_COOLDOWN_REPLY
	message.spell_id = opt.DpsInfo.spell_id
	message.cooldown_remaining = opt.DpsInfo.cooldown_remaining
	message.timer_remaining = opt.DpsInfo.timer_remaining
	
	opt:SendMessage(message, opt.PriestInfo.name)
end

function opt:OnDpsCooldownChanged(message)
	opt.DpsInfo.cooldown_remaining = message.cooldown_remaining
	opt:OnReceivedDpsCooldown(message.cooldown_remaining)
end

function opt:OnDpsCooldownReply(message)
	-- update cooldown
	opt.DpsInfo.cooldown_remaining = message.cooldown_remaining
	opt:OnReceivedDpsCooldown(message.cooldown_remaining)

	-- update activity
	opt.DpsInfo.timer_remaining = message.timer_remaining
	opt:OnReceivedDpsActivity(message.timer_remaining)
end

function opt:NotifyDpsCooldownChanged()
	local message = { }
	message.id = NOTIFY_DPS_COOLDOWN_CHANGED
	message.spell_id = opt.DpsInfo.spell_id
	message.cooldown_remaining = opt.DpsInfo.cooldown_remaining
	opt:SendMessage(message, opt.PriestInfo.name)
end

-----------------------------------
-- dps active messages
-----------------------------------

function opt:NotifyDpsActiveChanged()
	local message = { }
	message.id = NOTIFY_DPS_ACTIVE_CHANGED
	message.spell_id = opt.DpsInfo.spell_id
	message.timer_remaining = opt.DpsInfo.timer_remaining
	opt:SendMessage(message, opt.PriestInfo.name)
end

function opt:OnDpsActiveReply(message)
	opt.DpsInfo.timer_remaining = message.timer_remaining
	opt:OnReceivedDpsActivity(message.timer_remaining)
end

-----------------------------------
-- PI Me Messages
-----------------------------------

function opt:SendPiMeRequest()
	local message = { }
	message.id = REQUEST_PIME
	opt:SendMessage(message, opt.PriestInfo.name)
end

function opt:OnPiMeRequest(message)
	opt:OnReceivedPIRequest(name)
end

-----------------------------------
-- Buddy Changed
-----------------------------------

function opt:NotifyFriendshipTerminated(name, mode)
	local message = { }
	message.id = BUDDY_CHANGED
	message.mode = mode
	opt:SendMessage(message, name)
end

function opt:OnBuddyChanged(message)
	pbPrintf("%s removed you as a PI Buddy.", message.name, message.mode)

	local name = strlower(message.name)
	if (opt.IsPriest) then
		opt:OnDpsBuddyLost(name, message.mode)
	else
		opt:OnPriestBuddyLost(name, message.mode)
	end
end

-----------------------------------
-- Request Buddy Message
-----------------------------------

local request_buddy
local request_mode

function opt:SendPIBuddyRequest(name, mode)

	if (opt.IsPriest) then
		opt.DpsInfo.player_declined = false
	else
		opt.PriestInfo.player_declined = false
	end

	-- cache our requestee
	request_buddy = name

	-- send the message
	local message = { }
	message.id = REQUEST_BUDDY
	message.mode = mode
	opt:SendMessage(message, name)

	-- update ui
	opt:ForceUiUpdate()
end

function opt:OnPIBuddyRequest(message)
	opt:RequestPIBuddy(message.name, message.mode)
end

function opt:ConfirmRequestBuddy()
	local name = request_buddy
	if (not request_buddy or request_buddy == "") then return end

	-- clear out the ignore list for this player for next time
	ignore_list[strlower(request_buddy)] = nil

	if (opt.IsPriest) then
		if (request_mode == "raid") then
			opt:SetRaidDpsBuddy(name)
			opt.ui.raid_dpsEditBox:SetText(name)
			opt.ui.raid_dpsEditBox:SetCursorPosition(0)
		else
			opt:SetDpsBuddy(name)
			opt.ui.dpsEditBox:SetText(name)
			opt.ui.dpsEditBox:SetCursorPosition(0)
		end
	else
		if (request_mode == "raid") then
			opt:SetRaidPriestBuddy(name)
			opt.ui.raid_priestEditBox:SetText(name)
			opt.ui.raid_priestEditBox:SetCursorPosition(0)
		else
			opt:SetPriestBuddy(name)
			opt.ui.priestEditBox:SetText(name)
			opt.ui.priestEditBox:SetCursorPosition(0)
		end
	end

	opt:SyncInfo()
	opt:ForceUiUpdate()
end

function opt:DenyBuddyRequest()

	local message = {}
	message.id = REQUEST_BUDDY_DECLINE
	opt:SendMessage(message, request_buddy)

end

function opt:OnAcceptBuddyRequest(name)
	if (strlower(name) == strlower(request_buddy)) then
		pbPrintf("%s accepted your buddy request.", name)

		local current_buddy = opt:GetCurrentBuddy()
		if (opt.IsPriest) then
			opt.DpsInfo.player_declined = false
		else
			opt.PriestInfo.player_declined = false
		end

		opt:ForceUiUpdate()
	end
end

function opt:OnDeclineBuddyRequest(name)
	if (request_buddy and strlower(name) == strlower(request_buddy)) then
		if (opt.IsPriest) then
			opt.DpsInfo.player_declined = true
		else
			opt.PriestInfo.player_declined = true
		end
		opt:ForceUiUpdate()
	end
end

local request_active = false
StaticPopupDialogs["PIBuddy_RequestBuddyConfirm"] = {
	text = "|cffFFF569PI Buddy|r: %s would like to be your %s buddy. Will you accept?",
	button1 = "Accept",
	button2 = "Decline",
	OnAccept = function(self, data, data2)
		opt:ConfirmRequestBuddy()
		request_active = false
	end,
	OnCancel  = function(self, data, data2)
		opt:DenyBuddyRequest()
		request_active = false
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
  }

function opt:RequestPIBuddy(name, mode)

	-- early out if already your buddy
	local current_buddy = opt:GetCurrentBuddy()
	if (current_buddy and strlower(current_buddy) == strlower(name)) then
		return
	end

	-- early out if a request is active
	if (request_active) then return end

	request_buddy = name
	request_mode = mode
	request_active = true

	StaticPopup_Show("PIBuddy_RequestBuddyConfirm", name, mode)
end
  


-----------------------------------
-- handler
-----------------------------------

local has_shown_version_warning = false

function opt:GetCurrentBuddy()
	if (opt.IsPriest) then
		return opt.DpsInfo.name
	else
		return opt.PriestInfo.name
	end
end

function opt:HandleMessage(message)

	if (message.id == nil) then 
		pbDiagf("Invalid Message")
		return 
	end

	-- check for old message version
	if (message.version and message.version > CURRENT_VERSION) then

		-- we only need to warn once
		if (has_shown_version_warning) then
			return 
		end

		pbPrintf("PIBuddy: Version out of date. Please update!")
		has_shown_version_warning = true
		return
	end

	-- handle buddy requests first
	if (message.id == REQUEST_BUDDY) then
		opt:RequestPIBuddy(message.name, message.mode)
	elseif (message.id == REQUEST_BUDDY_ACCEPT) then
		pbPrintf("%s accepted your PI Buddy request.", message.name)
	elseif (message.id == REQUEST_BUDDY_DECLINE) then
		opt:OnDeclineBuddyRequest(message.name)
	end

	-- check if the message came from someone who isn't our current buddy

	-- get current buddy for this mode
	local current_buddy = opt:GetCurrentBuddy()

	-- check if the message came from someone else
	if (message.name ~= current_buddy) then

		-- if we've already filtered messages from this person
		if (ignore_list[strlower(message.name)]) then
			pbDiagf("Ignoring message from: %s", strlower(message.name))
			return 
		end

		-- we got an info request - we are in a group and not in combat
		if (message.id == DPS_INFO_REQUEST or message.id == PRIEST_INFO_REQUEST) then
			if (not opt.InCombat) then
				if (opt:IsPartyMember(message.name)) then

					local mode
					if (opt.InRaid) then mode = "raid" else mode = "party" end

					-- don't allow any more automatic buddy requests from this player
					opt:RequestPIBuddy(message.name, mode)
					ignore_list[strlower(message.name)] = true
				end
				return
			end
		end

		-- do not handle this message
		return
	end
	
	-------------------------------
	-- Handle the remainng messages
	-------------------------------

	-- dps info syncing
	
	if (message.id == DPS_INFO_REQUEST) then
		if (not opt.IsPriest) then
			opt:OnDpsInfoRequest(message)
		end
	elseif (message.id == DPS_INFO_REPLY) then
		opt:OnDpsInfoReply(message)
	elseif (message.id == NOTIFY_DPS_INFO_CHANGED) then
		opt:OnDpsInfoReply(message)
		
	-- priest info syncing
	elseif (message.id == PRIEST_INFO_REQUEST) then
		if (opt.IsPriest) then
			opt:OnPriestInfoRequest(message)
		end
	elseif (message.id == PRIEST_INFO_REPLY) then
		opt:OnPriestInfoReply(message)
	elseif (message.id == NOTIFY_PRIEST_INFO_CHANGED) then
		opt:OnPriestInfoReply(message)
	
	-- priest cooldown syncing
	elseif (message.id == NOTIFY_PI_COOLDOWN_CHANGED) then
		opt:OnPICooldownReply(message)
	elseif (message.id == PI_COOLDOWN_REQUEST) then
		opt:OnPICooldownRequest()
	elseif (message.id == PI_COOLDOWN_REPLY) then
		opt:OnPICooldownReply(message)

	-- dps cooldown syncing
	elseif (message.id == NOTIFY_DPS_COOLDOWN_CHANGED) then
		opt:OnDpsCooldownChanged(message)
	elseif (message.id == DPS_COOLDOWN_REQUEST) then
		opt:OnDpsCooldownRequest()
	elseif (message.id == DPS_COOLDOWN_REPLY) then
		opt:OnDpsCooldownReply(message)

	-- dps active syncing
	elseif (message.id == NOTIFY_DPS_ACTIVE_CHANGED) then
		opt:OnDpsActiveReply(message)
	
	-- PI ME!
	
	elseif (message.id == REQUEST_PIME) then
		opt:OnPiMeRequest(message)

	-- budy changed
	elseif (message.id == BUDDY_CHANGED) then
		opt:OnBuddyChanged(message)

	end

end
