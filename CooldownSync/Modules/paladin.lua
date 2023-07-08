local opt = CooldownSyncConfig

function opt:AddPaladinModule()
    module = opt:BuildClassModule("paladin")
    return module
end