-- This message is actually starting to near the message limit of discord.

return [[**!#mutuals**
Usage example: ``!#mutuals -s(2) -l(58703855-----------) -k(2) -f(>0) -f(<25) -bl(175060-----------,58667634-----------)``
All arguments are optional, can be placed in any order, and are not case sensitive. 

*Global scope searches every server Mutuals Finder is in and returns your mutual members between servers.
Server scope searches for mutual members shared specifically with the server the command is executed on.
      Server can be specified with -l(ServerID) if you're using direct messages / a different server.
Key option changes key of the presented message. Key1 - Mutuals: Guild, Guild, ... | Key2 - Guild: Mutual, Mutuals, ... 
      -c(Num) defines minimum of how many guilds you have to share with a member for them to display, key 2 only.
Filter specifies how many values there has to be per key to display it to you. May be specified twice.
Whitelist and Blacklist filters what users may be shown. You may have any amount of users specied, seperated between commas.
If additional support needed, message %s.*
**Arguments:**
``-h`` Sends this menu to the user (Hello!). Overrides other arguments.
``-s(2)`` Scope option. 1: Global, 2: Server | Default 1
``-l(ServerID)`` Overwrite server usage location. For server scope.
``-k(2)`` Key option. 1: Person. 2: Guilds. | Default 1
``-c(Num)`` Minimum count option, k(2) only. Num can be any number 0 and above. | Default 2
``-f(>Num)`` Filter option. Num can be any number 0 and above | Default >1
``-f(<Num)`` Filter option. Num can be any number 0 and above | Default <10000
``-wl(UserID,...)`` Whitelist option. Only shows specified users. Overrides blacklist. //not yet implemented
``-bl(UserID,...)`` Blacklist option. Filters out specified users. //not yet implemented
]]