local _, rui = ...
local B, L, C = unpack(rui)

local MP = B.MP
local FormatTime = MP.FormatTime

local originalColor = {
	{0,0.7,0,0.8},
	{0.7,0.7,0,0.8},
	{0.7,0,0,0.8},
	{0,0,0,0.8},
	{0,0.4,0.8,0.8},
}
local greyedColor = {0.7,0.7,0.7,0.8}

local playerServerAppendix = "-"..GetRealmName()
local function GetFullName(name)
	if not name:find("%-") then name = name..playerServerAppendix end
	return name
end

-- Frames
local MPBFrame = CreateFrame("Frame","MythicPlusBlacklistFrame",UIParent)
MPBFrame:SetSize(600,400)
MPBFrame:SetPoint("CENTER")
MPBFrame:Hide()
tinsert(UISpecialFrames,MPBFrame:GetName())
local background = MPBFrame:CreateTexture(nil, "BACKGROUND")
background:SetColorTexture(0,0,0,0.8)
background:SetAllPoints(true)
local title = MPBFrame:CreateFontString(nil,"ARTWORK","GameFontHighlightLarge")
title:SetPoint("TOP", MPBFrame, "TOP",0,-5)
title:SetText(L["MythicPlus Blacklist"])

local currentRunText = MPBFrame:CreateFontString(nil,"ARTWORK","GameFontNormal")
currentRunText:SetPoint("TOP", title, "BOTTOM",0,-20)
local defaultFont_GameFontNormal = currentRunText:GetFont()
currentRunText:SetFont(defaultFont_GameFontNormal,20)

local function UnselectButtons(frame)
	frame.selected = false
	for i=1, 5 do frame.button[i]:SetBackdropColor(unpack(originalColor[i])) end
end

local function SelectButton(frame, idx)
	frame.selected = idx
	for i=1, 5 do
		if i == idx then
			frame.button[i]:SetBackdropColor(unpack(originalColor[idx]))
		else
			frame.button[i]:SetBackdropColor(unpack(greyedColor))
		end
	end
end

local buttonBackdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	insets = {left = 2, right = 2, top = 2, bottom = 2},
}
local function OnClick(self)
	PlaySound(856)
	local frame, idx = self.parent, self.lvl
	if frame.selected ~= idx then
		SelectButton(frame, idx)
	else
		UnselectButtons(frame)
	end
end
-- party 1-4
local PartyFrame = {}
for i=1, 4 do
	local frame = CreateFrame("Frame", nil, MPBFrame)
	frame:SetPoint("TOPLEFT",MPBFrame,"TOPLEFT",-75+i*125,-75)
	frame:SetSize(125,250)
	local portrait = frame:CreateTexture(nil, "OVERLAY")
	portrait:SetPoint("TOP",frame,"TOP")
	portrait:SetSize(50,50)
	local nameText = frame:CreateFontString(nil,"ARTWORK","GameFontNormal")
	nameText:SetPoint("TOP", portrait, "BOTTOM",0,-10)
	PartyFrame[i] = frame
	frame.portrait = portrait
	frame.nameText = nameText
	frame.button = {}
	frame.selected = false
	for j=1, 5 do
		local button = CreateFrame("Button",nil, frame, "BackdropTemplate")
		button:SetPoint("TOP",frame,"TOP",0,-50-30*j)
		button:SetSize(100,30)
		button:SetBackdrop(buttonBackdrop)
		button:SetBackdropColor(unpack(originalColor[j]))
		button:SetScript("OnClick", OnClick)
		button.parent = frame
		button.lvl = j
		local text = button:CreateFontString(nil,"ARTWORK","GameFontNormal")
		text:SetText(L["MPB:LV"..j])
		text:SetPoint("CENTER")
		frame.button[j] = button
	end
end

local resetTries = true
local function ResetPartyFrames()
	PlaySound(850)
	resetTries = not resetTries
	if resetTries then
		for _,frame in ipairs(PartyFrame) do UnselectButtons(frame) end
	else
		for _,frame in ipairs(PartyFrame) do
			local status = C.db.instance.mythicPlus.scoreData[frame.name]
			if status then SelectButton(frame, status) end
		end
	end
end

local function SetAllPartyFrames()
	for i=1, 4 do
		local unit, frame = "party"..i, PartyFrame[i]
		if UnitExists(unit) then
			frame:Show()
			SetPortraitTexture(frame.portrait, unit)
			local name = GetUnitName(unit, true)
			local guid = UnitGUID(unit)
			local _, class = GetPlayerInfoByGUID(guid)
			frame.nameText:SetFormattedText("|c%s%s|r",RAID_CLASS_COLORS[class].colorStr,name)
			name = GetFullName(name)
			frame.name = name
			local status = C.db.instance.mythicPlus.scoreData[name]
			if status then
				SelectButton(frame, status)
			else
				UnselectButtons(frame)
			end
		else
			frame:Hide()
			frame.selected = nil
			frame.name = nil
		end
	end
end

local confirmButton = CreateFrame("Button",nil, MPBFrame,"BackdropTemplate")
confirmButton:SetSize(300,40)
confirmButton:SetPoint("BOTTOM", MPBFrame, "BOTTOM", 0, 10)
confirmButton:SetBackdrop(buttonBackdrop)
confirmButton:SetBackdropColor(0,0.7,0.2)
local confirmText = confirmButton:CreateFontString(nil,"ARTWORK","GameFontNormal")
confirmText:SetText(L["Confirm"])
confirmText:SetPoint("CENTER")
confirmText:SetFont(defaultFont_GameFontNormal, 17)
confirmButton:SetScript("OnClick", function()
	PlaySound(851)
	for _,frame in ipairs(PartyFrame) do
		if frame.name then C.db.instance.mythicPlus.scoreData[frame.name] = frame.selected or nil end
	end
end)

local resetButton = CreateFrame("Button",nil, MPBFrame,"BackdropTemplate")
resetButton:SetSize(75,40)
resetButton:SetPoint("RIGHT", confirmButton, "LEFT")
resetButton:SetBackdrop(buttonBackdrop)
resetButton:SetBackdropColor(0.4,0.1,0.1)
local resetText = resetButton:CreateFontString(nil,"ARTWORK","GameFontNormal")
resetText:SetText(L["Reset"])
resetText:SetPoint("CENTER")
resetText:SetFont(defaultFont_GameFontNormal, 17)
resetButton:SetScript("OnClick", ResetPartyFrames)

local closeButton = CreateFrame("Button",nil, MPBFrame,"BackdropTemplate")
closeButton:SetSize(75,40)
closeButton:SetPoint("LEFT", confirmButton, "RIGHT")
closeButton:SetBackdrop(buttonBackdrop)
closeButton:SetBackdropColor(0.8,0.8,0.8)
local closeText = closeButton:CreateFontString(nil,"ARTWORK","GameFontNormal")
closeText:SetText(L["Close"])
closeText:SetPoint("CENTER")
closeText:SetFont(defaultFont_GameFontNormal, 17)
closeButton:SetScript("OnClick", function()
	PlaySound(856)
	MPBFrame:Hide()
end)

local function ShowMPB() MPBFrame:Show() end

local function DelayShow()
	local flag = false
	for _,frame in ipairs(PartyFrame) do
		if frame.name and C.db.instance.mythicPlus.scoreData[frame.name] ~= 5 then flag = true end
	end
	if flag then C_Timer.After(5, ShowMPB) end
end

-- Show after M+ or quit
local isMythicPlusStarted = false
local function StartMythicPlus()
	SetAllPartyFrames()
	currentRunText:SetFormattedText("+%d %s", MP.currentRun.level, MP.currentRun.name)
	isMythicPlusStarted = true
end

local function EndMythicPlus()
	SetAllPartyFrames()
	local _, level, _, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo()
	currentRunText:SetFormattedText("+%d %s %s/%s %s", level, MP.currentRun.name, FormatTime(MP.currentRun.time), FormatTime(MP.currentRun.timeLimit), onTime and "+"..keystoneUpgradeLevels or "-1")
	DelayShow()
	isMythicPlusStarted = false
end

local function OnZoneChangedNewArea()
	local _, zoneType = GetInstanceInfo()
	if isMythicPlusStarted and zoneType ~= "party" then
		DelayShow()
		isMythicPlusStarted = false
	end
end

-- Show player info when entering new group
local currentGroup, announcedList = {}, {}
local function OnGroupRosterUpdate()
	for i=1,4 do
		local unit = "party"..i
		if UnitExists(unit) then
			local name = GetFullName(GetUnitName(unit, true))
			local status = C.db.instance.mythicPlus.scoreData[name]
			currentGroup[name] = true
			if not announcedList[name] and status and status <= 4 then
				print(format(L["MPB:Anounce_Chat"],name,L["MPB:LV"..status]))
				announcedList[name] = true
			end
		end
	end
	for k in pairs(announcedList) do if not currentGroup[k] then announcedList[k] = nil end end
	wipe(currentGroup)
end

-- Show player info when hovering LFG
local function LFGListSearchEntryOnEnter(self)
	local resultID = self.resultID
	local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
	if not searchResultInfo.leaderName then return end
	local leaderName = GetFullName(searchResultInfo.leaderName)
	local status = C.db.instance.mythicPlus.scoreData[leaderName]
	if status then
		if searchResultInfo.isDelisted or not GameTooltip:IsShown() then return end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["MPB:Announce_Tooltips"],leaderName)
		GameTooltip:Show()
	end
end

-- Show player info when hovering applicants
local function LFGListApplicantMemberOnEnter(self)
	local applicantID = self:GetParent().applicantID
	local memberIdx = self.memberIdx
	local name = GetFullName(C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx))
	local status = C.db.instance.mythicPlus.scoreData[name]
	if status then
		if not GameTooltip:IsShown() then return end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["MPB:Announce_Tooltips"],name)
		GameTooltip:Show()
	end
end

B:AddInitScript(function()
	if C.db.instance.mythicPlus.scores then
		B:AddEventScript("CHALLENGE_MODE_START", StartMythicPlus)
		B:AddEventScript("CHALLENGE_MODE_COMPLETED", EndMythicPlus)
		B:AddEventScript("ZONE_CHANGED_NEW_AREA", OnZoneChangedNewArea)
		B:AddEventScript("GROUP_ROSTER_UPDATE", OnGroupRosterUpdate)
		hooksecurefunc("LFGListSearchEntry_OnEnter", LFGListSearchEntryOnEnter)
		hooksecurefunc("LFGListApplicantMember_OnEnter", LFGListApplicantMemberOnEnter)
		SetAllPartyFrames()
	end
end)
