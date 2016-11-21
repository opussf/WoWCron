#!/usr/bin/env lua

addonData = { ["version"] = "1.0",
}

require "wowTest"

test.outFileName = "testOut.xml"

wowCron_Frame = CreateFrame()

-- require the file to test
package.path = "../src/?.lua;'" .. package.path
require "wowcron"
--require "INEEDOptions"

function test.before()
	cron_player = {"* * * * * /in item:54233 7" }
	cron_global = {
		"* 0 * * * /happy",
		"*/30 * * * * /cry",
		"* 0,12 * * * /giggle",
		"* * 1,15 * * /dance",
		"0 * * * * /cheer"
	}
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
function test.testADDON_LOADED_buildsEventsTable()
	-- this should already be loaded
	size = 0
	for k,v in pairs( wowCron.events ) do
		size = size + 1
	end
	assertEquals( 6, size )
	--assertEquals( 0, wowCron.events["* * * * * /in item:54233 7"] )
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
function test.testBuildFirstCronMacro_expands()
	wowCron.started = time({["year"] = 2016, ["month"] = 5, ["day"] = 25, ["hour"] = 0, ["min"] = 0, ["sec"] = 0})
	cron = wowCron.BuildFirstCronMacro()
	assertEquals( "1 0 25 5 *", cron )
end
function test.testBuildFirstCronMacro_added()
	found = false
	for k,v in pairs(wowCron.macros) do
		found = found or (k == "@first")
	end
	assertTrue( found, "@first should be auto generated and added to the macro list." )
end
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
function test.testCmd_spaceStrip()
	cmd, parameters = wowCron.DeconstructCmd( "/hello  There is an extra space here." )
	assertEquals( "There is an extra space here.", parameters )
end
function test.testBuildRunNowList_CreatesEntries()
	wowCron.Command("* * * * * /cron list")
	wowCron.BuildRunNowList()
	assertEquals( 2, #wowCron.toRun )
end
function test.testRunNowList_runsOnEmptyList()
	assertEquals( 0, #wowCron.toRun )  -- start with it empty.  Make sure of this
	wowCron.RunNowList()
end
function test.testOnUpdate_runOne()
	wowCron.Command("* * * * * /cron list")
	wowCron.BuildRunNowList()
	wowCron.OnUpdate()
	assertEquals( 1, #wowCron.toRun ) -- one should be left
end
function test.testOnUpdate_runTwo()
	wowCron.Command("* * * * * /cron list")
	wowCron.BuildRunNowList()
	wowCron.OnUpdate()
	assertEquals( 1, #wowCron.toRun ) -- one should be left
	wowCron.OnUpdate()
	assertEquals( 0, #wowCron.toRun ) -- none left
end


test.run()
