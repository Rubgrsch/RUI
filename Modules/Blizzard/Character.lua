local _, rui = ...
local B, L, C = unpack(rui)

-- Item info
local itemToFresh = {}
local function RegisterItem(id, func, ...)
	local t = {func, ...}
	if itemToFresh[id] then
		local tt = itemToFresh[id]
		tt[#tt+1] = t
	else
		itemToFresh[id] = {t}
	end
end

B:AddEventScript("GET_ITEM_INFO_RECEIVED",function(_,_,id,success)
	if not itemToFresh[id] then return end
	if success then
		for _, v in ipairs(itemToFresh[id]) do v[1](select(2,unpack(v))) end
	end
	itemToFresh[id] = nil
end)

-- playerFrame
local slots = {
	"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand", "SecondaryHand", "Tabard",
}

local inspectInit = false
local function CreateString(unitStr)
	for i = 1, #slots do
		local slot = _G[unitStr..slots[i].."Slot"]
		slot.itemLevel = slot:CreateFontString(nil, "OVERLAY", nil, 1)
		slot.itemLevel:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
		slot.itemLevel:SetPoint("BOTTOMRIGHT", 0, 2)
	end
	if unitStr == "Inspect" then
		local iLvl = InspectFrame:CreateFontString(nil, "OVERLAY")
		iLvl:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
		iLvl:SetPoint("BOTTOMRIGHT", -10, 10)
		InspectFrame.iLvl = iLvl
	end
end

local function UpdateSlotItemLevel(slot,itemLink)
	if itemLink then
		local _, _, quality = GetItemInfo(itemLink)
		if quality == nil then
			-- query for item info
			local id = tonumber(itemLink:match("item:(%d+)"))
			RegisterItem(id,UpdateSlotItemLevel,slot,itemLink)
			return false
		end
		local iLvl = GetDetailedItemLevelInfo(itemLink)
		if iLvl then
			slot.itemLevel:SetText(iLvl)
			slot.itemLevel:SetTextColor(GetItemQualityColor(quality))
		else
			slot.itemLevel:SetText("")
		end
	else
		slot.itemLevel:SetText("")
	end
	return true
end

local function UpdatePlayerItemLevel()
	for i=1, #slots do
		local slot = _G["Character"..slots[i].."Slot"]
		local itemLink = GetInventoryItemLink("player", i)
		UpdateSlotItemLevel(slot,itemLink)
	end
end

local function UpdateInspectItemLevel(_,_,guid)
	if not inspectInit then
		CreateString("Inspect")
		inspectInit = true
	end
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		local iLvlSum, allReady, twohand = 0, true, false
		for i=1, #slots do
			local slot = _G["Inspect"..slots[i].."Slot"]
			local itemLink = GetInventoryItemLink(InspectFrame.unit, i)
			if itemLink then
				local ready = UpdateSlotItemLevel(slot,itemLink)
				if i ~= 4 and i ~= 18 then
					if ready then
						local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
						local iLvl = GetDetailedItemLevelInfo(itemLink)
						if i <= 15 or (i == 17 and not twohand) then
							iLvlSum = iLvlSum + iLvl
						elseif i == 16 then
							if itemEquipLoc == "INVTYPE_2HWEAPON" or itemEquipLoc == "INVTYPE_RANGED" then
								iLvlSum = iLvlSum + iLvl * 2
								twohand = true
							else
								iLvlSum = iLvlSum + iLvl
							end
						end
					else
						allReady = false
					end
				end
			end
		end
		if allReady then InspectFrame.iLvl:SetFormattedText(L["ILvl:%.1f"], iLvlSum/16) end
	end
end

B:AddInitScript(function()
	CreateString("Character")
	UpdatePlayerItemLevel()
	B:AddEventScript("PLAYER_EQUIPMENT_CHANGED", UpdatePlayerItemLevel)
	B:AddEventScript("INSPECT_READY", UpdateInspectItemLevel)
end)
