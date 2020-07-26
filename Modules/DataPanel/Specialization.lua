local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP

local specMenuList = {
	{text = SPECIALIZATION, notCheckable = true},
}
local lootMenuList = {
	{text = SELECT_LOOT_SPECIALIZATION, notCheckable = true},
	{checked = function() return GetLootSpecialization() == 0 end, func = function() SetLootSpecialization(0) end},
}

local function AddSpecToMenu()
	for i = 1, GetNumSpecializations() do
		local id, name, _, icon = GetSpecializationInfo(i)
		if id then
			specMenuList[#specMenuList+1] = {text = "|T"..icon..":0|t"..name, checked = function() return GetSpecialization() == i end, func = function() SetSpecialization(i) end}
			lootMenuList[#lootMenuList+1] = {text = "|T"..icon..":0|t"..name, checked = function() return GetLootSpecialization() == id end, func = function() SetLootSpecialization(id) end}
		end
	end
end

local data1 = DP:CreateData("Specialization")
data1.OnMouseUp = function(self, btn)
	if not InCombatLockdown() then
		if btn == "LeftButton" then
			EasyMenu(specMenuList, B.easyMenu, self, 0, 0, "MENU")
		else
			if not PlayerTalentFrame then LoadAddOn("Blizzard_TalentUI") end
			if PlayerTalentFrame:IsShown() then
				HideUIPanel(PlayerTalentFrame)
			else
				ShowUIPanel(PlayerTalentFrame)
			end
		end
	end
end
data1.OnEvent = function(self)
	local _, _, _, icon = GetSpecializationInfo(GetSpecialization())
	if icon then self.text:SetFormattedText(L["Spec: %d"], icon) end
end
data1.events = {"PLAYER_SPECIALIZATION_CHANGED", "PLAYER_ENTERING_WORLD"}

local data2 = DP:CreateData("Loot")
data2.OnMouseUp = function(self)
	if not InCombatLockdown() then
		EasyMenu(lootMenuList, B.easyMenu, self, 0, 0, "MENU")
	end
end
data2.OnEvent = function(self)
	local lootSpecID = GetLootSpecialization()
	local specID, name = GetSpecializationInfo(GetSpecialization())
	local _, _, _, icon = GetSpecializationInfoByID(lootSpecID == 0 and specID or lootSpecID)
	self.text:SetFormattedText(L["Loot: %d"], icon)
	lootMenuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, name)
end
data2.events = {"PLAYER_SPECIALIZATION_CHANGED", "PLAYER_LOOT_SPEC_UPDATED", "PLAYER_ENTERING_WORLD"}

B:AddInitScript(AddSpecToMenu)
