WORLDPANELS_VERSION = "0.81"

--[[
  Lua控制的弗兰肯斯坦世界面板库 由BMD开发

  安装方法
  -在您的代码中"require"此文件以使WorldPanels API可用
  -确保此文件与timers.lua和playertables.lua一起放置在vscripts/libraries路径中
  -确保您的全景UI内容布局文件夹中有barebones_worldpanels.xml
  -确保您的全景UI内容脚本文件夹中有barebones_worldpanels.js
  -确保barebones_worldpanels.xml在您的custom_ui_manifest.xml中包含
    <CustomUIElement type="Hud" layoutfile="file://{resources}/layout/custom_game/barebones_worldpanels.xml" />

  库使用方法
  -WorldPanels是一种向个人显示全景UI布局文件的方式，这些文件看起来像是位于世界特定点或特定实体上
  -WorldPanels可以通过以下方式与单个玩家、整个团队或所有客户端共享
    WorldPanels:CreateWorldPanel(playerID, configTable) -- 1个玩家或玩家ID数组，如{3,5,8}
    WorldPanels:CreateWorldPanelForTeam(teamID, configTable) -- 1个团队
    WorldPanels:CreateWorldPanelForAll(configTable) -- 所有玩家
  -WorldPanels由一个配置表指定，该表有几个潜在参数:
    -layout: 在此worldpanel中显示的全景UI布局文件
    -position: 与"entity"互斥。Position是显示worldpanel的世界向量位置
    -entity: 与"position"互斥。Entity是worldpanel将跟踪其位置的实体（hscript或索引）
    -offsetX: 可选参数（默认为0）应用于worldpanel的屏幕像素偏移（x方向）
    -offsetY: 可选参数（默认为0）应用于worldpanel的屏幕像素偏移（y方向）
    -horizontalAlign: 可选参数（默认为"center"）worldpanel在调整面板大小时使用的对齐方式。有效选项为"center"、"left"、"right"
    -verticalAlign: 可选参数（默认为"bottom"）worldpanel在调整面板大小时使用的对齐方式。有效选项为"bottom"、"center"、"top"
    -entityHeight: 可选参数（默认为0）用于实体世界面板的高度偏移（参见：单位KV定义中的"HealthBarOffset"）
    -edgePadding: 可选参数（默认不锁定到屏幕边缘）限制worldpanel的屏幕百分比填充
    -duration: 可选参数（默认无限）面板将存在的GameTime秒数，之后将自动销毁
    -data: 可选的数据表，将附加到worldpanel，使值可以在javascript中通过$.GetContextPanel().Data使用
      此表应只包含数字、字符串或表值（没有实体/hscripts）

  -Create方法返回的WorldPanels具有以下方法:
    wp:SetPosition(position)
    wp:SetEntity(entity)
    wp:SetHorizontalAlign(hAlign)
    wp:SetVerticalAlign(vAlign)
    wp:SetOffsetX(offsetX)
    wp:SetOffsetY(offsetY)
    wp:SetEdgePadding(edge)
    wp:SetEntityHeight(entityHeight)
    wp:SetData(data)
    wp:Delete()

  -示例/worldpanelsExample.lua中有使用示例


  注意
  -WorldPanel全景UI性能仍可能是个问题（取决于布局）。谨慎使用
  -附加到实体的WorldPanel只在玩家对该实体有视野时才会显示
  -如果附加的实体死亡（且不是英雄类型单位），WorldPanel会自动删除
  -由于Valve的Game.WorldToScreenX/Y存在bug，某些情况下边缘跟踪目前不准确
  -WorldPanel库为您的布局文件的javascript提供了一些有用的属性
    $.GetContextPanel().WorldPanel      包含以下表格式的WorldPanel配置:
      {layout, offsetX, offsetY, position, entity, entityHeight, hAlign, vAlign, edge}
    $.GetContextPanel().OnEdge          如果此worldpanel有边缘锁定/填充并触及屏幕边缘/填充边缘，则为true。否则为false。每帧更新
    $.GetContextPanel().OffScreen       如果此worldpanel没有边缘锁定/填充并完全在屏幕外，则为true。否则为false。每帧更新
    $.GetContextPanel().Data            传递给CreateWorldPanel的"data"对象

  示例
  -为玩家0的英雄实体创建一个特殊的worldpanel，只对玩家0可见。为面板的高度给单位位置添加210
    WorldPanels:CreateWorldPanel(0, 
      {layout = "file://{resources}/layout/custom_game/worldpanels/healthbar.xml",
        entity = PlayerResource:GetSelectedHeroEntity(0),
        entityHeight = 210,
      })

  -为所有玩家创建一个worldpanel，在Vector(0,0,0)的地面上方200高度显示，并锁定到屏幕边缘的5%
    WorldPanels:CreateWorldPanelForAll(
      {layout = "file://{resources}/layout/custom_game/worldpanels/arrow.xml",
        position = GetGroundPosition(Vector(0,0,0), nil) + Vector(0,0,200),
        edgePadding = 5,
      })


]]

require('libraries/timers')
require('libraries/playertables')

local haStoI = {[0]="center", [1]="left", [2]="right"}
local haItoS = {center=0, left=1, right=2}
local vaStoI = {bottom=0, center=1, top=2}
local vaItoS = {[0]="bottom", [1]="center", [2]="top"}

if not WorldPanels then
  WorldPanels = class({})
end

local UpdateTable = function(wp)
  local idString = wp.idString
  local pt = wp.pt
  local pids = wp.pids
  for i=1,#pids do
    local pid = pids[i]
    local ptName = "worldpanels_" .. pid

    if not PlayerTables:TableExists(ptName) then
      PlayerTables:CreateTable(ptName, {[idString]=pt}, {pid})
    else
      PlayerTables:SetTableValue(ptName, idString, pt)
    end
  end
end

function WorldPanels:start()
  self.initialized = true

  self.entToPanels = {}
  self.worldPanels = {}
  self.nextID = 0

  --CustomGameEventManager:RegisterListener("Attachment_DoSphere", Dynamic_Wrap(WorldPanels, "Attachment_DoSphere"))
  ListenToGameEvent('entity_killed', Dynamic_Wrap(WorldPanels, 'OnEntityKilled'), self)
end

function WorldPanels:OnEntityKilled( keys )
  --print( '[WorldPanels] OnEntityKilled Called' )
  --PrintTable( keys )
  

  -- The Ent that was Killed
  local killedEnt = EntIndexToHScript( keys.entindex_killed )

  local panels = WorldPanels.entToPanels[killedEnt]

  if not killedEnt.IsRealHero or not killedEnt:IsRealHero() then
    if panels then
      for i=1,#panels do
        local panel = panels[i]
        for j=1,#panel.pids do
          local pid = panel.pids[j]
          PlayerTables:DeleteTableKey("worldpanels_" .. pid, panel.idString)
        end
      end
    end
  end

  
end

function WorldPanels:CreateWorldPanelForAll(conf)
  local pids = {}
  for i=0,DOTA_MAX_TEAM_PLAYERS do
    if PlayerResource:IsValidPlayer(i) then
      pids[#pids+1] = i;
    end
  end

  return WorldPanels:CreateWorldPanel(pids, conf)
end

function WorldPanels:CreateWorldPanelForTeam(team, conf)
  local count = PlayerResource:GetPlayerCountForTeam(team)
  local pids = {}
  for i=1,count do
    pids[#pids+1] = PlayerResource:GetNthPlayerIDOnTeam(team, i)
  end

  return WorldPanels:CreateWorldPanel(pids, conf)
end

function WorldPanels:CreateWorldPanel(pids, conf)
  --{position, entity, offsetX, offsetY, hAlign, vAlign, entityHeight, edge, duration, data}
  -- duration?
  if type(pids) == "number" then
    pids = {pids}
  end

  local ent = conf.entity
  local ei = conf.entity
  if ent and type(ent) == "number" then
    ei = ent
    ent = EntIndexToHScript(ent)
  elseif ent and ent.GetEntityIndex then
    ei = ent:GetEntityIndex() 
  end

  local pt = {
    layout =            conf.layout,
    position =          conf.position,
    entity =            ei,
    offsetX =           conf.offsetX,
    offsetX =           conf.offsetY,
    entityHeight =      conf.entityHeight,
    edge =              conf.edgePadding,
    data =              conf.data,
  }

  if conf.horizontalAlign then pt.hAlign = haStoI[conf.horizontalAlign] end
  if conf.verticalAlign   then pt.vAlign = vaStoI[conf.verticalAlign] end

  local idString = tostring(self.nextID)

  local wp = {
    id =                self.nextID,
    idString =          idString,
    pids =              pids,
    pt =                pt,
  }

  function wp:SetPosition(pos)
    self.pt.entity = nil
    self.pt.position = pos
    UpdateTable(self)
  end

  function wp:SetEntity(entity)
    local ei = entity
    if entity and not type(entity) == "number" and entity.GetEntityIndex then
      ei = entity:GetEntityIndex() 
    end

    self.pt.entity = ei
    self.pt.position = nil
    UpdateTable(self)
  end

  function wp:SetHorizontalAlign(hAlign)
    self.pt.hAlign = haStoI[hAlign]
    UpdateTable(self)
  end

  function wp:SetVerticalAlign(vAlign)
    self.pt.vAlign = vaStoI[vAlign]
    UpdateTable(self)
  end

  function wp:SetOffsetX(offX)
    self.pt.offsetX = offX
    UpdateTable(self)
  end

  function wp:SetOffsetY(offY)
    self.pt.offsetY = offY
    UpdateTable(self)
  end

  function wp:SetEntityHeight(height)
    self.pt.entityHeight = height
    UpdateTable(self)
  end

  function wp:SetEdgePadding(edge)
    self.pt.edge = edge
    UpdateTable(self)
  end

  function wp:SetData(data)
    self.pt.data = data
    UpdateTable(self)
  end

  function wp:Delete()
    for j=1,#self.pids do
      local pid = self.pids[j]
      PlayerTables:DeleteTableKey("worldpanels_" .. pid, self.idString)
    end
  end

  if conf.duration then
    pt.endTime = GameRules:GetGameTime() + conf.duration
    Timers:CreateTimer(conf.duration,function()
      wp:Delete()
    end)
  end

  UpdateTable(wp)

  if ei then
    self.entToPanels[ent] = self.entToPanels[ent] or {}
    table.insert(self.entToPanels[ent], wp)
  end

  self.worldPanels[self.nextID] = wp
  self.nextID = self.nextID + 1
  return wp
end

if not WorldPanels.initialized then WorldPanels:start() end