local _, rui = ...
local B, L, C = unpack(rui)

-- Add DELETE when deleting items
hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(s) s.editBox:SetText(DELETE_ITEM_CONFIRM_STRING) end)

-- Fix LFG globalstring error
if GetLocale() == "zhCN" and strmatch((GetBuildInfo()),"^%d+") ~= "9" then
	StaticPopupDialogs["LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS"] = {
		text = "针对此项活动，你的队伍人数已满，将被移出列表。",
		button1 = OKAY,
		timeout = 0,
		whileDead = 1,
	}
end

-- Auto Achievement Screenshot, stolen from EKCore
local function AutoScreenshot() if C.db.general.autoScreenshot then C_Timer.After(1,Screenshot) end end
B:AddEventScript("ACHIEVEMENT_EARNED", AutoScreenshot)
B:AddEventScript("CHALLENGE_MODE_COMPLETED", AutoScreenshot)

-- Original: DressUpVisual()
local function NewDressUpVisual(...)
	local frame, raceFilename, classFilename
	if SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame:IsShown() then
		frame = SideDressUpFrame
		raceFilename = select(2, UnitRace("player"))
	else
		frame = DressUpFrame
		classFilename = select(2, UnitClass("player"))
	end
	SetDressUpBackground(frame, raceFilename, classFilename)

	DressUpFrame_Show(frame)

	local playerActor = frame.ModelScene:GetPlayerActor()
	if (not playerActor) then
		return false;
	end

	playerActor:Undress()
	local result = playerActor:TryOn(...)
	if ( result ~= Enum.ItemTryOnReason.Success ) then
		UIErrorsFrame:AddExternalErrorMessage(ERR_NOT_EQUIPPABLE)
	end
	DressUpFrame_OnDressModel(frame)
	return true
end

B:AddInitScript(function()
	-- Hide boss loot banner
	if C.db.general.hideBossBanner then BossBanner:UnregisterEvent("BOSS_KILL") end

	if C.db.general.undress then DressUpVisual = NewDressUpVisual end
end)
