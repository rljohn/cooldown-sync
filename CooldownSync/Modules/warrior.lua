local opt = CooldownSyncConfig

function opt:AddWarriorModule()
    module = opt:BuildClassModule("warrior")
    return module
end