local string_sub, table_concat = string.sub, table.concat



local errorCollection = RelC.Queue(20)



RelC.Hooks.Add("ServerLuaError", "Capture Server Error", function(err, stack)
	--[[if stack and type(stack) == "table" then
		MsgN("STACK:")
		PrintTable(stack, 1)
		MsgN()
	else
		MsgN("No stack!\n")
	end--]]

	errorCollection:Queue({ err, stack })
end, true)



local hook_relayConsoleGetServerErrorPlayers = RelC.Hooks.Call.GetServerErrorPlayers

local function getPlayers()
	local plys = {}

	hook_relayConsoleGetServerErrorPlayers(plys)

	return plys
end



local thesaurus = { }

local function acquire()
	local ret = { }

	while not errorCollection:IsEmpty() do
		local err = errorCollection:Dequeue()

		ret[#ret+1] = err

		--	Will do something with this error. :V\
		--	I forgot what I had to do.. *facepalms*
	end

	return ret
end



local hook_relayConsoleServerErrorsTransmit = RelC.Hooks.Call.ServerErrorsTransmit

RelC.Hooks.Add("GamemodeThink", "Process and Dispatch Server Errors", function()
	local errs = acquire()

	if #errs > 0 then
		local plys = getPlayers()

		hook_relayConsoleServerErrorsTransmit(plys, errs)
	end
end, true)




