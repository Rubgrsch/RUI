local _, rui = ...
local B, L, C = unpack(rui)

-- ouf totem do not support right click to cancel, so here using additional code
local totems = CreateFrame("Frame",nil,UIParent)
totems:SetSize(20*MAX_TOTEMS,20)
B:SetupMover(totems, "TotemFrame",L["TotemFrame"],true)
for i = 1, MAX_TOTEMS do
	local totem = CreateFrame("Frame", nil, totems)
	local totemFrame = _G["TotemFrameTotem"..i]
	totem.__owner = totemFrame
	totem:SetSize(20, 20)
	totem:SetPoint("TOPLEFT", totems, "TOPLEFT", (i-1) * totem:GetWidth(), 0)
	totemFrame:SetParent(totem)
	totemFrame:SetAllPoints(totem)
	totemFrame:SetAlpha(0)
	local icon = totem:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints()
	local cooldown = CreateFrame("Cooldown", nil, totem, "CooldownFrameTemplate")
	B:SetupCooldown(cooldown,11)
	cooldown:SetReverse(true)
	totem.Cooldown = cooldown
	totem.Icon = icon
	totems[i] = totem
end

local function UpdateTotem(self)
	for i, totem in ipairs(self) do
		local haveTotem, _, startTime, duration, icon = GetTotemInfo(i)
		if haveTotem and duration > 0 then
			totem.Icon:SetTexture(icon)
			totem.Cooldown:SetCooldown(startTime, duration)
		else
			totem.Icon:SetTexture("")
			totem.Cooldown:SetCooldown(0, 0)
		end
	end
end

totems:RegisterEvent("PLAYER_TOTEM_UPDATE")
totems:RegisterEvent("PLAYER_ENTERING_WORLD")
totems:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
totems:RegisterEvent("PLAYER_TALENT_UPDATE")
totems:SetScript("OnEvent", UpdateTotem)
