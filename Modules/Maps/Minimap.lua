local _, rui = ...
local B, L, C = unpack(rui)

local function SetupMinimap()
	MinimapCluster:EnableMouse(false)
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(_, offset)
		if offset > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "MiddleButton" then
			if not InCombatLockdown() then
				-- TODO: Change this after implement datapanel
				if not IsAddOnLoaded('Blizzard_EncounterJournal') then
					EncounterJournal_LoadUI()
				end
				ToggleFrame(EncounterJournal)
			end
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self)
		else
			Minimap_OnClick(self)
		end
	end)
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)
	Minimap:SetAlpha(0.9)
	Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
	Minimap:SetSize(C.db.maps.minimapSize,C.db.maps.minimapSize)
	B:SetupMover(Minimap, "Minimap",L["Minimap"])

	MinimapZoneText:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE")
	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint("TOP",Minimap,"TOP",0,-2)
	MinimapZoneTextButton:EnableMouse(false)

	-- Move thingy
	local difficulties = {"MiniMapInstanceDifficulty", "GuildInstanceDifficulty", "MiniMapChallengeMode"}
	for _, v in pairs(difficulties) do
		local difficulty = _G[v]
		difficulty:ClearAllPoints()
		difficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
	end

	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0)
	QueueStatusMinimapButtonBorder:Hide()
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -3, -3)
	MiniMapMailFrame:SetSize(18,18)
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:ClearAllPoints()
	MiniMapMailIcon:SetAllPoints()

	local blzFrames = {
		"MinimapZoomIn",
		"MinimapZoomOut",
		"MiniMapTracking",
		"MinimapBorder",
		"MinimapNorthTag",
		"MiniMapWorldMapButton",
		"MinimapBorderTop",
		"GameTimeFrame",
	}
	local function HideFrame(f)
		if f.UnregisterAllEvents then
			f:UnregisterAllEvents()
		end
		f.Show = f.Hide
		f:Hide()
	end
	for _, f in ipairs(blzFrames) do HideFrame(_G[f]) end
	if TimeManagerClockButton then
		HideFrame(TimeManagerClockButton)
	else
		B:AddEventScript("ADDON_LOADED", function(_,_,addonName)
			if addonName == "Blizzard_TimeManager" then HideFrame(TimeManagerClockButton) end
		end)
	end
end

local function SetupMinimapDataButton()
	local dataButton = CreateFrame("Button",nil,Minimap)
	dataButton:SetSize(20,20)
	dataButton:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -2)
	local dataButtonList = CreateFrame("Frame", nil, Minimap)
	dataButtonList:SetPoint("RIGHT", dataButton, "LEFT", 0, 0)
	dataButtonList:SetSize(0,20)
	dataButtonList:Hide()
	dataButtonList.idx = 0
	dataButtonList.list = {}
	dataButtonList.forceShow = false
	local texture = dataButton:CreateTexture()
	texture:SetTexture(1044996)
	texture:SetAllPoints()
	texture:SetAlpha(0.6)
	local highlight = dataButton:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetColorTexture(1, 1, 1, 0.25)
	local function ButtonOnEnter()
		texture:SetAlpha(1)
		dataButtonList:Show()
	end
	local function ButtonOnLeave()
		if not dataButtonList.forceShow then
			texture:SetAlpha(0.6)
			if dataButtonList:IsShown() then dataButtonList:Hide() end
		end
	end
	local function ButtonOnClick()
		dataButtonList.forceShow = not dataButtonList.forceShow
	end
	local function ListOnEnter(self)
		self:Show()
	end
	local function ListOnLeave(self)
		if not self.forceShow then
			self:Hide()
			texture:SetAlpha(0.6)
		end
	end
	dataButton:SetScript("OnEnter", ButtonOnEnter)
	dataButton:SetScript("OnLeave", ButtonOnLeave)
	dataButton:SetScript("OnClick", ButtonOnClick)
	dataButtonList:SetScript("OnEnter",ListOnEnter)
	dataButtonList:SetScript("OnLeave", ListOnLeave)

	local minimapButtonList = {
		"GarrisonLandingPageMinimapButton",
	}
	local function HandleMinimapButton(button)
		if dataButtonList.list[button] then return end
		local idx = dataButtonList.idx + 1
		button:ClearAllPoints()
		button:SetSize(20,20)
		button:SetParent(dataButtonList)
		button:SetPoint("RIGHT",dataButtonList,"RIGHT",-idx*20+20,0)
		dataButtonList.idx = idx
		dataButtonList:SetSize(idx*20,20)
		dataButtonList.list[button] = button
	end

	for _, f in ipairs(minimapButtonList) do HandleMinimapButton(_G[f]) end
end

B:AddInitScript(function()
	if C.db.maps.minimap then
		SetupMinimap()
		SetupMinimapDataButton()
	end
end)
