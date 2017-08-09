local find, sub, match, gmatch = string.find, string.sub, string.match, string.gmatch
local tonumber, error = tonumber, error



function RelC.Utils.SplitByLines(txt)
	local pieces, cnt, a, b, c = {}, 1, 0, 1

	while a do
		a, c = find(txt, "\r*\n\r*", b)

		if not a or not c then break end

		pieces[cnt] = sub(txt, b, a - 1)
		cnt = cnt + 1
		b = c + 1
	end

	pieces[cnt] = sub(txt, b)

	return pieces
end

function RelC.Utils.DecodeClientsideErrorString(txt)
	local stack, err = {}, ""

	local path, line, errmsg, stacktrace = match(txt, "^([^:]+):([^:]+):%s+([^\n]+)(.+)$")

	if not path or not line or not errmsg or not stacktrace then
		-- If we can't find a pattern, return the string we received.
		-- This supports ErrorNoHalt and friends.

		return txt, stack
	end

	--[[ uncomment this if you want to include the first error in the returned table
	stack[1] = {
		source = path,
		currentline = tonumber(line),
		name = ""
	}
	]]

	err = errmsg

	for funcname, path, line in gmatch(stacktrace, "%s+%d+%.%s+([^%s]+)%s+%-%s+([^:]+):([^\n]+)") do
		stack[#stack+1] = {
			source = path,
			currentline = tonumber(line),
			name = funcname
		}
	end

	return err, stack
end

if true then return end

if SERVER then
	local function a()
		debug.Trace()
		error "shalalalalalom"
		return "a" + {}
	end

	local function b()
		return a() + "b"
	end

	timer.Simple(1, b)
end
