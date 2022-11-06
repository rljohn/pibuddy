local opt = PIBuddyConfig

-- communication

local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")
local AceComm = LibStub:GetLibrary ("AceComm-3.0")
if (AceComm) then
	AceComm:RegisterComm("PIBuddy",
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
		pbPrintf("Can not send message, invalid data")
		pbDump(data)
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
	
    local serialized = LibSerialize:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	
	if (not realm or realm == "" or realm == opt.PlayerRealm) then
		pbDiagf("Sending whisper message '%s' to '%s'", opt:PrintMessageId(data.id), target)
		pbDump(data)
    	AceComm:SendCommMessage("PIBuddy", encoded, "WHISPER", target)
	else
		pbDiagf("Sending raid message '%s' to '%s'", opt:PrintMessageId(data.id), target)
		pbDump(data)
		AceComm:SendCommMessage("PIBuddy", encoded, "RAID", nil)
	end
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
		pbDiagf("Discarding message, invalid data")
		pbDump(data)
		return
	end

	-- messages on raid channel must be discarded if they are not for me
	if (not data.target or (data.target ~= opt.PlayerName and data.target ~= opt.PlayerNameRealm)) then
		pbDiagf("Discarding '%s' message, not for me", opt:PrintMessageId(data.id))
		pbDump(data)
		return
	end

	-- replace the name with the sender, which will have the server name built in if necessary
	data.name = sender

	pbDiagf("Handling message '%s' from '%s'", opt:PrintMessageId(data.id), sender)
	pbDump(data)
	opt:HandleMessage(data)
end
