#!/usr/bin/env lua

require "wowTest"

test.outFileName = "testOut.xml"

wowCron_Frame = CreateFrame()

-- require the file to test
ParseTOC( "../src/wowcron.toc" )

function test.before()
	cron_player = {"* * * * * /in item:54233 7" }
	cron_global = {
		"* 0 * * * /happy",
		"*/30 * * * * /cry",
		"* 0,12 * * * /giggle",
		"* * 1,15 * * /dance",
		"0 * * * * /cheer"
	}
	at_player = {}
	at_global = {}
	wowCron.events = {}
	wowCron.OnLoad()
	wowCron.ADDON_LOADED()
	wowCron.PLAYER_ENTERING_WORLD()
	nextMin = wowCron.lastUpdated+(60-(wowCron.lastUpdated%60))  -- compute the TS of the next top of the minute
end
function test.after()
	wowCron.toRun = {}
end
function test.validValues( expected, actual )
	-- takes 2 tables [val] = 1 and compares them
	for i in pairs( expected ) do
		assertTrue( actual[i] )
	end
	for i in pairs( actual ) do
		assertTrue( expected[i] )
	end
end
function test.testADDON_LOADED_buildsCronsTable()
	-- this should already be loaded
	size = 0
	for k,v in pairs( wowCron.crons ) do
		size = size + 1
	end
	assertEquals( 6, size )
	--assertEquals( 0, wowCron.crons["* * * * * /in item:54233 7"] )
end
function test.testExpand_minute_all()
	local expectedValues = {}
	for i = 0,59 do
		expectedValues[i] = 1
	end
	local expandedMin = wowCron.Expand( "*", "min" )
	test.validValues( expectedValues, expandedMin )
end
function test.testExpand_minute_singleValue()
	local expectedValues = { [7]=1 }
	local expandedMin = wowCron.Expand( "7", "min" )
end
function test.testExpand_hour_all()
	local expectedValues = {}
	for i = 0,23 do
		expectedValues[i] = 1
	end
	local expandedHour = wowCron.Expand( "*", "hour" )
	test.validValues( expectedValues, expandedHour )
end
function test.testExpand_month_all()
	local expectedValues = {}
	for i = 1,12 do
		expectedValues[i] = 1
	end
	local expandedMonth = wowCron.Expand( "*", "month" )
	test.validValues( expectedValues, expandedMonth )
end
function test.testExpand_day_all()
	local expectedValues = {}
	for i = 1,31 do
		expectedValues[i] = 1
	end
	local expandedDay = wowCron.Expand( "*", "day" )
	test.validValues( expectedValues, expandedDay )
end
function test.testExpand_wday_all()
	local expectedValues = {}
	for i = 1,8 do  -- adjusted for Lua's date wday (1 = Sunday)
		expectedValues[i] = 1
	end
	local expandedWDAY = wowCron.Expand( "*", "wday" )
	test.validValues( expectedValues, expandedWDAY )
end
function test.testParse()
	vals = { wowCron.Parse("* * * * * cmd") }
	assertEquals( "*", vals[1] )
	assertEquals( "*", vals[2] )
	assertEquals( "*", vals[3] )
	assertEquals( "*", vals[4] )
	assertEquals( "*", vals[5] )
	assertEquals( "cmd", vals[6] )
end
function test.testExpand_hour_range()
	local expectedValues = {}
	for i = 0,12 do
		expectedValues[i] = 1
	end
	local expandedHour = wowCron.Expand( "0-12", "hour" )
	test.validValues( expectedValues, expandedHour )
end
function test.testExpand_hour_2values()
	local expectedValues = {}
	expectedValues[6] = 1
	expectedValues[12] = 1
	local expandedHour = wowCron.Expand( "6,12", "hour" )
	test.validValues( expectedValues, expandedHour )
end
function test.testExpand_hour_3values()
	local expectedValues = {}
	expectedValues[6] = 1
	expectedValues[12] = 1
	expectedValues[18] = 1
	local expandedHour = wowCron.Expand( "6,12,18", "hour" )
	test.validValues( expectedValues, expandedHour )
end
function test.testExpand_hour_step()
	local expectedValues = {}
	expectedValues[0] = 1
	expectedValues[6] = 1
	expectedValues[12] = 1
	expectedValues[18] = 1
	local expandedHour = wowCron.Expand( "*/6", "hour" )
	test.validValues( expectedValues, expandedHour )
end
function test.testExpand_hour_rangeWithStep()
	local expectedValues = {}
	expectedValues[0] = 1
	expectedValues[6] = 1
	expectedValues[12] = 1
	expectedValues[18] = 1
	local expandedHour = wowCron.Expand( "0-18/6", "hour" )
	test.validValues( expectedValues, expandedHour )
end
function test.testExpand_hour_2values_rangeWStep()
	local expectedValues = {}
	expectedValues[0] = 1
	expectedValues[3] = 1
	expectedValues[6] = 1
	expectedValues[12] = 1
	expectedValues[18] = 1
	local expandedHour = wowCron.Expand( "0-6/3,6-18/6", "hour" )
	test.validValues( expectedValues, expandedHour )
end
function test.testExpand_hour_2values_wildWStep()
	local expectedValues = {}
	expectedValues[0] = 1
	expectedValues[5] = 1
	expectedValues[10] = 1
	expectedValues[12] = 1
	expectedValues[15] = 1
	expectedValues[20] = 1
	local expandedHour = wowCron.Expand( "*/12,*/5", "hour" )
	test.validValues( expectedValues, expandedHour )
end
function test.testExpand_hour_outOfRange_single()
	--expectedValues = {}
	local expandedHour = wowCron.Expand( "25", "hour")
	assertIsNil( expandedHour[25] )
end
function test.testRunNow_onMinute_yes()
	local ts = 1401054240 -- Sunday 14:44
	local run, cmd = wowCron.RunNow( "* * * * * /hello", ts )
	assertTrue( run, "This should be true" )
end
function test.testRunNow_returns_cmd()
	local ts = 1401054240 -- Sunday 14:44
	local run, cmd = wowCron.RunNow( "* * * * * /hello", ts )
	assertEquals( "/hello", cmd )
end
function test.testRunNow_returns_cmdParameters()
	local ts = 1401054240 -- Sunday 14:44
	local run, cmd = wowCron.RunNow( "* * * * * /say Hello", ts )
	assertEquals( "/say Hello", cmd )
end
function test.testRunNow_onMinute5_yes()
	local ts = 1401055500  -- Sunday 15:05
	local run, cmd = wowCron.RunNow( "*/5 * * * * /hello", ts )
	assertTrue( run, "This should be true" )
end
function test.testRunNow_onMinute5_no()
	local ts = 1401054240  -- Sunday 14:44
	local run, cmd = wowCron.RunNow( "*/5 * * * * /hello", ts )
	assertIsNil( run, "This should be nil" )
end
function test.testRunNow_onSunday_yes()
	local ts = 1401054240  -- Sunday 14:44
	local run, cmd = wowCron.RunNow( "* * * * 0 /hello", ts )
	assertTrue( run, "This should be true" )
end
function test.testRunNow_onSunday_no()
	local ts = 1401054240  -- Sunday 14:44
	local run, cmd = wowCron.RunNow( "* * * * 1-6 /hello", ts )
	assertIsNil( run, "This should be nil" )
end
function test.testRunNow_noCmd()
	local ts = 1401054240 -- Sunday 14:44
	local run, cmd = wowCron.RunNow( "* * * * * ", ts )
	assertEquals( "", cmd )
end
function test.testRunNow_noCmd_noTrailingSpace()
	local ts = 1401054240 -- Sunday 14:44
	local run, cmd = wowCron.RunNow( "* * * * *", ts )
	assertIsNil( run, "This should be nil" )
end
function test.testRunNow_macro_hourly()
	local ts = 1401055200 -- Sunday 15:00
	local run, cmd = wowCron.RunNow( "@hourly /hello", ts )
	assertTrue( run, "This should be true" )
end
function test.testRunNow_macro_midnight()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "@midnight /hello it is @midnight.", ts )
	assertTrue( run, "This should be true" )
end
function test.testRunNow_explicit_midnight()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "0 0 * * * /hello it is 0 0", ts )
	assertTrue( run, "This should be true" )
end
function test.testRunNow_day_yes()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * 25 * * /hello it is the 25th", ts )
	assertTrue( run, "This should be true" )
end
function test.testRunNow_day_no()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * 5 * * /hello it is the 5th", ts )
	assertIsNil( run, "This should not run" )
end
function test.testRunNow_month_yes()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * * 5 * /hello it is May.", ts )
	assertTrue( run, "This should be true" )
end
function test.testRunNow_month_no()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * * 6 * /hello it is June.", ts )
	assertIsNil( run, "This should not run" )
end
function test.testRunNow_minHourDayMonth_yes()
	ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 1, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "1 0 25 5 * /hello it is 00:01 May 25.", ts )
	assertTrue( run, "This should be true" )
end
function test.testRunNow_minHourDayMonth_no()
	ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 1, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "2 0 25 5 * /hello it is 00:02 May 25.", ts )
	assertIsNil( run, "This should not run" )
end
-- function test.testBuildFirstCronMacro_expands()
-- 	wowCron.started = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
-- 	cron = wowCron.BuildFirstCronMacro()
-- 	assertEquals( "1 0 25 5 *", cron )
-- end
-- function test.testBuildFirstCronMacro_added()
-- 	found = false
-- 	for k,v in pairs(wowCron.macros) do
-- 		found = found or (k == "@first")
-- 	end
-- 	assertTrue( found, "@first should be auto generated and added to the macro list." )
-- end
function test.testCmd_global_flag()
	wowCron.Command("global")
	assertTrue( wowCron.global )
end
function test.testCmd_global_list()
	wowCron.Command("global list")
end
function test.testCmd_player_list()
	wowCron.Command("list")
end
function test.testCmd_global_rm()
	wowCron.Command("global rm 1")
	assertEquals( "*/30 * * * * /cry", cron_global[1] )
end
function test.testCmd_player_rm()
	wowCron.Command("rm 1")
	assertEquals( 0, #cron_player )
end
function test.testCmd_global_add_default()
	wowCron.Command("global * * * * * /cron list")
	assertEquals( "* * * * * /cron list", cron_global[6] )
end
function test.testCmd_player_add_default()
	wowCron.Command("* * * * * /cron list")
	assertEquals( "* * * * * /cron list", cron_player[2] )
end
function test.testCmd_global_add_explicit()
	wowCron.Command("global add * * * * * /cron list")
	assertEquals( "* * * * * /cron list", cron_global[6] )
end
function test.testCmd_player_add_explicit()
	wowCron.Command("add * * * * * /cron list")
	assertEquals( "* * * * * /cron list", cron_player[2] )
end
function test.testChatMsg_s()
	local ts = 1401054240  -- Sunday 14:44
	assertTrue( wowCron.SendMessage( "/s", "Hello all." ) )
end
function test.testChatMsg_say()
	local ts = 1401054240  -- Sunday 14:44
	assertTrue( wowCron.SendMessage( "/SAY", "Hello all." ) )
end
function test.testChatMsg_g()
	local ts = 1401054240  -- Sunday 14:44
	assertTrue( wowCron.SendMessage( "/G", "Hello all." ) )
end
function test.testMacro_unkownMacro()
	local ts = 1401055200 -- Sunday 15:00
	local run, cmd = wowCron.RunNow( "@hurly /hello there mortal one. What is up?", ts )
	assertIsNil( run, "This should be nil" )
end
function test.notest_Macro_First()
	wowCron.Command("add @first /say hello")
	wowCron.Command("add @first /g hello guild")
	wowCron.hasFirstBeenRun = nil
	wowCron.lastUpdated = 0
	wowCron.BuildRunNowList()
	wowCron.OnUpdate()
	wowCron.LOADING_SCREEN_DISABLED()
	--print( "num in toRun: "..#wowCron.toRun )
	assertTrue( wowCron.hasFirstBeenRun )
	assertIsNil( wowCron_Frame.Events["LOADING_SCREEN_DISABLED"], "LOADING_SCREEN_DISABLED should not be a registerd event anymore." )
	wowCron.OnUpdate()
	wowCron.OnUpdate()
	wowCron.OnUpdate()
	assertEquals( 0, #wowCron.toRun, "toRun list should be empty by now." )
end
function test.test_Macro_Gold()
	wowCron.toRun = {}
	wowCron.Command("add @gold /snap")
	wowCron.BuildRunNowList()
	assertTrue( wowCron.PLAYER_MONEY, "PLAYER_MONEY event function should exist" )
	assertTrue( wowCron_Frame.Events["PLAYER_MONEY"], "PLAYER_MONEY should be a registerd event" )
	wowCron.PLAYER_MONEY()
	foundInToRun = false
	for _, v in pairs( wowCron.toRun ) do
		if v == "/snap" then foundInToRun = true
		end
	end
	assertTrue( foundInToRun, "/snap should be found in the list of events to do." )
end
function test.testMonthNameExpansion_oneMonth_yes()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * * may * /hello it is in May.", ts )
	assertTrue( run, "This should run." )
end
function test.testMonthNameExpansion_oneMonth_no()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * * jun * /hello it is in June.", ts )
	assertIsNil( run, "This should not run" )
end
function test.testMonthNameExpansion_twoMonths_yes()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * * apr,may * /hello it is in May.", ts )
	assertTrue( run, "This should run." )
end
function test.testMonthNameExpansion_twoMonths_no()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * * jun,jul * /hello it is in June or July.", ts )
	assertIsNil( run, "This should not run" )
end
function test.testMonthNameExpansion_twoMonthsRange_yes()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * * apr-jun * /hello it is in Apr-Jun.", ts )
	assertTrue( run, "This should run." )
end
function test.testMonthNameExpansion_twoMonthsRange_no()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * * jan-apr * /hello it is in jan-apr.", ts )
	assertIsNil( run, "This should not run" )
end
function test.testMonthNameExpansion_twoMonths_error01()
	local ts = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	local run, cmd = wowCron.RunNow( "* * * febfeb * /hello it is in febfeb.", ts )
	assertIsNil( run, "This should not run" )
end
function test.testCmd_spaceStrip()
	cmd, parameters = wowCron.DeconstructCmd( "/hello  There is an extra space here." )
	assertEquals( "There is an extra space here.", parameters )
end
function test.notestBuildRunNowList_CreatesEntries()
	cron_player = {"* * * * * /in item:54233 7" }
	cron_global = {}
	wowCron.Command("* * * * * /cron list")
	wowCron.BuildRunNowList()
	assertEquals( 2, #wowCron.toRun )
end
-- function test.testRunNowList_runsOnEmptyList()
-- 	assertEquals( 0, #wowCron.toRun )  -- start with it empty.  Make sure of this
-- 	wowCron.RunNowList()
-- end
function test.notestOnUpdate_runOne()
	print("=-=-=-=-=-")
	cron_player = {"* * * * * /in item:54233 7" }
	cron_global = {}

	wowCron.Command("* * * * * /cron list")
	wowCron.BuildRunNowList()
	for k, v in pairs( wowCron.toRun ) do
		print( k, v )
	end

	wowCron.OnUpdate()
	for k, v in pairs( wowCron.toRun ) do
		print( k, v )
	end

	assertEquals( 1, #wowCron.toRun ) -- one should be left
end
function test.notestOnUpdate_runTwo()
	cron_player = {"* * * * * /in item:54233 7" }
	cron_global = {}
	wowCron.Command("* * * * * /cron list")
	for k, v in pairs( wowCron.toRun ) do
		print( k, v )
	end
	wowCron.BuildRunNowList()
	for k, v in pairs( wowCron.toRun ) do
		print( k, v )
	end
	wowCron.OnUpdate()
	assertEquals( 1, #wowCron.toRun ) -- one should be left
	wowCron.OnUpdate()
	assertEquals( 0, #wowCron.toRun ) -- none left
end
function test.testPlayerCronsAreLast()
	assertEquals( "* * * * * /in item:54233 7", wowCron.crons[6])
end
function test.testLongTest()
	-- run a bunch of things
	--
	cron_player = { "@first /g hello all" }
	wowCron.events = {}
	wowCron.eventCmds = {}
	wowCron.OnLoad()
	wowCron.ADDON_LOADED()
	wowCron.OnUpdate()
	wowCron.PLAYER_ENTERING_WORLD()
	wowCron.OnUpdate()
	wowCron.OnUpdate()
	wowCron.LOADING_SCREEN_DISABLED()
	wowCron.OnUpdate()
	wowCron.OnUpdate()
	wowCron.OnUpdate()
	wowCron.OnUpdate()
	wowCron.OnUpdate()
end
function test.testEventMacro_Add_CreatesFunction()
	wowCron.PLAYER_MONEY = nil
	wowCron.Command("@gold /snap")
	wowCron.ParseAll()
	wowCron.BuildRunNowList()
	assertTrue( wowCron.PLAYER_MONEY )
	wowCron.PLAYER_MONEY()
end
function test.testEventMacro_Add_RegistersEvent()
	wowCron_Frame.Events = {}
	wowCron.PLAYER_MONEY = nil
	wowCron.Command("@gold /snap")
	wowCron.BuildRunNowList()
	assertTrue( wowCron_Frame.Events.PLAYER_MONEY )
end
function test.testEventMacro_Remove_RemovesCommandFromEventCommands()
	wowCron.PLAYER_MONEY = nil
	wowCron.toRun = {}
	wowCron.Command("@gold /fart")
	wowCron.Command("@gold /rested gold")
	print("PLAYER_MONEY list")
	wowCron.BuildRunNowList()
	wowCron.PLAYER_MONEY()

end
----------
-- AT
----------
function test.buildTestTimeStrings()
	-- %p (am/pm)   -- fun trivia,  +1 day +1 hour = +90000 seconds
	target = date( "*t", time()+86400 )  -- +1 day
	target.sec = 0
	out = {}
	--print( date( "Test time: %x %X", time(target) ) )
	out.date6 = date( "%m%d%y", time(target) )
	out.date8 = date( "%m%d%Y", time(target) )
	out.date2_slash = date( "%m/%d/%y", time(target) )
	out.date4_slash = date( "%m/%d/%Y", time(target) )
	out.date2_dot = date( "%d.%m.%y", time(target) )
	out.date4_dot = date( "%d.%m.%Y", time(target) )
	out.tomorrowTS = time(target)
	target.hour = 12
	target.min = 0
	out.tomorrowNoonTS = time(target)

	target = date( "*t", time()+3600 ) -- +1 hour
	target.sec = 0
	out.plushour5 = date( "%H:%M", time(target) )
	out.plushour4 = date( "%H%M", time(target) )
	out.plushourTS = time(target)

	target = date( "*t", time() )
	target.sec = 0
	out.nowTS = time(target)

	target = date( "*t", time()+300 )
	target.sec = 0
	out.plus5minTS = time(target)

	return out
end

function test.testAT_hasCommand()
	wowCron.AtCommand( "" )
end
function test.testAT_tomorrow_date6()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( dateTable.date6.." /wave" )
	assertTrue( at_player[dateTable.tomorrowTS] )
	assertEquals( "/wave", at_player[targetTS][1] )
end
function test.testAT_tomorrow_date8()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( dateTable.date8.." /wave" )
	assertTrue( at_player[dateTable.tomorrowTS] )
	assertEquals( "/wave", at_player[targetTS][1] )
end
function test.testAT_tomorrow_date2_slash()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( dateTable.date2_slash.." /wave" )
	assertTrue( at_player[dateTable.tomorrowTS] )
	assertEquals( "/wave", at_player[targetTS][1] )
end
function test.testAT_tomorrow_date4_slash()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( dateTable.date4_slash.." /wave" )
	assertTrue( at_player[dateTable.tomorrowTS] )
	assertEquals( "/wave", at_player[targetTS][1] )
end
function test.testAT_tomorrow_date2_dot()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( dateTable.date2_dot.." /wave" )
	assertTrue( at_player[dateTable.tomorrowTS] )
	assertEquals( "/wave", at_player[targetTS][1] )
end
function test.testAT_tomorrow_date4_dot()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( dateTable.date4_dot.." /wave" )
	assertTrue( at_player[dateTable.tomorrowTS] )
	assertEquals( "/wave", at_player[targetTS][1] )
end
function test.testAT_plushour5()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( dateTable.plushour5.." /hi" )
	assertTrue( at_player[dateTable.plushourTS] )
end
function test.testAT_plushour4()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( dateTable.plushour4.." /cheer" )
	assertTrue( at_player[dateTable.plushourTS] )
end
function test.testAT_plushour5_long_command()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( dateTable.plushour5.." /mm dps" )
	assertEquals( "/mm dps", at_player[dateTable.plushourTS][1] )
end
function test.testAT_macro_now()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( "now /mm dps" )
	assertTrue( at_player[dateTable.nowTS] )
end
function test.testAT_macro_noon()
	wowCron.AtCommand( "noon /doit" )
end
function test.testAT_macro_tomorrow()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( "tomorrow /slash tomorrow" )
	assertTrue( at_player[dateTable.tomorrowTS] )
	assertEquals( "/slash tomorrow", at_player[dateTable.tomorrowTS][1] )
end
function test.testAT_macro_tomorrow_noon()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( "tomorrow noon /yes" )
	assertTrue( at_player[dateTable.tomorrowNoonTS] )
end
function test.testAT_now_plus5_min()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( "now +5 minutes /fart")
	assertTrue( at_player[dateTable.plus5minTS] )
end
function test.testAT_now_plus5_min_seperate()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( "now + 5 minutes /fart")
	assertTrue( at_player[dateTable.plus5minTS] )
end
function test.testAT_now_plus_error()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( "now + minutes /fart")
	assertTrue( at_player[dateTable.nowTS] )
end
function test.testAT_AddACommand_900PM()
	wowCron.AtCommand( "9:00 PM /snore" )
	target = date( "*t" )
	if( target.hour >= 21 ) then
		target = date( "*t", time()+86400 ) -- get tomorrow to reset time back to the desired target
	end
	target["hour"] = 21; target.min = 0; target.sec = 0;
	targetTS = time( target )
	--print( targetTS..">?"..time() )
	assertTrue( at_player[targetTS] )
	assertEquals( "/snore", at_player[targetTS][1] )
end
function test.testAT_AddACommand_900AM()
	wowCron.AtCommand( "9:00 AM /wave" )
	target = date( "*t" )
	if( target.hour >= 9 ) then
		target = date( "*t", time()+86400 ) -- get tomorrow to reset time back to the desired target
	end
	target.hour = 9; target.min = 0; target.sec = 0;
	targetTS = time( target )
	assertTrue( at_player[targetTS] )
	assertEquals( "/wave", at_player[targetTS][1] )
end
function test.testAT_Global_now()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( "global now /mm dps" )
	assertTrue( at_global[dateTable.nowTS] )
end
function test.testAT_at_player_adds_to_toRun()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( "now /now" )
	wowCron.BuildRunNowList()
	assertEquals( "/now", wowCron.toRun[3] )
	assertIsNil( at_player[dateTable.nowTS] )
end
function test.testAT_ListCommand()
	dateTable = test.buildTestTimeStrings()
	wowCron.AtCommand( "now /now" )
	wowCron.AtCommand( "now + 1 hours /later" )
	wowCron.AtCommand( "tomorrow /tomorrow" )
	wowCron.AtCommand( "list" )
end
function test.testAT_Oops()
	wowCron.AtCommand( "oops" )
end
--[[

function test.testAT_Date_Aug11()
	wowCron.AtCommand( "Aug 11 /hny" )
	target = date( "*t" )
	target.month = 8; target.day = 11; target.sec = 0;
	targetTS = time( target )
	assertTrue( at_player[targetTS] )
	assertEquals( "/hny", at_player[targetTS][1] )
end

--[[
function test.testAT_Date_081144()
	wowCron.AtCommand( "8/11/44 /future" )
	target = date( "*t" )
	target.month = 8; target.day = 11; target.year = 2044; target.sec = 0;
	targetTS = time( target )
	print(targetTS)
	for k,v in pairs(at_player) do
		print( k,v[1] )
	end
	assertTrue( at_player[targetTS], "Target TS does not exist." )
	assertEquals( "/future", at_player[targetTS][1] )
end
function test.testAT_Date_08112044()
	wowCron.AtCommand( "8/11/2044 /fullyear" )
	target = date( "*t" )
	target.month = 8; target.day = 11; target.year = 2044;
	targetTS = time( target )
	assertTrue( at_player[targetTS] )
	assertEquals( "/fullyear", at_player[targetTS][1] )
end

function test.testAT_Date_0811_2()
	wowCron.AtCommand( "11.08 /future" )
	target = date( "*t" )
	target.month = 8; target.day = 11; target.year = 2022;
	targetTS = time( target )
	assertTrue( at_player[targetTS] )
	assertEquals( "/future", at_player[targetTS][1] )
end
function test.testAT_Date_0811_2()
	wowCron.AtCommand( "11.08 /future" )
	target = date( "*t" )
	target.month = 8; target.day = 11; target.year = 2022;
	targetTS = time( target )
	assertTrue( at_player[targetTS] )
	assertEquals( "/future", at_player[targetTS][1] )
end
]]


test.run()
