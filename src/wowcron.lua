WOWCRON_MSG_ADDONNAME = "WoWCron";
WOWCRON_MSG_VERSION   = GetAddOnMetadata(INEED_MSG_ADDONNAME,"Version");
WOWCRON_MSG_AUTHOR    = "opussf";

-- Colours
--[[
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
]]

wowCron = {}
cron_global = {}
cron_player = {}
wowCron.events = {}  -- [nextTS] = {[1]={['event'] = 'runME', ['fullEvent'] = '* * * * * runMe'}}
-- meh, ['fullEvent'] = ts
wowCron.nextEvent = 0
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
	wowCron.lastUpdated = time()
end
function wowCron.OnUpdate()
	nowTS = time()
	local now = date( "*t", nowTS )
	if (wowCron.lastUpdated < nowTS) and (now.sec == 0) then
		wowCron.lastUpdated = nowTS
		wowCron.Print("On the minute. "..(nowTS % 60))
		for cron, ts in pairs(wowCron.events) do
			if (ts < nowTS) then -- has not been run yet
			end
			local run, cmd = wowCron.RunNow( cron )

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

-- Support Code
function wowCron.BuildSlashCommands()
	local count = 0
	for k,v in pairs(SlashCmdList) do
		count = count + 1
		wowCron.Print(string.format("% 2i : %s", count, k))
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
--		print(k..":"..v)
		parsed[k] = wowCron.Expand( parsed[k], v )
	end
	-- parsed[2] = {[5] = 1, [10] = 1}  2 equates to the 2nd value in fieldNames

	isMatch = true
	for i, fieldName in pairs( wowCron.fieldNames ) do
--		print(i.."::"..fieldName.."("..ts[fieldName]..")")
		isMatch = isMatch and wowCron.TableHasKey( parsed[i], ts[fieldName] )
--		print(isMatch)
	end

	return isMatch, parsed[6]

--[[

	for k,v in pairs( wowCron.fieldNames ) do
		print(k.."::"..v.."("..ts[v]..")")
		for kk,vv in pairs( parsed[k] ) do
			print("\t"..kk..":"..vv)
		end
	end
]]
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
			out[v] = 1
		end
	end
	return out
end

function wowCron.ParseAll()
	-- Only when starting, or changing
	wowCron.events = {}
	for _, cmd in ipairs(cron_global) do
		wowCron.events[cmd] = 0
		--wowCron.Parse( cmd )
	end
	-- player specific override global
	for _, cmd in ipairs(cron_player) do
		wowCron.events[cmd] = 0
		--wowCron.Parse( cmd )
	end

end
function wowCron.Parse( cron )
	-- takes the cron string and returns the 5 cron patterns, and the command
	local min, hour, day, month, wday, cmd =
			strmatch( cron,	"^(%S+)%s*(%S+)%s*(%S+)%s*(%S+)%s*(%S+)%s*(.*)$" )
	return min, hour, day, month, wday, cmd
end

--[[
function wowCron.CalculatePossibleValues( field, inValue )
	local minValue
end
]]

--[[
if msg then
		local i,c = strmatch(msg, "^(|c.*|r)%s*(%d*)$")
		if i then  -- i is an item, c is a count or nil
			return i, c
		else  -- Not a valid item link
			msg = string.lower(msg)
			local a,b,c = strfind(msg, "(%S+)")  --contiguous string of non-space characters
			if a then
				-- c is the matched string, strsub is everything after that, skipping the space
				return c, strsub(msg, b+2)
			else
				return ""
			end
		end
	end
end
]]


function wowCron.Command( msg )
	wowCron.Parse( msg )
end
function wowCron.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = WOWCRON_MSG_ADDONNAME.."> "..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end

