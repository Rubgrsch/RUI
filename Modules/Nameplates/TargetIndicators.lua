local _, rui = ...
local B, L, C = unpack(rui)

local oUF = rui.oUF

local function Update(self)
	if UnitIsUnit(self.unit, "target") then
		self.TargetIndicator:Show()
	else
		self.TargetIndicator:Hide()
	end
end

local function Enable(self)
	if not self.TargetIndicator then return end
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Update, true)
end

local function Disable(self)
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
end

oUF:AddElement("TargetIndicator", Update, Enable, Disable)
