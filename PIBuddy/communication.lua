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

function opt:SendMessage(data, target)

	if (target == nil or target == "") then
		return 
	end
	
	if (data == nil or data.id == nil) then 
		pbPrintf("Can not send message, invalid data")
		pbDump(data)
		return 
	end
	
	-- append our player name
	if (data.name == nil) then
		data.name = opt.PlayerName
	end

	pbDiagf("Sending message '%s' to '%s'", opt:PrintMessageId(data.id), target)
	pbDump(data)
	
    local serialized = LibSerialize:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	
    AceComm:SendCommMessage("PIBuddy", encoded, "WHISPER", target)
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

	pbDiagf("Handling message '%s' from '%s'", opt:PrintMessageId(data.id), sender)
	pbDump(data)
	opt:HandleMessage(data)
end
