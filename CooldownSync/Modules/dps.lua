local opt = CooldownSyncConfig

local function CDSync_OnTalentsChanged(self, spec_id)
    self:ResetCooldowns()
end

local function CDSync_OnCooldownUpdated(self, spell_id, start, duration, time_remaining, percent)
    local ability = self.cooldowns:GetAbility(spell_id)
    if (ability and ability.icon) then
        ability.icon:SetCooldown(start, duration, percent)
    end
end

function opt:BuildDpsModule(name)
    
    module = self:BuildModule(name)
    module.cooldowns = self:GetModule("cooldowns")
    
    -- build cooldown icons
    module.icon_offset_x = 8
    module.icon_offset_y = -8
    module.icon_spacing = opt.env.IconSize + 8

    -- events
    module.talents_changed = CDSync_OnTalentsChanged
    module.cooldown_update = CDSync_OnCooldownUpdated

    -- setup abilities
    function module.SetupAbilities()
        local abilities = self:GetSpecInfo(opt.PlayerClass, opt.PlayerSpec)
        for index, ability in opt:pairsByKeys ( abilities ) do
            local spell_id = ability[1]
            module.cooldowns:TrackAbility(spell_id)
            local icon = self:AddAbilityCooldownIcon(module, spell_id)
            module.cooldowns:AddIcon(spell_id, icon)
        end
    end

    -- reset
    function module.ResetCooldowns(self)
        self.icon_offset_x = 8
        self.icon_offset_y = -8
        self.cooldowns:Reset()
        opt:ResetCooldownIcons()
        self:SetupAbilities()
    end
    
    module.SetupAbilities()
    return module
end

function opt:AddAbilityCooldownIcon(module, spell_id)
    local icon = opt:CreateCooldownIcon(opt.main, spell_id)
    icon:SetPoint('TOPLEFT', opt.main, 'TOPLEFT', module.icon_offset_x, module.icon_offset_y)
    module.icon_offset_x = module.icon_offset_x + module.icon_spacing
    return icon
end