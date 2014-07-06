local hook_relayConsoleRConTransmit = RelC.Hooks.Call.RConTransmit



local PANEL = {
	Buttons = {
		{ Image = "icon16/map.png", Tooltip = "Restart by changelevel to current map.", Command = function() return "changelevel " .. game.GetMap() end },
		{ Image = "icon16/arrow_refresh.png", Tooltip = "Full engine restart.", OnClick = function()
			hook_relayConsoleRConTransmit("changelevel " .. game.GetMap())

			timer.Simple(1, function()
				RunConsoleCommand("retry")
			end)
		end},
	}
}



function PANEL:Init()
	local w = 0

	for i = 1, #self.Buttons do
		local btn, pnl = self.Buttons[i]

		if btn.Image then
			pnl = vgui.Create("DImageButton", self)
			pnl:SetSize(16, 16)

			pnl:SetImage(btn.Image)
			pnl:SetStretchToFit(true)
		elseif btn.Text then
			pnl = vgui.Create("DButton", self)

			pnl:SetText(btn.Text)
			pnl:SizeToContents()
			pnl:SetWide(pnl:GetWide() + 8)
		end

		if IsValid(pnl) then
			if i > 1 then
				pnl:DockMargin(0, 0, 4, 0)

				w = w + 4
			end

			pnl:Dock(RIGHT)

			w = w + pnl:GetWide()

			if type(btn.Tooltip) == "string" then
				pnl:SetToolTip(btn.Tooltip)
			end

			if btn.Command then
				if type(btn.Command) == "function" then
					pnl.DoClick = function(pnl)
						hook_relayConsoleRConTransmit(btn.Command())
					end
				elseif type(btn.Command) == "string" then
					pnl.DoClick = function(pnl)
						hook_relayConsoleRConTransmit(btn.Command)
					end
				end
			elseif type(btn.OnClick) == "function" then
				pnl.DoClick = btn.OnClick
			end
		end
	end

	self:SetWide(w)
end



vgui.Register("RelC_Console_Window_Buttons", PANEL, "Panel")
