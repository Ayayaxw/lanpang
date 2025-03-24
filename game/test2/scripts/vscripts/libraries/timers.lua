TIMERS_VERSION = "1.05"

--[[

  -- 一个立即在下一帧开始运行的计时器，每秒运行一次，尊重暂停
  Timers:CreateTimer(function()
      print ("你好。我立即运行，然后每秒运行一次。")
      return 1.0
    end
  )

  -- 使用简写调用的相同计时器
  Timers(function()
    print ("你好。我立即运行，然后每秒运行一次。")
    return 1.0
  end)
  

  -- 带有表上下文的函数调用计时器
  Timers:CreateTimer(GameMode.someFunction, GameMode)

  -- 5秒后开始运行的计时器，每秒运行一次，尊重暂停
  Timers:CreateTimer(5, function()
      print ("你好。我在你调用我5秒后运行，然后每秒运行一次。")
      return 1.0
    end
  )

  -- 10秒延迟，使用游戏时间运行一次（尊重暂停）
  Timers:CreateTimer({
    endTime = 10, -- 此计时器首次执行的时间，如果您希望它在下一帧首先运行，可以省略此项
    callback = function()
      print ("你好。我在开始后10秒运行。")
    end
  })

  -- 10秒延迟，无论暂停与否都只运行一次
  Timers:CreateTimer({
    useGameTime = false,
    endTime = 10, -- 此计时器首次执行的时间，如果您希望它在下一帧首先运行，可以省略此项
    callback = function()
      print ("你好。即使有人暂停游戏，我也会在开始后10秒运行。")
    end
  })


  -- 一个无论暂停与否都在2分钟后开始每秒运行一次的计时器
  Timers:CreateTimer("uniqueTimerString3", {
    useGameTime = false,
    endTime = 120,
    callback = function()
      print ("你好。我在2分钟后运行，然后每秒运行一次。")
      return 1
    end
  })


  -- 使用旧风格的计时器，从5秒后开始每秒重复一次
  Timers:CreateTimer("uniqueTimerString3", {
    useOldStyle = true,
    endTime = GameRules:GetGameTime() + 5,
    callback = function()
      print ("你好。我在5秒后运行，然后每秒运行一次。")
      return GameRules:GetGameTime() + 1
    end
  })

]]


TIMERS_THINK = 0.01

if Timers == nil then
  print ( '[Timers] creating Timers' )
  Timers = {}
  setmetatable(Timers, {
    __call = function(t, ...)
      return t:CreateTimer(...)
    end
  })
  --Timers.__index = Timers
end

function Timers:start()
  Timers = self
  self.timers = {}
  
  --local ent = Entities:CreateByClassname("info_target") -- Entities:FindByClassname(nil, 'CWorld')
  local ent = SpawnEntityFromTableSynchronous("info_target", {targetname="timers_lua_thinker"})
  ent:SetThink("Think", self, "timers", TIMERS_THINK)
end

function Timers:Think()
  --if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    --return
  --end

  -- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
  local now = GameRules:GetGameTime()

  -- Process timers
  for k,v in pairs(Timers.timers) do
    local bUseGameTime = true
    if v.useGameTime ~= nil and v.useGameTime == false then
      bUseGameTime = false
    end
    local bOldStyle = false
    if v.useOldStyle ~= nil and v.useOldStyle == true then
      bOldStyle = true
    end

    local now = GameRules:GetGameTime()
    if not bUseGameTime then
      now = Time()
    end

    if v.endTime == nil then
      v.endTime = now
    end
    -- Check if the timer has finished
    if now >= v.endTime then
      -- Remove from timers list
      Timers.timers[k] = nil

      Timers.runningTimer = k
      Timers.removeSelf = false
      
      -- Run the callback
      local status, nextCall
      if v.context then
        status, nextCall = xpcall(function() return v.callback(v.context, v) end, function (msg)
                                    return msg..'\n'..debug.traceback()..'\n'
                                  end)
      else
        status, nextCall = xpcall(function() return v.callback(v) end, function (msg)
                                    return msg..'\n'..debug.traceback()..'\n'
                                  end)
      end

      Timers.runningTimer = nil

      -- Make sure it worked
      if status then
        -- Check if it needs to loop
        if nextCall and not Timers.removeSelf then
          -- Change its end time

          if bOldStyle then
            v.endTime = v.endTime + nextCall - now
          else
            v.endTime = v.endTime + nextCall
          end

          Timers.timers[k] = v
        end

        -- Update timer data
        --self:UpdateTimerData()
      else
        -- Nope, handle the error
        Timers:HandleEventError('Timer', k, nextCall)
      end
    end
  end

  return TIMERS_THINK
end

function Timers:HandleEventError(name, event, err)
  print(err)

  -- Ensure we have data
  name = tostring(name or 'unknown')
  event = tostring(event or 'unknown')
  err = tostring(err or 'unknown')

  -- Tell everyone there was an error
  --Say(nil, name .. ' threw an error on event '..event, false)
  --Say(nil, err, false)

  -- Prevent loop arounds
  if not self.errorHandled then
    -- Store that we handled an error
    self.errorHandled = true
  end
end

function Timers:CreateTimer(name, args, context)
  if type(name) == "function" then
    if args ~= nil then
      context = args
    end
    args = {callback = name}
    name = DoUniqueString("timer")
  elseif type(name) == "table" then
    args = name
    name = DoUniqueString("timer")
  elseif type(name) == "number" then
    args = {endTime = name, callback = args}
    name = DoUniqueString("timer")
  end
  if not args.callback then
    print("Invalid timer created: "..name)
    return
  end


  local now = GameRules:GetGameTime()
  if args.useGameTime ~= nil and args.useGameTime == false then
    now = Time()
  end

  if args.endTime == nil then
    args.endTime = now
  elseif args.useOldStyle == nil or args.useOldStyle == false then
    args.endTime = now + args.endTime
  end

  args.context = context

  Timers.timers[name] = args 

  return name
end

function Timers:RemoveTimer(name)
  Timers.timers[name] = nil
  if Timers.runningTimer == name then
    Timers.removeSelf = true
  end
end

function Timers:RemoveTimers(killAll)
  local timers = {}
  Timers.removeSelf = true

  if not killAll then
    for k,v in pairs(Timers.timers) do
      if v.persist then
        timers[k] = v
      end
    end
  end

  Timers.timers = timers
end

if not Timers.timers then Timers:start() end

GameRules.Timers = Timers