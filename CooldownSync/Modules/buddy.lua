local opt = CooldownSyncConfig

local COUNT = 10
function opt:AddBuddyModule()

    module = self:BuildModule('buddy')
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

    -- resets all buddy info
    function module:Reset()

        cdDiagf("Reset")
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

        cdDiagf("Registering buddy: %s", name)

        -- early out if already exists
        local b = self:FindBuddy(name)
        if (b) then
            cdDiagf("Already registered")
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
        cdDiagf("Clearing buddies...")
        opt.env.Buddies = {}
        opt.env.RaidBuddies = {}
        self:RefreshBuddies()
    end

    function module:RemoveActiveBuddy(buddy)
        cdDiagf("Removing active buddy: %s", buddy.id)
        for idx, b in pairs(self.active_buddies) do
            if b == buddy then
                self.active_buddies[idx] = nil
                return
            end
        end
    end

    function module:OnBuddyUnavailable(buddy)
        cdDiagf("Buddy %s unavailable", buddy.id)
        opt:ModuleEvent_BuddyUnavailable(buddy)
        self:FreeBuddy(buddy)
        self:RemoveActiveBuddy(buddy)
    end

    -- update buddy status
    function module:RefreshBuddies()

        cdDiagf("Refreshing buddies...")

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
                cdDiagf("Buddy %s: unitid %s -> %s", b.id, b.unit_id, info.unit_id)
                opt:ModuleEvent_BuddyUnitIdChanged(b, info.unit_id)
                b.unit_id = info.unit_id
            end

            if (b.dead ~= info.dead) then
                cdDiagf("Buddy %s: dead %s -> %s", b.id, tostring(b.dead), tostring(info.dead))
                b.dead = info.dead
            end

            if (b.online ~= info.online) then
                cdDiagf("Buddy %s: online %s -> %s", b.id, tostring(b.online), tostring(info.online))
                b.online = info.online
            end

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

        local inspect = opt:GetModule("inspect")
        inspect:add_request(buddy.unit_id, buddy.id, buddy.guid)

        opt:ModuleEvent_BuddyAvailable(buddy)
    end
        
    function module:post_init()
        self:RefreshBuddies()
    end

    function module:party_changed()
        self:RefreshBuddies()
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