local opt = CooldownSyncConfig

local function CDSync_OnCooldownStart(ability, duration, time_remaining, progress)
    if not ability then return end
    ability.on_cooldown = true
    ability.cd_duration = duration
    ability.time_remaining = time_remaining
    ability.cd_progress = progress
end

local function CDSync_OnCooldownEnd(ability)
    if not ability then return end
    ability.on_cooldown = false
    ability.cd_duration = 0
    ability.time_remaining = 0
    ability.cd_progress = 1.0
end

function opt:CalculateCooldownPercent(duration, time_remaining)
    if duration == 0 then
        return 1.0
    end

    local percent = opt:Clamp(time_remaining / duration, 0.0, 1.0)
    return percent
end

function opt:AddCooldownModule()
    
    module = self:BuildModule("cooldowns")
    module.cooldowns = {}

    function module:init()
        self:TrackCooldowns(opt.PlayerGUID)
    end

    -- tracks cooldowns for a new player
    function module:TrackCooldowns(guid)
        if self.cooldowns[guid] then return self.cooldowns[guid] end

        -- add cooldowns module
        local cds = {}
        cds.abilities = {}
        self.cooldowns[guid] = cds
        return cds
    end

    -- remove tracking from this player
    function module:UntrackCooldowns(guid)
        if not self.cooldowns[guid] then return end
        self.cooldowns[guid] = nil
    end

    -- begin tracking this ability for this player
    function module:TrackAbility (guid, spell_id)

        local cds = self:TrackCooldowns(guid)
        if not cds then return end

        -- early out if we're already tracking this one
        local ability = cds.abilities[spell_id]
        if ability then return end

        -- add new ability to track
        ability = {}
        ability.on_cooldown = false
        ability.cd_duration = 0
        ability.time_remaining = 0
        ability.cd_progress = 1.0
        cds.abilities[spell_id] = ability
    end

    -- finds the cooldowns that match a player guid
    function module:FindCooldowns(guid)
        return self.cooldowns[guid]
    end

    -- refresh player auras
    function module:CheckPlayerAuras()
        local cds = self:FindCooldowns(opt.PlayerGUID)
        if not cds then return end
        for spell_id, ability in pairs(cds.abilities) do
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(spell_id)
            if (aura) then
                opt:ModuleEvent_OnAuraGained(spell_id, opt.PlayerGUID, opt.PlayerName)
            end
        end
    end

    -- refresh aura timings
    function module:UpdatePlayerAuras()
        local cds = self:FindCooldowns(opt.PlayerGUID)
        if not cds then return end

        for spell_id, ability in pairs(cds.abilities) do
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
    end

    -- lookup player and spell
    function module:GetAbility(guid, spell_id)
        local cds = self:FindCooldowns(guid)
        if not cds then return nil end
        return cds.abilities[spell_id]
    end

    -- lookup player, find ability by spellid and update icon
    function module:AddIcon(guid, spell_id, icon)
        local ability = self:GetAbility(guid, spell_id)
        if not ability then return end
        ability.icon = icon
    end

    -- resets the cooldowns array
    function module:Reset()
        self.cooldowns = {}
    end

    -- lookup the player by guid, set matching cooldown's active state
    function module:SetAuraActive(guid, spell_id, active)
        local ability = self:GetAbility(guid, spell_id)
        if not ability then return end
        ability.active = active
    end

    -- local player gained aura event
    function module:aura_gained(spell_id)
        self:SetAuraActive(opt.PlayerGUID, spell_id, true)
    end

    -- other player gained aura event
    function module:other_aura_gained(guid, spell_id)
        self:SetAuraActive(guid, spell_id, true)
    end

    -- player lost aura event
    function module:aura_lost(spell_id)
        self:SetAuraActive(opt.PlayerGUID, spell_id, false)
    end

    -- other player lost aura event
    function module:other_aura_lost(guid, spell_id)
        self:SetAuraActive(guid, spell_id, false)
    end

    function module:cooldowns_updated()
        
        local cds = self:FindCooldowns(opt.PlayerGUID)
        if not cds then return end

        for spell_id, ability in pairs(cds.abilities) do

            -- get CD from API
            local start, duration, enabled = GetSpellCooldown(spell_id);
    
            -- verify its not just the GCD
            -- if we think its the GCD, just bail. catch this next frame.
            local on_cooldown = (start > 0) and (enabled == 1)
            local on_gcd_cooldown = false
    
            if (on_cooldown) then
    
                local _, gcd_duration, _ = GetSpellCooldown(61304)
                if (duration > 0 and duration == gcd_duration) then
                    on_cooldown = false
                    on_gcd_cooldown = true
                end
    
            end
    
            -- ignoring the GCD cd
            if not on_gcd_cooldown then
                if on_cooldown then
    
                    local endTime = start + duration
                    local cd_remaining = endTime - GetTime()
    
                    local percent = opt:CalculateCooldownPercent(duration, cd_remaining)
                    ability.cd_duration = duration
                    ability.time_remaining = cd_remaining
                    ability.cd_progress = percent
    
                    if not ability.on_cooldown then
                        CDSync_OnCooldownStart(ability, cd_remaining)
                        opt:ModuleEvent_OnCooldownStart(spell_id, start, duration, cd_remaining, percent)
                    end
                    
                    opt:ModuleEvent_OnCooldownUpdate(opt.PlayerGUID, spell_id, start, duration, cd_remaining, percent)
                end
    
                if not on_cooldown and ability.on_cooldown then
                    CDSync_OnCooldownEnd(ability)
                    opt:ModuleEvent_OnCooldownEnd(opt.PlayerGUID, spell_id)
                end
            end
        end
    end

    -- do not register CD start/end, we fire those events
    return module
end

