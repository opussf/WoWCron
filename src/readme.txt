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
    {year = 1998, month = 9, day = 16, yday = 259, wday = 4,   (1 = Sunday)
     hour = 23, min = 48, sec = 10, isdst = false}


----

wowCron.nextEvent = TS of next event
wowCron.events[TS] is a list of events to run


----

/console scriptErrors 1

----


"@reboot"  : '',  # is this valid for this class?
"@hourly"  : '0 * * * *',
"@daily"   : '0 0 * * *',
"@midnight": '0 0 * * *',
"@weekly"  : '0 0 * * 0',
"@monthly" : '0 0 1 * *',
"@yearly"  : '0 0 1 1 *',
"@annually": '0 0 1 1 *',