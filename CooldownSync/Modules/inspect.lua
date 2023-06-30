local opt = CooldownSyncConfig

function opt:AddInspectModule()
    module = self:BuildModule("inspect")
    module.requests = {}

    function module:add_request(unit_id, id, guid)
        if not self.requests[id] then
            local request = {}
            request.start = GetTime()
            request.unit_id = unit_id
            request.guid = guid
            request.send_addon_msg = false
            request.notified = false

            cdDiagf("Request talent info for: %s", id)
            self.requests[id] = request
            module.active = true
        end
    end

    function module:update()
        if not module.active then return end
        
        for key, request in pairs(self.requests) do
            
            if not request.send_addon_msg then
                cdDiagf("Requesting talent via addon message")
                request.send_addon_msg = true
            end

            if not request.notified then
                if CanInspect(request.unit_id) then
                    cdDiagf("Requesting talent via inspect")
                    request.notified = true
                    NotifyInspect(request.unit_id)
                end
            end
        end
    end

    function module:inspect_ready(guid)

        for key, request in pairs(self.requests) do
            if request.guid == guid then

                if request.notified then
                    ClearInspectPlayer()
                end

                local spec = GetInspectSpecialization(request.unit_id)
                opt:ModuleEvent_InspectSpecialization(request.guid, spec)

                self.requests[key] = nil

                if opt:GetTableSize(self.requests) == 0 then
                    module.active = false
                end
                
                return
            end
        end
    end

    function module:unit_id_changed(buddy, unit_id)
        for key, request in pairs(self.requests) do
            if request.guid == buddy.guid then
                request.unit_id = unit_id

                if request.notified then
                    NotifyInspect(unit_id)
                end
            end
        end
    end
end