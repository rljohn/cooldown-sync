local opt = CooldownSyncConfig

function opt:AddDeathKnightModule()
    module = opt:BuildClassModule("deathknight")
    return module
end