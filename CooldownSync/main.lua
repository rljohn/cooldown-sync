---@diagnostic disable: param-type-mismatch
local opt = CooldownSyncConfig
local main
local PADDING = 16

function opt:CreateMainFrame()

	-- main frame
		
	main = CreateFrame('FRAME', 'CooldownSync', UIParent, "BackdropTemplate")
	main:SetFrameStrata("BACKGROUND")
	main:SetWidth(300)
	main:SetHeight(220)
	
	if (opt.env.FrameX > 0 and opt.env.FrameY > 0) then
		main:SetPoint("TOPLEFT","UIParent","BOTTOMLEFT",opt.env.FrameX,opt.env.FrameY)
	else
		main:SetPoint("CENTER","UIParent","CENTER")
	end
	
	-- background
	
	main:SetBackdrop(
		{
			bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true,
			tileEdge = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 3, right = 5, top = 3, bottom = 5 },
		}
	)
	opt:SetMainFrameBackgroundVisible(opt.env.ShowBackground)
	
	-- mouse
	main:SetClampedToScreen(true)
	main:RegisterForDrag("LeftButton")
	
	if (opt.env.LockButton == false) then
		opt:UnlockMainFrame()
	end
	
	-- add text
	
	main.header = main:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	main.header:SetText(opt.titles.CooldownSync)
	main.header:SetPoint('TOPLEFT', main, 'TOPLEFT', 6, 14)
	opt:SetMainFrameTitleVisible(opt.env.ShowTitle)
	main:SetPoint("CENTER",0,0)	
	opt.main = main

	-- Tick
	local ONUPDATE_INTERVAL = 0.1
	local SLOWUPDATE_INTERVAL = 1

	local TimeSinceLastUpdate = 0
	local TimeSinceLastSlowUpdate = 0

	main:SetScript("OnUpdate", function(self, elapsed)

		-- 10Hz update frequency
		TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
		if TimeSinceLastUpdate >= ONUPDATE_INTERVAL then
			TimeSinceLastUpdate = 0
			opt:ModuleEvent_OnUpdate()
		end

		-- 1Hz update frequency
		TimeSinceLastSlowUpdate = TimeSinceLastSlowUpdate + elapsed
		if TimeSinceLastSlowUpdate >= SLOWUPDATE_INTERVAL then
			TimeSinceLastSlowUpdate = 0
			opt:ModuleEvent_OnSlowUpdate()
		end

	end)

	main:SetScript('OnMouseDown', function(self, button, ...)
		if (button == "RightButton") then
			opt:ModuleEvent_OnMainFrameRightClick()
		end
	end)

end

function opt:ShowMainFrame()
	main:Show()
end

function opt:HideMainFrame()
	main:Hide()
end

function opt:UnlockMainFrame()

	if (main == nil) then
		return
	end

	main:EnableMouse(true)
	main:SetMovable(true)
	
	main:SetScript ("OnDragStart", function() 
		main:StartMoving()
	end)
	
	main:SetScript ("OnDragStop", function() 
		main:StopMovingOrSizing() 
		local x, y = main:GetLeft(), main:GetTop()
		opt.env.FrameX = x
		opt.env.FrameY = y
	end)

end

function opt:LockMainFrame()
	if (main == nil) then
		return
	end
	
	main:EnableMouse(false)
	main:SetMovable(false)
	main:SetScript("OnDragStart", nil)
	main:SetScript("OnDragStop", nil)
end

function opt:SetMainFrameBackgroundVisible(visible)
	if (visible) then
		main:SetBackdropColor(0, 0, 0, .4)
		main:SetBackdropBorderColor(1, 1, 1, 0.4)
	else
		main:SetBackdropColor(0, 0, 0, 0)
		main:SetBackdropBorderColor(0, 0, 0, 0)
	end
end

function opt:SetMainFrameTitleVisible(visible)

	if (visible) then
		main.header:Show()
	else
		main.header:Hide()
	end
end
