local opt = CooldownSyncConfig

function opt:AddMonkModule()
    module = opt:BuildClassModule("monk")
    return module
end