local opt = CooldownSyncConfig

function opt:AddMonkModule()
    local module = opt:BuildClassModule("monk")
    return module
end