local opt = CooldownSyncConfig

local RecycledIcons = {}

local Glower = LibStub("LibCustomGlow-1.0")
local LGF = LibStub("LibGetFrame-1.0")

function opt:InitGlowLibrary()
    if (LGF) then
		LGF.GetUnitFrame("player")
	end
end

function opt:RecycleIcon(icon)
    cdDiagf("Recycling icon.")
    icon:Reset()
    table.insert(RecycledIcons, icon)
end

function opt:FindInactiveIcon()

    for key,icon in pairs(RecycledIcons) do
        cdDiagf("Reusing recycled icon")
        RecycledIcons[key] = nil
        icon:Reset()
        return icon
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

        panel = CreateFrame('FRAME', nil, opt.main, "BackdropTemplate")
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

        function panel:Begin()

            self.active = true
            self.timer:Show()
    
            if (self.cd_start > 0) then
                self:HideCooldown()
            end
    
            if (Glower) then
                Glower.PixelGlow_Start ( self.spell, nil, nil, nil, nil, nil, 1, 1)
                self.glowing = true
            end
        end
    
        function panel:End()
            self.active = false
            self.timer:Hide()
    
            if (self.hiding_cooldown and self.cd_start > 0) then
                self:ShowCooldown()
            end
    
            if (self.glowing) then
                Glower.PixelGlow_Stop(self.spell)
                self.glowing = false
            end
        end
    
        function panel:SetAura(time_remaining)
            local text = opt:TimeRemainingString(time_remaining)
            self.timer:SetText(text)
        end
    
        function panel:HideCooldown()
            if (self.cd_start > 0) then
                self.hiding_cooldown = true
            end
            self.cooldown_icon:SetCooldown(0, 0)
        end
    
        function panel:ShowCooldown()
            self.hiding_cooldown = false
            self.cooldown_icon:SetCooldown(self.cd_start, self.cd_duration)
        end
    
        function panel:SetCooldown(start, duration)
            self.cd_start = start
            self.cd_duration = duration
    
            if (not panel.active) then
                self.cooldown_icon:SetCooldown(start, duration)
            else
                self.hiding_cooldown = true
            end
        end
    
        function panel:EndCooldown()
            self.cooldown_icon:SetCooldown(0, 0)
            self.cd_start = 0
            self.cd_end = 0
        end
    
        function panel:Reset()
            panel:End()
            panel:EndCooldown()
            panel.active = false
            panel.glowing = false
            panel.hiding_cooldown = true
            panel.cd_duration = 0
            panel.spell_id = spell_id
            self:Hide()
        end
    end

    -- reset properties
    panel.active = false
    panel.glowing = false
    panel.hiding_cooldown = true
    panel.cd_duration = 0
    panel.cd_start = 0
    panel.spell_id = spell_id
    panel:HideCooldown()
    panel:Show()
    return panel
end
