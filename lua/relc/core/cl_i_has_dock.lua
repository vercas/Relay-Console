local surface_SetFont, surface_GetTextSize, surface_SetDrawColor, surface_DrawRect = surface.SetFont, surface.GetTextSize, surface.SetDrawColor, surface.DrawRect



local PANEL = { }



function PANEL:Init()
	self.dock = self:Add("Panel")
	self.dock:DockMargin(0, 0, 0, 8 - 1)
	self.dock:Dock(TOP)



	self.dock:SetTall(22)
	--	Standard size for DButton.
end



function PANEL:AddButton(img, txt, onClick)
	local btn = self.dock:Add("DButton")
	btn:DockMargin(0, 0, 8 - 1, 0)
	btn:Dock(LEFT)

	btn:SetImage(img)
	btn:SetText(txt)
	btn:SizeToContents()
	btn:InvalidateLayout(true)

	if img then
		--btn:SetContentAlignment(4)

		btn._ComputeSize = function(btn)
			surface_SetFont(btn:GetFont())
			local tw, th = surface_GetTextSize(btn:GetText())

			--btn:SetTextInset(4 + btn.m_Image:GetWide() + 4, 0)
			btn:SetSize(     6 + btn.m_Image:GetWide() + 6 + tw + 6, 22)
			btn:SetTextInset(6, 0)
		end
	else
		btn._ComputeSize = function(btn)
			surface_SetFont(btn:GetFont())
			local tw, th = surface_GetTextSize(btn:GetText())

			btn:SetSize(6 + tw + 6, 22)
		end
	end

	btn.DoClick = onClick

	btn:_ComputeSize()

	return btn
end



function PANEL:AddSeparator()
	local pnl = self.dock:Add("Panel")
	pnl:SetWide(1)
	pnl:DockMargin(0, 0, 8 - 1, 0)
	pnl:Dock(LEFT)

	function pnl.Paint(pnl, w, h)
		surface_SetDrawColor(0, 0, 0, 192)
		surface_DrawRect(0, 0, w, h)
	end

	return pnl
end



vgui.Register("RelC_I_HAS_DOCK", PANEL, "Panel")
