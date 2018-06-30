# Features

"* * * * * /run wowCron.Print(date(\"%H:%M\"))", -- [12]

## validate

Run a validation on new entries.
Report:
   * when the next run will be, or error
   * scan the command, check for:
      * Properly formatted cron string
      * /run command (nothing else parsed)
      * valid slash command ( search emotes and slash commands and chat channels )

Validate new commands

What should a failed entry do?
   * Simply report?
      * "* * * * /s Bleh" - invalid crontab format
      * "* * * * * /s Bleh" - "  valid - <next time>"
      * "* * * * * /yuus" - invalid /command
   * build a report
      * report = {
            ["global"] = {
                  [1] = { ["valid"] = nil, ["msg"] = "bad crontab format" },
                  [2] = { ["valid"] = true, ["msg"] = "Next run at: <next time>" },
                  [3] = { ["valid"] = nil, ["msg"] = "bad command" }
            },
            ["player"] = { }
         }
      * print the report

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

