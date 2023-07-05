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

function opt:BuildLogModule(name)
    module = self:BuildModule(name)

    function module:talents_changed(self)
        cdPrintf("OnTalentsChanged")
    end

    function module:combat_start()
        cdPrintf("OnCombatStart")
    end

    function module:combat_end()
        cdPrintf("OnCombatEnd")
    end

    function module:aura_gained (spell_id, guid, name)
        cdPrintf("OnAuraGained: %d (%s, %s)", spell_id, guid, name)
    end

    function module:aura_lost (spell_id, guid, name)
        cdPrintf("OnAuraLost: %d", spell_id, guid, name)
    end

    function module:other_aura_gained (spell_id, guid, name)
        --cdPrintf("OnOtherAuraGained: %d (%s, %s)", spell_id, guid, name)
    end

    function module:other_aura_lost (spell_id, guid, name)
        --cdPrintf("OnOtherAuraLost: %d (%s, %s)", spell_id, guid, name)
    end

    function module:cooldowns_updated()
        --cdPrintf("OnCooldownsUpdated")
    end

    function module:cooldown_start(spell_id, start, duration, time_remaining, percent)
        cdPrintf("OnCooldownStart: %d, %s remaining", spell_id, string.format("%.1f", time_remaining))
    end

    function module:cooldown_update(guid, spell_id, start, duration, time_remaining, percent)
        --cdPrintf("OnCooldownUpdate: %d, %s remaining", spell_id, string.format("%.1f", time_remaining))
    end

    function module:cooldown_end(guid, spell_id)
        cdPrintf("OnCooldownEnd: %s (%d)", guid, spell_id)
    end

    function module:spell_cast(spell_id, target_guid, target_name)
        cdPrintf("OnSpellCast: %d to %s (%s)", spell_id, target_name, target_guid)
    end

    function module:other_spell_cast(spell_id, source_guid, source_name, target_guid, target_name)
        -- cdPrintf("OnOtherSpellCast: %d from %s (%s) to %s (%s)", spell_id, source_name, source_guid, target_name, target_guid)
    end

    function module:party_changed(self)
        cdPrintf("OnPartyChanged")
    end

    function module:inspect_ready(guid)
        cdPrintf("OnInspectReady: %s", guid)
    end

    function module:buddy_added(n)
        cdPrintf("OnBuddyRegistered: %s", n)
    end

    function module:buddy_removed(n)
        cdPrintf("OnBuddyUnregistered: %s", n)
    end

    function module:buddy_available(buddy)
        cdPrintf("OnBuddyAvailable: %s", buddy.id)
    end

    function module:buddy_available(buddy)
        cdPrintf("OnBuddyAvailable: %s", buddy.id)
    end

    function module:buddy_unavailable(buddy)
        cdPrintf("OnBuddyUnavailable: %s", buddy.id)
    end

    function module:buddy_spec_changed(buddy)
        cdPrintf("OnBuddySpecChanged: %s - %s", buddy.id, buddy.spec_name)
    end

    function module:unit_id_changed(buddy, unit_id)
        cdPrintf("OnUnitIdChanged: %s - %s", buddy.id, unit_id)
    end

end