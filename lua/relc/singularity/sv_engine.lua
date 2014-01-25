local DecodeClientsideErrorString = RelC.Utils.DecodeClientsideErrorString



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

		if type(err) ~= "string" or (stack ~= nil and type(stack) ~= "table") then
			MsgC(Color(255, 0, 0), "Messed up error: ")
			MsgN("(", type(err), ") ", tostring(err), " - ", "(", type(stack), ") ", tostring(stack))

			return
		elseif stack == nil then
			stack = {}
		end

		if catching then
			queue:Queue({ err, stack })

			MsgC(Color(255, 0, 0), "Capture error that would cause infinite recursion:\n")
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
