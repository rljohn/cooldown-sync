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
        cds.secondary_auras = {}
        self.cooldowns[guid] = cds

        function cds:Reset()
            self.abilities = {}
            self.secondary_auras = {}
        end

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

        -- add the alternate aura lookup
        if (info.aura) then
            ability.aura = info.aura
            cds.secondary_auras[info.aura] = ability
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

    -- lookup player by their alternate aura
    function module:FindAbilityBySecondaryAura(guid, aura_id)
        local cds = self:FindCooldowns(guid)
        if not cds then return nil end
        return cds.secondary_auras[aura_id]
    end

    -- lookup player, find ability by spellid and update icon
    function module:AddIcon(guid, spell_id, icon)
        local ability = self:GetAbility(guid, spell_id)
        if not ability then return end
        ability.icon = icon
    end

    function module:BlessingOfSeasonsHelper(guid, spell_id)
        if (spell_id == 388007 or spell_id == 388010 or
            spell_id == 388011 or spell_id == 388013) then
            local ability = self:GetAbility(guid, 388007)
            if ability then
                 -- summer -> autumn
                if spell_id == 388007 then
                    ability.icon.spell.texture:SetTexture(GetSpellTexture(388010))
                -- autumn -> winter
                elseif spell_id == 388010 then
                    ability.icon.spell.texture:SetTexture(GetSpellTexture(388011))
                -- winter -> spring
                elseif spell_id == 388011 then
                    ability.icon.spell.texture:SetTexture(GetSpellTexture(388013))
                -- spring -> 
                elseif spell_id == 388013 then
                    ability.icon.spell.texture:SetTexture(3636845)
                end
                
            end
        end
    end

    function module:spell_cast(spell_id, target_guid, target_name)
        self:BlessingOfSeasonsHelper(opt.PlayerGUID, spell_id)
    end

    function module:other_spell_cast(spell_id, source_guid, source_name, target_guid, target_name)
        self:BlessingOfSeasonsHelper(source_guid, spell_id)
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

    function module:player_died()
        local cds = self:FindCooldowns(opt.PlayerGUID)
        if not cds then return end

        for spell_id, ability in pairs(cds.abilities) do
            CDSync_OnCooldownEnd(ability)
            opt:ModuleEvent_OnCooldownEnd(opt.PlayerGUID, spell_id)
        end
    end

    function module:EstimateCooldown(guid, ability)
        if not ability.cooldown_estimate then return end

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

