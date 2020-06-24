local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local coloredString = {L["[AFK]"], L["[DND]"]}

local guildList = {}
local function PrepareGuildList()
	local total, cur = GetNumGuildMembers(), 1
	for i=1, total do
		local name, rankName, rankIndex, level, _, zone, _, _, isOnline, status, class = GetGuildRosterInfo(i)
		if isOnline then
			local t = guildList[cur] or {}
			t[1] = name
			t[2] = rankName
			t[3] = rankIndex
			t[4] = level
			t[5] = class
			t[6] = zone
			t[7] = status
			guildList[cur] = t
			cur = cur + 1
		end
	end
	for i=cur, #guildList do guildList[i] = nil end
end

local function SortGuildList(a,b)
	-- level -> rankIndex -> status -> name
	if a[4] == b[4] then
		if a[3] == b[3] then
			if a[7] == b[7] then
				return a[1] < b[1]
			else
				return a[7] < b[7]
			end
		else
			return a[3] < b[3]
		end
	else
		return a[4] > b[4]
	end
end

local data = DP:CreateData("Guild")
local function OnEnter(self)
	if not C.db.dataPanel.tooltipInCombat and InCombatLockdown() then return end
	local tooltip = GameTooltip
	tooltip:SetOwner(self, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	tooltip:ClearLines()
	PrepareGuildList()
	if next(guildList) then sort(guildList, SortGuildList) end
	local guildName = GetGuildInfo("player")
	local numTotalGuildMembers, _, numOnlineAndMobile = GetNumGuildMembers()
	if guildName then
		tooltip:AddDoubleLine(guildName,numOnlineAndMobile.."/"..numTotalGuildMembers,0.7,0.7,1,0.7,0.7,1)
		local MOTD = GetGuildRosterMOTD()
		if MOTD ~= "" then
			tooltip:AddLine(MOTD,1,1,1)
		end
		tooltip:AddLine(" ")
		local isModifierKeyDown = IsModifierKeyDown() and 2 or 6
		for _, info in ipairs(guildList) do
			tooltip:AddDoubleLine(info[4].." |c"..RAID_CLASS_COLORS[info[5]].colorStr..B.formatName(info[1]).."|r"..(coloredString[info[7]] or ""),info[isModifierKeyDown])
		end
	end
	tooltip:Show()
	self.isTTShown = true
end
data.OnEnter = OnEnter
data.OnMouseUp = function(self)
	if not InCombatLockdown() then
		ToggleGuildFrame()
	end
end
data.OnEvent = function(self, event)
	if event ~= "MODIFIER_STATE_CHANGED" then
		if IsInGuild() then
			local _, _, numOnlineAndMobile = GetNumGuildMembers()
			self.text:SetFormattedText(L["Guild: %d"], numOnlineAndMobile)
		else
			self.text:SetText(L["NoGuild"])
		end
	end
	if self.isTTShown then OnEnter(self) end
end
data.events = {"GUILD_ROSTER_UPDATE", "PLAYER_GUILD_UPDATE", "GUILD_MOTD", "PLAYER_ENTERING_WORLD", "MODIFIER_STATE_CHANGED"}
