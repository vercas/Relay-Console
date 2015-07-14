local DecodeClientsideErrorString = RelC.Utils.DecodeClientsideErrorString
local find = string.find
local type, tostring, pcall, hook = type, tostring, pcall, hook



local hasEngineSpew, engineSpew = pcall(require, "enginespew")
local hasLuaError, luaError = pcall(require, "luaerror")



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
	if luaerror == nil then
		-- Nothing to do here, bad module.

		return
	end

	-- Enable all the detours to provide the same functionality as gm_luaerror.

	luaerror.EnableRuntimeDetour(true)
	luaerror.EnableCompiletimeDetour(true)
	luaerror.EnableClientDetour(true)

	hook.Add("LuaError", "Relay Console", function(isruntime, file, line, err, stack)
		-- Simulate Garry's Mod behavior if it's a compiletime error and stack is empty.

		if not isruntime and #stack == 0 then
			stack[1] = {
				source = file,
				currentline = line,
				name = "unknown"
			}
		end

		hook_luaErrorSV(err, stack)
	end)

	hook.Add("ClientLuaError", "Relay Console", function(ply, file, line, err, stack)
		hook_luaErrorCL(ply, err, stack)
	end)
end
