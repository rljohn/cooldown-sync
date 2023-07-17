---@diagnostic disable: undefined-field
local opt = CooldownSyncConfig

local LGF = LibStub("LibGetFrame-1.0")
local Glower = LibStub("LibCustomGlow-1.0")

function opt:AddEvokerModule()
    module = opt:BuildClassModule("evoker")
    module.glows = {}

    function module:load_default_values()
        opt:SetDefaultValue('Evoker_AugCooldowns', false)
    end

    function module:BuildPanels()
        local options = opt:CreatePanel(opt, nil, 585, 100)
        options:SetPoint('TOPLEFT', opt.ui.main, 'BOTTOMLEFT', 0, -80)
        
        local title = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        title:SetText(opt.titles.Evoker_Options)
        title:SetPoint('TOPLEFT', options, 'TOPLEFT', 0, 32)

        local header = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        header:SetText(opt.titles.Evoker_Augmentation)
        header:SetPoint('TOPLEFT', options, 'TOPLEFT', 4, -4)

        local glow = opt:CreateCheckBox(opt, 'Evoker_AugCooldowns')
        glow:SetPoint("TOPLEFT", header, "BOTTOMLEFT", -4, -4)
        glow:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
            end)
        opt:AddTooltip(glow, opt.titles.Evoker_GlowCooldowns, opt.titles.Evoker_GlowMajorCooldownsTooltip)
    end

    module.base_other_aura_gained = module.other_aura_gained
    module.base_other_aura_lost = module.other_aura_lost
    module.base_other_spell_cast = module.other_spell_cast

    module.base_init = module.init
    function module:init()
        self:base_init()
        self:BuildPanels()
    end

    function module:other_spell_cast(spell_id, source_guid, source_name, target_guid, target_name)
        module:base_other_spell_cast(spell_id, source_guid, source_name, target_guid, target_name)
        if not opt.InGroup and not opt.InRaid then return end -- only in party/raid
        if not opt.PlayerSpec == 1473 then return end -- aug check
        if not opt.env.Evoker_AugCooldowns then return end -- settings check

        local unit = opt:GetUnitInfo(source_name)
        if not unit then return end

        local unit_id = unit.unit_id
        local _, _, class_id = UnitClass(unit.unit_id)
        
        local ability = opt:FindAbility(class_id, spell_id)
        if not ability then return end
        if not ability.dur then return end

        self:add_glow(source_guid, unit_id, spell_id, ability.dur)
    end

    function module:other_aura_gained(spell_id, guid, n)
        module:base_other_aura_gained(spell_id, guid, n)
        if not opt.InGroup and not opt.InRaid then return end

        local unit = opt:GetUnitInfo(n)
        if not unit then return end

        local unit_id = unit.unit_id
        local _, _, class_id = UnitClass(unit.unit_id)

        local ability = opt:FindAbility(class_id, spell_id)
        if not ability then return end

        local duration = opt:GetAuraDuration(unit_id, spell_id)
        if ability.min and ability.min > duration then return end

        self:add_glow(guid, unit_id, spell_id, duration)
    end

    function module:other_aura_lost(spell_id, guid, n)
        module:base_other_aura_lost(spell_id, guid, n)
        if not opt.InGroup and not opt.InRaid then return end

        local unit = opt:GetUnitInfo(n)
        if not unit then return end

        for glow_guid, glow in pairs(self.glows) do
            if glow_guid == guid then
                glow.end_time = 0
                return
            end
        end
    end

    function module:add_glow(guid, unit_id, spell_id, duration)

        local glow = {}
        glow.unit_id = unit_id
        glow.guid = guid
        glow.spell_id = spell_id
        glow.end_time = GetTime() + duration
        glow.glowing = false
        glow.glow_frames = nil

        function glow:Begin()
            self:End()

            self.glow_frames = LGF.GetUnitFrame(self.unit_id, {
				ignorePlayerFrame = false,
				ignoreTargetFrame = false,
				ignoreTargettargetFrame = false,
                ignorePartyFrame = false,
				returnAll = true,
			  })

            if not self.glow_frames then
                return 
            end

            for _, frame in pairs(self.glow_frames) do
                Glower.PixelGlow_Start(frame)
            end

            self.glowing = true
        end

        function glow:End()
            if not self.glowing then return end
            self.glowing = false

            if not self.glow_frames then return end
            for _, frame in pairs(self.glow_frames) do
                if (frame) then
                    Glower.PixelGlow_Stop(frame)
                end
            end
            self.glow_frames = nil
        end

        glow:Begin()
        self.glows[guid] = glow
    end

    function module:update_slow()
        local to_remove = {}

        -- end all expired glows
        local current = GetTime()
        for guid, glow in pairs(self.glows) do
            if current > glow.end_time then
                to_remove[guid] = glow
                glow:End()
            end
        end

        -- clear tracking for expired glows
        for guid, glow in pairs(to_remove) do
            self.glows[guid] = nil
        end
    end

    return module
end