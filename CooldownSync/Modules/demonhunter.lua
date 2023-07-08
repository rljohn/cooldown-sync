local opt = CooldownSyncConfig

function opt:AddDemonHunterModule()
    module = opt:BuildClassModule("demonhunter")
    return module
end