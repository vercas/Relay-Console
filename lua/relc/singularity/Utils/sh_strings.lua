local find, sub = string.find, string.sub
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



local SplitByLines = RelC.Utils.SplitByLines

function RelC.Utils.DecodeClientsideErrorString(txt)
	local lines, i, err, stack = SplitByLines(txt), 1, nil, {}

	--	Skip empty line(s)
	while #lines[i] == 0 do
		i = i + 1
	end

	local a, b, location, errstr = find(lines[i], "%[ERROR%] (.*:[%-%d]*): (.*)")	--	"[ERROR] (source:line): (error text)"

	if a ~= 1 or b ~= #lines[i] then
		error("Text given does not contain a valid/known error string!")
	end

	--err = "[" .. location .. "] " .. errstr
	err = errstr

	i = i + 1

	--	Skip empty line(s)
	while #lines[i] == 0 do
		i = i + 1
	end

	repeat
		local a, b, pos, funcname, source, line = find(lines[i], "%s*(%d+)%.%s*(%w*) %- (.+):([%-%d]+)%s*")	--	"  (pos). (funcname) - (source):(line)"

		if a ~= 1 or b ~= #lines[i] or tonumber(pos) ~= (#stack + 1) then
			break	--	Not a stack thingie.
		end

		stack[tonumber(pos)] = {
			name = funcname,
			source = source,
			currentline = tonumber(line),
		}

		i = i + 1
	until lines[i] == nil or #lines[i] == 0

	--	Beatiful way, isn't it? :D

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