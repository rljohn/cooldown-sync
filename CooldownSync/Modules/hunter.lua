local opt = CooldownSyncConfig

function opt:AddHunterModule()
    module = opt:BuildDpsModule("hunter")
    return module
end