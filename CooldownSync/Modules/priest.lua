---@diagnostic disable: param-type-mismatch, undefined-field
local opt = CooldownSyncConfig

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")
local media = LibStub("LibSharedMedia-3.0")
local major_cooldown = 'Power Infusion'
local class = 'Priest'
local macro_name = 'CDSyncPriest'

function opt:AddPriestModule()
    module = opt:BuildClassModule(strlower(class))
    module.buddy = opt:GetModule("buddy")

    function module:load_default_values()

        opt:SetDefaultValue('Priest_Buddy', "")
        opt:SetDefaultValue('Priest_RaidBuddy', "")
        opt:SetDefaultValue('Priest_CooldownAudio', "None")
        opt:SetDefaultValue('Priest_CooldownChannel', "Master")
        opt:SetDefaultValue('Priest_ShowFrameGlow',  true)
        opt:SetDefaultValue('Priest_Trinket1Party', true)
        opt:SetDefaultValue('Priest_Trinket1Raid', true)
        opt:SetDefaultValue('Priest_Trinket2Party', true)
        opt:SetDefaultValue('Priest_Trinket2Raid', true)
        opt:SetDefaultValue('Priest_GenerateMacroParty', false)
        opt:SetDefaultValue('Priest_GenerateMacroRaid', false)
        opt:SetDefaultValue('Priest_FocusParty', false)
        opt:SetDefaultValue('Priest_FocusRaid', false)
        opt:SetDefaultValue('Priest_FriendlyParty', true)
        opt:SetDefaultValue('Priest_FriendlyRaid', true)
        opt:SetDefaultValue('Priest_TargetLastTargetParty', true)
        opt:SetDefaultValue('Priest_TargetLastTargetRaid', true)
    end

    function module:BuildMacroPanel()

        local class_macros = CreateFrame('FRAME', 'CDSyncPriestMacros', opt)
        class_macros.name = class .. ' Macros'
        class_macros.ShouldResetFrames = false
        class_macros.parent = opt.name
        InterfaceOptions_AddCategory(class_macros)

        self:CreatePriestMacroPanel(true, class_macros, 25, -48)
        self:CreatePriestMacroPanel(false, class_macros, 25, -330)
    end

    function module:CheckMacros()
        self.ExportMacrosRaid = opt.InRaid and opt.env.Priest_GenerateMacroRaid
        self.ExportMacros = opt.InGroup and opt.env.Priest_GenerateMacroParty
    end

    function module:GetMacroText(party)
        local text = '#showtooltip ' .. major_cooldown
 
        -- trinkets

        if (party) then
            if (opt.env.Priest_Trinket1Party) then
                text = text .. '\n/use 13'
            end

            if (opt.env.Priest_Trinket2Party) then
                text = text .. '\n/use 14'
            end
        else
            if (opt.env.Priest_Trinket1Raid) then
                text = text .. '\n/use 13'
            end

            if (opt.env.Priest_Trinket2Raid) then
                text = text .. '\n/use 14'
            end
        end

        -- buddy

        if (party) then
            if (opt.env.Priest_Buddy and opt.env.Priest_Buddy ~= "") then
                text = text .. string.format('\n/cast [@%s,help,nodead] ' .. major_cooldown, opt.env.Priest_Buddy)
                text = text .. string.format('\n/stopmacro [@%s,help,nodead]', opt.env.Priest_Buddy)
            end
        else
            if (opt.env.Priest_RaidBuddy and opt.env.Priest_RaidBuddy ~= "") then
                text = text .. string.format('\n/cast [@%s,help,nodead] ' .. major_cooldown, opt.env.Priest_RaidBuddy)
                text = text .. string.format('\n/stopmacro [@%s,help,nodead]', opt.env.Priest_RaidBuddy)
            end
        end

        -- focus

            if ((party and opt.env.Priest_FocusParty) or (not party and opt.env.Priest_FocusRaid)) then
                text = text .. '\n/cast [focus,help,nodead] ' .. major_cooldown
            end

        -- friendly

        if ((party and opt.env.Priest_FriendlyParty) or (not party and opt.env.Priest_FriendlyRaid)) then
            text = text .. '\n/targetfriendplayer [nohelp]'
            text = text .. '\n/cast [help] ' .. major_cooldown

            if ((party and opt.env.Priest_TargetLastTargetParty) or (not party and opt.env.Priest_TargetLastTargetRaid)) then
                text = text .. '\n/targetlasttarget [help]'
            end
        end

        -- self

        text = text .. '\n/cast [@player] ' .. major_cooldown

        return text
    end

    function module:UpdateMacros()

        if (opt.InCombat) then return end

        local text = nil
        if (self.ExportMacrosRaid) then
            text = self:GetMacroText(false)
        elseif (self.ExportMacros) then
            text = self:GetMacroText(true)
        end

        if (text == nil) then return end

        self.ExportMacros = false
        self.ExportMacrosRaid = false

        local index = GetMacroIndexByName(macro_name);
        if (index == 0) then
            CreateMacro(macro_name, "135939", text, false)
        else
            EditMacro(index, macro_name, nil, text)
        end
    end

    function module:RefreshPriestMacros(party)

        local text = self:GetMacroText(party)
        if (not text) then return end

        if (party) then
            self.macroEditBox:SetText(text)
        else
            self.macroEditBoxRaid:SetText(text)
        end

        self:CheckMacros()
    end

    function module:CreatePriestMacroPanel(party, parent, x, y)

        -- macro panel

        local macro_panel = CreateFrame('Frame', nil, parent, "BackdropTemplate")
        macro_panel:SetPoint('TOPLEFT', parent, 'TOPLEFT', x, y)
        macro_panel:SetSize(360, 220)
        macro_panel:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
            edgeSize = 14,
            insets = {left = 3, right = 3, top = 3, bottom = 3},
        })
        macro_panel:SetBackdropColor(0, 0, 0)
        macro_panel:SetBackdropBorderColor(0.3, 0.3, 0.3)
        macro_panel:EnableMouse(true)

        -- title

        local title = macro_panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        title:SetPoint('TOPLEFT', macro_panel, 'TOPLEFT', 0, 32)
        if (party) then
            title:SetText(opt.titles.Priest_MacroConfig)
        else
            title:SetText(opt.titles.Priest_MacroConfigRaid)
        end

        -- edit box

        local editBox = CreateFrame("EditBox", nil, macro_panel)
        editBox:SetPoint("TOP")
        editBox:SetPoint("LEFT")
        editBox:SetPoint("RIGHT")
        editBox:SetFontObject('ChatFontNormal')
        editBox:SetMultiLine(true)
        editBox:SetSize(360, 200)
        editBox:SetMaxLetters(1024)
        editBox:SetCursorPosition(0)
        editBox:SetAutoFocus(false)
        editBox:SetJustifyH("LEFT")
        editBox:SetJustifyV("MIDDLE")
        editBox:SetTextInsets(10, 10, 10, 10)

        editBox:SetScript('OnEscapePressed', function(self)
            editBox:ClearFocus()
            editBox:HighlightText(0,0)
        end)

        macro_panel:SetScript("OnMouseDown", function(self)
            editBox:SetFocus()
            editBox:HighlightText()
        end)

        -- focus

        local use_focus
        if (party) then use_focus = opt:CreateCheckBox(parent, 'Priest_FocusParty') else use_focus = opt:CreateCheckBox(parent, 'Priest_FocusRaid') end
        use_focus:SetPoint("TOPLEFT", macro_panel, "TOPRIGHT", 8, 0)
        use_focus:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                module:RefreshPriestMacros(party)
            end)
        opt:AddTooltip(use_focus, opt.titles.Priest_FocusParty, opt.titles.Priest_FocusTooltip)

        local use_friendly
        if (party) then use_friendly = opt:CreateCheckBox(parent, 'Priest_FriendlyParty') else use_friendly = opt:CreateCheckBox(parent, 'Priest_FriendlyRaid') end
        use_friendly:SetPoint("TOPLEFT", use_focus, "BOTTOMLEFT", 0, -8)
        use_friendly:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                module:RefreshPriestMacros(party)
            end)
        opt:AddTooltip(use_friendly, opt.titles.Priest_FriendlyParty, opt.titles.Priest_FriendlyTooltip)

        -- trinket 1

        local trinket1, trinket2
        if (party) then trinket1 = opt:CreateCheckBox(parent, 'Priest_Trinket1Party') else trinket1 = opt:CreateCheckBox(parent, 'Priest_Trinket1Raid') end
        trinket1:SetPoint("TOPLEFT", use_friendly, "BOTTOMLEFT", 0, -8)
        trinket1:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                module:RefreshPriestMacros(party)
            end)
        opt:AddTooltip(trinket1, opt.titles.Priest_Trinket1Party, opt.titles.Priest_Trinket1Tooltip)

        -- trinket 2

        if (party) then trinket2 = opt:CreateCheckBox(parent, 'Priest_Trinket2Party') else trinket2 = opt:CreateCheckBox(parent, 'Priest_Trinket2Raid') end
        trinket2:SetPoint("TOPLEFT", trinket1, "BOTTOMLEFT", 0, -8)
        trinket2:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                module:RefreshPriestMacros(party)
            end)
        opt:AddTooltip(trinket2, opt.titles.Priest_Trinket2Party, opt.titles.Priest_Trinket2Tooltip)

        -- target last target

        local tlt
        if (party) then tlt = opt:CreateCheckBox(parent, 'Priest_TargetLastTargetParty') else tlt = opt:CreateCheckBox(parent, 'Priest_TargetLastTargetRaid') end
        tlt:SetPoint("TOPLEFT", trinket2, "BOTTOMLEFT", 0, -8)
        tlt:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                module:RefreshPriestMacros(party)
            end)
        opt:AddTooltip(tlt, opt.titles.Priest_TargetLastTargetParty, opt.titles.Priest_TargetLastTargetTooltip)

        -- auto generate

        local autogenerate
        if (party) then autogenerate = opt:CreateCheckBox(parent, 'Priest_GenerateMacroParty') else autogenerate = opt:CreateCheckBox(parent, 'Priest_GenerateMacroRaid') end
        autogenerate:SetPoint("TOPLEFT", tlt, "BOTTOMLEFT", 0, -8)
        autogenerate:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                if (self:GetChecked()) then
                    if (party) then
                        module.ExportMacros = true
                    else
                        module.ExportMacrosRaid = true
                    end
                end
            end)
        opt:AddTooltip(autogenerate, opt.titles.Priest_GenerateMacroParty, opt.titles.Priest_GenerateMacroPartyTooltip)

        -- cache the boxes

        if (party) then
            self.macroEditBox = editBox
        else
            self.macroEditBoxRaid = editBox
        end

        self:RefreshPriestMacros(party)
    end

    module.base_init = module.init
    function module:init()
        self:base_init()
        self:BuildPanels()
    end

    local EDITBOX_OFFSET_X = 58
    local EDITBOX_WIDTH = 144
    local BUTTON_HEIGHT = 22
    local COPY_TARGET_OFFSET_Y = -4

    function module:BuildPanels()
            
        local party = opt:CreatePanel(opt, nil, 264, 64)
        party:SetPoint('TOPLEFT', opt.ui.main, 'BOTTOMLEFT', 0, -80)

        local title = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        title:SetText(opt.titles.PartyBuddy)
        title:SetPoint('TOPLEFT', party, 'TOPLEFT', 0, 32)

        local raid = opt:CreatePanel(opt, nil, 264, 64)
        raid:SetPoint('TOPLEFT', party, 'BOTTOMLEFT', 0, -72)

        local title2 = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        title2:SetText(opt.titles.RaidBuddy)
        title2:SetPoint('TOPLEFT', raid, 'TOPLEFT', 0, 32)

        local options = opt:CreatePanel(opt, "ConfigFrame", 258, 200)
        options:SetPoint('TOPLEFT', party, 'TOPRIGHT', 64, 0)
        
        self:BuildPartyOptions(party)
        self:BuildRaidOptions(raid)
        self:BuildMiscOptions(options)

    end

    function module:BuildPartyOptions(parent)

        -- party buddy

        local title = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        title:SetText(opt.titles.Buddy)
        title:SetPoint('TOPLEFT', parent, 'TOPLEFT', 8, -8)
        
        -- party edit box 

        opt.ui.buddyEditBox = opt:CreateEditBox(opt, 'Priest_PartyEditBox', 64, EDITBOX_WIDTH, 32)
        opt.ui.buddyEditBox:SetPoint('TOPLEFT', title, 'TOPLEFT', EDITBOX_OFFSET_X, 9)
        opt.ui.buddyEditBox:SetText(opt.env.Priest_Buddy)
        opt.ui.buddyEditBox:SetCursorPosition(0)
        opt.ui.buddyEditBox:SetScript('OnEnterPressed', function(self)
            opt.ui.buddySubmitBtn:Click()
            end)
        opt.ui.buddyEditBox:SetScript('OnEscapePressed', function(self)
                opt.ui.buddyEditBox:ClearFocus()
            end)
        opt:AddTooltip(opt.ui.buddyEditBox, opt.titles.PartyBuddy, opt.titles.PartyBuddyTooltip)
            
        -- apply btn
        opt.ui.buddySubmitBtn = CreateFrame("Button", "Priest_ApplyButton", opt, "UIPanelButtonTemplate")
        opt.ui.buddySubmitBtn:SetPoint('LEFT', opt.ui.buddyEditBox, 'RIGHT', 8, 0)
        opt.ui.buddySubmitBtn:SetWidth(60)
        opt.ui.buddySubmitBtn:SetHeight(BUTTON_HEIGHT)
        opt.ui.buddySubmitBtn:SetText(opt.titles.ApplyBtn)
        opt.ui.buddySubmitBtn:SetScript("OnClick", function(self, arg1)
           module:ApplyBuddy(opt.ui.buddyEditBox, opt.ui.buddySubmitBtn, false)
        end)
        opt.ui.buddySubmitBtn:Disable()
        opt:AddTooltip(opt.ui.buddySubmitBtn, opt.titles.ApplyBtnHeader, opt.titles.ApplyBtnTooltip)

        -- copy target btn
        opt.ui.buddySetTargetBtn = CreateFrame("Button", "Priest_SetTargetButton", opt, "UIPanelButtonTemplate")
        opt.ui.buddySetTargetBtn:SetPoint('TOPLEFT', opt.ui.buddyEditBox, 'BOTTOMLEFT', -8, COPY_TARGET_OFFSET_Y)
        opt.ui.buddySetTargetBtn:SetWidth(100)
        opt.ui.buddySetTargetBtn:SetHeight(BUTTON_HEIGHT)
        opt.ui.buddySetTargetBtn:SetText(opt.titles.SetAsTargetBtn)
        opt.ui.buddySetTargetBtn:SetScript("OnClick", function(self, arg1)
            if (UnitIsPlayer("target") and GetUnitName("target", true) and GetUnitName("target", true) ~= opt.PlayerName) then
                opt.ui.buddyEditBox:SetText(GetUnitName("target", true))
                opt.ui.buddyEditBox:SetCursorPosition(0)
            end
        end)
        opt:AddTooltip(opt.ui.buddySetTargetBtn, opt.titles.SetAsTargetBtn, opt.titles.CopyTargetTooltip)
        
        opt.ui.buddyEditBox:SetScript('OnTextChanged', function(self)
            module:OnBuddyEditChanged(opt.ui.buddyEditBox, opt.env.Priest_Buddy, opt.ui.buddySubmitBtn)
        end)
        
    end

    function module:BuildRaidOptions(parent)
    
        -- party buddy

        local title = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        title:SetText(opt.titles.Buddy)
        title:SetPoint('TOPLEFT', parent, 'TOPLEFT', 8, -8)
        
        -- party edit box 
        
        opt.ui.buddyEditBoxRaid = opt:CreateEditBox(opt, 'Priest_RaidEditBox', 64, EDITBOX_WIDTH, 32)
        opt.ui.buddyEditBoxRaid:SetPoint('TOPLEFT', title, 'TOPLEFT', EDITBOX_OFFSET_X, 9)
        opt.ui.buddyEditBoxRaid:SetText(opt.env.Priest_RaidBuddy)
        opt.ui.buddyEditBoxRaid:SetCursorPosition(0)
        opt.ui.buddyEditBoxRaid:SetScript('OnEnterPressed', function(self)
            opt.ui.buddySubmitBtnRaid:Click()
            end)
        opt.ui.buddyEditBoxRaid:SetScript('OnEscapePressed', function(self)
                opt.ui.buddyEditBoxRaid:ClearFocus()
            end)
    
        opt.ui.buddySubmitBtnRaid = CreateFrame("Button", "Priest_RaidApplyButton", opt, "UIPanelButtonTemplate")
        opt.ui.buddySubmitBtnRaid:SetPoint('LEFT', opt.ui.buddyEditBoxRaid, 'RIGHT', 8, 0)
        opt.ui.buddySubmitBtnRaid:SetWidth(60)
        opt.ui.buddySubmitBtnRaid:SetHeight(BUTTON_HEIGHT)
        opt.ui.buddySubmitBtnRaid:SetText(opt.titles.ApplyBtn)
        opt.ui.buddySubmitBtnRaid:SetScript("OnClick", function(self, arg1)
            module:ApplyBuddy(opt.ui.buddyEditBoxRaid, opt.ui.buddySubmitBtnRaid, true)
        end)
        opt.ui.buddySubmitBtnRaid:Disable()

        -- copy target btn
        opt.ui.buddySetTargetBtnRaid = CreateFrame("Button", "Priest_RaidSetTargetButton", opt, "UIPanelButtonTemplate")
        opt.ui.buddySetTargetBtnRaid:SetPoint('TOPLEFT', opt.ui.buddyEditBoxRaid, 'BOTTOMLEFT', -8, COPY_TARGET_OFFSET_Y)
        opt.ui.buddySetTargetBtnRaid:SetWidth(100)
        opt.ui.buddySetTargetBtnRaid:SetHeight(BUTTON_HEIGHT)
        opt.ui.buddySetTargetBtnRaid:SetText(opt.titles.SetAsTargetBtn)
        opt.ui.buddySetTargetBtnRaid:SetScript("OnClick", function(self, arg1)
            if (UnitIsPlayer("target") and GetUnitName("target", true) and GetUnitName("target", true) ~= opt.PlayerName) then
                opt.ui.buddyEditBoxRaid:SetText(GetUnitName("target", true))
                opt.ui.buddyEditBoxRaid:SetCursorPosition(0)
            end
        end)

    end

    function module:BuildMiscOptions(parent)
        
        local title = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
        title:SetText(opt.titles.Priest_Options)
        title:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, 32)

        opt.ui.CooldownSound = LibDD:Create_UIDropDownMenu("CDSyncPriestSoundDropdown", opt.ui.main)
        
        local SoundDB = media:List("sound")
    
        local PER_PAGE = 25
        LibDD:UIDropDownMenu_Initialize(opt.ui.CooldownSound, function(self, level, menuList)

            -- reset to populate
            local NumSounds = getn(SoundDB)
            local NumCategories
            if NumSounds > PER_PAGE then
                NumCategories = (NumSounds / PER_PAGE)
            elseif NumSounds > 1 then
                NumCategories = 1
            else
                NumCategories = 0
            end
    
            -- find the selected index
            local selectedIndex = 0
            local selectedPage = 0
            for i = 1, #SoundDB do
                local sound = SoundDB[i]
                if (sound == opt.env.Priest_CooldownAudio) then
                    selectedPage = floor(i / PER_PAGE) + 1
                    break
                end
            end
    
            -- #1 option is to play major cooldown sound
            if (not level or level == 1) then
                local defaultOption = UIDropDownMenu_CreateInfo()
                local cooldownText = major_cooldown
                defaultOption.text = cooldownText
                defaultOption.arg1 = cooldownText
                defaultOption.value = cooldownText
                defaultOption.func = function(self)
                    opt.env.Priest_CooldownAudio = cooldownText
                    module:PlayAudioSound()
                    LibDD:UIDropDownMenu_SetSelectedValue(opt.ui.CooldownSound, cooldownText)
                    LibDD:UIDropDownMenu_SetText(opt.ui.CooldownSound, cooldownText)
                    LibDD:CloseDropDownMenus()
                end
                LibDD:UIDropDownMenu_AddButton(defaultOption)
            end
    
            -- build the page
            if (NumSounds > 1 and (level == 1 or level == nil)) then
                
                -- add categories
                for i = 1, NumCategories do
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = "Page " .. i
                    info.func = nil
                    info.hasArrow = true
                    info.menuList = i
                    info.checked = (selectedPage == i)
                    LibDD:UIDropDownMenu_AddButton(info)
                end
    
            elseif (menuList or NumSounds == 1) then
    
                local startIdx = (menuList and (menuList-1) * PER_PAGE) or 1
                local endIdx = startIdx + PER_PAGE
    
                for i = 1, #SoundDB do
    
                    if (i >= startIdx and i < endIdx) then
                    
                        local sound = SoundDB[i]
    
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = sound
                        info.arg1 = sound
                        info.value = sound
                        info.checked = (opt.env.Priest_CooldownAudio == sound)
    
                        info.func = function(self)
                            opt.env.Priest_CooldownAudio = self.value
                            module:PlayAudioSound()
                            LibDD:UIDropDownMenu_SetSelectedValue(opt.ui.CooldownSound, opt.env.Priest_CooldownAudio)
                            LibDD:UIDropDownMenu_SetText(opt.ui.CooldownSound, opt.env.Priest_CooldownAudio)
                            LibDD:CloseDropDownMenus()
                        end
                        LibDD:UIDropDownMenu_AddButton(info, level)
                    end
                end
            end
        end)
    
        LibDD:UIDropDownMenu_SetWidth(opt.ui.CooldownSound, 220)
        opt.ui.CooldownSound:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -32)
    
        if (opt.env.Priest_CooldownAudio and opt.env.Priest_CooldownAudio ~= "") then
            LibDD:UIDropDownMenu_SetSelectedValue(opt.ui.CooldownSound, opt.env.Priest_CooldownAudio)
            LibDD:UIDropDownMenu_SetText(opt.ui.CooldownSound, opt.env.Priest_CooldownAudio)
        else
            LibDD:UIDropDownMenu_SetSelectedValue(opt.ui.CooldownSound, major_cooldown)
        end
    
        -- audio label

        local soundLabel = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        soundLabel:SetText(opt.titles.Priest_Sound)
        soundLabel:SetPoint('BOTTOMLEFT', opt.ui.CooldownSound, 'TOPLEFT', 20, 6)
        opt:AddTooltip(soundLabel, opt.titles.Priest_Sound, opt.titles.Priest_SoundTooltip)
        opt:AddTooltip(opt.ui.CooldownSound, opt.titles.Priest_Sound, opt.titles.Priest_SoundTooltip)

        -- audio channel

        opt.ui.CooldownChannel =  LibDD:Create_UIDropDownMenu("CDSyncPriestChannelDropdown", opt.ui.main)
        LibDD:UIDropDownMenu_Initialize(opt.ui.CooldownChannel, function(self, level, menuList)

            local callback = function(self)
                opt.env.Priest_CooldownChannel = self.value
                LibDD:UIDropDownMenu_SetSelectedValue(opt.ui.CooldownChannel, opt.env.Priest_CooldownChannel)
                LibDD:CloseDropDownMenus()
                module:PlayAudioSound()
            end

            local add_func = function(value)
                local info = UIDropDownMenu_CreateInfo()
                info.text = value
                info.arg1 = value
                info.value = value
                info.func = callback
                LibDD:UIDropDownMenu_AddButton(info)
            end

            add_func("Master")
            add_func("Music")
            add_func("SFX")
            add_func("Ambience")

        end)
        LibDD:UIDropDownMenu_SetWidth(opt.ui.CooldownChannel, 220)
        opt.ui.CooldownChannel:SetPoint("TOPLEFT", opt.ui.CooldownSound, "BOTTOMLEFT", 0, -32)

        if (opt.env.Priest_CooldownChannel and opt.env.Priest_CooldownChannel ~= "") then
            LibDD:UIDropDownMenu_SetSelectedValue(opt.ui.CooldownChannel, opt.env.Priest_CooldownChannel)
            LibDD:UIDropDownMenu_SetText(opt.ui.CooldownChannel, opt.env.Priest_CooldownChannel)
        else
            LibDD:UIDropDownMenu_SetSelectedValue(opt.ui.CooldownChannel, "Master")
        end

        -- channel label

        local channelHeader = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        channelHeader:SetText(opt.titles.Priest_Channel)
        channelHeader:SetPoint('BOTTOMLEFT', opt.ui.CooldownChannel, 'TOPLEFT', 20, 6)
        opt:AddTooltip(channelHeader, opt.titles.Priest_Channel, opt.titles.Priest_ChannelTooltip)
        opt:AddTooltip(opt.ui.CooldownChannel, opt.titles.Priest_Channel, opt.titles.Priest_ChannelTooltip)

         -- frame glow

        local glow = opt:CreateCheckBox(opt, 'Priest_ShowFrameGlow')
        glow:SetPoint("TOPLEFT", opt.ui.CooldownChannel, "BOTTOMLEFT", 16, -12)
        glow:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                opt:ForceUiUpdate()
            end)
        opt:AddTooltip(glow, opt.titles.Priest_ShowFrameGlowHeader, opt.titles.Priest_ShowFrameGlowTooltip)
        
    end

    function module:OnBuddyEditChanged(box, buddy, submit_button)

        if (box:GetText() == buddy) then
            submit_button:Disable()
        else
            submit_button:Enable()
        end

    end

    function module:ApplyBuddy(frame, button, is_raid)
        
        local frameText = strlower(frame:GetText())
	    if (frameText == strlower(opt.PlayerName)) then
		    frame:SetText('')
            return
        end

        local previous
        if is_raid then
            previous = opt.env.Priest_RaidBuddy
        else
            previous = opt.env.Priest_Buddy
        end

        if frameText == strlower(previous) then
            return
        end

        -- replace previous buddy
        self.buddy:RemoveBuddy(previous, is_raid)
        if (frameText ~= '') then
            self.buddy:RegisterBuddy(frame:GetText())
        end

        if is_raid then
            opt.env.Priest_RaidBuddy = frame:GetText()
            module:RefreshPriestMacros(false)
        else
            opt.env.Priest_Buddy = frame:GetText()
            module:RefreshPriestMacros(true)
        end

        frame:ClearFocus()
		button:Disable()
        opt:ForceUiUpdate()
        
    end

    function module:update_slow()
        self:UpdateMacros()
    end

    function module:PlayAudioSound()
        opt:PlayAudio(opt.env.Priest_CooldownAudio, opt.env.Priest_CooldownChannel)
    end

    function module:ability_begin(guid, ability)
        local buddy = self.buddy:FindBuddyByGuid(guid)
        if not buddy then end
        self:PlayAudioSound()
        if opt.env.Priest_ShowFrameGlow then
            buddy:Glow()
        end
    end

    function module:ability_end(guid, ability)
        local buddy = self.buddy:FindBuddyByGuid(guid)
        if not buddy then end
        buddy:EndGlow()
    end

    function module:main_frame_right_click()
        local name = GetUnitName("target", true)
        if (UnitIsPlayer("target") and name and name ~= opt.PlayerName) then
            if opt.InRaid then
                opt.ui.buddyEditBoxRaid:SetText(name)
                opt.ui.buddyEditBoxRaid:SetCursorPosition(0)
                module:ApplyBuddy(opt.ui.buddyEditBox, opt.ui.buddySubmitBtn, true)
            else
                opt.ui.buddyEditBox:SetText(name)
                opt.ui.buddyEditBox:SetCursorPosition(0)
                module:ApplyBuddy(opt.ui.buddyEditBox, opt.ui.buddySubmitBtn, false)
            end
            module:RefreshPriestMacros(opt.InRaid)
        end
    end

    function module:ability_frame_double_click(row)
        if not row or not row.player then return end
        
        if opt.InRaid then
            if row.player == opt.env.Priest_RaidBuddy then
                opt.ui.buddyEditBoxRaid:SetText('')
                opt.ui.buddyEditBoxRaid:SetCursorPosition(0)
                module:ApplyBuddy(opt.ui.buddyEditBox, opt.ui.buddySubmitBtn, true)
            end
        else
            if row.player == opt.env.Priest_Buddy then
                opt.ui.buddyEditBox:SetText('')
                opt.ui.buddyEditBox:SetCursorPosition(0)
                module:ApplyBuddy(opt.ui.buddyEditBox, opt.ui.buddySubmitBtn, false)
            end
        end
    end

    function module:post_init()
        if not opt:StringNilOrEmpty(opt.env.Priest_Buddy) then
            self.buddy:SetClassBuddy(opt.env.Priest_Buddy, false)
        end

        if not opt:StringNilOrEmpty(opt.env.Priest_RaidBuddy) then
            self.buddy:SetClassBuddy(opt.env.Priest_RaidBuddy, true)
        end
    end

    module:BuildMacroPanel()
    return module
end