if quanshui == nil  then
    quanshui = ({}) end

function quanshuiStart(params)
    if not params or not params.activator then
        return
    end

    local unit = params.activator
    if not unit or not IsValidEntity(unit) or unit:IsNull() then
        return 
    end

    -- 检查是否为有效单位且具有这些方法
    if not unit.IsAlive or not unit.HasModifier or not unit.GetTeamNumber or not unit.GetAbsOrigin or not unit.MoveToTargetToAttack then
        return
    end

    if unit:IsAlive() and unit:HasModifier("modifier_antimage_blink_illusion") then
        Timers:CreateTimer(function()
            if not IsValidEntity(unit) or unit:IsNull() or not unit:IsAlive() or not unit:HasModifier("modifier_antimage_blink_illusion") then
                return nil
            end

            local enemies = FindUnitsInRadius(unit:GetTeamNumber(),
                                            unit:GetAbsOrigin(),
                                            nil,
                                            1000,
                                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                                            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                            DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                                            FIND_CLOSEST,
                                            false)

            if #enemies > 0 then
                local target = enemies[1]
                unit:MoveToTargetToAttack(target)
            end
            
            return 0.5
        end)
    end
end
    

function hero_chaosEnd(params)
    -- if not params or not params.activator then
    --     return
    -- end
    
    -- local unit = params.activator
    -- if not unit or not IsValidEntity(unit) then
    --     return
    -- end
    
    -- if not unit:IsNull() then
    --     if unit:IsRealHero() and not unit:IsIllusion() 
    --         and not unit:HasModifier("modifier_monkey_king_fur_army_soldier")
    --         and not unit:HasModifier("modifier_dawnbreaker_solar_guardian_air_time") then
            
    --         local unitPos = unit:GetAbsOrigin()
    --         if not unitPos then
    --             return
    --         end
            
    --         local rectLeft = -1595.39
    --         local rectRight = 1852.88
    --         local rectTop = 1332.27
    --         local rectBottom = -828.52
    --         local zHeight = 128.00
            
    --         local nearestX = math.max(rectLeft + 100, math.min(rectRight - 100, unitPos.x))
    --         local nearestY = math.max(rectBottom + 100, math.min(rectTop - 100, unitPos.y))
    --         local nearestPoint = Vector(nearestX, nearestY, zHeight)
            
    --         if IsValidEntity(unit) and not unit:IsNull() then
    --             FindClearSpaceForUnit(unit, nearestPoint, true)
    --         end
    --     end
    -- end
end


-- 假设这是触发器内部的函数，params包含了触发器事件的相关信息
function quanshuiEnd(params)
    -- if params and params.activator then
    --     local unit = params.activator
    --     if unit and type(unit) == "table" then

            
    --         -- 主要逻辑
    --         if isValidUnit(unit) then
    --             teleportUnitToRectangle(unit)
    --             startPositionCheck(unit)
    --         end
    --     end
    -- end
end

function isValidUnit(unit)
    if unit == nil then return false end
    if not IsValidEntity(unit) then return false end
    if not unit.IsNull or unit:IsNull() then return false end
    if not unit.GetUnitName then return false end
    
    local unitName = unit:GetUnitName()
    if not unitName then return false end

    local invalidNames = {
        "npc_dota_thinker",
        "npc_dota_unit_undying_zombie_torso",
        "npc_dota_unit_undying_zombie",
        "npc_dota_wisp_spirit",
        "npc_dota_troll_warlord_axe",
        "npc_dota_rattletrap_cog",
        "npc_dota_muerta_revenant",
    }
    
    for _, name in ipairs(invalidNames) do
        if unitName == name then return false end
    end
    
    if string.find(unitName, "npc_dota_unit_tombstone") then return false end
    
    --if unit.IsIllusion and type(unit.IsIllusion) == "function" and unit:IsIllusion() then return false end
    
    if unit.HasModifier and type(unit.HasModifier) == "function" then
        if unit:HasModifier("modifier_monkey_king_fur_army_soldier") then return false end
        -- 添加对破晓辰星终极技能 modifier 的检查
        if unit:HasModifier("modifier_dawnbreaker_solar_guardian_air_time") then return false end
    end
    
    return true
end

function teleportUnitToRectangle(unit)
    local unitPos = unit:GetAbsOrigin()
    
    -- 定义触发器的中心位置和矩形边界
    local center = Vector(100, -2950, 0)
    local size = Vector(2500, 1000, 0)
    
    -- 计算矩形边界
    local rectLeft = center.x - size.x / 2
    local rectRight = center.x + size.x / 2
    local rectBottom = center.y - size.y / 2
    local rectTop = center.y + size.y / 2
    
    -- 计算最近点并稍微往区域里面传送100单位
    local nearestX = math.max(rectLeft + 100, math.min(rectRight - 100, unitPos.x))
    local nearestY = math.max(rectBottom + 100, math.min(rectTop - 100, unitPos.y))
    
    local nearestPoint = Vector(nearestX, nearestY, unitPos.z)
    
    FindClearSpaceForUnit(unit, nearestPoint, true)
    
    local unitName = unit:GetUnitName()
    if unitName and unitName ~= "" then
        print(string.format("Hero %s has been teleported back to the nearest point in the rectangular area.", unitName))
    end
end

function isUnitInRectangle(unitPos, rectLeft, rectRight, rectBottom, rectTop)
    return unitPos.x >= rectLeft and unitPos.x <= rectRight and unitPos.y >= rectBottom and unitPos.y <= rectTop
end

function startPositionCheck(unit)
    local center = Vector(100, -2950, 0)
    local size = Vector(2500, 1000, 0)
    
    local rectLeft = center.x - size.x / 2
    local rectRight = center.x + size.x / 2
    local rectBottom = center.y - size.y / 2
    local rectTop = center.y + size.y / 2
    
    local function checkPosition()
        if isValidUnit(unit) then
            local unitPos = unit:GetAbsOrigin()
            if not isUnitInRectangle(unitPos, rectLeft, rectRight, rectBottom, rectTop) then
                teleportUnitToRectangle(unit)
            end
            return 0.5
        else
            return nil
        end
    end
    
    Timers:CreateTimer(0.1, checkPosition)
end


function shuabing(params)
    --print("接触了")
    --printTable(params)
end

function printTable(t)
    for key, value in pairs(t) do
        print(key, value)
    end
end

function SpawnCreep(trigger)
    local triggerName = thisEntity:GetName()
    local heroFound = false

    -- 检测触发区域内的单位
    local entities = Entities:FindAllInSphere(trigger:GetCenter(), trigger:GetBoundingMaxs():Length())
    for _, entity in pairs(entities) do
        if entity:IsRealHero() then
            heroFound = true
            break
        end
    end

    -- 如果区域内有英雄，生成一个兵
    if heroFound then
        CreateUnitByName("npc_dota_creep_badguys_melee_upgraded_mega", trigger:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
    end
end
