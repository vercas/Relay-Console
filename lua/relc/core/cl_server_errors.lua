local PANEL = {}



function PANEL:Init()
	self.errs = self:Add("RelC_Error_List")
	self.errs:Dock(FILL)



	RelC.Hooks.Add("ServerErrorReceived", "Server Lua Error Display", function(data)
		if IsValid(self) and IsValid(self.errs) then
			if self.on then
				self:AddData(data)
			else
				local cnt = #self.queue
				
				for i = 1, #data do
					self.queue[cnt + i] = data[i]
				end
			end
		end
	end, true)
end



function PANEL:PauseChanged()
	if self.on and #self.queue > 0 then
		self:AddData(self.queue)
		self.queue = {}
	end
end



function PANEL:Clear()
	self.errs:Clear()
end

function PANEL:AddData(data)
	for i = 1, #data do
		self.errs:LuaError("server", data[i][2][1], data[i][2][2])
	end
end



vgui.Register("RelC_Server_Errors_Panel", PANEL, "RelC_Panel_Base")
