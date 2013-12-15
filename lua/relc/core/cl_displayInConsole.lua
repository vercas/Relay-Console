if true then return end
--	To do: Make this some sort of setting.



local MsgC = MsgC



local srvCol = Color(143, 218, 230, 255)

RelC.Hooks.Add("SpewReceived", "Server console to Client console", function(data)
	for i = 1, #data do
		if type(data[i]) == "string" then
			MsgC(srvCol, data[i])
		end
	end
end, true)
