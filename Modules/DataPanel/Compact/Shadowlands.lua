local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local rewards = {
	{
		name = L["MythicPlus"],
		completed = {},
	},
	{
		name = L["Ranked PvP"],
		completed = {},
	},
	{
		name = L["Raid"],
		completed = {},
	},
}

local function WipeRewards()
	for _, reward in ipairs(rewards) do
		for k in ipairs(reward.completed) do reward.completed[k] = nil end
		reward.threshold = nil
		reward.progress = nil
	end
end

local OnEvent
local function DelayedOnEvent()
	OnEvent(DP.panelList.Compact)
end
function OnEvent(self) -- 3/9
	WipeRewards()
	local totalChest = 0
	local activities = C_WeeklyRewards.GetActivities()
	if #activities ~= 9 then
		C_Timer.After(1,DelayedOnEvent)
		return
	end
	for _, activity in ipairs(activities) do
		local reward = rewards[activity.type]
		if activity.progress >= activity.threshold then -- completed
			totalChest = totalChest + 1
			local iLvl = GetDetailedItemLevelInfo(C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id))
			if not iLvl then
				C_Timer.After(1,DelayedOnEvent)
			end
			reward.completed[#reward.completed+1] = iLvl
		else -- in progress
			if not reward.threshold or reward.threshold > activity.threshold then
				reward.threshold = activity.threshold
				reward.progress = activity.progress
			end
		end
	end
	self.text:SetFormattedText(L["Weekly: %d/%d"], totalChest, 9)
end

local function OnEnter(tooltip)
	tooltip:AddLine(L["Weekly Chest"])
	tooltip:AddLine(" ")
	for _, reward in ipairs(rewards) do
		tooltip:AddLine(reward.name)
		for _, iLvl in ipairs(reward.completed) do
			tooltip:AddDoubleLine(L["Completed:"],format(L["iLvl %d"],iLvl))
		end
		if reward.threshold then
			tooltip:AddDoubleLine(L["Next Reward:"],format("%d/%d",reward.progress,reward.threshold))
		end
		tooltip:AddLine(" ")
	end
end

local function OnAddonLoaded(_,_,name)
	if name == "Blizzard_WeeklyRewards" then
		WeeklyRewardsFrame:Show()
	end
end

local function OnClick()
	if IsAddOnLoaded("Blizzard_WeeklyRewards") then
		if WeeklyRewardsFrame:IsShown() then
			WeeklyRewardsFrame:Hide()
		else
			WeeklyRewardsFrame:Show()
		end
	else
		B:AddEventScript("ADDON_LOADED", OnAddonLoaded)
		WeeklyRewards_LoadUI()
	end
end

local compactData = {
	OnEvent = OnEvent,
	events = {
		"PLAYER_ENTERING_WORLD",
		"WEEKLY_REWARDS_UPDATE",
		"CHALLENGE_MODE_COMPLETED",
	},
	OnEnter = OnEnter,
	OnClick = OnClick,
}

DP:RegisterState("shadowlands", compactData)
