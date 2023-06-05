local opt = CooldownSyncConfig
local ADDON_VERSION = "1.3"

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
		
	opt.ui.main = opt:CreatePanel(opt, nil, 580, 175)
	opt.ui.main:SetPoint('TOPLEFT', opt, 'TOPLEFT', 25, -48)
end

-- Widget Visiblility

function opt:ForceUiUpdate()

	if (opt.main == nil) then return end

end
