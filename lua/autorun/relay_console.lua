if SERVER then
	AddCSLuaFile()
end

local reloading = type(_G.RelC) == "table"

_G.RelC = _G.RelC or { }
local RelC=_G.RelC

RelC.Reloading = reloading



local sub,gsub,rep=string.sub,string.gsub,string.rep
local floor=math.floor
local sort,remove=table.sort,table.remove



local prefixLookup = {sh = 1, sv = 2, cl = 3}

local function sorter(a, b)
	local aPrefix, aName = a:lower():match("^(%a+)_([%w_]+)%.lua")
	local bPrefix, bName = b:lower():match("^(%a+)_([%w_]+)%.lua")

	if not prefixLookup[aPrefix] then
		if prefixLookup[bPrefix] then
			return false
		end
	elseif not prefixLookup[bPrefix] then
		if prefixLookup[aPrefix] then
			return true
		end
	end

	if aPrefix ~= bPrefix then
		return prefixLookup[aPrefix] < prefixLookup[bPrefix]
	end

	if aName == "init" then
		return true
	elseif bName == "init" then
		return false
	end

	return a < b
end


local function IMsg(str)
	if str==true then
		return MsgN("+----------------------------------------------------------------------------+")
	elseif str==false then
		return MsgN("|                                                                            |")
	else
		local len=#str
		local s1=floor((76-len)/2)
		local s2=76-s1-len
		Msg("|")
		Msg(rep(" ",s1))
		Msg(str)
		Msg(rep(" ",s2))
		return MsgN("|")
	end
end


MsgN()

IMsg(true)
IMsg("Initializing Relay Console...")
IMsg(true)


local GAMEPAT = ""
local currentDir=GAMEPAT
local dirDeepness=0
local lineWidth=75

IMsg("Initializing file inclusion functions.")

local include2
include2=function(abs)
	local cont=file.Read(abs,"LUA")
	cont="local RelC,FILE_PATH=RelC,"..string.format("%q",abs).." "..cont
	local fnc=CompileString(cont,abs,false)
	if type(fnc)=="function" then
		return fnc()
	else
		return MsgC(Color(255,0,0),tostring(fnc))
	end
end

local PrintTable
PrintTable=function(tab)
	for ind=1,#tab do
		local val=tab[ind]
		local indL=#tostring(indL)
		MsgN(ind,rep(" ",20-indL),"=\t",val)
	end
end

local vinclude=nil

if SERVER then
	vinclude=function(path,noInit,noFolders)
		local ext=string.GetExtensionFromFilename(path)
		local abs=((#currentDir > 0) and (currentDir.."/") or "") .. path
		local pth=gsub(abs,((#GAMEPAT > 0) and (GAMEPAT.."/") or ""),"")
		if ext=="lua" then
			local prefix=sub(path,1,3)
			if abs:find("-",1,true)then
				local spaces1=rep(" ",#pth-#path)
				local spaces2=rep(" ",lineWidth-7-#pth)
				return Msg("| "..spaces1..path..spaces2.."SKIPPED|\n")
			elseif prefix=="sv_" then
				local spaces1=rep(" ",#pth-#path)
				local spaces2=rep(" ",lineWidth-8-#pth)
				Msg("| "..spaces1..path..spaces2.."INCLUDED|\n")
				return include(abs)
			elseif prefix=="cl_" then
				local spaces1=rep(" ",#pth-#path)
				local spaces2=rep(" ",lineWidth-6-#pth)
				Msg("| "..spaces1..path..spaces2.."CACHED|\n")
				return AddCSLuaFile(abs)
			else
				local spaces1=rep(" ",#pth-#path)
				local spaces2=rep(" ",lineWidth-15-#pth)
				Msg("| "..spaces1..path..spaces2.."CACHED INCLUDED|\n")
				include(abs)
				return AddCSLuaFile(abs)
			end
		elseif not ext and not noFolders then
			local spaces1=rep(" ",#pth-#path)
			local spaces2=rep(" ",lineWidth-7-#pth)
			Msg("| "..spaces1..path..":"..spaces2.."FOLDER|\n")
			dirDeepness=dirDeepness+2
			local oldDir=currentDir
			if currentDir=="" then
				currentDir=path
			else
				currentDir=abs
			end
			local files=table.Add(file.Find(currentDir.."/*","LUA"))
			local changed=true
			while changed do
				changed=false
				for i=1,#files do
					if sub(files[i],-5):lower()==".moon" then
						remove(files,i)
						changed=true
						break
					end
				end
			end
			sort(files,sorter)
			if not noInit then
				if table.HasValue(files,"sh_init.lua")then
					vinclude("sh_init.lua")
				end
				if table.HasValue(files,"sv_init.lua")then
					vinclude("sv_init.lua")
				end
			end
			local _list_0=files
			for _index_0=1,#_list_0 do
				local lua=_list_0[_index_0]
				if lua~="sh_init.lua" and lua~="sv_init.lua" and not lua:find("sv_")then
					vinclude(lua)
				end
			end
			local _list_1=files
			for _index_0=1,#_list_1 do
				local lua=_list_1[_index_0]
				if lua~="sh_init.lua" and lua~="sv_init.lua" and lua:find("sv_")then
					vinclude(lua)
				end
			end
			dirDeepness=dirDeepness-2
			currentDir=oldDir
		end
	end
else
	vinclude=function(path,noInit,noFolders)
		local ext=string.GetExtensionFromFilename(path)
		local abs=((#currentDir > 0) and (currentDir.."/") or "") .. path
		local pth=gsub(abs,GAMEPAT,"")
		if ext=="lua" then
			if abs:find("-",1,true)then
				local spaces1=rep(" ",#pth-#path)
				local spaces2=rep(" ",lineWidth-7-#pth)
				Msg("| "..spaces1..path..spaces2.."SKIPPED|\n")
			elseif sub(path,1,3)~="sv_" then
				local spaces1=rep(" ",#pth-#path)
				local spaces2=rep(" ",lineWidth-8-#pth)
				Msg("| "..spaces1..path..spaces2.."INCLUDED|\n")
				include(abs)
			end
		elseif not ext and not noFolders then
			local spaces1=rep(" ",#pth-#path)
			local spaces2=rep(" ",lineWidth-7-#pth)
			Msg("| "..spaces1..path..":"..spaces2.."FOLDER|\n")
			local oldDir=currentDir
			if currentDir=="" then
				currentDir=path
			else
				currentDir=abs
			end
			local files=table.Add(file.Find(currentDir.."/*","LUA"))
			sort(files,sorter)
			if not noInit then
				if table.HasValue(files,"sh_init.lua")then
					vinclude("sh_init.lua")
				end
				if table.HasValue(files,"cl_init.lua")then
					vinclude("cl_init.lua")
				end
			end
			local _list_0=files
			for _index_0=1,#_list_0 do
				local lua=_list_0[_index_0]
				if lua~="sh_init.lua" and lua~="cl_init.lua" and not lua:find("cl_")then
					vinclude(lua)
				end
			end
			local _list_1=files
			for _index_0=1,#_list_1 do
				local lua=_list_1[_index_0]
				if lua~="sh_init.lua" and lua~="cl_init.lua" and lua:find("cl_")then
					vinclude(lua)
				end
			end
			currentDir=oldDir
		end
		return 
	end
end





IMsg(true)

IMsg(false)



IMsg("Including code files:")

IMsg(false)
vinclude("relc")
IMsg(false)



IMsg(true)
IMsg("Relay Console initialization finished.")
IMsg(true)

MsgN()
