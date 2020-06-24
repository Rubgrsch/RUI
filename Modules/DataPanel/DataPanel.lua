local _, rui = ...
local B, L, C = unpack(rui)

local DP = {}
B.DP = DP

local panelWidth, panelHeight = 400, 20
local panelBlockWidth = panelWidth/5

local panelList = {}
DP.panelList = panelList

local function OnLeave(self)
	self.isTTShown = false
	GameTooltip:Hide()
end

function DP:CreateData(dataName)
	local frame = CreateFrame("Frame")
	panelList[dataName] = frame
	return frame
end

local function RegisterData(frame)
	frame:SetSize((frame.width or 1)*panelBlockWidth, panelHeight)
	local text = frame:CreateFontString(nil,"ARTWORK")
	text:SetFont(STANDARD_TEXT_FONT,12)
	text:SetPoint("CENTER")
	frame.text = text
	frame.isTTShown = false
	if frame.OnEnter then
		frame:SetScript("OnEnter", frame.OnEnter)
		frame:SetScript("OnLeave", frame.OnLeave or OnLeave)
	end
	if frame.OnMouseUp then frame:SetScript("OnMouseUp", frame.OnMouseUp) end
	if frame.events and frame.OnEvent then
		frame:SetScript("OnEvent", frame.OnEvent)
		for _, event in ipairs(frame.events) do frame:RegisterEvent(event) end
	end
	if frame.OnUpdate then
		if frame.updateInterval then
			B:AddTimer(frame.updateInterval, frame.OnUpdate)
		else -- every frame
			frame.elapsed = 0
			frame:SetScript("OnUpdate", frame.OnUpdate)
		end
	end
end

local panelOrder = {
	left = {"Durability", "Specialization", "Loot", "Gold"},
	right = {"Latency", "FPS", "Guild", "Friends", "Time"},
}

B:AddInitScript(function()
	if C.db.dataPanel.enableLeft then
		local leftPanel = CreateFrame("Frame", "DataPanelLeft", UIParent)
		leftPanel:SetSize(panelWidth,panelHeight)
		B:SetupMover(leftPanel, "DataPanelLeft", L["LeftDataPanel"])
		local leftTexture = leftPanel:CreateTexture(nil, "BACKGROUND")
		leftTexture:SetColorTexture(0, 0, 0, 0.4)
		leftTexture:SetAllPoints(true)
		for idx, name in ipairs(panelOrder.left) do
			local frame = panelList[name]
			RegisterData(frame)
			frame:SetParent(leftPanel)
			if idx == 1 then
				frame:SetPoint("LEFT", leftPanel, "LEFT")
			else
				frame:SetPoint("LEFT", panelList[panelOrder.left[idx-1]], "RIGHT")
			end
		end
	end
	if C.db.dataPanel.enableRight then
		local rightPanel = CreateFrame("Frame", "DataPanelRight", UIParent)
		rightPanel:SetSize(panelWidth,panelHeight)
		B:SetupMover(rightPanel, "DataPanelRight", L["RightDataPanel"])
		local rightTexture = rightPanel:CreateTexture(nil, "BACKGROUND")
		rightTexture:SetColorTexture(0, 0, 0, 0.4)
		rightTexture:SetAllPoints(true)
		for idx, name in ipairs(panelOrder.right) do
			local frame = panelList[name]
			RegisterData(frame)
			frame:SetParent(rightPanel)
			if idx == 1 then
				frame:SetPoint("LEFT", rightPanel, "LEFT")
			else
				frame:SetPoint("LEFT", panelList[panelOrder.right[idx-1]], "RIGHT")
			end
		end
	end
end)
