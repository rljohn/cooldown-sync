local folder,ns = ...

-- Setup the Interface Options

local frame_name = 'CooldownSyncConfig'
local opt = CreateFrame('FRAME',frame_name,InterfaceOptionsFramePanelContainer)
opt = CooldownSyncConfig
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
opt.globals = {}
opt.env.DB = {}
opt.env.Buddies = {}

-- ui frames
opt.ui = {}

-- defaults

local function SetValue(key, value)
	opt.env[key] = value
end

function opt:SetDefaultValue(key, value)
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
	self:SetDefaultValue('DB', {})
	self:SetDefaultValue('Buddies', {})
	self:SetDefaultValue('RaidBuddies', {})
	self:SetDefaultValue('ShowMinimapIcon', true)
	self:SetDefaultValue('ShowBackground', true)
	self:SetDefaultValue('ShowTitle', true)
	self:SetDefaultValue('LockButton', false)
	self:SetDefaultValue('IconSize', 32)
	self:SetDefaultValue('FrameX', -1)
	self:SetDefaultValue('FrameY', -1)

	-- module defaults
	self:ModuleEvent_LoadDefaultValues()
	
end

-- Main Interface Callbacks

function opt:OnLogin()

	-- init
	self:BuildLogModule("logging")
	self:InitGlowLibrary()
	self:SetupLocale()
	
	-- check name, realm
	opt.PlayerName = UnitName("player")
	opt.PlayerRealm = self:SpaceStripper(GetNormalizedRealmName())
	opt.PlayerGUID = UnitGUID("player")
	opt.PlayerNameRealm = string.format("%s-%s", opt.PlayerName, opt.PlayerRealm)
	opt.PlayerLevel = UnitLevel("player")
	_, opt.PlayerRace = UnitRace("player")

	-- check class info
	local localizedClass, englishClass, classIndex = UnitClass("player");
	opt.ClassName = localizedClass
	opt.PlayerClass = classIndex

	-- group info
	opt.InGroup = IsInGroup() or IsInRaid()
	opt.InRaid = IsInRaid()
	self:OnPlayerFocusChanged()

	-- load per-character settings
	if (CooldownSyncPerCharacterConfig) then
		opt.env = CooldownSyncPerCharacterConfig
	end

	-- load global settings
	if (CooldownSyncGlobalConfig) then
		opt.globals = CooldownSyncGlobalConfig
	end

	-- create main panel
	InterfaceOptions_AddCategory(opt)

	-- create modules and load missing values
	self:CreateModules()
	self:LoadMissingValues()
	
	-- talents
	self:UpdateTalentSpec()

	-- create widgets
	self:CreateWidgets()
	self:CreateMainFrame()
	
	opt:ModuleEvent_OnInit()

	-- request initial sync
	C_Timer.After(1, function()
		opt:ModuleEvent_OnPostInit()
	end)
	
	-- minimap
	self:CreateMinimapIcon()

	cdDiagf("Intialized")
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
---@diagnostic disable-next-line: undefined-field
			if not tooltip or not tooltip.AddLine then return end
---@diagnostic disable-next-line: undefined-field
			tooltip:AddLine("CooldownSync")
		end,
		
		})
		
		opt.ui.MinimapIcon = LibStub("LibDBIcon-1.0", true)
---@diagnostic disable-next-line: param-type-mismatch
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
	opt:LockMainFrame()
end

function opt:Unlock()
	opt:UnlockMainFrame()
end

function opt:Config()
	InterfaceOptionsFrame_OpenToCategory(opt)
end

-- tick functions

function opt:OnUpdate(elapsed)
	
end

