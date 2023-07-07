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
            row.icon_offset_x = 0
            row.icon_offset_y = -16

            previous = row

            for _, icon in pairs(row.icons) do
                icon:SetPoint('TOPLEFT', row, 'TOPLEFT', row.icon_offset_x, row.icon_offset_y)
                if not icon.hidden then
                    row.icon_offset_x = row.icon_offset_x + row.icon_spacing
                end
            end
            
        end
    end

    -- events
    function module:talents_changed()
        self:ResetCooldowns()
    end

    function module:cooldown_update(guid, spell_id, start, duration, time_remaining)
        cdDiagf("cooldown_update: %d (%s) - %d, %d, %f", spell_id, guid, start, duration, time_remaining)

        local ability = self.cooldowns:GetAbility(guid, spell_id)
        if (ability and ability.icon) then
            ability.icon:SetCooldown(start, duration)
        end
    end

    ------------------
    -- ACTIVE STATE
    ------------------

    function module:SetAbilityActive(guid, ability)
        if ability.active then return end

        ability.start_time = GetTime()
        ability.active = true
        if (ability.icon) then

            -- show if this ability is hidden
            if ability.icon.hidden then
                ability.icon:Show()
                ability.icon.hidden = false
            end

            -- hide its exclusive partner
            if ability.exclusive then
                local other = self.cooldowns:GetAbility(guid, ability.exclusive)
                if other then
                    if other.icon and not other.hidden then
                        other.icon.hidden = true
                        other.icon:Hide()
                        self:align_bars()
                    end
                end
            end

            ability.icon:Begin()
        end
    end

    function module:ClearAbilityActive(ability)
        if not ability.active then return end

        ability.start_time = 0
        ability.active = false

        if (ability.icon) then
            ability.icon:End()
        end
    end

    ------------------
    -- SPELL CAST
    ------------------

    function module:HandleSpellCast(guid, spell_id)
        local ability = self.cooldowns:GetAbility(guid, spell_id)
        if not ability then return nil end
        if ability.active then return nil end

        if ability.aura_estimate then
            self:SetAbilityActive(guid, ability)
        end

        return ability
    end

    function module:spell_cast(spell_id, target_guid, target_name)
        local ability = self:HandleSpellCast(opt.PlayerGUID, spell_id)
        
        if ability then
            self:UpdatePlayerAbility(spell_id, ability)
        end
    end

    function module:other_spell_cast(spell_id, source_guid, source_name, target_guid, target_name)
        local buddy = self.buddy:FindBuddyByGuid(source_guid)
        if not buddy then return end

        cdPrintf("OnOtherSpellCast: %d from %s (%s) to %s (%s)", spell_id, source_name, source_guid, target_name, target_guid)

        local ability = self:HandleSpellCast(source_guid, spell_id)
        if ability then
            self:UpdateOtherPlayerAbility(spell_id, ability)
            self.cooldowns:EstimateCooldown(source_guid, ability)
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
        self:SetAbilityActive(guid, ability)
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

        cdPrintf("OnOtherAuraGained: %d (%s)", spell_id, n)

        local ability = self:HandleAuraGained(guid, spell_id)
        if ability then
            self:UpdateOtherPlayerAbility(ability)
            self.cooldowns:EstimateCooldown(guid, ability)
        end
    end

    ------------------
    -- AURA LOST
    ------------------

    function module:HandleAuraLost(guid, spell_id)
        local ability = self.cooldowns:GetAbility(guid, spell_id)
        if not ability then return end
        if not ability.active then return end

        if not ability.aura_estimate then
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

    function module:UpdatePlayerAbility(spell_id, ability)
        if not ability then return end
        if not ability.active then return end

        local time_remaining = 0

        if ability.aura_estimate then
            local expirationTime = ability.start_time + ability.aura_estimate
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

    function module:UpdateOtherPlayerAbility(unitId, spell_id, ability)
        if not ability then return end
        if not ability.active then return end

        local time_remaining = 0

        if ability.aura_estimate then
            local expirationTime = ability.start_time + ability.aura_estimate
            time_remaining = expirationTime - GetTime()
            if (time_remaining < 0) then
                ability.icon:End()
            end
        else
            time_remaining = opt:GetAuraDuration(unitId, spell_id)
        end

        if (ability.icon) then
            ability.icon:SetAura(time_remaining)
        end
    end

    -- refresh aura timings
    function module:UpdatePlayerAuras()
        local cds = self.cooldowns:FindCooldowns(opt.PlayerGUID)
        if not cds then return end

        for spell_id, ability in pairs(cds.abilities) do
           self:UpdatePlayerAbility(spell_id, ability)
        end
    end

    -- other player timings
    function module:UpdateBuddyAuras()
        for id, row in pairs(self.buddy_rows) do
            local buddy = self.buddy:FindBuddy(id)
            if buddy then
                local cds = self.cooldowns:FindCooldowns(buddy.guid)
                if (cds) then
                    for spell_id, ability in pairs(cds.abilities) do
                        self:UpdateOtherPlayerAbility(buddy.unit_id, spell_id, ability)
                    end
                end
            end
        end
    end

    function module:update()
        self:UpdatePlayerAuras()
        self:UpdateBuddyAuras()
    end

    function module:CreateAbilityRow(n)
        local row = opt:CreateAbilityRow(opt.main, nil, 400, 64, n)
        row.icon_offset_x = 0
        row.icon_offset_y = -16
        row.icon_spacing = module.icon_spacing
        row.icons = {}
        return row
    end

    function module:SetupAbilityRow(row, guid, class, spec, race, player)

        -- create icons for each ability
        local abilities = opt:GetSpecInfo(class, spec)
        if abilities then

            -- create ability icons
            for index, info in opt:pairsByKeys ( abilities ) do

                module.cooldowns:TrackAbility(guid, info)

                local icon = opt:AddAbilityCooldownIcon(row, info.id, info.hidden)

                cdDiagf('trace')
                cdDump(row)

                table.insert(row.icons, icon)

                module.cooldowns:AddIcon(guid, info.id, icon)

                if info.hidden then
                    icon.hidden = true
                    icon:Hide()
                    self:align_bars()
                end
            end

        end

        -- racial
        local racial = opt:GetRacialAbility(race)
        if racial then

            local info = racial[1]
            module.cooldowns:TrackAbility(guid, info)

            local icon = opt:AddAbilityCooldownIcon(row, info.id, info.hidden)
            module.cooldowns:AddIcon(guid, info.id, icon)
            table.insert(row.icons, icon)

        end

        return row

    end

    --------------------
    -- SETUP
    --------------------
    
    function module:CheckPlayerAuras()
        local cds = self.cooldowns:FindCooldowns(opt.PlayerGUID)
        if not cds then return end
        for spell_id, ability in pairs(cds.abilities) do
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(spell_id)
            if (aura) then
                opt:ModuleEvent_OnAuraGained(spell_id, opt.PlayerGUID, opt.PlayerName)
            end
        end
    end

    function module:SetupAbilities()

        local row = self:CreateAbilityRow(opt.PlayerName)
        self:SetupAbilityRow(row, opt.PlayerGUID, opt.PlayerClass, opt.PlayerSpec, opt.PlayerRace, true)

        self.player = row
        self:align_bars()

        -- check initial aura state
        self:CheckPlayerAuras()
        self.cooldowns:cooldowns_updated()
    end

    --------------------
    -- RESET
    --------------------

    function module:ResetCooldowns()
        self.cooldowns:Reset()
        opt:ResetCooldownIcons()
        self:SetupAbilities()
    end

    --------------------
    -- BUDDIES
    --------------------

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
            self:SetupAbilityRow(row, buddy.guid, buddy.class, buddy.spec, buddy.race, false)
        end

        self:align_bars()
    end
    
    return module
end

function opt:AddAbilityCooldownIcon(parent, spell_id, hidden)
    local icon = opt:CreateCooldownIcon(parent, spell_id)
    icon:SetPoint('TOPLEFT', parent, 'TOPLEFT', parent.icon_offset_x, parent.icon_offset_y)

    if not hidden then
        parent.icon_offset_x = parent.icon_offset_x + parent.icon_spacing
    end

    return icon
end