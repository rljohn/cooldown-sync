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

function opt:AddCooldownModule()
    
    module = self:BuildModule("cooldowns")
    module.cooldowns = {}

    function module:init()
        self:TrackCooldowns(opt.PlayerGUID)
    end

    -- tracks cooldowns for a new player
    function module:TrackCooldowns(guid)

        -- early out if already exists
        if self.cooldowns[guid] then 
            return self.cooldowns[guid] 
        end

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
    function module:TrackAbility (guid, info)

        local cds = self:TrackCooldowns(guid)
        if not cds then return end

        -- early out if we're already tracking this one
        local ability = cds.abilities[info.id]
        if ability then return end

        -- add new ability to track
        ability = {}
        ability.spell_id = info.id
        ability.on_cooldown = false
        ability.cd_duration = 0
        ability.time_remaining = 0
        ability.cd_progress = 1.0
        
        -- aura to check instead of spell_id
        if (info.aura) then
            ability.aura = info.aura
        end
        
        -- minimum aura duration
        if (info.min) then
            ability.minimum_duration = info.min
        end

        -- ability estimates
        if (info.dur) then
            ability.aura_estimate = info.dur
        end

        -- cooldown estimates
        if (info.cd) then
            ability.cooldown_estimate = info.cd
        end

        -- start hidden?
        if (info.hidden) then
            ability.start_hidden = info.hidden
        end

        -- partner aura
        if (info.exclusive) then
            ability.exclusive = info.exclusive
        end

        cds.abilities[info.id] = ability
    end

    -- finds the cooldowns that match a player guid
    function module:FindCooldowns(guid)
        return self.cooldowns[guid]
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
    
                    ability.cd_duration = duration
                    ability.time_remaining = cd_remaining
    
                    if not ability.on_cooldown then
                        CDSync_OnCooldownStart(ability, cd_remaining)
                        opt:ModuleEvent_OnCooldownStart(spell_id, start, duration, cd_remaining)
                    end
                    
                    opt:ModuleEvent_OnCooldownUpdate(opt.PlayerGUID, spell_id, start, duration, cd_remaining)
                end
    
                if not on_cooldown and ability.on_cooldown then
                    CDSync_OnCooldownEnd(ability)
                    opt:ModuleEvent_OnCooldownEnd(opt.PlayerGUID, spell_id)
                end
            end
        end
    end

    function module:EstimateCooldown(guid, ability)
        if not ability.cooldown_estimate then return end
        
        cdDiagf('estimating: %d', ability.spell_id)

        local start = GetTime()
        local duration = ability.cooldown_estimate
        local endTime = start + duration
        local cd_remaining = endTime - GetTime()

        CDSync_OnCooldownStart(ability, cd_remaining)
        opt:ModuleEvent_OnCooldownStart(ability.spell_id, start, duration, cd_remaining)
        opt:ModuleEvent_OnCooldownUpdate(guid, ability.spell_id, start, duration, cd_remaining)
    end

    -- do not register CD start/end, we fire those events
    return module
end

