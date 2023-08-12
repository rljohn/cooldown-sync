---@diagnostic disable: undefined-field
local opt = CooldownSyncConfig
local ALLOW_NOPARTY_BROADCAST = false
local ALLOW_HANDLE_SELF_MSG = false

-- communication

local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")
local AceComm = LibStub:GetLibrary ("AceComm-3.0")
if (AceComm) then
	AceComm:RegisterComm("CooldownSync",
		function(prefix, message, distribution, sender)
			opt:OnCommReceived(prefix, message, distribution, sender)
		end)
end

-- Send an addon COMM message

local function PrepareMessage(data)

	-- add default fields
	data.version = opt.MESSAGE_VERSION
	data.sender = opt.PlayerName
	data.sender_realm = opt.PlayerRealm
	data.sender_guid = opt.PlayerGUID

	-- serialize and compress
	local serialized = LibSerialize:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    return LibDeflate:EncodeForWoWAddonChannel(compressed)
end

local function DispatchMessage(data)
	local message = PrepareMessage(data)
	if message then
		if ( data.target and (not data.realm or data.realm == "" or data.realm == opt.PlayerRealm) ) then
			cdDiagf("Dispatching message to %s: %s", data.target, opt:PrintMessageId(data.id))
			cdDump(data)
			AceComm:SendCommMessage("CooldownSync", message, "WHISPER", data.target)
		elseif opt.InRaid then
			cdDiagf("Dispatching message to raid: %s", opt:PrintMessageId(data.id))
			cdDump(data)
			if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
				AceComm:SendCommMessage("CooldownSync", message, "INSTANCE_CHAT", nil)
			else
				AceComm:SendCommMessage("CooldownSync", message, "RAID", nil)
			end
		elseif opt.InGroup then
			cdDiagf("Dispatching message to party: %s", opt:PrintMessageId(data.id))
			cdDump(data)
			if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
				AceComm:SendCommMessage("CooldownSync", message, "INSTANCE_CHAT", nil)
			else
				AceComm:SendCommMessage("CooldownSync", message, "PARTY", nil)
			end
		elseif ALLOW_NOPARTY_BROADCAST then
			cdDiagf("Dispatching message to self: %s", opt:PrintMessageId(data.id))
			cdDump(data)
			AceComm:SendCommMessage("CooldownSync", message, "WHISPER", opt.PlayerName)
		end
	end
end

function opt:Broadcast(data)

	if (not data or not data.id) then return end

	-- can only broadcast to party or raid
	if not ALLOW_NOPARTY_BROADCAST then
		if not opt.InGroup and not opt.InRaid then
			return
		end
	end

	DispatchMessage(data)
end

function opt:SendMessage(data, target, realm)
	if (not data or not data.id) then return end

	-- target is required
	if (target == nil or target == "") then
		return
	end
	
	-- set target/realm so if we have to broadcast message, others will ignore
	data.target = target
	data.realm = realm

	-- add default fields
	DispatchMessage(data)
	
end

function opt:SendReply(message, response)
	response.target = message.sender
	response.realm = message.sender_realm
	opt:SendMessage(response, response.target, response.realm)
end

-- Received an addon COMM message

function opt:OnCommReceived(prefix, payload, distribution, sender)

	local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
    if not decoded then return end
	
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return end
	
    local success, data = LibSerialize:Deserialize(decompressed)
    if not success then return end

	if (data == nil or data.id == nil) then
		cdDiagf("Discarding message, invalid data")
		cdDump(data)
		return
	end

	if not ALLOW_HANDLE_SELF_MSG then
		if sender == opt.PlayerName then
			cdDiagf("Discarding '%s' message I sent", opt:PrintMessageId(data.id))
			return
		end
	end

	-- messages on raid channel must be discarded if they are not for me
	local target_match = data.target == nil or data.target == opt.PlayerName
	local realm_match = data.realm == nil or data.realm == opt.PlayerRealm

	if (not target_match or not realm_match) then
		cdDiagf("Discarding '%s' message, not for me", opt:PrintMessageId(data.id))
		cdDump(data)
		return
	end

	cdDiagf("Handling message '%s' from '%s'", opt:PrintMessageId(data.id), sender)
	cdDump(data)
	opt:HandleMessage(data)
end