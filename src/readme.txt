* * * * * <command>
^ ^ ^ ^ ^
| | | | + - day of week (0 - 6) (Sunday = 0)
| | | + --- month (1 - 12)
| | + ----- day of month (1 - 31)
| + ------- hour (0 - 23)
+ --------- minute (0 - 59)



----
http://www.lua.org/pil/22.1.html

    temp = os.date("*t", 906000490)

produces the table
    {year = 1998, month = 9, day = 16, yday = 259, wday = 4,
     hour = 23, min = 48, sec = 10, isdst = false}



----

wowCron.nextEvent = TS of next event
wowCron.events[TS] is a list of events to run