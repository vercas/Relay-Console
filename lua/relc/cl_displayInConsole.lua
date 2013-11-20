if true then return end



RelC.Hooks.Add("RelayConsoleSpewReceived", "Relay Console - Server console to Client console", function(data)
	MsgC(Color(143, 218, 230, 255), data[1])
end, true)
