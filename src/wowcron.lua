WOWCRON_MSG_ADDONNAME = "WoWCron";
WOWCRON_MSG_VERSION   = GetAddOnMetadata(INEED_MSG_ADDONNAME,"Version");
WOWCRON_MSG_AUTHOR    = "opussf";

-- Colours
COLOR_RED = "|cffff0000";
COLOR_GREEN = "|cff00ff00";
COLOR_BLUE = "|cff0000ff";
COLOR_PURPLE = "|cff700090";
COLOR_YELLOW = "|cffffff00";
COLOR_ORANGE = "|cffff6d00";
COLOR_GREY = "|cff808080";
COLOR_GOLD = "|cffcfb52b";
COLOR_NEON_BLUE = "|cff4d4dff";
COLOR_END = "|r";

wowCron = {}
cron_global = {}
cron_player = {}
cron_knownSlashCmds = {}
cron_knownEmotes = {}
wowCron.events = {}  -- [nextTS] = {[1]={['event'] = 'runME', ['fullEvent'] = '* * * * * runMe'}}
-- meh, ['fullEvent'] = ts
-- meh, meh...  [1] = '* * * * * runMe', [2] = "* * * * * other"
--wowCron.nextEvent = 0
wowCron.ranges = {
	["min"]   = {0,59},
	["hour"]  = {0,23},
	["month"] = {1,12},
	["day"]   = {1,31},
	["wday"]  = {0,7}, -- 0 and 7 is sunday
}
wowCron.fieldNames = { "min", "hour", "month", "day", "wday" }

-- events
function wowCron.OnLoad()
	SLASH_CRON1 = "/CRON"
	SlashCmdList["CRON"] = function(msg) wowCron.Command(msg); end

	wowCron_Frame:RegisterEvent("ADDON_LOADED")
	wowCron_Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	wowCron.lastUpdated = time()
end
function wowCron.OnUpdate()
	nowTS = time()
	local now = date( "*t", nowTS )
	if (wowCron.lastUpdated < nowTS) and (now.sec == 0) then
		wowCron.lastUpdated = nowTS
		wowCron.Print(date("%H:%M"))
		for _,cron in pairs( wowCron.events ) do
			runNow, cmd = wowCron.RunNow( cron )
			if runNow then
				slash, parameters = wowCron.DeconstructCmd( cmd )
				print("do now: "..cmd.." -->"..slash.." "..parameters)
				-- find the function to call based on the slashcommand
				isGood = false
				for _,func in ipairs(wowCron.actionsList) do
					isGood = isGood or func( slash, parameters )
					if isGood then break end
				end
			end
		end
		if (now.min == 0) then
			wowCron.Print("On the hour")
		end
	end
end
function wowCron.ADDON_LOADED()
	-- Unregister the event for this method.
	wowCron_Frame:UnregisterEvent("ADDON_LOADED")

	wowCron.ParseAll()
	wowCron.BuildSlashCommands()
	--INEED.OptionsPanel_Reset();
	--wowCron.Print("Loaded")
end
function wowCron.PLAYER_ENTERING_WORLD()
	wowCron_Frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
	wowCron.BuildSlashCommands()
end

-- Support Code
wowCron.actionsList = {}
function wowCron.CallAddon( slash, parameters )
	-- loop through cron_knownSlashCmds (for other loaded addons)
	-- return true if could handle the slash command
	for k,v in pairs( cron_knownSlashCmds ) do
		if string.lower( slash ) == string.lower( k ) then
			--call the function
			v( parameters )
			return true
		end
	end
end
wowCron.actionsList[1] = wowCron.CallAddon
function wowCron.CallEmote( slash, parameters )
	-- look for emote in cron_knownEmotes for emotes to call
	-- return true if could handle the slash command
	token = string.upper(strsub( slash, -(strlen( slash )-1) ))
	for _,v in pairs( cron_knownEmotes ) do
		if token == v then
			DoEmote(token)
			return true
		end
	end
end
wowCron.actionsList[2] = wowCron.CallEmote
function wowCron.RunScript( slash, parameters )
	slash = string.lower( slash )
	--print("RunScript( "..slash..", "..parameters.." )")
	if slash == "/run" or slash == "/script" then
		--print("Calling "..parameters)
		loadstring(parameters)()
		return true
	end
end
wowCron.actionsList[3] = wowCron.RunScript

function wowCron.BuildSlashCommands()
	local count = 0
	for k,v in pairs(SlashCmdList) do
		count = count + 1
		--wowCron.Print(string.format("% 2i : %s :: %s", count, k, type(v)))
		cron_knownSlashCmds[k] = v
		lcv = 1
		while true do
			teststr = "SLASH_"..k..lcv
			gggg = _G[ teststr ]
			if not gggg then break end
			--print("_G["..teststr.."] = "..gggg)
			cron_knownSlashCmds[gggg] = v
			if lcv >= 10 then break end
			lcv = lcv + 1
		end
	end
	--print(MAXEMOTEINDEX)
	for i = 1,1000 do
		cron_knownEmotes[i] = _G["EMOTE"..i.."_TOKEN"]
	end
end
function wowCron.RunNow( cmdIn, ts )
	-- @param cmdIn command to test
	-- @param ts optional ts to test with
	-- @return boolean run this command now (1, nil)
	-- @return string command to run (cmd, nil)

	-- put all six values into parsed table
	parsed = { wowCron.Parse( cmdIn ) }
	local ts = ts or time()
	local ts = date( "*t", ts )

	-- expand the string pattern to a keyed truth table
	for k,v in pairs( wowCron.fieldNames ) do -- 1 based array of field names, k = int, v = str
		parsed[k] = wowCron.Expand( parsed[k], v )
	end
	-- parsed[2] = {[5] = 1, [10] = 1}  2 equates to the 2nd value in fieldNames

	-- this is technically incorrect, will have to revisit this later.
	-- wday and day should be or if they are not wild cards.
	isMatch = true
	for i, fieldName in pairs( wowCron.fieldNames ) do
		isMatch = isMatch and wowCron.TableHasKey( parsed[i], ts[fieldName] )
	end

	return isMatch, parsed[6]
end
function wowCron.TableHasKey( table, key )
	-- loop over the table, return true if any of the keys equal the given key
	for k in pairs( table ) do
		if key == k then
			return true
		end
	end
end
function wowCron.Expand( value, type )
	-- @parm value Value to expand
	-- @param type The type to expand
	-- @return table of possible values as keys

	-- valid min/max values are in wowCron.ranges.type
	local minVal, maxVal = unpack(wowCron.ranges[type])

	-- Expand * to min-max
	value = string.gsub(value, "*", minVal.."-"..maxVal)
	-- split the values on ,
	valueList = { strsplit( ",", value ) }
	out = {}

	for _,value in ipairs(valueList) do
		svalue, step = strmatch( value, "^(%S*)/(%S*)$" )
		if step then value = svalue end
		step = step or 1

		s, e = strmatch( value, "^(%d+)-(%d+)$")
		s = s or value  -- if not a range, then set s to the value
		e = e or s  -- if not a range, then set e to the value

		for v = s, e, step do
			if v >= minVal and v <= maxVal then  -- @TODO should this toss an error of some sort, or just quietly fail?  Where should the error be registered?
				out[type == "wday" and v+1 or v] = 1 -- add one for the wday conversion
			end
		end
	end
	return out
end

function wowCron.ParseAll()
	-- Only when starting, or changing
	wowCron.events = {}
	for _, cmd in ipairs(cron_global) do
		tinsert( wowCron.events, cmd )
	end
	-- player specific events
	for _, cmd in ipairs(cron_player) do
		tinsert( wowCron.events, cmd )
	end

end
function wowCron.Parse( cron )
	-- takes the cron string and returns the 5 cron patterns, and the command
	local min, hour, day, month, wday, cmd =
			strmatch( cron,	"^(%S+)%s*(%S+)%s*(%S+)%s*(%S+)%s*(%S+)%s*(.*)$" )
	return min, hour, day, month, wday, cmd
end

function wowCron.DeconstructCmd( cmdIn )
	local a,b,c = strfind( cmdIn, "(%S+)" )
	if a then
		return c, strsub( cmdIn, b+2 )
	else
		return ""
	end
end
function wowCron.PrintHelp()
	wowCron.Print("Creates a crontab for WoW.")
	wowCron.Print("Used standard Cron format (min hour day month wday cmd).")
	wowCron.Print("cmd can be any currently installed addon slash command, an emote, or '/run <lua code>'.")
	for cmd, info in pairs(wowCron.CommandList) do
		wowCron.Print(string.format("%s %s %s -> %s",
			SLASH_CRON1, cmd, info.help[1], info.help[2]))
	end
end
function wowCron.List()
	cronTable = wowCron.global and cron_global or cron_player
	wowCron.Print( "Listing cron entries for "..( wowCron.global and "global" or "personal" ) )
	for i,entry in ipairs(cronTable) do
		wowCron.Print( string.format("[% 3i] %s", i, entry) )
	end
end
function wowCron.Remove( index )
	cronTable = wowCron.global and cron_global or cron_player
	index = tonumber(index)
	if index and index>0 and index<=#cronTable then
		local entry = table.remove( cronTable, index )
		wowCron.Print( COLOR_RED.."REMOVING: "..COLOR_END..entry )
	end
end
function wowCron.AddEntry( entry )
	if strlen( entry ) >= 9 then -- VERY mimimum size of a cron is 9 char (5x * and 4 spaces)
		cronTable = wowCron.global and cron_global or cron_player
		table.insert( cronTable, entry )
		wowCron.Print( string.format("Added to %s: %s", (wowCron.global and "global" or "personal"), entry ) )
	else
		wowCron.PrintHelp()
	end
end
wowCron.CommandList = {
	["help"] = {
		["func"] = wowCron.PrintHelp,
		["help"] = {"","Print this help."},
	},
	["global"] = {
		["func"] = function( msg ) wowCron.Command( msg, true ); end,
		["help"] = {"<commands>", "Sets global flag"},
	},
	["list"] = {
		["func"] = wowCron.List,
		["help"] = {"", "List cron entries."}
	},
	["rm"] = {
		["func"] = wowCron.Remove,
		["help"] = {"index", "Remove index entry."}
	},
	["add"] = {
		["func"] = wowCron.AddEntry,
		["help"] = {"<entry>", "Adds an entry. Default action."}
	},
}
function wowCron.Command( msg, isGlobal )
	wowCron.global = isGlobal
	cmd, parameters = wowCron.DeconstructCmd( msg )
	cmd = string.lower(cmd)
	local cmdFunc = wowCron.CommandList[cmd]
	if cmdFunc then
		cmdFunc.func( parameters )
	else
		wowCron.AddEntry( msg )
	end
end
function wowCron.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = WOWCRON_MSG_ADDONNAME.."> "..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end

