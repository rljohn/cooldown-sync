local opt = CooldownSyncConfig

local Glower = LibStub("LibCustomGlow-1.0")
local LGF = LibStub("LibGetFrame-1.0")

function opt:AddGlowModule()
    module = self:BuildModule("glow")
end