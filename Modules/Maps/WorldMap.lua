local _, rui = ...
local B, L, C = unpack(rui)

local currentMapID

-- NDui method to reduce memory usage. Credits: siweia.
local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)
local function GetPlayerMapCoords()
	local mapID = currentMapID
	if not mapID then return end
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end
	local mapRect = mapRects[mapID]
	tempVec2D:Subtract(mapRect[1])
	return tempVec2D.y/mapRect[2].y, tempVec2D.x/mapRect[2].x
end

local coordinates = CreateFrame("Frame", nil, WorldMapFrame)
coordinates:SetFrameStrata("HIGH")
coordinates:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 15)
local playerCoords = coordinates:CreateFontString(nil, "OVERLAY")
playerCoords:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
playerCoords:SetTextColor(1,1,0)
playerCoords:SetPoint("BOTTOMLEFT",WorldMapFrame.BorderFrame,"BOTTOMLEFT",5,5)
local mouseCoords = coordinates:CreateFontString(nil, "OVERLAY")
mouseCoords:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
mouseCoords:SetTextColor(1,1,0)
mouseCoords:SetPoint("BOTTOMLEFT",playerCoords,"TOPLEFT",0,0)

local function UpdateMapID()
	local mapID = C_Map.GetBestMapForUnit("player")
	currentMapID = mapID
	if not mapID then return end
	local mapRect = mapRects[mapID]
	if not mapRect then	
		local p1 = select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
		local p2 = select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
		if not p1 or not p2 then return end
		mapRect = {p1, p2}
		mapRect[2]:Subtract(mapRect[1])
		mapRects[mapID] = mapRect
	end
end

local function UpdateCoords()
	if WorldMapFrame.ScrollContainer:IsMouseOver() then
		local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
		if cursorX and cursorY and cursorX > 0 and cursorY > 0 then
			mouseCoords:SetFormattedText("%s: %2.2f, %2.2f",L["Mouse"], 100 * cursorX, 100 * cursorY)
		else
			mouseCoords:SetText("")
		end
	else
		mouseCoords:SetText("")
	end
	local x, y = GetPlayerMapCoords()
	if not x or (x == 0 and y == 0) then
		playerCoords:SetText("")
	else
		playerCoords:SetFormattedText("%s: %2.2f, %2.2f",L["Player"], 100 * x, 100 * y)
	end
end

B:AddInitScript(function()
	if C.db.maps.coords then
		B:AddEventScript("ZONE_CHANGED_NEW_AREA", UpdateMapID)
		B:AddEventScript("ZONE_CHANGED_INDOORS", UpdateMapID)
		B:AddEventScript("ZONE_CHANGED", UpdateMapID)
		B:AddEventScript("PLAYER_ENTERING_WORLD", UpdateMapID)
		local timerHandler = B:AddTimer(0.1, UpdateCoords, false)
		WorldMapFrame:HookScript("OnShow", function()
			B:ToggleTimer(timerHandler, true)
		end)
		WorldMapFrame:HookScript("OnHide", function()
			B:ToggleTimer(timerHandler, false)
		end)
	end
end)
