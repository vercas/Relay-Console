local file = file



RelC.Hooks.Add("EngineSpew", "Log To File", function(typ, msg, group, level)
	--file.Append("conlog.txt", msg)
end)
