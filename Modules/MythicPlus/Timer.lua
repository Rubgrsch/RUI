local _, rui = ...
local B, L, C = unpack(rui)

local MP = B.MP
local defaultFont = STANDARD_TEXT_FONT

local function FormatTime(seconds)
	if seconds < 0 then seconds = -seconds end
	local s = seconds % 60
	local m = (seconds - s) / 60
	return format("%02d:%02d", m, s)
end

local MPTimerFrame = CreateFrame("Frame", "MythicPlusTimerFrame", UIParent)
MPTimerFrame:SetSize(300,300)
B:SetupMover(MPTimerFrame,"MythicPlusTimerFrame",L["MythicPlusTimer"], nil,function() return C.db.instance.mythicPlus.timer end)
MPTimerFrame:Hide()
local levelText = MPTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
levelText:SetPoint("TOPLEFT",MPTimerFrame,"TOPLEFT")
levelText:SetFont(defaultFont,20)
local affixesText = MPTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
affixesText:SetPoint("TOPLEFT",levelText,"BOTTOMLEFT",0,-5)
affixesText:SetFont(defaultFont,14)
local mainTimeText = MPTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainTimeText:SetPoint("TOPLEFT",affixesText,"BOTTOMLEFT",0,-15)
mainTimeText:SetFont(defaultFont,22)
local plusThreeText = MPTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
plusThreeText:SetPoint("TOPLEFT",affixesText,"BOTTOMLEFT",55,-12)
plusThreeText:SetFont(defaultFont,14)
local plusTwoText = MPTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
plusTwoText:SetPoint("TOPLEFT",affixesText,"BOTTOMLEFT",55,-26)
plusTwoText:SetFont(defaultFont,14)
local timeLimitText = MPTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
timeLimitText:SetPoint("TOPLEFT",affixesText,"BOTTOMLEFT",100,-17)
timeLimitText:SetFont(defaultFont,18)

local criteriasList = {}
local deathCounter = MPTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
deathCounter:SetFont(defaultFont,13)
local prideText = MPTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
prideText:SetFont(defaultFont,14)

local lastSteps = 0
local function SetCriteriasPoints()
	local _, _, steps = C_Scenario.GetStepInfo()
	for i = #criteriasList + 1, steps do
		local text = MPTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetFont(defaultFont,14)
		criteriasList[i] = text
		if i == 1 then
			criteriasList[i]:SetPoint("TOPLEFT",affixesText,"BOTTOMLEFT",0,-50)
		else
			criteriasList[i]:SetPoint("TOPLEFT",criteriasList[i-1],"BOTTOMLEFT",0,-5)
		end
	end
	for i=1, steps do
		criteriasList[i]:SetTextColor(1,1,1)
		criteriasList[i].isGrey = false
		criteriasList[i]:Show()
	end
	for i=steps+1, #criteriasList do criteriasList[i]:Hide() end
	deathCounter:ClearAllPoints()
	deathCounter:SetPoint("TOPLEFT",criteriasList[steps],"BOTTOMLEFT",0,-15)
	-- pride
	prideText:ClearAllPoints()
	prideText:SetPoint("TOPLEFT",deathCounter,"BOTTOMLEFT",0,-5)
	-- end pride
	lastSteps = steps
end

function MP:UpdateTimerTime()
	local cr = self.currentRun
	if plusTwoText.isGreen and cr.timeLimit2 < cr.time then
		plusTwoText:SetTextColor(1,0,0)
		plusTwoText.isGreen = false
	end
	if plusThreeText.isGreen and cr.timeLimit3 < cr.time then
		plusThreeText:SetTextColor(1,0,0)
		plusThreeText.isGreen = false
	end
	if mainTimeText.isGreen and cr.timeLimit < cr.time then
		mainTimeText:SetTextColor(1,0,0)
		mainTimeText.isGreen = false
		plusTwoText:Hide()
		plusThreeText:Hide()
		timeLimitText:SetPoint("TOPLEFT",affixesText,"BOTTOMLEFT",55,-17)
	end
	plusTwoText:SetText(FormatTime(cr.timeLimit2 - cr.time))
	plusThreeText:SetText(FormatTime(cr.timeLimit3 - cr.time))
	mainTimeText:SetText(FormatTime(cr.timeLimit - cr.time))
	timeLimitText:SetText(FormatTime(cr.time).." / "..FormatTime(cr.timeLimit))
end

-- Hide ObjectiveTrackerFrame in M+
-- Stolen and modified from Bigwigs
local restoreObjectiveTracker = nil

local function HideTrackerFrame()
	if not ObjectiveTrackerFrame:IsProtected() then
		restoreObjectiveTracker = ObjectiveTrackerFrame:GetParent()
		if restoreObjectiveTracker then
			ObjectiveTrackerFrame:SetParent(B.hider)
		end
	end
end

local function ShowTrackerFrame()
	if restoreObjectiveTracker then
		ObjectiveTrackerFrame:SetParent(restoreObjectiveTracker)
		restoreObjectiveTracker = nil
	end
end

-- Timer Events
local function OnScenarioCriteriaUpdate()
	if not MP.currentRun.MPing then return end
	local _, _, steps = C_Scenario.GetStepInfo()
	if steps > lastSteps then SetCriteriasPoints() end
	for i = 1, steps-1 do -- for bosses
		if not criteriasList[i].isGrey then
			local name, _, completed = C_Scenario.GetCriteriaInfo(i)
			if completed then
				criteriasList[i]:SetTextColor(0.8,0.8,0.8)
				criteriasList[i].isGrey = true
			end
			criteriasList[i]:SetText((completed and "1/1 " or "0/1 ")..name)
		end
	end
	if criteriasList[steps] and not criteriasList[steps].isGrey then
		local name, _, completed, _, totalQuantity, _, _, quantityString = C_Scenario.GetCriteriaInfo(steps)
		if completed then
			criteriasList[steps]:SetText("100% "..name)
			criteriasList[steps]:SetTextColor(0.8,0.8,0.8)
			criteriasList[steps].isGrey = true
			prideText:SetText("")
		elseif quantityString and quantityString ~= "" then
			local quantity = tonumber(quantityString:sub(1, -2))
			if quantity then
				local remains = totalQuantity - quantity
				local progress = quantity / totalQuantity * 100
				criteriasList[steps]:SetFormattedText("%.2f%% %d/%d - %d %s",progress,quantity,totalQuantity,remains,name)
				-- 9.0 Pride
				local prideTick = totalQuantity / 5
				local nextPride = math.ceil(math.ceil(quantity/prideTick) * prideTick - quantity)
				prideText:SetFormattedText("%s: %.2f%% %d", L["Pride"], nextPride / totalQuantity * 100, nextPride)
			end
		end
	end
end
B:AddEventScript("SCENARIO_CRITERIA_UPDATE", OnScenarioCriteriaUpdate)
B:AddEventScript("SCENARIO_UPDATE", OnScenarioCriteriaUpdate)

local function OnChallengeModeDeathCountUpdated()
	local count, timeLost = C_ChallengeMode.GetDeathCount()
	if count == 0 then
		deathCounter:SetText("")
	else
		deathCounter:SetFormattedText("%s: %d / |cffff0000-%s|r", L["Death"], count, FormatTime(timeLost))
	end
end
B:AddEventScript("CHALLENGE_MODE_DEATH_COUNT_UPDATED", OnChallengeModeDeathCountUpdated)

local function OnChallengeModeStart()
	local cr = MP.currentRun
	if not cr.MPing or not C.db.instance.mythicPlus.timer then return end
	levelText:SetFormattedText("+%d %s", cr.level, cr.name)
	local affixesString = ""
	for _, affix in ipairs(cr.affixes) do
		affixesString = affixesString .. " " .. (C_ChallengeMode.GetAffixInfo(affix))
	end
	affixesText:SetText(affixesString)
	mainTimeText:SetTextColor(0,1,0)
	plusTwoText:SetTextColor(0,1,0)
	plusThreeText:SetTextColor(0,1,0)
	if cr.pride then
		prideText:Show()
	else
		prideText:Hide()
	end
	mainTimeText.isGreen = true
	plusTwoText.isGreen = true
	plusThreeText.isGreen = true
	plusTwoText:Show()
	plusThreeText:Show()
	timeLimitText:SetPoint("TOPLEFT",affixesText,"BOTTOMLEFT",100,-17)
	lastSteps = 0
	SetCriteriasPoints()
	OnScenarioCriteriaUpdate()
	OnChallengeModeDeathCountUpdated()
	MP:UpdateTimerTime()
	if C.db.instance.mythicPlus.hideTracker then HideTrackerFrame() end
	MPTimerFrame:Show()
end
B:AddEventScript("CHALLENGE_MODE_START", OnChallengeModeStart)
B:AddEventScript("PLAYER_ENTERING_WORLD", OnChallengeModeStart)

local function OnZoneChangedNewArea()
	local _, zoneType = GetInstanceInfo()
	if zoneType ~= "party" then
		MPTimerFrame:Hide()
		if C.db.instance.mythicPlus.hideTracker then ShowTrackerFrame() end
	end
end
B:AddEventScript("ZONE_CHANGED_NEW_AREA", OnZoneChangedNewArea)

SlashCmdList["MPTIMER"] = function()
	if MPTimerFrame:IsShown() then MPTimerFrame:Hide() else MPTimerFrame:Show() end
end
SLASH_MPTIMER1 = "/mpt"
