local _, rui = ...
local B, L, C = unpack(rui)

local next = next

-- Movers
-- B:SetupMover(frame,moverName,localizedName)
-- moverName is for DB saving, localizedName is displayed name in mover mode
C.mover = {}
local function MoverLock(_,button)
	if button == "RightButton" then
		for _,m in pairs(C.mover) do
			m:Hide()
			C.db.mover[m.moverName]={"BOTTOMLEFT", m:GetLeft(), m:GetBottom()}
		end
	end
end

function B:SetupMover(frame,moverName,localizedName)
	local mover = CreateFrame("Frame", nil, UIParent)
	mover:Hide()
	mover:SetSize(frame:GetWidth(),frame:GetHeight())
	mover:RegisterForDrag("LeftButton")
	mover:SetScript("OnDragStart", mover.StartMoving)
	mover:SetScript("OnDragStop", mover.StopMovingOrSizing)
	mover:SetScript("OnMouseDown",MoverLock)
	mover:SetMovable(true)
	mover:EnableMouse(true)
	mover:SetFrameStrata("HIGH")
	mover.moverName = moverName
	local texture = mover:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0.8, 0.8, 0.8, 0.5)
	texture:SetAllPoints(true)
	local text = mover:CreateFontString(nil,"ARTWORK","GameFontHighlightLarge")
	text:SetPoint("CENTER", mover, "CENTER")
	text:SetText(localizedName)

	frame:ClearAllPoints()
	frame:SetPoint("CENTER", mover)
	C.mover[frame] = mover

	if C.db then
		mover:SetPoint(unpack(C.db.mover[mover.moverName]))
	end
end

-- Event Script
-- B:AddEventScript(event, func) -- func(self,event,...)
-- B:AddInitScript(func)
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(self,event,...)
	for _,func in ipairs(self[event]) do func(self,event,...) end
end)

function B:AddEventScript(event, func)
	if not frame[event] then
		frame[event] = {}
		frame:RegisterEvent(event)
	end
	local t = frame[event]
	for _, v in ipairs(t) do if v == func then return end end
	t[#t+1] = func
end

function B:RemoveEventScript(event, func)
	local t = frame[event]
	for i, v in ipairs(t) do if v == func then tremove(t,i) end end
	if not next(frame[event]) then
		frame[event] = nil
		frame:UnregisterEvent(event)
	end
end

-- Init
local init = {}
function B:AddInitScript(func)
	init[#init+1] = func
end

B:AddEventScript("PLAYER_LOGIN", function(self)
	for _,v in ipairs(init) do v() end
	self:UnregisterEvent("PLAYER_LOGIN")
	init = nil
end)

-- OnUpdate Timer
-- timerHandler = B:AddTimer(timeInterval, func[, enabled])
-- B:ToggleTimer(timerHandler, status)
local timerFrame = CreateFrame("Frame")
local timerList = {}

timerFrame:Hide()
timerFrame:SetScript("OnUpdate", function(_, elapsed)
	for _, v in next, timerList do
		if v[3] then
			v[4] = v[4] - elapsed
			if v[4] < 0 then
				v[2]()
				v[4] = v[1]
			end
		end
	end
end)

local function CheckTimer()
	local hasEnabled = false
	for _, v in ipairs(timerList) do if v[3] == true then hasEnabled = true end end
	if hasEnabled then timerFrame:Show() else timerFrame:Hide() end
end

function B:AddTimer(time, func, enabled)
	if enabled == nil then enabled = true end
	local curIdx = #timerList+1
	timerList[curIdx] = {
		time,
		func,
		enabled, -- currently enabled
		time, -- elpased
	}
	CheckTimer()
	return curIdx
end

function B:ToggleTimer(timerIdx, status)
	local timer = timerList[timerIdx]
	if status == nil then status = not timer[3] end
	timer[3] = status
	timer[4] = 0
	CheckTimer()
end
