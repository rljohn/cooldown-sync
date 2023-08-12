local opt = CooldownSyncConfig

function opt:AddShamanModule()
    local module = opt:BuildClassModule("shaman")
    return module
end