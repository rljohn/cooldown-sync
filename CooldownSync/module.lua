local opt = CooldownSyncConfig
opt.modules = {}

-- Default module
function opt:BuildModule(id)

    -- create default module with nil implementation
    module = {}
    module.name = id
    module.init = function()
        cdPrintf("Module (%s) initialized", id)
    end
    module.post_init = nil
    module.update = nil
    module.talents_changed = nil
    module.combat_start = nil
    module.combat_end = nil
    module.aura_gained = nil
    module.aura_lost = nil
    module.cooldowns_updated = nil
    module.cooldown_update = nil
    module.cooldown_start = nil
    module.cooldown_end = nil
    module.spell_cast = nil
    module.other_spell_cast = nil
    module.party_changed = nil
    module.buddy_added = nil
    module.buddy_removed = nil
    module.buddy_available = nil
    module.buddy_unavailable = nil
    module.inspect_ready = nil

    -- register module
    self:AddModule(id, module)

    -- return module, otherwise access using GetModule(id)
    return module
end

-- Module Registration and Access
function opt:AddModule(id, module)
    opt.modules[id] = module
end

function opt:GetModule(id)
    return opt.modules[id]
end

-- Module Event Handlers
function opt:ModuleEvent_LoadDefaultValues()
    for key, module in pairs(opt.modules) do
        if (module.load_default_values) then
            module:load_default_values()
        end
    end
end

function opt:ModuleEvent_OnInit()
    for key, module in pairs(opt.modules) do
        if (module.init) then
            module:init()
        end
    end
end

function opt:ModuleEvent_OnPostInit()
    for key, module in pairs(opt.modules) do
        if (module.post_init) then
            module:post_init()
        end
    end
end

function opt:ModuleEvent_OnResize()
    for key, module in pairs(opt.modules) do
        if (module.on_resize) then
            module:on_resize()
        end
    end
end

function opt:ModuleEvent_OnUpdate(elapsed)
    for key, module in pairs(opt.modules) do
        if (module.update) then
            module:update(elapsed)
        end
    end
end

function opt:ModuleEvent_OnTalentsChanged()
    for key, module in pairs(opt.modules) do
        if (module.talents_changed) then
            module:talents_changed()
        end
    end
end

function opt:ModuleEvent_OnCombatStart()
    for key, module in pairs(opt.modules) do
        if (module.combat_start) then
            module:combat_start()
        end
    end
end

function opt:ModuleEvent_OnCombatEnd()
    for key, module in pairs(opt.modules) do
        if (module.combat_end) then
            module:combat_end()
        end
    end
end

function opt:ModuleEvent_PartyChanged()
    for key, module in pairs(opt.modules) do
        if (module.party_changed) then
            module:party_changed()
        end
    end
end

function opt:ModuleEvent_OnAuraGained(spell_id, guid, name)
    for key, module in pairs(opt.modules) do
        if (module.aura_gained) then
            module:aura_gained(spell_id, guid, name)
        end
    end
end

function opt:ModuleEvent_OnAuraLost(spell_id, guid, name)
    for key, module in pairs(opt.modules) do
        if (module.aura_lost) then
            module:aura_lost(spell_id, guid, name)
        end
    end
end

function opt:ModuleEvent_OnOtherAuraGained(spell_id, guid, name)
    for key, module in pairs(opt.modules) do
        if (module.other_aura_gained) then
            module:other_aura_gained(spell_id, guid, name)
        end
    end
end

function opt:ModuleEvent_OnOtherAuraLost(spell_id, guid, name)
    for key, module in pairs(opt.modules) do
        if (module.other_aura_lost) then
            module:other_aura_lost(spell_id, guid, name)
        end
    end
end

function opt:ModuleEvent_OnSpellCast(spell_id, target_guid, target_name)
    for key, module in pairs(opt.modules) do
        if (module.spell_cast) then
            module:spell_cast(spell_id, target_guid, target_name)
        end
    end
end

function opt:ModuleEvent_OnOtherSpellCast(spell_id, source_guid, source_name, target_guid, target_name)
    for key, module in pairs(opt.modules) do
        if (module.other_spell_cast) then
            module:other_spell_cast(spell_id, source_guid, source_name, target_guid, target_name)
        end
    end
end

function opt:ModuleEvent_OnCooldownsUpdated()
    for key, module in pairs(opt.modules) do
        if (module.cooldowns_updated) then
            module:cooldowns_updated()
        end
    end
end
function opt:ModuleEvent_OnCooldownStart(spell_id, start, duration, time_remaining)
    for key, module in pairs(opt.modules) do
        if (module.cooldown_start) then
            module:cooldown_start(spell_id, start, duration, time_remaining)
        end
    end
end

function opt:ModuleEvent_OnCooldownUpdate(guid, spell_id, start, duration, time_remaining)
    for key, module in pairs(opt.modules) do
        if (module.cooldown_update) then
            module:cooldown_update(guid, spell_id, start, duration, time_remaining)
        end
    end
end

function opt:ModuleEvent_OnCooldownEnd(guid, spell_id)
    for key, module in pairs(opt.modules) do
        if (module.cooldown_end) then
            module:cooldown_end(guid, spell_id)
        end
    end
end

function opt:ModuleEvent_BuddyAdded(name)
    for key, module in pairs(opt.modules) do
        if (module.buddy_added) then
            module:buddy_added(name)
        end
    end
end

function opt:ModuleEvent_BuddyRemoved(name)
    for key, module in pairs(opt.modules) do
        if (module.buddy_removed) then
            module:buddy_removed(name)
        end
    end
end

function opt:ModuleEvent_BuddyAvailable(buddy)
    for key, module in pairs(opt.modules) do
        if (module.buddy_available) then
            module:buddy_available(buddy)
        end
    end
end

function opt:ModuleEvent_BuddyUnavailable(buddy)
    for key, module in pairs(opt.modules) do
        if (module.buddy_unavailable) then
            module:buddy_unavailable(buddy)
        end
    end
end

function opt:ModuleEvent_BuddySpecChanged(buddy)
    for key, module in pairs(opt.modules) do
        if (module.buddy_spec_changed) then
            module:buddy_spec_changed(buddy)
        end
    end
end

function opt:ModuleEvent_InspectRequest(guid)
    for key, module in pairs(opt.modules) do
        if (module.inspect_request) then
            module:inspect_request(guid)
        end
    end
end

function opt:ModuleEvent_InspectReady(guid)
    for key, module in pairs(opt.modules) do
        if (module.inspect_ready) then
            module:inspect_ready(guid)
        end
    end
end

function opt:ModuleEvent_BuddyUnitIdChanged(buddy, unit_id)
    for key, module in pairs(opt.modules) do
        if (module.unit_id_changed) then
            module:unit_id_changed(buddy, unit_id)
        end
    end
end

function opt:ModuleEvent_InspectSpecialization(guid, spec)
    for key, module in pairs(opt.modules) do
        if (module.inspect_specialization) then
            module:inspect_specialization(guid, spec)
        end
    end
end

-- Class Modules
function opt:BuildClassModules(class)

    if (class == 1) then
        self:AddWarriorModule()
    elseif (class == 2) then
        self:AddPaladinModule()
    elseif (class == 3) then
        self:AddHunterModule()
    elseif (class == 4) then
        self:AddRogueModule()
    elseif (class == 5) then
        self:AddPriestModule()
    elseif (class == 6) then
        self:AddDeathKnightModule()
    elseif (class == 7) then
        self:AddShamanModule()
    elseif (class == 8) then
        self:AddMageModule()
    elseif (class == 9) then
        self:AddWarlockModule()
    elseif (class == 10) then
        self:AddMonkModule()
    elseif (class == 11) then
        self:AddDruidModule()
    elseif (class == 12) then
        self:AddDemonHunterModule()
    elseif (class == 13) then
        self:AddEvokerModule()
    end

end

function opt:CreateModules()

    -- all classes
    self:AddInspectModule()
    self:AddBuddyModule()
    self:AddCooldownModule()

    -- my class
    self:BuildClassModules(opt.PlayerClass)
end