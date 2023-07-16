local opt = CooldownSyncConfig

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

        local glow = opt:CreateCheckBox(opt, 'Evoker_GlowMajorCooldowns')
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
        if not opt.InGroup and not opt.InRaid then return end

        local unit = opt:GetUnitInfo(source_name)
        if not unit then return end

        local unit_id = unit.unit_id
        local _, _, class_id = UnitClass(unit.unit_id)
        
        local ability = opt:FindAbility(class_id, spell_id)
        if not ability then return end
        if not ability.aura_estimate then return end

        self:add_glow(unit_id, ability)
        DevTools_Dump(ability)
    end

    function module:other_aura_gained(spell_id, guid, n)
        module:base_other_aura_gained(spell_id, guid, n)
        if not opt.InGroup and not opt.InRaid then return end

        print(n)

        local unit = opt:GetUnitInfo(n)
        if not unit then return end

        print('trace1')
    end

    function module:other_aura_lost(spell_id, guid, n)
        module:base_other_aura_lost(spell_id, guid, n)
        if not opt.InGroup and not opt.InRaid then return end

        print(n)

        local unit = opt:GetUnitInfo(n)
        if not unit then return end

        print('trace2')
    end

    function module:add_glow(guid, unit_id, ability)
        local glow = {}
        glow.unit_id = ability
        glow.spell_id = ability.spell_id
        glow.end_time = GetTime() + ability.aura_estimate

        function glow:Begin()
            self:End()
        end

        function glow:End()

        end

        glow:Begin()
        self.glows[guid] = glow
    end

    function module:update_slow()
        local to_remove = {}
        for guid, glow in pairs(self.glows) do
            
        end
    end

    return module
end