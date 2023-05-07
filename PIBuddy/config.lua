local folder,ns = ...

-- Setup the Interface Options

local frame_name = 'PIBuddyConfig'
local opt = CreateFrame('FRAME',frame_name,InterfaceOptionsFramePanelContainer)
opt.Initialized = false
opt.name = 'PI Buddy'
opt.ShouldResetFrames = false
opt.UpdateInterval = 1.0
opt.TimeSinceLastUpdate = 0

-- misc info
opt.InGroup = false
opt.InCombat = false

-- class info
opt.PlayerGUID = 0
opt.PlayerName = ""
opt.PlayerRealm = ""
opt.ClassName = "Priest"
opt.PlayerClass = 0
opt.PlayerSpec = 0
opt.IsPriest = false
opt.HasFocus = false
opt.HasPI = false
opt.HasTwins = false
opt.HasCooldown = false
opt.IsBuddyDead = false
opt.ExportMacros = false
opt.ExportMacrosRaid = false

-- cooldowns
opt.POWER_INFUSION = 10060 -- pi
opt.COOLDOWN_SPELL = 0 -- unknown
		
-- character environment data
opt.env = {}
opt.env.DB = {}

-- ui frames
opt.ui = {}

-- defaults

local function SetValue(key, value)
	opt.env[key] = value
end

local function SetDefaultValue(key, value)
	if (opt.env[key] == nil) then
		SetValue(key, value)
	end
end

function opt:ResetAll()
	opt.env = {}
	opt.env.DB = {}
	ReloadUI()
end

function opt:LoadMissingValues()

	-- options
	SetDefaultValue('DB', {})
	SetDefaultValue('ShowButton', 1)
	SetDefaultValue('ShowMinimapIcon', true)
	SetDefaultValue('ShowBackground', true)
	SetDefaultValue('ShowTitle', true)
	SetDefaultValue('ShowPriest', true)
	SetDefaultValue('ShowDps', true)
	SetDefaultValue('ShowPiMe', true)
	SetDefaultValue('ShowFocusMe', true)
	SetDefaultValue('ShowPiMeGlow', true)
	SetDefaultValue('ShowCooldownTimers', false)
	SetDefaultValue('ShowSpellTimers', true)
	SetDefaultValue('ShowSpellGlow', true)
	SetDefaultValue('WarnNoBuddy', true)
	SetDefaultValue('WarnNoFocus', false)
	SetDefaultValue('WarnNoPowerInfusion', false)
	SetDefaultValue('WarnNoTwins', false)
	SetDefaultValue('LockButton', false)
	SetDefaultValue('IconSize', 64)
	SetDefaultValue('FrameX', -1)
	SetDefaultValue('FrameY', -1)
	SetDefaultValue('AllowOneWay', true)
	SetDefaultValue('DpsCooldownAudio', "None")
	SetDefaultValue('PiMeAudio', "None")

	-- macros
	SetDefaultValue('Trinket1Party', true)
	SetDefaultValue('Trinket1Raid', true)
	SetDefaultValue('Trinket2Party', true)
	SetDefaultValue('Trinket2Raid', true)
	SetDefaultValue('GenerateMacroParty', false)
	SetDefaultValue('GenerateMacroRaid', false)
	SetDefaultValue('PIFocusParty', false)
	SetDefaultValue('PIFocusRaid', false)
	SetDefaultValue('PIFriendlyParty', true)
	SetDefaultValue('PIFriendlyRaid', true)
	SetDefaultValue('PITargetLastTargetParty', true)
	SetDefaultValue('PITargetLastTargetRaid', true)
	
	-- buddies
	SetDefaultValue('PriestBuddy', "")
	SetDefaultValue('DpsBuddy', "")
	SetDefaultValue('RaidPriestBuddy', "")
	SetDefaultValue('RaidDpsBuddy', "")
	
	-- remember cooldowns
	SetDefaultValue('Cooldowns', {})

	-- do not allow buddy to self
	local lower_name = strlower(opt.PlayerName)

	if (strlower(opt.env.PriestBuddy) == lower_name) then
		SetValue('PriestBuddy', "")
	end
	if (strlower(opt.env.RaidPriestBuddy) == lower_name) then
		SetValue('RaidPriestBuddy', "")
	end
	if (strlower(opt.env.DpsBuddy) == lower_name) then
		SetValue('DpsBuddy', "")
	end
	if (strlower(opt.env.RaidDpsBuddy) == lower_name) then
		SetValue('RaidDpsBuddy', "")
	end
end

-- Main Interface Callbacks

function opt:OnLogin()

	-- init
	opt:ResetBuddyInfo()

	-- check name, realm
	opt.PlayerName = UnitName("player")
	opt.PlayerRealm = opt:SpaceStripper(GetNormalizedRealmName())
	opt.PlayerGUID = UnitGUID("player")
	opt.PlayerNameRealm = string.format("%s-%s", opt.PlayerName, opt.PlayerRealm)
	opt.PlayerLevel = UnitLevel("player")

	-- check class info
	local localizedClass, englishClass, classIndex = UnitClass("player");
	opt.ClassName = localizedClass
	opt.PlayerClass = classIndex
	opt.PriestInfo.spell_id = opt.POWER_INFUSION
	opt.PriestInfo.aura_id = opt.POWER_INFUSION
	if (classIndex == 5) then
		opt.IsPriest = true
	end
	
	-- group info
	opt.InGroup = IsInGroup() or IsInRaid()
	opt.InRaid = IsInRaid()
	opt:OnPlayerFocusChanged()

	-- load settings
	if (PIBuddyPerCharacterConfig) then
		opt.env = PIBuddyPerCharacterConfig
	end
	opt:LoadMissingValues()
	
	-- talents
	opt:UpdateTalentSpec()
		
	-- inital buddies
	opt:CheckPriestBuddy()
	opt:CheckDpsBuddy()
	
	-- create panel
	InterfaceOptions_AddCategory(opt)
	opt:SetupLocale()
	opt:CreateWidgets()
	opt:CreateMainFrame()
	opt:ForceUiUpdate()
	
	-- request initial sync
	C_Timer.After(1, function() 

		-- level warning
		if (opt.PlayerLevel < 30) then
			pbPrintf("%s", opt.titles.PIBuddyLevelWarning)
		end

		-- macros
		opt:CheckMacros()

		-- sync
		opt:SyncInfo()
	end)
	
	-- minimap
	opt:CreateMinimapIcon()
	opt.Initialized = true
end

function opt:OnTalentsChanged()
	if (not opt.Initialized) then return end
	opt:UpdateTalentSpec()
	opt:SyncInfo()
end

function opt:UpdateTalentSpec()

	local currentSpec = GetSpecialization()
	local id, name, description, icon, role, primaryStat = GetSpecializationInfo(currentSpec)
	opt.PlayerSpec = id

	-- forward dps spec on to the buddy system
	if (opt.IsPriest) then
		opt:SetPriestSpec(opt.PlayerSpec)
		opt.HasPI = IsSpellKnown(10060)

		local nodeId = 82683 -- opt:GetTalentNodeForSpell(373466)
		if (nodeId > 0) then
			opt.HasTwins = opt:HasTalentNode(nodeId)
		end
	end

	if (not opt.IsPriest) then
		opt:SetDpsSpec(opt.PlayerSpec)
		opt:CheckDpsCooldownInfo()

		if (opt.Initialized) then
			opt:NotifyDpsInfoChanged()
		end
	end

	-- update main frame UI
	opt:ForceUiUpdate()
end

function opt:OnPlayerFocusChanged()
	local focus = GetUnitName("focus", true)
	if (focus) then
		opt.HasFocus = true
		opt.FocusName = focus
	else
		opt.HasFocus = false
		opt.FocusName = ""
	end

	-- update main frame UI
	opt:ForceUiUpdate()
end

function opt:CheckDpsCooldownInfo()

	-- load spells for this spec
	local spells = opt:GetSpecInfo(opt.PlayerClass, opt.PlayerSpec)
	if (spells == nil or next(spells) == nil or spells == {}) then
		return
	end
	-- load the cooldown setting
	local cd
	local spell_id = 0

	-- reset the 'has cooldown' setting
	opt.HasCooldown = false

	-- check if the the cooldown setting is present
	if (opt.env.Cooldowns == nil or opt.env.Cooldowns[opt.PlayerSpec] == nil) then
		cd = spells[1]
		spell_id = cd[1]
	else

		-- the setting we're looking for
		local saved_spell_id = opt.env.Cooldowns[opt.PlayerSpec]

		-- iterate through all cooldowns for this spec
		for index,cooldown in opt:pairsByKeys ( spells ) do

			-- check to see if we can find the spell in this index
			local found = false
			for cd_index, spell in opt:pairsByKeys ( cooldown ) do
				if (saved_spell_id == spell) then
					found = true
					break
				end
			end

			-- see which of the talents we actually took
			if (found) then
				for cd_index,spell in opt:pairsByKeys ( cooldown ) do
					spell_id = spell
					if (IsPlayerSpell(spell)) then
						opt.HasCooldown = true
						break
					end
				end

				break
			end
		end
	end

	opt:SetDpsInfo(opt.PlayerClass, opt.PlayerSpec, spell_id)
end

function opt:OnLogout()
	-- save settings
	PIBuddyPerCharacterConfig = opt.env
end

function opt:OnPlayerDied()
	opt:OnLosePowerInfusion()
	opt:OnLoseDpsCooldown()
end

function opt:IsOneWayEnabled()

	if (not opt.env.AllowOneWay) then
		return false
	end

	if (opt.IsPriest) then
		if (opt.DpsInfo.failed_sync) then
			return true
		end
	else
		if (opt.PriestInfo.failed_sync) then
			return true
		end
	end

	return false
end

function opt:CreateMinimapIcon()

	local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("PIBuddyAddon", 
	{
		type = "data source",	
		text = "PI Buddy",
		icon = "135939",
		OnClick = function(self, btn)
			opt:Config()
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine("PIBuddy")
		end,
		
		})
		
		opt.ui.MinimapIcon = LibStub("LibDBIcon-1.0", true)
		opt.ui.MinimapIcon:Register("PIBuddy", miniButton, opt.env.DB)
		opt:MinimapUpdate()
end

function PIBuddy_OnAddonCompartmentClick(addonName, buttonName)
	opt:Config()
end

function opt:MinimapUpdate()
	if (not opt.ui.MinimapIcon) then return end
	if (opt.env.ShowMinimapIcon) then
		opt.ui.MinimapIcon:Show("PIBuddy")
	else
		opt.ui.MinimapIcon:Hide("PIBuddy")
	end
end

-- UI callbacks

function opt:Lock()
	opt:LockMainFrame()
end

function opt:Unlock()
	opt:UnlockMainFrame()
end

function opt:Config()
	InterfaceOptionsFrame_OpenToCategory(opt)
end

-- tick functions

function opt:OnUpdate(elapsed)

	-- Power Infusion
	if (opt.IsPriest) then
		opt:UpdatePriestTimers()
	else
		opt:UpdateRemotePriestTimers()
	end

	-- Dps Cooldowns
	if (not opt.IsPriest) then
		opt:UpdateDpsTimers()
	else
		opt:UpdateRemoteDpsTimers()
	end

	if (opt.IsBuddyDead) then
		opt:UpdateDeadBuddy(elapsed)
	end

	opt:UpdateMacros()
	
end

