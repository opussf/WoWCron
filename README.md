[![Build Status](https://travis-ci.org/opussf/WoWCron.svg?branch=master)](https://travis-ci.org/opussf/WoWCron)

# WoW Cron

Have you ever wanted to have World of Warcraft do an action on a regular schedule?
Call an addon, sort your bags, have an emote run on a schedule (Role Play potential right there).
Maybe even do it once everytime you login (or reload).

Now the power of cron is in your hands, and in WoW.

## What it can do

This addon lets you use the power of cron to call any installed addon, perform an emote, or run something like a macro.

A simple cron string like ```* * * * * /joke``` will have your character do the joke emote every minute.

### Brief into to cron

For a full introduction to cron, do a search and read some of the great information out there.
The important bit of information, for this document is that cron defines 6 fields that describe a pattern to match against time to see if a command should be run that minute.
The 6 fields of cron are space delimted and are, in order:
* min
* hour
* month
* day
* day of week (0 = Sunday)
* command

The fields are normally numeric, some implementations support 3 letter abbriviations for month and day of week.
This does not yet.

There are a few macros for cron, normally starting with the '@' character.
```@hourly```, ```@midnight```, ```@first``` are the only macros currently supported.
```@first``` will only run the very first time.

### Allowed commands

The allowed commands can be any of the following:
* Any slash command for any currently installed addon. It should queitly fail if the addon is not installed for your current character.
* Any emote. Note that the emote aliases are not currently supported. (/joke works but not /silly)
* Running some Lua code directly.  Use ```/run``` or ```/script``` as the start of the command to identify code to run.

### Examples
* ```0,15,30,45 * * * * /train``` does the train macro on the quarter hour marks.
* ```*/2 * * * * /run SortBags()``` calls the SortBags() function every 2 minutes.
* ```@first /ineed list``` runs the ineed addon with the list command.

### Commands
To keep it simple, there are only a few commands.
