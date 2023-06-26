local opt = CooldownSyncConfig

function opt:AddBuddyModule()

    module = self:BuildModule('buddy')
    module.buddy_pool = {}
    module.active_buddies = {}

    -- create a buddy
    function module.CreateBuddy(self)

        buddy = {}
        
        function buddy.Reset(self)
            buddy.name = nil
            buddy.realm = nil
            buddy.name_and_realm = nil
            buddy.guid = nil
            buddy.class = 0
            buddy.spec = 0
            buddy.online = false
            buddy.dead = false
        end
    
        buddy.Reset()
        return buddy
    end

    -- allocates a buddy from the pool
    function module.AllocateBuddy(self)
        if self.buddy_pool == nil then return nil end

         -- find first available buddy in pool
        for i = 1, #self.buddy_pool do
            if (self.buddy_pool[i]) then
                cdDiagf("Allocating buddy at index: %d", i)
                buddy = self.buddy_pool[i]
                self.buddy_pool[i] = nil
                buddy.Reset()
                return buddy
            end
        end

        return nil
    end

    -- returns a buddy to the pool
    function module.FreeBuddy(self, buddy)
        -- find first free space in pool
        for i = 1, #self.buddy_pool do
            if (not self.buddy_pool[i]) then
                cdDiagf("Freeing buddy at index: %d", i)
                self.buddy_pool[i] = buddy
                buddy.Reset()
            end
        end
    end

    -- retrieve a buddy based on player name
    function module.FindBuddy(self, name)
        for i = 1, #self.active_buddies do
            if (self.active_buddies[i]) then
                if (self.active_buddies[i].name == name) then
                    return self.active_buddies[i]
                end
            end
        end

        return nil
    end

    -- resets all buddy info
    function module.Reset(self)

        while #self.active_buddies > 0 do
            b = table.remove(self.active_buddies)
            FreeBuddy(self, b)
        end

    end

    -- override the initialization function
    function module.init (self)
        -- fill the pool
        for i=1,10 do
            self.buddy_pool[i] = self.CreateBuddy()
        end
    end

    -- register a buddy
    function module.RegisterBuddy(self, name)

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
            end
        else
            if (not opt:TableContainsKey(opt.env.Buddies, name)) then
                opt.env.Buddies[name] = setting
                opt:ModuleEvent_BuddyAdded(name)
            end
        end
    end

    -- unregister buddy
    function module.RemoveBuddy(self, name)

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
        local b = self:FindBuddy(name)
        if (b) then
            module:FreeBuddy(name)
            opt:ModuleEvent_BuddyRemoved(name)
        end
    end

    -- clear buddy registrations
    function module.ClearBuddies(self)
        opt.env.Buddies = {}
        opt.env.RaidBuddies = {}
    end

    -- update buddy status
    function module.RefreshBuddies(self)

        local list

        if IsInRaid() then 
            list = opt.env.RaidBuddies 
        else
            list = opt.env.Buddies
        end

        for key, value in pairs(list) do
            --if (value.enabled) then
                self.RefreshBuddy(self, key)
            --end
            
        end
    end

    function module.RefreshBuddy(self, key)

        local b = self:FindBuddy(key)
        if b then return end

        local info = opt:GetUnitInfo(key)
        if not info then return end

        b = self:AllocateBuddy(key)
        if not b then return end
        cdPrintf("Allocated buddy: %s", key)
        table.insert(self.active_buddies, b)

        cdPrintf("Refreshing buddy: %s", key)
        name, realm = UnitName(info.unit_id)
        b.name = name
        b.realm = opt:SpaceStripper(realm)
        b.name_and_realm = opt:SpaceStripper(GetUnitName(info.unit_id))
        b.guid = info.guid
        b.class = info.class
        b.online = info.online
        b.dead = info.dead
        NotifyInspect(info.unit_id)

    end
        
    function module.update(self)
        self.RefreshBuddies(self)
    end

end