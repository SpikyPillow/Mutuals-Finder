--[[
  Todo list of jazz (roughly in order of to do it):
  
  Code
    !#mutuals
      Finish -s and -l -- 1.5
      Finish -bl and -wl -- 1.6

  Not Code:
    Make Bot Icon.
    Advertise the bot a little.
]]

local discordia = require('discordia')
local client = discordia.Client {
	logFile = 'bot.log',
  cacheAllMembers = true,
  syncGuilds = true,
}
local uv = require "uv"

local botVersion = "1.4c"
local ruirr = "175060396627984384"
local timeoutList = {}
local pingList = {}
local queuedPong = {}

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
    message.channel:send(require "help")
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
      message.channel:send(string.format(desc, client:getUser("175060396627984384").tag))
    else
      local args = {}
        if str:match("-k%(2%)") then
          args.key = 2
          if str:find("-c%(") then
            local a,b = str:find("-c%(")
            local s = str:sub(b)
            local c = s:find(")")
            local s = s:sub(2, c-1)
            args.count = tonumber(s)
            if args.count < 0 then
              args.count = 2
            end
          end
          if args.count == nil then
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
        message.channel:send("Packing up information, you'll be messaged shortly!")
        
        print (string.format("Job starting for %s (%s).", message.author.tag, message.author.id))
        timeoutList[user] = x+30000

        x = uv.now()
        for i,v in pairs(message.author.mutualGuilds) do --for every user guild
          if args.key == 2 then
            formatted[v] = {}
            for a,b in pairs (v.members) do -- for every member in user guild
              if a ~= user and a ~= client.user.id then
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
              local check = true
              for u,_ in pairs(formatted) do
                if u == a then
                  check = false
                end
              end
  
              if a ~= user and a ~= client.user.id and check then
                for c,d in pairs(b.mutualGuilds) do
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
        -- print ("\n\n\n")

        if args.key == 2 then
          for i,v in pairs(formatted) do
            print (i.name)
            local s = "Mutual Members: "
            for a,b in ipairs(v) do
              --print (a,b)
              s = s .. client:getUser(b).tag .. " || " 
            end
            print(s)
          end
        else
          for i,v in pairs(formatted) do
            print (client:getUser(i).tag)
            local s = "Mutual Guilds: "
            for _,u in pairs(v) do
              s = s .. u.name .. " || "
            end
            print(s)
          end
        end

        local def = (args.key or args.filter[1] or args.filter[1] ~= 1 or args.filter[2] or args.filter[2] ~= 10000 ) and "Custom" or "Default"
        local sco = "Global"
        local key = (args.key) and "Guild [MinGuilds:" .. (args.count or 2) .. "]" or "Person"
        local fil = ">" .. args.filter[1] .. ",<" .. args.filter[2]
        local ser = (message.guild and message.guild.id) or "nil"
        local msg = string.format("**Formatting: %s (Scope: %s, Key: %s, Filter: %s values. Server: %s)**\n", def, sco, key, fil, ser)
        local line = ""
        for i,v in pairs (formatted) do
          if #v > args.filter[1] and #v < args.filter[2] then
            if args.key == 2 then 
              line = "``" .. i.name .. "``: "
            else
              line = "``" .. client:getUser(i).tag .. "``: "
            end
            for _,u in pairs(v) do
              local chunk = ""
              if args.key == 2 then
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
        message.channel:send(string.format("Information Sent! Operation completed in: %.2f seconds (%d ms).", (a-x)/1000, (a-x)))
      else
        message.channel:send(string.format("Usage Limited to every 30 seconds. %.1fs remaining.", (timeoutList[user]-uv.now())/1000))
      end
    end
  end
end)