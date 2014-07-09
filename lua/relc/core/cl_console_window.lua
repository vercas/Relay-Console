local surface = surface
local Create = vgui.Create
local MousePos = gui.MousePos
local LEFT, RIGHT, TOP, BOTTOM, NODOCK, FILL = LEFT, RIGHT, TOP, BOTTOM, NODOCK, FILL



local min_w, min_h = 300, 300
local minimized_h = 22



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
	self:SetMinWidth(min_w)
	self:SetMinHeight(min_h)

	local tabs_left_offset = 24

	if self.SetTitleVisible then
		self:SetTitleVisible(false)

		self:SetIcon("icon16/application_xp_terminal.png")
	else
		self.lblTitle:SetVisible(false)

		tabs_left_offset = 6
	end

	if self.SetScreenLock then self:SetScreenLock(true) end

	if self.SetMaximizeButtonEnabled then self:SetMaximizeButtonEnabled(true) end
	if self.SetMinimizeButtonEnabled then self:SetMinimizeButtonEnabled(true) end

	self:DockPadding(5, 5, 5, 5)

	local tabs = self:Add("DPropertySheet")

	--[[local tabsPL = tabs.PerformLayout
	function tabs.PerformLayout(tabs, w, h)
		tabsPL(tabs, w, h)

		tabs.tabScroller:StretchToParent(32 - 5, 0, 31 * 3 + 4 - 5, nil)
	end--]]

	tabs.tabScroller:Dock(TOP)

	self.tabs = tabs

	if self:GetSkin() and self:GetSkin().Name == "vAdmin skin" then
		tabs.tabScroller:DockMargin(tabs_left_offset - 5 + 4, 1, (16 + 4) * 3 + 4, 0)
		tabs:DockMargin(-4, -2, -4, -4)
	else
		tabs.tabScroller:DockMargin(tabs_left_offset - 5 + 4, 1, 31 * 3 + 4, 0)
		tabs:DockMargin(-5, -2, -5, -5)
	end

	tabs:Dock(FILL)

	self.RCon = Create("RelC_RCon_Panel", self)
	tabs:AddSheet("RCon", self.RCon, "icon16/server.png")

	self.ErrSv = Create("RelC_Server_Errors_Panel", self)
	tabs:AddSheet("Server Errors", self.ErrSv, "icon16/error.png")

	RelC.Hooks.Call.PopulateTabs(tabs)

	self:SetSize(surface.ScreenWidth() * 0.6, surface.ScreenHeight() * 0.7)
	--self:SetPos(ScrW() * 0.4 - 50, 50)
	self:SetPos(50, 50)

	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(true)

	self.oldmi = true

	self.minimized = false
	self.maximized = false

	--	Preppending to the existing Think function.

	self.OldThink = self.Think

	function self:Think()
		ThinkMovement(self)

		self:OldThink()

		self:OnThink()
	end

	--	Extra buttons.

	local btnStrip = Create("RelC_Console_Window_Buttons", tabs.tabScroller)

	btnStrip:DockMargin(0, 0, 4, 12)
	btnStrip:Dock(RIGHT)
end

function PANEL:OnVisible()
	self:MakePopup()

	--self.RCon:OnVisible()
end

function PANEL:OnClose()
	--	Should save position and size and active tab?
end

function PANEL:Place()
	if self.minimized then
		self.boundsForMinimize = { 0, 0, 0, 0, self.boundsForMaximize and true }
		self.boundsForMinimize[1], self.boundsForMinimize[2] = self:GetPos()
		self.boundsForMinimize[3], self.boundsForMinimize[4] = self:GetSize()
		--	[5] = was maximized before

		self.tabs:SetVisible(false)
		self:SetMinHeight(minimized_h)
		self:SetTall(minimized_h)
		self:SetSizable(false)
		self:SetDraggable(false)
		self:Dock(TOP)

		if self.SetMaximizeButtonEnabled then self:SetMaximizeButtonEnabled(false) end
	elseif self.maximized then
		if not self.boundsForMaximize then
			self.boundsForMaximize = { 0, 0, 0, 0 }
			self.boundsForMaximize[1], self.boundsForMaximize[2] = self:GetPos()
			self.boundsForMaximize[3], self.boundsForMaximize[4] = self:GetSize()
		end

		self.tabs:SetVisible(true)
		self:SetMinHeight(min_h)
		self:SetSizable(false)
		self:SetDraggable(false)
		self:Dock(FILL)

		if self.SetMaximizeButtonEnabled then self:SetMaximizeButtonEnabled(true) end

		self.boundsForMinimize = nil
	else
		self:Dock(NODOCK)
		self:SetDraggable(true)
		self:SetSizable(true)
		self:SetMinHeight(min_h)
		self.tabs:SetVisible(true)

		if self.SetMaximizeButtonEnabled then self:SetMaximizeButtonEnabled(true) end

		if self.boundsForMinimize then
			self:SetPos(self.boundsForMinimize[1], self.boundsForMinimize[2])
			self:SetSize(self.boundsForMinimize[3], self.boundsForMinimize[4])
		elseif self.boundsForMaximize then
			self:SetPos(self.boundsForMaximize[1], self.boundsForMaximize[2])
			self:SetSize(self.boundsForMaximize[3], self.boundsForMaximize[4])
		end

		self.boundsForMaximize = nil
		self.boundsForMinimize = nil
	end

	self:InvalidateLayout(true)
end

function PANEL:OnMaximized()
	self.maximized = not self.maximized

	self:Place()
end

function PANEL:OnMinimized()
	self.minimized = not self.minimized

	self:Place()
end

function PANEL:OnThink()
	if self:GetDock() == FILL then
		local x, y = self:GetPos()
		local w, h = self:GetSize()
		local sw, sh = surface.ScreenWidth(), surface.ScreenHeight()

		if x ~= 0 or y ~= 0 or w ~= sw or h ~= sh then
			self:SetPos(0, 0)
			self:SetSize(sw, sh)

			x, y, w, h = 0, 0, sw, sh
		end
	elseif self:GetDock() == RIGHT then
		local x, y = self:GetPos()
		local w, h = self:GetSize()
		local sw, sh = surface.ScreenWidth(), surface.ScreenHeight()

		if x ~= 0 or y ~= 0 or w ~= sw or h ~= minimized_h then
			self:SetPos(0, 0)
			self:SetSize(sw, minimized_h)

			x, y, w, h = 0, 0, sw, minimized_h
		end
	end
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

			if not con.minimized then
				con:MakePopup()
			end
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
