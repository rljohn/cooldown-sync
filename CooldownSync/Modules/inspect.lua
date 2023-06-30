local opt = CooldownSyncConfig

function opt:AddInspectModule()
    module = self:BuildModule("inspect")
    module.requests = {}

    function module:add_request(unit_id, id, guid)
        if not self.requests[id] then

            -- create new request
            local request = {}
            request.start = GetTime()
            request.unit_id = unit_id
            request.guid = guid
            request.send_addon_msg = false
            request.notified = false

            -- add request
            self.requests[id] = request
            module.active = true
        end
    end

    function module:update()

        -- optimize, early out
        if not module.active then return end
        
        for key, request in pairs(self.requests) do
            -- only do this once
            if not request.send_addon_msg then
                request.send_addon_msg = true
                -- TODO
            end

            -- only do this once
            if not request.notified then
                if CanInspect(request.unit_id) then
                    request.notified = true
                    NotifyInspect(request.unit_id)
                end
            end
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

                -- remove our request
                self.requests[key] = nil

                -- clear active flag if required
                if opt:GetTableSize(self.requests) == 0 then
                    module.active = false
                end
                
                return
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
                    NotifyInspect(unit_id)
                end
            end
        end
    end
end