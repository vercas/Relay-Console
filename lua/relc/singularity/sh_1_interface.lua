local hook_gamemodeThink = RelC.Hooks.Call.GamemodeThink
local hook_playerJoined = RelC.Hooks.Call.PlayerJoined
local hook_playerLeft = RelC.Hooks.Call.PlayerLeft
local hook_entityRemoved = RelC.Hooks.Call.EntityRemoved



hook.Add("Think", "Relay Console", function()
	hook_gamemodeThink()
end)

hook.Add("PlayerAuthed", "Relay Console", function(ply, steamID, uniqueID)
	hook_playerJoined(ply, ply:SteamID64(), ply:SteamID())
end)

hook.Add("EntityRemoved", "Relay Console", function(ent)
	--	hook_entityRemoved(ent)
	--	Yet unused.

	if ent:IsPlayer() then
		hook_playerLeft(ent, ent:SteamID64(), ent:SteamID())
	end
end)
