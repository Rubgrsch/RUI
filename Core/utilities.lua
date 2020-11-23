local _, rui = ...
local B, L, C = unpack(rui)

local next = next

-- Movers
local RUIParent = CreateFrame("Frame", nil, UIParent)
RUIParent:SetAllPoints()
-- B:SetupMover(frame,moverName,localizedName)
-- moverName is for DB saving, localizedName is displayed name in mover mode
C.mover = {}
local function MoverLock(_,button)
	if button == "RightButton" then
		for _,m in pairs(C.mover) do
			m:Hide()
			local point, _, secondaryPoint, x, y = m:GetPoint()
			C[m.isRole and "roleDB" or "db"].mover[m.moverName]={point, secondaryPoint, x, y}
		end
	end
end

function B:SetupMover(frame,moverName,localizedName,isRole,enable)
	local mover = CreateFrame("Frame", "RUIMover"..moverName, RUIParent)
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
	mover.isRole = isRole
	mover.frame = frame
	if enable then mover.enable = enable end
	local texture = mover:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0.8, 0.8, 0.8, 0.5)
	texture:SetAllPoints(true)
	local text = mover:CreateFontString(nil,"ARTWORK","GameFontHighlightLarge")
	text:SetPoint("CENTER", mover, "CENTER")
	text:SetText(localizedName)

	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", mover, "TOPLEFT")
	C.mover[frame] = mover

	if C.db then
		local point, secondaryPoint, x, y = unpack(C[isRole and "roleDB" or "db"].mover[moverName])
		mover:SetPoint(point, RUIParent, secondaryPoint, x, y)
	end
end

function B:ResizeMover(frame,x,y)
	C.mover[frame]:SetSize(x or frame:GetWidth(), y or frame:GetHeight())
end

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

-- Event Script
-- B:AddEventScript(event, func, isSecure) -- func(self,event,...)
-- B:AddInitScript(func)
local frame = CreateFrame("Frame")
local secureFrame = CreateFrame("Frame")
local secureFuncs = {}
frame:SetScript("OnEvent", function(self,event,...)
	for _,func in ipairs(self[event]) do func(self,event,...) end
end)
secureFrame:SetScript("OnEvent", function(self,event,...)
	local notSecure = InCombatLockdown()
	for _,func in ipairs(self[event]) do
		if notSecure then
			B:AddDelayedCombatFunc(func)
		else
			func(self,event,...)
		end
	end
end)

function B:AddEventScript(event, func, secure)
	local f = secure and secureFrame or frame
	if not f[event] then
		f[event] = {}
		f:RegisterEvent(event)
	end
	local t = f[event]
	for _, v in ipairs(t) do if v == func then return end end
	t[#t+1] = func
end

function B:RemoveEventScript(event, func)
	local t = frame[event]
	if not t then return end
	for i, v in ipairs(t) do if v == func then tremove(t,i) end end
	if not next(frame[event]) then
		frame[event] = nil
		frame:UnregisterEvent(event)
	end
end

local timer
local function DelayedFunc()
	if InCombatLockdown() then
		B:ToggleTimer(timer, false)
		return
	end
	for _, f in ipairs(secureFuncs) do
		f()
		secureFuncs[f] = nil
		B:ToggleTimer(timer, false)
	end
end
timer = B:AddTimer(0.5, DelayedFunc, false)

-- Delay some func to be execute after leaving combat
B:AddEventScript("PLAYER_REGEN_ENABLED", function()
	if #secureFuncs > 0 then B:ToggleTimer(timer, true) end
end)

function B:AddDelayedCombatFunc(f)
	secureFuncs[#secureFuncs+1] = f
end

-- Init
local init = {}
function B:AddInitScript(func, secure)
	if secure and InCombatLockdown() then B:AddEventScript("PLAYER_LOGIN", func, true)
	else init[#init+1] = func end
end

B:AddEventScript("PLAYER_LOGIN", function(self)
	for _,v in ipairs(init) do v() end
	self:UnregisterEvent("PLAYER_LOGIN")
	init = nil
end)
