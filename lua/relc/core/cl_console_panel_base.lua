local PANEL = {}



function PANEL:Init()
	self.on, self.queue = true, {}



	if self.Clear then
		self:AddButton(nil --[["icon16/cross.png"]], "Clear", function(btn)
			self:Clear()
		end)

		self:AddSeparator()
	end



	self.btn_PR = self:AddButton(nil, "Resume updating", function(btn)
		self.on = not self.on
		
		btn:SetText(self.on and "Pause updating" or "Resume updating")

		if self.PauseChanged then
			self:PauseChanged()
		end
	end)

	self.btn_PR:SetText("Pause updating")



	self.countlbl = self.dock:Add("DLabel")
	self.countlbl:DockMargin(0, 0, 8 - 1, 0)
	self.countlbl:Dock(LEFT)

	self.countlbl:SetText("Queued items: ----")
	self.countlbl:SizeToContents()

	self.countlbl:SetTextColor(Color(240, 240, 240, 255))

	local oldCount = -1

	function self.countlbl.Think(lbl)
		local cnt = #self.queue

		if cnt ~= oldCount then
			oldCount = cnt

			lbl:SetText("Queued items: " .. tostring(cnt))
		end
	end
end



vgui.Register("RelC_Panel_Base", PANEL, "RelC_I_HAS_DOCK")
