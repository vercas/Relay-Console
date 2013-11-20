local GetAllPlayers = player.GetAll



local function includeSuperadmins(plys)
	local all = GetAllPlayers()

	for i = 1, #all do
		if IsValid(all[i]) and all[i]:IsSuperAdmin() then
			plys[#plys + 1] = all[i]
		end
	end

	--BroadcastChatText("Relayed console stuff to ", #plys, " players our of ", #all, ".")
end

RelC.Hooks.Add("GetSpewPlayers", "Include Super Administrators by Default", includeSuperadmins, true)
RelC.Hooks.Add("GetRConPlayers", "Include Super Administrators by Default", includeSuperadmins, true)
RelC.Hooks.Add("GetLuaSVPlayers", "Include Super Administrators by Default", includeSuperadmins, true)
RelC.Hooks.Add("GetServerErrorPlayers", "Include Super Administrators by Default", includeSuperadmins, true)
RelC.Hooks.Add("GetClientErrorPlayers", "Include Super Administrators by Default", includeSuperadmins, true)
