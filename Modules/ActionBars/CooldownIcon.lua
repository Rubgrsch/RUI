local _, rui = ...
local B, L, C = unpack(rui)

local cooldown = CreateFrame("Cooldown", nil, UIParent)
cooldown:SetSize(20,20)
cooldown:SetPoint("CENTER")
cooldown:Hide()
local icon = cooldown:CreateTexture(nil,"OVERLAY")
icon:SetAllPoints()
B:SetupCooldown(cooldown)
cooldown:SetScript("OnUpdate",function(self,elapsed)
	self.time = self.time + elapsed
	if self.time > 1 then
		self:Hide()
		self.time = 0
	else
		self:SetAlpha(0.8*(1-self.time))
	end
end)

cooldown:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
cooldown:SetScript("OnEvent", function(self,_,_,_,spellID)
	local start, duration, enabled, modRate = GetSpellCooldown(spellID)
	if duration < 2 then return end
	self:SetCooldown(start, duration, enabled, modRate)
	local _,_, iconID = GetSpellInfo(spellID)
	icon:SetTexture(iconID)
	local x,y = GetCursorPosition()
	local scale = self:GetEffectiveScale()
	self:SetPoint("TOPRIGHT", _G.UIParent, "BOTTOMLEFT",x/scale,y/scale)
	self.time = 0
	self:Show()
end)
