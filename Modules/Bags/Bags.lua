local _, rui = ...
local B, L, C = unpack(rui)

local BAG = {}
B.BAG = BAG

local slotSize = 30

local isNotEquipmentLoc = {[""] = true, ["INVTYPE_BAG"] = true, ["INVTYPE_QUIVER"] = true, ["INVTYPE_TABARD"] = true}

-- slot content
local function UpdateSlotContent(slot, i, j)
	-- ContainerFrame.lua Line 587
	-- Set content
	local texture, count, locked, quality, readable, _, itemLink, isFiltered = GetContainerItemInfo(i,j)
	SetItemButtonTexture(slot, texture)
	SetItemButtonCount(slot, count)
	SetItemButtonDesaturated(slot, locked)
	SetItemButtonQuality(slot, quality, itemLink)
	-- quest texture
	local questTexture = _G[slot:GetName().."IconQuestTexture"]
	if questTexture then
		local isQuestItem, questId, isActive = GetContainerItemQuestInfo(i, j)
		if ( questId and not isActive ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
			questTexture:Show()
		elseif ( questId or isQuestItem ) then
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
	if i < 0 then -- Bank slots
		slot.GetInventorySlot = ButtonInventorySlot
		slot.UpdateTooltip = BankFrameItemButton_OnEnter
	end
	if slot == tooltip:GetOwner() then
		if texture then
			slot:UpdateTooltip()
		else
			tooltip:Hide()
		end
	end
	slot:SetMatchesSearch(not isFiltered)
	-- Item Level
	if slot.itemLevel then
		if itemLink then
			local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, itemClassID, itemSubClassID = GetItemInfo(itemLink)
			local iLvl = GetDetailedItemLevelInfo(itemLink)
			if ((itemClassID == 3 and itemSubClassID == 11) or not isNotEquipmentLoc[itemEquipLoc]) and (quality and quality > 1) and iLvl then
				slot.itemLevel:SetText(iLvl)
				slot.itemLevel:SetTextColor(GetItemQualityColor(quality))
			end
		else
			slot.itemLevel:SetText("")
		end
	end
end

local slots = {}

local id = 1
local function CreateSlot(holder, i,j)
	local slot = CreateFrame("ItemButton", "RSlot"..id,holder, i == -1 and "BankItemButtonGenericTemplate" or "ContainerFrameItemButtonTemplate")
	id = id + 1
	slot:SetSize(slotSize, slotSize)
	slot:SetNormalTexture(nil)
	slot.IconBorder:SetSize(slotSize,slotSize)
	slot.IconOverlay:SetSize(slotSize,slotSize)
	if slot.NewItemTexture then slot.NewItemTexture:SetSize(slotSize,slotSize) end
	local questTexture = _G[slot:GetName().."IconQuestTexture"]
	if questTexture then questTexture:SetSize(slotSize,slotSize) end
	slot.Count:SetPoint("BOTTOMRIGHT",0,2)
	slot.itemLevel = slot:CreateFontString(nil, "OVERLAY", nil, 1)
	slot.itemLevel:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
	slot.itemLevel:SetPoint("BOTTOMRIGHT", 0, 2)
	slot:SetID(j)
	slot:Show()
	slots[i][j] = slot
	return slot
end

local function SetSlots(bags)
	local flag = false
	-- Check if bag size changed, if changed then reset points.
	-- Use #slots since no need to reset points if we just swap two same size bags
	for _, i  in ipairs(bags.bagIDs) do
		if not slots[i] then slots[i] = {lastSlots = -1} end
		local numSlots = GetContainerNumSlots(i)
		if numSlots ~= slots[i].lastSlots then flag = true end
		slots[i].lastSlots = numSlots
	end
	if flag then
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
	bags:SetSize(slotSize*bags.slotsPerRow+2,slotSize*bags.rows+2)
	-- Update bagFrame size
	if bags.enable then
		bags:GetParent():SetSize(slotSize*bags.slotsPerRow+5,slotSize*bags.rows+52)
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
local function ShowTooltip(self)
	local tooltip = GameTooltip
	tooltip:SetOwner(self, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT")
	tooltip:ClearLines()
	tooltip:AddLine(self.tooltipText)
	tooltip:Show()
end

-- Bags
local function CreateBagFrame(frame)
	local bags = CreateFrame("Frame", "RBag", frame)
	bags.bagIDs = {0, 1, 2, 3, 4}
	bags:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	bags.holders = {}
	bags.bagIcons = {}
	bags.slotsPerRow = 10
	for _, i in ipairs(bags.bagIDs) do
		local holder = CreateFrame("Frame", "RBagHolder"..i, bags)
		holder:SetID(i)
		bags.holders[i] = holder
	end
	BAG.bags = bags
	bags.enable = true
	UpdateSlots(bags)
	return bags
end

local function CreateBagContainer()
	local f = CreateFrame("Frame", "RBagContainer")
	f:SetFrameStrata("HIGH")
	f:SetPoint("BOTTOMRIGHT", -10, 20)
	f:Hide()
	tinsert(UISpecialFrames, f:GetName())
	BAG.bagsFrame = f
	local texture = f:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, 0.8)
	texture:SetAllPoints(true)
	-- Bag
	local bags = CreateBagFrame(f)
	-- backpack
	local backpack = CreateFrame("ItemButton", "RBackpack",f, "ItemAnimTemplate")
	local backpackSize = 22
	backpack:SetSize(backpackSize, backpackSize)
	backpack:SetNormalTexture(nil)
	backpack.IconBorder:SetSize(backpackSize,backpackSize)
	backpack.IconOverlay:SetSize(backpackSize,backpackSize)
	backpack:SetPoint("TOPLEFT", f, "TOPLEFT")
	backpack.icon:SetTexture(130716)
	backpack:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	backpack:SetScript("OnClick", PutItemInBackpack)
	backpack:SetScript("OnReceiveDrag", PutItemInBackpack)
	backpack:Show()
	-- Bag Icons
	for i=1, 4 do
		local icon = CreateFrame("ItemButton", "RBag"..i,f, "ContainerFrameItemButtonTemplate")
		icon:SetSize(backpackSize, backpackSize)
		icon:SetNormalTexture(nil)
		icon.IconBorder:SetSize(backpackSize,backpackSize)
		icon.IconOverlay:SetSize(backpackSize,backpackSize)
		icon.NewItemTexture:SetSize(backpackSize,backpackSize)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", f, "TOPLEFT", backpackSize*i, 0)
		icon:Show()
		icon:SetID(i-4)
		bags.bagIcons[i] = {icon, 0, i-4}
		UpdateSlotContent(icon, 0, i-4)
	end
	-- Gold
	local goldText = f:CreateFontString(nil, "OVERLAY")
	goldText:SetPoint("TOPRIGHT",f,"TOPRIGHT", 0, -backpackSize/2+12/2)
	goldText:SetFont(STANDARD_TEXT_FONT, 12)
	BAG.goldText = goldText
	-- Sort
	local sortButton = CreateFrame("Button", nil, f)
	sortButton:SetSize(16, 16)
	sortButton:SetNormalTexture(655994)
	sortButton:SetPoint("LEFT",bags.bagIcons[4][1],"RIGHT", 10, 0)
	sortButton.tooltipText = L["Sort Bags"]
	sortButton:SetScript("OnEnter", ShowTooltip)
	sortButton:SetScript("OnClick", SortBags)
end

-- Bank
local function CreateBankFrame(frame)
	local bank = CreateFrame("Frame", "RBank", frame)
	bank.bagIDs = {-1, 5, 6, 7, 8, 9, 10, 11}
	bank:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	bank.holders = {}
	bank.bagIcons = {}
	bank.slotsPerRow = 12
	for _, i in ipairs(bank.bagIDs) do
		local holder = CreateFrame("Frame", "RBankHolder"..i, bank)
		holder:SetID(i)
		bank.holders[i] = holder
	end
	BAG.bank = bank
	bank.enable = true
	return bank
end

local function CreateBankReagent(frame)
	local bankReagent = CreateFrame("Frame", "RBankReagent", frame)
	bankReagent.bagIDs = {-3}
	bankReagent:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	bankReagent.holders = {}
	bankReagent.bagIcons = {}
	bankReagent.slotsPerRow = 10
	bankReagent:Hide()
	local holder = CreateFrame("Frame", "RBankReagentHolder", bankReagent)
	holder:SetID(-3)
	bankReagent.holders[-3] = holder
	BAG.bankReagent = bankReagent
	bankReagent.enable = false
	UpdateSlots(bankReagent)
	return bankReagent
end

local function CreateBankContainer()
	local f = CreateFrame("Frame", "RBankContainer")
	f:SetFrameStrata("HIGH")
	f:SetPoint("BOTTOMLEFT", 10, 20)
	f:Hide()
	f:SetID(-4)
	tinsert(UISpecialFrames, f:GetName())
	BAG.bankFrame = f
	local texture = f:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, 0.8)
	texture:SetAllPoints(true)
	-- Bank
	local bank = CreateBankFrame(f)
	-- Reagent
	local reagent = CreateBankReagent(f)
	-- Bank Icons
	for i=1, 7 do
		local icon = CreateFrame("ItemButton", "RBank"..i,f,"BankItemButtonBagTemplate")
		local iconSize = 25
		icon:SetSize(iconSize, iconSize)
		icon:SetNormalTexture(nil)
		icon.IconBorder:SetSize(iconSize,iconSize)
		icon.IconOverlay:SetSize(iconSize,iconSize)
		icon:SetID(i)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", f, "TOPLEFT", -iconSize+iconSize*i, 0)
		icon:Show()
		icon.isBag = 1
		UpdateSlotContent(icon, -4, i)
		bank.bagIcons[i] = {icon, -4, i}
	end
	local sortButton, reagentButton, depositReagentButton
	-- Sort
	sortButton = CreateFrame("Button", nil, f)
	sortButton:SetSize(16, 16)
	sortButton:SetNormalTexture(655994)
	sortButton:SetPoint("LEFT",bank.bagIcons[7][1],"RIGHT", 10, 0)
	sortButton.tooltipText = L["Sort Bank"]
	sortButton:SetScript("OnEnter", ShowTooltip)
	sortButton:SetScript("OnClick", function()
		if reagent:IsShown() then
			SortReagentBankBags()
		else
			SortBankBags()
		end
	end)
	-- Reagent
	reagentButton = CreateFrame("Button", nil, f)
	reagentButton:SetSize(16, 16)
	reagentButton:SetNormalTexture(1379169)
	reagentButton.tooltipText = L["Reagent"]
	reagentButton:SetPoint("LEFT",sortButton,"RIGHT", 2, 0)
	reagentButton:SetScript("OnEnter", ShowTooltip)
	reagentButton:SetScript("OnClick", function()
		if reagent:IsShown() then
			reagent:Hide()
			bank:Show()
			depositReagentButton:Hide()
			bank.enable = true
			reagent.enable = false
			SetSlots(bank)
		else
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
	depositReagentButton:SetNormalTexture(1379169)
	depositReagentButton.tooltipText = L["Import Reagent"]
	depositReagentButton:SetPoint("LEFT",sortButton,"RIGHT", 2, 0)
	depositReagentButton:SetScript("OnEnter", ShowTooltip)
	depositReagentButton:SetScript("OnClick", DepositReagentBank)
	depositReagentButton:Hide()
end

local function UpdateBankAndBag()
	if BAG.bagsFrame:IsShown() then
		UpdateSlots(BAG.bags)
	else
		BAG.bags.needUpdate = true
	end
	if BAG.bankFrame:IsShown() then
		UpdateSlots(BAG.bank)
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
	BAG.bankFrame:Show()
end

local function CloseBank()
	CloseBag()
	BAG.bankFrame:Hide()
end

local function SetMoneyText()
	BAG.goldText:SetFormattedText(B.MoneyString(GetMoney(), 3))
end

B:AddInitScript(function()
	-- Frames
	CreateBagContainer()
	CreateBankContainer()
	SetMoneyText()
	-- Events
	B:AddEventScript("BAG_UPDATE", UpdateBankAndBag)
	B:AddEventScript("PLAYERBANKSLOTS_CHANGED", UpdateBankAndBag)
	B:AddEventScript("BAG_UPDATE_COOLDOWN", UpdateBankAndBag)
	B:AddEventScript("BAG_SLOT_FLAGS_UPDATED", UpdateBankAndBag)
	B:AddEventScript("QUEST_ACCEPTED", UpdateBankAndBag)
	B:AddEventScript("QUEST_REMOVED", UpdateBankAndBag)
	B:AddEventScript("ITEM_LOCK_CHANGED", UpdateBankAndBag)
	B:AddEventScript("BANKFRAME_OPENED", OpenBank)
	B:AddEventScript("BANKFRAME_CLOSED", CloseBank)
	B:AddEventScript("PLAYER_MONEY", SetMoneyText)
	hooksecurefunc("ToggleAllBags", ToggleBags)
	-- Disable BLZ containers
	BankFrame:UnregisterAllEvents()
	for i=1, NUM_CONTAINER_FRAMES do
		local f = _G["ContainerFrame"..i]
		f:UnregisterAllEvents()
		f.Show = f.Hide
	end
end)
