local opt = CooldownSyncConfig

function opt:AddMageModule()
    module = opt:BuildClassModule("mage")
    return module
end