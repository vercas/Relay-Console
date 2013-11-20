--	--	--	--	--	--	--	--	--
--	Addon-specific hook module	--
--	--	--	--	--	--	--	--	--



local vcall = pcall --RelC.Singularity.AttemptCall
local table_remove, unpack = table.remove, unpack
local insert = table.insert



--	--	--	--	--	--	--	--	--	--	--
--	Conservation of hooks upon refresh!	--
--	--	--	--	--	--	--	--	--	--	--

RelC.Hooks = RelC.Hooks or { }

local store = RelC.Hooks._Store or { }
local funcies = RelC.Hooks._Funcies or { }

RelC.Hooks._Store = store
RelC.Hooks._Funcies = funcies



--	--	--	--	--	--	--	--	--	--	--	--
--	Some configuration for the hook system.	--
--	--	--	--	--	--	--	--	--	--	--	--

local removeHooksThatHaveErrors = false
local catchHookErrors = false



local removehook = nil	--	Function that will be assigned later.



local function _InitHook(hook)
	store[hook] = store[hook] or { }
	local story = store[hook]

	funcies[hook] = function(...)
		local errors = false

		local problems = { }

		for k, v in pairs(story) do
			if catchHookErrors then
				--local a,b=pcall(v,...)
				local a, b = vcall(v, ...)

				if not a then
					errors = true
					insert(problems, k)

					--ErrorNoHalt("Relay Console Hooks: Encountered error with \""..tostring(k).."\" of hook \""..tostring(hook).."\"; "..tostring(b))
					ErrorNoHalt("Relay Console Hooks: Encountered error with \"" .. tostring(k) .. "\" of hook \"" .. tostring(hook) .. "\": " .. tostring(b.Error) .. "\n" .. tostring(b.ShortTrace) .. "\n--")
				end
			else
				v(...)
			end
		end

		if removeHooksThatHaveErrors and errors then
			for i = 1, #problems do
				removehook(hook, problems[i])

				MsgN("Relay Console Hooks: Removed \""..tostring(problems[i]).."\" from hook \""..tostring(hook).."\" to prevent further problems.")
			end
		end

		return true
	end
end



for hook, func in pairs(funcies) do
	_InitHook(hook)
end



RelC.Hooks.Add = function(hook, name, func, override)
	if not funcies[hook] then
		_InitHook(hook)
	elseif store[hook][name] and not override then
		return false
	end

	store[hook][name] = func

	return true
end

RelC.Hooks.Remove = function(hook, name)
	if store[hook] and store[hook][name] then
		store[hook][name] = nil

		return true
	end

	return false
end
removehook = RelC.Hooks.Remove

local callmeta = {
	__call = function(self, hook, ...)
		if not funcies[hook] then
			_InitHook(hook)
		end

		return funcies[hook](...)
	end,

	__index = function(self, hook)
		if not funcies[hook] then
			_InitHook(hook)
		end

		return funcies[hook]
	end,

	__newindex = function(self, key, val)
		error("Cannot change this table!")
	end,

	__metatable = true,
}

RelC.Hooks.Call = setmetatable({ }, callmeta)



--	--	--	--	--	--	--	--
--	Some forwarded hooks	--
--	--	--	--	--	--	--	--



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
	hook_entityRemoved(ent)

	if ent:IsPlayer() then
		hook_playerLeft(ent, ent:SteamID64(), ent:SteamID())
	end
end)



--	--	--	--	--	--	--	--	--
--	Addon-specific hook module	--
--	--	--	--	--	--	--	--	--



local _queue_meta = {
	__index = {
		Queue = function(self, val)
			self[#self + 1] = val
		end,

		Dequeue = function(self)
			local val = self[1]

			table_remove(self, 1)

			return val
		end,

		Peek = function(self)
			return self[1]
		end,

		SetHead = function(self, val)
			self[1] = val
		end,

		IsEmpty = function(self)
			return #self == 0
		end,
	}
}



RelC.Queue = function()
	return setmetatable({}, _queue_meta)
end




--	--	--	--	--	--	--	--	--
--	Now the engine hooking part	--
--	--	--	--	--	--	--	--	--



local hasEngineSpew, engineSpew = pcall(require, "enginespew")
local hasLuaError, luaError = pcall(require, "luaerror2")



RelC.HasEngineSpew = hasEngineSpew
RelC.HasLuaError = hasLuaError



local hook_engineSpew = RelC.Hooks.Call.EngineSpew
local hook_luaErrorSV = RelC.Hooks.Call.ServerLuaError
local hook_luaErrorCL = RelC.Hooks.Call.ClientLuaError



if hasEngineSpew then
	local spewing, queue = false, RelC.Queue(20)

	hook.Add("EngineSpew", "Relay Console", function(msgType, msgText, msgGroup, msgLevel)
		if spewing then
			queue:Queue({ msgType, msgText, msgGroup, msgLevel })
		else
			spewing = true

			hook_engineSpew(msgType, msgText, msgGroup, msgLevel)

			spewing = false
		end
	end)

	hook.Add("Think", "Relay Console EngineSpew Decongestion", function()
		while not queue:IsEmpty() do
			spewing = true

			hook_engineSpew(unpack(queue:Dequeue()))

			spewing = false
		end
	end)
end

if hasLuaError then
	local catching, queue = false, RelC.Queue(20)

	hook.Add("LuaError", "Relay Console", function(serverside, err, stack)
		--[[if not stack then
			print("stack is ", type(stack), " ", tostring(stack))
			local _stack, _thesaurus, _newthesaurus = RelC.Utils.AcquireStack(3)
			stack = _stack
		end--]]

		if catching then
			queue:Queue({ err, stack })
		else
			catching = true

			hook_luaErrorSV(err, stack)

			catching = false
		end
	end)

	hook.Add("Think", "Relay Console LuaError Decongestion", function()
		while not queue:IsEmpty() do
			catching = true

			hook_luaErrorSV(unpack(queue:Dequeue()))

			catching = false
		end
	end)



	hook.Add("ClientLuaError", "Relay Console", function(ply, err)
		hook_luaErrorCL(ply, err)
	end)
end
