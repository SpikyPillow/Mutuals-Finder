--[[
  Todo list of jazz (roughly in order of when i want to do it):
  
  Code
    Get github to exist, i guess --1.1
    Change a coupse things to prefer string.format, for ease of reading? idk, i like it, okay? --1.2
    Add !#help --1.3
    Finish -f, -s, and -l in !#mutuals. --1.4

  Not Code:
    Make Bot Icon.
    Advertise the bot a little.

]]

local discordia = require('discordia')
local client = discordia.Client {
	logFile = 'mybot.log',
  cacheAllMembers = true,
  syncGuilds = true,
}
local uv = require "uv"

local botVersion = "1.0a"
local timeoutList = {}
local pingList = {}
local queuedPong = {}

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

client:run("Bot " .. require "token")

client:on("ready", function()
  print(string.format("Logged in as %s\n", client.user.username))
  client:setGame("!#mutuals -h")
end)

-- Big beefy bit of it
client:on("messageCreate", function(message)
  local ping = false
  local str = message.content:lower()

  --Ping? Recieved
  if message.author.id == "586676341349285888" and message.content == "Ping?" then  
    ping = true -- add to "queue"
    queuedPong[message.id] = message.channel
  end
  
  -- !#ping Command!
  if str:find("!#ping") == 1 then
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

  if str:find("!#mutuals ") == 1 or str == "!#mutuals" then
    if (str:match("-h")) then
      message.channel:send(require "desc")
    else
      local args = {}
        if str:match("-k%(2%)") then
          args.key = 2
          if str:find("-c%(") then
            local a,b = str:lower():find("-c%(")
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
      local user = message.author.id
      local formatted = {}
      local count = {}
      
      local x = uv.now()
      local check = true
      for i,v in pairs(timeoutList) do
        if i == user then
          if v > x then
            check = false
          else
            timeoutList[user] = nil
          end
        end
      end
      
      if check then
        message.channel:send("Packing up information, you'll be messaged shortly!")
        
        print ("Job starting for: " .. message.author.tag .. " (" .. message.author.id .. ").")
        if user ~= "586676341349285888" then
          timeoutList[user] = x+30000
        end

        x = uv.now()
        for i,v in pairs(message.author.mutualGuilds) do --for every user guild
          if args.key == 2 then
            formatted[v] = {}
            for a,b in pairs (v.members) do -- for every member in user guild
              if a ~= user and a ~= "586676341349285888" then
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
  
              if a ~= user and a ~= "586676341349285888" and check then
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

        local default = (args.key) and "Custom" or "Default"
        local key = (args.key) and "Guild [MinGuilds:" .. (args.count or 2) .. "]" or "Person"
        local ser = (message.guild and message.guild.id) or "nil"
        local msg = "**Formatting: " .. default .. " (Scope: Global, Key: " .. key .. ", Filter: >1 values. Server: " .. ser .. ")**\n"
        local line = ""
        for i,v in pairs (formatted) do
          if #v > 1 then
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

        print "Job Done!"
        local a = uv.now()
        message.channel:send("Information Sent! Operation completed in: " .. (a-x)/1000 .. " seconds (" .. (a-x) .. " ms).")
      else
        message.channel:send("Usage limited to every 30 seconds. " .. (timeoutList[user]-uv.now())/1000 .. "s remaining.")
      end
    end
  end
end)