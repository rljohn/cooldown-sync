local opt = CooldownSyncConfig

function opt:BuildClassModule(name)
    
    module = self:BuildModule(name)
    module.cooldowns = self:GetModule("cooldowns")
    module.buddy = self:GetModule("buddy")
    
    module.player = nil
    module.buddy_rows = {}

    local frame_margin_x = 8
    local frame_margin_y = -8
    local frame_spacing_y = -8

    -- build cooldown icons
    module.icon_spacing = opt.env.IconSize + 8

    -- ui

    function module:align_bars()
        if not self.player then return end

        local previous = opt.main
        module.player:SetPoint('TOPLEFT', previous, 'TOPLEFT', frame_margin_x, frame_margin_y)
        previous = module.player

        for key, row in pairs(self.buddy_rows) do
            row:SetPoint('TOPLEFT', previous, 'BOTTOMLEFT', 0, frame_spacing_y)
            previous = row
        end
    end

    -- events
    function module:talents_changed()
        self:ResetCooldowns()
    end

    function module:cooldown_update(spell_id, start, duration, time_remaining, percent)
        local ability = self.cooldowns:GetAbility(spell_id)
        if (ability and ability.icon) then
            ability.icon:SetCooldown(start, duration, percent)
        end
    end

    function module:aura_gained(spell_id)
        local ability = self.cooldowns:GetAbility(spell_id)
        if (ability and ability.icon) then
            ability.icon:Begin()
            self:UpdateAbility(spell_id, ability)
        end
    end

    function module:aura_lost(spell_id)
        local ability = self.cooldowns:GetAbility(spell_id)
        if (ability and ability.icon) then
            ability.icon:End()
        end
    end

    function module:UpdateAbility(spell_id, ability)
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

    function module:UpdateAuras()
        for spell_id, ability in pairs(self.cooldowns.abilities) do
            self:UpdateAbility(spell_id, ability)
        end
    end

    function module:update()
        self:UpdateAuras()
    end

    function module:CreateAbilityRow(name)
        local row = opt:CreateAbilityRow(opt.main, nil, 400, 64, name)
        row.icon_offset_x = 0
        row.icon_offset_y = -16
        row.icon_spacing = module.icon_spacing
        return row
    end

    function module:SetupAbilityRow(row, class, spec, race, player)

        -- create icons for each ability
        local abilities = opt:GetSpecInfo(class, spec)
            if abilities then

            -- create ability icons
            for index, ability in opt:pairsByKeys ( abilities ) do
                local spell_id = ability[1]
                if player then
                    module.cooldowns:TrackAbility(spell_id)
                end
                local icon = opt:AddAbilityCooldownIcon(row, module, spell_id)
                if player then
                    module.cooldowns:AddIcon(spell_id, icon)
                end
            end
        end

        -- racial
        local racial = opt:GetRacialAbility(race)
        if racial then
            local spell_id = racial[1]
            module.cooldowns:TrackAbility(spell_id)

            local icon = opt:AddAbilityCooldownIcon(row, module, spell_id)
            module.cooldowns:AddIcon(spell_id, icon)
        end

        return row

    end

    -- setup abilities
    function module:SetupAbilities()

        local row = self:CreateAbilityRow(opt.PlayerName)
        self:SetupAbilityRow(row, opt.PlayerClass, opt.PlayerSpec, opt.PlayerRace, true)

        self.player = row
        self:align_bars()

        -- check initial aura state
        self.cooldowns:CheckAuras()
    end

    -- reset
    function module:ResetCooldowns()
        self.cooldowns:Reset()
        opt:ResetCooldownIcons()
        self:SetupAbilities()
    end

    -- buddy settings
    function module:buddy_available(buddy)
        local row = self:CreateAbilityRow(buddy.name)
        self.buddy_rows[buddy.id] = row
        self:align_bars()
    end
    
    function module:buddy_unavailable(buddy)
        self.buddy_rows[buddy.id] = nil
        self:align_bars()
    end

    function module:buddy_spec_changed(buddy)

        local row = self.buddy_rows[buddy.id]
        if row then
            cdDump(buddy)
            self:SetupAbilityRow(row, buddy.class, buddy.spec, buddy.race, false)
        end

        self:align_bars()
    end
    
    module:SetupAbilities()
    return module
end

function opt:AddAbilityCooldownIcon(parent, module, spell_id)
    local icon = opt:CreateCooldownIcon(parent, spell_id)
    icon:SetPoint('TOPLEFT', parent, 'TOPLEFT', parent.icon_offset_x, parent.icon_offset_y)
    parent.icon_offset_x = parent.icon_offset_x + parent.icon_spacing
    return icon
end