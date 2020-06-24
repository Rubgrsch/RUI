local _, rui = ...
local B, L, C = unpack(rui)
local MP = B.MP

local function ReplyString()
	local _, _, steps = C_Scenario.GetStepInfo()
	local bosses, totalbosses, progress = 0, 0
	for i=1, steps do
		local _, _, completed, quantity, totalQuantity, _, _, _, _, _, _, _, isWeightedProgress = C_Scenario.GetCriteriaInfo(i)
		if isWeightedProgress then
			progress = completed and 100 or quantity
		else
			bosses = bosses + quantity
			totalbosses = totalbosses + totalQuantity
		end
	end
	return format(L["MPAutoreply"], MP.currentRun.level, MP.currentRun.name, bosses, totalbosses, progress)
end

local sentPlayers, wipeTimer = {}, false
local function WipePlayers() for k in pairs(sentPlayers) do sentPlayers[k] = nil end wipeTimer = false end
local function SentMessage(target)
	sentPlayers[target] = true
	if not wipeTimer then
		wipeTimer = true
		C_Timer.After(60, WipePlayers)
	end
end

local function OnChatMsgWhisper(_, _, _, sender, _, _, _, _, _, _, _, _, _, guid)
	if C.db.instance.mythicPlus.autoReply and MP.currentRun.MPing and (C_BattleNet.GetGameAccountInfoByGUID(guid) or IsGuildMember(guid) or C_FriendList.IsFriend(guid)) and not (UnitInRaid(sender) or UnitInParty(sender)) and not sentPlayers[sender] then
		SentMessage(sender)
		SendChatMessage(ReplyString(), "WHISPER", nil, sender)
	end
end

local function OnChatMsgBNWhisper(_, _, _, _, _, _, _, _, _, _, _, _, _, _, bnSenderID)
	if C.db.instance.mythicPlus.autoReply and MP.currentRun.MPing and not sentPlayers[bnSenderID] then
		local index = BNGetFriendIndex(bnSenderID)
		local gameAccs = C_BattleNet.GetFriendNumGameAccounts(index)
		for i=1, gameAccs do
			local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(index, i)
			if gameAccountInfo.clientProgram == "WoW" then
				local player = gameAccountInfo.characterName
				if gameAccountInfo.realmName ~= GetRealmName() then
					player = player .. "-" .. gameAccountInfo.realmName
				end
				if UnitInRaid(player) or UnitInParty(player) then
					return
				end
			end
		end
		SentMessage(bnSenderID)
		BNSendWhisper(bnSenderID, ReplyString())
	end
end

B:AddEventScript("CHAT_MSG_WHISPER", OnChatMsgWhisper)
B:AddEventScript("CHAT_MSG_BN_WHISPER", OnChatMsgBNWhisper)
