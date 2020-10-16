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
		if btn == "RightButton" then
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
	dataButton:SetNormalTexture(1044996)
	dataButton:GetNormalTexture():SetAlpha(0.6)
	dataButton:SetHighlightTexture(1044996)
	local dataButtonList = CreateFrame("Frame", nil, dataButton)
	dataButtonList:SetPoint("RIGHT", dataButton, "LEFT")
	dataButtonList:Hide()
	dataButtonList.offset = 0
	dataButtonList.list = {}
	local forceShow = false
	dataButton:SetScript("OnEnter", function(self)
		self:GetNormalTexture():SetAlpha(1)
		dataButtonList:Show()
	end)
	dataButton:SetScript("OnLeave", function(self)
		if not forceShow then
			self:GetNormalTexture():SetAlpha(0.6)
			if dataButtonList:IsShown() then dataButtonList:Hide() end
		end
	end)
	dataButton:SetScript("OnClick", function()
		forceShow = not forceShow
	end)

	local BLZMinimapButtonList = {
		"GarrisonLandingPageMinimapButton",
	}
	local function HandleMinimapButton(button, isLDB)
		if dataButtonList.list[button] then return end
		local idx = #dataButtonList.list
		button:ClearAllPoints()
		button:SetParent(dataButtonList)
		local offset = -dataButtonList.offset
		button:SetPoint("RIGHT",dataButtonList,"RIGHT",offset,0)
		hooksecurefunc(button, "SetPoint", function(self, _, parent)
			if parent ~= dataButtonList then
				self:ClearAllPoints()
				self:SetPoint("RIGHT",dataButtonList,"RIGHT",offset,0)
			end
		end)
		dataButtonList.offset = dataButtonList.offset + button:GetSize()
		dataButtonList.list[idx+1] = button
		if isLDB then
			if button:GetScript("OnDragStart") then button:SetScript("OnDragStart", nil) end
			if button:GetScript("OnDragStop") then button:SetScript("OnDragStop", nil) end
			if button:GetScript("OnMouseDown") then button:SetScript("OnMouseDown", nil) end
			if button:GetScript("OnMouseUp") then button:SetScript("OnMouseUp", nil) end
		end
	end

	for _, f in ipairs(BLZMinimapButtonList) do HandleMinimapButton(_G[f]) end
	for _, f in ipairs({Minimap:GetChildren()}) do
		if f and f:GetName() and f:GetName():find("LibDBIcon10_") then
			HandleMinimapButton(f, true)
		end
	end
	dataButtonList:SetSize(dataButtonList.offset,40)
end

B:AddInitScript(function()
	if C.db.maps.minimap then
		SetupMinimap()
		SetupMinimapDataButton()
	end
end)
