local ScrW, ScrH = ScrW, ScrH
local Create = vgui.Create
local MousePos = gui.MousePos



--	--	--	--	--	--	--	--	--	--	--
--	Is the screen point over this panel?
local function _isPointOver(self, x, y)
	local l, t = self:LocalToScreen(0, 0)
	local r, b = self:LocalToScreen(self:GetSize())

	return l <= x and t <= y and r >= x and b >= y
end



local function highlightPanel(pnl, status, msg)
	if status then
		if not pnl.OLDPAINTOVER then
			pnl.OLDPAINTOVER = pnl.PaintOver or function() end

			pnl.PaintOver = function(pnl, w, h)
				pnl:OLDPAINTOVER(w, h)

				surface.SetDrawColor(255,0,0,128)
				surface.DrawRect(0,0,w,h)
			end

			if msg then
				MsgN(msg)
			end
		end
	else
		if pnl.OLDPAINTOVER then
			pnl.PaintOver = pnl.OLDPAINTOVER
			pnl.OLDPAINTOVER = nil

			if msg then
				MsgN(msg)
			end
		end
	end
end



--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--
--	Stops mouse input over the tab scroller when the mouse is NOT directly over a tab.
--	AKA allows to drag the window throught the property list.
local function ThinkMovement(self)
	local mx, my = MousePos()
	local lx, ly = self:ScreenToLocal(mx, my)
	local w, h = self:GetSize()
	local mi = true

	if (ly < 25 or ly >= h - 5 or lx <= 5 or lx >= w - 5) and _isPointOver(self.tabs, mx, my) then
		mi = false

		local _list_0 = self.tabs.tabScroller:GetChildren()

		for _index_0 = 1, #_list_0 do
			local child = _list_0[_index_0]

			if _isPointOver(child, mx, my) then
				mi = true

				break
			end
		end
	end

	if mi ~= self.oldmi then
		self.tabs:SetMouseInputEnabled(mi)

		self.oldmi = mi
	end
end



local PANEL = { }



function PANEL:Init()
	--self:SetSkin("vAdmin skin")
	--	Good looks. 

	local oldSV = self.SetVisible

	self.SetVisible = function(this, b)
		oldSV(this, b)

		if b then
			this:OnVisible()
		end
	end

	self:SetTitle("Relay Console")

	self:SetSizable(true)
	self:SetDeleteOnClose(false)
	self:SetMinWidth(300)
	self:SetMinHeight(300)

	local tabs_left_offset = 32

	if self.SetTitleVisible then
		self:SetTitleVisible(false)

		self:SetIcon("icon16/application_xp_terminal.png")
	else
		self.lblTitle:SetVisible(false)

		tabs_left_offset = 6
	end

	self:DockPadding(5, 5, 5, 5)

	local tabs = self:Add("DPropertySheet")

	--[[local tabsPL = tabs.PerformLayout
	function tabs.PerformLayout(tabs, w, h)
		tabsPL(tabs, w, h)

		tabs.tabScroller:StretchToParent(32 - 5, 0, 31 * 3 + 4 - 5, nil)
	end--]]

	tabs.tabScroller:Dock(TOP)
	tabs.tabScroller:DockMargin(tabs_left_offset - 5 + 4, 0, 31 * 3 + 4, 0)

	self.tabs = tabs

	if self:GetSkin() and self:GetSkin().Name == "vAdmin skin" then
		tabs:DockMargin(-4, -1, -4, -4)
	else
		tabs:DockMargin(-5, -1, -5, -5)
	end

	tabs:Dock(FILL)

	self.RCon = Create("RelC_RCon_Panel", self)
	tabs:AddSheet("RCon", self.RCon, "icon16/server.png")

	self.ErrSv = Create("RelC_Server_Errors_Panel", self)
	tabs:AddSheet("Server Errors", self.ErrSv, "icon16/error.png")

	self:SetSize(ScrW() * 0.6, ScrH() * 0.7)
	--self:SetPos(ScrW() * 0.4 - 50, 50)
	self:SetPos(50, 50)

	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(true)

	self.oldmi = true

	self.OldThink = self.Think

	function self:Think()
		ThinkMovement(self)

		self:OldThink()
	end
end

function PANEL:OnVisible()
	self:MakePopup()

	--self.RCon:OnVisible()
end

function PANEL:OnClose()
	--	Should save position and size and active tab?
end



if vFrame then
	vgui.Register("RelC_Console_Window", PANEL, "vFrame")
else
	vgui.Register("RelC_Console_Window", PANEL, "DFrame")
end



local gui_IsGameUIVisible, gui_IsConsoleVisible = gui.IsGameUIVisible, gui.IsConsoleVisible
local isVisible = gui_IsConsoleVisible

local menuOn, con = nil, nil



local hook_relayConsoleTryCanShow = RelC.Hooks.Call.TryCanShow



local function _create()
	con = Create("RelC_Console_Window")
	_G.RelayConsole_Window = con
end

local function _check()
	local isVis = isVisible()

	if isVis ~= menuOn then
		menuOn = isVis

		if not IsValid(con) then
			return
		end

		if isVis then
			con:Show()
			con:MakePopup()
		else
			con:Close()
		end
	end
end



if IsValid(_G.RelayConsole_Window) then
	_G.RelayConsole_Window:Remove()
	--_create()
	hook_relayConsoleTryCanShow()
end



timer.Simple(0, function()
	if not IsValid(_G.RelayConsole_Window) then
		--_create()
		hook_relayConsoleTryCanShow()
	end
end)



RelC.Hooks.Add("GamemodeThink", "Window Checks", _check, true)



RelC.Hooks.Add("ShowConsole", "Console Display", function()
	if IsValid(con or _G.RelayConsole_Window) then
		return
	end

	con = Create("RelC_Console_Window")
	_G.RelayConsole_Window = con
	menuOn = not isVisible()

	_check()
end, true)


RelC.Hooks.Add("HideConsole", "Console Removal", function()
	local win = (con or _G.RelayConsole_Window)

	if win then
		win:Remove()
	end
end, true)
