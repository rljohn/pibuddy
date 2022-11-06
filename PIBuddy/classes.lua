local opt = PIBuddyConfig

-- Auras for DOT Tracking
PIBuddyClassList = {

	-- Warrior
	[1] = {
		[71] = { -- Arms
			[1] = { 107574 }, -- Avatar
			[2] = { 376079 }, -- Spear of Bastion
			[3] = { 167105 }, -- Colossus Smash
		},
		[72] = { -- Fury
			[1] = { 1719 }, -- Recklessness
			[2] = { 107574 }, -- Avatar
			[3] = { 376079 }, -- Spear of Bastion
		},
		[73] = { -- Protection
			[1] = { 107574 }, -- Avatar
			[2] = { 376079 }, -- Spear of Bastion
		},
	},
	
	-- Paladin
	[2] = {
		[65] = { -- Holy
		},
		[66] = { -- Protection
			[1] = { 31884 }, -- Avenging Wrath
			[2] = { 327193 }, -- Moment of Glory
		},
		[70] = { -- Retribution
			[1] = { 31884 }, -- Avenging Wrath
		},
	},
	
	-- Hunter
	[3] = {
		[253] = { -- Beast Mastery
			[1] = { 19574 }, -- Bestial Wrath
			[2] = { 359844 }, -- Call of the Wild
			[3] = { 193530 }, -- Aspect of the Wild
			[4] = { 201430 }, -- Stampede
			[5] = { 321530 }, -- Bloodshed
			[6] = { 328231 }, -- Wild Spirits
		},
		[254] = { -- Marksmanship
			[1] = { 288613 }, -- Trueshot
			[2] = { 201430 }, -- Stampede
			[3] = { 328231 }, -- Wild Spirits
		},
		[255] = { -- Survival
			[1] = { 360966 }, -- Spearhead
			[2] = { 203415 }, -- Fury of the Eagle (debuff)
			[3] = { 201430 }, -- Stampede
			[4] = { 328231 }, -- Wild Spirits
		},
	},
	
		
	-- Rogue
	[4] = {
		[259] = { -- Assassination
			[1] = { 360194 }, -- Deathmark (debuff)
			[2] = { 385627 }, -- Kingsbane (debuff)
		},
		[260] = { -- Outlaw
			[1] = { 13750 }, -- Adrenaline Rush
			[2] = { 343142 }, -- Dreadblades
			[3] = { 13877 }, -- Blade Flurry
		},
		[261] = { -- Subtlety
			[1] = { 121471 }, -- Shadow Blades
			[2] = { 384631 }, -- Flagellation
		},
	},
	
	-- Priest
	[5] = {
		[256] = { -- Discipline
			[1] = { 10060 }, -- Power Infusion		
		},
		[257] = { -- Holy
			[1] = { 10060 }, -- Power Infusion
		},
		-- Shadow
		[258] =  { 
			[1] = { 10060 }, -- Power Infusion
		},
	},
	
	-- Death Knight
	[6] = {
		[250] = { -- Blood
			[1] = { 49028 }, -- Dancing Rune Weapon
			[2] = { 194844 }, -- Bonestorm
			[3] = { 315443 }, -- Abomination Limb
			[4] = { 47568 },  -- Empower Rune Weapon
		},
		[251] = { -- Frost
			[1] = { 152279 }, -- Breath of Sindragosa
			[2] = { 279302 }, -- Frostwyrm's Fury
			[3] = { 315443 }, -- Abomination Limb
			[4] = { 47568 },  -- Empower Rune Weapon
		},
		[252] = { -- Unholy
			[1] = { 49206 }, -- Summon Gargoyle
			[2] = { 42650 }, -- Army of the Dead
			[3] = { 315443 }, -- Abomination Limb
			[4] = { 47568 },  -- Empower Rune Weapon
			[5] = { 207289 }, -- Unholy Assault
		},
	},
	
	-- Shaman
	[7] = {
		[262] = { -- Elemental
			[1] = { 198067 }, -- Fire Elemental (pet)
		},
		[263] = { -- Enhancement
			[1] = { 51533 }, -- Feral Spirit
			[2] = { 114051 }, -- Ascendance
		},
		[264] = { -- Restoration
		},
	},
	
	-- Mage
	[8] = {
		[62] = { -- Arcane
			[1] = { 365350 } -- Arcane Surge
		},
		[63] = { -- Fire
			[1] = { 190319 } -- Combustion
		},
		[64] = { -- Frost
			[1] = { 12472 } -- Icy Veins
		},
	},
	
	-- Warlock
	[9] = {
		[265] = { -- Affliction
			[1] = { 205180 }, -- Summon Darkglare (pet)
		},
		[266] = { -- Demonology
			[1] = { 265187 }, -- Summon Demonic Tyrant (pet)
		},
		[267] = { -- Destruction
			[1] = { 1122 }, -- Summon Infernal (pet)
		},
	},
	
	-- Monk
	[10] = {
		[268] = { -- Brewmaster
			[1] = { 387184 }, -- Weapons of Order
		},
		[269] = { -- Windwalker
			[1] = { 137639 , 152173 }, -- Storm, Earth, Fire / Serenity
			[2] = { 123904 }, -- Invoke Xuen, the White Tiger (pet)
		},
		[270] = { -- Mistweaver
		},
	},
	
	-- Druid
	[11] = {
		[102] = { -- Balance
			[1] = { 102560, 391528 }, -- Incarnation: Chosen of Elune, Convoke the Spirits 
			[2] = { 194223 }, -- Celestial Alignment
			[3] = { 323546 }, -- Ravenous Frenzy
		},
		[103] = { -- Feral
			[1] = { 102543, 391528 }, -- Incarnation: Avatar of Ashamane, Convoke the Spirits
			[2] = { 106951 }, -- Berserk
		},
		[104] = { -- Guardian
			[1] = { 102558, 391528 },-- Incarnation: Guardian of Ursoc, Convoke the Spirits
			[2] = { 50334 }, -- Berserk
		},
		[105] = { -- Restoration
		},
	},
	
	-- Demon Hunter
	[12] = {
		[577] = { -- Havoc
			[1] = { 191427 }, -- Metamorphosis (dps)
		},
		[581] = { -- Vengeance
			[1] = { 187827 }, -- Metamorphosis (tank)
		},
	},

	-- Evoker
	[13] = {
		[1467] = { -- Devasatation
			[1] = { 375087 }, -- Dragonrage
		},
		[1468] = { -- Preservation
		},
	}
}

-- Cooldowns that don't use its own spell ID for the aura it provides.
DPSBuddySpellAuras = {
	[365350] 	= 365362, 	-- Arcane Surge [Arcane Mage]
	[49028] 	= 81256, 	-- Dancing Rune Weapon [Death Knight]
	[315443]	= 383269,	-- Abomination Limb [Death Knight]
	[51533]		= 333957,	-- Feral Spirit [Shaman]
	[191427]	= 162264, 	-- Metamorphosis [Demon Hunter]
}

-- Cooldowns that don't provide an aura at all, guess-timate the timer.
DPSBuddySpellActiveTime = {
	[198067]	= 30, -- Elemental Shaman, Fire Elemental
	[123904]	= 24, -- Windwalker Monk, Invoke Xuen
	[1122]		= 30, -- Destruction Warlock, Summon Infernal
	[265187]	= 15, -- Demonology Warlock, Summon Demonic Tryant
	[205180]	= 30, -- Affliction Warlock, Summon Darkglare
	[376079]	= 8,  -- Warrior, Spear of Bastion
	[167105]	= 13, -- Warrior, Colossus Smash
	[360194]	= 20, -- Rogue, Deathmark
	[385627]	= 14, -- Rogue, Kingsbane

	-- Warlock Summons
	-- Hunter Spear Attack
	-- Rogue Bleeds
}

-- When running in one-sided mode, the best we can do is guess.
-- [1] = cooldown
-- [2] = duration
DPSBuddyEstimates = {

	-- Warrior
	[107574] 	= { 90, 20 }, -- Avatar
	[376079] 	= { 90, 8 }, -- Spear of Bastion (players likely to take this will take +3 seconds talent)
	[167105] 	= { 45, 10 }, -- Colossus Smash
	[1719] 		= { 90, 12 }, -- Recklessness

	-- Paladin
	[31884] 	= { 120, 20 }, -- Avenging Wrath
	[327193] 	= { 327193, 15 }, -- Moment of Glory

	-- Hunter
	[19574] 	= { 90, 15 }, -- Bestial Wrath
	[193530] 	= { 120, 20 }, -- Aspect of the Wild
	[359844]	= { 180, 20 }, -- Call of the Wild
	[201430] 	= { 120, 12 }, -- Stampede
	[321530] 	= { 60, 18 }, -- Bloodshed
	[288613] 	= { 120, 15 }, -- Trueshot
	[360966] 	= { 90, 12 }, -- Spearhead
	[203415] 	= { 45, 4 }, -- Fury of the Eagle
	[328231]	= { 120, 18 }, -- Wild Spirits

	-- Rogue
	[360194] 	= { 120, 20 }, -- Deathmark
	[385627] 	= { 60, 14 }, -- Kingsbane
	[13750] 	= { 180, 20 }, -- Adrenaline Rush
	[343142] 	= { 120, 10 }, -- Dreadblades
	[13877] 	= { 30, 10 }, -- Blade Flurry
	[121471] 	= { 180, 20 }, -- Shadow Blades
	[384631] 	= { 90, 24 }, -- Flagellation (lasts 12 seconds after effect ends)

	-- Priest
	[228260] 	= { 120, 40 }, -- Void Eruption (20s extended by insanity usage, rough guess at 40s)
	[391109] 	= { 120, 20 }, -- Dark Ascension
	[200174] 	= { 60, 15 }, -- Mindbender

	-- Death Knight
	[49028] 	= { 120, 8 }, -- Dancing Rune Weapon
	[194844] 	= { 60, 10 }, -- Bonestorm (1s per 10 runic power, estimate at 10s)
	[315443] 	= { 120, 12 }, -- Abomination Limb
	[47568] 	= { 120, 20 }, -- Empower Rune Weapon (TODO: 2 charges?)
	[152279] 	= { 120, 45 }, -- Breath of Sindragosa (lasts until out of Runic Power, rough guess at 45s)
	[279302] 	= { 90, 3 }, -- Frostyrm's Fury (base CD 3m, but likely to take the half-CD talent - not a real aura, so just display it for 3s to match stun duration)
	[49206] 	= { 180, 25 }, -- Summon Gargoyle
	[42650] 	= { 300, 30 }, -- Army of the Dead (death coils reduce cooldown. assume the DK will reduce the CD down from 8m to 5m?? innaccurate)
	[207289]	= { 90, 20 }, -- Unholy Assault

	-- Shaman
	[198067] 	= { 150, 30 }, -- Fire Elemental
	[51533] 	= { 90, 15 }, -- Feral Sprit (talents/abiliies reduce this CD. our guess here is likely innaccurate) 
	[114051] 	= { 180, 15 }, -- Ascendance

	-- Mage
	[365350] 	= { 90, 12 }, -- Arcane Surge
	[190319] 	= { 120, 12 }, -- Combustion
	[12472] 	= { 180, 25 }, -- Icy Veins

	-- Warlock
	[205180] 	= { 120, 20 }, -- Summon Darkglare
	[265187] 	= { 90, 15 }, -- Summon Demonic Tyrant
	[1122] 		= { 180, 30 }, -- Summon Infernal

	-- Monk
	[387184] 	= { 120, 30 }, -- Weapons of Order
	[137639] 	= { 90, 15 }, -- Storm, Earth, Fire (TODO: 2 charges?)
	[152173] 	= { 90, 12 }, -- Serenity
	[123904] 	= { 120, 24 }, -- Invoke Xuen, the White Tiger

	-- Druid
	[102560] 	= { 180, 30 }, -- Incarnation: Chosen of Elune
	[391528] 	= { 120, 4 }, -- Convoke the Spirits
	[194223] 	= { 180, 20 }, -- Celestial Alignment
	[323546]	= { 180, 20 }, -- Ravenous Frenzy
	[102543] 	= { 180, 30 }, -- Incarnation: Avatar of Ashamane
	[106951] 	= { 180, 20 }, -- Berserk (Feral)
	[102558] 	= { 180, 30 }, -- Incarnation: Guardian of Ursoc
	[50334] 	= { 180, 15 }, -- Berserk (Guardian)

	-- Demon Hunter
	[191427] 	= { 240, 24 }, -- Metamorphosis (Havoc)
	[187827] 	= { 240, 15 }, -- Metamorphosis (Vengeance)

	-- Evoker
	[375087] 	= { 120, 14 }, -- Dragonrage
}

function opt:GetClassInfo(class_id)
	if (PIBuddyClassList[class_id] == nil) then return nil end	
	return PIBuddyClassList[class_id]
end

function opt:GetSpecInfo(class_id, spec_id)
	if (PIBuddyClassList[class_id] == nil) then return nil end
	if (PIBuddyClassList[class_id][spec_id] == nil) then return nil end
	return PIBuddyClassList[class_id][spec_id]
end