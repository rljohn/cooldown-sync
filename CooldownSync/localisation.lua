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

		-- Spell Glow
		
		ShowSpellGlow = "Show Spell Glow",
		ShowSpellGlowHeader = "Show Spell Glow",
		ShowSpellGlowTooltip = "Show a glow around spells when they are active.\n\nNOTE: Disabling glow effects may improve performance.",

		-- minimap
		ShowMinimapIcon = 'Show Minimap Icon',
		ShowMinimapHeader = 'Show Minimap Icon',
		ShowMinimapTooltip = 'Toggle the PIBuddy minimap icon.',

		--------------------
		-- PRIEST
		--------------------

		MacroConfig = 'Power Infusion (Party) - Macro',
		MacroConfigRaid = 'Power Infusion (Raid) - Macro',

		Priest_GenerateMacroParty = 'Automatically generate macro',
		Priest_GenerateMacroPartyTooltip = 'Automatically creates and updates a macro called "PIBUDDY" when in a group.',

		Priest_GenerateMacroRaid = 'Automatically generate macro',
		Priest_GenerateMacroRaidTooltip = 'Automatically creates and updates a macro called "PIBUDDY" when in a raid.',

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

		Priest_Sound = 'Play Sound on buddy cooldown',
		Priest_SoundTooltip = 'Sound to play when your buddy activates their cooldown.',
		Priest_SoundPiMe = 'Play Sound on |cffFFF569PI ME|r Request',
		Priest_SoundPiMeTooltip = 'Sound to play when your buddy requests Power Infusion.',
	}
	
end