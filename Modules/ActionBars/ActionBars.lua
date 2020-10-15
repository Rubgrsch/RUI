local _, rui = ...
local B, L, C = unpack(rui)

local AB = {}
B.AB = AB

local bars = {}
local barsData = {
	[1] = {
		idx = 1,
		page = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[overridebar]14;[shapeshift]13;[vehicleui]12;[possessbar]12;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1",
		visibility = "[petbattle] hide; show",
		binding = "ACTIONBUTTON",
		name = "ActionButton",
	},
	[2] = {
		idx = 6,
		page = "6",
		visibility = "[vehicleui][overridebar][petbattle] hide; show",
		binding = "MULTIACTIONBAR1BUTTON",
		name = "MultiBarBottomLeftButton",
	},
	[3] = {
		idx = 5,
		page = "5",
		visibility = "[vehicleui][overridebar][petbattle] hide; show",
		binding = "MULTIACTIONBAR2BUTTON",
		name = "MultiBarBottomRightButton",
	},
	[4] = {
		idx = 3,
		page = "3",
		visibility = "[vehicleui][overridebar][petbattle] hide; show",
		binding = "MULTIACTIONBAR3BUTTON",
		name = "MultiBarRightButton"
	},
	[5] = {
		idx = 4,
		page = "4",
		visibility = "[vehicleui][overridebar][petbattle] hide; show",
		binding = "MULTIACTIONBAR4BUTTON",
		name = "MultiBarLeftButton",
	},
}

local function ResetNormalTexture(self, texture)
	if texture and texture ~= self._normalTexture_ then
		self:SetNormalTexture(self._normalTexture_)
	end
end

local function ResetTexture(self, texture)
	if texture and texture ~= self._texture_ then
		self:SetTexture("")
	end
end

local function HandleActionButton(button)
	local buttonName = button:GetName()
	-- Texture
	button:SetNormalTexture("")
	button._normalTexture_ = ""
	hooksecurefunc(button, "SetNormalTexture", ResetNormalTexture)
	-- flyout border, like summon pet
	_G[buttonName.."FlyoutBorder"]:SetTexture("")
	_G[buttonName.."FlyoutBorderShadow"]:SetTexture("")
	-- green border for usable item
	_G[buttonName.."Border"]:SetTexture("")
	-- hotkey
	local hotkey = _G[buttonName.."HotKey"]
	hotkey:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
	hotkey:ClearAllPoints()
	hotkey:SetPoint("TOPRIGHT", 0, -1)
	-- name
	local name = _G[buttonName.."Name"]
	name:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
	name:ClearAllPoints()
	name:SetPoint("BOTTOMLEFT", 0, 0)
	-- count
	local count = _G[buttonName.."Count"]
	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT", 0, 0)
	-- float bg, only for bar4 and 5
	local floatingBG = _G[buttonName.."FloatingBG"]
	if floatingBG then floatingBG:Hide() end
	-- cooldown
	local cooldown = _G[buttonName.."Cooldown"]
	cooldown:ClearAllPoints()
	cooldown:SetPoint("CENTER", 0, 0)
	cooldown:SetPoint("TOPLEFT", 0, 0)
	cooldown:SetPoint("BOTTOMRIGHT", 0, 0)
	B:SetupCooldown(cooldown,14)
	-- Shine
	local shine = _G[buttonName.."Shine"]
	shine:ClearAllPoints()
	shine:SetPoint("CENTER", 0, 0)
	shine:SetPoint("TOPLEFT", 0, 0)
	shine:SetPoint("BOTTOMRIGHT", 0, 0)
	-- AutoCastable
	local autoCastable = _G[buttonName.."AutoCastable"]
	if autoCastable then
		autoCastable:SetTexCoord(0.23, 0.75, 0.23, 0.75) -- better ways?
		autoCastable:ClearAllPoints()
		autoCastable:SetPoint("CENTER", 0, 0)
		autoCastable:SetPoint("TOPLEFT", 0, 0)
		autoCastable:SetPoint("BOTTOMRIGHT", 0, 0)
	end
end

local function CreateActionBar(idx)
	local frameName = "RUIActionBar"..idx
	local frame = CreateFrame("Frame", frameName, UIParent, "SecureHandlerStateTemplate")
	B:SetupMover(frame, "ActionBar"..idx,format(L["ActionBar%d"],idx),true, function() return C.roleDB.actionBars["bar"..idx.."SlotsNum"] > 0 end)
	local texture = frame:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, 0.5)
	texture:SetAllPoints(true)
	frame:SetAttribute("_onstate-page", [[
		self:SetAttribute("actionpage", newstate)
	]])
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local name = barsData[idx].name..i
		local button = _G[name]
		button:SetParent(frame)
		HandleActionButton(button)
		frame:SetAttribute("_onstate-page", [[
			self:SetAttribute("actionpage", newstate)
		]])
		frame[i] = button
	end
	RegisterStateDriver(frame, "page", barsData[idx].page)
	bars[idx] = frame
end

local function CreatePetBar()
	local frameName = "RUIPetActionBar"
	local frame = CreateFrame("Frame", frameName, UIParent, "SecureHandlerStateTemplate")
	B:SetupMover(frame, "PetActionBar",L["PetActionBar"],true)
	local texture = frame:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, 0.5)
	texture:SetAllPoints(true)
	for i = 1, NUM_PET_ACTION_SLOTS do
		local name = "PetActionButton"..i
		local button = _G[name]
		button:SetParent(frame)
		button:ClearAllPoints()
		HandleActionButton(button)
		frame[i] = button
	end
	frame.visibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.visibility)
end

local function CreateVehicleLeave()
	local frameName = "RUILeaveVehicle"
	local frame = CreateFrame("Frame", frameName, UIParent, "SecureHandlerStateTemplate")
	frame:SetSize(32, 32)
	B:SetupMover(frame, "LeaveVehicleButton",L["LeaveVehicleButton"],true)
	local button = CreateFrame("CheckButton", "RUILeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
	button:SetAllPoints()
	button:RegisterForClicks("AnyUp")
	button.icon:SetTexture(237700)
	HandleActionButton(button)
	button:SetScript("OnClick", function(self)
		if UnitOnTaxi("player") then TaxiRequestEarlyLanding() else VehicleExit() end
		self:SetChecked(false)
	end)
	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	RegisterStateDriver(frame, "exit", "[canexitvehicle]1;[mounted]2;3")
	frame:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])
	if not CanExitVehicle() then frame:Hide() end
end

local function CreateStanceBar()
	local frameName = "RUIStanceBar"
	local frame = CreateFrame("Frame", frameName, UIParent, "SecureHandlerStateTemplate")
	B:SetupMover(frame, "StanceBar",L["StanceBar"],true,function() return GetNumShapeshiftForms() > 0 end)
	local num = GetNumShapeshiftForms()
	for i = 1, NUM_STANCE_SLOTS do
		local name = "StanceButton"..i
		local button = _G[name]
		button:SetParent(frame)
		button:ClearAllPoints()
		HandleActionButton(button)
		if i <= num then button:Show() else button:Hide() end
		frame[i] = button
	end
	frame.visibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", num > 0 and frame.visibility or "hide")
	-- Disable unused stance buttons
	B:AddEventScript("UPDATE_SHAPESHIFT_COOLDOWN", function()
		local num = GetNumShapeshiftForms()
		for i = 1, NUM_STANCE_SLOTS do if i <= num then frame[i]:Show() else frame[i]:Hide() end end
	end)
end

local function DisableBLZ()
	MainMenuBarArtFrame:Hide()
	MainMenuBar:SetMovable(true)
	MainMenuBar:SetUserPlaced(true)
	MainMenuBar.ignoreFramePositionManager = true
	MainMenuBar:SetAttribute("ignoreFramePositionManager", true)
	MainMenuBar:Hide()
	MainMenuBar:UnregisterAllEvents()
	MainMenuBar.Show = MainMenuBar.Hide
	MainMenuBarVehicleLeaveButton:Hide()
	MainMenuBarVehicleLeaveButton:UnregisterAllEvents()
	MainMenuBarVehicleLeaveButton.Show = OverrideActionBar.Hide
	OverrideActionBar:Hide()
	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar.Show = OverrideActionBar.Hide
	PetActionBarFrame:Hide()
	--PetActionBarFrame:UnregisterAllEvents()
	--PetActionBarFrame.Show = OverrideActionBar.Hide

	RegisterStateDriver(MultiBarLeft, "visibility", "hide")
	RegisterStateDriver(MultiBarRight, "visibility", "hide")

	ExtraActionBarFrame:SetParent(UIParent)
	B:SetupMover(ExtraActionButton1, "ExtraActionBarButton",L["ExtraActionBarButton"])
	-- TODO Cooldown
	local style = ExtraActionButton1.style
	style:SetTexture("")
	style._texture_ = ""
	hooksecurefunc(style, "SetTexture", ResetTexture)
end

local function SetOverrideKeybind()
	for idx, frame in ipairs(bars) do
		local binding = barsData[idx].binding
		ClearOverrideBindings(frame)
		for i = 1, #frame do
			for j = 1, select("#", GetBindingKey(binding..i)) do
				local key = select(j, GetBindingKey(binding..i))
				if key and key ~= "" then
					SetOverrideBindingClick(frame, false, key, barsData[idx].name..i)
				end
			end
		end
	end
end

local function ClearOverrideKeybind()
	for _, frame in ipairs(bars) do
		ClearOverrideBindings(frame)
	end
end

-- config
function C:SetupActionBarButtons(idx)
	local frame = bars[idx]
	local btnNum, btnPerRow, buttonSize = C.roleDB.actionBars["bar"..idx.."SlotsNum"], C.roleDB.actionBars["bar"..idx.."SlotsPerRow"], C.roleDB.actionBars.actionBarSlotSize
	if btnNum == 0 then
		RegisterStateDriver(frame, "visibility", "hide")
	else
		frame:SetSize(buttonSize*min(btnPerRow,btnNum), buttonSize*ceil(btnNum/btnPerRow))
		B:ResizeMover(frame)
		for i=1, #frame do
			local button = frame[i]
			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonSize*((i-1)%btnPerRow), -buttonSize*floor((i-1)/btnPerRow))
			button:SetSize(buttonSize, buttonSize)
			if i <= btnNum then button:Show() else button:Hide() end
		end
		RegisterStateDriver(frame, "visibility", barsData[idx].visibility or frame.visibility)
	end
end

function C:SetupOtherActionBarBttons()
	local buttonSize = C.roleDB.actionBars.otherBarSlotSize
	-- PetBar
	local frame, btnNum, btnPerRow = _G.RUIPetActionBar, NUM_PET_ACTION_SLOTS, C.roleDB.actionBars.perBarSlotsPerRow
	frame:SetSize(buttonSize*min(btnPerRow,btnNum), buttonSize*ceil(btnNum/btnPerRow))
	B:ResizeMover(frame)
	for i=1, #frame do
		local button = frame[i]
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonSize*((i-1)%btnPerRow), -buttonSize*floor((i-1)/btnPerRow))
		button:SetSize(buttonSize, buttonSize)
		if i <= btnNum then button:Show() else button:Hide() end
	end
	-- StanceBar
	frame, btnNum, btnPerRow = _G.RUIStanceBar, NUM_STANCE_SLOTS, C.roleDB.actionBars.stanceBarSlotsPerRow
	frame:SetSize(buttonSize*min(btnPerRow,btnNum), buttonSize*ceil(btnNum/btnPerRow))
	B:ResizeMover(frame)
	for i=1, #frame do
		local button = frame[i]
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonSize*((i-1)%btnPerRow), -buttonSize*floor((i-1)/btnPerRow))
		button:SetSize(buttonSize, buttonSize)
		if i <= btnNum then button:Show() else button:Hide() end
	end
end

B:AddInitScript(function()
	if not C.roleDB.actionBars.enable then return end
	for i=1, 5 do
		CreateActionBar(i)
		C:SetupActionBarButtons(i)
	end
	CreatePetBar()
	CreateVehicleLeave()
	CreateStanceBar()
	C:SetupOtherActionBarBttons()

	DisableBLZ()

	-- Fix elements
	-- vehicle
	local function UpdateActionButtonAction(_, event, arg1)
		if event == "ACTIONBAR_UPDATE_STATE" or ((event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and arg1 == "player") then
			local frame = bars[1]
			for i=1, #frame do
				frame[i]:UpdateAction()
				frame[i]:Update()
			end
		end
	end
	-- do we need all these??
	B:AddEventScript("UPDATE_VEHICLE_ACTIONBAR", UpdateActionButtonAction)
	B:AddEventScript("UPDATE_OVERRIDE_ACTIONBAR", UpdateActionButtonAction)
	B:AddEventScript("ACTIONBAR_UPDATE_STATE", UpdateActionButtonAction)
	B:AddEventScript("ACTIONBAR_SLOT_CHANGED", UpdateActionButtonAction)
	B:AddEventScript("UNIT_ENTERED_VEHICLE", UpdateActionButtonAction)
	B:AddEventScript("UNIT_EXITED_VEHICLE", UpdateActionButtonAction)
	-- overide keybind
	B:AddEventScript("UPDATE_BINDINGS", SetOverrideKeybind)
	B:AddEventScript("PET_BATTLE_CLOSE", SetOverrideKeybind)
	B:AddEventScript("PET_BATTLE_OPENING_DONE", ClearOverrideKeybind)
	if C_PetBattles.IsInBattle() or UnitInVehicle("player") then
		SetOverrideKeybind()
	else
		ClearOverrideKeybind()
	end
end)
