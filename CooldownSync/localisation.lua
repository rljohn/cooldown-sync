local opt = CooldownSyncConfig

function opt:SetupLocale()

	local LOCALE = GetLocale()

	opt.titles = {

		--------------------
		-- Addon
		--------------------

		CooldownSync = 'Cooldown Sync',
		CooldownSyncConfig = 'Cooldown Sync Config',

		--------------------
		-- Settings
		--------------------

		-- Show Button
		ShowText = 'Show Frame',
		ShowTextTooltip = "Choose when the frame should be displayed",
		
		-- Icon Size
		IconSize = 'Icon Size',
		IconSizeTooltip = 'Size of the PI Buddy cooldown icons.',

		-- Lock button
		LockButton = 'Lock Frame',
		LockButtonHeader = 'Lock Frame',
		LockButtonTooltip = 'Locks the frame.',

		-- Background
		ShowBackground = 'Show Background',
		ShowBackgroundHeader = 'Show Background',
		ShowBackgroundTooltip = 'Show the frame background.',
		
		-- Title
		ShowTitle = 'Show Title',
		ShowTitleHeader = 'Show Title',
		ShowTitleTooltip = 'Show the frame title.',

		-- Cooldowns
		ShowCooldownTimers = "Show Cooldown Timers",
		ShowCooldownTimersHeader = "Show Cooldown Timers",
		ShowCooldownTimersTooltip = "Display a timer when spells are on cooldown",

		-- Spell Timers
		ShowSpellTimers = "Show Spell Timers",
		ShowSpellTimersHeader = "Show Spell Timers",
		ShowSpellTimersTooltip = "Display a timer when spells are active",

		-- minimap
		ShowMinimapIcon = 'Show Minimap Icon',
		ShowMinimapHeader = 'Show Minimap Icon',
		ShowMinimapTooltip = 'Toggle the Cooldown sync minimap icon.',

		-- Spell Glow

		ShowSpellGlow = "Show Spell Glow",
		ShowSpellGlowHeader = "Show Spell Glow",
		ShowSpellGlowTooltip = "Show a glow around spells when they are active.\n\nNOTE: Disabling glow effects may improve performance.",
	
		-- Buddy
		PartyBuddy = 'Buddy (Party Content)',
		RaidBuddy = 'Buddy (Raid Content)',
		Buddy = 'Buddy:',
		ApplyBtn = 'Apply',
		ApplyBtnHeader = 'Apply Buddy',
		SetAsTargetBtn = 'Copy Target',

		PartyBuddyTooltip = 'Configure a Buddy for party content.',
		RaidBuddyTooltip = 'Configure a Buddy for raid groups.',
		CopyTargetTooltip = 'Set your current target as your buddy.\n\nYou can also right click on the main frame to set your current target as your buddy.',
		ApplyBtnTooltip = 'Click to confirm your current buddy.',

		--------------------
		-- PRIEST
		--------------------

		Priest_MacroConfig = 'Power Infusion (Party) - Macro',
		Priest_MacroConfigRaid = 'Power Infusion (Raid) - Macro',

		Priest_GenerateMacroParty = 'Automatically generate macro',
		Priest_GenerateMacroPartyTooltip = 'Automatically creates and updates a macro called "CDSyncPriest" when in a group.',

		Priest_GenerateMacroRaid = 'Automatically generate macro',
		Priest_GenerateMacroRaidTooltip = 'Automatically creates and updates a macro called "CDSyncPriest" when in a raid.',

		Priest_Trinket1Party = 'Use Trinket (Slot 1)',
		Priest_Trinket1Raid = 'Use Trinket (Slot 1)',
		Priest_Trinket1Tooltip = 'Include first trinket in the macro.',

		Priest_Trinket2Party = 'Use Trinket (Slot 2)',
		Priest_Trinket2Raid = 'Use Trinket (Slot 2)',
		Priest_Trinket2Tooltip = 'Include second trinket in the macro.',

		Priest_PIFocusParty = 'Include Focus Target',
		Priest_PIFocusRaid = 'Include Focus Target',
		Priest_PIFocusTooltip = 'Attempt to cast on your focus target.',

		Priest_PIFriendlyParty = 'Include Friendly Target',
		Priest_PIFriendlyRaid = 'Include Friendly Target',
		Priest_PIFriendlyTooltip = 'Attempt to target a random friendly player, in case your buddy is dead.',

		Priest_PITargetLastTargetParty = 'Target Last Target',
		Priest_PITargetLastTargetRaid  = 'Target Last Target',
		Priest_PITargetLastTargetTooltip = 'Attempt to target your last target.',
		
		-- sound

		Priest_Sound = 'Play Sound on Buddy Cooldown',
		Priest_SoundTooltip = 'Sound to play when your buddy activates their cooldowns.',
	
		Priest_ShowFrameGlow = "Show Frame Glow",
		Priest_ShowFrameGlowHeader = "Show Frame Glow",
		Priest_ShowFrameGlowTooltip = "Show a glow around party and raid frames when a buddy's major cooldowns are active.",

		--------------------
		-- PALADIN
		--------------------

		Paladin_Options = "Paladin Options",

		Paladin_MacroConfig = 'Blessing of Summer (Party) - Macro',
		Paladin_MacroConfigRaid = 'Blessing of Summer (Raid) - Macro',

		Paladin_GenerateMacroParty = 'Automatically generate macro',
		Paladin_GenerateMacroPartyTooltip = 'Automatically creates and updates a macro called "CDSyncPally" when in a group.',

		Paladin_GenerateMacroRaid = 'Automatically generate macro',
		Paladin_GenerateMacroRaidTooltip = 'Automatically creates and updates a macro called "CDSyncPally" when in a raid.',

		Paladin_Trinket1Party = 'Use Trinket (Slot 1)',
		Paladin_Trinket1Raid = 'Use Trinket (Slot 1)',
		Paladin_Trinket1Tooltip = 'Include first trinket in the macro.',

		Paladin_Trinket2Party = 'Use Trinket (Slot 2)',
		Paladin_Trinket2Raid = 'Use Trinket (Slot 2)',
		Paladin_Trinket2Tooltip = 'Include second trinket in the macro.',

		Paladin_FocusParty = 'Include Focus Target',
		Paladin_FocusRaid = 'Include Focus Target',
		Paladin_FocusTooltip = 'Attempt to cast on your focus target.',

		Paladin_FriendlyParty = 'Include Friendly Target',
		Paladin_FriendlyRaid = 'Include Friendly Target',
		Paladin_FriendlyTooltip = 'Attempt to target a random friendly player, in case your buddy is dead.',

		Paladin_TargetLastTargetParty = 'Target Last Target',
		Paladin_TargetLastTargetRaid  = 'Target Last Target',
		Paladin_TargetLastTargetTooltip = 'Attempt to target your last target.',
		
		-- sound

		Paladin_Sound = 'Play Sound on Buddy Cooldown:',
		Paladin_SoundTooltip = 'Sound to play when your buddy activates their cooldown.',

		-- Spell Glow

		Paladin_ShowFrameGlow = "Show Frame Glow",
		Paladin_ShowFrameGlowHeader = "Show Frame Glow",
		Paladin_ShowFrameGlowTooltip = "Show a glow around party and raid frames when a buddy's major cooldowns are active.",
	}
	
end