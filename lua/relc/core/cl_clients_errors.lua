local PANEL = { }



function PANEL:Init()
	self.errs = self:Add("RelC_Error_List")
	self.errs:Dock(FILL)



	--[[RelC.Hooks.Add("ServerErrorReceived", "Server Lua Error Display", function(data)
		if IsValid(self) and IsValid(self.errs) then
			for i = 1, #data do
				--local d = data[i]

				self.errs:LuaError("server", data[i][2][1], data[i][2][2])
			end
		end
	end, true)--]]
end



vgui.Register("RelC_Client_Errors_Panel", PANEL, "Panel")
