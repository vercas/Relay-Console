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
	self.contents = self:Add("DPanel")
	self.contents:Dock(FILL)

	self.output = self.contents:Add("RichText")
	self.output:DockMargin(1, 1, 1, 1)
	self.output:Dock(FILL)



	if self:GetSkin() and self:GetSkin().Name == "vAdmin skin" then
		--
	else
		self.contents:SetBackgroundColor(Color(81, 83, 86))
	end



	RelC.Hooks.Add("ServerErrorReceived", "Server Lua Error Display", function(data)
		if IsValid(self) and IsValid(self.output) then
			for i = 1, #data do
				local d = data[i]

				self.output:AppendText(d[2][1])
				self.output:AppendText('\n')
			end

			self.output:GotoTextEnd()
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

vgui.Register("RelC_Error_List", PANEL, "Panel")
