local string_sub, string_find = string.sub, string.find

local net = net



local msg_data = "Relay Console Data Transmission"
local msg_command = "Relay Console Command Transmission"

local TYPE_SPEW = 1
local TYPE_ERRORSV = 2

local TYPE_RCON = 1
local TYPE_LUASV = 2
local TYPE_LUACL = 3	--	Unused yet. Would have to be checked serverside. :(



if SERVER then
	util.AddNetworkString(msg_data)
	util.AddNetworkString(msg_command)

	local function sendData(plys, type, data)
		net.Start(msg_data)
		net.WriteInt(type, 32)
		net.WriteTable(data)
		net.Send(plys)

		--[[if type ~= TYPE_SPEW then
			MsgN("Sending data of type ", type, ":")
			PrintTable(data, 1)
		end--]]
	end

	local hook_relayConsoleRConReceived = RelC.Hooks.Call.RConReceived
	local hook_relayConsoleLuaSVReceived = RelC.Hooks.Call.LuaSVReceived

	net.Receive(msg_command, function(len, ply)
		local type = net.ReadInt(32)
		local data = net.ReadTable()

		--MsgN("Received command of type ", type)

		if type == TYPE_RCON then
			hook_relayConsoleRConReceived(ply, data[1])
		elseif type == TYPE_LUASV then
			hook_relayConsoleLuaSVReceived(ply, data[1])
		end
	end)



	RelC.Hooks.Add("SpewTransmit", "Network Transmission", function(plys, data)
		if #plys > 0 then
			sendData(plys, TYPE_SPEW, data)
		end
	end, true)



	local errorLookup, nextID = {}, {}

	RelC.Hooks.Add("ServerErrorsTransmit", "Network Transmission", function(plys, errs)
		for p = 1, #plys do
			local ply = plys[p]

			if not errorLookup[ply] then
				errorLookup[ply] = {}
				nextID[ply] = 0
			end

			local myLookup, newErrs = errorLookup[ply], {}

			for i = 1, #errs do
				local err = errs[i]
				local digest = RelC.Utils.DigestTable(err)
				digest = RelC.Singularity.vON.Serialize(digest)

				if myLookup[digest] then
					newErrs[i] = {myLookup[digest]}
				else
					newErrs[i] = {nextID[ply], err}

					myLookup[digest] = nextID[ply]
					nextID[ply] = nextID[ply] + 1
				end
			end

			sendData(ply, TYPE_ERRORSV, newErrs)

			--MsgC(Color(255, 255, 0), "Sending error table to ", tostring(ply), ":\n")
			--PrintTable(newErrs)
		end
	end, true)

	RelC.Hooks.Add("PlayerLeft", "Clean up Error Lookup", function(ply, sid64, sid)
		errorLookup[ply] = nil
		nextID[ply] = nil
	end)
else
	local function sendCommand(type, data)
		net.Start(msg_command)
		net.WriteInt(type, 32)
		net.WriteTable(data)
		net.SendToServer()

		--MsgN("Transmitted command of type ", type)
	end

	local hook_relayConsoleSpewReceived = RelC.Hooks.Call.SpewReceived
	local hook_relayConsoleServerErrorReceived = RelC.Hooks.Call.ServerErrorReceived

	local errorLookup = {}

	net.Receive(msg_data, function(len)
		local type = net.ReadInt(32)
		local data = net.ReadTable()

		if type == TYPE_SPEW then
			hook_relayConsoleSpewReceived(data)
		elseif type == TYPE_ERRORSV then
			for i = 1, #data do
				if data[i][2] then
					errorLookup[data[i][1]] = data[i][2]
					--data[i] = data[i][2]
				else
					data[i][2] = errorLookup[data[i][1]]
					--data[i] = errorLookup[data[i][1]]
				end
			end

			hook_relayConsoleServerErrorReceived(data)
		end
	end)



	RelC.Hooks.Add("RConTransmit", "Network Transmission", function(cmd)
		local a, b = string_find(cmd, '%s+')

		if a == 1 and b ~= 0 then
			--Msg("Cutting ", string.format("%q", cmd), " at ", a, ", ", b, ": ")

			cmd = string_sub(cmd, b + 1)

			--MsgN(string.format("%q", cmd))
		end

		--	Removed trailing whitespaces.

		sendCommand(TYPE_RCON, { cmd })
	end, true)

	RelC.Hooks.Add("LuaSVTransmit", "Network Transmission", function(cmd)
		sendCommand(TYPE_LUASV, { cmd })
	end, true)
end
