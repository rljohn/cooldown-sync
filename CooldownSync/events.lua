local opt = CooldownSyncConfig

-- Setup Slash Commands

function opt:PrintHelp()
	print('|cffFFF569Cooldown Sync|r Commands:')
	print(' /cds add <name> - Adds <name> as a buddy in your current party type.')
	print(' /cds remove <name> - Removes <name> as a buddy in your current party type.')
	print(' /cds reset - Completely resets the addon to its default settings.')
end

local buddy = nil
local inspect = nil
SLASH_CooldownSync1 = '/cds';
function SlashCmdList.CooldownSync(msg, editbox)

	local args = {}
	for word in msg:gmatch("%S+") do
		table.insert(args, word)
	end

	if args == nil then
		opt:Config()
		return
	end

	local count = #args
	if not buddy then
		buddy = opt:GetModule("buddy")
	end
	if not inspect then
		inspect = opt:GetModule("inspect")
	end

	-- 1 param actions
	if (count == 1) then
		if (args[1] == "reinit") then
			opt:ResetAll()
			return
		elseif (args[1] == "help") then
			opt:PrintHelp()
			return
		elseif (args[1] == "reset") then
			local cds = opt:GetModule("cooldowns")
			cds:reset_all_cooldowns()
			return
		end
	-- 2 param actions
	elseif (count == 2) then
		if (args[1] == "add") then
			if args[2] == "target" then
				opt:ModuleEvent_AddTargetBuddy()
			else
				buddy:RegisterBuddy(args[2], opt.env.InRaid)
			end
			return
		elseif (args[1] == "remove") then
			buddy:RemoveBuddy(args[2])
			return
		end
	end

	-- if all else fails, load config
	opt:Config()
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
opt:RegisterEvent("INSPECT_READY")
opt:RegisterEvent("ENCOUNTER_START")
opt:RegisterEvent("ENCOUNTER_END")

-- Events

function opt:OnCombatEvent(...)

	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

	-- all events we care about will have a dest or source
	local is_from_player = (sourceGUID == opt.PlayerGUID)
	local is_targeting_player = (destGUID == opt.PlayerGUID)

	------------------------------------
	-- Aura was Gained
	------------------------------------

	if (subevent == "SPELL_AURA_APPLIED") then
		local spell_id = select(12,...)
		if (destGUID == opt.PlayerGUID) then
			opt:ModuleEvent_OnAuraGained(spell_id, destGUID, destName)
		else
			opt:ModuleEvent_OnOtherAuraGained(spell_id, destGUID, destName)
		end
		return
	end
	
	------------------------------------
	-- Aura Lost
	------------------------------------

	if (subevent == "SPELL_AURA_REMOVED") then
		local spell_id = select(12,...)
		if (destGUID == opt.PlayerGUID) then
			opt:ModuleEvent_OnAuraLost(spell_id, destGUID, destName)
		else
			opt:ModuleEvent_OnOtherAuraLost(spell_id, destGUID, destName)
		end
		return
	end

	------------------------------------
	-- Spell Cast
	------------------------------------

	if (subevent == "SPELL_CAST_SUCCESS") then
		local spell_id = select(12,...)
		
		if (sourceGUID == opt.PlayerGUID) then
			opt:ModuleEvent_OnSpellCast(spell_id, destGUID, destName)
		else
			opt:ModuleEvent_OnOtherSpellCast(spell_id, sourceGUID, sourceName, destGUID, destName)
		end
		return
	end

	------------------------------------
	-- Unit Died
	------------------------------------

	if (subevent == "UNIT_DIED") then
		opt:ModuleEvent_OnUnitDied(destGUID)
		return
	end

end

function opt:OnEnterCombat()
	opt.InCombat = true
	opt:ModuleEvent_OnCombatStart()
	opt:ForceUiUpdate()
end

function opt:OnLeaveCombat()
	opt.InCombat = false
	opt:ModuleEvent_OnCombatEnd()
	opt:ForceUiUpdate()
end

function opt:OnGroupChanged()

	local was_in_group = opt.InGroup or opt.InRaid
	opt.InGroup = IsInGroup() or IsInRaid()
	opt.InRaid = IsInRaid()

	-- notify modules the party situation has changed
	opt:ModuleEvent_PartyChanged()

	-- more specific party join/leave events
	local in_group = opt.InGroup
	if in_group and not was_in_group then
		opt:ModuleEvent_OnGroupJoined()
	elseif not in_group and was_in_group then
		opt:ModuleEvent_OnGroupLeft()
	end
end

function opt:OnCooldownsUpdated()
	opt:ModuleEvent_OnCooldownsUpdated()
end

function opt:OnInspectReady(guid)
	opt:ModuleEvent_InspectReady(guid)
end

-- Event Handlers

local function CooldownSync_EventHandler(self, event, ...)

	if (event == "PLAYER_LOGIN") then
		opt:OnLogin()
	elseif (event == "PLAYER_LOGOUT") then
		opt:OnLogout()
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		opt:OnCombatEvent(CombatLogGetCurrentEventInfo())
	elseif (event == "SPELL_UPDATE_COOLDOWN") then
		opt:OnCooldownsUpdated()
	elseif (event == "PLAYER_REGEN_DISABLED") then
		opt:OnEnterCombat()
	elseif (event == "PLAYER_REGEN_ENABLED") then
		opt:OnLeaveCombat()
	elseif (event == "GROUP_ROSTER_UPDATE") then
		opt:OnGroupChanged()
	elseif (event == "PLAYER_SPECIALIZATION_CHANGED") then
		local unit_id = ...
		opt:OnTalentsChanged(unit_id)
	elseif (event == "PARTY_CONVERTED_TO_RAID") then
		opt:OnGroupChanged()
	elseif (event == "TRAIT_CONFIG_UPDATED") then
		opt:OnTalentsChanged("player")
	elseif (event == "PLAYER_FOCUS_CHANGED") then
		opt:OnPlayerFocusChanged()
	elseif (event == "PLAYER_DEAD") then
		opt:OnPlayerDied()
	elseif (event == "ENCOUNTER_START") then
		local id, name, difficulty, groupSize = ...
		opt:OnEncounterStart(id, name, difficulty, groupSize)
	elseif (event == "ENCOUNTER_END") then
		local id, name, difficulty, groupSize = ...
		opt:OnEncounterEnd(id, name, difficulty, groupSize)
	elseif (event == "INSPECT_READY") then
		local guid = ...
		opt:OnInspectReady(guid)
	end
end
opt:SetScript("OnEvent", CooldownSync_EventHandler)