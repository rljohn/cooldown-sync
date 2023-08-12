local opt = CooldownSyncConfig

function opt:AddHunterModule()
    local module = opt:BuildClassModule("hunter")
    return module
end