local _, rui = ...
local B, L, C = unpack(rui)

local function TimeText(seconds)
	if seconds > 86400 then
		return "%dd", ceil(seconds/86400)
	elseif seconds > 3600 then
		return "%dh", ceil(seconds/3600)
	elseif seconds > 600 then
		return "%dm", seconds/60
	elseif seconds > 60 then
		return "%d:%02d", seconds/60, seconds%60
	elseif seconds > 5 then
		return "%d", floor(seconds)
	else
		return "|cffff0000%.1f|r", seconds
	end
end

function EndCD(self)
	self:Hide()
	self.elapsed = 0
	self.endTime = nil
	self.duration = nil
end

local function OnUpdate(self,elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > self.rate then
		local cur = GetTime()
		if self.endTime and cur > self.endTime then
			EndCD(self)
		elseif self.endTime then
			if self.duration > 1.5 then
				self.text:SetFormattedText(TimeText(self.endTime - cur))
			else
				self.text:SetText()
			end
		end
		self.elapsed = 0
		if self.rate > 0.1 and self.endTime - cur < 6 then self.rate = 0.1 end
	end
end

local function CreateCooldown(self, fontSize)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints()
	self.ruicd = frame
	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER")
	text:SetFont(STANDARD_TEXT_FONT, fontSize, "OUTLINE")
	text:SetJustifyH("CENTER")
	frame.text = text
	frame:SetScript("OnUpdate", OnUpdate)
end

local function SetCooldown(self, start, duration)
	if start and duration then
		local timer = self.ruicd
		timer.endTime = start + duration
		timer.duration = duration
		local elapsed = timer.endTime - GetTime()
		timer.rate = elapsed > 10 and 1 or 0.1
		timer:Show()
		OnUpdate(timer,100)
	else
		EndCD(timer)
	end
end

function B:SetupCooldown(cooldown, fontSize)
	if not cooldown.ruicd then
		CreateCooldown(cooldown, fontSize)
		hooksecurefunc(cooldown, "SetCooldown", SetCooldown)
		cooldown:SetHideCountdownNumbers(true)
	end
end
