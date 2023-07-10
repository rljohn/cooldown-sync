local opt = CooldownSyncConfig

function opt:BuildClassModule(name)
    
    module = self:BuildModule(name)
    module.cooldowns = self:GetModule("cooldowns")
    module.buddy = self:GetModule("buddy")
    
    module.player = nil
    module.buddy_rows = {}
    module.recycled_rows = {}

    local frame_margin_x = 12
    local frame_margin_y = 12

    local frame_spacing_y = 12
    local frame_spacing_x = 8

    local icon_offset_y = 16
    local min_width = 88

    -- ui

    function module:init()
        self:SetupAbilities()
    end

    -- resets icon positions
    -- TODO: Instead of row offsets, just offset to the previous icon
    function module:AlignIcons()
        
        -- player row is anchored to the main frame
        local previous = opt.main
        self.player:SetPoint('TOPLEFT', previous, 'TOPLEFT', frame_margin_x, -frame_margin_y + 2)
        self.player.icon_offset_x = 0
        self.player.icon_offset_y = -icon_offset_y
        self.player.icon_spacing = opt.env.IconSize + frame_spacing_x

        -- re-anchor the icons
        for _,icon in pairs(self.player.icons) do
            icon:SetPoint('TOPLEFT', self.player, 'TOPLEFT', self.player.icon_offset_x, self.player.icon_offset_y)
            if not icon.hidden then
                self.player.icon_offset_x = self.player.icon_offset_x + self.player.icon_spacing
            end
        end

        previous = module.player

        -- buddy rows are anchored to the player, and then the previous row
        for key, row in pairs(self.buddy_rows) do

            row:SetPoint('TOPLEFT', previous, 'BOTTOMLEFT', 0, -frame_spacing_y)
            row.icon_offset_x = 0
            row.icon_offset_y = -icon_offset_y
            row.icon_spacing = opt.env.IconSize + frame_spacing_x

            -- re-align the columns
            for _, icon in pairs(row.icons) do
                icon:SetPoint('TOPLEFT', row, 'TOPLEFT', row.icon_offset_x, row.icon_offset_y)
                if not icon.hidden then
                    row.icon_offset_x = row.icon_offset_x + row.icon_spacing
                end
            end
            
            previous = row
        end
    end

    function module:align_bars()
        if not self.player then return end

        -- resize each row and icon
        self:ResizeFrames()

        -- re-align icons in each row
        self:AlignIcons()

        -- from the results, reset the main frame size
        self:ResizeMainFrame()
    end

    function module:ResizeFrames()

        -- iterate through the icons.
        -- count the non-hidden ones so we can calculate row size
        local count = 0
        for _, icon in pairs(self.player.icons) do
            icon.spell:SetSize(opt.env.IconSize, opt.env.IconSize)
            if not icon.hidden then
                count = count + 1
            end
        end

        -- pretend at least two icons is present
        if count <= 2 then count = 2 end
        local width = count * (opt.env.IconSize + frame_spacing_x)
        local height = opt.env.IconSize + icon_offset_y
        self.player:SetSize(width, height)

        -- resize buddy frames
        for key, row in pairs(self.buddy_rows) do
            count = 0

            -- resize each icon
            for _, icon in pairs(row.icons) do
                icon.spell:SetSize(opt.env.IconSize, opt.env.IconSize)
                if not icon.hidden then
                    count = count + 1
                end
            end

            -- pretend at least two icons are present
            if count <= 2 then count = 2 end

            -- resize the row
            width = count * (opt.env.IconSize + frame_spacing_x)
            height = opt.env.IconSize + icon_offset_y
            row:SetSize(width, height)
        end
    end

    function module:on_resize()
        self:align_bars()
    end

    function module:ResizeMainFrame()
        if (opt.main == nil) then return end

        local max_header_len = self.player.header:GetWidth() + (2*frame_spacing_x)

        -- the player row is always present
        local rows = 1
        local columns = 0
        for _, icon in pairs(self.player.icons) do
            if not icon.hidden then
                columns = columns + 1
            end
        end
        -- pretend at least two icons is present
        if columns <= 2 then columns = 2 end
        local max_columns = columns

        -- iterate through all buddy rows
        for key, row in pairs(self.buddy_rows) do
            
            if row.header then
                local len = row.header:GetWidth() + (2*frame_spacing_x)
                if (len > max_header_len) then
                    max_header_len = len
                end
            end

            columns = 0

            -- count the number of non-hidden columns
            for _, icon in pairs(row.icons) do
                if not icon.hidden then
                    columns = columns + 1
                end
            end

            -- pretend at least two icons are present
            if columns <= 2 then columns = 2 end

            -- check if this is the widest frame
            if (columns > max_columns) then
                max_columns = columns
            end

            -- increment rows
            rows = rows + 1
        end

        local min_height = 60

        -- require some minimum dimensions

        local new_width = (frame_margin_x) + (max_columns * (opt.env.IconSize + frame_spacing_x)) + (frame_margin_x-frame_spacing_x)
        if (new_width < min_width) then new_width = min_width end

        local new_height = (frame_margin_y) + (rows * (opt.env.IconSize + icon_offset_y + frame_spacing_y)) + (frame_margin_y-frame_spacing_y)
        if (new_height < min_height) then new_height = min_height end

        -- ensure the main header has room
        if opt.env.ShowTitle then
            local title_width = opt.main.header:GetWidth()
            if title_width > new_width then
                new_width = title_width + frame_margin_x
            end
        end
        -- ensure the player headers have room
        if max_header_len > new_width then
            new_width = max_header_len
        end

        opt.main:SetSize(new_width, new_height)
    end

    -- events
    function module:talents_changed(unit_id)
        if (unit_id == "player") then
            self:ResetPlayerCooldowns()
        end
    end

    function module:cooldown_update(guid, spell_id, start, duration, time_remaining)
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
        if not ability then
            ability = self.cooldowns:FindAbilityBySecondaryAura(guid, spell_id)
            if not ability then return nil end
        end

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
        if not ability then
            ability = self.cooldowns:FindAbilityBySecondaryAura(guid, spell_id)
            if not ability then return nil end
        end

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

            -- allow aura override
            local id
            if ability.aura then
                id = ability.aura
            else
                id = spell_id
            end
            
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(id)
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
            -- allow aura override
            local id
            if ability.aura then
                id = ability.aura
            else
                id = spell_id
            end

            time_remaining = opt:GetAuraDuration(unitId, id)
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

    ------------------------------
    -- update loop
    ------------------------------

    function module:update()
        self:UpdatePlayerAuras()
        self:UpdateBuddyAuras()
    end

    ------------------------------
    -- Ability Rows
    ------------------------------

    function module:FindInactiveRow()

        for key, row in pairs(self.recycled_rows) do
            self.recycled_rows[key] = nil
            row:Show()
            return row
        end
    
        return nil
    end

    function module:CreateAbilityRow(n)
        local row = self:FindInactiveRow()
        if not row then
           row = opt:CreateAbilityRow(opt.main, nil, 400, 64, n)
        else
            row.header:Show()
        end
        row.icon_offset_x = 0
        row.icon_offset_y = -16
        row.icon_spacing = opt.env.IconSize + frame_spacing_x
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

            -- allow aura override
            local id
            if ability.aura then
                id = ability.aura
            else
                id = spell_id
            end

            local aura = C_UnitAuras.GetPlayerAuraBySpellID(id)
            if (aura) then
                opt:ModuleEvent_OnAuraGained(spell_id, opt.PlayerGUID, opt.PlayerName)
            end
        end
    end

    function module:SetupAbilities()

        local row = self:CreateAbilityRow(opt.PlayerName)
        self:SetupAbilityRow(row, opt.PlayerGUID, opt.PlayerClass, opt.PlayerSpec, opt.PlayerRace, true)
        self.player = row

        -- setup bar alignment
        self:align_bars()

        -- check initial aura state
        self:CheckPlayerAuras()
        self.cooldowns:cooldowns_updated()
    end

    --------------------
    -- RESET
    --------------------

    function module:ResetPlayerCooldowns()
       
        local cds = self.cooldowns:FindCooldowns(opt.PlayerGUID)
        cds:Reset()
  
        -- clear all icons
         for _, icon in pairs(self.player.icons) do
            opt:RecycleIcon(icon)
        end
        self.player.icons = {}

        -- reconfigure ability tracking
        self:SetupAbilityRow(self.player, opt.PlayerGUID, opt.PlayerClass, opt.PlayerSpec, opt.PlayerRace, true)
        self:align_bars()
        self:CheckPlayerAuras()
        self.cooldowns:cooldowns_updated()
    end

    function module:ClearBuddyCooldowns(buddy)
        local cds = self.cooldowns:FindCooldowns(buddy.guid)
        if cds then
            cds:Reset()
        end

        local row = self.buddy_rows[buddy.id]
        if not row then return end

        -- clear all icons
        for _, icon in pairs(row.icons) do
            opt:RecycleIcon(icon)
        end
        row.icons = {}

        row.icon_offset_x = 0
    end

    --------------------
    -- BUDDIES
    --------------------

    function module:buddy_available(buddy)
        local row = self:CreateAbilityRow(buddy.name)
        self.buddy_rows[buddy.id] = row
        self:align_bars()
    end
    
    function module:RecycleBuddyRow(row)
        if not row then return end
        for _, icon in pairs(row.icons) do
            opt:RecycleIcon(icon)
        end
        row.icons = {}

        row:Hide()
        row.header:Hide()
        table.insert(self.recycled_rows, row)
    end

    function module:buddy_unavailable(buddy)
        self:RecycleBuddyRow(self.buddy_rows[buddy.id])
        self.buddy_rows[buddy.id] = nil
        self:align_bars()
    end

    function module:buddy_spec_changed(buddy)

        local cds = self.cooldowns:FindCooldowns(buddy.guid)
        if cds then
            cds:Reset()
        end

        local row = self.buddy_rows[buddy.id]
        if row then
            if buddy.spec == 0 then
                self:ClearBuddyCooldowns(buddy)
            else
                self:ClearBuddyCooldowns(buddy)
                self:SetupAbilityRow(row, buddy.guid, buddy.class, buddy.spec, buddy.race, false)
            end
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