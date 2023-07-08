local opt = CooldownSyncConfig

function opt:AddDruidModule()
    module = opt:BuildClassModule("druid")
    return module
end