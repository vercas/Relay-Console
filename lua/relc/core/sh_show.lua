local string_sub, string_find = string.sub, string.find

local net, util = net, util



local msg_show = "Relay Console Show"



if SERVER then
	local hook_relayConsoleGetShowPlayers = RelC.Hooks.Call.GetShowPlayers

	local function getPlayers()
		local plys = {}

		hook_relayConsoleGetShowPlayers(plys)

		for i = 1, #plys do
			plys[plys[i]] = true
		end

		return plys
	end



	util.AddNetworkString(msg_show)

	net.Receive(msg_show, function(len, ply)
		net.Start(msg_show)
		net.WriteInt(getPlayers()[ply] and -1 or 0, 32)
		net.Send(ply)
	end)



	local lastCheck, lastplys = 0, {}

	RelC.Hooks.Add("GamemodeThink", "Periodic Show Check", function()
		local now = CurTime()

		if (now - lastCheck) > 30 then
			--MsgC(Color(255, 255, 0), "Checking who should see the console!\n")

			local plys = getPlayers()
			local toShow, toHide = {}, {}

			for i = 1, #plys do
				if not lastplys[plys[i]] then
					toShow[#toShow+1] = plys[i]

					--MsgC(Color(0, 0, 255), "Will show for: ", tostring(plys[i]), "\n")
				end
			end

			for i = 1, #lastplys do
				if not plys[lastplys[i]] then
					toHide[#toHide+1] = lastplys[i]

					--MsgC(Color(255, 0, 0), "Will hide for: ", tostring(lastplys[i]), "\n")
				end
			end

			net.Start(msg_show)
			net.WriteInt(-1, 32)
			net.Send(toShow)

			net.Start(msg_show)
			net.WriteInt(0, 32)
			net.Send(toHide)

			lastplys = plys
			lastCheck = now
		end
	end, true)
else
	local hook_relayConsoleShowConsole = RelC.Hooks.Call.ShowConsole
	local hook_relayConsoleHideConsole = RelC.Hooks.Call.HideConsole

	net.Receive(msg_show, function(len)
		--MsgC(Color(255, 255, 0), "Got show response: ")
		
		if net.ReadInt(32) == 0 then
			--MsgC(Color(255, 0, 0), "nope.\n")

			hook_relayConsoleHideConsole()
		else
			--MsgC(Color(0, 0, 255), "YESH.\n")

			hook_relayConsoleShowConsole()
		end
	end)



	RelC.Hooks.Add("TryCanShow", "Console Display", function()
		net.Start(msg_show)
		net.SendToServer()
	end, true)
end
