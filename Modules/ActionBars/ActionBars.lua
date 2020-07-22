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

local buttonSize = 32

local function ResetNormalTexture(self)
	local texture = self:GetNormalTexture()
	if texture and texture ~= self._lastNormalTexture_ then
		self:SetNormalTexture(nil)
		self._lastNormalTexture_ = texture
	end
end

local function ResetTexture(self)
	local texture = self:GetTexture()
	if texture and texture ~= self._lastTexture_ then
		self:SetTexture(nil)
		self._lastTexture_ = texture
	end
end

local function HandleActionButton(button)
	local buttonName = button:GetName()
	-- Texture
	button:SetNormalTexture(nil)
	hooksecurefunc(button, "SetNormalTexture", ResetNormalTexture)
	-- flyout border, like summon pet
	_G[buttonName.."FlyoutBorder"]:SetTexture(nil)
	_G[buttonName.."FlyoutBorderShadow"]:SetTexture(nil)
	-- green border for usable item
	_G[buttonName.."Border"]:SetTexture(nil)
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
end

local function CreateActionBar(idx, btnPerRow)
	local frameName = "RUIActionBar"..idx
	local frame = CreateFrame("Frame", frameName, UIParent, "SecureHandlerStateTemplate")
	frame:SetSize(buttonSize*btnPerRow, buttonSize*ceil(NUM_ACTIONBAR_BUTTONS/btnPerRow))
	B:SetupMover(frame, "ActionBar"..idx,L["ActionBar"..idx],true)
	local texture = frame:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, 0.5)
	texture:SetAllPoints(true)
	frame.btnPerRow = btnPerRow or NUM_ACTIONBAR_BUTTONS
	frame:SetAttribute("_onstate-page", [[
		self:SetAttribute("actionpage", newstate)
	]])
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local name = barsData[idx].name..i
		local button = _G[name]
		button:SetParent(frame)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonSize*((i-1)%btnPerRow), -buttonSize*floor((i-1)/btnPerRow))
		button:SetSize(buttonSize,buttonSize)
		HandleActionButton(button)
		frame:SetAttribute("_onstate-page", [[
			self:SetAttribute("actionpage", newstate)
		]])
		frame[i] = button
	end
	RegisterStateDriver(frame, "page", barsData[idx].page)
	RegisterStateDriver(frame, "visibility", barsData[idx].visibility)
	bars[idx] = frame
end

local function CreatePetBar(btnPerRow)
	local frameName = "RUIPetActionBar"
	local frame = CreateFrame("Frame", frameName, UIParent, "SecureHandlerStateTemplate")
	frame:SetSize(buttonSize*btnPerRow, buttonSize*ceil(NUM_PET_ACTION_SLOTS/btnPerRow))
	B:SetupMover(frame, "PetActionBar",L["PetActionBar"],true)
	local texture = frame:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, 0.5)
	texture:SetAllPoints(true)
	frame.btnPerRow = btnPerRow or NUM_PET_ACTION_SLOTS
	for i = 1, NUM_PET_ACTION_SLOTS do
		local name = "PetActionButton"..i
		local button = _G[name]
		button:SetParent(frame)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonSize*((i-1)%btnPerRow), -buttonSize*floor((i-1)/btnPerRow))
		button:SetSize(buttonSize,buttonSize)
		HandleActionButton(button)
		frame[i] = button
	end
	RegisterStateDriver(frame, "visibility", "[pet] show; hide")
end

local function DisableBLZ()
	MainMenuBarArtFrame:Hide()
	MainMenuBar:Hide()
	MainMenuBar:UnregisterAllEvents()
	MainMenuBar.Show = MainMenuBar.Hide
	OverrideActionBar:Hide()
	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar.Show = OverrideActionBar.Hide
	PetActionBarFrame:Hide()
	--PetActionBarFrame:UnregisterAllEvents()
	--PetActionBarFrame.Show = OverrideActionBar.Hide

	--MicroButtonAndBagsBar:SetSize(300,20)
	--B:SetupMover(MicroButtonAndBagsBar, "MicroButtonBar",L["MicroButtonBar"])
	RegisterStateDriver(MultiBarLeft, "visibility", "hide")
	RegisterStateDriver(MultiBarRight, "visibility", "hide")

	ExtraActionBarFrame:SetParent(UIParent)
	B:SetupMover(ExtraActionButton1, "ExtraActionBarButton",L["ExtraActionBarButton"])
	local style = ExtraActionButton1.style
	style:SetTexture(nil)
	hooksecurefunc(style, "SetTexture", ResetTexture)
end

local function SetOverrideKeybind()
	local frame = bars[1]
	local binding = barsData[1].binding
	ClearOverrideBindings(frame)
	for i = 1, #frame do
		for j = 1, select("#", GetBindingKey(binding..i)) do
			local key = select(j, GetBindingKey(binding..i))
			if key and key ~= "" then
				SetOverrideBindingClick(frame, false, key, barsData[1].name..i)
			end
		end
	end
end

local function ClearOverrideKeybind()
	ClearOverrideBindings(bars[1])
end

B:AddInitScript(function()
	if not C.roleDB.actionBars.enable then return end
	CreateActionBar(1,12)
	CreateActionBar(2,12)
	CreateActionBar(3,6)
	CreateActionBar(4,1)
	CreateActionBar(5,1)
	CreatePetBar(10)

	DisableBLZ()

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
