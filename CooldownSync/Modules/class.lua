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

    function module:init()
        cdPrintf("Module (%s) initialized", self.name)
        self:SetupAbilities()
    end

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

    function module:cooldown_update(guid, spell_id, start, duration, time_remaining, percent)
        local ability = self.cooldowns:GetAbility(guid, spell_id)
        if (ability and ability.icon) then
            ability.icon:SetCooldown(start, duration, percent)
        end
    end

    ------------------
    -- ACTIVE STATE
    ------------------

    function module:SetAbilityActive(ability, spell_id)
        ability.start_time = GetTime()
        ability.active = true
        if (ability.icon) then
            ability.icon:Begin()
        end
    end

    function module:ClearAbilityActive(ability)

        ability.start_time = 0
        ability.active = false

        if (ability.icon) then
            ability.icon:End()
        end
    end

    ------------------
    -- SPELL CAST
    ------------------

    function module:spell_cast(spell_id, target_guid, target_name)
        local ability = self.cooldowns:GetAbility(opt.PlayerGUID, spell_id)
        if not ability then return end
        if ability.active then return end

        -- begin an estimate for this spell
        if ability.estimate_duration then
            self:SetAbilityActive(ability)
            self:UpdatePlayerAbility(spell_id, ability)
        end
    end

    ------------------
    -- AURA GAINED
    ------------------

    function module:HandleAuraGained(guid, spell_id)
        local ability = self.cooldowns:GetAbility(guid, spell_id)
        if not ability then return nil end
        if ability.active then return nil end

        -- trigger the active state
        self:SetAbilityActive(ability)
        return ability
    end

    function module:aura_gained(spell_id)
        local ability = self:HandleAuraGained(opt.PlayerGUID, spell_id)
        if ability then
            self:UpdatePlayerAbility(spell_id, ability)
        end
    end

    function module:other_aura_gained (spell_id, guid, n)
        local buddy = self.buddy:FindBuddyByGuid(guid)
        if not buddy then return end

        local ability = self:HandleAuraGained(opt.PlayerGUID, spell_id)
        if ability then
            self:UpdateOtherPlayerAbility(ability)
        end
    end

    ------------------
    -- AURA LOST
    ------------------

    function module:HandleAuraLost(guid, spell_id)
        local ability = self.cooldowns:GetAbility(guid, spell_id)
        if not ability then return end
        if not ability.active then return end

        if not ability.estimate_duration then
            self:ClearAbilityActive(ability)
        end
    end

    function module:aura_lost(spell_id)
        self:HandleAuraLost(opt.PlayerGUID, spell_id)
    end

    function module:other_aura_lost (spell_id, guid, n)
        local buddy = self.buddy:FindBuddyByGuid(guid)
        if not buddy then return end

        self:HandleAuraLost(guid, spell_id)
    end

    ------------------
    -- AURA UPDATE
    ------------------

    -- refresh aura timing
    function module:UpdatePlayerAbility(spell_id, ability)
        if not ability then return end
        if not ability.active then return end

        local time_remaining = 0

        if ability.estimate_duration then
            local expirationTime = ability.start_time + ability.estimate_duration
            time_remaining = expirationTime - GetTime()
            if (time_remaining < 0) then
                ability.icon:End()
            end
        else
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(spell_id)
            if aura then
                time_remaining = aura.expirationTime - GetTime()
            end
        end

        if (time_remaining < 0) then
            time_remaining = 0
        end
        
        if (ability.icon) then
            ability.icon:SetAura(time_remaining)
        end
    end

    function module:UpdateOtherPlayerAbility(spell_id, ability)
        if not ability then return end
        if not ability.active then return end
    end

    -- refresh aura timings
    function module:UpdatePlayerAuras()
        local cds = self.cooldowns:FindCooldowns(opt.PlayerGUID)
        if not cds then return end

        for spell_id, ability in pairs(cds.abilities) do
           self:UpdatePlayerAbility(spell_id, ability)
        end
    end

    function module:update()
        self:UpdatePlayerAuras()
    end

    function module:CreateAbilityRow(n)
        local row = opt:CreateAbilityRow(opt.main, nil, 400, 64, n)
        row.icon_offset_x = 0
        row.icon_offset_y = -16
        row.icon_spacing = module.icon_spacing
        return row
    end

    function module:SetupAbilityRow(row, guid, class, spec, race, player)

        -- create icons for each ability
        local abilities = opt:GetSpecInfo(class, spec)
            if abilities then

            -- create ability icons
            for index, ability in opt:pairsByKeys ( abilities ) do
                local spell_id = ability[1]

                module.cooldowns:TrackAbility(guid, spell_id)
                local icon = opt:AddAbilityCooldownIcon(row, module, spell_id)
                module.cooldowns:AddIcon(guid, spell_id, icon)
            end
        end

        -- racial8
        local racial = opt:GetRacialAbility(race)
        if racial then
            local spell_id = racial[1]
            module.cooldowns:TrackAbility(guid, spell_id)

            local icon = opt:AddAbilityCooldownIcon(row, module, spell_id)
            module.cooldowns:AddIcon(guid, spell_id, icon)
        end

        return row

    end

    -- setup abilities
    function module:SetupAbilities()

        local row = self:CreateAbilityRow(opt.PlayerName)
        self:SetupAbilityRow(row, opt.PlayerGUID, opt.PlayerClass, opt.PlayerSpec, opt.PlayerRace, true)

        self.player = row
        self:align_bars()

        -- check initial aura state
        self.cooldowns:CheckPlayerAuras()
        self.cooldowns:cooldowns_updated()
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
            self:SetupAbilityRow(row, buddy.guid, buddy.class, buddy.spec, buddy.race, false)
        end

        self:align_bars()
    end
    
    return module
end

function opt:AddAbilityCooldownIcon(parent, module, spell_id)
    local icon = opt:CreateCooldownIcon(parent, spell_id)
    icon:SetPoint('TOPLEFT', parent, 'TOPLEFT', parent.icon_offset_x, parent.icon_offset_y)
    parent.icon_offset_x = parent.icon_offset_x + parent.icon_spacing
    return icon
end