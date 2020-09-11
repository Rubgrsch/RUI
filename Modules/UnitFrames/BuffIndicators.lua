local _, rui = ...
local B, L, C = unpack(rui)

local oUF = rui.oUF

local function Update(self, event, unit)
	if unit ~= self.unit then return end
	for i=1, 40 do
		local name, icon, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitBuff(unit, i)
		if name then
			local p = C.buffIndicators[spellId]
			if p then
				local button = self.BuffIndicators[p]
				if duration and duration > 0 then
					button.cd:SetCooldown(expiration - duration, duration)
					button.cd:Show()
				else
					button.cd:Hide()
				end
				button.count:SetText(count > 1 and count or "")
			end
		end
	end
end

local function Enable(self)
	if not self.BuffIndicators then return end
	local flag = false
	for k,v in pairs(C.buffIndicators) do
		if k then
			local button = self.BuffIndicators[v]
			local _, _, fileID = GetSpellInfo(k)
			button.icon:SetTexture(fileID)
			flag = true
		end
	end
	if flag then self:RegisterEvent("UNIT_AURA", Update) end
end

local function Disable()
	self:UnregisterEvent("UNIT_AURA")
end

oUF:AddElement("BuffIndicator", Update, Enable, Disable)