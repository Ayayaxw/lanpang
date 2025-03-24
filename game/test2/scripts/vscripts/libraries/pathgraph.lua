PATHGRAPH_VERSION = "0.80"

--[[
  路径图实例化库 由BMD开发

  安装方法
  -在您的代码中"require"此文件以访问PathGraph全局变量和函数

  使用方法
  -应在游戏模式初始化期间调用PathGraph:Initialize()
  -Initialize函数将查找所有通过hammer放置在地图上的相连"path_corner"实体并将它们连接起来
  -Initialize后，每个"path_corner"实体都将有一个"edges"属性，包含该节点到所有其他连接节点的完整边图
  -应调用PathGraph:DrawPaths(pathCorner, duration, color)进行调试，以显示路径图连接
    -pathCorner是要显示连接图的path_corner实体
    -duration是显示图形的持续时间
    -color是用于图形线条和节点的颜色
  注意
  -目前仅支持path_corner而不支持path_track

  示例:
  --初始化图形
    PathGraph:Initialize()

  --从名为"start_node"的path_corner节点开始遍历所有连接的边
    local node = Entities:FindByName(nil, "start_node")
    for _,edge in pairs(node.edges) do
      print("'start_node'与'"..edge:GetName().."'相连")
    end

]]

if not PathGraph then
  PathGraph = class({})
end

local TableCount = function(t)
  local n = 0
  for _ in pairs( t ) do
    n = n + 1
  end
  return n
end

function PathGraph:Initialize()
  local corners = Entities:FindAllByClassname('path_corner')
  local points = {} 
  for _,corner in ipairs(corners) do
    points[corner:entindex()] = corner
  end

  local names = {}

  for _,corner in ipairs(corners) do
    local name = corner:GetName()
    if names[name] ~= nil then
      print("[PathGraph] Initialization error, duplicate path_corner named '" .. name .. "' found. Skipping...")
    else
      local parents = Entities:FindAllByTarget(corner:GetName())
      corner.edges = corner.edges or {}
      
      for _,parent in ipairs(parents) do
        corner.edges[parent:entindex()] = parent
        parent.edges = parent.edges or {}
        parent.edges[corner:entindex()] = corner
      end
    end
  end
end

function PathGraph:DrawPaths(pathCorner, duration, color)
  duration = duration or 10
  color = color or Vector(255,255,255)
  if pathCorner ~= nil then
    if pathCorner:GetClassname() ~= "path_corner" or pathCorner.edges == nil then
      print("[PathGraph] An invalid path_corner was passed to PathGraph:DrawPaths.")
      return
    end

    local seen = {}
    local toDo = {pathCorner}

    repeat 
      local corner = table.remove(toDo)
      local edges = corner.edges
      DebugDrawCircle(corner:GetAbsOrigin(), color, 50, 20, true, duration)
      seen[corner:entindex()] = corner

      for index,edge in pairs(edges) do
        if seen[index] == nil then
          DebugDrawLine_vCol(corner:GetAbsOrigin(), edge:GetAbsOrigin(), color, true, duration)
          table.insert(toDo, edge)
        end
      end
    until (#toDo == 0)
  else
    local corners = Entities:FindAllByClassname('path_corner')
    local points = {} 
    for _,corner in ipairs(corners) do
      points[corner:entindex()] = corner
    end

    repeat 
      local seen = {}
      local k,v = next(points)
      local toDo = {v}

      repeat 
        local corner = table.remove(toDo)
        points[corner:entindex()] = nil
        local edges = corner.edges
        DebugDrawCircle(corner:GetAbsOrigin(), color, 50, 20, true, duration)
        seen[corner:entindex()] = corner

        for index,edge in pairs(edges) do
          if seen[index] == nil then
            DebugDrawLine_vCol(corner:GetAbsOrigin(), edge:GetAbsOrigin(), color, true, duration)
            table.insert(toDo, edge)
          end
        end
      until (#toDo == 0)
    until (TableCount(points) == 0)
  end
end

--PathGraph:Initialize()

GameRules.PathGraph = PathGraph