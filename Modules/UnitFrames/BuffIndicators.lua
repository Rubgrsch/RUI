local _, rui = ...
local B, L, C = unpack(rui)

local oUF = rui.oUF

local function Update(self, _, unit)
	if unit ~= self.unit then return end
	for i=1, 4 do
		local button = self.BuffIndicators[i]
		button.shouldHide = true
	end
	for i=1, 40 do
		local name, _, count, _, duration, expiration, _, _, _, spellId = UnitBuff(unit, i)
		if name then
			local p = C.buffIndicators[spellId]
			if p then
				local button = self.BuffIndicators[p]
				if duration and duration > 0 then
					button.cd:SetCooldown(expiration - duration, duration)
					button.cd:Show()
					button.icon:Show()
					button.shouldHide = false
				else
					button.shouldHide = true
				end
				button.count:SetText(count > 1 and count or "")
			end
		end
	end
	for i=1, 4 do
		local button = self.BuffIndicators[i]
		if button.shouldHide then
			button.icon:Hide()
			button.cd:Hide()
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
			button.icon:Hide()
			flag = true
		end
	end
	if flag then self:RegisterEvent("UNIT_AURA", Update) end
end

local function Disable(self)
	self:UnregisterEvent("UNIT_AURA")
end

oUF:AddElement("BuffIndicator", Update, Enable, Disable)
