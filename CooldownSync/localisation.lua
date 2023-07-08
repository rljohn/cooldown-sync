local opt = CooldownSyncConfig

function opt:SetupLocale()

	local LOCALE = GetLocale()

	opt.titles = {

		-- addon
		CooldownSync = 'Cooldown Sync',
		CooldownSyncConfig = 'Cooldown Sync Config',
	
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
	}
	
end