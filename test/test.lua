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
	cron_player = {"* * * * * /in item:54233 7", "0 * * * * /cheer"}
	cron_global = {
		"* 0 * * * /happy",
		"*/30 * * * * /cry",
		"* 0,12 * * * /giggle",
		"* * 1,15 * * /dance",
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
function test.testExpand_dow_all()
	local expectedValues = {}
	for i = 0,7 do
		expectedValues[i] = 1
	end
	local expandedDOW = wowCron.Expand( "*", "dow" )
	test.validValues( expectedValues, expandedDOW )
end
--[[

function test.testRunNow_onMinute_yes()
	local ts = 1401054240 -- Sunday 14:44
	local run, cmd = wowCron.RunNow( "* * * * * /hello", ts )
	assertTrue( run, "This should be true" )
	assertEquals( cmd, "/hello" )
end
function test.testRunNow_onMinute5_yes()
	local ts = 1401055500  -- Sunday 15:05
	print( time() )
	print( time() % 60 )
	local run, cmd = wowCron.RunNow( "*/5 * * * * /hello", ts )
	assertTrue( run, "This should be true" )
	assertEquals( cmd, "/hello" )
end

]]
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
