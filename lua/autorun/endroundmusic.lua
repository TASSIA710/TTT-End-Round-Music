
--[[
	TTT End Round Music -> Autorun (Shared)
	by Tassilo (https://github.com/TASSIA710)
--]]

TassiloEndRoundMusic = {}



if SERVER then

	-- == ServerSide: Start == --
	-- Includes
	include("endroundmusic_songs.lua")
	include("endroundmusic_commands.lua")

	-- Check if we have songs
	if table.IsEmpty(TassiloEndRoundMusic.Songs) then
		print("[EndRoundMusic] ERROR: No songs provided.")
		return
	end

	-- Pool network strings
	util.AddNetworkString("EndRoundMusic:CacheSound")
	util.AddNetworkString("EndRoundMusic:PlaySound")
	util.AddNetworkString("EndRoundMusic:RequestCache")

	-- Update cache
	TassiloEndRoundMusic.Cache = nil
	function TassiloEndRoundMusic.UpdateCache()
		TassiloEndRoundMusic.Cache = table.Random(TassiloEndRoundMusic.Songs)
		net.Start("EndRoundMusic:CacheSound")
		net.WriteString(TassiloEndRoundMusic.Cache.Author)
		net.WriteString(TassiloEndRoundMusic.Cache.Title)
		net.WriteString(TassiloEndRoundMusic.Cache.URL)
		net.Broadcast()
	end
	TassiloEndRoundMusic.UpdateCache()

	-- Prepare Round: Cache new song for round end
	hook.Add("TTTPrepareRound", "EndRoundMusic:TTTPrepareRound", function()
		TassiloEndRoundMusic.UpdateCache()
	end)

	-- End Round: Play cached song
	hook.Add("TTTEndRound", "EndRoundMusic:TTTEndRound", function()
		for _, ply in pairs(player.GetAll()) do
			if ply:GetPData("EndRoundMusic:Muted", "false") == "true" then continue end
			net.Start("EndRoundMusic:PlaySound")
			local volume = tonumber(ply:GetPData("EndRoundMusic:Volume", 100))
			if not volume then volume = 100 end
			net.WriteUInt(volume, 8)
			net.Send(ply)
		end
	end)

	-- Request Cache: Just joined player wants to know the current song
	net.Receive("EndRoundMusic:RequestCache", function(len, ply)
		net.Start("EndRoundMusic:CacheSound")
		net.WriteString(TassiloEndRoundMusic.Cache.Author)
		net.WriteString(TassiloEndRoundMusic.Cache.Title)
		net.WriteString(TassiloEndRoundMusic.Cache.URL)
		net.Send(ply)
	end)
	-- == ServerSide: End == --

else

	-- == ClientSide: Start == --
	TassiloEndRoundMusic.Current = nil

	net.Receive("EndRoundMusic:CacheSound", function(len)
		local author = net.ReadString()
		local title = net.ReadString()
		sound.PlayURL(net.ReadString(), "noplay", function(channel, errorID, errorName)
			if IsValid(channel) then
				TassiloEndRoundMusic.Current = {
					Author = author,
					Title = title,
					Channel = channel
				}
			else
				print("[EndRoundMusic] ERROR: Failed to cache sound (" .. errorID .. "): " .. errorName)
			end
		end)
	end)

	net.Receive("EndRoundMusic:PlaySound", function(len)

		if not TassiloEndRoundMusic.Current then
			print("[EndRoundMusic] ERROR: Tried to playback sound, but no clip was cached.")
			return
		end
		if not TassiloEndRoundMusic.Current.Channel or not TassiloEndRoundMusic.Current.Channel:IsValid() then
			print("[EndRoundMusic] ERROR: Tried to playback sound, but cached clips channel is invalid.")
			return
		end

		TassiloEndRoundMusic.Current.Channel:SetVolume(net.ReadUInt(8) / 100)
		TassiloEndRoundMusic.Current.Channel:Play()
		chat.AddText(Color(255, 255, 255), "Now playing: ", TassiloEndRoundMusic.Current.Author, " - ", TassiloEndRoundMusic.Current.Title)
	end)

	net.Start("EndRoundMusic:RequestCache")
	net.SendToServer()
	-- == ClientSide: End == --

end
