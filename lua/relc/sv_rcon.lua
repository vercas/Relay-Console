local string_sub, string_find, unpack = string.sub, string.find, unpack



--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--
--	Parses a command into chunks that the retarded RunConsoleCommand function can use without turning a fan towards you and having an atomic crap in it.
--	Identical to the algorithm used by the actual console. AFAIK...
local function runCommand(cmd)
	local pieces = {}

	while #cmd > 0 do
		local a, b = string_find(cmd, '%s+')
		local c, d = string_find(cmd, '"', 1, true)

		local quotes = false

		if b and c and c == d and c < b then
			quotes = true
		end

		if quotes then
			local e, f = string_find(cmd, '"', d + 1, true)

			if e and f then
				pieces[#pieces + 1] = string_sub(cmd, d + 1, e - 1)
				cmd = string_sub(cmd, f + 1)
			else
				quotes = false
			end
		end

		if not quotes then
			if a and b then
				pieces[#pieces + 1] = string_sub(cmd, 1, a - 1)
				cmd = string_sub(cmd, b + 1)
			else
				break
			end--]]
		end
	end

	if #cmd > 0 then
		pieces[#pieces + 1] = cmd
	end

	--[[MsgC(Color(255, 0, 0), "Pieces are:\n")
	PrintTable(pieces, 1)
	MsgN()--]]

	RunConsoleCommand(unpack(pieces))
end

--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--
--	Splits a command string into multiple commands just like the normal console does.
local function runMultipleCommands(cmd)
	local cmds = {}

	local a, b, c = 0, 0, 0
	while a <= #cmd do
		b = a
		a, c = string_find(cmd, ";%s*", b + 1)

		if a then
			cmds[#cmds + 1] = string_sub(cmd, b + 1, a - 1)
			a = c
		else
			a = b
			break
		end
	end

	if a < #cmd then
		cmds[#cmds + 1] = string_sub(cmd, a + 1)
	end

	--[[MsgC(Color(255, 0, 0), "Commands are:\n")
	PrintTable(cmds, 1)
	MsgN()--]]

	for i = 1, #cmds do
		runCommand(cmds[i])
	end
end



local hook_relayConsoleGetRConPlayers = RelC.Hooks.Call.GetRConPlayers

RelC.Hooks.Add("RConReceived", "Execution", function(ply, cmd)
	local plys = {}

	hook_relayConsoleGetRConPlayers(plys)

	for i = 1, #plys do
		if plys[i] == ply then
			runMultipleCommands(cmd)

			break
		end
	end
end, true)
