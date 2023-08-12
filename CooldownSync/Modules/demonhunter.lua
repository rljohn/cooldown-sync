local opt = CooldownSyncConfig

function opt:AddDemonHunterModule()
    local module = opt:BuildClassModule("demonhunter")
    return module
end