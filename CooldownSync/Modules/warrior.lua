local opt = CooldownSyncConfig

function opt:AddWarriorModule()
    module = opt:BuildDpsModule("warrior")
    return module
end