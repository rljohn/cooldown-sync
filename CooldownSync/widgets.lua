---@diagnostic disable: undefined-field
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
    icon:Reset()
    table.insert(RecycledIcons, icon)
end

function opt:FindInactiveIcon()

    for key,icon in pairs(RecycledIcons) do
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
        panel.spell.texture:SetAllPoints(panel.spell)
        panel.spell.texture:SetTexCoord(ICON_ZOOM, 1-ICON_ZOOM, ICON_ZOOM, 1-ICON_ZOOM)
        panel.spell:SetScript('OnMouseDown', function(self, button, ...)
            if (button == "RightButton") then
                opt:ModuleEvent_OnMainFrameRightClick()
            elseif (button == "MiddleButton") then
                opt:ModuleEvent_OnRowMiddleClick(parent)
            end
        end)

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

            if (opt.env.ShowSpellTimers) then
                self.timer:Show()
            end
    
            if (self.cd_start > 0) then
                self:HideCooldown()
            end
    
            if (Glower and opt.env.ShowSpellGlow) then
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
    
        function panel:SetCooldown(start, duration, time_remaining)
            self.cd_start = start
            self.cd_duration = duration
            self.cd_time_remaining = time_remaining
    
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
            self.cd_time_remaining = 0
        end

        function panel:UnitDied()
            if self.spell then
                self.spell:SetAlpha(0.15)
            end
        end

        function panel:UnitAlive()
            if self.spell then
                self.spell:SetAlpha(1)
            end
        end
    
        function panel:Reset()
            self:End()
            self:EndCooldown()
            self.active = false
            self.glowing = false
            self.hiding_cooldown = true
            self.cd_duration = 0
            self.spell_id = spell_id
            self.spell:SetAlpha(1)
            self:Hide()
        end

        function panel:on_settings_changed()
            if not self.active then return end
            
            -- toggle glow 
            if self.glowing and not opt.env.ShowSpellGlow then
                Glower.PixelGlow_Stop(self.spell)
                self.glowing = false
            elseif not self.glowing and opt.env.ShowSpellGlow then
                Glower.PixelGlow_Start ( self.spell, nil, nil, nil, nil, nil, 1, 1)
                self.glowing = true
            end

            -- toggle timer
            if not opt.env.ShowSpellTimers then
                self.timer:Hide()
            else
                self.timer:Show()
            end     
        end
    end

    -- set icons
    panel.spell.texture:SetTexture(GetSpellTexture(spell_id))

    -- reset properties
    panel.active = false
    panel.glowing = false
    panel.hiding_cooldown = true
    panel.cd_duration = 0
    panel.cd_start = 0
    panel.cd_time_remaining = 0
    panel.spell_id = spell_id
    panel:HideCooldown()
    panel:Show()
    return panel
end
