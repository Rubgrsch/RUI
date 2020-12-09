local _, rui = ...
local B, L, C = unpack(rui)

-- text for 'The Eye of the Jailer'
local text = UIWidgetTopCenterContainerFrame:CreateFontString(nil, "OVERLAY")
text:SetFont(STANDARD_TEXT_FONT, 14, "THICKOUTLINE")
text:SetPoint("BOTTOM",UIWidgetTopCenterContainerFrame,"TOP",0,-10)

local function UpdateJailer()
	local raw = C_UIWidgetManager.GetDiscreteProgressStepsVisualizationInfo(2885).progressVal
	local lvl = math.floor(raw / 1000)
	if lvl < 5 then
		text:SetFormattedText("%sLV %d | %d/%d|r",B.RGBStr(1-raw/5000),lvl,raw-lvl*1000,1000)
	else
		text:SetText("|cffff0000!! LV 5 !!|r")
	end
end

local function OnUpdateUIWidget(_,_,widget)
	if widget.widgetID ~= 2885 then return end
	UpdateJailer()
end

local function OnChangeMap()
	local mapID = C_Map.GetBestMapForUnit("player")
	if mapID == 1543 then -- maw
		UpdateJailer()
		text:Show()
	else
		text:Hide()
	end
end

B:AddEventScript("ZONE_CHANGED_NEW_AREA", OnChangeMap)
B:AddEventScript("ZONE_CHANGED_INDOORS", OnChangeMap)
B:AddEventScript("ZONE_CHANGED", OnChangeMap)
B:AddEventScript("PLAYER_ENTERING_WORLD", OnChangeMap)
B:AddEventScript("UPDATE_UI_WIDGET", OnUpdateUIWidget)

B:AddInitScript(function()
	ObjectiveTrackerFrame:SetMovable(true)
	ObjectiveTrackerFrame:SetUserPlaced(true)
	ObjectiveTrackerFrame:SetHeight(300)
	B:SetupMover(ObjectiveTrackerFrame, "ObjectiveTrackerFrame",L["ObjectiveTracker"])

	B:SetupMover(VehicleSeatIndicator, "VehicleSeatIndicator",L["VehicleSeat"])
	hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", C.mover[VehicleSeatIndicator], "TOPLEFT")
		end
	end)
end)
