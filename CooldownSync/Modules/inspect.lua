local opt = CooldownSyncConfig

function opt:AddInspectModule()
    module = self:BuildModule("inspect")
    module.requests = {}

    function module:add_request(buddy)
        if self.requests[buddy.id] then return end

        -- create new request
        local request = {}
        request.start = GetTime()
        request.last = 0
        request.unit_id = buddy.unit_id
        request.class = buddy.class_id
        request.guid = buddy.guid
        request.name = buddy.name
        request.realm = buddy.realm
        request.send_addon_msg = false
        request.notified = false

        -- add request
        self.requests[buddy.id] = request
        module.active = true

        opt:ModuleEvent_InspectRequest(buddy.guid)
    end

    function module:update()

        -- optimize, early out
        if not module.active then return end
        
        local time = GetTime()

        for key, request in pairs(self.requests) do
            -- only do this once
            if not request.send_addon_msg then
                request.send_addon_msg = true
                -- TODO
            end

            -- only do this once
            if not request.notified or ((time-request.last) > 2) then
                if CanInspect(request.unit_id) and CheckInteractDistance(request.unit_id, 1) then
                    request.last = time
                    request.notified = true
                    NotifyInspect(request.unit_id)
                end
            end
        end
    end

    function module:RemoveRequest(key)
        -- remove our request
        self.requests[key] = nil

        -- clear active flag if required
        if opt:GetTableSize(self.requests) == 0 then
            module.active = false
        end
    end

    function module:inspect_ready(guid)

        for key, request in pairs(self.requests) do
            if request.guid == guid then

                -- clear inspections if we requested it
                if request.notified then
                    ClearInspectPlayer()
                end

                -- forward talents on to other modules
                local spec = GetInspectSpecialization(request.unit_id)
                opt:ModuleEvent_InspectSpecialization(request.guid, spec)
                self:RemoveRequest(key)
                return
            end
        end
    end

    function module:talents_received(name, spec_id)
        for key, request in pairs(self.requests) do
            if request.name == name then
                self:RemoveRequest(key)
                return
            end
        end
    end

    function module:other_spell_cast(spell_id, source_guid, source_name, target_guid, target_name)
        for key, request in pairs(self.requests) do
            if (source_guid == request.guid) then
                
                if request.notified then
                    ClearInspectPlayer()
                end

                local spec_id = opt:FindSpec(class, spell_id)
                if not spec_id then return end

                opt:ModuleEvent_InspectSpecialization(request.guid, spec_id)
                self:RemoveRequest(key)
            end
        end
    end

    function module:unit_id_changed(buddy, unit_id)
        
        -- find the unit
        for key, request in pairs(self.requests) do
            if request.guid == buddy.guid then

                -- update unit ID
                request.unit_id = unit_id

                -- trigger a new inspect of this unit-id
                if request.notified then
                    ClearInspectPlayer()
                    NotifyInspect(unit_id)
                end
            end
        end
    end
end