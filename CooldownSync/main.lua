local opt = CooldownSyncConfig
local main
local PADDING = 16

function opt:CreateMainFrame()

	-- main frame
		
	main = CreateFrame('FRAME', 'CooldownSync', UIParent, "BackdropTemplate")
	main:SetFrameStrata("BACKGROUND")
	main:SetWidth(300)
	main:SetHeight(200)
	
	if (opt.env.FrameX > 0 and opt.env.FrameY > 0) then
		main:SetPoint("TOPLEFT","UIParent","BOTTOMLEFT",opt.env.FrameX,opt.env.FrameY)
	else
		main:SetPoint("CENTER","UIParent","CENTER")
	end
	
	-- background
	
	main:SetBackdrop(
	{
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		edgeSize = 3,
		insets = { left = 1, right = 1, top = 1, bottom = 1 },
	})
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
	local ONUPDATE_INTERVAL = 0.05
	local TimeSinceLastUpdate = 0
	main:SetScript("OnUpdate", function(self, elapsed)
		TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
		if TimeSinceLastUpdate >= ONUPDATE_INTERVAL then
			TimeSinceLastUpdate = 0
			opt:OnUpdate(elapsed)
			opt:ModuleEvent_OnUpdate(elapsed)
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

function opt:OnResize()

	if (main == nil) then
		return
	end
	
	local width = PADDING	
	main:SetWidth(width)
	main:SetHeight(opt.env.IconSize + (2*PADDING))

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
