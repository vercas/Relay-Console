--Returns a function(plys) that adds every player with the ucl permission
--passed in permission, or with the relayc-all permission to the plys table
local function getAccessHandler(permission)
	return function(plys)
		for k, ply in pairs(player.GetAll()) do
			if ULib.ucl.query(ply, permission) then
				table.insert(plys,ply)
			end
		end
	end
end 

--Set up permissions
if SERVER then
	ULib.ucl.registerAccess("relayc show", ULib.ACCESS_ADMIN, "Ability to see the Relay Console", "Relay Console" )
	ULib.ucl.registerAccess("relayc spew", ULib.ACCESS_ADMIN, "Ability to see the Engine Spew", "Relay Console" )
	ULib.ucl.registerAccess("relayc rcon", ULib.ACCESS_SUPERADMIN, "Ability to use RCON", "Relay Console" )
	ULib.ucl.registerAccess("relayc luasv", ULib.ACCESS_SUPERADMIN, "Ability to run serverside lua", "Relay Console" )
	ULib.ucl.registerAccess("relayc sverrors", ULib.ACCESS_ADMIN, "Ability to see serverside lua errors", "Relay Console" )
	ULib.ucl.registerAccess("relayc clerrors", ULib.ACCESS_ADMIN, "Ability to see other client's errors", "Relay Console" )
end

RelC.Hooks.Add("GetShowPlayers", "Ulx Access", getAccessHandler("relayc show"), true)

RelC.Hooks.Add("GetSpewPlayers", "Ulx Access", getAccessHandler("relayc spew"), true)
RelC.Hooks.Add("GetRConPlayers", "Ulx Access", getAccessHandler("relayc rcon"), true)
RelC.Hooks.Add("GetLuaSVPlayers", "Ulx Access", getAccessHandler("relayc luasv"), true)
RelC.Hooks.Add("GetServerErrorPlayers", "Ulx Access", getAccessHandler("relayc sverrors"), true)
RelC.Hooks.Add("GetClientErrorPlayers", "Ulx Access", getAccessHandler("relayc clerrors"), true)
