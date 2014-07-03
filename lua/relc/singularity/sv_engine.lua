local DecodeClientsideErrorString = RelC.Utils.DecodeClientsideErrorString
local find = string.find
local type, tostring, pcall, hook = type, tostring, pcall, hook



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
		--	Making sure stuff is alright.

		if type(err) ~= "string" or (stack ~= nil and type(stack) ~= "table") then
			MsgC(Color(255, 0, 0), "Messed up error: ")
			MsgN("(", type(err), ") ", tostring(err), " - ", "(", type(stack), ") ", tostring(stack))

			--	This kind of errors are bogus - not actual errors.

			return
		elseif stack == nil then
			stack = {}--RelC.Utils.AcquireStack(2, true)
		end

		--	Fixing possible problems...

		local a, b, source, line, errstr = find(err, "(.+):([%-%d]+): (.+)")

		if a == 1 and b == #err and type(errstr) == "string" and #errstr > 0 then
			err = errstr

			if #stack == 0 then
				stack[1] = {
					source = source,
					currentline = tonumber(line),
					name = "unknown; inferred"
				}

				stack[2] = {
					source = "MISSING STACK INFORMATION!",
					currentline = -1,
					name = "unknown"
				}
			end
		end

		--	Preventing recursive errors.

		if catching then
			queue:Queue({ err, stack })

			MsgC(Color(255, 0, 0), "Captured error that would cause infinite recursion:\n")
			PrintTable({ err, stack })
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



	hook.Add("ClientLuaError", "Relay Console", function(ply, txt)
		local err, stack = DecodeClientsideErrorString(txt)

		--	Decoding is done here because a better engine interface could provide the necessary data directly.

		hook_luaErrorCL(ply, err, stack)
	end)
end
