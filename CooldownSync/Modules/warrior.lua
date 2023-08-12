local opt = CooldownSyncConfig

function opt:AddWarriorModule()
    local module = opt:BuildClassModule("warrior")
    return module
end