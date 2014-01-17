local GetAllPlayers = player.GetAll



local function includeSuperadmins(plys)
	local all = GetAllPlayers()

	for i = 1, #all do
		if IsValid(all[i]) and all[i]:IsUserGroup("owner") then
			plys[#plys + 1] = all[i]
		end
	end

	--BroadcastChatText("Relayed console stuff to ", #plys, " players our of ", #all, ".")
end

RelC.Hooks.Add("GetShowPlayers", "Include Owners by Default", includeSuperadmins, true)

RelC.Hooks.Add("GetSpewPlayers", "Include Owners by Default", includeSuperadmins, true)
RelC.Hooks.Add("GetRConPlayers", "Include Owners by Default", includeSuperadmins, true)
RelC.Hooks.Add("GetLuaSVPlayers", "Include Owners by Default", includeSuperadmins, true)
RelC.Hooks.Add("GetServerErrorPlayers", "Include Owners by Default", includeSuperadmins, true)
RelC.Hooks.Add("GetClientErrorPlayers", "Include Owners by Default", includeSuperadmins, true)
