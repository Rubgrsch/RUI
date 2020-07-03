local _, rui = ...
local B, L, C = unpack(rui)

local BAG = {}
B.BAG = BAG

local containerSize = 22

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
	if i < 0 then -- Bank slots
		slot.GetInventorySlot = i == -3 and ReagentButtonInventorySlot or ButtonInventorySlot
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
			else
				slot.itemLevel:SetText("")
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
	local slotSize = holder:GetParent().slotSize
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
		bags:GetParent():SetSize(bags.slotSize*bags.slotsPerRow+5,bags.slotSize*bags.rows+52)
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

local function OnLeave()
	GameTooltip:Hide()
end

-- Bags
local function CreateBagContainer()
	local f = CreateFrame("Frame", "RBagContainer")
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
	sortButton:SetScript("OnClick", SortBags)
end

-- Bank
local function CreateBankContainer()
	local f = CreateFrame("Frame", "RBankContainer")
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
	UpdateSlots(reagent)
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
	sortButton:SetScript("OnClick", function()
		PlaySound(852)
		if reagent:IsShown() then
			SortReagentBankBags()
		else
			SortBankBags()
		end
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
	depositReagentButton.tooltipText = L["Import Reagent"]
	depositReagentButton:SetPoint("LEFT",reagentButton,"RIGHT", 2, 0)
	depositReagentButton:SetScript("OnEnter", OnEnter)
	depositReagentButton:SetScript("OnLeave", OnLeave)
	depositReagentButton:SetScript("OnClick", function()
		PlaySound(852)
		DepositReagentBank()
	end)
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
	BAG.bankFrame:Show()
end

local function CloseBank()
	CloseBag()
	BAG.bankFrame:Hide()
end

local function SetMoneyText()
	BAG.goldText:SetFormattedText(B.MoneyString(GetMoney(), 3))
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
local function ResizeSlot(slot,size)
	slot:SetSize(size, size)
	slot:SetNormalTexture(nil)
	slot.IconBorder:SetSize(size,size)
	slot.IconOverlay:SetSize(size,size)
	if slot.NewItemTexture then slot.NewItemTexture:SetSize(size,size) end
	local questTexture = _G[slot:GetName().."IconQuestTexture"]
	if questTexture then questTexture:SetSize(size,size) end
end

function BAG:SetupSize()
	if not C.db.bags.enable then return end
	local bagSlotSize = C.db.bags.bagSlotSize
	local bagSlotsPerRow = C.db.bags.bagSlotsPerRow
	local bankSlotSize = C.db.bags.bankSlotSize
	local bankSlotsPerRow = C.db.bags.bankSlotsPerRow
	BAG.bags.slotSize = bagSlotSize
	BAG.bank.slotSize = bankSlotSize
	BAG.reagent.slotSize = bankSlotSize
	BAG.bags.slotsPerRow = bagSlotsPerRow
	BAG.bank.slotsPerRow = bankSlotsPerRow
	BAG.reagent.slotsPerRow = bankSlotsPerRow
	-- Resize Created Slots
	for _, i in ipairs(BAG.bags.bagIDs) do
		for _, slot in ipairs(slots[i]) do
			ResizeSlot(slot,bagSlotSize)
		end
	end
	for _, i in ipairs(BAG.bank.bagIDs) do
		for _, slot in ipairs(slots[i]) do
			ResizeSlot(slot,bankSlotSize)
		end
	end
	for _, i in ipairs(BAG.reagent.bagIDs) do
		for _, slot in ipairs(slots[i]) do
			ResizeSlot(slot,bankSlotSize)
		end
	end
	SetSlots(BAG.bags, true)
	SetSlots(BAG.bank, true)
	SetSlots(BAG.reagent, true)
end

B:AddInitScript(function()
	if not C.db.bags.enable then return end
	-- Frames
	CreateBagContainer()
	CreateBankContainer()
	SetMoneyText()
	-- Onupdate timer
	sellJunkTimer = B:AddTimer(0.2, SellJunk, false)
	-- Events
	B:AddEventScript("BAG_UPDATE", UpdateBankAndBag)
	B:AddEventScript("BAG_UPDATE_COOLDOWN", UpdateBankAndBag)
	B:AddEventScript("QUEST_ACCEPTED", UpdateBankAndBag)
	B:AddEventScript("QUEST_REMOVED", UpdateBankAndBag)
	B:AddEventScript("ITEM_LOCK_CHANGED", UpdateBankAndBag)
	B:AddEventScript("PLAYERBANKSLOTS_CHANGED", UpdateBankAndBag)
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
end)
