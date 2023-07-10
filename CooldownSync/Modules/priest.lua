---@diagnostic disable: param-type-mismatch
local opt = CooldownSyncConfig

function opt:AddPriestModule()
    module = opt:BuildClassModule("priest")

    function module.load_default_values()

        opt:SetDefaultValue('Priest_PriestBuddy', "")
        opt:SetDefaultValue('Priest_DpsBuddy', "")
        opt:SetDefaultValue('Priest_RaidPriestBuddy', "")
        opt:SetDefaultValue('Priest_RaidDpsBuddy', "")

        opt:SetDefaultValue('Priest_DpsCooldownAudio', "None")
        opt:SetDefaultValue('Priest_PiMeAudio', "None")

        opt:SetDefaultValue('Priest_Trinket1Party', true)
        opt:SetDefaultValue('Priest_Trinket1Raid', true)
        opt:SetDefaultValue('Priest_Trinket2Party', true)
        opt:SetDefaultValue('Priest_Trinket2Raid', true)
        opt:SetDefaultValue('Priest_GenerateMacroParty', false)
        opt:SetDefaultValue('Priest_GenerateMacroRaid', false)
        opt:SetDefaultValue('Priest_PIFocusParty', false)
        opt:SetDefaultValue('Priest_PIFocusRaid', false)
        opt:SetDefaultValue('Priest_PIFriendlyParty', true)
        opt:SetDefaultValue('Priest_PIFriendlyRaid', true)
        opt:SetDefaultValue('Priest_PITargetLastTargetParty', true)
        opt:SetDefaultValue('Priest_PITargetLastTargetRaid', true)
    end

    function module:BuildMacroPanel()

        local pi_macros = CreateFrame('FRAME', 'CDSyncPIMacros', opt)
        pi_macros.name = 'Priest Macros'
        pi_macros.ShouldResetFrames = false
        pi_macros.parent = opt.name
        InterfaceOptions_AddCategory(pi_macros)

        self:CreatePIMacroPanel(true, pi_macros, 25, -48)
        self:CreatePIMacroPanel(false, pi_macros, 25, -330)
    end

    function module:CheckMacros()
        cdDiagf("Check Macros")
        self.ExportMacrosRaid = opt.InRaid and opt.env.Priest_GenerateMacroRaid
        self.ExportMacros = opt.InGroup and opt.env.Priest_GenerateMacroParty
    end

    function module:GetMacroText(party)
        local text = '#showtooltip Power Infusion'
 
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
            if (opt.env.Priest_DpsBuddy and opt.env.Priest_DpsBuddy ~= "") then
                text = text .. string.format('\n/cast [@%s,help,nodead] Power Infusion', opt.env.Priest_DpsBuddy)
                text = text .. string.format('\n/stopmacro [@%s,help,nodead]', opt.env.Priest_DpsBuddy)
            end
        else
            if (opt.env.Priest_RaidDpsBuddy and opt.env.Priest_RaidDpsBuddy ~= "") then
                text = text .. string.format('\n/cast [@%s,help,nodead] Power Infusion', opt.env.Priest_RaidDpsBuddy)
                text = text .. string.format('\n/stopmacro [@%s,help,nodead]', opt.env.Priest_RaidDpsBuddy)
            end
        end

        -- focus

            if ((party and opt.env.Priest_PIFocusParty) or (not party and opt.env.Priest_PIFocusRaid)) then
                text = text .. '\n/cast [focus,help,nodead] Power Infusion'
            end

        -- friendly

        if ((party and opt.env.Priest_PIFriendlyParty) or (not party and opt.env.Priest_PIFriendlyRaid)) then
            text = text .. '\n/targetfriendplayer [nohelp]'
            text = text .. '\n/cast [help] Power Infusion'

            if ((party and opt.env.Priest_PITargetLastTargetParty) or (not party and opt.env.Priest_PITargetLastTargetRaid)) then
                text = text .. '\n/targetlasttarget [help]'
            end
        end

        -- self

        text = text .. '\n/cast [@player] Power Infusion'

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

        local index = GetMacroIndexByName("CDSyncPriest");
        if (index == 0) then
            CreateMacro("CDSyncPriest", "135939", text, false)
        else
            EditMacro(index, "CDSyncPriest", "135939", text)
        end
    end

    function module:RefreshPIMacros(party)

        local text = self:GetMacroText(party)
        if (not text) then return end

        if (party) then
            self.macroEditBox:SetText(text)
        else
            self.macroEditBoxRaid:SetText(text)
        end

        cdDiagf("Refresh Macros")
        self:CheckMacros()
    end

    function module:CreatePIMacroPanel(party, parent, x, y)

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
        if (party) then use_focus = opt:CreateCheckBox(parent, 'Priest_PIFocusParty') else use_focus = opt:CreateCheckBox(parent, 'Priest_PIFocusRaid') end
        use_focus:SetPoint("TOPLEFT", macro_panel, "TOPRIGHT", 8, 0)
        use_focus:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                module:RefreshPIMacros(party)
            end)
        opt:AddTooltip(use_focus, opt.titles.PIFocusParty, opt.titles.PIFocusTooltip)

        local use_friendly
        if (party) then use_friendly = opt:CreateCheckBox(parent, 'Priest_PIFriendlyParty') else use_friendly = opt:CreateCheckBox(parent, 'Priest_PIFriendlyRaid') end
        use_friendly:SetPoint("TOPLEFT", use_focus, "BOTTOMLEFT", 0, -8)
        use_friendly:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                module:RefreshPIMacros(party)
            end)
        opt:AddTooltip(use_friendly, opt.titles.PIFriendlyParty, opt.titles.PIFriendlyTooltip)

        -- trinket 1

        local trinket1, trinket2
        if (party) then trinket1 = opt:CreateCheckBox(parent, 'Priest_Trinket1Party') else trinket1 = opt:CreateCheckBox(parent, 'Priest_Trinket1Raid') end
        trinket1:SetPoint("TOPLEFT", use_friendly, "BOTTOMLEFT", 0, -8)
        trinket1:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                module:RefreshPIMacros(party)
            end)
        opt:AddTooltip(trinket1, opt.titles.Trinket1Party, opt.titles.Trinket1Tooltip)

        -- trinket 2

        if (party) then trinket2 = opt:CreateCheckBox(parent, 'Priest_Trinket2Party') else trinket2 = opt:CreateCheckBox(parent, 'Priest_Trinket2Raid') end
        trinket2:SetPoint("TOPLEFT", trinket1, "BOTTOMLEFT", 0, -8)
        trinket2:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                module:RefreshPIMacros(party)
            end)
        opt:AddTooltip(trinket2, opt.titles.Trinket2Party, opt.titles.Trinket2Tooltip)

        -- target last target

        local tlt
        if (party) then tlt = opt:CreateCheckBox(parent, 'Priest_PITargetLastTargetParty') else tlt = opt:CreateCheckBox(parent, 'Priest_PITargetLastTargetRaid') end
        tlt:SetPoint("TOPLEFT", trinket2, "BOTTOMLEFT", 0, -8)
        tlt:SetScript('OnClick', function(self, event, ...)
                opt:CheckBoxOnClick(self)
                module:RefreshPIMacros(party)
            end)
        opt:AddTooltip(tlt, opt.titles.PITargetLastTargetParty, opt.titles.PITargetLastTargetTooltip)

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
        opt:AddTooltip(autogenerate, opt.titles.GenerateMacroParty, opt.titles.GenerateMacroPartyTooltip)

        -- cache the boxes

        if (party) then
            self.macroEditBox = editBox
        else
            self.macroEditBoxRaid = editBox
        end

        self:RefreshPIMacros(party)
    end

    function module:update_slow()
        self:UpdateMacros()
    end

    module:BuildMacroPanel()
    return module
end