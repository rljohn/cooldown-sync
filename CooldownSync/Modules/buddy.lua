local opt = CooldownSyncConfig

function opt:AddBuddyModule()

    module = self:BuildModule('buddy')
    module.buddy_pool = {}

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
    function module.FreeBuddy(self, uddy)
        -- find first free space in pool
        for i = 1, #self.buddy_pool do
            if (not self.buddy_pool[i]) then
                self.buddy_pool[i] = buddy
                buddy.Reset()
            end
        end
    end

    -- retrieve a buddy based on player GUID
    function module.FindBuddy(self, guid)
        for i = 1, #self.buddy_pool do
            if (self.buddy_pool[i]) then
                if (self.buddy_pool[i].guid == guid) then
                    return self.buddy_pool[i]
                end
            end
        end
    end

    -- override the initialization function
    function module.init (self)
        -- fill the pool
        for i=1,10 do
            self.buddy_pool[i] = self.CreateBuddy()
        end
    end

end