local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local BNApp = {
	["App"] = true,
	["BSAp"] = true,
}

local friendsList, needRefresh = {}, true
local function PrepareBNFriendsList()
	wipe(friendsList)
	for i = 1, BNGetNumFriends() do
		local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
		local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(i)
		BNApp.App, BNApp.BSAp = true, true
		local games = 0
		for j = 1, numGameAccounts do
			local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(i, j)
			local idx = #friendsList+1
			if BNApp[gameAccountInfo.clientProgram] then
				BNApp[gameAccountInfo.clientProgram] = idx
			else
				games = games + 1
			end
			local t = {}
			for k,v in pairs(accountInfo) do if type(v) ~= "table" then t[k] = v end end -- skip gameAccountInfo
			for k,v in pairs(gameAccountInfo) do t[k] = v end
			friendsList[idx] = t
		end
		-- remove friends' BNapp info who have Games + BNApp, or two BNApps
		-- since it's array, remove backwards
		if numGameAccounts > 1 then
			local removeA, removeB
			if games > 0 and BNApp.App ~= true then removeA = BNApp.App end
			if BNApp.BSAp ~= true then removeB = BNApp.BSAp end
			if removeA and removeB then
				tremove(friendsList,removeA > removeB and removeA or removeB)
				tremove(friendsList,removeA < removeB and removeA or removeB)
			else
				if removeA then tremove(friendsList,removeA) end
				if removeB then tremove(friendsList,removeB) end
			end
		end
	end
	needRefresh = false
end

local clientPrograms = {["App"] = "zy", ["BSAp"] = "zz"}
setmetatable(clientPrograms, {__index=function(_, key) return key end})
local function SortFriendsList(a,b)
	if a.wowProjectID or b.wowProjectID then
		-- WoW: online -> retail -> realNameFriend -> AFK/DND -> level -> myFaction -> accountName
		if a.wowProjectID == b.wowProjectID then
			if a.isBattleTagFriend == b.isBattleTagFriend then
				-- (a.isDND or a.isAFK or a.isGameAFK or a.isGameDND) can be true, false and nil. And false ~= nil !!
				-- So we should convert nil to false here
				if not (a.isDND or a.isAFK or a.isGameAFK or a.isGameDND) == not (b.isDND or b.isAFK or b.isGameDND or b.isGameAFK) then
					if a.characterLevel == b.characterLevel then
						if a.factionName == b.factionName then
							return a.accountName < b.accountName
						else
							return a.factionName == B.playerFaction
						end
					else
						return a.characterLevel > b.characterLevel
					end
				else
					return b.isDND or b.isAFK or b.isGameDND or b.isGameAFK
				end
			else
				return b.isBattleTagFriend
			end
		else
			return a.wowProjectID and a.wowProjectID == WOW_PROJECT_ID
		end
	else
		-- Others: game -> realNameFriend -> AFK/DND -> accountName
		if a.clientProgram == b.clientProgram then
			if a.isBattleTagFriend == b.isBattleTagFriend then
				if (a.isDND or a.isAFK or a.isGameAFK or a.isGameDND) == (b.isDND or b.isAFK or b.isGameDND or b.isGameAFK) then
					return a.accountName < b.accountName
				else
					return b.isDND or b.isAFK or b.isGameDND or b.isGameAFK
				end
			else
				return b.isBattleTagFriend
			end
		else
			return clientPrograms[a.clientProgram] < clientPrograms[b.clientProgram]
		end
	end
end

local data = DP:CreateData("Friends")
local function OnEnter(self)
	if not C.db.dataPanel.tooltipInCombat and InCombatLockdown() then return end
	local tooltip = GameTooltip
	tooltip:SetOwner(self, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	tooltip:ClearLines()
	if needRefresh then
		PrepareBNFriendsList()
		if next(friendsList) then sort(friendsList, SortFriendsList) end
	end
	local onlineFriends = C_FriendList.GetNumOnlineFriends()
	local _, numBNetOnline = BNGetNumFriends()
	tooltip:AddLine(format(L["Friends: %d"], onlineFriends + numBNetOnline))
	tooltip:AddLine(" ")
	local isModifierKeyDown = IsModifierKeyDown()
	for _, info in ipairs(friendsList) do
		if info.wowProjectID then -- WoWOnline
			local characterName = info.characterName and (info.className and "|c"..RAID_CLASS_COLORS[B.UnlocalizedClassNames[info.className]].colorStr or "|cffffffff")..info.characterName or ""
			local factionIcon = info.factionName == "Horde" and "|T374221:0|t" or info.factionName == "Alliance" and "|T374217:0|t" or " "
			if isModifierKeyDown then
				tooltip:AddDoubleLine((info.characterLevel or "0")..factionIcon..characterName..(info.realmName and "-"..info.realmName or "").."|r", ((info.isAFK or info.isGameAFK) and L["[AFK]"] or "")..((info.isDND or info.isGameDND) and L["[DND]"] or "")..info.accountName,1,0.82,0,1,1,1)
			else
				tooltip:AddDoubleLine((info.characterLevel or "0")..factionIcon..characterName.."|r"..((info.isAFK or info.isGameAFK) and L["[AFK]"] or "")..((info.isDND or info.isGameDND) and L["[DND]"] or ""), info.areaName or "",1,0.82,0,1,0.82,0)
			end
		end
	end
	for i = 1, C_FriendList.GetNumFriends() do
		local info = C_FriendList.GetFriendInfoByIndex(i)
		if info.connected then
			tooltip:AddDoubleLine(info.level..(B.playerFaction == "Horde" and "|T374221:0|t" or "|T374217:0|t").."|c"..RAID_CLASS_COLORS[B.UnlocalizedClassNames[info.className]].colorStr..info.name.."|r",(info.afk and L["[AFK]"] or "")..(info.dnd and L["[DND]"] or "")..info.name,1,0.82,0,1,1,1)
		end
	end
	for _, info in ipairs(friendsList) do
		if info.isOnline and not info.wowProjectID then -- BNOnline
			if isModifierKeyDown then
				tooltip:AddDoubleLine(info.clientProgram, ((info.isAFK or info.isGameAFK) and L["[AFK]"] or "")..((info.isDND or info.isGameDND) and L["[DND]"] or "")..info.accountName, 1,0.82,0,1,1,1)
			else
				tooltip:AddDoubleLine(info.accountName..((info.isAFK or info.isGameAFK) and L["[AFK]"] or "")..((info.isDND or info.isGameDND) and L["[DND]"] or ""), info.clientProgram, 1,1,1,1,0.82,0)
			end
		end
	end
	tooltip:Show()
	self.isTTShown = true
end
data.OnEnter = OnEnter
data.OnMouseUp = function(self)
	if not InCombatLockdown() then
		ToggleFriendsFrame(1)
	end
end
data.OnEvent = function(self, event)
	if event ~= "MODIFIER_STATE_CHANGED" then
		local onlineFriends = C_FriendList.GetNumOnlineFriends()
		local _, numBNetOnline = BNGetNumFriends()
		self.text:SetFormattedText(L["Friends: %d"], onlineFriends + numBNetOnline)
		needRefresh = true
	end
	if self.isTTShown then OnEnter(self) end
end
data.events = {"BN_FRIEND_ACCOUNT_ONLINE", "BN_FRIEND_ACCOUNT_OFFLINE", "BN_FRIEND_INFO_CHANGED", "FRIENDLIST_UPDATE", "PLAYER_ENTERING_WORLD", "MODIFIER_STATE_CHANGED"}
