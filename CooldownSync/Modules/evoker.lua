local opt = CooldownSyncConfig

function opt:AddEvokerModule()
    module = opt:BuildClassModule("evoker")

    module.base_other_aura_gained = module.other_aura_gained
    module.base_other_aura_lost = module.other_aura_lost

    function module.other_aura_gained(spell_id, guid, n)
        module.base_other_aura_gained(spell_id, guid, n)
    end

    function module.other_aura_lost(spell_id, guid, n)
        module.base_other_aura_lost(spell_id, guid, n)
    end

    return module
end