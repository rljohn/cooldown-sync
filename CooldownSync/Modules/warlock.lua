local opt = CooldownSyncConfig

function opt:AddWarlockModule()
    module = opt:BuildClassModule("warlock")
    return module
end