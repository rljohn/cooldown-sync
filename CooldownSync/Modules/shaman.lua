local opt = CooldownSyncConfig

function opt:AddShamanModule()
    module = opt:BuildClassModule("shaman")
    return module
end