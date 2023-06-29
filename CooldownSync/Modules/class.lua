local opt = CooldownSyncConfig

local function CDSync_OnTalentsChanged(self, spec_id)
    self:ResetCooldowns()
end

local function CDSync_UpdateAbility(self, spell_id, ability)
    if ability.active and ability.icon then
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(spell_id)
        if aura then
            local time_remaining = aura.expirationTime - GetTime()
        
            if (time_remaining < 0) then
                time_remaining = 0
            end
            
            ability.icon:SetAura(time_remaining)
        end
    end
end

local function CDSync_OnAuraGained(self, spell_id)
    local ability = self.cooldowns:GetAbility(spell_id)
    if (ability and ability.icon) then
        ability.icon:Begin()
        CDSync_UpdateAbility(self, spell_id, ability)
    end
end

local function CDSync_OnAuraLost(self, spell_id)
    local ability = self.cooldowns:GetAbility(spell_id)
    if (ability and ability.icon) then
        ability.icon:End()
    end
end

local function CDSync_UpdateAuras(self)
    for spell_id, ability in pairs(self.cooldowns.abilities) do
        CDSync_UpdateAbility(self, spell_id, ability)
    end
end

local function CDSync_Update(self)
    CDSync_UpdateAuras(self)
end

local function CDSync_OnCooldownUpdated(self, spell_id, start, duration, time_remaining, percent)
    local ability = self.cooldowns:GetAbility(spell_id)
    if (ability and ability.icon) then
        ability.icon:SetCooldown(start, duration, percent)
    end
end

function opt:BuildClassModule(name)
    
    module = self:BuildModule(name)
    module.cooldowns = self:GetModule("cooldowns")
    
    -- build cooldown icons
    module.padding = 8
    module.icon_offset_x = 8
    module.icon_offset_y = -8
    module.icon_spacing = opt.env.IconSize + 8

    -- events
    module.talents_changed = CDSync_OnTalentsChanged
    module.cooldown_update = CDSync_OnCooldownUpdated
    module.aura_gained = CDSync_OnAuraGained
    module.aura_lost = CDSync_OnAuraLost
    module.update = CDSync_Update
    
    -- buddy auras
    module.buddy_widgets = {}

    -- setup abilities
    function module.SetupAbilities(self)

        -- create icons for each ability
        local abilities = opt:GetSpecInfo(opt.PlayerClass, opt.PlayerSpec)

        local header = opt.main:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        header:SetPoint('TOPLEFT', opt.main, 'TOPLEFT', module.icon_offset_x, module.icon_offset_y)
        header:SetText(opt.PlayerName)
        module.icon_offset_y = module.icon_offset_y - 16
        module.other_buddies_start = module.icon_offset_y - opt.env.IconSize

        -- create ability icons
        for index, ability in opt:pairsByKeys ( abilities ) do
            local spell_id = ability[1]
            module.cooldowns:TrackAbility(spell_id)
            local icon = opt:AddAbilityCooldownIcon(module, spell_id)
            module.cooldowns:AddIcon(spell_id, icon)
        end

        -- check initial aura state
        module.cooldowns:CheckAuras()
    end

    -- reset
    function module.ResetCooldowns(self)
        self.icon_offset_x = 8
        self.icon_offset_y = -8
        self.cooldowns:Reset()

        -- todo - only player icons
        opt:ResetCooldownIcons()

        self:SetupAbilities()
    end

    function module.buddy_available(self, buddy)

        local display = {}
        display.header = opt.main:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
        display.header:SetPoint('TOPLEFT', opt.main, 'TOPLEFT', module.padding_x, module.padding_y)
        display.header:SetText(buddy.name)

        display.cooldowns = {}
        self.buddy_widgets[buddy.guid] = display
    end

    function module.buddy_unavailable(self, buddy)
        if not buddy_widgets[buddy.guid] then return end

        local display = buddy_widgets[buddy.guid]
        for spell_id, icon in pairs(display.cooldowns) do
            icon:Reset()
        end

        buddy_widgets[buddy.guid] = nil
    end

    function module.buddy_spec_changed(self, buddy)
        
        local display = self.buddy_widgets[buddy.guid]
        if not display then return end
        
        if display.cooldowns then
            for spell_id, icon in pairs(display.cooldowns) do
                icon:Reset()
            end
        end

        cdPrintf("getting specic info for %s,%s", buddy.class_id, buddy.spec)

        local abilities = opt:GetSpecInfo(buddy.class_id, buddy.spec)
        if not abilities then end

        -- create ability icons
        for index, ability in opt:pairsByKeys ( abilities ) do
            local spell_id = ability[1]
            module.cooldowns:TrackAbility(spell_id)
            local icon = opt:AddAbilityCooldownIcon(module, spell_id)
            module.cooldowns:AddIcon(spell_id, icon)
        end

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