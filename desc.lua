return [[**!#mutuals**
Usage example: ``!#mutuals -s(2) -l(58703855...........) -k2 -f(>0) -f(<25)``
All arguments are optional, and can be placed in any order.
*Global scope searches every server Mutuals Finder is in and returns your mutual members between servers.
Server scope searches for mutuals members shared specifically with the server the command is executed on.
      Server can be specified with -l(server id) if you're using direct messages / a different server.
Key option sorts how the information is presented to you, by default it's what guilds mutuals are in.
      -c(Num) defines minimum of how many guilds you have to share with a member for them to display, key 2 only.
Filter specifies how many values there has to be per key to display it to you, may be specified twice.*
Arguments:
``-h`` Displays this menu (Hello!). Overrides other arguments.
``-s(1 or 2)`` Scope option. 1: Global, 2: Server | Default 1. //not yet implemented
``-l(server id)`` Overwrite server usage location. For server scope. //not yet implemented
``-k(1 or 2)`` Key option. 1: Person. 2: Guilds. | Default 1
``-c(Num)`` Minimum count option, k(2) only. Num can be any integer 0 and above. | Default 2
``-f(>Num or <Num)`` Filter option. Num can be any integer 0 and above | Default >1 //not yet implemented
]]