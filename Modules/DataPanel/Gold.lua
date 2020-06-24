local _, rui = ...
local B, L, C = unpack(rui)

local DP = B.DP
local MoneyString = B.MoneyString

local loginMoney

local data = DP:CreateData("Gold")
data.OnEnter = function(self)
	if not C.db.dataPanel.tooltipInCombat and InCombatLockdown() then return end
	local tooltip = GameTooltip
	tooltip:SetOwner(self, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
	tooltip:ClearLines()
	local moneyChange = GetMoney() - loginMoney
	local symbol
	if moneyChange == 0 then symbol = ""
	elseif moneyChange > 0 then  symbol = "+"
	else symbol = "-" end
	tooltip:AddDoubleLine(L["ThisSession:"], symbol..format(MoneyString(math.abs(moneyChange), C.db.dataPanel.moneyFormat)))
	tooltip:Show()
end
data.OnMouseUp = function(self)
	if not InCombatLockdown() then
		ToggleAllBags()
	end
end
data.OnEvent = function(self)
	local m = GetMoney()
	if not loginMoney then loginMoney = m end
	self.text:SetFormattedText(MoneyString(m, C.db.dataPanel.moneyFormat))
end
data.events = {"PLAYER_ENTERING_WORLD", "PLAYER_MONEY"}
