local opt = PIBuddyConfig

function opt:SetupLocale()

	local LOCALE = GetLocale()

	opt.titles = {
	
		-- addon
		PIBuddy = 'PIBuddy',
		PIBuddyConfig = 'PIBuddy Config',
		
		-- min level

		PIBuddyLevelWarning = "This addon is designed for high level players with access to their signature class abilities. You may wish to disable it while leveling.",

		-- controls
		
		Controls = 'Frame Options',
		
		-- show buton
		ShowText = 'Show PIBuddy Frame',
		ShowTextTooltip = "Choose when the PIBuddy Frame should be displayed", 
				
		-- lock button
		LockButton = 'Lock Frame',
		LockButtonHeader = 'Lock Frame',
		LockButtonTooltip = 'Locks the PIBuddy frame.',

		-- priest-only options
		PriestConfig = "Priest Config",

		-- macros

		MacroConfig = 'Power Infusion (Party) - Macro',
		MacroConfigRaid = 'Power Infusion (Raid) - Macro',

		GenerateMacroParty = 'Automatically generate macro',
		GenerateMacroPartyTooltip = 'Automatically creates and updates a macro called "PIBUDDY" when in a group.',

		GenerateMacroRaid = 'Automatically generate macro',
		GenerateMacroRaidTooltip = 'Automatically creates and updates a macro called "PIBUDDY" when in a raid.',

		Trinket1Party = 'Use Trinket (Slot 1)',
		Trinket1Raid = 'Use Trinket (Slot 1)',
		Trinket1Tooltip = 'Include first trinket in the macro.',

		Trinket2Party = 'Use Trinket (Slot 2)',
		Trinket2Raid = 'Use Trinket (Slot 2)',
		Trinket2Tooltip = 'Include second trinket in the macro.',

		PIFocusParty = 'Include Focus Target',
		PIFocusRaid = 'Include Focus Target',
		PIFocusTooltip = 'Attempt to cast on your focus target.',

		PIFriendlyParty = 'Include Friendly Target',
		PIFriendlyRaid = 'Include Friendly Target',
		PIFriendlyTooltip = 'Attempt to target a random friendly player, in case your buddy is dead.',

		PITargetLastTargetParty = 'Target Last Target',
		PITargetLastTargetRaid  = 'Target Last Target',
		PITargetLastTargetTooltip = 'Attempt to target your last target.',

		-- sound

		Sound = 'Play Sound on DPS Cooldown',
		SoundTooltip = 'Sound to play when your buddy activates their cooldown.',
		SoundPiMe = 'Play Sound on |cffFFF569PI ME|r Request',
		SoundPiMeTooltip = 'Sound to play when your buddy requests Power Infusion.',

		-- minimap
		ShowMinimapIcon = 'Show Minimap Icon',
		ShowMinimapHeader = 'Show Minimap Icon',
		ShowMinimapTooltip = 'Toggle the PIBuddy minimap icon.',
		
		-- other toggles
		
		ShowBackground = 'Show Background',
		ShowBackgroundHeader = 'Show Background',
		ShowBackgroundTooltip = 'Show the PIBuddy frame background.',
		
		ShowTitle = 'Show Title',
		ShowTitleHeader = 'Show Title',
		ShowTitleTooltip = 'Show the PIBuddy frame title.',
		
		ShowPriest = 'Show Priest Buddy',
		ShowPriestHeader = 'Show Priest Buddy',
		ShowPriestTooltip = "Show the priest's power infusion icon.",
		
		ShowDps = 'Show DPS Buddy',
		ShowDpsHeader = 'Show DPS Buddy',
		ShowDpsTooltip = "Show the DPS Buddy's major cooldown.",
		
		ShowPiMe = "Show |cffFFF569PI ME|r Button",
		ShowPiMeHeader = "Show |cffFFF569PI ME|r Button",
		ShowPiMeTooltip = 'Show a button to request PI immediately.\n\nYou can also trigger this from a macro by typing:\n\n/pibuddy request',

		ShowPiMeGlow = "Show |cffFFF569PI ME|r Frame Glow",
		ShowPiMeGlowHeader = "Show |cffFFF569PI ME|r Frame Glow",
		ShowPiMeGlowTooltip = "Glow your buddy's unit frames after receiving a PI request",
		
		ShowFocusMe = "Show Focus Button",
		ShowFocusMeHeader = "Show Focus Button",
		ShowFocusMeTooltip = "Show a 'Set Focus' Button when your buddy is not your current focus.",

		ShowCooldownTimers = "Show Cooldown Timers",
		ShowCooldownTimersHeader = "Show Cooldown Timers",
		ShowCooldownTimersTooltip = "Display a timer when spells are on cooldown",

		ShowSpellTimers = "Show Spell Timers",
		ShowSpellTimersHeader = "Show Spell Timers",
		ShowSpellTimersTooltip = "Display a timer when spells are active",

		ShowSpellGlow = "Show Spell Glow",
		ShowSpellGlowHeader = "Show Spell Glow",
		ShowSpellGlowTooltip = "Show a glow around spells when they are active.\n\nNOTE: Disabling glow effects may improve performance.",
		
		-- GlowPiMe = 'Glow Raid Frame',
		-- GlowPiMeHeader = Glow Raid Frame',
		-- GlowPiMeTooltip = "Glow your buddy's unit frame when PI has been requested.",
		
		WarnNoBuddy = 'Warn on Buddy Unavailable',
		WarnNoBuddyHeader = 'Warn on Buddy Unavailable',
		WarnNoBuddyTooltip = 'Warn when a Buddy is not set, not in group, disconnected, dead, etc.',

		WarnNoFocus = 'Warn on No Focus',
		WarnNoFocusHeader = 'Warn on No Focus',
		WarnNoFocusTooltip = 'Display a warning when your focus is unset.',
		
		WarnNoPowerInfusion = 'Warn on Missing PI',
		WarnNoPowerInfusionHeader = 'Warn on Missing PI',
		WarnNoPowerInfusionTooltip = 'Display a warning when Power Infusion talent is not taken.',
		
		WarnNoTwins = 'Warn on Missing Twins',
		WarnNoTwinsHeader = 'Warn on Missing Twins',
		WarnNoTwinsTooltip = 'Display a warning when Twins of the Sun Priestess talent is not taken.',
		
		-- warnings on the frame

		WarningTextNoBuddy = 'Party PIBuddy Not Set!',
		WarningTextNoBuddyRaid = 'Raid PIBuddy Not Set!',
		WarningTextNoBuddyAtTheMomentParty = 'Party PIBuddy (%s) is missing!',
		WarningTextNoBuddyAtTheMomentRaid = 'Raid PIBuddy (%s) is missing!',
		WarningTextNoBuddySync = 'Waiting for PIBuddy Info from %s!',
		WarningTextDpsBuddyIsAPriest = "DPS Buddy is Invalid Class (Priest)",
		WarningTextPriestBuddyIsntPriest = "Priest Buddy Is Invalid Class (%s)",
		WarningTextBuddyDead = "Buddy (%s) is dead!",

		WarningTextNoFocus = 'No Focus Target',
		WarningTextNoPI = 'Power Infusion - MISSING',
		WarningTextNoTwins = 'Twins of the Sun Priestess - MISSING',

		-- one-way relationship

		AllowOneWay = 'Enable one-way mode',
		AllowOneWayHeader = 'Allow one-way mode',
		AllowOneWayTooltip = "Enables the use of cooldown tracking via combat events instead of synchronizing cooldowns. Only one player needs to have PIBuddy installed.\n\nNOTE: This uses default values for cooldowns which won't be affected by talents or cooldown-reducing abilities.",

		-- spec specific
		
		TooltipUnavailable = 'Unavailable',
		PriestOnlyTooltip = 'Only available to Priests.',
		DpsOnlyTooltip = 'Not available to Priests.',

		-- create pime macro


		
		-- frame size
		
		IconSize = 'Icon Size',
		IconSizeTooltip = 'Size of the PI Buddy cooldown icons.',
		
		-- pime
		
		ShowPIMeButton = 'Show "PI ME" Button',
		RequestPI = 'PI Me!',

		-- focus me
		
		ShowFocusMeButton = 'Show "Set Focus" Button',
		SetFocusText = 'Set Focus',

		-- config
		
		PartyConfig = 'PI Buddy (Party and Arena)',
		RaidConfig = 'PI Buddy (Raid)',
		
		-- target
		
		PartyBuddyPriest = 'Configure a Priest Buddy for parties.',
		PartyBuddyDps = 'Configure a DPS Buddy for parties.',
		RaidBuddyPriest = 'Configure a Priest Buddy for raid groups.',
		RaidBuddyDps = 'Configure a DPS buddy for raid groups.',

		-- buddy selection

		PriestBuddy = 'Buddy:',
		DPSBuddy = 'Buddy:',
		PriestTooltip = 'Select a Priest Buddy',
		DPSTooltip = 'Select a DPS Buddy',
		NoBuddy = 'No Buddy',

		-- apply target
		ApplyBtn = 'Apply',
		ApplyBtnHeader = 'Apply Buddy',
		ApplyBtnTooltip = 'Click to confirm your current buddy.',

		-- copy target
		SetAsTargetBtn = 'Copy Target',
		CopyTargetTooltip = 'Set your current target as your buddy.\n\nYou can also right click on the icons on the PIBuddy frame to set your current target as your buddy.',

		-- buddy request
		RequestBuddy = 'Request Buddy',
		RequestBuddyHeader = 'Request Buddy',
		RequestBuddyTooltip = 'Send this player a buddy request. If they have PIBuddy installed, they will be asked to set you as their buddy.',
		
		-- buddy status

		StatusTitle = "Status:",

		-- buddy default
		StatusDefault = "Synced",
		StatusDefaultTooltip = "You are synced with your buddy.",

		-- buddy - not set
		StatusNotSet = "Not Set",
		StatusNotSetTooltip = "A Buddy has not been set.",

		-- buddy - wrong group type (party)
		StatusNoParty = "Not in Party",
		StatusNoPartyTooltip = "You are not currently in a party.",

		-- buddy - wrong group type (raid)
		StatusNoRaid = "Not in Raid",
		StatusNoRaidTooltip = "You are not currently in a raid group.",

		-- buddy - dps buddy was a priest

		StatusPriestDps = "Invalid Target",
		StatusPriestDpsTooltip = "You cannot set a Priest as DPS Buddy.",

		StatusNotAPriest = "Not a Priest",
		StatusNotAPriestTooltip = "You must set a Priest as your Priest Buddy.",

		-- buddy - not in group
		StatusNotInGroup = "Unavailable",
		StatusNotInGroupTooltip = "Your buddy is not currently in your party or raid.",

		-- buddy - offline?
		StatusNotOnline = "Offline",
		StatusNotOnlineTooltip = "Your buddy is currently offline.",

		-- buddy - syncing
		StatusSyncing = "Syncing",
		StatusSyncingTooltip = "Waiting for response from your buddy",

		-- buddy - sync failed
		StatusSyncFailed = "Not Synced",
		StatusSyncFailedTooltip = "Unable to sync with your buddy. They might not be running PIBuddy or have selected a different buddy.",

		-- buddy - sync declined
		StatusSyncDeclined = "Declined",
		StatusSyncDeclinedTooltip = "A buddy request was declined, cancelled or timed out.",

		-- buddy - synced

		StatusReady = "Ready",
		StatusReadyTooltip = "Your buddy is ready to go.",

		-- cooldowns
		
		CooldownConfig = 'Configure Cooldowns',
		CooldownConfigInfo = "Select a cooldown to sync for each talent specialization.",
		CooldownConfigInfoPriests = "Your buddy can select which cooldown to sync for each talent specialization.\n\nHowever, as a Priest your only purpose is to cast Power Infusion.",
	}	
	
end