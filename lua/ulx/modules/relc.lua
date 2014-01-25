local function spawn()
	if not RelC then return end	--	No Relay Console, no permissions for it.

	local GetAll = player.GetAll
	local query = ULib.ucl.query



	local function getAccessHandler(permission)
		return function(plys)
			local all = GetAll()

			for i = 1, #all do
				if query(all[i], permission) then
					plys[#plys+1] = all[i]
				end
			end
		end
	end 



	ULib.ucl.registerAccess("relayc show",     ULib.ACCESS_ADMIN,      "Ability to see the Relay Console window.",               "Relay Console")
	ULib.ucl.registerAccess("relayc spew",     ULib.ACCESS_ADMIN,      "Ability to see the engine spew in Relay Console.",       "Relay Console")
	ULib.ucl.registerAccess("relayc rcon",     ULib.ACCESS_SUPERADMIN, "Ability to run RCon commands in Relay Console.",         "Relay Console")
	ULib.ucl.registerAccess("relayc luasv",    ULib.ACCESS_SUPERADMIN, "Ability to run serverside Lua code in Relay Console.",   "Relay Console")
	ULib.ucl.registerAccess("relayc sverrors", ULib.ACCESS_ADMIN,      "Ability to see serverside Lua errors in Relay Console.", "Relay Console")
	ULib.ucl.registerAccess("relayc clerrors", ULib.ACCESS_ADMIN,      "Ability to see other clients' errors in Relay Console.", "Relay Console")

	RelC.Hooks.Add("GetShowPlayers",        "ULX Bridge", getAccessHandler("relayc show"))

	RelC.Hooks.Add("GetSpewPlayers",        "ULX Bridge", getAccessHandler("relayc spew"))
	RelC.Hooks.Add("GetRConPlayers",        "ULX Bridge", getAccessHandler("relayc rcon"))
	RelC.Hooks.Add("GetLuaSVPlayers",       "ULX Bridge", getAccessHandler("relayc luasv"))
	RelC.Hooks.Add("GetServerErrorPlayers", "ULX Bridge", getAccessHandler("relayc sverrors"))
	RelC.Hooks.Add("GetClientErrorPlayers", "ULX Bridge", getAccessHandler("relayc clerrors"))
end



if RelC then
	spawn()
else
	timer.Simple(0, spawn)
end

--	ULX might load before Relay Console.
