local opt = CooldownSyncConfig
local ignore_list = {}

-- API version appended to initial sync messages
-- Usage: Identifies a user on an older client
local CURRENT_VERSION = 2
opt.MESSAGE_VERSION = 2

-- buddy info
local BUDDY_INFO_REQUEST = 100
local BUDDY_INFO_REPLY = 101
local BUDDY_INFO_CHANGED = 102

local SPELL_COOLDOWN_REQUEST = 200
local SPELL_COOLDOWN_REPLY = 201
local SPELL_COOLDOWN_CHANGED = 202

-- request buddy
local REQUEST_BUDDY = 300
local REQUEST_BUDDY_ACCEPT = 301
local REQUEST_BUDDY_DECLINE = 302
local BUDDY_CHANGED = 303

-----------------------------------
-- Debug Print
-----------------------------------
function opt:PrintMessageId(id)
	local table = 
	{
		[BUDDY_INFO_REQUEST] = "BUDDY_INFO_REQUEST",
		[BUDDY_INFO_REPLY] = "BUDDY_INFO_REPLY",
		[BUDDY_INFO_CHANGED] = "BUDDY_INFO_CHANGED",

		[SPELL_COOLDOWN_REQUEST] = "SPELL_COOLDOWN_REQUEST",
		[SPELL_COOLDOWN_REPLY] = "SPELL_COOLDOWN_REPLY",
		[SPELL_COOLDOWN_CHANGED] = "SPELL_COOLDOWN_CHANGED",

		[REQUEST_BUDDY] = "REQUEST_BUDDY",
		[REQUEST_BUDDY_ACCEPT] = "REQUEST_BUDDY_ACCEPT",
		[REQUEST_BUDDY_DECLINE] = "REQUEST_BUDDY_DECLINE",
        [BUDDY_CHANGED] = "BUDDY_CHANGED",
	}

	return table[id] or 'UNKNOWN MESSAGE'
end

function opt:HandleMessage(message)

	if (message.id == nil) then 
		pbDiagf("Invalid Message")
		return 
	end

end
