local _, rui = ...
local B, L, C = unpack(rui)

-- Chat msg sound
local function ChatSound()
	PlaySound(SOUNDKIT.TELL_MESSAGE)
end

B:AddEventScript("CHAT_MSG_BN_WHISPER", ChatSound)

-- scroll
local function FastScroll(self,direct)
	if direct > 0 then -- up
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			self:ScrollByAmount(2)
		end
	else
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			self:ScrollByAmount(-2)
		end
	end
end
hooksecurefunc("FloatingChatFrame_OnMouseScroll", FastScroll)

-- chat copy
local function CopyChat()
	local frame, t, idx = _G.SELECTED_DOCK_FRAME, {}, 1
	for i = 1, frame:GetNumMessages() do
		local msg, r, g, b = frame:GetMessageInfo(i)
		if not msg:find("|K") then -- not need to copy protected string
			r, g, b = r or 1, g or 1, b or 1
			t[idx] = format("|cff%02x%02x%02x%s|r",r*255,g*255,b*255,msg)
			idx = idx + 1
		end
	end
	return table.concat(t, "\n")
end

local copy = CreateFrame("Button", nil, UIParent)
copy:SetPoint("LEFT", ChatFrameChannelButton, "RIGHT")
copy:SetSize(12,12)
local texture = copy:CreateTexture(nil, "ARTWORK")
texture:SetAllPoints()
texture:SetTexture("Interface/Buttons/UI-GuildButton-PublicNote-Up")
texture:SetAlpha(0.5)
local scroll = CreateFrame("ScrollFrame", "RUIChatHistoryScroll", UIParent, "UIPanelScrollFrameTemplate")
scroll:SetSize(380,200)
scroll:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",50,50)
scroll:Hide()
local texture2 = scroll:CreateTexture(nil, "BACKGROUND")
texture2:SetSize(400,200)
texture2:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",50,50)
texture2:SetColorTexture(0.1,0.1,0.1,0.8)
local editbox = CreateFrame("EditBox", nil, scroll)
editbox:SetMultiLine(true)
editbox:SetMaxLetters(99999)
editbox:EnableMouse(true)
editbox:SetAutoFocus(false)
editbox:SetWidth(380)
editbox:SetFont(ChatFrame1:GetFont(), 12)
scroll:SetScrollChild(editbox)

editbox:SetScript("OnEscapePressed", function() scroll:Hide() end)
copy:SetScript("OnClick", function()
	if scroll:IsShown() then
		scroll:Hide()
	else
		editbox:SetText(CopyChat())
		scroll:Show()
	end
end)

local function ResizeChat1()
	ChatFrame1:SetUserPlaced(true)
	ChatFrame1:SetSize(C.db.chat.frame1Width, C.db.chat.frame1Height)
	ChatFrame1Background:SetAllPoints(ChatFrame1)
end

B:AddInitScript(function()
	ResizeChat1()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		frame.ScrollBar:Hide()
		frame.ScrollBar:UnregisterAllEvents()
		frame.ScrollBar:SetParent(B.hider)
		frame.ScrollBar.Show = frame.ScrollBar.Hide
		frame.ScrollToBottomButton:Hide()
		frame.ScrollToBottomButton:UnregisterAllEvents()
		frame.ScrollToBottomButton.Show = frame.ScrollToBottomButton.Hide
		frame.buttonFrame:Hide()
		frame.buttonFrame:UnregisterAllEvents()
		frame.buttonFrame.Show = frame.ScrollToBottomButton.Hide
		frame:SetClampedToScreen(false)
		local editbox =  _G["ChatFrame"..i.."EditBox"]
		editbox:SetAltArrowKeyMode(false)
	end
	QuickJoinToastButton:Hide()
	QuickJoinToastButton:UnregisterAllEvents()
	ChatFrameMenuButton:Hide()
	ChatFrameMenuButton:UnregisterAllEvents()
	ChatFrameChannelButton:RegisterForClicks("AnyUp")
	ChatFrameChannelButton:SetScript("OnClick", function(self, button)
		if button == "LeftButton" then
			ToggleChannelFrame()
		else
			PlaySound(SOUNDKIT.IG_CHAT_EMOTE_BUTTON);
			ChatFrame_ToggleMenu();
		end
	end)
	ChatFrameChannelButton:SetScript("OnEnter", nil)
	ChatFrameChannelButton:SetScript("OnLeave", nil)
	ChatFrameChannelButton:ClearAllPoints()
	ChatFrameChannelButton:SetPoint("BOTTOMLEFT", GeneralDockManager, "TOPLEFT")
	ChatFrameChannelButton:SetAlpha(0.6)
	ChatFrameChannelButton:SetSize(12,12)
	--BNToastFrame:ClearAllPoints()
	--B:SetupMover(BNToastFrame, "BNToastFrame",L["BNToastFrame"],true)
end)
