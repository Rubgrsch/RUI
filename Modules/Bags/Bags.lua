local _, rui = ...
local B, L, C = unpack(rui)

local BAG = {}
B.BAG = BAG

local containerSize = 22
local searchText = ""

local isNotEquipmentLoc = {[""] = true, ["INVTYPE_BAG"] = true, ["INVTYPE_QUIVER"] = true, ["INVTYPE_TABARD"] = true}
local itemQualities = {}
local slots = {}
local BagFilterIcon = {
	[LE_BAG_FILTER_FLAG_EQUIPMENT] = 132745,
	[LE_BAG_FILTER_FLAG_CONSUMABLES] = 134873,
	[LE_BAG_FILTER_FLAG_TRADE_GOODS] = 132906,
}

-- Main Search func, current rules:
-- [Exact] itemID / itemQuality
-- [Exact, ~= 1] iLvl / count
-- [Find] itemName
local function IsSlotSearchMatched(i,j)
	local flag = false
	local _, itemCount, _, quality, _, _, itemLink, _, _, itemID = GetContainerItemInfo(i, j)
	if itemLink then
		local text = searchText
		local textnum = tonumber(searchText)
		local itemName = GetItemInfo(itemLink)
		local iLvl = GetDetailedItemLevelInfo(itemLink)
		if itemName then
			if		itemID == textnum
				or	(iLvl == textnum and textnum ~= 1)
				or	(itemCount == textnum and textnum ~= 1)
				or	itemQualities[quality] == text
				or	itemName:find(text)
			then
				flag = true
			end
		end
	end
	return flag
end

-- This only update alpha, used for OnTextChanged
local function UpdateSearchSlots(bags)
	for _,i in ipairs(bags.bagIDs) do
		for j = 1, GetContainerNumSlots(i) do
			local slot = slots[i][j]
			if searchText == "" or IsSlotSearchMatched(i, j) then
				slot:SetAlpha(1)
			else
				slot:SetAlpha(0.2)
			end
		end
	end
end

local function OnTextChanged(self)
	searchText = self:GetText()
	if BAG.bagsFrame.editBox:GetText() ~= searchText then BAG.bagsFrame.editBox:SetText(searchText) end
	if BAG.bankFrame.editBox:GetText() ~= searchText then BAG.bankFrame.editBox:SetText(searchText) end
	UpdateSearchSlots(BAG.bags)
	if BAG.bankFrame:IsShown() then
		UpdateSearchSlots(BAG.bank)
		UpdateSearchSlots(BAG.reagent)
	end
end

local function GetBagFlag(id)
	for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
		if ( i ~= LE_BAG_FILTER_FLAG_JUNK ) then
			if GetBagSlotFlag(id, i) then return i end
		end
	end
end

local itemLocation = ItemLocation:CreateEmpty()

-- slot content
local function UpdateSlotContent(slot, i, j)
	-- FrameXML\ContainerFrame.lua Line 587 -- wow-ui-source
	-- Set content
	local texture, count, locked, quality, readable, _, itemLink = GetContainerItemInfo(i,j)
	SetItemButtonTexture(slot, texture)
	SetItemButtonCount(slot, count)
	SetItemButtonDesaturated(slot, locked)
	SetItemButtonQuality(slot, quality, itemLink)
	-- quest texture
	local questTexture = _G[slot:GetName().."IconQuestTexture"]
	if questTexture then
		local isQuestItem, questId, isActive = GetContainerItemQuestInfo(i, j)
		if questId and not isActive then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
			questTexture:Show()
		elseif questId or isQuestItem then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER)
			questTexture:Show()
		else
			questTexture:Hide()
		end
	end
	if slot.NewItemTexture then
		-- textures
		local isNewItem = C_NewItems.IsNewItem(i, j)
		local isBattlePayItem = IsBattlePayItem(i, j)
		local battlepayItemTexture = slot.BattlepayItemTexture
		local newItemTexture = slot.NewItemTexture
		local flash = slot.flashAnim
		local newItemAnim = slot.newitemglowAnim
		if isNewItem then
			if isBattlePayItem then
				newItemTexture:Hide()
				battlepayItemTexture:Show()
			else
				if quality and NEW_ITEM_ATLAS_BY_QUALITY[quality] then
					newItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality])
				else
					newItemTexture:SetAtlas("bags-glow-white")
				end
				battlepayItemTexture:Hide()
				newItemTexture:Show()
			end
			if not flash:IsPlaying() and not newItemAnim:IsPlaying() then
				flash:Play()
				newItemAnim:Play()
			end
		else
			battlepayItemTexture:Hide()
			newItemTexture:Hide()
			if flash:IsPlaying() or newItemAnim:IsPlaying() then
				flash:Stop()
				newItemAnim:Stop()
			end
		end
	end
	-- Cooldown
	if texture then
		local start, duration, enable = GetContainerItemCooldown(i, j)
		CooldownFrame_Set(_G[slot:GetName().."Cooldown"], start, duration, enable)
		slot.hasItem = 1
	else
		_G[slot:GetName().."Cooldown"]:Hide()
		slot.hasItem = nil
	end
	slot.readable = readable
	-- Tooltip
	local tooltip = GameTooltip
	if slot == tooltip:GetOwner() then
		if texture then
			slot:UpdateTooltip()
		else
			tooltip:Hide()
		end
	end
	-- End of BLZ code
	-- Start of my code
	-- For bag slots (excluding bag icons)
	if not slot.itemLevel then return end
	if itemLink then
		-- Search
		if searchText == "" or IsSlotSearchMatched(i, j) then
			slot:SetAlpha(1)
		else
			slot:SetAlpha(0.2)
		end
		local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, itemClassID, itemSubClassID, bindType = GetItemInfo(itemLink)
		-- Item Level
		local iLvl = GetDetailedItemLevelInfo(itemLink)
		if ((itemClassID == 3 and itemSubClassID == 11) or not isNotEquipmentLoc[itemEquipLoc]) and (quality and quality > 1) and iLvl then
			slot.itemLevel:SetText(iLvl)
			slot.itemLevel:SetTextColor(GetItemQualityColor(quality))
		else
			slot.itemLevel:SetText("")
		end
		-- BoE star
		if bindType == 2 then
			itemLocation:SetBagAndSlot(i, j)
			local isBound = C_Item.IsBound(itemLocation)
			if not isBound then slot.BoE:SetText("*") end
		else
			slot.BoE:SetText("")
		end
		slot.BoE:SetTextColor(GetItemQualityColor(quality))
	else
		-- For bag icons
		slot.itemLevel:SetText("")
		slot.BoE:SetText("")
	end
	if slot.filterIcon then
		if GetBagFlag(i) then
			filterIcon:SetTexture(BagFilterIcon[i])
			filterIcon:Show()
		else
			filterIcon:Hide()
		end
	end
end

local slotNum = 1
local function CreateSlot(holder, i,j)
	local slot = CreateFrame("ItemButton", "RSlot"..slotNum,holder, (i == -1 or i == -3) and "BankItemButtonGenericTemplate" or "ContainerFrameItemButtonTemplate")
	slotNum = slotNum + 1
	local slotSize = holder:GetParent().slotSize
	slot:SetSize(slotSize, slotSize)
	slot:SetNormalTexture(nil)
	slot.IconBorder:SetSize(slotSize,slotSize)
	slot.IconOverlay:SetSize(slotSize,slotSize)
	if slot.NewItemTexture then slot.NewItemTexture:SetSize(slotSize,slotSize) end
	local questTexture = _G[slot:GetName().."IconQuestTexture"]
	if questTexture then questTexture:SetSize(slotSize,slotSize) end
	slot.Count:SetPoint("BOTTOMRIGHT",0,2)
	-- iLvl
	slot.itemLevel = slot:CreateFontString(nil, "OVERLAY", nil, 1)
	slot.itemLevel:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
	slot.itemLevel:SetPoint("BOTTOMRIGHT", 0, 2)
	-- BoE star
	slot.BoE = slot:CreateFontString(nil, "OVERLAY", nil, 1)
	slot.BoE:SetFont(STANDARD_TEXT_FONT, 20, "OUTLINE")
	slot.BoE:SetPoint("TOPRIGHT", 0, 0)
	if i < 0 then -- Bank slots
		slot.GetInventorySlot = i == -3 and ReagentButtonInventorySlot or ButtonInventorySlot
		slot.UpdateTooltip = BankFrameItemButton_OnEnter
	end
	slot:SetID(j)
	slots[i][j] = slot
	return slot
end

local function SetSlots(bags,forceRefresh)
	local flag = false
	-- Check if bag size changed, if changed then reset points.
	-- Use #slots since no need to reset points if we just swap two same size bags
	for _, i  in ipairs(bags.bagIDs) do
		if not slots[i] then slots[i] = {lastSlots = -1} end
		local numSlots = GetContainerNumSlots(i)
		if numSlots ~= slots[i].lastSlots then flag = true end
		slots[i].lastSlots = numSlots
	end
	if flag or forceRefresh then
		-- Reset slots points
		local slotsInRow, rows, first, last = 0, 0, nil, nil
		local slotsPerRow = bags.slotsPerRow
		for _, i  in ipairs(bags.bagIDs) do
			local numSlots = GetContainerNumSlots(i)
			for j = 1, numSlots do
				local slot = slots[i][j] or CreateSlot(bags.holders[i], i,j)
				-- Set Point
				slot:ClearAllPoints()
				if not first or not last then
					slot:SetPoint("TOPLEFT",bags,"TOPLEFT")
					first = slot
					rows = rows + 1
				elseif slotsInRow < slotsPerRow then
					slot:SetPoint("LEFT",last,"RIGHT")
				else
					slot:SetPoint("TOP",first,"BOTTOM")
					slotsInRow = slotsInRow - slotsPerRow
					first = slot
					rows = rows + 1
				end
				slot:Show()
				last = slot
				slotsInRow = slotsInRow + 1
			end
			for j = numSlots + 1, #slots[i] do
				local slot = slots[i][j]
				slot:ClearAllPoints()
				slot:Hide()
			end
		end
		bags.rows = rows
	end
	bags:SetSize(bags.slotSize*bags.slotsPerRow+2,bags.slotSize*bags.rows+2)
	-- Update bagFrame size
	if bags.enable then
		bags:GetParent():SetSize(bags.slotSize*bags.slotsPerRow+5,bags.slotSize*bags.rows+44)
	end
end

local function UpdateSlots(bags)
	SetSlots(bags)
	-- Bag slots
	for _,i in ipairs(bags.bagIDs) do
		for j = 1, GetContainerNumSlots(i) do
			local slot = slots[i][j]
			-- content
			UpdateSlotContent(slot, i, j)
		end
	end
	-- Bags
	for _, v in ipairs(bags.bagIcons) do UpdateSlotContent(v[1], v[2], v[3]) end
	bags.needUpdate = false
end

-- Frame event scripts
local function OnEnter(self)
	local tooltip = GameTooltip
	tooltip:SetOwner(self, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT")
	tooltip:ClearLines()
	tooltip:AddLine(self.tooltipText)
	tooltip:Show()
end

local function OnLeave() GameTooltip:Hide() end

local function ClearFocus(self) self:ClearFocus() end

-- FrameXML\ContainerFrame.lua Line 1669 -- wow-ui-source
local function BagFlagDropdown()
	local dropdown = BAG.bagFlagDropdown
	local id = dropdown.id
	local frame = dropdown.frame
	if not id or not frame then return end

	local info = UIDropDownMenu_CreateInfo()
	if not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(id)) then
		info.text = BAG_FILTER_ASSIGN_TO
		info.isTitle = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info)

		info.isTitle = nil
		info.notCheckable = nil
		info.tooltipWhileDisabled = 1
		info.tooltipOnButton = 1

		for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
			if ( i ~= LE_BAG_FILTER_FLAG_JUNK ) then
				info.text = BAG_FILTER_LABELS[i]
				info.func = function(_, _, _, value)
					value = not value
					if (id > NUM_BAG_SLOTS) then
						SetBankBagSlotFlag(id - NUM_BAG_SLOTS, i, value)
					else
						SetBagSlotFlag(id, i, value)
					end
					if (value) then
						frame.localFlag = i
						frame.filterIcon:SetTexture(BagFilterIcon[i])
						frame.filterIcon:Show()
					else
						frame.filterIcon:Hide()
						frame.localFlag = -1
					end
				end
				if (frame.localFlag) then
					info.checked = frame.localFlag == i
				else
					if (id > NUM_BAG_SLOTS) then
						info.checked = GetBankBagSlotFlag(id - NUM_BAG_SLOTS, i)
					else
						info.checked = GetBagSlotFlag(id, i)
					end
				end
				info.disabled = nil
				info.tooltipTitle = nil
				UIDropDownMenu_AddButton(info)
			end
		end
	end

	info.text = BAG_FILTER_CLEANUP
	info.isTitle = 1
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info)

	info.isTitle = nil
	info.notCheckable = nil
	info.isNotRadio = true
	info.disabled = nil

	info.text = BAG_FILTER_IGNORE
	info.func = function(_, _, _, value)
		if (id == -1) then
			SetBankAutosortDisabled(not value)
		elseif (id == 0) then
			SetBackpackAutosortDisabled(not value)
		elseif (id > NUM_BAG_SLOTS) then
			SetBankBagSlotFlag(id - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value)
		else
			SetBagSlotFlag(id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value)
		end
	end
	if (id == -1) then
		info.checked = GetBankAutosortDisabled()
	elseif (id == 0) then
		info.checked = GetBackpackAutosortDisabled()
	elseif (id > NUM_BAG_SLOTS) then
		info.checked = GetBankBagSlotFlag(id - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP)
	else
		info.checked = GetBagSlotFlag(id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP)
	end
	UIDropDownMenu_AddButton(info)
end

-- Bags
local function CreateBagContainer()
	local f = CreateFrame("Frame", "RBagContainer")
	f:EnableMouse(true)
	f:SetFrameStrata("HIGH")
	f:SetPoint("BOTTOMRIGHT", -10, 20)
	f:Hide()
	tinsert(UISpecialFrames, f:GetName())
	BAG.bagsFrame = f
	local texture = f:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, 0.85)
	texture:SetAllPoints(true)
	-- Bag
	local bags = CreateFrame("Frame", "RBag", f)
	bags.bagIDs = {0, 1, 2, 3, 4}
	bags:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
	bags.holders = {}
	bags.bagIcons = {}
	bags.slotsPerRow = C.db.bags.bagSlotsPerRow
	bags.slotSize = C.db.bags.bagSlotSize
	for _, i in ipairs(bags.bagIDs) do
		local holder = CreateFrame("Frame", "RBagHolder"..i, bags)
		holder:SetID(i)
		bags.holders[i] = holder
	end
	BAG.bags = bags
	bags.enable = true
	UpdateSlots(bags)
	-- backpack
	local backpack = CreateFrame("ItemButton", "RBackpack",f, "ItemAnimTemplate")
	backpack:SetSize(containerSize, containerSize)
	backpack:SetNormalTexture(nil)
	backpack.IconBorder:SetSize(containerSize,containerSize)
	backpack.IconOverlay:SetSize(containerSize,containerSize)
	backpack:SetPoint("TOPLEFT", f, "TOPLEFT")
	backpack.icon:SetTexture(130716)
	backpack:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	backpack:SetScript("OnClick", PutItemInBackpack)
	backpack:SetScript("OnReceiveDrag", PutItemInBackpack)
	backpack:Show()
	-- Bag Icons
	for i=1, 4 do
		local icon = CreateFrame("ItemButton", "RBag"..i,f, "ContainerFrameItemButtonTemplate")
		icon:SetSize(containerSize, containerSize)
		icon:SetNormalTexture(nil)
		icon.IconBorder:SetSize(containerSize,containerSize)
		icon.IconOverlay:SetSize(containerSize,containerSize)
		icon.NewItemTexture:SetSize(containerSize,containerSize)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", f, "TOPLEFT", containerSize*i, 0)
		icon:Show()
		icon:SetID(i-4)
		local filterIcon = icon:CreateTexture(nil, "OVERLAY")
		filterIcon:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT")
		filterIcon:SetPoint("TOPLEFT", icon, "CENTER")
		icon.filterIcon = filterIcon
		local flag = GetBagFlag(i)
		if flag then
			filterIcon:SetTexture(BagFilterIcon[flag])
			filterIcon:Show()
		else
			filterIcon:Hide()
		end
		icon:SetScript("OnClick", function(self, btn)
			if btn == "RightButton" then
				local dropdown = BAG.bagFlagDropdown
				dropdown.id = i
				dropdown.frame = self
				ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
			end
		end)
		bags.bagIcons[i] = {icon, 0, i-4}
		UpdateSlotContent(icon, 0, i-4)
	end
	-- Gold
	local goldText = f:CreateFontString(nil, "OVERLAY")
	goldText:SetPoint("TOPRIGHT",f,"TOPRIGHT", 0, -containerSize/2+12/2)
	goldText:SetFont(STANDARD_TEXT_FONT, 12)
	BAG.goldText = goldText
	-- Sort
	local sortButton = CreateFrame("Button", nil, f)
	sortButton:SetSize(16, 16)
	sortButton:SetNormalTexture(655994)
	sortButton:SetPoint("LEFT",bags.bagIcons[4][1],"RIGHT", 10, 0)
	sortButton.tooltipText = L["Sort Bags"]
	sortButton:SetScript("OnEnter", OnEnter)
	sortButton:SetScript("OnLeave", OnLeave)
	local function postUpdate()
		sortButton:Enable()
		BAG:ToggleAllBagUpdate() -- Delay to skip events spam
	end
	sortButton:SetScript("OnClick", function()
		PlaySound(852)
		sortButton:Disable()
		BAG:ToggleAllBagUpdate(false)
		SortBags()
		C_Timer.After(0.5, postUpdate) -- Delay to skip events spam
	end)
	-- Search
	local editBox = CreateFrame("EditBox", nil, f)
	editBox:SetPoint("TOPLEFT", backpack, "BOTTOMLEFT", 2, -2)
	editBox:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -2, -38)
	editBox:SetAutoFocus(false)
	editBox:SetFont(STANDARD_TEXT_FONT, 14)
	editBox:SetTextInsets(14,0,0,0)
	editBox:SetScript("OnEscapePressed", ClearFocus)
	editBox:SetScript("OnEnterPressed", ClearFocus)
	editBox:SetScript("OnTextChanged", OnTextChanged)
	f.editBox = editBox
	local editboxTexture = editBox:CreateTexture(nil, "OVERLAY")
	editboxTexture:SetTexture(374210)
	editboxTexture:SetPoint("TOPLEFT", editBox, "TOPLEFT")
	editboxTexture:SetSize(14,14)
end

-- Bank
local function CreateBankContainer()
	local f = CreateFrame("Frame", "RBankContainer")
	f:SetMovable(true)
	f:SetFrameStrata("HIGH")
	f:SetPoint("BOTTOMLEFT", 10, 20)
	f:Hide()
	f:SetID(-4)
	tinsert(UISpecialFrames, f:GetName())
	BAG.bankFrame = f
	local texture = f:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, 0.85)
	texture:SetAllPoints(true)
	-- Bank
	local bank = CreateFrame("Frame", "RBank", f)
	bank.bagIDs = {-1, 5, 6, 7, 8, 9, 10, 11}
	bank:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
	bank.holders = {}
	bank.bagIcons = {}
	bank.slotsPerRow = C.db.bags.bankSlotsPerRow
	bank.slotSize = C.db.bags.bankSlotSize
	for _, i in ipairs(bank.bagIDs) do
		local holder = CreateFrame("Frame", "RBankHolder"..i, bank)
		holder:SetID(i)
		bank.holders[i] = holder
	end
	BAG.bank = bank
	bank.enable = true
	-- Reagent
	local reagent = CreateFrame("Frame", "RBankReagent", f)
	reagent.bagIDs = {-3}
	reagent:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
	reagent.holders = {}
	reagent.bagIcons = {}
	reagent.slotsPerRow = C.db.bags.bankSlotsPerRow
	reagent.slotSize = C.db.bags.bankSlotSize
	reagent:Hide()
	local holder = CreateFrame("Frame", "RBankReagentHolder", reagent)
	holder:SetID(-3)
	reagent.holders[-3] = holder
	BAG.reagent = reagent
	reagent.enable = false
	-- Bank backpack
	local bankBackpack = CreateFrame("ItemButton", "RBankBackpack",f, "BankItemButtonBagTemplate")
	bankBackpack:SetScript("OnClick", function(self)
		local inventoryID = self:GetInventorySlot()
		PutItemInBag(inventoryID)
	end)
	bankBackpack:SetSize(containerSize, containerSize)
	bankBackpack:SetNormalTexture(nil)
	bankBackpack.IconBorder:SetSize(containerSize,containerSize)
	bankBackpack.IconOverlay:SetSize(containerSize,containerSize)
	bankBackpack:SetPoint("TOPLEFT", f, "TOPLEFT")
	bankBackpack.icon:SetTexture(130716)
	bankBackpack:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	bankBackpack:Show()
	bankBackpack:SetID(-1)
	bankBackpack.tooltipText = ""
	-- Bank Containers
	local numSlots, full = GetNumBankSlots()
	for i=1, numSlots do
		local icon = (BAG.bank.bagIcons[i] and BAG.bank.bagIcons[i][1]) or CreateFrame("ItemButton", "RBank"..i,f,"BankItemButtonBagTemplate")
		icon:SetSize(containerSize, containerSize)
		icon:SetNormalTexture(nil)
		icon.IconBorder:SetSize(containerSize,containerSize)
		icon.IconOverlay:SetSize(containerSize,containerSize)
		icon:SetID(i)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", f, "TOPLEFT", containerSize*i, 0)
		icon:Show()
		icon.tooltipText = BANK_BAG
		local filterIcon = icon:CreateTexture(nil, "OVERLAY")
		filterIcon:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT")
		filterIcon:SetPoint("TOPLEFT", icon, "CENTER")
		icon.filterIcon = filterIcon
		local flag = GetBagFlag(i+4)
		if flag then
			filterIcon:SetTexture(BagFilterIcon[flag])
			filterIcon:Show()
		else
			filterIcon:Hide()
		end
		icon:SetScript("OnClick", function(self, btn)
			if btn == "RightButton" then
				local dropdown = BAG.bagFlagDropdown
				dropdown.id = i+4
				dropdown.frame = self
				ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
			end
		end)
		UpdateSlotContent(icon, -4, i)
		BAG.bank.bagIcons[i] = {icon, -4, i}
	end
	if not full then
		local icon = CreateFrame("Button", "RBankPurchase",f)
		icon:SetScript("OnClick", function()
			local cost = GetBankSlotCost(numSlots)
			BankFrame.nextSlotCost = cost
			SetMoneyFrameColor("BankFrameDetailMoneyFrame", GetMoney() >= cost and "white" or "red")
			MoneyFrame_Update("BankFrameDetailMoneyFrame", cost)
			StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
		end)
		icon.tooltipText = L["Purchase Bags"]
		icon:SetScript("OnEnter", OnEnter)
		icon:SetScript("OnLeave", OnLeave)
		icon:SetSize(containerSize, containerSize)
		icon:SetPoint("TOPLEFT", f, "TOPLEFT", containerSize*(numSlots+1), 0)
		icon:SetNormalTexture(132763)
	end
	local sortButton, reagentButton, depositReagentButton
	-- Sort
	sortButton = CreateFrame("Button", nil, f)
	sortButton:SetSize(16, 16)
	sortButton:SetNormalTexture(655994)
	sortButton:SetPoint("TOPLEFT",f,"TOPLEFT", 10+containerSize*8, -(containerSize-16)/2)
	sortButton.tooltipText = L["Sort Bank"]
	sortButton:SetScript("OnEnter", OnEnter)
	sortButton:SetScript("OnLeave", OnLeave)
	local function postUpdate()
		sortButton:Enable()
		BAG:ToggleAllBagUpdate() -- Delay to skip events spam
	end
	sortButton:SetScript("OnClick", function(self)
		PlaySound(852)
		self:Disable()
		BAG:ToggleAllBagUpdate(false)
		if reagent:IsShown() then
			SortReagentBankBags()
		else
			SortBankBags()
		end
		C_Timer.After(0.5, postUpdate)
	end)
	-- Reagent
	reagentButton = CreateFrame("Button", nil, f)
	reagentButton:SetSize(16, 16)
	reagentButton:SetNormalTexture(1379169) -- 132761
	reagentButton.tooltipText = L["Reagent"]
	reagentButton:SetPoint("LEFT",sortButton,"RIGHT", 2, 0)
	reagentButton:SetScript("OnEnter", OnEnter)
	reagentButton:SetScript("OnLeave", OnLeave)
	reagentButton:SetScript("OnClick", function()
		if not IsReagentBankUnlocked() then
			StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
		elseif reagent:IsShown() then
			PlaySound(852)
			reagent:Hide()
			bank:Show()
			depositReagentButton:Hide()
			bank.enable = true
			reagent.enable = false
			SetSlots(bank)
		else
			PlaySound(852)
			bank:Hide()
			reagent:Show()
			depositReagentButton:Show()
			bank.enable = false
			reagent.enable = true
			SetSlots(reagent)
		end
	end)
	-- Deposit Reagent
	depositReagentButton = CreateFrame("Button", nil, f)
	depositReagentButton:SetSize(16, 16)
	depositReagentButton:SetNormalTexture(450905)
	depositReagentButton.tooltipText = L["Deposit Reagent"]
	depositReagentButton:SetPoint("LEFT",reagentButton,"RIGHT", 2, 0)
	depositReagentButton:SetScript("OnEnter", OnEnter)
	depositReagentButton:SetScript("OnLeave", OnLeave)
	depositReagentButton:SetScript("OnClick", function()
		PlaySound(852)
		DepositReagentBank()
	end)
	depositReagentButton:Hide()
	-- Search
	local editBox = CreateFrame("EditBox", nil, f)
	editBox:SetPoint("TOPLEFT", bankBackpack, "BOTTOMLEFT", 2, -2)
	editBox:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -2, -38)
	editBox:SetAutoFocus(false)
	editBox:SetFont(STANDARD_TEXT_FONT, 14)
	editBox:SetTextInsets(14,0,0,0)
	editBox:SetScript("OnEscapePressed", ClearFocus)
	editBox:SetScript("OnEnterPressed", ClearFocus)
	editBox:SetScript("OnTextChanged", OnTextChanged)
	f.editBox = editBox
	local editboxTexture = editBox:CreateTexture(nil, "OVERLAY")
	editboxTexture:SetTexture(374210)
	editboxTexture:SetPoint("TOPLEFT", editBox, "TOPLEFT")
	editboxTexture:SetSize(14,14)
end

local function UpdateBankAndBag()
	if BAG.bagsFrame:IsShown() then
		UpdateSlots(BAG.bags)
	else
		BAG.bags.needUpdate = true
	end
	if BAG.bankFrame:IsShown() then
		UpdateSlots(BAG.bank)
		UpdateSlots(BAG.reagent)
	end
end

local function OpenBag()
	if BAG.bags.needUpdate then UpdateSlots(BAG.bags) end
	PlaySound(862)
	BAG.bagsFrame:Show()
end

local function CloseBag()
	PlaySound(863)
	BAG.bagsFrame:Hide()
end

local function ToggleBags()
	if BAG.bagsFrame:IsShown() then CloseBag() else OpenBag() end
end

local function OpenBank()
	OpenBag()
	UpdateSlots(BAG.bank)
	UpdateSlots(BAG.reagent)
	BAG.bankFrame:Show()
end

local function CloseBank()
	CloseBag()
	BAG.bankFrame:Hide()
end

local function SetMoneyText()
	BAG.goldText:SetFormattedText(B.MoneyString(GetMoney(), 3))
end

function BAG:ToggleAllBagUpdate(status)
	if status == false then
		B:RemoveEventScript("BAG_UPDATE", UpdateBankAndBag)
		B:RemoveEventScript("BAG_UPDATE_COOLDOWN", UpdateBankAndBag)
		B:RemoveEventScript("QUEST_ACCEPTED", UpdateBankAndBag)
		B:RemoveEventScript("QUEST_REMOVED", UpdateBankAndBag)
		B:RemoveEventScript("ITEM_LOCK_CHANGED", UpdateBankAndBag)
		B:RemoveEventScript("PLAYERBANKSLOTS_CHANGED", UpdateBankAndBag)
	else
		B:AddEventScript("BAG_UPDATE", UpdateBankAndBag)
		B:AddEventScript("BAG_UPDATE_COOLDOWN", UpdateBankAndBag)
		B:AddEventScript("QUEST_ACCEPTED", UpdateBankAndBag)
		B:AddEventScript("QUEST_REMOVED", UpdateBankAndBag)
		B:AddEventScript("ITEM_LOCK_CHANGED", UpdateBankAndBag)
		B:AddEventScript("PLAYERBANKSLOTS_CHANGED", UpdateBankAndBag)
		UpdateBankAndBag()
	end
end

-- Auto sell junk / Auto Repair
local junkList, idx = {}, 1
local sellJunkTimer
local function EndSellJunk()
	wipe(junkList)
	idx = 1
	B:ToggleTimer(sellJunkTimer, false)
end

local function SellJunk()
	local t = junkList[idx]
	if not t then
		EndSellJunk()
		return
	end
	UseContainerItem(t[1], t[2])
	idx = idx + 1
end

local flagSkipGuild = false
local function OnMerchantShow()
	OpenBag()
	-- repair
	if C.db.bags.autoRepair > 0 and CanMerchantRepair() then
		local cost = GetRepairAllCost()
		if cost > 0 then
			RepairAllItems(C.db.bags.autoRepair == 2 and not flagSkipGuild and IsInGuild() and CanGuildBankRepair() and cost > GetGuildBankWithdrawMoney())
		end
	end
	-- sell junk
	if C.db.bags.autoSellJunk then
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local itemID = GetContainerItemID(bag, slot)
				if itemID then
					local _, _, itemRarity, _, _, itemType, _, _, _, _, itemSellPrice = GetItemInfo(itemID)
					if itemRarity and itemRarity == 0 and itemType ~= "Quest" and itemSellPrice > 0 then
						junkList[#junkList+1] = {bag, slot}
					end
				end
			end
		end
		B:ToggleTimer(sellJunkTimer, true)
	end
end
B:AddEventScript("UI_ERROR_MESSAGE", function(_, _, errorType) if errorType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then flagSkipGuild = true end end)

local function OnMerchantClosed()
	if C.db.bags.autoSellJunk then EndSellJunk() end
	CloseBag()
end

-- config and init
local function ResizeSlots(bags)
	local size = bags.slotSize
	for _, i in ipairs(bags.bagIDs) do
		if slots[i] then -- in case we didn't create them
			for _, slot in ipairs(slots[i]) do
				slot:SetSize(size, size)
				slot:SetNormalTexture(nil)
				slot.IconBorder:SetSize(size,size)
				slot.IconOverlay:SetSize(size,size)
				if slot.NewItemTexture then slot.NewItemTexture:SetSize(size,size) end
				local questTexture = _G[slot:GetName().."IconQuestTexture"]
				if questTexture then questTexture:SetSize(size,size) end
			end
		end
	end
	SetSlots(bags, true)
end

function C:ResizeBags()
	if not C.db.bags.enable then return end
	BAG.bags.slotSize = C.db.bags.bagSlotSize
	BAG.bank.slotSize = C.db.bags.bankSlotSize
	BAG.reagent.slotSize = C.db.bags.bankSlotSize
	BAG.bags.slotsPerRow = C.db.bags.bagSlotsPerRow
	BAG.bank.slotsPerRow = C.db.bags.bankSlotsPerRow
	BAG.reagent.slotsPerRow = C.db.bags.bankSlotsPerRow
	-- Resize Created Slots
	ResizeSlots(BAG.bags)
	ResizeSlots(BAG.bank)
	ResizeSlots(BAG.reagent)
end

B:AddInitScript(function()
	if not C.db.bags.enable then return end
	-- Bag flag dropdown
	local dropdown = CreateFrame("Frame", "RBagFlagDropdown", UIParent, "UIDropDownMenuTemplate")
	BAG.bagFlagDropdown = dropdown
	UIDropDownMenu_Initialize(dropdown, BagFlagDropdown, "MENU")
	-- Frames
	CreateBagContainer()
	CreateBankContainer()
	SetMoneyText()
	-- Onupdate timer
	sellJunkTimer = B:AddTimer(0.2, SellJunk, false)
	-- Events
	BAG:ToggleAllBagUpdate()
	B:AddEventScript("BANKFRAME_OPENED", OpenBank)
	B:AddEventScript("BANKFRAME_CLOSED", CloseBank)
	B:AddEventScript("MERCHANT_SHOW", OnMerchantShow)
	B:AddEventScript("MERCHANT_CLOSED", OnMerchantClosed)
	B:AddEventScript("PLAYER_MONEY", SetMoneyText)
	hooksecurefunc("ToggleAllBags", ToggleBags)
	-- Disable BLZ frames
	BankFrame:UnregisterAllEvents()
	for i=1, NUM_CONTAINER_FRAMES do
		local f = _G["ContainerFrame"..i]
		f:UnregisterAllEvents()
		f.Show = f.Hide
	end
	MicroButtonAndBagsBar.MicroBagBar:Hide()
	MainMenuBarBackpackButton:Hide()
	MainMenuBarBackpackButton:UnregisterAllEvents()
	for i=0, 3 do
		local f = _G["CharacterBag"..i.."Slot"]
		f:Hide()
		f:UnregisterAllEvents()
		f.Show = f.Hide
	end
	-- Add search info
	for i in pairs(ITEM_QUALITY_COLORS) do itemQualities[i] = _G["ITEM_QUALITY"..i.."_DESC"] end
end)
