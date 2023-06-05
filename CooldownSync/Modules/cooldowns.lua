local opt = CooldownSyncConfig

local function CDSync_OnAuraGained(self, spell_id)
    if (self.abilities[spell_id]) then
        self.abilities[spell_id].active = true
    end
end

local function CDSync_OnAuraLost(self, spell_id)
    if (self.abilities[spell_id]) then
        self.abilities[spell_id].active = false
    end
end

local function CDSync_OnCooldownStart(self, spell_id, duration, time_remaining, progress)
    if (self.abilities[spell_id]) then
        self.abilities[spell_id].on_cooldown = true
        self.abilities[spell_id].cd_duration = duration
        self.abilities[spell_id].time_remaining = time_remaining
        self.abilities[spell_id].cd_progress = progress
    end
end

local function CDSync_OnCooldownEnd(self, spell_id)
    if (self.abilities[spell_id]) then
        self.abilities[spell_id].on_cooldown = false
        self.abilities[spell_id].cd_duration = 0
        self.abilities[spell_id].time_remaining = 0
        self.abilities[spell_id].cd_progress = 1.0
    end
end

local function CDSync_OnCooldownsUpdated(self)
    
    for spell_id, ability in pairs(self.abilities) do

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

                local percent = opt:CalculateCoolodwnPercent(duration, cd_remaining)
                self.abilities[spell_id].cd_duration = duration
                self.abilities[spell_id].time_remaining = cd_remaining
                self.abilities[spell_id].cd_progress = percent

                if not ability.on_cooldown then
                    CDSync_OnCooldownStart(self, spell_id, cd_remaining)
                    opt:ModuleEvent_OnCooldownStart(spell_id, start, duration, cd_remaining, percent)
                end
                
                opt:ModuleEvent_OnCooldownUpdate(spell_id, start, duration, cd_remaining, percent)
            end

            if not on_cooldown and ability.on_cooldown then
                CDSync_OnCooldownEnd(self, spell_id)
                opt:ModuleEvent_OnCooldownEnd(spell_id)
            end
        end
    end
end

local function CDSync_Update(self)
    CDSync_OnCooldownsUpdated(self)
end

local function CDSync_OnSpellCast(self, spell_id, target_guid, target_name)

end

local function CDSync_OnOtherSpellCast(self, spell_id, source_guid, source_name, target_guid, target_name)

end

function opt:CalculateCoolodwnPercent(duration, time_remaining)
    if duration == 0 then
        return 1.0
    end

    local percent = opt:Clamp(time_remaining / duration, 0.0, 1.0)
    return percent
end

function opt:AddCooldownModule()
    
    module = self:BuildModule("cooldowns")
    module.abilities = {}

    function module.TrackAbility (self, spell_id)
        ability = {}
        ability.id = spell_id
        self.abilities[spell_id] = ability
    end

    function module.CheckAuras(self)
        for spell_id, ability in pairs(self.abilities) do
            local aura = C_UnitAuras.GetPlayerAuraBySpellID(spell_id)
            if (aura) then
                opt:ModuleEvent_OnAuraGained(spell_id, opt.PlayerGUID, opt.PlayerName)
            end
        end
    end

    function module.GetAbility(self, spell_id)
        return self.abilities[spell_id]
    end

    function module.AddIcon(self, spell_id, icon)
        if self.abilities[spell_id] then
            self.abilities[spell_id].icon = icon
        end
    end

    function module.Reset (self)
        self.abilities = {}
    end

    -- override module defaults
    module.post_init = CDSync_PostInit
    module.aura_gained = CDSync_OnAuraGained
    module.aura_lost = CDSync_OnAuraLost
    module.spell_cast = CDSync_OnSpellCast
    module.update = CDSync_Update
    module.cooldowns_updated = CDSync_OnCooldownsUpdated

    -- do not register CD start/end, we fire those events

    return module
end

