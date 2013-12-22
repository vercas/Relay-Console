local string_sub, table_concat, table_remove = string.sub, table.concat, table.remove
local type = type



local spewCollection = RelC.Queue(20)
--	This sounds like a party prostitue, doesn't it?
--	Can take 20 loads by default. Lovely, isn't it?

local lastColor = nil



RelC.Hooks.Add("EngineSpew", "Capture Spew", function(typ, msg, group, level)
	if lastColor then
		spewCollection:Queue(lastColor)

		lastColor = nil
	end

	--BroadcastChatText("Added spew: ", msg)
	spewCollection:Queue(msg)
end, true)



local hook_relayConsoleGetSpewPlayers = RelC.Hooks.Call.GetSpewPlayers

local function getPlayers()
	local plys = {}

	hook_relayConsoleGetSpewPlayers(plys)

	return plys
end



local sendAmount, throttleAmount, minimumAmount = 200, 10, 100

local function acquire()
	local ret, len, piece, last, lastIsColor = {}, 0

	while (not spewCollection:IsEmpty()) and len < sendAmount do
		piece = spewCollection:Peek()

		if type(piece) == "string" then
			if len + #piece <= sendAmount then
				spewCollection:Dequeue()
			else
				spewCollection:SetHead(string_sub(piece, sendAmount - len + 1))

				piece = string_sub(piece, 1, sendAmount - len)
			end

			if type(last) == "string" then
				ret[#ret] = { [-1] = true, last, piece }
			elseif type(last) == "table" and last._CONCAT then
				last[#last+1] = piece
			else
				ret[#ret+1] = piece
			end

			len = len + #piece

			lastIsColor = false
		elseif type(piece) == "table" then
			spewCollection:Dequeue()

			if piece.r then
				if type(last) == "table" and last.r then
					ret[#ret] = piece
				else
					ret[#ret+1] = piece
				end

				lastIsColor = true
			end
		end

		last = ret[#ret]
	end

	if not spewCollection:IsEmpty() then
		sendAmount = sendAmount + throttleAmount
	elseif len < sendAmount and (sendAmount - throttleAmount) >= minimumAmount then
		sendAmount = sendAmount - throttleAmount
	end

	for i = 1, #ret do
		if type(ret[i]) == "table" and ret[i][-1] then
			ret[i] = table_concat(ret[i])
		end
	end

	return ret, (not lastIsColor) and spewCollection:IsEmpty()
end



local hook_relayConsoleSpewTransmit = RelC.Hooks.Call.SpewTransmit

RelC.Hooks.Add("GamemodeThink", "Dispatch Spew", function()
	local str, noColor = acquire()

	if #str > 0 then
		local plys = getPlayers()

		hook_relayConsoleSpewTransmit(plys, str)

		if noColor then
			lastColor = Color(255, 255, 255, 255)
		end
	end
end, true)



--	--	--	--	--	--
--	Color capture.	--
--	--	--	--	--	--



local colors = {
	print = Color(255, 255, 255, 255),
	Msg = Color(143, 218, 230, 255),
	MsgC = Color(0, 201, 255, 255)
}



local oldFuncKeys, oldFuncs, _G = {}, {}, _G

for _, name in pairs({"print", "Msg", "MsgN", "MsgC"}) do
	oldFuncKeys[name] = "__RelC_legacy_" .. name
	_G[oldFuncKeys[name]] = _G[oldFuncKeys[name]] or _G[name]	--	Support for reloading.
	oldFuncs[name] = _G[oldFuncKeys[name]]
end



local function concat(tab, sep)
	for i = 1, #tab do
		tab[i] = tostring(tab[i])
	end

	return table_concat(tab, sep)
end



function print(...)
	lastColor = colors.print

	if not RelC.HasEngineSpew then
		spewCollection:Queue(concat({...}, "\t"))
		spewCollection:Queue("\n")
	end

	oldFuncs.print(...)
end

function Msg(...)
	lastColor = colors.Msg

	if not RelC.HasEngineSpew then
		spewCollection:Queue(concat({...}))
	end

	oldFuncs.Msg(...)
end

function MsgN(...)
	lastColor = colors.Msg

	if not RelC.HasEngineSpew then
		spewCollection:Queue(concat({...}))
		spewCollection:Queue("\n")
	end

	oldFuncs.MsgN(...)
end

function MsgC(col, ...)
	lastColor = col or colors.MsgC

	if not RelC.HasEngineSpew then
		spewCollection:Queue(concat({...}))
	end

	oldFuncs.MsgC(col, ...)
end
