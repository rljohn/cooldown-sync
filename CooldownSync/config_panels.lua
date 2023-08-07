---@diagnostic disable: undefined-field
local opt = CooldownSyncConfig
local ADDON_VERSION = "<VERSION>"

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function opt:CreateWidgets()

	local HEADER_OFFSET = -32

	-- version
	
	local version = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	version:SetFontObject("GameFontNormalSmall")
	version:SetTextColor(1,1,1,0.5)
	version:SetPoint('TOPRIGHT', -5, 0)
	version:SetText(string.format("Cooldown Sync (%s) by rljohn", ADDON_VERSION))
	
	-- frame panel
		
	opt.ui.main = opt:CreatePanel(opt, nil, 585, 175)
	opt.ui.main:SetPoint('TOPLEFT', opt, 'TOPLEFT', 25, -48)

	-- title

	opt.ui.controlsTitle = opt:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	opt.ui.controlsTitle:SetText(opt.titles.CooldownSync)
	opt.ui.controlsTitle:SetPoint('TOPLEFT', opt.ui.main, 'TOPLEFT', 0, 32)

	-- show (visibility)

	opt.ui.showOptionsLabel = opt:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	opt.ui.showOptionsLabel:SetText(opt.titles.ShowText)
	opt.ui.showOptionsLabel:SetPoint('TOPLEFT', opt.ui.main, 'TOPLEFT', 8, -8)
		
	opt.ui.showOptions = LibDD:Create_UIDropDownMenu("PIBuddyShowOptionsDropdown", opt.ui.main)
	opt.ui.showOptions:SetPoint('TOPLEFT', opt.ui.showOptionsLabel, 'BOTTOMLEFT', -20, -8)
	LibDD:UIDropDownMenu_Initialize(opt.ui.showOptions, function(self, level, menuList)
	
		local info = LibDD:UIDropDownMenu_CreateInfo()
		info.func = function(self, arg1, arg2, checked)
			LibDD:UIDropDownMenu_SetSelectedValue(opt.ui.showOptions, arg1)
			opt.env.ShowButton = arg1
			opt:ForceUiUpdate()
		end
		
		info.text, info.value, info.arg1, info.arg2 = "Show Always", 1, 1, "Show Always"
		LibDD:UIDropDownMenu_AddButton(info)

		info.text, info.value, info.arg1, info.arg2 = "Combat Only", 2, 2, "Combat Only"
		LibDD:UIDropDownMenu_AddButton(info)
		
		info.text, info.value, info.arg1, info.arg2 = "Group Only", 3, 3, "Group Only"
		LibDD:UIDropDownMenu_AddButton(info)

		info.text, info.value, info.arg1, info.arg2 = "With Buddy Only", 4, 4, "With Buddy Only"
		LibDD:UIDropDownMenu_AddButton(info)
		
		info.text, info.value, info.arg1, info.arg2 = "Never", 5, 5, "Never"
		LibDD:UIDropDownMenu_AddButton(info)
		
		LibDD:UIDropDownMenu_SetSelectedValue(opt.ui.showOptions, opt.env.ShowButton)
	end)
	opt:AddTooltip(opt.ui.showOptionsLabel, opt.titles.ShowText, opt.titles.ShowTextTooltip)
	opt:AddTooltip(opt.ui.showOptions, opt.titles.ShowText, opt.titles.ShowTextTooltip)

	-- lock button

	opt.ui.lock = opt:CreateCheckBox(opt, 'LockButton')
	opt.ui.lock:SetPoint("TOPLEFT", opt.ui.showOptionsLabel, "TOPLEFT", 0, -58)
	opt.ui.lock:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			if (self:GetChecked()) then
				opt:Lock()
			else
				opt:Unlock()
			end
		end)
	opt:AddTooltip(opt.ui.lock, opt.titles.LockButtonHeader, opt.titles.LockButtonTooltip)
	
	-- show background
	
	opt.ui.showBackground = opt:CreateCheckBox(opt, 'ShowBackground')
	opt.ui.showBackground:SetPoint("TOPLEFT", opt.ui.lock, "TOPLEFT", 0, -25)
	opt.ui.showBackground:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.showBackground, opt.titles.ShowBackgroundHeader, opt.titles.ShowBackgroundTooltip)
	
	-- show title
	
	opt.ui.showTitle = opt:CreateCheckBox(opt, 'ShowTitle')
	opt.ui.showTitle:SetPoint("TOPLEFT", opt.ui.showBackground, "TOPLEFT", 0, -25)
	opt.ui.showTitle:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ForceUiUpdate()
			opt:ModuleEvent_OnResize()
		end)
	opt:AddTooltip(opt.ui.showTitle, opt.titles.ShowTitleHeader, opt.titles.ShowTitleTooltip)
	
	opt.ui.showMinimap = opt:CreateCheckBox(opt, 'ShowMinimapIcon')
	opt.ui.showMinimap:SetPoint("TOPLEFT", opt.ui.showTitle, "TOPLEFT", 0, -25)
	opt.ui.showMinimap:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:MinimapUpdate()
		end)
	opt:AddTooltip(opt.ui.showMinimap, opt.titles.ShowMinimapHeader, opt.titles.ShowMinimapTooltip)

	-- size

	opt.ui.iconSize = opt:CreateSlider(opt, 'IconSize', 32, 96, 8, 140)
	opt.ui.iconSize:SetPoint("TOPLEFT", opt.ui.main, "TOPLEFT", 205, -26)
	opt.ui.iconSize:SetScript("OnValueChanged", function(self, value, ...)
			local changed = opt:OnSliderValueChanged(self, value)
			if changed then
				opt:ModuleEvent_OnResize()
			end
		end)
	opt:AddTooltip(opt.ui.iconSize, opt.titles.IconSize, opt.titles.IconSizeTooltip)

	-- frame glow

	opt.ui.icon_glow = opt:CreateCheckBox(opt, 'ShowSpellGlow')
	opt.ui.icon_glow:SetPoint("TOPLEFT", opt.ui.lock, "TOPLEFT", 200, 0)
	opt.ui.icon_glow:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ModuleEvent_OnSettingsChanged()
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.icon_glow, opt.titles.ShowSpellGlowHeader, opt.titles.ShowSpellGlowTooltip)

	-- spell timers

	opt.ui.spell_timers = opt:CreateCheckBox(opt, 'ShowSpellTimers')
	opt.ui.spell_timers:SetPoint("TOPLEFT", opt.ui.icon_glow, "TOPLEFT", 0, -25)
	opt.ui.spell_timers:SetScript('OnClick', function(self, event, ...)
			opt:CheckBoxOnClick(self)
			opt:ModuleEvent_OnSettingsChanged()
			opt:ForceUiUpdate()
		end)
	opt:AddTooltip(opt.ui.spell_timers, opt.titles.ShowSpellTimersHeader, opt.titles.ShowSpellTimersTooltip)

end

-- Widget Visiblility

function opt:ForceUiUpdate()

	if (opt.main == nil) then return end

	local show = true

	if (opt.env.ShowButton == true) then
		show = true
	elseif (not opt.InCombat and opt.env.ShowButton == 2) then -- in combat only
		show = false
	elseif (not opt.InGroup and opt.env.ShowButton == 3) then -- in group only
		show = false
	elseif (not opt.InGroup and opt.env.ShowButton == 4) then -- with buddy only
		show = false
	elseif (opt.env.ShowButton == 5) then -- show never
		show = false
	end

	if (show) then
		if (not opt.main:IsShown()) then
			opt:ShowMainFrame()
		end
	elseif (opt.main:IsShown()) then
		opt:HideMainFrame()
	end

	opt:SetMainFrameBackgroundVisible(opt.env.ShowBackground)
	opt:SetMainFrameTitleVisible(opt.env.ShowTitle)
end
