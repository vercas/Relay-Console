local find, sub = string.find, string.sub
local Msg, MsgN, print = Msg, MsgN, print
local type, error, tostring, xpcall = type, error, tostring, xpcall
local debug_getinfo, debug_getlocal, debug_getupvalue, debug_traceback = debug.getinfo, debug.getlocal, debug.getupvalue, debug.traceback
local math_floor = math.floor



function RelC.Utils.Traceback(level)
	return debug_traceback("Event-Horizon traceback:", 2 + ((type(level) == "number") and level or 0))
end
local Tb = RelC.Utils.Traceback



--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--
--	Prints large tracebacks around the limitations of the print functions!	--
--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--

function RelC.Utils.PrintTraceback(steps, level, tb)
	if not tb then
		tb = Tb(level)
	end

	if Msg and MsgN then
		for i = 1, #tb, steps do
			Msg(sub(tb, i, i + steps - 1))
		end

		MsgN()
	else
		local i, j, k = 1

		repeat
			j, k = find(tb, i, "\r*\n\r*")	--	Will screw every carrior return.

			if not (j and k) then
				print(sub(tb, i))

				break
			else
				print(sub(tb, i, j - 1))

				i = k + 1
			end
		until false

		print()
	end
end



local function queuefunc(fnc, functionlist, donefunctions)
	if donefunctions[fnc] then return end

	functionlist[#functionlist+1] = fnc
	donefunctions[fnc] = true
end

function RelC.Utils.AcquireStack(level)
	if type(level) ~= "number" or level ~= math_floor(level) or level < 1 then
		error("level must be a strictly positive integer")
	end

	local functionlist, donefunctions, stack, thesaurus = {}, {}, {}, {}

	local i = level

	while true do
		local info = debug_getinfo(i)

		if not info then
			break
		end

		stack[#stack+1] = info
		info._stackpos = i

		if info.func then
			thesaurus[info.func] = info
			queuefunc(info.func, functionlist, donefunctions)
			info.func = tostring(info.func)
		end

		--if info.what == "Lua" then
		info._locals = {}
		local locals = info._locals

		local j = 1

		while true do
			local n, v = debug_getlocal(i, j)

			if not n then break end

			locals[#locals+1] = {name=n,value=v}

			if type(v) == "function" then
				queuefunc(v, functionlist, donefunctions)
				locals[#locals].value = tostring(locals[#locals].value)
			end

			j = j + 1
		end
		--end

		i = i + 1
	end

	i = 1

	while i <= #functionlist do
		local fnc = functionlist[i]

		local info

		if thesaurus[fnc] then
			info = thesaurus[fnc]
			thesaurus[fnc] = info._stackpos
		else
			info = debug_getinfo(fnc)
			thesaurus[fnc] = info
		end

		local ups = {}
		info._upvalues = ups

		for j = 1, info.nups do
			local n, v = debug_getupvalue(fnc, j)

			ups[#ups+1] = {name=n,value=v}

			if type(v) == "function" then
				queuefunc(v, functionlist, donefunctions)
				ups[#ups].value = tostring(ups[#ups].value)
			end
		end

		i = i + 1
	end

	local newthesaurus = {}

	for k, v in pairs(thesaurus) do
		newthesaurus[tostring(k)] = v
	end

	return stack, thesaurus, newthesaurus
end