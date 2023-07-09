local opt = CooldownSyncConfig

local COUNT = 10
function opt:AddBuddyModule()

    module = self:BuildModule('buddy')
    module.inspect = self:GetModule("inspect")
    module.buddy_pool = {}
    module.active_buddies = {}

    -- create a buddy
    function module:CreateBuddy()

        local buddy = {}
        
        function buddy:Reset()
            buddy.id = nil
            buddy.unit_id = nil
            buddy.name = nil
            buddy.realm = nil
            buddy.name_and_realm = nil
            buddy.guid = nil
            buddy.class = nil
            buddy.class_id = 0
            buddy.spec = 0
            buddy.spec_name = nil
            buddy.online = false
            buddy.dead = false
        end
    
        buddy:Reset()
        return buddy
    end

    -- allocates a buddy from the pool
    function module:AllocateBuddy()
        if self.buddy_pool == nil then return nil end

         -- find first available buddy in pool
        for i = 1, COUNT do
            if (self.buddy_pool[i]) then
                local buddy = self.buddy_pool[i]
                self.buddy_pool[i] = nil
                buddy.Reset()
                return buddy
            end
        end

        return nil
    end

    -- returns a buddy to the pool
    function module:FreeBuddy(buddy)
        -- find first free space in pool
        for i = 1, COUNT do
            if (not self.buddy_pool[i]) then
                cdDiagf("Freeing buddy at index: %d", i)
                self.buddy_pool[i] = buddy
                self.buddy_pool[i]:Reset()
            end
        end
    end

    -- retrieve a buddy based on player name (lowercase)
    function module:FindBuddy(id)
        for idx, buddy in pairs(self.active_buddies) do
            if (buddy) then
                if (buddy.id == id) then
                    return buddy
                end
            end
        end

        return nil
    end

    -- retrieve a buddy based on guid
    function module:FindBuddyByGuid(guid)
        for idx, buddy in pairs(self.active_buddies) do
            if (buddy) then
                if (buddy.guid == guid) then
                    return buddy
                end
            end
        end

        return nil
    end

    -- retrieve a buddy based on unit_id
    function module:FindBuddyByUnitId(unit_id)
        for idx, buddy in pairs(self.active_buddies) do
            if (buddy) then
                if (buddy.unit_id == unit_id) then
                    return buddy
                end
            end
        end

        return nil
    end

    -- resets all buddy info
    function module:Reset()

        while #self.active_buddies > 0 do
            local b = table.remove(self.active_buddies)
            self:FreeBuddy(b)
        end

    end

    -- override the initialization function
    function module:init()
        -- fill the pool
        for i=1,10 do
            self.buddy_pool[i] = self:CreateBuddy()
        end
    end

    -- register a buddy
    function module:RegisterBuddy(name)

        -- early out if already exists
        local b = self:FindBuddy(name)
        if (b) then
            return
        end

        local setting = {}
        setting.enabled = false

        -- add to settings
        if (opt.InRaid) then
            if (not opt:TableContainsKey(opt.env.RaidBuddies, name)) then
                opt.env.RaidBuddies[name] = setting
                opt:ModuleEvent_BuddyAdded(name)
                self:RefreshBuddies()
            end
        else
            if (not opt:TableContainsKey(opt.env.Buddies, name)) then
                opt.env.Buddies[name] = setting
                opt:ModuleEvent_BuddyAdded(name)
                self:RefreshBuddies()
            end
        end
    end

    -- unregister buddy
    function module:RemoveBuddy(name)

        cdDiagf("Unregister buddy: %s", name)

        -- remove from settings
        if (opt.InRaid) then
            if (opt.env.RaidBuddies[name] ~= nil) then
                opt.env.RaidBuddies[name] = nil
            end
        else
            if (opt.env.Buddies[name] ~= nil) then
                opt.env.Buddies[name] = nil
            end
        end

        -- remove buddy
        local id = strlower(name)
        local b = self:FindBuddy(id)
        if (b) then
            self:OnBuddyUnavailable(b)
            opt:ModuleEvent_BuddyRemoved(b)
            self:RefreshBuddies()
        end
    end

    -- clear buddy registrations
    function module:ClearBuddies()
        opt.env.Buddies = {}
        opt.env.RaidBuddies = {}
        self:RefreshBuddies()
    end

    function module:RemoveActiveBuddy(buddy)
        for idx, b in pairs(self.active_buddies) do
            if b == buddy then
                self.active_buddies[idx] = nil
                return
            end
        end
    end

    function module:OnBuddyUnavailable(buddy)
        opt:ModuleEvent_BuddyUnavailable(buddy)
        self:FreeBuddy(buddy)
        self:RemoveActiveBuddy(buddy)
    end

    -- update buddy status
    function module:RefreshBuddies()

        local list
        if IsInRaid() then 
            list = opt.env.RaidBuddies 
        else
            list = opt.env.Buddies
        end
        
        -- wipe out any buddies no longer in the list
        for idx, buddy in pairs(self.active_buddies) do

            local found = false
            for key, value in pairs(list) do
                if buddy.id == key then
                    found = true
                end
            end

            if not found then
                self:OnBuddyUnavailable(buddy)
            end
        end

        -- refresh any buddies in the list
        for key, value in pairs(list) do
            --if (value.enabled) then
                self:RefreshBuddy(key)
            --end
        end
    end

    function module:RefreshBuddy(key)

        local id = strlower(key)
        local b = self:FindBuddy(id)
        local info = opt:GetUnitInfo(id)

        -- we could no longer find our buddy in our group
        if not info then
            if b then
                self:OnBuddyUnavailable(b)
            end
            return
        end

        _, info.race = UnitRace(info.unit_id)
        info.class_name, info.class_filename, info.class_id = UnitClass(info.unit_id)
		info.online = UnitIsConnected(info.unit_id)
		info.dead = UnitIsDead(info.unit_id)

        -- update existing buddy info and early out
        if b then

            if (b.unit_id ~= info.unit_id) then
                opt:ModuleEvent_BuddyUnitIdChanged(b, info.unit_id)
                b.unit_id = info.unit_id
            end

            if (b.dead ~= info.dead) then
                b.dead = info.dead
                if b.dead then
                    opt:ModuleEvent_OnBuddyDied(b)
                else
                    opt.ModuleEvent_OnBuddyAlive(b)
                end
            end

            if (b.online ~= info.online) then
                b.online = info.online
            end

            self.inspect:add_request(b)
            return
        end

        -- make a new buddy
        local buddy = self:AllocateBuddy()
        if not buddy then
            return
        end

        table.insert(self.active_buddies, buddy)

        local name, realm = UnitName(info.unit_id)
        buddy.unit_id = info.unit_id
        buddy.name = name
        buddy.realm = opt:SpaceStripper(realm)
        buddy.name_and_realm = opt:SpaceStripper(GetUnitName(info.unit_id, true))
        buddy.id = strlower(buddy.name_and_realm)
        buddy.guid = info.guid
        buddy.class = info.class_id
        buddy.class_name = info.class_name
        buddy.online = info.online
        buddy.dead = info.dead
        _, buddy.race = info.race
        buddy.spec = 0
        buddy.spec_name = "Unknown"

        self.inspect:add_request(buddy)
        opt:ModuleEvent_BuddyAvailable(buddy)
    end
        
    function module:post_init()
        self:RefreshBuddies()
    end

    function module:party_changed()
        self:RefreshBuddies()
    end

    function module:talents_changed(unit_id)
        if (unit_id == "player") then
            for idx, buddy in pairs(self.active_buddies) do
                opt:SendTalentSpecChanged(opt.PlayerSpec, buddy.name, buddy.realm)
            end
        else
            local buddy = self:FindBuddyByUnitId(unit_id)
            if buddy then
                buddy.spec = 0
                buddy.spec_name = "UNKNOWN"
                self.inspect:add_request(buddy)
                opt:ModuleEvent_BuddySpecChanged(buddy)
            end
        end
        
    end

    function module:talents_received(name, spec_id, spec_name)
        local buddy = self:FindBuddy(name)
        if not buddy then return end
        buddy.spec = spec_id
        buddy.spec_name = spec_name
        opt:ModuleEvent_BuddySpecChanged(buddy)
    end

    function module:update_slow(elapsed)

        -- check if any dead buddies are alive now
        -- no need to hit this super fast
        for idx, buddy in pairs(self.active_buddies) do
            local dead = UnitIsDeadOrGhost(buddy.unit_id)
            if dead ~= buddy.dead then
                if buddy.dead then
                    opt:ModuleEvent_OnBuddyDied(buddy)
                else
                    opt.ModuleEvent_OnBuddyAlive(buddy)
                end
            end
        end
    end

    function module:unit_died(guid)
        local buddy = self:FindBuddyByGuid(guid)
        if buddy then
            buddy.dead = true
            opt:ModuleEvent_OnBuddyDied(guid)
        end
    end

    function module:inspect_specialization(guid, spec)
        local buddy = self:FindBuddyByGuid(guid)
        if buddy then
            if (spec ~= buddy.spec) then
                buddy.spec = spec

                local spec_info = opt:GetClassInfoBySpec(buddy.spec)
                buddy.spec_name = spec_info.spec
                opt:ModuleEvent_BuddySpecChanged(buddy)
            end
        end
    end
end