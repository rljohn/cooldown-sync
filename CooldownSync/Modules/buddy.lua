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
                self.buddy_pool[i] = buddy
                buddy.Reset()
            end
        end
    end

    -- retrieve a buddy based on player GUID
    function module.FindBuddy(self, name)
        for i = 1, #self.buddy_pool do
            if (self.buddy_pool[i]) then
                if (self.buddy_pool[i].name == name) then
                    return self.buddy_pool[i]
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
        local b = module:FindBuddy(name)
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
        local b = module:FindBuddy(name)
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
    function module.UpdateBuddies(self)

        local list
        if IsInRaid() then 
            list = opt.env.RaidBuddies 
        else
            list = opt.env.Buddies
        end

        for key, value in pairs(list) do
            local b = FindBuddy(self, key)
            if (b) then

            else

            end
        end
    end

        
    function module.update(self)
        self.UpdateBuddies(self)
    end


end