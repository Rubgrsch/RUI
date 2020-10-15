local _, rui = ...
local B, L, C = unpack(rui)

local width, height = 24, 24
local idx = 1
local function CreateMenuButton(frame, OnMouseOver, texture, texCoord)
	local button = CreateFrame("Frame", nil, frame)
	button:SetSize(width, height)
	button:SetPoint("TOPLEFT", frame, "TOPLEFT", width*(idx-1), 0)
	button:SetScript("OnMouseUp", OnMouseOver)
	button.texture = button:CreateTexture(nil, "OVERLAY")
	button.texture:SetAllPoints()
	if texture then
		button.texture:SetTexture(texture)
		if texCoord then button.texture:SetTexCoord(texCoord, 1-texCoord, texCoord, 1-texCoord) end
	end
	frame[idx] = button
	idx = idx + 1
	return button
end

local function CreateMenuBar()
	local frame = CreateFrame("Frame", "RUIMenuBar", UIParent)
	frame.texture = frame:CreateTexture(nil, "OVERLAY")
	frame.texture:SetAllPoints()
	frame.texture:SetColorTexture(0, 0, 0)
	-- Character
	local characterButton = CreateMenuButton(frame, function(self) ToggleCharacter("PaperDollFrame") end)
	characterButton:RegisterEvent("PORTRAITS_UPDATED")
	characterButton:RegisterEvent("PLAYER_ENTERING_WORLD")
	characterButton.texture:SetTexCoord(0.12, 0.88, 0.12, 0.88)
	characterButton:SetScript("OnEvent", function(self) SetPortraitTexture(self.texture, "player") end)
	-- Spellbook
	CreateMenuButton(frame, function(self) ToggleSpellBook(BOOKTYPE_SPELL) end, "INTERFACE\\ICONS\\INV_Misc_Book_09")
	-- Spec and Talent
	local specButton = CreateMenuButton(frame, function()
		if not IsAddOnLoaded("Blizzard_TalentUI") then
			TalentFrame_LoadUI()
		end
		ToggleTalentFrame()
	end)
	specButton:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	specButton:RegisterEvent("PLAYER_ENTERING_WORLD")
	specButton:SetScript("OnEvent", function(self)
		local _, _, _, icon = GetSpecializationInfo(GetSpecialization())
		self.texture:SetTexture(icon)
	end)
	-- Achievement
	CreateMenuButton(frame, ToggleAchievementFrame, "INTERFACE\\ICONS\\Achievement_Quests_Completed_07")
	-- Quest
	CreateMenuButton(frame, ToggleQuestLog, "INTERFACE\\ICONS\\Ability_Spy", 0.12)
	-- Guild
	CreateMenuButton(frame, ToggleGuildFrame, "INTERFACE\\GUILDFRAME\\GuildLogo-NoLogo", 0.12)
	-- LFD, PVEFrame_ToggleFrame is available afterwards
	CreateMenuButton(frame, function() PVEFrame_ToggleFrame() end, "INTERFACE\\ICONS\\LEVELUPICON-LFD")
	-- Collection
	CreateMenuButton(frame, function() ToggleCollectionsJournal(1) end, "INTERFACE\\ICONS\\MountJournalPortrait")
	-- Journal
	CreateMenuButton(frame, function()
		if not IsAddOnLoaded("Blizzard_EncounterJournal") then
			EncounterJournal_LoadUI()
		end
		ToggleEncounterJournal()
	end, "INTERFACE\\ICONS\\INV_Misc_Book_11")
	-- Store
	CreateMenuButton(frame, ToggleStoreUI, "INTERFACE\\ICONS\\WoW_Store")
	-- End
	frame.num = idx-1
	frame:SetSize(width*(idx-1),height)
	B:SetupMover(frame, "MenuBar",L["MenuBar"],true,function() return C.roleDB.actionBars.menuBar end)
end

function C:SetupMenuBar()
	local frame = RUIMenuBar
	if C.roleDB.actionBars.menuBar then frame:Show() else frame:Hide() end
	local buttonSize = C.roleDB.actionBars.menuBarSlotSize
	frame:SetSize(buttonSize*frame.num, buttonSize)
	B:ResizeMover(frame)
	for i=1, frame.num do
		local button = frame[i]
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonSize*(i-1), 0)
		button:SetSize(buttonSize, buttonSize)
	end
end

B:AddInitScript(function()
	if not C.roleDB.actionBars.enable then return end

	CreateMenuBar()
	C:SetupMenuBar()
end)
