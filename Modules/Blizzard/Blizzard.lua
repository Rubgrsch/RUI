local _, rui = ...
local B, L, C = unpack(rui)

B:AddInitScript(function()
	ObjectiveTrackerFrame:SetMovable(true)
	ObjectiveTrackerFrame:SetUserPlaced(true)
	ObjectiveTrackerFrame:SetHeight(300)
	B:SetupMover(ObjectiveTrackerFrame, "ObjectiveTrackerFrame",L["ObjectiveTracker"])

	B:SetupMover(VehicleSeatIndicator, "VehicleSeatIndicator",L["VehicleSeat"])
	hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", C.mover[VehicleSeatIndicator], "TOPLEFT")
		end
	end)
end)
