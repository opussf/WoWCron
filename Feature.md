# Features

"* * * * * /run wowCron.Print(date(\"%H:%M\"))", -- [12]

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

