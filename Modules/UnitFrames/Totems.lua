local _, rui = ...
local B, L, C = unpack(rui)

-- ouf totem do not support right click to cancel, so here using additional code
local totems = CreateFrame("Frame")
totems:SetSize(20*MAX_TOTEMS,20)
B:SetupMover(totems, "TotemFrame",L["TotemFrame"],true)
for i = 1, MAX_TOTEMS do
	local totem = CreateFrame("Button", nil, totems, "SecureActionButtonTemplate")
	totem:SetSize(20, 20)
	totem:SetPoint("TOPLEFT", totems, "TOPLEFT", (i-1) * totem:GetWidth(), 0)
	totem:RegisterForClicks("RightButtonUp")
	totem:SetAttribute("*type2", "destroytotem")
	totem:SetAttribute("totem-slot", i)
	totem:SetID(i)
	local texture = totem:CreateTexture(nil, "BACKGROUND")
	texture:SetAllPoints()
	texture:SetColorTexture(0,0,0,0.5)
	local icon = totem:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints()
	local cooldown = CreateFrame("Cooldown", nil, totem, "CooldownFrameTemplate")
	cooldown:SetAllPoints()
	B:SetupCooldown(cooldown,11)
	cooldown:SetReverse(true)
	totem.Icon = icon
	totem.Cooldown = cooldown
	totems[i] = totem
end

local function UpdateTotem(self)
	for i, totem in ipairs(self) do
		local haveTotem, _, startTime, duration, icon = GetTotemInfo(i)
		if haveTotem and duration > 0 then
			totem.Icon:SetTexture(icon)
			totem.Cooldown:SetCooldown(startTime, duration)
		end
	end
end

totems:RegisterEvent("PLAYER_TOTEM_UPDATE")
totems:RegisterEvent("PLAYER_ENTERING_WORLD")
totems:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
totems:RegisterEvent("PLAYER_TALENT_UPDATE")
totems:SetScript("OnEvent", UpdateTotem)
