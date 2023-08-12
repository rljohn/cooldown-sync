local opt = CooldownSyncConfig

function opt:AddDruidModule()
    local module = opt:BuildClassModule("druid")
    return module
end