local opt = CooldownSyncConfig

-- Setup Slash Commands

function opt:PrintHelp()
	print('|cffFFF569Cooldown Sync|r Commands:')
end

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

	-- 1 param actions
	if (count == 1) then
		if (args[1] == "reset") then
			opt:ResetAll()
			opt:LoadMissingValues()
			return
		elseif (args[1] == "clear") then
			local buddy = opt:GetModule("buddy")
			buddy:ClearBuddies()
			return
		elseif (args[1] == "update") then
			local buddy = opt:GetModule("buddy")
			buddy:UpdateBuddies()
			return
		end
	-- 2 param actions
	elseif (count == 2) then
		if (args[1] == "add") then
			local buddy = opt:GetModule("buddy")
			buddy:RegisterBuddy(args[2])
			return
		elseif (args[1] == "remove") then
			local buddy = opt:GetModule("buddy")
			buddy:RemoveBuddy(args[2])
			return
		elseif (args[1] == "dump") then
			cdDiagf("Dumping: %s", args[2])
			if (args[2] == "env") then
				cdDump(opt.env)
			elseif (args[2] == "global") then
				cdDump(opt.globals)
			elseif (args[2] == "buddy") then
				local buddy = opt:GetModule("buddy")
				cdDump(buddy) 
			end
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
		if (destGUID == opt.PlayerGUID) then
			local spell_id = select(12,...)
			opt:ModuleEvent_OnAuraGained(spell_id, destGUID, destName)
		end

		return
	end
	
	------------------------------------
	-- Aura Lost
	------------------------------------

	if (subevent == "SPELL_AURA_REMOVED") then
		if (destGUID == opt.PlayerGUID) then
			local spell_id = select(12,...)
			opt:ModuleEvent_OnAuraLost(spell_id, destGUID, destName)
		end
		return
	end

	------------------------------------
	-- Spell Cast
	------------------------------------

	if (subevent == "SPELL_CAST_SUCCESS") then
		if (sourceGUID == opt.PlayerGUID) then
			local spell_id = select(12,...)
			opt:ModuleEvent_OnSpellCast(spell_id, destGUID, destName)
		else
			local spell_id = select(12,...)
			opt:ModuleEvent_OnOtherSpellCast(spell_id, sourceGUID, sourceName, destGUID, destName)
		end
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

function opt:OnCooldownsUpdated()
	opt:ModuleEvent_OnCooldownsUpdated()
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
opt:SetScript("OnEvent", CooldownSync_EventHandler)