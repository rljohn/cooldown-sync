local opt = CooldownSyncConfig

-- Auras for DOT Tracking
CooldownSyncClassList = {

	--[[
		id = spell_id
		cd = default cooldown
		dur = override duration
		min = minimum duration
		icon = icon override
		exclusive = talent is a choice node, so hide the partner if cast
		hidden = hide until this ability is cast by player
		multi = tracked by multiple specs do don't identify with it
	]]--

	-- Warrior
	[1] = {
		 -- Arms
		[71] = {
		 	-- Avatar
			{ id = 107574, cd = 90, min = 18, hidden = true  },
			 -- Spear of Bastion
			{ id = 376079, cd = 90, dur = 8, hidden = true  },
			 -- Colossus Smash
			{ id = 167105, cd = 45, dur = 13 },
			 -- Demolish
			{ id = 436358, cd = 45, dur = 2, hidden = true },
		},
		 -- Fury
		[72] = {
			-- Recklessness
			{ id = 1719, cd = 90, min = 10 },
			-- Avatar
			{ id = 107574, cd = 90, min = 18, hidden = true  },
			-- Spear of Bastion
			{ id = 376079, cd = 90, hidden = true },
		},
		-- Protection
		[73] = {
			-- Avatar
			{ id = 401150, cd = 90, min = 18, hidden = true },
			-- Spear of Bastion
			{ id = 376079, cd = 90, dur = 8, hidden = true },
			-- Shield Wall
			{ id = 871, cd = 180, dur = 8, hidden = true },
			-- Last Stand
			{ id = 12975, cd = 180, dur = 15 },
			-- Rallying Cry
			{ id = 97462, cd = 180, dur = 10 },
			 -- Demolish
			{ id = 436358, cd = 45, dur = 2, hidden = true },
		},
	},
	
	-- Paladin
	[2] = {
		-- Holy
		[65] = {
			-- Blessing of Summer
			{ id = 388007, cd = 45 },
		},
		-- Protection
		[66] = {
			-- Avenging Wrath
			{ id = 31884, cd = 60, min = 15},
			-- Moment of Glory
			{ id = 327193, cd = 15 },
		},
		-- Retribution
		[70] = { 
			-- Avenging Wrath
			{ id = 31884, cd = 60, min = 15 },
			-- Crusade
			{ id = 231895, cd = 120, min = 20 },
		},
	},
	
	-- Hunter
	[3] = {
		-- Beast Mastery
		[253] = {
			-- Bloodshed
			{ id = 321530, cd = 60 },
		},
		-- Marksmanship
		[254] = {
			-- Trueshot
			{ id = 288613, cd = 120 },
		},
		-- Survival
		[255] = {
			-- Spearhead
			{ id = 360966, cd = 90 },
			-- Fury of the Eagle (debuff)
			{ id = 203415, cd = 45, dur = 4 },
			-- Coordinated Assault
			{ id = 360952, cd = 120, dur = 20 },
		},
	},
	
		
	-- Rogue
	[4] = {
		-- Assassination
		[259] = {
			-- Deathmark (debuff)
			{ id = 360194, cd = 120, dur = 20 },
			-- Kingsbane (debuff)
			{ id = 385627, cd = 60, dur = 14 },
		},
		-- Outlaw
		[260] = {
			-- Adrenaline Rush
			{ id = 13750, cd = 180, dur = 20 },
			-- Dreadblades
			{ id = 343142, cd = 120, dur = 10 },
			-- Blade Flurry
			{ id = 13877, cd = 30, dur = 10 },
		},
		-- Subtlety
		[261] = {
			-- Shadow Blades
			{ id = 121471, cd = 180, dur = 20 },
			-- Flagellation
			{ id = 384631, cd = 90, dur = 24 },
		},
	},
	
	-- Priest
	[5] = {
		-- Discipline
		[256] = {
			-- Power Infusion	
			{ id = 10060, cd = 120 },
		},
		-- Holy
		[257] = {
			-- Power Infusion	
			{ id = 10060, cd = 120 },
		},
		-- Shadow
		[258] =  {
			-- Power Infusion	
			{ id = 10060, cd = 120, },
			-- Void Eruption
			{ id = 228260, cd = 120, exclusive = 391109, aura = 194249 },
			-- Dark Ascension
			{ id = 391109, cd = 60, exclusive = 228260, hidden = true },
		},
	},
	
	-- Death Knight
	[6] = {
		-- Blood
		[250] = {
			-- Dancing Rune Weapon
			{ id = 49028, cd = 120, aura = 81256 },
			-- Bonestorm
			{ id = 194844, cd = 60, hidden = true  },
			-- Abomination Limb
			{ id = 315443, cd = 120, aura = 383269, hidden = true, multi = true },
		},
		-- Frost
		[251] = {
			-- Breath of Sindragosa
			{ id = 152279, cd = 120, hidden = true },
			-- Frostwyrm's Fury
			{ id = 279302, cd = 90, dur = 3, hidden = true },
			-- Abomination Limb
			{ id = 315443, cd = 120, aura = 383269, hidden = true, multi = true },
		},
		-- Unholy
		[252] = {
			-- Army of the Dead
			{ id = 42650, cd = 180, dur = 30 },
			-- Unholy Assault
			{ id = 207289, cd = 90 },
			-- Summon Gargoyle
			{ id = 49206, cd = 180, dur = 25, hidden = true },
			-- Abomination Limb
			{ id = 315443, cd = 120, aura = 383269, hidden = true },
		},
	},
	
	-- Shaman
	[7] = {
		-- Elemental
		[262] = {
			-- Fire Elemental (pet)
			{ id = 198067, cd = 150, dur = 30, exclusive = 192249, hidden = true },
			-- Ascendance
			{ id = 114051, cd = 180 },
			-- Storm Elemental (pet)
			{ id = 192249, cd = 150, dur = 30, exclusive = 198067, hidden = true },
		},
		-- Enhancement
		[263] = {
			-- Feral Spirit
			{ id = 51533, cd = 45, aura = 333957},
			-- Ascendance
			{ id = 114051, cd = 180 },
		},
		-- Restoration
		[264] = {
			-- Ascendance
			{ id = 114052, cd = 180 },
			-- Spirit Link Totem
			{ id = 98008, cd = 180 },
		},
	},
	
	-- Mage
	[8] = {
		-- Arcane
		[62] = {
			-- Arcane Surge
			{ id = 365350, cd = 90, aura = 365362 },
			-- Evocation
			{ id = 12051, cd = 90 },
		},
		-- Fire
		[63] = {
			-- Combustion
			{ id = 190319, cd = 120, min = 10 },
		},
		-- Frost
		[64] = {
			-- Icy Veins
			{ id = 12472, cd = 180 }
		},
	},
	
	-- Warlock
	[9] = {
		-- Affliction
		[265] = {
			-- Summon Darkglare (pet)
			{ id = 205180, cd = 120, dur = 30},
			-- Malevolence
			{ id = 442726, cd = 60, dur = 20},
		},
		-- Demonology
		[266] = {
			-- Summon Demonic Tyrant (pet)
			{ id = 265187, cd = 120, dur = 15},
			-- Grimoire: Felguard
			{ id = 111898, cd = 120, dur = 17},

		},
		-- Destruction
		[267] = {
			-- Summon Infernal (pet)
			{ id = 1122, cd = 180, dur = 30},
			-- Malevolence
			{ id = 442726, cd = 60, dur = 20},
		},
	},
	
	-- Monk
	[10] = {
		-- Brewmaster
		[268] = {
			-- Weapons of Order
			{ id = 387184, cd = 120 },
		},
		-- Windwalker
		[269] = {
			-- Weapons of Order
			{ id = 387184, cd = 120 },
			-- Storm, Earth, Fire
			{ id = 137639, cd = 90, exclusive = 152173},
			-- Serenity
			{ id = 152173, cd = 90, exclusive = 137639, hidden = true },
			-- Invoke Xuen, the White Tiger (pet) 24
			{ id = 123904, cd = 120, dur = 24 },
		},
		-- Mistweaver
		[270] = {
		},
	},
	
	-- Druid
	[11] = {
		-- Balance
		[102] = {
			-- Incarnation: Chosen of Elune
			{ id = 102560, cd = 180, exclusive = 391528},
			-- Convoke the Spirits 
			{ id = 391528, cd = 120, dur = 4, exclusive = 102560, hidden = true, multi = true },
			-- Celestial Alignment
			{ id = 194223, cd = 180, min = 16 },
		},
		-- Feral
		[103] = {
			-- Incarnation: Avatar of Ashamane
			{ id = 102543, cd = 180, exclusive = 391528},
			-- Convoke the Spirits 
			{ id = 391528, cd = 120, dur = 4, exclusive = 102543, hidden = true, multi = true },
			-- -- Berserk
			{ id = 106951, cd = 180 },
		},
		-- Guardian
		[104] = {
			-- Incarnation: Avatar of Ashamane
			{ id = 102558, cd = 180, exclusive = 391528},
			-- Convoke the Spirits 
			{ id = 391528, cd = 120, dur = 4, exclusive = 102558, hidden = true, multi = true },
			-- Berserk
			{ id = 50334, cd = 180 },
		},
		-- Restoration
		[105] = {
		},
	},
	
	-- Demon Hunter
	[12] = {
		-- Havoc
		[577] = {
			-- Metamorphosis (dps)
			{ id = 191427, cd = 240, min = 20, aura = 162264 },
		},
		-- Vengeance
		[581] = {
			-- Metamorphosis (tank)
			{ id = 187827, cd = 240, min = 12 },
		},
	},

	-- Evoker
	[13] = {
		-- Devasatation
		[1467] = {
			-- Dragonrage
			{ id = 375087, cd = 120 },
		},
		-- Preservation
		[1468] = {
		},
		-- Augmentation
		[1473] = {
			-- Ebon Might
			{ id = 395152, cd = 30, aura = 395296 },
			-- Spatial Paradox
			{ id = 406732, cd = 120 },
		},
	}
}

local racialAbilities = {
	["Orc"] = {
		-- Blood Fury
		{ id = 20572, cd = 120 },
	},
	["Troll"] = { 
		-- Berserking
		{ id = 26297, cd = 180 },
	}
}

local classSpecs = {
	[71] = {id = 1, class = "Warrior", spec = "Arms"},
	[72] = {id = 1, class = "Warrior", spec = "Fury"},
	[73] = {id = 1, class = "Warrior", spec = "Protection"},
	[65] = {id = 2, class = "Paladin", spec = "Holy"},
	[66] = {id = 2, class = "Paladin", spec = "Protection"},
	[70] = {id = 2, class = "Paladin", spec = "Retribution"},
	[253] = {id = 3, class = "Hunter", spec = "Beast Mastery"},
	[254] = {id = 3, class = "Hunter", spec = "Marksmanship"},
	[255] = {id = 3, class = "Hunter", spec = "Survival"},
	[259] = {id = 4, class = "Rogue", spec = "Assassination"},
	[260] = {id = 4, class = "Rogue", spec = "Outlaw"},
	[261] = {id = 4, class = "Rogue", spec = "Subtlety"},
	[256] = {id = 5, class = "Priest", spec = "Discipline"},
	[257] = {id = 5, class = "Priest", spec = "Holy"},
	[258] = {id = 5, class = "Priest", spec = "Shadow"},
	[250] = {id = 6, class = "Death Knight", spec = "Blood"},
	[251] = {id = 6, class = "Death Knight", spec = "Frost"},
	[252] = {id = 6, class = "Death Knight", spec = "Unholy"},
	[262] = {id = 7, class = "Shaman", spec = "Elemental"},
	[263] = {id = 7, class = "Shaman", spec = "Enhancement"},
	[264] = {id = 7, class = "Shaman", spec = "Restoration"},
	[62] = {id = 8, class = "Mage", spec = "Arcane"},
	[63] = {id = 8, class = "Mage", spec = "Fire"},
	[64] = {id = 8, class = "Mage", spec = "Frost"},
	[265] = {id = 9, class = "Warlock", spec = "Affliction"},
	[266] = {id = 9, class = "Warlock", spec = "Demonology"},
	[267] = {id = 9, class = "Warlock", spec = "Destruction"},
	[268] = {id = 10, class = "Monk", spec = "Brewmaster"},
	[270] = {id = 10, class = "Monk", spec = "Mistweaver"},
	[269] = {id = 10, class = "Monk", spec = "Windwalker"},
	[102] = {id = 11, class = "Druid", spec = "Balance"},
	[103] = {id = 11, class = "Druid", spec = "Feral"},
	[104] = {id = 11, class = "Druid", spec = "Guardian"},
	[105] = {id = 11, class = "Druid", spec = "Restoration"},
	[577] = {id = 12, class = "Demon Hunter", spec = "Havoc"},
	[581] = {id = 12, class = "Demon Hunter", spec = "Vengeance"},
	[1467] = {id = 13, class = "Evoker", spec = "Devastation"},
	[1468] = {id = 13, class = "Evoker", spec = "Preservation"},
	[1473] = {id = 13, class = "Evoker", spec = "Augmentation"}
}


function opt:GetClassInfo(class_id)
	if (CooldownSyncClassList[class_id] == nil) then return nil end
	return CooldownSyncClassList[class_id]
end

function opt:GetSpecInfo(class_id, spec_id)
	if (CooldownSyncClassList[class_id] == nil) then return nil end
	if (CooldownSyncClassList[class_id][spec_id] == nil) then return nil end
	return CooldownSyncClassList[class_id][spec_id]
end

function opt:GetClassInfoBySpec(spec_id)
	return classSpecs[spec_id]
end

function opt:GetRacialAbility(race)
	return racialAbilities[race]
end

function opt:FindSpec(class_id, spell_id)
	local class_abilities = CooldownSyncClassList[class_id]
	if not class_abilities then return end

	for spec_id, spec_abilities in pairs(class_abilities) do
		for _, spell_info in pairs(spec_abilities) do
			if spell_info.id == spell_id then
				return spec_id
			end
		end
	end

	return nil
end

function opt:FindAbility(class_id, spell_id)
	local class_abilities = CooldownSyncClassList[class_id]
	if not class_abilities then return end

	for _, spec_abilities in pairs(class_abilities) do
		for _, spell_info in pairs(spec_abilities) do
			if spell_info.id == spell_id then
				return spell_info
			end
		end
	end

	return nil
end