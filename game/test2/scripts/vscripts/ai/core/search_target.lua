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
                                  unit:HasModifier("modifier_dark_willow_shadow_realm_buff") or
                                  unit:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")

        
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

    -- 根据 self.target 是否存在决定搜索范围
    local searchRadius = GLOBAL_SEARCH_RADIUS

    -- 使用确定的搜索范围
    local units = FindUnitsInRadius(entity:GetTeamNumber(), 
                                    entity:GetOrigin(), 
                                    nil, 
                                    searchRadius, 
                                    DOTA_UNIT_TARGET_TEAM_ENEMY, 
                                    DOTA_UNIT_TARGET_ALL, 
                                    flags, 
                                    FIND_CLOSEST,
                                    false)

    local enemyCount = 0

    for _, unit in pairs(units) do
        local unitName = unit:GetUnitName()
        
        -- 检查是否有需要排除的modifier
        local hasExcludedModifier = unit:HasModifier("modifier_ringmaster_the_box_buff") or 
                                   unit:HasModifier("modifier_slark_depth_shroud") or
                                   unit:HasModifier("modifier_slark_shadow_dance") or 
                                   unit:HasModifier("modifier_dark_willow_shadow_realm_buff") or
                                   unit:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")

        -- 只有当单位没有被排除的modifier时才进行检查
        if not hasExcludedModifier then
            -- 只检查是否匹配优先单位名称
            for _, prefName in ipairs(preferredUnitNames) do
                if string.find(unitName, prefName, 1, true) then
                    self:log("找到目标单位: " .. unitName)
                    return unit, enemyCount
                end
            end
        end
        
        enemyCount = enemyCount + 1
    end

    self:log("未找到表中的目标单位")
    return nil, enemyCount
end

function CommonAI:FindWeakAIUnitTarget(entity)
    -- 首先寻找非幻象英雄单位
    local units = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetAbsOrigin(),
        nil,
        1500, -- 搜索范围
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
        FIND_CLOSEST,
        false
    )
    
    for _, unit in pairs(units) do
        if self:CanAttackTarget(entity, unit) then
            return unit
        end
    end
    
    -- 如果没找到非幻象英雄，则寻找其他可攻击单位
    units = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetAbsOrigin(),
        nil,
        1500,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    
    for _, unit in pairs(units) do
        if self:CanAttackTarget(entity, unit) then
            return unit
        end
    end
    
    return nil
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
    --self:log("FindNearestEnemyLastResort被调用 - 最后的寻敌手段，实体: " .. (entity and entity:GetUnitName() or "nil"))
    
    -- 检查实体是否有效
    if not entity then
        --self:log("错误：FindNearestEnemyLastResort中的实体为nil")
        return nil
    end
    
    -- 排除的单位名单
    local excludedUnits = {
        ["caipan"] = true,
        ["npc_dota_thinker"] = true,
        ["npc_dota_side_gunner"] = true, -- 新增排除的单位
    }
    
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
    
    -- 找到不在排除列表中且不带wearable modifier的最近英雄
    local nearestHero = nil
    local nearestHeroDist = GLOBAL_SEARCH_RADIUS
    for _, hero in ipairs(heroEnemies) do
        local unitName = hero:GetUnitName()
        if not excludedUnits[unitName] and not hero:HasModifier("modifier_wearable") then
            local dist = (hero:GetOrigin() - entity:GetOrigin()):Length2D()
            if dist < nearestHeroDist then
                nearestHero = hero
                nearestHeroDist = dist
            end
        end
    end
    
    if nearestHero then
        --self:log("最后手段找到最近的敌方英雄: " .. nearestHero:GetUnitName())
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
    
    -- 找到不在排除列表中且不带wearable modifier的最近单位
    local nearestUnit = nil
    local nearestDist = GLOBAL_SEARCH_RADIUS
    for _, enemy in ipairs(allEnemies) do
        local unitName = enemy:GetUnitName()
        if not excludedUnits[unitName] and not enemy:HasModifier("modifier_wearable") then
            local dist = (enemy:GetOrigin() - entity:GetOrigin()):Length2D()
            if dist < nearestDist then
                nearestUnit = enemy
                nearestDist = dist
            end
        end
    end
    
    if nearestUnit then
        --self:log("最后手段找到最近的非英雄敌人: " .. nearestUnit:GetUnitName())
        return nearestUnit
    else
        --self:log("最后手段未找到任何敌人")
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


function CommonAI:FindBestAllyHeroTarget(entity, ability, requiredModifiers, minRemainingTime, sortBy, forceHero, canBeSelf, allowIllusions)
    -- 设置默认值
    requiredModifiers = requiredModifiers or {}
    minRemainingTime = minRemainingTime or 0
    sortBy = sortBy or "health_percent"
    if forceHero == nil then forceHero = true end
    if canBeSelf == nil then canBeSelf = true end
    allowIllusions = allowIllusions or false  -- 新增参数默认值

    -- 获取技能行为和施法距离
    local behavior = self:GetSkill_Behavior(ability, 0, 0)
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

    local flags = DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
    if allowIllusions then
        flags = flags - DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS  -- 移除排除幻象标志
    end

    local allies = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetOrigin(), 
        nil,
        searchRadius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        targetType,
        flags,  -- 使用动态计算的flags
        FIND_ANY_ORDER,
        false
    )

    -- 过滤并排序符合条件的单位
    local validHeroes = {}
    local validNonHeroes = {}
    local selfValid = false
    
    -- 检查避免重复施法策略
    local checkDuplicateCast = self:containsStrategy(self.global_strategy, "避免重复施法") and entity:GetHealthPercent() > 10
    local abilityName = ability and ability:GetAbilityName() or ""
    
    -- 检查是否是电弧/磁场技能
    local isArcMagneticField = (abilityName == "arc_warden_magnetic_field")
    
    for _, ally in pairs(allies) do
        -- 检查是否为自身且不允许选择自身
        if ally:IsUnselectable() then
            goto continue
        end
        if not canBeSelf and ally == entity then
            goto continue
        end
        
        -- 检查该目标是否在短时间内已被相同技能选为目标
        if checkDuplicateCast and Main.targetLockInfo then
            local currentTime = GameRules:GetGameTime()
            if Main.targetLockInfo.target == ally and 
                Main.targetLockInfo.caster ~= entity and
                Main.targetLockInfo.abilityName == abilityName and
                currentTime - Main.targetLockInfo.timestamp < 3 then
                self:log(string.format("单位 %s 在2秒内已被技能 %s 选为目标，跳过", ally:GetUnitName(), abilityName))
                goto continue
            end
        end
        
        -- 电弧/磁场技能的特殊处理：检查友军攻击范围内是否有敌人
        if isArcMagneticField and sortBy == "nearest_to_enemy" then
            local attackRange = ally:Script_GetAttackRange()
            if attackRange then
                local enemiesInRange = FindUnitsInRadius(
                    ally:GetTeamNumber(),
                    ally:GetOrigin(),
                    nil,
                    attackRange,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                    FIND_ANY_ORDER,
                    false
                )
                
                if #enemiesInRange == 0 then
                    self:log(string.format("单位 %s 攻击范围内没有敌人，不适合电弧/磁场技能", ally:GetUnitName()))
                    goto continue
                else
                    self:log(string.format("单位 %s 攻击范围内有 %d 个敌人，适合电弧/磁场技能", ally:GetUnitName(), #enemiesInRange))
                end
            end
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
        local compareValues = function()
            if sortBy == "health_percent" then
                return a:GetHealthPercent(), b:GetHealthPercent()
            elseif sortBy == "health" then
                return a:GetHealth(), b:GetHealth()
            elseif sortBy == "attack" then
                -- 使用当前最小最大攻击力的平均值
                return (a:GetDamageMin() + a:GetDamageMax()) / 2, (b:GetDamageMin() + b:GetDamageMax()) / 2
            elseif sortBy == "distance" then
                return (a:GetOrigin() - entity:GetOrigin()):Length2D(), (b:GetOrigin() - entity:GetOrigin()):Length2D()
            elseif sortBy == "mana_percent" then
                return a:GetManaPercent(), b:GetManaPercent()
            elseif sortBy == "max_mana" then
                return a:GetMaxMana(), b:GetMaxMana()
            elseif sortBy == "nearest_to_enemy" then
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
                
                return minDistA, minDistB
            elseif sortBy == "dispellable_debuffs" then
                -- 使用GetPurgableDebuffsCount函数计算可驱散的debuff数量
                return a:GetPurgableDebuffsCount(), b:GetPurgableDebuffsCount()
            end
            return 0, 0
        end

        local valueA, valueB = compareValues()
        
        if valueA == valueB then
            -- 当值相等时
            if canBeSelf then
                -- 如果可以选择自己，且其中一个是自己，优先选择自己
                if a == entity then return true end
                if b == entity then return false end
            end
            -- 使用实体ID来确保排序的一致性
            return a:GetEntityIndex() < b:GetEntityIndex()
        end
        
        -- attack和dispellable_debuffs比较是从大到小,其他都是从小到大
        if sortBy == "attack" or sortBy == "dispellable_debuffs" then
            return valueA > valueB
        else
            return valueA < valueB
        end
    end

    -- 分别对英雄和非英雄单位进行排序
    table.sort(validHeroes, sortFunction)
    table.sort(validNonHeroes, sortFunction)

    -- 如果有符合条件的英雄，优先返回英雄
    if #validHeroes > 0 then
        local target = validHeroes[1]
        
        -- 记录目标选择信息以避免重复施法
        if checkDuplicateCast then
            if not Main.targetLockInfo then Main.targetLockInfo = {} end
            Main.targetLockInfo = {
                target = target,
                caster = entity,
                abilityName = abilityName,
                timestamp = GameRules:GetGameTime()
            }
            self:log(string.format("记录友军施法目标: %s，施法者: %s，技能: %s", target:GetUnitName(), entity:GetUnitName(), abilityName))
        end
        
        self:log(string.format("选择英雄目标: %s", target:GetUnitName()))
        return target
    end

    -- 如果没有英雄且允许非英雄单位，返回非英雄单位
    if not forceHero and #validNonHeroes > 0 then
        local target = validNonHeroes[1]
        
        -- 记录非英雄单位目标选择信息以避免重复施法
        if checkDuplicateCast then
            if not Main.targetLockInfo then Main.targetLockInfo = {} end
            Main.targetLockInfo = {
                target = target,
                caster = entity,
                abilityName = abilityName,
                timestamp = GameRules:GetGameTime()
            }
            self:log(string.format("记录友军施法目标(非英雄): %s，施法者: %s，技能: %s", target:GetUnitName(), entity:GetUnitName(), abilityName))
        end
        
        self:log(string.format("选择非英雄目标: %s", target:GetUnitName()))
        return target
    end

    self:log("没有找到符合条件的目标")
    return nil
end

function CommonAI:GetLongestControlDebuff(entity)
    if not entity or not entity:IsAlive() then 
        return false 
    end
    
    local longest_duration = 0
    local longest_modifier = nil
    
    local modifiers = entity:FindAllModifiers()
    
    for _, modifier in pairs(modifiers) do
        local modifierName = modifier:GetName()
        -- 检查是否是眩晕、变羊、噩梦、恐惧或嘲讽
        local isStun = modifier:IsStunDebuff()
        local isHex = modifier:IsHexDebuff()
        local isNightmare = (modifierName == "modifier_bane_nightmare") 
        local isFear = modifier:IsFearDebuff()
        local isTaunt = modifier:IsTauntDebuff()
        
        if isStun or isHex or isNightmare or isFear or isTaunt then
            local remaining_time = modifier:GetRemainingTime()
            if remaining_time > longest_duration then
                longest_duration = remaining_time
                longest_modifier = modifier
            end
        end
    end
    
    if longest_modifier then
        return longest_modifier, longest_duration
    end
    
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
    local behavior = self:GetSkill_Behavior(ability, 0, 0)
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
    
    -- 确保搜索范围不小于目标距离
    if self.target then
        local distanceToTarget = (self.target:GetAbsOrigin() - self.entity:GetAbsOrigin()):Length2D()
        if searchRadius < distanceToTarget then
            searchRadius = distanceToTarget
        end
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
    
    -- 检查避免重复施法策略
    local checkDuplicateCast = self:containsStrategy(self.global_strategy, "避免重复施法") and sortBy == "control" and entity:GetHealthPercent() >10
    
    for _, enemy in pairs(enemies) do
        -- 检查该目标是否在短时间内已被选为目标
        if checkDuplicateCast and Main.targetLockInfo then
            local currentTime = GameRules:GetGameTime()
            if Main.targetLockInfo.target == enemy and 
               Main.targetLockInfo.caster ~= entity and
               currentTime - Main.targetLockInfo.timestamp < 1 then
                self:log(string.format("单位 %s 在0.5秒内已被其他单位选为目标，跳过", enemy:GetUnitName()))
                goto continue
            end
        end
    
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

    -- 函数用于计算单位冷却中的技能数量
    local function CountCooldownAbilities(unit)
        local count = 0
        for i = 0, unit:GetAbilityCount() - 1 do
            local ability = unit:GetAbilityByIndex(i)
            if ability and ability:GetCooldownTimeRemaining() > 0 then
                count = count + 1
            end
        end
        return count
    end

    -- 检查是否有单位有冷却中的技能
    local hasCooldownAbilities = false
    if sortBy == "cooldown_abilities" then
        for _, hero in pairs(validHeroes) do
            if CountCooldownAbilities(hero) > 0 then
                hasCooldownAbilities = true
                break
            end
        end
        
        if not hasCooldownAbilities and not forceHero then
            for _, nonHero in pairs(validNonHeroes) do
                if CountCooldownAbilities(nonHero) > 0 then
                    hasCooldownAbilities = true
                    break
                end
            end
        end
        
        -- 如果没有单位有冷却中的技能，直接返回nil
        if not hasCooldownAbilities then
            self:log("没有敌方单位有冷却中的技能")
            return nil
        end
    end

    -- 排序函数
    local sortFunction = function(a, b)
        if sortBy == "cooldown_abilities" then
            local aCount = CountCooldownAbilities(a)
            local bCount = CountCooldownAbilities(b)
            
            -- 如果两者都没有冷却中的技能，按距离排序
            if aCount == 0 and bCount == 0 then
                local distA = (a:GetOrigin() - entity:GetOrigin()):Length2D()
                local distB = (b:GetOrigin() - entity:GetOrigin()):Length2D()
                return distA < distB
            end
            
            -- 冷却技能数量多的排在前面
            if aCount ~= bCount then
                return aCount > bCount
            end
            
            -- 如果冷却技能数量相同，按距离排序
            local distA = (a:GetOrigin() - entity:GetOrigin()):Length2D()
            local distB = (b:GetOrigin() - entity:GetOrigin()):Length2D()
            return distA < distB
        elseif sortBy == "control" then
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
            -- 使用GetPurgableBuffsCount函数计算可驱散的增益BUFF数量
            local aBuffCount = a:GetPurgableBuffsCount()
            local bBuffCount = b:GetPurgableBuffsCount()
            
            if aBuffCount ~= bBuffCount then
                return aBuffCount > bBuffCount  -- 可驱散BUFF数量多的排在前面
            end
            
            -- 如果BUFF数量相同，按距离排序
            local distA = (a:GetOrigin() - entity:GetOrigin()):Length2D()
            local distB = (b:GetOrigin() - entity:GetOrigin()):Length2D()
            return distA < distB
        elseif sortBy == "health_percent" then
            return a:GetHealthPercent() < b:GetHealthPercent()
        elseif sortBy == "health" then
            return a:GetHealth() < b:GetHealth()
        elseif sortBy == "max_mana" then
            return a:GetMaxMana() > b:GetMaxMana()
        elseif sortBy == "attack" then
            return a:GetAttackDamage() > b:GetAttackDamage()
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
        
        -- 确保第一个目标在"cooldown_abilities"模式下有冷却技能
        if sortBy == "cooldown_abilities" and CountCooldownAbilities(target) == 0 then
            self:log("排序后的第一个英雄目标没有冷却中的技能，放弃选择")
            return nil
        end
        
        -- 记录目标选择信息以避免重复施法
        if checkDuplicateCast then
            if not Main.targetLockInfo then Main.targetLockInfo = {} end
            Main.targetLockInfo = {
                target = target,
                caster = entity,
                timestamp = GameRules:GetGameTime()
            }
            self:log(string.format("记录施法目标: %s，施法者: %s", target:GetUnitName(), entity:GetUnitName()))
        end
        
        self:log(string.format("选择敌方英雄目标: %s", target:GetUnitName()))

        return target
    end

    -- 如果没有英雄且允许非英雄单位，返回非英雄单位
    if not forceHero and #validNonHeroes > 0 then
        local target = validNonHeroes[1]
        
        -- 确保第一个非英雄目标在"cooldown_abilities"模式下有冷却技能
        if sortBy == "cooldown_abilities" and CountCooldownAbilities(target) == 0 then
            self:log("排序后的第一个非英雄目标没有冷却中的技能，放弃选择")
            return nil
        end
        
        -- 记录非英雄单位目标选择信息以避免重复施法
        if checkDuplicateCast then
            if not Main.targetLockInfo then Main.targetLockInfo = {} end
            Main.targetLockInfo = {
                target = target,
                caster = entity,
                timestamp = GameRules:GetGameTime()
            }
            self:log(string.format("记录施法目标(非英雄): %s，施法者: %s", target:GetUnitName(), entity:GetUnitName()))
        end
        
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
    - "max_mana": 按最大魔法值排序，优先返回最大的
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

function GetDistancePointToLine(point, segStart, segEnd)
    local segment = segEnd - segStart
    local vecToPoint = point - segStart
    local t = vecToPoint:Dot(segment) / segment:Dot(segment)
    t = math.max(0, math.min(1, t))
    local projection = segStart + t * segment
    return (point - projection):Length2D()
end

function CommonAI:FindClosestUnblockedEnemyHero(entity, ability, isAoeAbility, aoeWidth )
    local castRange = self:GetSkillCastRange(entity, ability)
    print("【阻挡检测】开始搜索, 施法者: " .. entity:GetUnitName() .. ", 施法距离: " .. castRange)
    
    local enemyHeroes = FindUnitsInRadius(
        entity:GetTeamNumber(),
        entity:GetAbsOrigin(),
        nil,
        castRange,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
        FIND_CLOSEST,
        false
    )
    
    print("【阻挡检测】找到敌方英雄数量: " .. #enemyHeroes)
    for _, hero in pairs(enemyHeroes) do
        local realHeroStr = hero:IsTempestDouble() and "(假)" or "(真)"
        print("【阻挡检测】发现敌方英雄: " .. hero:GetUnitName() .. realHeroStr)
    end
    
    if #enemyHeroes == 0 then
        print("【阻挡检测】没有找到敌方英雄，返回nil")
        return nil
    end

    local bestTarget = nil
    local bestMinBlockDistance = -1
    print("\n【阻挡检测】开始检查每个敌方英雄的阻挡情况...")

    for i, enemyHero in pairs(enemyHeroes) do
        local heroPos = entity:GetAbsOrigin()
        local enemyPos = enemyHero:GetAbsOrigin()
        local distanceToEnemy = (enemyPos - heroPos):Length2D()
        
        local realHeroStr = enemyHero:IsTempestDouble() and "(假)" or "(真)"
        print("\n【阻挡检测】正在检查敌方英雄: " .. enemyHero:GetUnitName() .. realHeroStr)
        print("【阻挡检测】与施法者距离: " .. math.floor(distanceToEnemy))

        local allUnits = FindUnitsInRadius(
            entity:GetTeamNumber(),
            heroPos,
            nil,
            distanceToEnemy,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        print("【阻挡检测】搜索到可能的阻挡单位数量: " .. #allUnits)

        local closestDistanceToLine = 99999
        local closestBlockingUnit = nil

        for _, unit in pairs(allUnits) do
            if unit ~= entity and unit ~= enemyHero and 
               (unit:GetTeamNumber() == entity:GetTeamNumber() or not unit:IsHero()) then
                local distanceToLine = GetDistancePointToLine(unit:GetAbsOrigin(), heroPos, enemyPos)
                local unitTypeStr = unit:IsHero() and "(友方英雄)" or "(小兵)"
                
                print("【阻挡检测】检查潜在阻挡单位: " .. unit:GetUnitName() .. unitTypeStr)
                print("【阻挡检测】到施法路径的距离: " .. math.floor(distanceToLine))
                
                if isAoeAbility then
                    local distanceToTarget = (unit:GetAbsOrigin() - enemyPos):Length2D()
                    if distanceToTarget <= aoeWidth  then
                        print("【阻挡检测】单位在AOE范围内(" .. math.floor(distanceToTarget) .. " <= " .. aoeWidth  .. ")，不计入阻挡")
                        goto continue
                    end
                end

                if distanceToLine < closestDistanceToLine then
                    closestDistanceToLine = distanceToLine
                    closestBlockingUnit = unit
                    print("【阻挡检测】更新最近阻挡单位为: " .. unit:GetUnitName() .. unitTypeStr .. ", 阻挡距离: " .. math.floor(closestDistanceToLine))
                end

                ::continue::
            end
        end

        print("\n【阻挡检测】总结检查 " .. enemyHero:GetUnitName() .. realHeroStr .. " 的阻挡情况:")
        if closestBlockingUnit then
            local blockingUnitTypeStr = closestBlockingUnit:IsHero() and "(友方英雄)" or "(小兵)"
            print("【阻挡检测】最近阻挡单位: " .. closestBlockingUnit:GetUnitName() .. blockingUnitTypeStr)
            print("【阻挡检测】阻挡距离: " .. math.floor(closestDistanceToLine))
        else
            closestDistanceToLine = 99999
            print("【阻挡检测】没有找到阻挡单位")
        end
        print("【阻挡检测】当前记录的最佳阻挡距离: " .. math.floor(bestMinBlockDistance))

        if closestDistanceToLine > bestMinBlockDistance then
            bestMinBlockDistance = closestDistanceToLine
            bestTarget = enemyHero
            print("【阻挡检测】更新最佳目标为: " .. enemyHero:GetUnitName() .. realHeroStr .. 
                  ", 新的最佳阻挡距离: " .. math.floor(bestMinBlockDistance))
        end
    end
    
    if bestMinBlockDistance < 150 then
        local realHeroStr = bestTarget and (bestTarget:IsTempestDouble() and "(假)" or "(真)") or ""
        print("\n【阻挡检测】最终结果: 最佳目标 " .. (bestTarget and bestTarget:GetUnitName() or "nil") .. realHeroStr .. 
              " 的阻挡距离(" .. math.floor(bestMinBlockDistance) .. ")小于150，被阻挡，返回nil")
        return nil
    end
    
    local realHeroStr = bestTarget:IsTempestDouble() and "(假)" or "(真)"
    print("\n【阻挡检测】最终结果: 选定目标: " .. bestTarget:GetUnitName() .. realHeroStr .. 
          ", 最佳阻挡距离: " .. math.floor(bestMinBlockDistance))
    return bestTarget
end

-- Helper function to calculate perpendicular distance from a point to a line
function CommonAI:PerpendicularDistance(lineStart, lineEnd, point)
    local line = lineEnd - lineStart
    local pointVector = point - lineStart
    local lineLength = line:Length2D()
    
    -- Avoid division by zero
    if lineLength == 0 then
        return (point - lineStart):Length2D()
    end
    
    -- Calculate perpendicular distance
    local t = ((pointVector.x * line.x + pointVector.y * line.y) / (lineLength * lineLength))
    local projection = lineStart + line * t
    return (point - projection):Length2D()
end

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