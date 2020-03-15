
--[[
	TTT End Round Music -> Commands (ServerSide)
	by Tassilo (https://github.com/TASSIA710)
--]]

hook.Add("PlayerSay", "EndRoundMusic:PlayerSay", function(ply, text)

	text = string.lower(text)
	if not string.StartWith(text, "!music") then return end
	text = string.Trim(string.sub(text, 7))

	if text == "mute" or text == "unmute" then
		if ply:GetPData("EndRoundMusic:Muted", "false") ~= "true" then
			ply:SetPData("EndRoundMusic:Muted", "true")
			ply:ChatPrint("EndRoundMusic is now muted.")
			return ""

		else
			ply:RemovePData("EndRoundMusic:Muted")
			ply:ChatPrint("EndRoundMusic is no-longer muted.")
			return ""

		end
	end

	if string.StartWith(text, "volume") then
		text = tonumber(string.Trim(string.sub(text, 7)))
		if not text then return end
		text = math.Clamp(math.Round(text), 0, 200)
		if text ~= 100 then
			ply:SetPData("EndRoundMusic:Volume", text)
		else
			ply:RemovePData("EndRoundMusic:Volume")
		end
		ply:ChatPrint("Set EndRoundMusic volume to " .. text .. "%.")
		return ""
	end

end)
