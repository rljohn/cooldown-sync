local opt = CooldownSyncConfig

opt.CooldownIcons = {}

local Glower = LibStub("LibCustomGlow-1.0")
local LGF = LibStub("LibGetFrame-1.0")

function opt:ResetCooldownIcons()
    for key, icon in pairs(self.CooldownIcons) do
        icon:Reset()
    end
    opt.CooldownIcons = {}
end

function opt:FindInactiveIcon()
    for _,icon in pairs(opt.CooldownIcons) do
        if not icon:IsShown() then
            pbDiagf("Recycling icon")
            return icon
        end
    end

    return nil
end

function opt:CreateCooldownIcon(parent, spell_id)

    local ICON_ZOOM = 0.08

    local spacing = 4
    local width = (7 * opt.env.IconSize) + spacing
    local height = opt.env.IconSize

    local panel = opt:FindInactiveIcon()
    if (panel == nil) then
        panel = CreateFrame('FRAME', nil, parent, "BackdropTemplate")
        panel:SetSize(width, height)

        panel.spell = CreateFrame('FRAME', nil, panel, "BackdropTemplate")
        panel.spell:SetPoint('TOPLEFT', panel, 'TOPLEFT', 0, 0)
        panel.spell:SetWidth(opt.env.IconSize)
        panel.spell:SetHeight(opt.env.IconSize)
        panel.spell.texture = panel.spell:CreateTexture(nil, "ARTWORK")
        panel.spell.texture:SetTexture(GetSpellTexture(spell_id))
        panel.spell.texture:SetAllPoints(panel.spell)
        panel.spell.texture:SetTexCoord(ICON_ZOOM, 1-ICON_ZOOM, ICON_ZOOM, 1-ICON_ZOOM)

        panel.timer = panel.spell:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        panel.timer:SetPoint('TOP', panel.spell, 'BOTTOM', 0, -2)
        panel.timer:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        panel.timer:Hide()

        panel.cooldown_icon = CreateFrame('Cooldown', nil, panel.spell, 'CooldownFrameTemplate')
        panel.cooldown_icon:SetAllPoints()
        panel.cooldown_icon:SetDrawEdge(false)
        panel.cooldown_icon:SetSwipeTexture("")
    end

    function panel.Begin(self)
        panel.active = true
        panel.timer:Show()
        self:EndCooldown()
    end

    function panel.End(self)
        panel.active = false
        panel.timer:End()
    end

    function panel.SetAura(self, time_remaining)
        local text = string.format("%d", time_remaining)
        self.panel.timer:SetText(text)
    end

    function panel.SetCooldown(self, start, duration, percent)
        if (not panel.active) then
            self.current = percent * 100
            self.cooldown_icon:SetCooldown(start, duration)
        end
    end

    function panel.EndCooldown()
        panel.cooldown_icon:SetCooldown(0, 0)
    end

    function panel.Reset(self)
        self:Hide()
    end

    panel.spell_id = spell_id
    panel:Show()
    table.insert(opt.CooldownIcons, panel)
    return panel

end
