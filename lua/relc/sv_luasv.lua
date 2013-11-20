local string_sub, string_find, unpack = string.sub, string.find, unpack



--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--
--	Parses Lua sort of like the Lua command line interpreter would.
local function runCommand(cmd)
	local a, b = string_find(cmd, "%s*=%s*")

	if a and b then
		cmd = "print(" .. string_sub(cmd, b + 1) .. ")"
	end

	(CompileString or loadstring)(cmd, "Relay Console LuaSV chunk")()
end



local hook_relayConsoleGetLuaSVPlayers = RelC.Hooks.Call.GetLuaSVPlayers

RelC.Hooks.Add("LuaSVReceived", "Execution", function(ply, cmd)
	local plys = {}

	hook_relayConsoleGetLuaSVPlayers(plys)

	for i = 1, #plys do
		if plys[i] == ply then
			runCommand(cmd)

			break
		end
	end
end, true)
