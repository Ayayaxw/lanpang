PLAYERTABLES_VERSION = "0.90"

--[[
  PlayerTables: 玩家特定共享状态/网络表库 由BMD开发

  PlayerTables设置一个在服务器(lua)和客户端(javascript)之间共享的表，可以在特定（但可更改）的客户端之间共享
  这在概念上与网络表非常相似，但构建在玩家特定状态上（不发送给所有玩家）
  与网络表一样，PlayerTable状态调整会镜像到客户端（当前已订阅的客户端）
  如果玩家断开连接然后重新连接，PlayerTables会在他们连接时自动传输他们订阅的表状态
  PlayerTables仅支持向客户端发送数字、字符串和数字/字符串/表的表

  安装方法
  -在您的代码中"require"此文件以访问PlayerTables全局表
  -确保您的全景UI内容脚本文件夹中有playertables/playertables_base.js
  -确保playertables/playertables_base.js脚本在您的custom_ui_manifest.xml中包含
    <scripts>
      <include src="file://{resources}/scripts/playertables/playertables_base.js" />
    </scripts>

  库使用方法
  -Lua
    -void PlayerTables:CreateTable(tableName, tableContents, pids)
      创建一个新的PlayerTable，具有给定的名称、默认表内容，并自动设置"pids"对象中所有playerID的订阅
    -void PlayerTables:DeleteTable(tableName)
      删除给定名称的表，通知所有已订阅的客户端
    -bool PlayerTables:TableExists(tableName)
      返回给定名称的表是否当前存在
    -void PlayerTables:SetPlayerSubscriptions(tableName, pids)
      基于"pids"对象清除并重置所有玩家订阅
    -void PlayerTables:AddPlayerSubscription(tableName, pid)
      为给定的玩家ID添加订阅
    -void PlayerTables:RemovePlayerSubscription(tableName, pid)
      移除给定玩家ID的订阅
    -<> PlayerTables:GetTableValue(tableName, key)
      返回给定"key"的PlayerTable当前值，如果键不存在则返回nil
    -<> PlayerTables:GetAllTableValues(tableName)
      返回给定表的当前键和值
    -void PlayerTables:DeleteTableValue(tableName, key)
      从playertable删除一个键
    -void PlayerTables:DeleteTableValues(tableName, keys)
      从playertable删除keys对象中给定的键
    -void PlayerTables:SetTableValue(tableName, key, value)
      为给定的键设置一个值
    -void PlayerTables:SetTableValues(tableName, changes)
      设置changes对象中给定的所有键值对

  -Javascript: 通过在文件顶部包含"var PlayerTables = GameUI.CustomUIConfig().PlayerTables"来包含javascript API
    -void PlayerTables.GetAllTableValues(tableName)
      返回表"tableName"中所有键的当前键和值
      如果不存在该名称的表，则返回null
    -void PlayerTables.GetTableValue(tableName, keyName)
      返回表"tableName"中"keyName"给定键的当前值（如果存在）
      如果表不存在则返回null，如果键不存在则返回undefined
    -int PlayerTables.SubscribeNetTableListener(tableName, callback) 
      设置此playertable更改时的回调，回调格式为:
        function(tableName, changesObject, deletionsObject)
          changesObject包含被更改的键值对
          deletionsObject包含被删除的键
          如果changesObject和deletionsObject都为null，则整个表被删除

      返回表示此订阅的整数值
    -void PlayerTables.UnsubscribeNetTableListener(callbackID)
      移除由callbackID（从SubscribeNetTableListener返回的整数）给定的现有订阅

  示例:
    --创建一个表并设置几个值
      PlayerTables:CreateTable("new_table", {initial="initial value"}, {0})
      PlayerTables:SetTableValue("new_table", "count", 0)
      PlayerTables:SetTableValues("new_table", {val1=1, val2=2})

    --更改玩家订阅
      PlayerTables:RemovePlayerSubscription("new_table", 0)
      PlayerTables:SetPlayerSubscriptions("new_table", {[1]=true,[3]=true})  -- pids对象可以是map或数组类型表

    --在客户端检索值
      var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
      $.Msg(PlayerTables.GetTableVaue("new_table", "count"));

    --在客户端订阅更改
      var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
      PlayerTables.SubscribeNetTableListener("new_table", function(tableName, changes, deletions){
        $.Msg(tableName + " changed: " + changes + " -- " + deletions);
      });

]]

if not PlayerTables then
  PlayerTables = class({})
end

function PlayerTables:start()
  self.tables = {}
  self.subscriptions = {}

  CustomGameEventManager:RegisterListener("PlayerTables_Connected", Dynamic_Wrap(PlayerTables, "PlayerTables_Connected"))
end

function PlayerTables:equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or self:equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function PlayerTables:copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[self:copy(k, s)] = self:copy(v, s) end
  return res
end

function PlayerTables:PlayerTables_Connected(args)
  --print('PlayerTables_Connected')
  --PrintTable(args)

  local pid = args.pid
  if not pid then
    return
  end

  local player = PlayerResource:GetPlayer(pid)
  --print('player: ', player)


  for k,v in pairs(PlayerTables.subscriptions) do
    if v[pid] then
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_fu", {name=k, table=PlayerTables.tables[k]} )
      end
    end
  end
end

function PlayerTables:CreateTable(tableName, tableContents, pids)
  tableContents = tableContents or {}
  pids = pids or {}

  if pids == true then
    pids = {}
    for i=0,DOTA_MAX_TEAM_PLAYERS-1 do
      pids[#pids+1] = i
    end
  end

  if self.tables[tableName] then
    print("[playertables.lua] Warning: player table '" .. tableName .. "' already exists.  Overriding.")
  end

  self.tables[tableName] = tableContents
  self.subscriptions[tableName] = {}

  for k,v in pairs(pids) do
    local pid = k
    if type(v) == "number" then
      pid = v
    end
    if pid >= 0 and pid < DOTA_MAX_TEAM_PLAYERS then
      self.subscriptions[tableName][pid] = true
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_fu", {name=tableName, table=tableContents} )
      end
    else
      print("[playertables.lua] Warning: Pid value '" .. pid .. "' is not an integer between [0," .. DOTA_MAX_TEAM_PLAYERS .. "].  Ignoring.")
    end
  end
end

function PlayerTables:DeleteTable(tableName)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local pids = self.subscriptions[tableName]

  for k,v in pairs(pids) do
    local player = PlayerResource:GetPlayer(k)
    if player then  
      CustomGameEventManager:Send_ServerToPlayer(player, "pt_fu", {name=tableName, table=nil} )
    end
  end

  self.tables[tableName] = nil
  self.subscriptions[tableName] = nil  
end

function PlayerTables:TableExists(tableName)
  return self.tables[tableName] ~= nil
end

function PlayerTables:SetPlayerSubscriptions(tableName, pids)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local oldPids = self.subscriptions[tableName]
  self.subscriptions[tableName] = {}

  for k,v in pairs(pids) do
    local pid = k
    if type(v) == "number" then
      pid = v
    end
    if pid >= 0 and pid < DOTA_MAX_TEAM_PLAYERS then
      self.subscriptions[tableName][pid] = true
      local player = PlayerResource:GetPlayer(pid)
      if player and oldPids[pid] == nil then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_fu", {name=tableName, table=table} )
      end
    else
      print("[playertables.lua] Warning: Pid value '" .. pid .. "' is not an integer between [0," .. DOTA_MAX_TEAM_PLAYERS .. "].  Ignoring.")
    end
  end
end

function PlayerTables:AddPlayerSubscription(tableName, pid)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local oldPids = self.subscriptions[tableName]

  if not oldPids[pid] then
    if pid >= 0 and pid < DOTA_MAX_TEAM_PLAYERS then
      self.subscriptions[tableName][pid] = true
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_fu", {name=tableName, table=table} )
      end
    else
      print("[playertables.lua] Warning: Pid value '" .. v .. "' is not an integer between [0," .. DOTA_MAX_TEAM_PLAYERS .. "].  Ignoring.")
    end
  end
end

function PlayerTables:RemovePlayerSubscription(tableName, pid)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local oldPids = self.subscriptions[tableName]
  oldPids[pid] = nil
end

function PlayerTables:GetTableValue(tableName, key)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local ret = self.tables[tableName][key]
  if type(ret) == "table" then
    return self:copy(ret)
  end
  return ret
end

function PlayerTables:GetAllTableValues(tableName)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local ret = self.tables[tableName]
  if type(ret) == "table" then
    return self:copy(ret)
  end
  return ret
end

function PlayerTables:DeleteTableKey(tableName, key)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local pids = self.subscriptions[tableName]

  if table[key] ~= nil then
    table[key] = nil
    for pid,v in pairs(pids) do
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_kd", {name=tableName, keys={[key]=true}} )
      end
    end
  end
end

function PlayerTables:DeleteTableKeys(tableName, keys)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local pids = self.subscriptions[tableName]

  local deletions = {}
  local notempty = false

  for k,v in pairs(keys) do
    if type(k) == "string" then
      if table[k] ~= nil then
        deletions[k] = true
        table[k] = nil
        notempty = true
      end
    elseif type(v) == "string" then
      if table[v] ~= nil then
        deletions[v] = true
        table[v] = nil
        notempty = true
      end
    end
  end

  if notempty then
    for pid,v in pairs(pids) do
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_kd", {name=tableName, keys=deletions} )
      end
    end
  end
end

function PlayerTables:SetTableValue(tableName, key, value)
  if value == nil then
    self:DeleteTableKey(tableName, key)
    return 
  end
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local pids = self.subscriptions[tableName]

  if not self:equals(table[key], value) then
    table[key] = value
    for pid,v in pairs(pids) do
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_uk", {name=tableName, changes={[key]=value}} )
      end
    end
  end
end

function PlayerTables:SetTableValues(tableName, changes)
  if not self.tables[tableName] then
    print("[playertables.lua] Warning: Table '" .. tableName .. "' does not exist.")
    return
  end

  local table = self.tables[tableName]
  local pids = self.subscriptions[tableName]

  for k,v in pairs(changes) do
    if self:equals(table[k], v) then
      changes[k] = nil
    else
      table[k] = v
    end
  end

  local notempty, _ = next(changes, nil)

  if notempty then
    for pid,v in pairs(pids) do
      local player = PlayerResource:GetPlayer(pid)
      if player then  
        CustomGameEventManager:Send_ServerToPlayer(player, "pt_uk", {name=tableName, changes=changes} )
      end
    end
  end
end

if not PlayerTables.tables then PlayerTables:start() end