# Features

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

