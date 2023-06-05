local opt = CooldownSyncConfig

function opt:AddHunterModule()
    module = opt:BuildClassModule("hunter")
    return module
end