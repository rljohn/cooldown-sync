local opt = CooldownSyncConfig

-- toggles for logging
local ENABLE_OUTPUT=true
local ENABLE_DIAG=true
local ENABLE_DUMPING=true

-- LOGGING
function cdPrintf(...)
 if (not ENABLE_OUTPUT) then return end
 local status, res = pcall(format, ...)
 if status then
    print('|cffFFF569Cooldown Sync:|r', res)
  end
end

-- DIAG
function cdDiagf(...)
	if (not ENABLE_DIAG) then return end
	local status, res = pcall(format, ...)
	if status then
		print('|cffFFF569Cooldown Sync:|r', res)
	 end
   end

-- DUMP
function cdDump(data)
 if (not ENABLE_DUMPING) then return end
 DevTools_Dump(data)
end

function opt:pairsByKeys (t, f)
  local a = {}

  for n in pairs(t) do table.insert(a, n) end

  table.sort(a, f)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then 
        return nil
    else 
        return a[i], t[a[i]]
    end
  end
  return iter
end

function opt:BuildLogModule(name)
    module = self:BuildModule(name)

    module.init = nil
    module.update = nil

    function module.talents_changed(self)
        cdPrintf("OnTalentsChanged")
    end
    function module.combat_start(self)
        cdPrintf("OnCombatStart")
    end

    function module.combat_end(self)
        cdPrintf("OnCombatEnd")
    end

    function module.aura_gained (self, spell_id, guid, name)
        cdPrintf("OnAuraGained: %d (%s, %s)", spell_id, guid, name)
    end

    function module.aura_lost (self, spell_id, guid, name)
        cdPrintf("OnAuraLost: %d", spell_id, guid, name)
    end

    function module.cooldowns_updated (self)
        --cdPrintf("OnCooldownsUpdated")
    end

    function module.cooldown_start(self, spell_id, start, duration, time_remaining, percent)
        cdPrintf("OnCooldownStart: %d, %s remaining", spell_id, string.format("%.1f", time_remaining))
    end

    function module.cooldown_update(self, spell_id, start, duration, time_remaining, percent)
        --cdPrintf("OnCooldownUpdate: %d, %s remaining", spell_id, string.format("%.1f", time_remaining))
    end

    function module.cooldown_end(self, spell_id)
        cdPrintf("OnCooldownEnd")
    end

    function module.spell_cast(self, spell_id, target_guid, target_name)
        cdPrintf("OnSpellCast: %d to %s (%s)", spell_id, target_name, target_guid)
    end

    function module.other_spell_cast(self, spell_id, source_guid, source_name, target_guid, target_name)
        -- cdPrintf("OnOtherSpellCast: %d from %s (%s) to %s (%s)", spell_id, source_name, source_guid, target_name, target_guid)
    end

    function module.party_changed ()
        cdPrintf("OnPartyChanged")
    end

end