local _, rui = ...
local B, L, C = unpack(rui)

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
end)
