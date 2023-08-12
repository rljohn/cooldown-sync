local opt = CooldownSyncConfig

function opt:AddWarlockModule()
    local module = opt:BuildClassModule("warlock")
    return module
end