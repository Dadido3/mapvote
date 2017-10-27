
local function normalizeMapName(name)
	name = string.lower(name)
	name = string.gsub(name, " ", "")
	name = string.gsub(name, ".bsp", "")
	name = string.gsub(name, ".bz2", "")
	return name
end

local function contains(t, e)
	for k, v in ipairs(t) do
		if v == e then return true end
	end
	return false
end

if EXCL_MAPVOTE.MapLoader == "fs" then
	-- Use the filesystem. We will read the maps list from a file called "excl_mapvote.txt" in the "data" folder.
	
	if not file.Exists("excl_mapvote.txt", "DATA") then
		file.Write("excl_mapvote.txt", "gm_construct\ngm_flatgrass")
	end
	
	local maps = file.Read("excl_mapvote.txt", "DATA")
	if not maps then
		Error("File I/O error; Couldn't open vote list.")
		return
	end
	
	-- Normalize line feed sequences and names
	maps = string.gsub(maps, "\r\n", "\n")
	maps = string.gsub(maps, "\r", "\n")
	maps = normalizeMapName(maps)
	maps = string.Explode("\n", maps)
	
	-- Get available maps
	local availableMaps = file.Find("maps/*.bsp", "GAME")
	MsgC(Color(255, 255, 255, 0), "\nAvailable maps:\n")
	for k, v in pairs(availableMaps) do
		availableMaps[k] = normalizeMapName(v)
		MsgC(Color(255, 255, 255, 0), availableMaps[k] .. "\t")
	end
	
	-- Remove the current map, empty entries, and not available maps from the list
	MsgC(Color(255, 255, 255, 0), "\nThese maps are defined in \"excl_mapvote.txt\", but can't be found:\n")
	for i = #maps, 1, -1 do -- ipairs will skip an element if you remove the current element, so iterate backwards
		if not contains(availableMaps, maps[i]) then
			MsgC(Color(255, 255, 255, 0), maps[i] .. "\t")
			table.remove(maps, i)
		elseif maps[i] == "" or maps[i] == normalizeMapName(game.GetMap()) then
			table.remove(maps, i)
		end
	end
	
	if not maps or not maps[1] then
		Error("List of maps is empty, check \"excl_mapvote.txt\" and make sure the defined maps are installed.")
		return
	end
	
	-- Select up to 8 random maps out of "maps" and the current map
	local amountMaps = math.min(8, #maps)
	EXCL_MAPVOTE.MapSelection = {}
	while #EXCL_MAPVOTE.MapSelection < amountMaps do
		local map
		local rnd = math.random(1, #maps)
		if #EXCL_MAPVOTE.MapSelection < amountMaps - 1 or not EXCL_MAPVOTE.AllowExtend then
			map = maps[rnd]
			table.remove(maps, rnd)
		else
			map = normalizeMapName(game.GetMap())
		end
		-- Check if AzBot is active on this map
		local bots = false
		if AzBot and AzBot.CheckMapNavMesh then
			bots = AzBot.CheckMapNavMesh(map) or false
		end
		table.insert(EXCL_MAPVOTE.MapSelection, {map = map, bots = bots})
	end
	
	MsgC(Color(255, 255, 255, 0), "\nThe following maps will be voted on later this game:\n")
	for k, v in pairs(EXCL_MAPVOTE.MapSelection) do
		MsgC(Color(255, 255, 255, 0), "\t" .. k .. ". " .. v.map)
		
		if file.Exists("materials/excl_mapvote/maps/" .. v.map .. ".png", "GAME") and not EXCL_MAPVOTE.IconsURL then
			resource.AddSingleFile("materials/excl_mapvote/maps/" .. v.map .. ".png")
		end
	end
	
--elseif EXCL_MAPVOTE.MapLoader == "somethingElse" then

-- Your own loader here


end
