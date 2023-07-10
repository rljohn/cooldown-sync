local opt = CooldownSyncConfig
local ignore_list = {}

local buddy = nil
local inspect = nil

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

-- talents
local TALENT_SPEC_REQUEST = 400
local TALENT_SPEC_REPLY = 401
local TALENT_SPEC_CHANGED = 402

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

		[TALENT_SPEC_REQUEST] = "TALENT_SPEC_REQUEST",
		[TALENT_SPEC_REPLY] = "TALENT_SPEC_REPLY",
		[TALENT_SPEC_CHANGED] = "TALENT_SPEC_CHANGED",
	}

	return table[id] or 'UNKNOWN MESSAGE'
end

function opt:HandleMessage(message)

	if (message.id == nil) then 
		cdDiagf("Invalid Message")
		return
	end

	-- module setup

	if buddy == nil then
		buddy = opt:GetModule("buddy")
	end

	if inspect == nil then
		inspect = opt:GetModule("inspect")
	end

	-- buddy requests first


	-- talent specs

	if message.id == TALENT_SPEC_REQUEST then
		opt:SendTalentSpecReply(message)
	elseif message.id == TALENT_SPEC_CHANGED then
		if inspect then
			opt:ModuleEvnet_OnTalentsReceived(message.sender, message.spec_id, message.spec_name)
		end
	end

end

function opt:SendTalentSpecRequest(name, realm)
	local message = {}
	message.id = TALENT_SPEC_REQUEST
	opt:SendMessage(message, name, realm)
end

function opt:SendTalentSpecChanged(spec_id, spec_name, name, realm)
	local message = {}
	message.id = TALENT_SPEC_CHANGED
	message.spec_id = spec_id
	message.spec_name = spec_name
	opt:SendMessage(message, name, realm)
end

function opt:SendTalentSpecReply(message)
	local response = {}
	response.id = TALENT_SPEC_REPLY
	response.spec_id = opt.PlayerSpec
	opt:SendReply(message, response)
end