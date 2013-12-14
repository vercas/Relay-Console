local string_sub, string_find, unpack = string.sub, string.find, unpack



local error_color = Color(255, 100, 0, 255)



--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--
--	Parses Lua sort of like the Lua command line interpreter would.
local function runCommand(cmd)
	local a, b = string_find(cmd, "%s*=%s*")

	if b and a == 1 then
		cmd = "print(" .. string_sub(cmd, b + 1) .. ")"
	end

	local res = (CompileString or loadstring)(cmd, "Relay Console LuaSV chunk", true)

	if type(res) == "function" then
		res()
	elseif res then
		MsgC(error_color, "Error: ", tostring(res), "\n")
	end
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
