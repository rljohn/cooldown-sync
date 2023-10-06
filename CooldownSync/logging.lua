---@diagnostic disable: lowercase-global
local opt = CooldownSyncConfig

-- toggles for logging
local ENABLE_LOG_MODULE=false
local ENABLE_OUTPUT=(ENABLE_LOG_MODULE and true)
local ENABLE_DIAG=(ENABLE_LOG_MODULE and true)
local ENABLE_DUMPING=(ENABLE_LOG_MODULE and true)

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

function cdStackf(...)
	if (not ENABLE_DIAG) then return end
	local status, res = pcall(format, ...)
	if status then
		print('|cffFFF569Cooldown Sync:|r', res)
        print(debugstack(2, 4, 4))
    end
end

function opt:BuildLogModule(name)
    if not ENABLE_LOG_MODULE then return end
    
    local module = self:BuildModule(name)

    function module:talents_changed(unit_id)
        cdDiagf("OnTalentsChanged: %s", unit_id)
    end

    function module:add_target()
        cdDiagf("AddTarget: %s", GetUnitName("target"))
    end

    function module:combat_start()
        cdDiagf("OnCombatStart")
    end

    function module:combat_end()
        cdDiagf("OnCombatEnd")
    end

    function module:aura_gained (spell_id, guid, name)
        cdDiagf("OnAuraGained: %d (%s, %s)", spell_id, guid, name)
    end

    function module:aura_lost (spell_id, guid, name)
        cdDiagf("OnAuraLost: %d", spell_id, guid, name)
    end

    function module:other_aura_gained (spell_id, guid, name)
        --cdDiagf("OnOtherAuraGained: %d (%s, %s)", spell_id, guid, name)
    end

    function module:other_aura_lost (spell_id, guid, name)
        --cdDiagf("OnOtherAuraLost: %d (%s, %s)", spell_id, guid, name)
    end

    function module:cooldowns_updated()
        --cdDiagf("OnCooldownsUpdated")
    end

    function module:cooldown_start(guid, spell_id, start, duration, time_remaining)
        cdDiagf("OnCooldownStart: %d, %s remaining", spell_id, string.format("%.1f", time_remaining))
    end

    function module:cooldown_update(guid, spell_id, start, duration, time_remaining)
        cdDiagf("OnCooldownUpdate: %d - (%f, %f) %s remaining", spell_id, start, duration, string.format("%.1f", time_remaining))
    end

    function module:cooldown_end(guid, spell_id)
        cdDiagf("OnCooldownEnd: %s (%d)", guid, spell_id)
    end

    function module:spell_cast(spell_id, target_guid, target_name)
        cdDiagf("OnSpellCast: %d to %s (%s)", spell_id, target_name, target_guid)
    end

    function module:other_spell_cast(spell_id, source_guid, source_name, target_guid, target_name)
        if target_guid and target_name then
            --cdDiagf("OnOtherSpellCast: %d from %s (%s) to %s (%s)", spell_id, source_name, source_guid, target_name, target_guid)
        elseif source_guid and source_name then
           -- cdDiagf("OnOtherSpellCast: %d from %s (%s) - no target", spell_id, source_name, source_guid)
        else
            --cdDiagf("OnOtherSpellCast: %d", spell_id)
        end
    end

    function module:party_changed()
        cdDiagf("OnPartyChanged")
    end

    function module:inspect_ready(guid)
        cdDiagf("OnInspectReady: %s", guid)
    end

    function module:buddy_added(n)
        cdDiagf("OnBuddyRegistered: %s", n)
    end

    function module:buddy_removed(n)
        cdDiagf("OnBuddyUnregistered: %s", n)
    end

    function module:buddy_available(buddy)
        cdDiagf("OnBuddyAvailable: %s", buddy.id)
    end
    function module:buddy_unavailable(buddy)
        cdDiagf("OnBuddyUnavailable: %s", buddy.id)
    end

    function module:inspect_request(guid)
        cdDiagf("OnInspectRequested: %s", guid)
    end

    function module:inspect_specialization(guid, spec)
        cdDiagf("InspectSpecialization: %s - %s", guid, spec)
    end

    function module:buddy_spec_changed(buddy)
        cdDiagf("OnBuddySpecChanged: %s - %s", buddy.id, buddy.spec_name)
    end

    function module:buddy_died(buddy)
        cdDiagf("OnBuddyDied: %s", buddy.guid)
    end

    function module:buddy_alive(buddy)
        cdDiagf("OnBuddyAlive: %s", buddy.guid)
    end

    function module:unit_died(guid)
        cdDiagf("OnUnitDied: %s", guid)
    end

    function module:unit_id_changed(buddy, unit_id)
        cdDiagf("OnUnitIdChanged: %s - %s", buddy.id, unit_id)
    end

    function module:main_frame_right_click()
        cdDiagf("OnMainFrameRightClick")
    end

    function module:ability_frame_middle_click(row)
        cdDiagf("OnAbilityRowDoubleClick - %s", row.player)
    end

    function module:ability_begin(guid, ability)
        cdDiagf("OnAbilityBegin: %s - %s", guid, ability.id)
    end

    function module:ability_end(guid, ability)
        cdDiagf("OnAbilityEnd: %s - %s", guid, ability.id)
    end

    function module:encounter_start(id, name, difficulty, group_size)
        cdDiagf("OnEncounterStart: %s - %s", id, name)
    end

    function module:encounter_end(id, name, difficulty, group_size)
        cdDiagf("OnEncounterEnd: %s - %s", id, name)
    end
        
end