# Features

## At
Add the /at command.
[AT man page:](https://www.computerhope.com/unix/uat.htm)

/at [global] <cmd>
/at 9:30 PM Tue

Let's assume the current time is 10:00 AM, Tuesday, October 18, 2014.

noon                 12:00 PM October 18 2014
midnight             12:00 AM October 19 2014
teatime              4:00 PM October 18 2014
tomorrow             10:00 AM October 19 2014
noon tomorrow        12:00 PM October 19 2014
next week            10:00 AM October 25 2014
next monday          10:00 AM October 24 2014
Fri                  10:00 AM October 21 2014
NOV                  10:00 AM November 18 2014
9:00 AM              9:00 AM October 19 2014
2:30 PM              2:30 PM October 18 2014
1430                 2:30 PM October 18 2014
2:30 PM tomorrow     2:30 PM October 19 2014
2:30 PM next month   2:30 PM November 18 2014
2:30 PM Fri          2:30 PM October 21 2014
2:30 PM 10/21        2:30 PM October 21 2014
2:30 PM Oct 21       2:30 PM October 21 2014
2:30 PM 10/21/2014   2:30 PM October 21 2014
2:30 PM 21.10.14     2:30 PM October 21 2014
now + 30 minutes     10:30 AM October 18 2014
now + 1 hour         11:00 AM October 18 2014
now + 2 days         10:00 AM October 20 2014
4 PM + 2 days        4:00 PM October 20 2014
now + 3 weeks        10:00 AM November 8 2014
now + 4 months       10:00 AM February 18 2015
now + 5 years        10:00 AM October 18 2019

 You can also say what day the job will be run, by giving a date in the form month-name day with an optional year, or giving a date of the form MMDD[CC]YY, MM/DD/[CC]YY, DD.MM.[CC]YY or [CC]YY-MM-DD.


/atq
Will show a list of at commands.

date( "*t" )
year  a full year
month 01-12
day   01-31
hour  00-23
min   00-59
sec   00-59
isdst a boolean, true if daylight saving

This is a short version of the linux AT command.

Since WoWCron supports a global and a 'local' list, so shall AT.
Save in at_global and at_player.
Save as { [ts] = { "command", "command"}, }

AT commands are saved.
Character level AT commands are only carried out for that character, if logged in at the time, not for any others.
Global level AT commands are carried out for any character logged in at the time.

Note on parsing:



"* * * * * /run wowCron.Print(date(\"%H:%M\"))", -- [12]

## Icon

Possible other icon:
https://static.wikia.nocookie.net/wowwiki/images/7/7f/Inv_misc_pocketwatch_01.png/revision/latest?cb=20061018134647

## memoryLeak

Had a horrible usage of memory.
Using ```date( "*t" )``` is NOT something to do in the OnUpdate method.
This creates a new table everytime, and it takes a while for the built-in GC to recover this.

I don't see a way to pass an already existing table to ```date( "*t" )```, but I do see that ```date( "%S" )``` does what I'm looking for.

## coroutine

Create a FIFO, process the FIFO as a coroutine

local function someCalculation()
   local output = ""
   for i = 1, 50 do
      output = output .. "."
      if i % 10 == 0 then
         print(output .. i)
         output = ""
         coroutine.yield()
      end
   end
end

-- Create a coroutine to run that function
local thread = coroutine.create(someCalculation)

-- Create a frame that will periodically (OnUpdate) resume the
-- coroutine.
local frame = CreateFrame("Frame")
local counter = 0
local throttle = 0.5
frame:SetScript("OnUpdate", function(self, elapsed)
      counter = counter + elapsed
      if counter >= throttle then
         counter = counter - throttle
         if coroutine.status(thread) ~= "dead" then
            coroutine.resume(thread)
         end
      end
end)

