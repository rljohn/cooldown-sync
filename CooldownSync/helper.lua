---@diagnostic disable: param-type-mismatch, missing-fields
local opt = CooldownSyncConfig

function opt:Clamp(value, min_value, max_value)
	return math.max(min_value, math.min(max_value, value))
end

-- Panels

function opt:CreatePanel(parent, name, width, height)
	local panel = CreateFrame("Frame", name, parent)
	panel:SetSize(width, height)
	
	local bg = CreateFrame('Frame', nil, panel, "BackdropTemplate")

---@diagnostic disable-next-line: param-type-mismatch
	bg:SetBackdrop({
        bgFile = 'interface/buttons/white8x8',
        edgeFile = 'Interface/Tooltips/UI-Tooltip-border',
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	
---@diagnostic disable-next-line: param-type-mismatch
	bg:SetBackdropColor(.1,.1,.1,.3)

---@diagnostic disable-next-line: param-type-mismatch
	bg:SetBackdropBorderColor(1, 1, 1)

	bg:SetPoint('TOPLEFT', panel, -10, 10)
	bg:SetPoint('BOTTOMRIGHT', panel, 30, -10)
	bg:SetFrameStrata("MEDIUM")
	bg:SetFrameLevel(0)
	
	return panel
end

function opt:CreateAbilityRow(parent, name, width, height, player)
	local panel = CreateFrame("Frame", name, parent)
	panel:SetSize(width, height)

	panel.header = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	panel.header:SetText(player)
	panel.header:SetPoint('TOPLEFT', panel, 'TOPLEFT', 0, 0)

	panel.status = panel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	panel.status:SetText("No Talent Info")
	panel.status:SetPoint('TOPLEFT', panel, 'TOPLEFT', 0, -16)

	local clickCount = 0
	local clickTime = 0
	local clickThreshold = 0.3 -- Time threshold for a double-click in seconds

	panel:SetScript('OnMouseUp', function(self, button, ...)
		if (button == "LeftButton") then
			local currentTime = GetTime()

			-- Check if it's a double-click
			if clickCount == 1 and currentTime - clickTime <= clickThreshold then

				-- Perform the desired action for a double-click
				opt:ModuleEvent_OnRowDoubleClick(panel)

				-- Reset click count and time
				clickCount = 0
				clickTime = 0
			else
				-- Not a double-click, update click count and time
				clickCount = 1
				clickTime = currentTime

				-- Start a timer to reset click count and time
				C_Timer.After(clickThreshold, function()
					clickCount = 0
					clickTime = 0
				end)
			end
		end
	end)

	return panel
end

-- Tooltips

function opt:OnTooltipEnter(self)
	
	if not self.tooltipText then
		return
	end
	
	GameTooltip:SetOwner(self,'ANCHOR_TOPLEFT')
	
	if self.tooltipTitle then
		GameTooltip:AddLine(self.tooltipTitle)
	end
	
	GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
	
	if self.tooltipText2 then
		GameTooltip:AddLine(self.tooltipText2, 1, 1, 1, true)
	end
	
	GameTooltip:Show()
end

function opt:OnTooltipLeave(self)
	if not self.tooltipText then
		return
	end
	
    GameTooltip:Hide()
end

function opt:AddTooltip2(frame, title, text, text2)
	frame:EnableMouse(true)
	frame.tooltipTitle = title
	frame.tooltipText = text
	frame.tooltipText2 = text2
	frame:SetScript('OnEnter',function(self)
			opt:OnTooltipEnter(self)
		end)
    frame:SetScript('OnLeave',function(self)
			opt:OnTooltipLeave(self)
		end)
		
	if (frame.label) then
		opt:AddTooltip2(frame.label, title, text, text2)
	end
end

function opt:AddTooltip(frame, title, text)
	opt:AddTooltip2(frame, title, text, nil)
end

function opt:ReplaceTooltip(frame, title, text)
	frame.tooltipTitle = title
	frame.tooltipText = text
end

-- Checkbox

function opt:CheckBoxOnClick(self)
	opt.env[self.id] = self:GetChecked()
		
	if self:GetChecked() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) 
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
end

function opt:CreateCheckBox(parent, name)
	local check = CreateFrame('CheckButton', 'CD_' .. name, parent, 'OptionsBaseCheckButtonTemplate')
	check.id = name
	check:Raise()
	
	check.label = check:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
	check.label:SetText(opt.titles[name] or name or '!MissingTitle')
	check.label:SetPoint('LEFT', check, 'RIGHT', 4, 0)
	check.label.check = check
	check:SetChecked(opt.env[name])

---@diagnostic disable-next-line: undefined-field
	check.label:SetScript('OnMouseDown', function(self, button, ...)
		if (button == 'LeftButton' and self.check:IsEnabled()) then
			self.check:Click()
		end
	end)
	
	return check
end

-- Slider

function opt:OnSliderValueChanged(self, value)
	local previous = opt.env[self.id]
	if previous == value then return false end

	local strval = string.format("%.2f", value)
	opt.env[self.id] = value
	self.label:SetText(strval)
	return true
end

function opt:CreateSlider(parent, name, minval, maxval, stepvalue, width)
	local slider = CreateFrame("Slider", 'CD_' .. name, parent, "OptionsSliderTemplate")
	slider.id = name
	slider:SetOrientation("HORIZONTAL")
	slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Vertical]])
	slider:SetMinMaxValues(minval, maxval)
	slider:SetWidth(width)
	slider:SetHeight(16)
	slider:SetValueStep(stepvalue)
	slider:SetObeyStepOnDrag(true)
	slider.title = opt.titles[name]
	
	getglobal('CD_' .. name .. 'Low'):SetText(tostring(minval)); --Sets the left-side slider text (default is "Low").
	getglobal('CD_' .. name .. 'High'):SetText(tostring(maxval)); --Sets the right-side slider text (default is "High").
	getglobal('CD_' .. name .. 'Text'):SetText(opt.titles[name] or name or '!MissingTitle'); --Sets the "title" text (top-centre of slider).
 
 	slider:SetValue(opt.env[name])
	
	local strval = string.format("%.2f", opt.env[name])
	slider.label = parent:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	slider.label:SetText(strval)
	slider.label:SetPoint('BOTTOM', slider, 0, -10)
	return slider;
end

-- Edit Box

function opt:CreateEditBox(parent, name, maxLetters, width, height)
	local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	box:SetAutoFocus(false)
	box:ClearFocus()
	box:SetAutoFocus(false)
	box:EnableMouse(true)
	box:SetMultiLine(false)
	box:SetMaxLetters(maxLetters)
	box:SetSize(width, height)
	return box
end

-- Is Player a Party Member

function opt:IsPartyMember(n)

	n = strlower(n)

	if (IsInRaid()) then
		for i = 1, MAX_RAID_MEMBERS do
			name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(i)
			if (name) then
				name = strlower(name)
				local unitId = "raid" .. i
				if (name == n) then
					return true
				end
			end
		end
	elseif (IsInGroup()) then
		for i = 1, 4 do
			local unitId = "party" .. i
			local name = GetUnitName(unitId, true)
			if (name) then
				if (strlower(name) == n) then
					return true
				end
			end
		end
	end

	return false

end

-- Talents

local LibTalentTree = nil
function opt:GetTalentNodeForSpell(spell_id)
	if (LibTalentTree == nil) then
		LibTalentTree = LibStub("LibTalentTree-1.0")
	end	

	if (LibTalentTree) then		
		local treeId = LibTalentTree:GetClassTreeId(opt.ClassName);
		local nodes = C_Traits.GetTreeNodes(treeId);
		local configId = C_ClassTalents.GetActiveConfigID();
		for _, nodeId in ipairs(nodes) do
			local nodeInfo = LibTalentTree:GetLibNodeInfo(treeId, nodeId);
---@diagnostic disable-next-line: param-type-mismatch
			local entryInfo = C_Traits.GetEntryInfo(configId, nodeInfo.entryIDs[1]);

			local definitionId = entryInfo.definitionID
			local def = C_Traits.GetDefinitionInfo(definitionId)
			if (def.spellID == spell_id) then
				return nodeId
			end
		end

	end
end

function opt:HasTalentNode(nodeId)
	local configId = C_ClassTalents.GetActiveConfigID();
	if (configId) then
		local nodeInfo = C_Traits.GetNodeInfo(configId, nodeId)
		if (nodeInfo) then
			return (nodeInfo.ranksPurchased > 0)
		end
	end

	return false
end

-- strings

function opt:SpaceStripper(str)
	if (not str) then return str end
	return string.gsub(str, "[^%S\n]+", "")
end

function opt:TimeRemainingString(time_remaining)
	if (time_remaining > 60) then
		local minutes = math.floor(time_remaining / 60)
  		local remainingSeconds = time_remaining % 60
  		return string.format("%d:%02d", minutes, remainingSeconds)
	else
		return string.format("%d", time_remaining)
	end
end

-- auras

function opt:GetAuraDuration(unit_id, spell_id)

	local result = -1
	AuraUtil.ForEachAura(unit_id, "HELPFUL", nil, function(name, icon, _, _, duration, expirationTime, _, _, _, spellId, ...)
		if (spellId == spell_id) then
			if (expirationTime and expirationTime > 0) then
				result = expirationTime - GetTime()
			end

			return true
		end
	end)
	
	return result
end

-- tables

function opt:pairsByKeys (t, f)
	local a = {}
  
	for n in pairs(t) do table.insert(a, n) end
  
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
	  i = i + 1
	  if a[i] == nil then 
		  return nil
	  else 
		  return a[i], t[a[i]]
	  end
	end
	return iter
  end

function opt:GetTableSize(t)
	local count = 0
	for _ in pairs(t) do
	  count = count + 1
	end
	return count
  end

function opt:TableContainsValue(t, v)
	for _, value in pairs(t) do
		if (value == v) then
			return true
		end
	end

	return false
end

function opt:TableContainsKey(t, k)
	return t[k] ~= nil
end

function opt:RemoveValueFromTable(tbl, value)
	local indicesToRemove = {}
  
	-- Find indices of elements to remove
	for index, val in pairs(tbl) do
	  if val == value then
		table.insert(indicesToRemove, index)
	  end
	end
  
	-- Remove elements
	for i = #indicesToRemove, 1, -1 do
	  table.remove(tbl, indicesToRemove[i])
	end
  end

-- players

-- Player Lookup

function opt:GetUnitInfo(n)

	if (n == nil or n == "") then return nil end
	n = strlower(n)

	-- is it a local player
	
	local localPlayer = strlower(opt.PlayerName)
	if (localPlayer == n) then
		local unitId = "player"
		local info = {}
		info.unit_id = unitId
		info.guid = UnitGUID(unitId)
		info.name = name
		return info
	end

	local focus = UnitName("focus")
	if (focus) then
		local focusPlayer = strlower(focus)
		if (focusPlayer == n) then
			local unitId = "focus"
			local info = {}
			info.unit_id = unitId
			info.guid = UnitGUID(unitId)
			info.name = name
			return info
		end
	end

	-- check raid members, party members
	
	if (IsInRaid()) then
		for i = 1, MAX_RAID_MEMBERS do
			local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(i)
			if (name) then
				name = strlower(name)
				local unitId = "raid" .. i
				if (name == n) then
					local info = {}
					info.unit_id = unitId
					info.guid = UnitGUID(unitId)
					info.name = name
					return info
				end
			end
		end
	elseif (IsInGroup()) then
		for i = 1, 4 do
			local unitId = "party" .. i
			local name = GetUnitName(unitId, true)
			if (name) then
				if (strlower(name) == n) then
					local info = {}
					info.unit_id = unitId
					info.guid = UnitGUID(unitId)
					info.name = name
					return info
				end
			end
		end
	end
	
	return nil
end

-- Audio

local media = LibStub("LibSharedMedia-3.0")

function opt:PlayAudio(sound, channel)
	if not sound or sound == "None" then return end

	if (sound == "Power Infusion") then
		PlaySound(170678, channel)
	elseif (sound == "Blessing of Summer") then
		PlaySound(160074, channel)
	else
		local soundFile = media:Fetch("sound", sound)
		if (soundFile) then
			PlaySoundFile(soundFile, "Master")
		end
	end
end

-- Strings

function opt:StringNilOrEmpty(str)
	if not str then return true end
	if str == "" then return true end
	if str:match("^%s*$") then return true end
	return false
end

function opt:Round(number)
    return math.floor(number + 0.5)
end

-- Raid

function opt:IsRaidDifficulty(difficulty_id)
	if(difficulty_id == 3 or -- 10m raid
		difficulty_id == 4 or -- 25m raid
		difficulty_id == 5 or -- 10m raid (heroic)
		difficulty_id == 6 or -- 25m raid (heroic)
		difficulty_id == 7 or -- LFR raid
		difficulty_id == 9 or -- 40m raid
		difficulty_id == 14 or -- normal
		difficulty_id == 15 or -- heroic
		difficulty_id == 16 or -- raid
		difficulty_id == 17 or -- LFR
		difficulty_id == 33    -- timewalking
	) then return true else return false end
end