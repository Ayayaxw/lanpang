SELECTION_VERSION = "1.00"

--[[
    Lua控制的选择库 由Noya开发
    
    安装方法:
    - 在您的代码中"require"此文件，以将新的API函数添加到PlayerResource全局变量
    - 另外，确保您的游戏脚本custom_net_tables.txt有一个"selection"条目
    - 最后，确保您的全景UI内容文件夹中正确添加和包含以下文件:
        selection.xml，以及custom_ui_manifest.xml中的include行，位于layout/custom_game/文件夹
        selection文件夹，包含selection.js和selection_filter.js，位于/scripts/文件夹

    使用方法:
    - 带unit_args的函数可以接收实体索引、NPC句柄或每种类型的表
    - 带unit的函数可以接收实体索引或NPC句柄

    * 为玩家创建新的选择
        PlayerResource:NewSelection(playerID, unit_args)

    * 向玩家当前选择添加单位
        PlayerResource:AddToSelection(playerID, unit_args)
    
    * 从玩家选择组中按索引移除单位
        PlayerResource:RemoveFromSelection(playerID, unit_args)
    
    * 返回玩家选择的单位实体索引列表
        PlayerResource:GetSelectedEntities(playerID)

    * 取消选择所有内容，选择主英雄（可以重定向到另一个实体）
        PlayerResource:ResetSelection(playerID)

    * 获取玩家选择的第一个单位的索引
        PlayerResource:GetMainSelectedEntity(playerID)
    
    * 检查单位是否被玩家选择，返回布尔值
        PlayerResource:IsUnitSelected(playerID, unit_args)

    * 强制刷新所有玩家的当前选择，在移除技能后很有用
        PlayerResource:RefreshSelection()
    
    * 将主英雄的选择重定向到另一个选择的实体
        PlayerResource:SetDefaultSelectionEntity(playerID, unit)
    
    * 将任何实体的选择重定向到另一个选择的实体
        hero:SetSelectionOverride(unit)

    * 使用-1重置为默认
        PlayerResource:SetDefaultSelectionEntity(playerID, -1)
        hero:SetSelectionOverride(-1)

    注意:
    - 您无法控制的敌方单位不能添加到玩家的选择组中
    - 此库需要"libraries/timers.lua"存在于您的vscripts目录中

--]]

function CDOTA_PlayerResource:NewSelection(playerID, unit_args)
    local player = self:GetPlayer(playerID)
    if player then
        local entities = Selection:GetEntIndexListFromTable(unit_args)
        CustomGameEventManager:Send_ServerToPlayer(player, "selection_new", {entities = entities})
    end
end 

function CDOTA_PlayerResource:AddToSelection(playerID, unit_args)
    local player = self:GetPlayer(playerID)
    if player then
        local entities = Selection:GetEntIndexListFromTable(unit_args)
        CustomGameEventManager:Send_ServerToPlayer(player, "selection_add", {entities = entities})
    end
end

function CDOTA_PlayerResource:RemoveFromSelection(playerID, unit_args)
    local player = self:GetPlayer(playerID)
    if player then
        local entities = Selection:GetEntIndexListFromTable(unit_args)
        CustomGameEventManager:Send_ServerToPlayer(player, "selection_remove", {entities = entities})
    end
end

function CDOTA_PlayerResource:ResetSelection(playerID)
    local player = self:GetPlayer(playerID)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "selection_reset", {})
    end
end

function CDOTA_PlayerResource:GetSelectedEntities(playerID)
    return Selection.entities[playerID] or {}
end

function CDOTA_PlayerResource:GetMainSelectedEntity(playerID)
    local selectedEntities = self:GetSelectedEntities(playerID) 
    return selectedEntities and selectedEntities["0"]
end

function CDOTA_PlayerResource:IsUnitSelected(playerID, unit)
    if not unit then return false end
    local entIndex = type(unit)=="number" and unit or IsValidEntity(unit) and unit:GetEntityIndex()
    if not entIndex then return false end
    
    local selectedEntities = self:GetSelectedEntities(playerID)
    for _,v in pairs(selectedEntities) do
        if v==entIndex then
            return true
        end
    end
    return false
end

function CDOTA_PlayerResource:RefreshSelection()
    Timers:CreateTimer(0.03, function()
        FireGameEvent("dota_player_update_selected_unit", {})
    end)
end

function CDOTA_PlayerResource:SetDefaultSelectionEntity(playerID, unit)
    if not unit then unit = -1 end
    local entIndex = type(unit)=="number" and unit or unit:GetEntityIndex()
    local hero = self:GetSelectedHeroEntity(playerID)
    if hero then
        hero:SetSelectionOverride(unit)
    end
end

function CDOTA_BaseNPC:SetSelectionOverride(reselect_unit)
    local unit = self
    local reselectIndex = type(reselect_unit)=="number" and reselect_unit or reselect_unit:GetEntityIndex()

    CustomNetTables:SetTableValue("selection", tostring(unit:GetEntityIndex()), {entity = reselectIndex})
end

------------------------------------------------------------------------
-- Internal
------------------------------------------------------------------------

require('libraries/timers')

if not Selection then
    Selection = class({})
end

function Selection:Init()
    Selection.entities = {} --Stores the selected entities of each playerID
    CustomGameEventManager:RegisterListener("selection_update", Dynamic_Wrap(Selection, 'OnUpdate'))
end

function Selection:OnUpdate(event)
    local playerID = event.PlayerID
    Selection.entities[playerID] = event.entities
end

-- Internal function to build an entity index list out of various inputs
function Selection:GetEntIndexListFromTable(unit_args)
    local entities = {}
    if type(unit_args)=="number" then
        table.insert(entities, unit_args) -- Entity Index
    -- Check contents of the table
    elseif type(unit_args)=="table" then
        if unit_args.IsCreature then
            table.insert(entities, unit_args:GetEntityIndex()) -- NPC Handle
        else
            for _,arg in pairs(unit_args) do
                -- Table of entity index values
                if type(arg)=="number" then
                    table.insert(entities, arg)
                -- Table of npc handles
                elseif type(arg)=="table" then
                    if arg.IsCreature then
                        table.insert(entities, arg:GetEntityIndex())
                    end
                end
            end
        end
    end
    return entities
end

if not Selection.entities then Selection:Init() end