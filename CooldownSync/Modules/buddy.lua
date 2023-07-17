---@diagnostic disable: undefined-field
local opt = CooldownSyncConfig

local LGF = LibStub("LibGetFrame-1.0")
local Glower = LibStub("LibCustomGlow-1.0")

local COUNT = 10


function opt:AddBuddyModule()

    module = self:BuildModule('buddy')
    module.inspect = self:GetModule("inspect")
    module.buddy_pool = {}
    module.active_buddies = {}
    module.recycled_buddy_options = {}

    -- create a buddy
    function module:CreateBuddy()

        local buddy = {}
        
        function buddy:Reset()
            self:EndGlow()
            self.id = nil
            self.unit_id = nil
            self.name = nil
            self.realm = nil
            self.name_and_realm = nil
            self.guid = nil
            self.class = nil
            self.class_id = 0
            self.spec = 0
            self.spec_name = nil
            self.online = false
            self.dead = false
            self.glowing = false
            self.glow_frames = nil
        end

        function buddy:Glow()
            if self.glowing then return end
            if not LGF then return end
            if not Glower then return end

            self.glow_frames = LGF.GetUnitFrame(self.unit_id, {
				ignorePlayerFrame = false,
				ignoreTargetFrame = false,
				ignoreTargettargetFrame = false,
                ignorePartyFrame = false,
				returnAll = true,
			  })

            if not self.glow_frames then return end

            for _, frame in pairs(self.glow_frames) do
                Glower.PixelGlow_Start(frame)
            end

            self.glowing = true
        end

        function buddy:EndGlow()
            if not self.glowing then return end
            self.glowing = false

            if not self.glow_frames then return end
            for _, frame in pairs(self.glow_frames) do
                if (frame) then
                    Glower.PixelGlow_Stop(frame)
                end
            end
            self.glow_frames = nil
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
                buddy:Reset()
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

    function module:hehexd()
        print('hehexd')
    end

    -- register a buddy
    function module:RegisterBuddy(name, in_raid)

        -- early out if already exists
        local b = self:FindBuddy(name)
        if (b) then
            return
        end

        local setting = {}
        setting.enabled = true
        setting.name = name

        -- add to settings
        if (in_raid) then
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

        if in_raid then
            self:AddBuddyWidget(self.raid_panel, nil, name, setting, in_raid)
        else
            self:AddBuddyWidget(self.party_panel, nil, name, setting, in_raid)
        end

        self:EvaluateAddButton()
        self:realign_options(in_raid)
    end

    function module:EvaluateAddButton()

        if self.add_button_raid then
            if opt:GetTableSize(opt.env.RaidBuddies) >= COUNT then
                self.add_button_raid:Disable()
            else
                self.add_button_raid:Enable()
            end
        end

        if self.add_button_party then
            if opt:GetTableSize(opt.env.Buddies) >= COUNT then
                self.add_button_party:Disable()
            else
                self.add_button_party:Enable()
            end
        end
    end

    -- unregister buddy
    function module:RemoveBuddy(name, is_raid)

        cdDiagf("Removing Buddy: %s", name)

        local realign = false

        -- remove from settings
        if (is_raid) then

            if (opt.env.RaidBuddies[name] and opt.env.RaidBuddies[name].frame) then
                opt.env.RaidBuddies[name].frame:Hide()
                realign = true
            end

            tinsert(self.recycled_buddy_options, opt.env.RaidBuddies[name])
            opt.env.RaidBuddies[name] = nil
        else

            if (opt.env.Buddies[name] and opt.env.Buddies[name].frame) then
                opt.env.Buddies[name].frame:Hide()
                realign = true
            end

            tinsert(self.recycled_buddy_options, opt.env.RaidBuddies[name])
            opt.env.Buddies[name] = nil
        end

        -- remove buddy
        local id = strlower(name)
        local b = self:FindBuddy(id)
        if (b) then
            self:OnBuddyUnavailable(b)
            opt:ModuleEvent_BuddyRemoved(b)
            self:RefreshBuddies()
        end

        -- check if add buttons should be enabled/disabled
        self:EvaluateAddButton()
    
        -- if set, re-align options UI
        if realign then
            self:realign_options(is_raid)
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
                if buddy.id == strlower(key) and value.enabled then
                    found = true
                end
            end

            if not found then
                self:OnBuddyUnavailable(buddy)
            end
        end

        -- refresh any buddies in the list
        for key, value in pairs(list) do
            if (value.enabled) then
                self:RefreshBuddy(key)
            end
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
                opt:SendTalentSpecChanged(opt.PlayerSpec, opt.PlayerSpecName, buddy.name, buddy.realm)
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
        if not buddy then return end
        
        if (spec ~= buddy.spec) then
            buddy.spec = spec

            local spec_info = opt:GetClassInfoBySpec(buddy.spec)
            buddy.spec_name = spec_info.spec
            opt:ModuleEvent_BuddySpecChanged(buddy)
        end
    end

    function module:talents_received(name, spec_id)
        local buddy = self:FindBuddy(name)
        if not buddy then return end

        if (spec_id ~= buddy.spec) then
            buddy.spec = spec_id

            local spec_info = opt:GetClassInfoBySpec(buddy.spec)
            buddy.spec_name = spec_info.spec
            opt:ModuleEvent_BuddySpecChanged(buddy)
        end
    end

    --------------------------------------
    -- Widgets
    --------------------------------------

    module.base_init = module.init
    function module:init()
        self:base_init()
        self:BuildPanels()
        self:realign_options(false)
        self:realign_options(true)
    end

    function module:AddBuddyButton(editBox, in_raid)

        local frameText = strlower(editBox:GetText())
	    if (frameText == strlower(opt.PlayerName)) then
		    editBox:SetText('')
            return
        end

        local name = editBox:GetText()
        local result = self:TryRegisterBuddy(name, in_raid)
        if result then
            editBox:SetText('')
        end
    end

    function module:TryRegisterBuddy(name, in_raid)

        local list
        if in_raid then
           list = opt.env.RaidBuddies
        else
           list = opt.env.Buddies
        end

        local count = opt:GetTableSize(list)
        if count >= COUNT then return end
        
        for existing_name, setting in pairs(list) do
           if existing_name == name then 
                
                return false
           end
        end
        
        self:RegisterBuddy(name, in_raid)
        return true
    end

    function module:BuildPanels()

        -- panel header

        local buddy_page = CreateFrame('FRAME', 'BuddyManagement', opt)
        buddy_page.name = 'Buddy Management'
        buddy_page.ShouldResetFrames = false
        buddy_page.parent = opt.name
        InterfaceOptions_AddCategory(buddy_page)
        self.buddy_page = buddy_page

        local header = buddy_page:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        header:SetText(opt.titles.BuddyTitle)
        header:SetPoint('TOPLEFT', buddy_page, 'TOPLEFT', 24, -16)

        local subheader = buddy_page:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        subheader:SetText(opt.titles.BuddyDesc)
        subheader:SetPoint('TOPLEFT', header, 'TOPLEFT', 0, -24)
        
        local subheader2 = buddy_page:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        subheader2:SetText(opt.titles.BuddyDesc2)
        subheader2:SetPoint('TOPLEFT', subheader, 'TOPLEFT', 0, -16)

        local subheader3 = buddy_page:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        subheader3:SetText(opt.titles.BuddyDesc3)
        subheader3:SetPoint('TOPLEFT', subheader2, 'TOPLEFT', 0, -16)

        -- buddy frames

        local party = opt:CreatePanel(buddy_page, nil, 256, 300)
        party:SetPoint('TOPLEFT', subheader3, 'BOTTOMLEFT', 0, -64)
        self.party_panel = party

        local title = buddy_page:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        title:SetText(opt.titles.PartyBuddies)
        title:SetPoint('TOPLEFT', party, 'TOPLEFT', 0, 32)

        local raid = opt:CreatePanel(buddy_page, nil, 256, 300)
        raid:SetPoint('TOPLEFT', party, 'TOPRIGHT', 64, 0)
        self.raid_panel = raid

        local title2 = buddy_page:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        title2:SetText(opt.titles.RaidBudies)
        title2:SetPoint('TOPLEFT', raid, 'TOPLEFT', 0, 32)

        local previous = nil
        for name, setting in pairs(opt.env.Buddies) do
            previous = self:AddBuddyWidget(party, previous, name, setting, false)
        end

        previous = nil
        for name, setting in pairs(opt.env.RaidBuddies) do
            previous = self:AddBuddyWidget(raid, previous, name, setting, true)
        end

        -- party add buttons

        local editBox = opt:CreateEditBox(buddy_page, nil, 64, 200, 32)
        editBox:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', -2, -12)
        editBox:SetCursorPosition(0)
        
        local addBtn = CreateFrame("Button", nil, party, "UIPanelButtonTemplate")
        addBtn:SetPoint('TOPLEFT', editBox, 'TOPRIGHT', 8, -4)
        addBtn:SetText('Add')
        addBtn:SetWidth(80)
        addBtn:SetHeight(24)
        addBtn:SetScript("OnClick", function(this, event, ...)
            self:AddBuddyButton(editBox, false)
            editBox:SetText('')
        end)
        self.add_button_party = addBtn

        editBox:SetScript('OnEnterPressed', function(self)
            addBtn:Click()
        end)
        editBox:SetScript('OnEscapePressed', function(self)
            editBox:ClearFocus()
        end)

        -- raid add butons

        local editBoxRaid = opt:CreateEditBox(buddy_page, nil, 64, 200, 32)
        editBoxRaid:SetPoint('TOPLEFT', raid, 'BOTTOMLEFT', -2, -12)
        editBoxRaid:SetCursorPosition(0)
        
        local addBtnRaid = CreateFrame("Button", nil, raid, "UIPanelButtonTemplate")
        addBtnRaid:SetPoint('TOPLEFT', editBoxRaid, 'TOPRIGHT', 8, -4)
        addBtnRaid:SetText('Add')
        addBtnRaid:SetWidth(80)
        addBtnRaid:SetHeight(24)
        addBtnRaid:SetScript("OnClick", function(this, arg1)
            self:AddBuddyButton(editBoxRaid, true)
            editBoxRaid:SetText('')
        end)
        self.add_button_raid = addBtnRaid

        editBoxRaid:SetScript('OnEnterPressed', function(self)
            addBtnRaid:Click()
        end)
        editBoxRaid:SetScript('OnEscapePressed', function(self)
            editBoxRaid:ClearFocus()
        end)
    end

    function module:AddBuddyWidget(parent, previous, name, setting, in_raid)

        if not parent then
            return
        end

        -- create and position frame

        local frame = CreateFrame('Frame', nil, parent)
        frame:SetSize(264, 24)
        frame:SetFrameStrata("HIGH")
        frame.buddy_name = name
        setting.frame = frame

        if previous then
            frame:SetPoint('TOPLEFT', previous, 'BOTTOMLEFT', 0, -4)
        else
            frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', 4, -4)
        end

        -- frame highlight

        frame.highlight = frame:CreateTexture('HIGHLIGHT')
        frame.highlight:SetTexture('Interface/BUTTONS/UI-Listbox-Highlight')
        frame.highlight:SetBlendMode('add')
        frame.highlight:SetAlpha(.5)
        frame.highlight:Hide()
        frame.highlight:SetAllPoints(frame)

        -- enabled checkbox

        frame.check = CreateFrame('CheckButton', nil, frame, 'OptionsBaseCheckButtonTemplate')
        frame.check:SetScript('OnClick', function(this)
            if not opt.env.Buddies[frame.buddy_name] then return end
            local was_enabled = opt.env.Buddies[frame.buddy_name].enabled
            if (was_enabled) then
                this:SetChecked(false)
                opt.env.Buddies[frame.buddy_name].enabled = false
                self:RefreshBuddies()
            else
                this:SetChecked(true)
                opt.env.Buddies[frame.buddy_name].enabled = true
                self:RefreshBuddies()
            end
        end)
        frame.check:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, -0)
        frame.check:SetChecked(setting.enabled)

        frame.check:SetScript('OnEnter', function(self)
            frame.highlight:Show()
            opt:OnTooltipEnter(frame)
        end)
        frame.check:SetScript('OnLeave', function(self)
            frame.highlight:Hide()
            opt:OnTooltipLeave(frame)
        end)

        -- name text

        frame.name = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        frame.name:SetText(name)
        frame.name:SetPoint('TOPLEFT', frame.check, 'TOPRIGHT', 4, -6)

        frame:SetScript('OnEnter', function(self)
            self.highlight:Show()
            opt:OnTooltipEnter(frame)
        end)
        frame:SetScript('OnLeave', function(self)
            self.highlight:Hide()
            opt:OnTooltipLeave(frame)
        end)

        -- remove button

        frame.remove = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        frame.remove:SetPoint('TOPRIGHT',  frame, 'TOPRIGHT', -4, 0)
        frame.remove:SetWidth(24)
        frame.remove:SetHeight(22)
        frame.remove:SetText('x')
        frame.remove:SetScript("OnClick", function(this, arg1)
            self:RemoveBuddy(frame.buddy_name, in_raid)
        end)

        return frame
    end

    function module:realign_panel(list, panel)

        local panels = {}
        for name, setting in pairs(list) do
            table.insert(panels, setting)
        end

        table.sort(panels, function(a,b)
            return a.name < b.name
        end)

        local previous = nil
        for _, setting in pairs(panels) do
            if setting.frame then
                if previous then
                    setting.frame:SetPoint('TOPLEFT', previous, 'BOTTOMLEFT', 0, -4)
                else
                    setting.frame:SetPoint('TOPLEFT', panel, 'TOPLEFT', 4, -4)
                end
                previous = setting.frame
            end
        end
    end

    function module:realign_options(in_raid)
        if in_raid then
            self:realign_panel(opt.env.RaidBuddies, self.raid_panel)
        else
            self:realign_panel(opt.env.Buddies, self.party_panel)
        end
    end

    function module:main_frame_right_click()
        if (UnitIsPlayer("target") and GetUnitName("target", true) and GetUnitName("target", true) ~= opt.PlayerName) then
            self:TryRegisterBuddy(GetUnitName("target", true), opt.InRaid)
        end
    end

end