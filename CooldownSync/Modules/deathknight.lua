local opt = CooldownSyncConfig

function opt:AddDeathKnightModule()
    local module = opt:BuildClassModule("deathknight")
    return module
end