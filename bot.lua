--[[
  Todo list of jazz (roughly in order):
  
  Code
    !#mutuals
      add whitelist and blacklist for users too
      Make it so that it yells at you if you do whacky bad argument stuff. trim white space next
      Make it so if gulid key has no values it doesnt show up, its a little unsighly
      check for if guilds are "large" ?

  Not Code:
    Advertise the bot a little.
      how do you advertise a discord bot
]]

local discordia = require('discordia')
local client = discordia.Client {
	logFile = 'bot.log',
  cacheAllMembers = true,
  syncGuilds = true,
}
local uv = require "uv"

local botVersion = "1.6b"
local ruirr = "175060396627984384"
local timeoutList = {}
local pingList = {}
local queuedPong = {}

function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

client:run("Bot " .. require "token") -- token.lua on client only

client:on("ready", function()
  print(string.format("Logged in as %s\n", client.user.username))
  client:setGame("!#mutuals -h or !#help")
end)

client:on("messageCreate", function(message)
  local ping = false
  local str = message.content:lower()

  if str:find("!#source") == 1 then
    message.channel:send("Source can be found at: https://github.com/SpikyPillow/Mutuals-Finder.")
  elseif str:find("!#help") == 1 then
    local help = require "help"
    message.channel:send("Messaging you the help info!")
    message.author:send(string.format(help, botVersion))
  elseif message.author.id == client.user.id and message.content == "Ping?" then  
    ping = true -- add to "queue"
    queuedPong[message.id] = message.channel
  elseif str:find("!#ping") == 1 then
    -- !#ping Command!
    ping = true
    local args = {}
    if str:match("-h") then
      message.channel:send("**!#ping**\nShows how much time it takes for the bot to send and recieve a message.\n``!#ping`` arguments: -h (shows the help menu)\nThat's it. What were you expecting...?")
    else
      local a = uv.now()
      pingList[message.channel:send("Ping?").id] = a
    end
  end
  -- "Queue" actions, edits "Ping?" message
  if ping then
    for i,v in pairs(pingList) do
      for a,b in pairs(queuedPong) do
        if a == i then
          table.remove(pingList, i)
          queuedPong[a]:getMessage(a):setContent("Pong! " .. (uv.now()-pingList[i])/1000 .. " seconds. (" .. (uv.now()-pingList[i]) .. "ms)")
          pingList[i] = nil
          queuedPong[a] = nil
        end
      end
    end
  end

  -- !#mutuals Command!
  if str:find("!#mutuals ") == 1 or str == "!#mutuals" then
    if str:match("-h") then
      local desc = require "desc"
      message.channel:send("Messaging you the help info!")
      message.author:send(string.format(desc, client:getUser("175060396627984384").tag))
    else
      local args = {}
        args.server = message.guild and message.guild.id
        if str:match("-k%(2%)") then
          args.key = true
          if str:find("-c%(") then
            local a,b = str:find("-c%(")
            local s = str:sub(b)
            local c = s:find(")")
            local s = s:sub(2, c-1)
            args.count = tonumber(s)
          end
          if args.count == nil or args.count < 0 then
            args.count = 2
          end
        end
        args.filter = {}
        if str:find("-f%(>") then
          local _,b = str:find("-f%(>")
          local s = str:sub(b)
          local c = s:find(")")
          local s = s:sub(2, c-1)
          
          args.filter[1] = tonumber(s)
        end
        if str:find("-f%(<") then
          local _,b = str:find("-f%(<")
          local s = str:sub(b)
          local c = s:find(")")
          local s = s:sub(2, c-1)
          
          args.filter[2] = tonumber(s)
        end
        if args.filter[1] == nil or args.filter[1] < 0 then
          args.filter[1] = 1
        end
        if args.filter[2] == nil or args.filter[2] < 0 then
          args.filter[2] = 10000
        end
        if str:find("-s%(2%)") then
          args.scope = true
          args.server = message.guild and message.guild.id
        end
        if str:find("-l%(") then
          local _,b = str:find("-l%(")
          local s = str:sub(b)
          local c = s:find(")")
          local s = s:sub(2, c-1)
          
          if tonumber(s) then
            args.server = s
          end
        end
        if args.server == nil then
          args.scope = nil
        end
        if str:find("-wl%(") then
          local _,b = str:find("-wl%(")
          local s = str:sub(b)
          local c = s:find(")")
          local s = s:sub(2, c-1)

          args.whitelist = split(s, ",") 
          for i,v in pairs (args.whitelist) do
            if tonumber(v) == nil then
              args.whitelist[i] = nil
            end
          end
        elseif str:find("-bl%(") then
          local _,b = str:find("-bl%(")
          local s = str:sub(b)
          local c = s:find(")")
          local s = s:sub(2, c-1)

          args.blacklist = split(s, ",") 
          for i,v in pairs (args.blacklist) do
            if tonumber(v) == nil then
              args.blacklist[i] = nil
            end
          end
        end

      local user = message.author.id
      local formatted = {}
      local count = {}
      
      local x = uv.now()
      local check = true
      for i,v in pairs(timeoutList) do
        if i == user and user ~= ruirr then
          if v > x then
            check = false
          else
            timeoutList[user] = nil
          end
        end
      end
      
      if check then
        local initMsg = message.channel:send("Packing up information, you'll be messaged shortly!")
        
        print (string.format("Job starting for %s (%s).", message.author.tag, message.author.id))
        timeoutList[user] = x+30000

        x = uv.now()

        local scopeWL = {}
        local g = client:getGuild(args.server)
        if args.scope and args.server and g then
          for i,v in pairs(g.members) do
            scopeWL[#scopeWL+1] = i
          end
        end

        for i,v in pairs(message.author.mutualGuilds) do --for every user guild
          local check = true -- check for whitelist / blacklist
          if args.whitelist then
            check = false
            for a,b in pairs(args.whitelist) do
              if i == b then
                check = true
              end
            end
          elseif args.blacklist then
            for a,b in pairs(args.blacklist) do
              if i == b then
                check = false
              end
            end
          end

          if check then
            if args.key then
              formatted[v] = {}
              for a,b in pairs (v.members) do -- for every member in user guild
                local wl = false --server scope check
                if args.scope and args.server and g then
                  for c,d in pairs(scopeWL) do
                    if a == d then
                      wl = true
                    end
                  end
                else
                  wl = true
                end 

                if a ~= user and a ~= client.user.id and wl then
                  formatted[v][#formatted[v] + 1] = a
                  if count[a] then
                    count[a] = count[a] + 1
                  else
                    count[a] = 1
                  end
                end
              end
            else
              for a,b in pairs(v.members) do
                local check = true --already in list check
                for u,_ in pairs(formatted) do
                  if u == a then
                    check = false
                  end
                end
                local wl = false --server scope check
                if args.scope and args.server and g then
                  for c,d in pairs(scopeWL) do
                    if a == d then
                      wl = true
                    end
                  end
                else
                  wl = true
                end 
    
                if a ~= user and a ~= client.user.id and check and wl then
                  for c,d in pairs(b.mutualGuilds) do
                    local bl = true -- if in blacklist
                    if args.blacklist then
                      for _,z in pairs(args.blacklist) do
                        if c == z then
                          bl = false
                        end
                      end
                    end
                    if bl then
                      for e,f in pairs(message.author.mutualGuilds) do                
                        if e == c then
                          if formatted[a] == nil then
                            formatted[a] = {}
                          end
                          formatted[a][#formatted[a] + 1] = f
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end

        -- if args.key then
        --   for i,v in pairs(formatted) do
        --     print (i.name)
        --     local s = "Mutual Members: "
        --     for a,b in ipairs(v) do
        --       s = s .. client:getUser(b).tag .. " || " 
        --     end
        --     print(s)
        --   end
        -- else
        --   for i,v in pairs(formatted) do
        --     print (client:getUser(i).tag)
        --     local s = "Mutual Guilds: "
        --     for _,u in pairs(v) do
        --       s = s .. u.name .. " || "
        --     end
        --     print(s)
        --   end
        -- end

        local def = (args.key or args.scope or (args.filter[1] and args.filter[1]) ~= 1 or (args.filter[2] and args.filter[2]) ~= 10000 or args.whitelist or args.blacklist) and "Custom" or "Default"
        local sco = args.scope and "Server" or "Global"
        local key = args.key and "Guild [MinGuilds:" .. (args.count or 2) .. "]" or "Person"
        local fil = ">" .. args.filter[1] .. ",<" .. args.filter[2]
        local ser = args.server or "nil"
        local lis = ((args.whitelist and "wl") or (args.blacklist and "bl")) or "nil"
        local msg = string.format("**Formatting: %s (Scope: %s, Key: %s, Filter: %s values, Server: %s, wl/bl: %s)**\n", def, sco, key, fil, ser, lis)

        local line = ""
        for i,v in pairs (formatted) do
          if #v > args.filter[1] and #v < args.filter[2] then
            if args.key then 
              line = "``" .. i.name .. "``: "
            else
              line = "``" .. client:getUser(i).tag .. "``: "
            end
            for _,u in pairs(v) do
              local chunk = ""
              if args.key then
                if count[u] >= args.count then
                  chunk = chunk .. client:getUser(u).tag
                end
              else
                chunk = chunk .. u.name 
              end
              local check = false
              if count and args.count then
                if count[u] >= args.count then
                  check = true
                end
              else
                check = true
              end
              if _ ~= #v and check then
                chunk = chunk .. ", "
              end
              if line:len() + chunk:len() > 2000 then
                message.author:send(msg)
                message.author:send(line)
                msg = ""
                line = ""
              end
              line = line .. chunk
            end
            line = line .. "\n"
            if line:len() + msg:len() > 2000 then
              message.author:send(msg)
              msg = ""
            end
            msg = msg .. line
          end
        end
        message.author:send(msg)

        print "Job Done!\n"
        local a = uv.now()
        initMsg:setContent(string.format("Information Sent! Operation completed in: %.2f seconds (%d ms).", (a-x)/1000, (a-x)))
      else
        message.channel:send(string.format("Usage Limited to every 30 seconds. %.1fs remaining.", (timeoutList[user]-uv.now())/1000))
      end
    end
  end
end)