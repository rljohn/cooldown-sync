local folder,ns = ...

-- Setup the Interface Options

local frame_name = 'CooldownSyncConfig'
local opt = CreateFrame('FRAME',frame_name,InterfaceOptionsFramePanelContainer)
opt.Initialized = false
opt.name = 'Cooldown Sync'
opt.ShouldResetFrames = false
opt.UpdateInterval = 1.0
opt.TimeSinceLastUpdate = 0

-- misc info
opt.InGroup = false
opt.InCombat = false

-- class info
opt.PlayerGUID = 0
opt.PlayerName = ""
opt.PlayerRealm = ""
opt.ClassName = ""
opt.PlayerClass = 0
opt.PlayerSpec = 0
		
-- character environment data
opt.env = {}
opt.env.DB = {}

-- ui frames
opt.ui = {}

-- defaults

local function SetValue(key, value)
	opt.env[key] = value
end

local function SetDefaultValue(key, value)
	if (opt.env[key] == nil) then
		SetValue(key, value)
	end
end

function opt:ResetAll()
	opt.env = {}
	opt.env.DB = {}
	ReloadUI()
end

function opt:LoadMissingValues()

	-- options
	SetDefaultValue('DB', {})
	SetDefaultValue('ShowMinimapIcon', true)
	SetDefaultValue('ShowBackground', true)
	SetDefaultValue('ShowTitle', true)
	SetDefaultValue('LockButton', false)
	SetDefaultValue('IconSize', 48)
	SetDefaultValue('FrameX', -1)
	SetDefaultValue('FrameY', -1)
	
end

-- Main Interface Callbacks

function opt:OnLogin()

	-- init
	opt:BuildLogModule("logging")
	
	-- check name, realm
	opt.PlayerName = UnitName("player")
	opt.PlayerRealm = self:SpaceStripper(GetNormalizedRealmName())
	opt.PlayerGUID = UnitGUID("player")
	opt.PlayerNameRealm = string.format("%s-%s", opt.PlayerName, opt.PlayerRealm)
	opt.PlayerLevel = UnitLevel("player")

	-- check class info
	local localizedClass, englishClass, classIndex = UnitClass("player");
	opt.ClassName = localizedClass
	opt.PlayerClass = classIndex

	-- group info
	opt.InGroup = IsInGroup() or IsInRaid()
	opt.InRaid = IsInRaid()
	self:OnPlayerFocusChanged()

	-- load settings
	if (CooldownSyncPerCharacterConfig) then
		opt.env = CooldownSyncPerCharacterConfig
	end
	self:LoadMissingValues()
	
	-- talents
	self:UpdateTalentSpec()

	-- create panel
	InterfaceOptions_AddCategory(opt)
	self:SetupLocale()
	self:CreateWidgets()
	self:CreateMainFrame()

	--
	self:CreateModules()
	opt:ModuleEvent_OnInit()
	
	-- request initial sync
	C_Timer.After(1, function()
	end)
	
	-- minimap
	self:CreateMinimapIcon()

	pbDiagf("Intialized")
	opt.Initialized = true
	self:ForceUiUpdate()
end

function opt:OnTalentsChanged()
	if (not opt.Initialized) then return end
	self:UpdateTalentSpec()
	opt:ModuleEvent_OnTalentsChanged()
	self:ForceUiUpdate()
end

function opt:UpdateTalentSpec()

	local currentSpec = GetSpecialization()
	local id, name, description, icon, role, primaryStat = GetSpecializationInfo(currentSpec)
	opt.PlayerSpec = id
end

function opt:OnPlayerFocusChanged()
	local focus = GetUnitName("focus", true)
	if (focus) then
		opt.HasFocus = true
		opt.FocusName = focus
	else
		opt.HasFocus = false
		opt.FocusName = ""
	end

	-- update main frame UI
	self:ForceUiUpdate()
end

function opt:CheckDpsCooldownInfo()

end

function opt:OnLogout()
	-- save settings
	CooldownSyncPerCharacterConfig = opt.env
end

function opt:OnPlayerDied()

end

function opt:CreateMinimapIcon()

	local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("CooldownSyncAddon", 
	{
		type = "data source",	
		text = "Cooldown Sync",
		icon = "135939",
		OnClick = function(self, btn)
			opt:Config()
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine("CooldownSync")
		end,
		
		})
		
		opt.ui.MinimapIcon = LibStub("LibDBIcon-1.0", true)
		opt.ui.MinimapIcon:Register("CooldownSync", miniButton, opt.env.DB)
		opt:MinimapUpdate()
end

function CooldownSync_OnAddonCompartmentClick(addonName, buttonName)
	opt:Config()
end

function opt:MinimapUpdate()
	if (not opt.ui.MinimapIcon) then return end
	if (opt.env.ShowMinimapIcon) then
		opt.ui.MinimapIcon:Show("CooldownSync")
	else
		opt.ui.MinimapIcon:Hide("CooldownSync")
	end
end

-- UI callbacks

function opt:Lock()
	self:LockMainFrame()
end

function opt:Unlock()
	self:UnlockMainFrame()
end

function opt:Config()
	InterfaceOptionsFrame_OpenToCategory(opt)
end

-- tick functions

function opt:OnUpdate(elapsed)
	
end

