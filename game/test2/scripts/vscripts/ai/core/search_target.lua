function CommonAI:FindHeroTarget(entity)
    self:log("FindHeroTarget called for entity: " .. (entity and entity:GetUnitName() or "nil"))
    if not entity then
        self:log("Error: entity is nil in FindHeroTarget")
        return nil, 0
    end

    -- 修改目标类型为英雄和普通单位
    local target_types = bit.bor(DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_BASIC)
    
    local units = FindUnitsInRadius(entity:GetTeamNumber(), 
                                  entity:GetOrigin(), 
                                  nil, 
                                  GLOBAL_SEARCH_RADIUS, 
                                  DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                  target_types,
                                  0, 
                                  FIND_CLOSEST, 
                                  false)
    
    local closestHero = nil
    local closestDistance = math.huge
    local enemyCount = 0
    
    -- 首先检查是否存在酒仙本体
    local brewmasterExists = false
    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_dota_hero_brewmaster" and 
           unit:IsRealHero() and 
           not unit:IsIllusion() then
            brewmasterExists = true
            break
        end
    end
    
    for _, unit in pairs(units) do
        local isEligible = false
        local isBrewmasterElement = unit:GetUnitName():find("npc_dota_brewmaster") ~= nil
        
        -- 英雄类目标判断
        if unit:IsHero() then
            -- 原有英雄判断逻辑
            if (not unit:IsSummoned() or unit:IsIllusion()) then
                if unit:IsRealHero() or 
                   (unit:IsIllusion() and unit:HasModifier("modifier_vengefulspirit_hybrid_special")) then
                    isEligible = true
                end
            end
        -- 熊猫元素分身判断：仅当本体不存在时才考虑分身
        elseif isBrewmasterElement and not unit:IsIllusion() and not brewmasterExists then
            isEligible = true
        end

        -- 排除特定 modifier
        local hasExcludedModifier = unit:HasModifier("modifier_ringmaster_the_box_buff") or 
                                  unit:HasModifier("modifier_slark_depth_shroud") or
                                  unit:HasModifier("modifier_slark_shadow_dance") or
                                  unit:HasModifier("modifier_dark_willow_shadow_realm_buff")
        
        if isEligible and not hasExcludedModifier then
            local distance = (unit:GetOrigin() - entity:GetOrigin()):Length2D()
            if distance < closestDistance then
                closestDistance = distance
                closestHero = unit
            end
            enemyCount = enemyCount + 1
        end
    end
    
    return closestHero, enemyCount
end

function CommonAI:FindTarget(entity)
    self:log("FindTarget called for entity: " .. (entity and entity:GetUnitName() or "nil"))
    
    if not entity then
        self:log("Error: entity is nil in FindTarget")
        return nil
    end
    
    -- 打印搜索实体的基本信息
    self:log(string.format("搜索实体信息 - 名称: %s, 队伍: %d, 位置: %s", 
        entity:GetUnitName(),
        entity:GetTeamNumber(),
        tostring(entity:GetOrigin())
    ))
    
    -- 使用全局定义的索敌范围
    local enemies = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetOrigin(),
        nil,
        GLOBAL_SEARCH_RADIUS,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    
    -- 打印找到的所有单位
    self:log(string.format("找到 %d 个敌对单位", #enemies))
    for i, enemy in ipairs(enemies) do
        self:log(string.format("敌人 %d: %s, 队伍: %d, 位置: %s", 
            i,
            enemy:GetUnitName(),
            enemy:GetTeamNumber(),
            tostring(enemy:GetOrigin())
        ))
    end
    
    if #enemies > 0 then
        self:log("返回最近的敌人: " .. enemies[1]:GetUnitName())
        return enemies[1]
    end
    
    self:log("未找到任何敌人")
    return nil
end


function CommonAI:FindPreferredTarget(entity, preferredUnitNames)
    self:log("为实体调用 FindPreferredTarget: " .. (entity and entity:GetUnitName() or "nil"))
    if not entity then
        self:log("错误：FindPreferredTarget 中的实体为 nil")
        return nil, 0
    end

    -- 确保 preferredUnitNames 是一个表
    preferredUnitNames = type(preferredUnitNames) == "table" and preferredUnitNames or {preferredUnitNames}

    -- 设置查找标志，包括所有可能的敌人类型
    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
                  DOTA_UNIT_TARGET_FLAG_INVULNERABLE + 
                  DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD +
                  DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS

    -- 使用全局定义的索敌范围和新的标志
    local units = FindUnitsInRadius(entity:GetTeamNumber(), 
                                    entity:GetOrigin(), 
                                    nil, 
                                    entity:Script_GetAttackRange() + 300, 
                                    DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                    DOTA_UNIT_TARGET_ALL, 
                                    flags, 
                                    FIND_CLOSEST,
                                    false)

    local enemyCount = 0

    for _, unit in pairs(units) do
        local unitName = unit:GetUnitName()
        
        -- 只检查是否匹配优先单位名称
        for _, prefName in ipairs(preferredUnitNames) do
            if string.find(unitName, prefName, 1, true) then
                self:log("找到目标单位: " .. unitName)
                return unit, enemyCount
            end
        end
        
        enemyCount = enemyCount + 1
    end

    self:log("未找到表中的目标单位")
    return nil, enemyCount
end



    
function CommonAI:FindNearestVulnerableEnemy(entity)
    -- 记录函数调用
    CommonAI.log("FindNearestVulnerableEnemy被调用，实体: " .. (entity and entity:GetUnitName() or "nil"))
    
    -- 检查实体是否有效
    if not entity then
        CommonAI.log("错误：FindNearestVulnerableEnemy中的实体为nil")
        return nil
    end
    
    -- 设置查找标志，只包括魔法免疫敌人，不包括无敌单位
    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES 

    -- 在指定范围内查找敌人
    local enemies = FindUnitsInRadius(
        entity:GetTeamNumber(),    -- 查找单位的队伍
        entity:GetOrigin(),        -- 搜索的中心点
        nil,                       -- 用于视野检查的单位（此处不需要）
        GLOBAL_SEARCH_RADIUS,      -- 搜索半径（使用全局定义的值）
        DOTA_UNIT_TARGET_TEAM_ENEMY, -- 目标队伍（敌对）
        DOTA_UNIT_TARGET_ALL,      -- 目标类型（所有单位）
        flags,                     -- 只包括魔法免疫敌人的标志
        FIND_CLOSEST,              -- 搜索顺序（最近的）
        false                      -- 是否可以看到单位（否）
    )
    
    -- 检查是否找到敌人
    if #enemies > 0 then
        -- 找到敌人，记录并返回最近的一个
        CommonAI.log("找到最近的可攻击敌人: " .. enemies[1]:GetUnitName())
        return enemies[1]
    else
        -- 没找到敌人，记录并返回nil
        CommonAI.log("未找到可攻击的敌人")
        return nil
    end
end

function CommonAI:FindNearestEnemyLastResort(entity)
    -- 记录函数调用
    self:log("FindNearestEnemyLastResort被调用 - 最后的寻敌手段，实体: " .. (entity and entity:GetUnitName() or "nil"))
    
    -- 检查实体是否有效
    if not entity then
        self:log("错误：FindNearestEnemyLastResort中的实体为nil")
        return nil
    end
    
    -- 设置查找标志
    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
                 DOTA_UNIT_TARGET_FLAG_INVULNERABLE + 
                 DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD +
                 DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS

    -- 首先尝试只寻找英雄单位
    local heroEnemies = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetOrigin(),
        nil,
        GLOBAL_SEARCH_RADIUS,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO, -- 只搜索英雄
        flags,
        FIND_ANY_ORDER,  -- 改为ANY_ORDER以获取所有单位
        false
    )
    
    -- 找到除caipan外且不带wearable modifier的最近英雄
    local nearestHero = nil
    local nearestHeroDist = GLOBAL_SEARCH_RADIUS
    for _, hero in ipairs(heroEnemies) do
        if hero:GetUnitName() ~= "caipan" and not hero:HasModifier("modifier_wearable") then
            local dist = (hero:GetOrigin() - entity:GetOrigin()):Length2D()
            if dist < nearestHeroDist then
                nearestHero = hero
                nearestHeroDist = dist
            end
        end
    end
    
    if nearestHero then
        self:log("最后手段找到最近的敌方英雄: " .. nearestHero:GetUnitName())
        return nearestHero
    end
    
    -- 如果没找到合适的英雄，则搜索所有单位
    local allEnemies = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetOrigin(),
        nil,
        GLOBAL_SEARCH_RADIUS,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        flags,
        FIND_ANY_ORDER,  -- 改为ANY_ORDER以获取所有单位
        false
    )
    
    -- 找到除caipan和thinker外且不带wearable modifier的最近单位
    local nearestUnit = nil
    local nearestDist = GLOBAL_SEARCH_RADIUS
    for _, enemy in ipairs(allEnemies) do
        if enemy:GetUnitName() ~= "npc_dota_thinker" and 
           enemy:GetUnitName() ~= "caipan" and
           not enemy:HasModifier("modifier_wearable") then
            local dist = (enemy:GetOrigin() - entity:GetOrigin()):Length2D()
            if dist < nearestDist then
                nearestUnit = enemy
                nearestDist = dist
            end
        end
    end
    
    if nearestUnit then
        self:log("最后手段找到最近的非英雄敌人: " .. nearestUnit:GetUnitName())
        return nearestUnit
    else
        self:log("最后手段未找到任何敌人")
        return nil
    end
end

function CommonAI:FindNearestNoSelfAllyLastResort(entity)
    -- 设置查找标志，包括所有可能的敌人类型
    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
    DOTA_UNIT_TARGET_FLAG_INVULNERABLE + 
    DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD +
    DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
    -- 使用全局定义的索敌范围
    local allies = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetOrigin(),
        nil,
        GLOBAL_SEARCH_RADIUS,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        flags, -- 排除幻象和召唤单位
        FIND_CLOSEST,
        false
    )
    -- 确保选中的单位不是自己
    for _, ally in pairs(allies) do
        self:log("找到友方单位: " .. ally:GetUnitName() .. " 位置: " .. tostring(ally:GetOrigin()))
        if ally ~= entity then  -- 排除自身
            return ally
        end
    end
    return nil
end


function CommonAI:FindNearestNoSelfAlly(entity)
    local allies = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetOrigin(),
        nil,
        GLOBAL_SEARCH_RADIUS,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        FIND_CLOSEST,
        false
    )
    -- 常规查找最近的非自身单位
    for _, ally in pairs(allies) do
        self:log("找到友方单位: " .. ally:GetUnitName() .. " 位置: " .. tostring(ally:GetOrigin()))
        if ally ~= entity then
            return ally
        end
    end
    return nil
end

function CommonAI:FindNearestNoSelfAllyHero(entity)
    local allies = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetOrigin(), 
        nil,
        GLOBAL_SEARCH_RADIUS,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        FIND_CLOSEST,
        false
    )
    -- 查找最近的非自身友方英雄
    for _, ally in pairs(allies) do
        self:log("找到友方英雄: " .. ally:GetUnitName() .. " 位置: " .. tostring(ally:GetOrigin()))
        if ally ~= entity then
            return ally
        end
    end
    return nil
end


--[[
FindBestAllyHeroTarget - 寻找最佳友方英雄目标
功能: 在技能施法范围内寻找符合条件的友方英雄单位。会自动识别技能是否为指向性技能。

参数说明:
--[[
    FindBestAllyHeroTarget - 寻找最佳友方目标单位
    参数:
    - entity: 施法者单位
    - ability: 技能对象
    - requiredModifiers: table, 需要检查的buff名称列表, 可选
    - minRemainingTime: number, buff剩余时间阈值(秒), 可选
    - sortBy: string, 排序方式, 可选:
        - "health_percent": 按血量百分比排序(默认)
        - "health": 按当前血量排序
        - "attack": 按攻击力排序
        - "distance": 按与施法者距离排序
        - "mana_percent": 按蓝量百分比排序
        - "nearest_to_enemy": 按与敌方英雄距离排序
    - forceHero: bool, 是否只选择英雄单位, 默认true
    - canBeSelf: bool, 是否可以选择自己, 默认true
    返回:
    - 符合条件的最佳目标单位,如果没有符合条件的目标则返回nil

使用示例:
-- 示例1: 简单使用,寻找血量百分比最低的友方英雄
local target = self:FindBestAllyHeroTarget(
    caster,    -- 施法者
    ability    -- 技能
)

-- 示例2: 完整参数使用
local target = self:FindBestAllyHeroTarget(
    caster,                     -- 施法者
    ability,                    -- 技能
    {"modifier_my_buff"},       -- 检查是否需要刷新buff
    5,                          -- buff剩余时间少于5秒视为需要刷新
    "health_percent"            -- 选择血量百分比最低的目标
)
--]]

local DOTA_ABILITY_BEHAVIOR = {
    LAST_RESORT_POINT = -2147483648,
    NONE = 0,
    HIDDEN = 1,
    PASSIVE = 2,
    NO_TARGET = 4,
    UNIT_TARGET = 8,
    POINT = 16,
    AOE = 32,
    NOT_LEARNABLE = 64,
    CHANNELLED = 128,
    ITEM = 256,
    TOGGLE = 512,
    DIRECTIONAL = 1024,
    IMMEDIATE = 2048,
    AUTOCAST = 4096,
    OPTIONAL_UNIT_TARGET = 8192,
    OPTIONAL_POINT = 16384,
    OPTIONAL_NO_TARGET = 32768,
    AURA = 65536,
    ATTACK = 131072,
    DONT_RESUME_MOVEMENT = 262144,
    ROOT_DISABLES = 524288,
    UNRESTRICTED = 1048576,
    IGNORE_PSEUDO_QUEUE = 2097152,
    IGNORE_CHANNEL = 4194304,
    DONT_CANCEL_MOVEMENT = 8388608,
    DONT_ALERT_TARGET = 16777216,
    DONT_RESUME_ATTACK = 33554432,
    NORMAL_WHEN_STOLEN = 67108864,
    IGNORE_BACKSWING = 134217728,
    RUNE_TARGET = 268435456,
    DONT_CANCEL_CHANNEL = 536870912,
    VECTOR_TARGETING = 1073741824
}


function CommonAI:FindBestAllyHeroTarget(entity, ability, requiredModifiers, minRemainingTime, sortBy, forceHero, canBeSelf)
    -- 设置默认值
    requiredModifiers = requiredModifiers or {}
    minRemainingTime = minRemainingTime or 0
    sortBy = sortBy or "health_percent" -- 默认按生命百分比排序
    if forceHero == nil then forceHero = true end -- 默认强制英雄单位
    if canBeSelf == nil then canBeSelf = true end -- 默认可以选择自己

    -- 获取技能行为和施法距离
    local behavior = self:GetAbilityBehavior(ability, 0, 0)
    local isTargetAbility = (bit.band(behavior, DOTA_ABILITY_BEHAVIOR.UNIT_TARGET) ~= 0)
    local castRange = self:GetSkillCastRange(entity, ability)
    local searchRadius = 0

    -- 根据技能类型决定搜索范围
    if isTargetAbility then
        searchRadius = castRange + 200
    else
        local aoeRadius = self:GetSkillAoeRadius(ability)
        searchRadius = castRange + aoeRadius + 200
    end

    local targetType = forceHero and DOTA_UNIT_TARGET_HERO or DOTA_UNIT_TARGET_ALL

    local allies = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetOrigin(), 
        nil,
        searchRadius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        targetType,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        FIND_ANY_ORDER,
        false
    )

    -- 过滤并排序符合条件的单位
    local validHeroes = {}
    local validNonHeroes = {}
    local selfValid = false
    
    for _, ally in pairs(allies) do
        -- 检查是否为自身且不允许选择自身
        if not canBeSelf and ally == entity then
            goto continue
        end
        if #requiredModifiers > 0 then
            local needRefresh = false
            for _, modifier in ipairs(requiredModifiers) do
                local modifiers = ally:FindAllModifiersByName(modifier)
                if #modifiers > 0 then
                    local maxRemainingTime = 0
                    for _, modifierInstance in ipairs(modifiers) do
                        local remainingTime = modifierInstance:GetRemainingTime()
                        if remainingTime > maxRemainingTime then
                            maxRemainingTime = remainingTime
                        end
                    end
                    
                    if maxRemainingTime > minRemainingTime then
                        self:log(string.format("单位 %s 的 %s 状态剩余时间 %.2f 秒足够,跳过", ally:GetUnitName(), modifier, maxRemainingTime))
                        needRefresh = false
                        break
                    else
                        self:log(string.format("单位 %s 的 %s 状态剩余时间 %.2f 秒不足", ally:GetUnitName(), modifier, maxRemainingTime))
                        needRefresh = true
                    end
                else
                    self:log(string.format("单位 %s 没有 %s 状态", ally:GetUnitName(), modifier))
                    needRefresh = true
                end
            end

            if not needRefresh then
                goto continue
            end
        end

        -- 检查是否为自身并标记
        if ally == entity then
            selfValid = true
        end

        -- 根据单位类型分别加入不同的列表
        if ally:IsHero() then
            table.insert(validHeroes, ally)
        else
            table.insert(validNonHeroes, ally)
        end
        
        ::continue::
    end

    -- 排序函数
    local sortFunction = function(a, b)
        if sortBy == "health_percent" then
            local healthPercentA = a:GetHealthPercent()
            local healthPercentB = b:GetHealthPercent()
            if healthPercentA == healthPercentB then
                return a:GetEntityIndex() < b:GetEntityIndex()
            end
            return healthPercentA < healthPercentB
        elseif sortBy == "health" then
            local healthA = a:GetHealth()
            local healthB = b:GetHealth()
            if healthA == healthB then
                return a:GetEntityIndex() < b:GetEntityIndex()
            end
            return healthA < healthB
        elseif sortBy == "attack" then
            -- 使用当前最小最大攻击力的平均值
            local attackA = (a:GetDamageMin() + a:GetDamageMax()) / 2
            local attackB = (b:GetDamageMin() + b:GetDamageMax()) / 2
            
            if attackA == attackB then
                return a:GetEntityIndex() < b:GetEntityIndex()
            end
            return attackA > attackB
        elseif sortBy == "distance" then
            local distA = (a:GetOrigin() - entity:GetOrigin()):Length2D()
            local distB = (b:GetOrigin() - entity:GetOrigin()):Length2D()
            if distA == distB then
                return a:GetEntityIndex() < b:GetEntityIndex()
            end
            return distA < distB
        elseif sortBy == "mana_percent" then
            local manaPercentA = a:GetManaPercent()
            local manaPercentB = b:GetManaPercent()
            if manaPercentA == manaPercentB then
                return a:GetEntityIndex() < b:GetEntityIndex()
            end
            return manaPercentA < manaPercentB
        elseif sortBy == "nearest_to_enemy" then
            -- 如果是自身且允许选择自身，优先级最高
            if canBeSelf then
                if a == entity then return true end
                if b == entity then return false end
            end
            
            local enemies = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetOrigin(),
                nil,
                1500,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                FIND_ANY_ORDER,
                false
            )
            
            local minDistA = math.huge
            local minDistB = math.huge
            
            if #enemies > 0 then
                for _, enemy in pairs(enemies) do
                    local distA = (a:GetOrigin() - enemy:GetOrigin()):Length2D()
                    local distB = (b:GetOrigin() - enemy:GetOrigin()):Length2D()
                    minDistA = math.min(minDistA, distA)
                    minDistB = math.min(minDistB, distB)
                end
            end
            
            if minDistA == minDistB then
                return a:GetEntityIndex() < b:GetEntityIndex()
            end
            return minDistA < minDistB
        end
        
        -- 如果没有匹配到任何排序方式，使用EntityIndex作为默认排序
        return a:GetEntityIndex() < b:GetEntityIndex()
    end

    -- 分别对英雄和非英雄单位进行排序
    table.sort(validHeroes, sortFunction)
    table.sort(validNonHeroes, sortFunction)

    -- 如果有符合条件的英雄，优先返回英雄
    if #validHeroes > 0 then
        local target = validHeroes[1]
        self:log(string.format("选择英雄目标: %s", target:GetUnitName()))
        return target
    end

    -- 如果没有英雄且允许非英雄单位，返回非英雄单位
    if not forceHero and #validNonHeroes > 0 then
        local target = validNonHeroes[1]
        self:log(string.format("选择非英雄目标: %s", target:GetUnitName()))
        return target
    end

    self:log("没有找到符合条件的目标")
    return nil
end

function CommonAI:GetLongestControlDebuff(entity)
    --print("GetLongestControlDebuff执行了")
    if not entity or not entity:IsAlive() then 
        --print("GetLongestControlDebuff: 单位无效或已死亡")
        return false 
    end
    
    local longest_duration = 0
    local longest_modifier = nil
    
    -- 获取单位身上所有modifier
    local modifiers = entity:FindAllModifiers()
    --print("GetLongestControlDebuff: 开始检查单位的所有modifier")
    
    -- 遍历所有modifier
    for _, modifier in pairs(modifiers) do
        local modifierName = modifier:GetName()
        -- 检查是否是眩晕或变羊或噩梦
        local isStun = modifier:IsStunDebuff()
        local isHex = modifier:IsHexDebuff()
        local isNightmare = (modifierName == "modifier_bane_nightmare")
        
        -- print(string.format("检查modifier: %s", modifierName))
        -- print(string.format("是否眩晕: %s", tostring(isStun)))
        -- print(string.format("是否变羊: %s", tostring(isHex)))
        -- print(string.format("是否噩梦: %s", tostring(isNightmare)))
        
        if isStun or isHex or isNightmare then
            local remaining_time = modifier:GetRemainingTime()
            --print(string.format("发现控制效果: %s, 剩余时间: %.2f", modifierName, remaining_time))
            -- 更新最长持续时间的modifier
            if remaining_time > longest_duration then
                longest_duration = remaining_time
                longest_modifier = modifier
                --print(string.format("更新最长控制效果为: %s, 持续时间: %.2f", modifierName, remaining_time))
            end
        end
    end
    
    -- 如果找到控制效果，返回modifier和剩余时间，否则返回false
    if longest_modifier then
        --print(string.format("最终返回控制效果: %s, 持续时间: %.2f", longest_modifier:GetName(), longest_duration))
        return longest_modifier, longest_duration
    end
    
    --print("GetLongestControlDebuff: 未找到任何控制效果")
    return false
end

function CommonAI:FindBestEnemyHeroTarget(entity, ability, requiredModifiers, minRemainingTime, sortBy, forceHero)
    -- 设置默认值
    requiredModifiers = requiredModifiers or {}
    minRemainingTime = minRemainingTime or 0
    sortBy = sortBy or "distance" -- 默认按距离排序

    if self:containsStrategy(self.global_strategy, "不允许对非英雄释放控制") then
        forceHero = true -- 如果有"允许对非英雄释放技能"策略，则默认不强制英雄单位
       
    else
        if forceHero == nil then 
            forceHero = false -- 没有该策略时保持原来的默认值，强制英雄单位
        end
    end

    -- 获取技能行为和施法距离
    local behavior = self:GetAbilityBehavior(ability, 0, 0)
    local isTargetAbility = (bit.band(behavior, DOTA_ABILITY_BEHAVIOR.UNIT_TARGET) ~= 0)
    local castRange = self:GetSkillCastRange(entity, ability)
    local searchRadius = 0

    -- 根据技能类型决定搜索范围
    if isTargetAbility then
        searchRadius = castRange + 200
    else
        local aoeRadius = self:GetSkillAoeRadius(ability)
        searchRadius = castRange + aoeRadius + 200
    end
    
    -- 确保搜索范围不小于攻击范围
    local attackRange = self.entity:Script_GetAttackRange() + 100
    if searchRadius < attackRange then
        searchRadius = attackRange
    end

    local targetType = forceHero and DOTA_UNIT_TARGET_HERO or DOTA_UNIT_TARGET_ALL

    local enemies = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetOrigin(), 
        nil,
        searchRadius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        targetType,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
        FIND_ANY_ORDER,
        false
    )

    -- 过滤并排序符合条件的单位
    local validHeroes = {}
    local validNonHeroes = {}
    
    for _, enemy in pairs(enemies) do
        if #requiredModifiers > 0 then
            local hasAllModifiers = true
            for _, modifier in ipairs(requiredModifiers) do
                local modifiers = enemy:FindAllModifiersByName(modifier)
                if #modifiers > 0 then
                    local maxRemainingTime = 0
                    for _, modifierInstance in ipairs(modifiers) do
                        local remainingTime = modifierInstance:GetRemainingTime()
                        if remainingTime > maxRemainingTime then
                            maxRemainingTime = remainingTime
                        end
                    end
                    
                    if maxRemainingTime > minRemainingTime then
                        self:log(string.format("单位 %s 的 %s 状态剩余时间 %.2f 秒足够", enemy:GetUnitName(), modifier, maxRemainingTime))
                        hasAllModifiers = false
                        break
                    end
                end
            end

            if not hasAllModifiers then
                goto continue
            end
        end

        -- 根据单位类型分别加入不同的列表
        if enemy:IsHero() then
            table.insert(validHeroes, enemy)
        else
            table.insert(validNonHeroes, enemy)
        end
        
        ::continue::
    end

    -- 排序函数
    local sortFunction = function(a, b)
        if sortBy == "control" then
            local castPoint = self:GetRealCastPoint(ability) + 0.2 + minRemainingTime 
            local modifierA, durationA = self:GetLongestControlDebuff(a)
            local modifierB, durationB = self:GetLongestControlDebuff(b)
            
            -- 如果控制时间大于施法前摇，将其排到后面
            if (durationA and durationA > castPoint) and (durationB and durationB > castPoint) then
                -- 如果都超过施法前摇，按距离排序
                local distA = (a:GetOrigin() - entity:GetOrigin()):Length2D()
                local distB = (b:GetOrigin() - entity:GetOrigin()):Length2D()
                return distA < distB
            end
            
            if (durationA and durationA > castPoint) then return false end
            if (durationB and durationB > castPoint) then return true end
            
            -- 如果两个单位的控制状态不同
            if (not durationA) ~= (not durationB) then
                -- 没被控制的排在前面
                return not durationA
            end
            
            if durationA and durationB and math.abs(durationA - durationB) > 0.01 then
                -- 控制时间短的排在前面
                return durationA < durationB
            end
            
            -- 如果控制状态相同，按距离排序
            local distA = (a:GetOrigin() - entity:GetOrigin()):Length2D()
            local distB = (b:GetOrigin() - entity:GetOrigin()):Length2D()
            return distA < distB

        elseif sortBy == "distance" then
            local distA = (a:GetOrigin() - entity:GetOrigin()):Length2D()
            local distB = (b:GetOrigin() - entity:GetOrigin()):Length2D()
            return distA < distB
        elseif sortBy == "channeling" then
            -- 首先按是否在持续施法排序
            local aChanneling = a:IsChanneling()
            local bChanneling = b:IsChanneling()
            
            if aChanneling ~= bChanneling then
                return aChanneling
            end
            
            local distA = (a:GetOrigin() - entity:GetOrigin()):Length2D()
            local distB = (b:GetOrigin() - entity:GetOrigin()):Length2D()
            return distA < distB
        elseif sortBy == "dispellable_buffs" then
            -- 计算增益BUFF数量
            local function CountBuffs(unit)
                local count = 0
                local modifiers = unit:FindAllModifiers()
                for _, modifier in pairs(modifiers) do
                    if modifier and not modifier:IsDebuff() then
                        count = count + 1
                    end
                end
                return count
            end
            
            local aBuffCount = CountBuffs(a)
            local bBuffCount = CountBuffs(b)
            
            if aBuffCount ~= bBuffCount then
                return aBuffCount > bBuffCount  -- BUFF数量多的排在前面
            end
            
            -- 如果BUFF数量相同，按距离排序
            local distA = (a:GetOrigin() - entity:GetOrigin()):Length2D()
            local distB = (b:GetOrigin() - entity:GetOrigin()):Length2D()
            return distA < distB
        elseif sortBy == "health_percent" then
            return a:GetHealthPercent() < b:GetHealthPercent()
        elseif sortBy == "health" then
            return a:GetHealth() < b:GetHealth()
        elseif sortBy == "attack" then
            return a:GetAttackDamage() > b:GetAttackDamage()
        elseif sortBy == "mana_percent" then
            return a:GetManaPercent() < b:GetManaPercent()
        elseif sortBy == "threat" then
            -- 威胁度评估：优先攻击距离近且血量低的目标
            local distA = (a:GetOrigin() - entity:GetOrigin()):Length2D()
            local distB = (b:GetOrigin() - entity:GetOrigin()):Length2D()
            local threatA = (1000 - distA) * (100 - a:GetHealthPercent())
            local threatB = (1000 - distB) * (100 - b:GetHealthPercent())
            return threatA > threatB
        end
        return false
    end

    -- 分别对英雄和非英雄单位进行排序
    table.sort(validHeroes, sortFunction)
    table.sort(validNonHeroes, sortFunction)

    -- 如果有符合条件的英雄，优先返回英雄
    if #validHeroes > 0 then
        local target = validHeroes[1]
        -- 单独检查控制状态
        if sortBy == "control" then
            local castPoint = self:GetRealCastPoint(ability) + 0.2 + minRemainingTime 
            local modifier, duration = self:GetLongestControlDebuff(target)
            if duration and duration > castPoint then
                self:log(string.format("目标被控制时间(%.2f)大于施法前摇(%.2f)，放弃选择", duration, castPoint))
                return nil
            end
        end
        self:log(string.format("选择敌方英雄目标: %s", target:GetUnitName()))
        return target
    end

    -- 如果没有英雄且允许非英雄单位，返回非英雄单位
    if not forceHero and #validNonHeroes > 0 then
        local target = validNonHeroes[1]
        self:log(string.format("选择敌方非英雄目标: %s", target:GetUnitName()))
        return target
    end

    self:log("没有找到符合条件的敌方目标")
    return nil
end

--[[
FindBestEnemyHeroTarget - 寻找最佳敌方目标单位
功能: 在技能施法范围内寻找符合条件的敌方单位。会自动识别技能是否为指向性技能。

参数说明:
- entity: 施法者单位
- ability: 技能对象
- requiredModifiers: table, 需要检查的buff名称列表, 可选
- minRemainingTime: number, buff剩余时间阈值(秒), 可选
- sortBy: string, 排序方式, 可选:
    - "distance": 按与施法者距离排序(默认)
    - "health_percent": 按血量百分比排序
    - "health": 按当前血量排序
    - "attack": 按攻击力排序
    - "mana_percent": 按蓝量百分比排序
    - "threat": 按威胁度排序(结合距离和血量)
- forceHero: bool, 是否只选择英雄单位, 默认true

返回:
- 符合条件的最佳目标单位,如果没有符合条件的目标则返回nil

使用示例:
-- 示例1: 简单使用,寻找最近的敌方英雄
local target = self:FindBestEnemyHeroTarget(
    caster,    -- 施法者
    ability    -- 技能
)

-- 示例2: 完整参数使用
local target = self:FindBestEnemyHeroTarget(
    caster,                     -- 施法者
    ability,                    -- 技能
    {"modifier_stunned"},       -- 检查是否有眩晕状态
    1,                          -- 状态剩余时间少于1秒
    "threat",                   -- 按威胁度排序
    true                        -- 只选择英雄单位
)
--]]



function CommonAI:FindAllyTarget(entity)
    -- 使用全局定义的索敌范围
    local allies = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetOrigin(),
        nil,
        GLOBAL_SEARCH_RADIUS,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        0,
        FIND_CLOSEST,
        false
    )
    if #allies > 0 then
        return allies[1]
    end
    return nil
end