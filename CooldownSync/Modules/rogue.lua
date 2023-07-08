local opt = CooldownSyncConfig

function opt:AddRogueModule()
    module = opt:BuildClassModule("rogue")
    return module
end