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
	nextMin = wowCron.lastUpdated+(60-(wowCron.lastUpdated%60))  -- compute the TS of the next top of the minute
end
function test.after()
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
	assertEquals( 0, wowCron.events["* * * * * /in item:54233 7"] )
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
	for i = 0,7 do
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
function test.testRunNow_onMinute5_yes()
	local ts = 1401055500  -- Sunday 15:05
	print( time() )
	print( time() % 60 )
	local run, cmd = wowCron.RunNow( "*/5 * * * * /hello", ts )
	assertTrue( run, "This should be true" )
end
function test.testRunNow_onMinute5_no()
	local ts = 1401054240  -- Sunday 14:44
	print( time() )
	print( time() % 60 )
	local run, cmd = wowCron.RunNow( "*/5 * * * * /hello", ts )
	assertIsNil( run, "This should be nil" )
end




--[[

function test.testParseSets_nextEvent()
	wowCron.Command( "* * * * * /openfire" )
	assertEquals( nextMin, wowCron.nextEvent, "nextEvent should be the TS of the next top of the minute")
end
function test.testParseSets_events_event()
	wowCron.Command( "* * * * * /openfire" )
	assertEquals( "/openfire", wowCron.events[nextMin][1].event, "The event field should be set")
end
function test.testParseSets_events_fullEvent()
	wowCron.Command( "* * * * * /openfire" )
	assertEquals( "* * * * * /openfire", wowCron.events[nextMin][1].fullEvent )
end

]]

test.run()
