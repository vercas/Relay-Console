local ScrW, ScrH = ScrW, ScrH
local type, IsValid = type, IsValid



local hook_relayConsoleRConTransmit = RelC.Hooks.Call.RConTransmit
local hook_relayConsoleLuaSVTransmit = RelC.Hooks.Call.LuaSVTransmit



local TYPE_RCON = 1
local TYPE_LUASV = 2
local TYPE_LUACL = 3	--	Unused yet.



local fontOutput = "RelC_RCon_Output"

surface.CreateFont(fontOutput, {
	font = "Courier New",
	size = 16,
	weight = 400,
	outline = 0,
	antialias = false,
})



local PANEL = { }



function PANEL:Init()
	self.bottom = self:Add("Panel")
	self.bottom:DockMargin(0, 8 - 1, 0, 0)
	self.bottom:Dock(BOTTOM)

	self.input = self.bottom:Add("DTextEntry")
	self.input:Dock(FILL)

	self.send = self.bottom:Add("DButton")
	self.send:DockMargin(8 - 1, 0, 0, 0)
	self.send:Dock(RIGHT)

	self.choice = self.bottom:Add("DComboBox")
	self.choice:DockMargin(0, 0, 8 - 1, 0)
	self.choice:Dock(LEFT)

	self.contents = self:Add("DPanel")
	self.contents:Dock(FILL)

	self.output = self.contents:Add("RichText")
	self.output:DockMargin(1, 1, 1, 1)
	self.output:Dock(FILL)



	function self.choice.OnSelect(choice, index, value, data)
		self.chosenSubmission = data
	end

	self.choice:SetWide(130)

	self.choice:AddChoice("Console command", TYPE_RCON, true)
	self.choice:AddChoice("Lua chunk (serverside)", TYPE_LUASV, false)
	--self.choice:AddChoice("Lua chunk (clientside)", TYPE_LUACL, false)



	self.send:SetText("Submit")
	self.send:SetDisabled(true)
	--self.send:SizeToContents()

	function self.send.DoClick(send)
		local txt = self.input:GetValue()
		self.input:SetCaretPos(0)
		self.input:SetText("")

		self.input:OnChange()

		self.input:AddHistory(txt)

		self.output:InsertColorChange(180, 180, 180, 255)

		if self.chosenSubmission == TYPE_RCON then
			self.output:AppendText("] " .. txt .. "\n")

			hook_relayConsoleRConTransmit(txt)
		elseif self.chosenSubmission == TYPE_LUASV then
			self.output:AppendText("> " .. txt .. "\n")
			
			hook_relayConsoleLuaSVTransmit(txt)
		else
			self.output:AppendText("» Invalid input type: " .. type(self.chosenSubmission) .. " «\n")
		end

		self.output:GotoTextEnd()
	end



	self.input:SetHistoryEnabled(true)

	self.input._OnKeyCodeTyped = self.input.OnKeyCodeTyped
	function self.input.OnKeyCodeTyped(input, code)
		if code == KEY_ENTER then
			input:OnKeyCode(code)

			if (not self.send:GetDisabled()) and self.send.DoClick then
				self.send:DoClick()
			end
		else
			input:_OnKeyCodeTyped(code)
		end
	end

	function self.input.OnChange(input)
		local value = input:GetValue()

		local enabled = value and #value > 0

		self.send:SetDisabled(not enabled)
	end

	--	Dear Garry. Have a cookie, and then try to fix this. :3
	local ufh = self.input.UpdateFromHistory

	function self.input.UpdateFromHistory(input)
		ufh(input)

		input:OnChange()
	end



	if self:GetSkin() and self:GetSkin().Name == "vAdmin skin" then
		--
	else
		self.contents:SetBackgroundColor(Color(81, 83, 86))
	end



	RelC.Hooks.Add("SpewReceived", "RCon Spew Display", function(data)
		if IsValid(self) and IsValid(self.output) then
			if self.on then
				self:AddData(data)

				self.output:GotoTextEnd()
			else
				local cnt = #self.queue
				
				for i = 1, #data do
					self.queue[cnt + i] = data[i]
				end
			end
		end
	end, true)



	function self:PostInit()
		--	BLOODY HELL M8
		self.output:SetFontInternal(fontOutput)
		self.output:SetFGColor(Color(180, 180, 180, 255))
		self.output:InsertColorChange(180, 180, 180, 255)

		--[[function self:PostInit()
			--	FUCKIN' HELL M8
			self.output:SetFontInternal(fontOutput)
		end--]]
	end
end



function PANEL:Think()
	if self.PostInit then
		local func = self.PostInit
		self.PostInit = false

		func(self)
	end
end



function PANEL:PauseChanged()
	self.send:SetDisabled(not self.on)

	if self.on and #self.queue > 0 then
		self:AddData(self.queue)
		self.queue = {}

		self.output:GotoTextEnd()
	end
end



function PANEL:Clear()
	if IsValid(self.output) then
		self.output:SetText("")
	end
end

function PANEL:AddData(data)
	for i = 1, #data do
		local d = data[i]

		if type(d) == "string" then
			self.output:AppendText(d)
		elseif type(d) == "table" then
			if d.url then
				--
			elseif d.r then
				self.output:InsertColorChange(d.r, d.g, d.b, d.a)
			end
		end
	end
end



vgui.Register("RelC_RCon_Panel", PANEL, "RelC_Panel_Base")
