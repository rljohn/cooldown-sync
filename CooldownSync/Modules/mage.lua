local opt = CooldownSyncConfig

function opt:AddMageModule()
    local module = opt:BuildClassModule("mage")
    return module
end