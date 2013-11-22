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
