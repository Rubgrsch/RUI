local _, rui = ...
local B, L, C = unpack(rui)

local rt = CreateFrame("Frame", "RUIRaidTools", UIParent)
rt:SetSize(120,40)
B:SetupMover(rt, "RaidTools",L["RaidTools"])
local texture = rt:CreateTexture(nil, "BACKGROUND")
texture:SetColorTexture(0, 0, 0, 0.8)
texture:SetAllPoints(true)

local countdown = CreateFrame("Button", nil, rt, "SecureActionButtonTemplate")
countdown:SetNormalTexture("Interface/Icons/INV_Misc_PocketWatch_01")
countdown:SetSize(20,20)
countdown:SetPoint("TOPRIGHT",rt,"TOPRIGHT")
countdown:SetAttribute("type1", "macro")
countdown:SetAttribute("macrotext1", "/pull 12")

local ready = CreateFrame("Button", nil, rt)
ready:SetNormalTexture("Interface/Buttons/UI-CheckBox-Check")
ready:SetSize(20,20)
ready:SetPoint("BOTTOMRIGHT",rt,"BOTTOMRIGHT")
ready:SetScript("OnClick", function()
	if not InCombatLockdown() and IsInGroup() and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant("player") and IsInRaid())) then
		DoReadyCheck()
	end
end)

local t = {6,4,3,7,1,2,5,8}
for i=1, 8 do
	local f = CreateFrame("Button", nil, rt, "SecureActionButtonTemplate")
	f:SetNormalTexture("Interface/TargetingFrame/UI-RaidTargetingIcon_"..t[i])
	f:SetSize(20,20)
	f:SetPoint("TOPLEFT",rt,"TOPLEFT",20*((i-1)%4),i>4 and -20 or 0)
	f:SetAttribute("type1", "macro")
	f:SetAttribute("macrotext1", "/wm "..i)
	f:SetAttribute("macrotext2", "/cwm "..i)
end
local clear = CreateFrame("Button", nil, rt)
clear:SetNormalTexture("Interface/Buttons/UI-GroupLoot-Pass-Down")
clear:SetSize(20,20)
clear:SetPoint("TOPLEFT",rt,"TOPLEFT",20*4,-10)
clear:SetScript("OnClick", ClearRaidMarker)

local function ToggleRaidTools()
	if IsInGroup() then rt:Show() else rt:Hide() end
end

B:AddEventScript("PLAYER_ENTERING_WORLD", ToggleRaidTools)
B:AddEventScript("GROUP_ROSTER_UPDATE", ToggleRaidTools)
