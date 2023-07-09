---@diagnostic disable: undefined-field
local opt = CooldownSyncConfig

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

function opt:SendMessage(data, target, realm)

	if (target == nil or target == "") then
		return 
	end
	
	if (data == nil or data.id == nil) then
		cdPrintf("Can not send message, invalid data")
		cdDump(data)
		return
	end
	
	-- append our realm

	if (data.realm == nil) then
		data.realm = opt.PlayerRealm
	end

	if (data.target == nil) then
		data.target = target
	end

	if (data.version == nil) then
		data.version = opt.MESSAGE_VERSION
	end
	
	data.sender = opt.PlayerName
	data.sender_realm = opt.PlayerRealm

    local serialized = LibSerialize:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	
	if (not realm or realm == "" or realm == opt.PlayerRealm) then
		cdDiagf("Sending whisper message '%s' to '%s'", opt:PrintMessageId(data.id), target)
		cdDump(data)
    	AceComm:SendCommMessage("CooldownSync", encoded, "WHISPER", target)
	else
		cdDiagf("Sending raid message '%s' to '%s'", opt:PrintMessageId(data.id), target)
		cdDump(data)
		AceComm:SendCommMessage("CooldownSync", encoded, "RAID", nil)
	end
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
		--cdDump(data)
		return
	end

	-- messages on raid channel must be discarded if they are not for me
	if (not data.target or 
        (data.target ~= "all" and data.target ~= opt.PlayerName and data.target ~= opt.PlayerNameRealm)) then
		cdDiagf("Discarding '%s' message, not for me", opt:PrintMessageId(data.id))
		--cdDump(data)
		return
	end

	-- replace the name with the sender, which will have the server name built in if necessary
	data.name = sender

	cdDiagf("Handling message '%s' from '%s'", opt:PrintMessageId(data.id), sender)
	--cdDump(data)
	opt:HandleMessage(data)
end