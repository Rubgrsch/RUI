local _, rui = ...
local B, L, C = unpack(rui)

local MP = {}
B.MP = MP

MP.currentRun = {}
local function StartMythicPlus()
	local _, _, difficulty, _, _, _, _, _ = GetInstanceInfo()
	local _, elapsed = GetWorldElapsedTime(1)
	if not ( C_ChallengeMode.IsChallengeModeActive() and difficulty == 8 and elapsed >= 0) then return end
	local level, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
	local mapID = C_ChallengeMode.GetActiveChallengeMapID()
	local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID)
	local cr = MP.currentRun
	cr.level = level
	cr.affixes = affixes
	cr.name = name
	cr.MPing = true
	cr.time = 0
	cr.timeLimit = timeLimit
	cr.timeLimit2 = timeLimit*0.8
	cr.timeLimit3 = timeLimit*0.6
	-- 9.0 S1: pride
	cr.pride = false
	for _, affix in ipairs(affixes) do
		if affix == 121 then cr.pride = true end
	end
end
B:AddEventScript("CHALLENGE_MODE_START", StartMythicPlus)
B:AddEventScript("PLAYER_ENTERING_WORLD", StartMythicPlus)

local function EndMythicPlus()
	MP.currentRun.MPing = false
end
B:AddEventScript("CHALLENGE_MODE_COMPLETED", EndMythicPlus)

local function OnZoneChangedNewArea()
	local _, zoneType = GetInstanceInfo()
	if zoneType ~= "party" and MP.currentRun.name then
		for k in pairs(MP.currentRun) do MP.currentRun[k] = nil end
	end
end
B:AddEventScript("ZONE_CHANGED_NEW_AREA", OnZoneChangedNewArea)

hooksecurefunc("Scenario_ChallengeMode_UpdateTime", function(_, elapsed)
	local cr = MP.currentRun
	if cr.MPing then
		cr.time = elapsed
		MP:UpdateTimerTime()
	end
end)

function MP.FormatTime(seconds)
	if seconds < 0 then seconds = 0 end
	local s = seconds % 60
	local m = (seconds - s) / 60
	return format("%02d:%02d", m, s)
end

-- Auto insert keystone
local function InsertKeystone()
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			-- check if item at slot is the key
			if GetContainerItemID(bag, slot) == 180653 then
				-- pickup item and insert it
				PickupContainerItem(bag, slot)
				if CursorHasItem() then
					C_ChallengeMode.SlotKeystone()
				end
				return
			end
		end
	end
end

local function OnAddonLoaded(_,_,name)
	if name == "Blizzard_ChallengesUI" then
		ChallengesKeystoneFrame:HookScript("OnShow", InsertKeystone)
	end
end

B:AddInitScript(function()
	if IsAddOnLoaded("Blizzard_ChallengesUI") then
		ChallengesKeystoneFrame:HookScript("OnShow", InsertKeystone)
	else
		B:AddEventScript("ADDON_LOADED", OnAddonLoaded)
	end
end)
