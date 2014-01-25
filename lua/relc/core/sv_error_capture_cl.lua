local errorCollection = RelC.Queue(20)



RelC.Hooks.Add("ClientLuaError", "Capture Client Error", function(ply, err, stack)
	errorCollection:Queue({ ply, err, stack })
end, true)



local hook_relayConsoleGetClientErrorPlayers = RelC.Hooks.Call.GetClientErrorPlayers

local function getPlayers()
	local plys = {}

	hook_relayConsoleGetClientErrorPlayers(plys)

	return plys
end



local function acquire()
	local ret = { }

	while not errorCollection:IsEmpty() do
		local err = errorCollection:Dequeue()

		ret[#ret+1] = err
	end

	return ret
end



local hook_relayConsoleClientErrorsTransmit = RelC.Hooks.Call.ClientErrorsTransmit

RelC.Hooks.Add("GamemodeThink", "Process and Dispatch Client Errors", function()
	local errs = acquire()

	if #errs > 0 then
		local plys = getPlayers()

		hook_relayConsoleClientErrorsTransmit(plys, errs)
	end
end, true)
