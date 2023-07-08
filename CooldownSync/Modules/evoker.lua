local opt = CooldownSyncConfig

function opt:AddEvokerModule()
    module = opt:BuildClassModule("evoker")
    return module
end