local type, pairs, tostring, string = type, pairs, tostring, string
local rep, format = string.rep, string.format
local table_sort = table.sort



function RelC.Utils.CopyArray(src)
	local rep = {}

	for i = #src, 1, -1 do
		rep[i] = src[i]
	end

	return rep
end

local function copyDictionary(tab, lookup)
	if not lookup then lookup = {} end

	local new = {}

	lookup[tab] = new

	for k, v in pairs(tab) do
		if type(k) == "table" then
			k = lookup[k] or copyDictionary(k, lookup)
		end

		if type(v) == "table" then
			v = lookup[v] or copyDictionary(v, lookup)
		end

		new[k] = v
	end

	return new
end

RelC.Utils.CopyDictionary = copyDictionary



local function computeDifference(a, b, diffs, ...)
	if not diffs then diffs = {} end

	local done = {}

	for k, v in pairs(a) do
		done[k] = true

		if v ~= b[k] then
			if type(v) == "table" and type(b[k]) == "table" then
				computeDifference(v, b[k], diffs, k, ...)
			else
				diffs[#diffs+1] = {b[k], k, ...}
			end
		end
	end

	for k, v in pairs(b) do
		if not done[k] then
			diffs[#diffs+1] = {v, k, ...}
		end
	end

	return diffs
end

RelC.Utils.ComputeTableDifferences = computeDifference



local function prettyString(data)
	if type(data) == "string" then
		return format("%q", data)
	else
		return tostring(data)
	end
end

local colkeys = { a = true, r = true, g = true, b = true}
local function isColor(tab)
	local hits = 0

	for k, _ in pairs(tab) do
		if colkeys[k] then
			hits = hits + 1
		else
			return false
		end
	end

	return hits == 4
end

local function PrintTable(t, indent, done)
	done = done or {}
	indent = indent or 0
	local str, cnt = "", 0

	for key, value in pairs(t) do
		str = str .. rep ("    ", indent)

		if type(value) == "table" and not done[value] then
			done[value] = true

			local ts = tostring(value)

			if isColor(value) then
				str = str .. prettyString (key) .. " = " .. string.format("# %X %X %X %X", value.a, value.r, value.g, value.b) .. "\n"
			elseif ts:sub(1, 9) == "table: 0x" then
				local _str, _cnt = PrintTable(value, indent + 1, done)

				str = str .. prettyString(key) .. ":" .. ((_cnt > 0) and ("\n" .. _str) or " empty table\n")
			else
				str = str .. prettyString (key) .. " = " .. ts .. "\n"
			end
		else
			str = str .. prettyString (key) .. " = " .. prettyString(value) .. "\n"
		end

		cnt = cnt + 1
	end

	return str, cnt
end

RelC.Utils.TableToString = PrintTable



function RelC.Utils.CreateArrayLookupTable(arr)
	local res = {}

	for i = #arr, 1, -1 do
		res[arr[i]] = i
	end

	return res
end



local function digestSorter(a, b)
	return tostring(a[1]) < tostring(b[1])
end

local function convertDictionaryToArray(tab)
	local new = {}

	for k, v in pairs(tab) do
		if type(v) == "table" then
			new[#new+1] = {k, convertDictionaryToArray(v)}
		else
			new[#new+1] = {k, v}
		end
	end

	table_sort(new, digestSorter)

	return new
end

--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--	--
--	Gets a version of this table with the data preserved but arranged in an order which can be consistently retrieved in the same order.
RelC.Utils.DigestTable = convertDictionaryToArray
