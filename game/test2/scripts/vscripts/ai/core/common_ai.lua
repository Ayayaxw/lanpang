-- common_ai.lua

CommonAI = {}
CommonAI.__index = CommonAI  -- 添加这一行

--DEBUG_MODE = true  -- 当设为 true 时打印状态信息，设为 false 时不打印
if IsInToolsMode() then 
    DEBUG_MODE = true
else
    DEBUG_MODE = false
end
GLOBAL_SEARCH_RADIUS = 3500


require("ai/core/search_target")
require("ai/core/common_function")
require("ai/skill/skill_common")
require("ai/skill/ConditionFunctions")
require("ai/hero_ai/visage")

require("ai/skill/OnSpellCast")
require("ai/skill/SkillHandlers/EnemyTarget_InRange")
require("ai/skill/SkillHandlers/EnemyTarget_OutOfRange")

require("ai/skill/SkillHandlers/EnemyPoint_InCastRange")
require("ai/skill/SkillHandlers/EnemyPoint_InAoeRange")
require("ai/skill/SkillHandlers/EnemyPoint_OutOfRange")


require("ai/skill/SkillHandlers/AllyTarget_InRange")
require("ai/skill/SkillHandlers/AllyTarget_OutOfRange")

require("ai/skill/SkillInfo/GetSkill_CastPoint")
require("ai/skill/SkillInfo/GetSkill_CastRange")
require("ai/skill/SkillInfo/GetSkill_AoeRadius")

require("ai/skill/SkillInfo/GetSkill_DisabledSkills")
require("ai/skill/SkillInfo/GetSkill_Conditions")
require("ai/skill/SkillInfo/GetItem_Conditions")
require("ai/skill/SkillInfo/GetSkill_HighPrioritySkills")
require("ai/skill/SkillInfo/GetSkill_MediumPrioritySkills")
require("ai/skill/SkillInfo/GetSkill_TargetTeam")
require("ai/skill/SkillInfo/GetSkill_SelfCastSkill")
require("ai/skill/SkillInfo/Get_DodgableSkills")
require("ai/skill/SkillInfo/Get_DodgeSkills")



AIStates = {
    Idle = 0,
    Seek = 1,
    Attack = 2,
    CastSpell = 4,
    Channeling = 8,
    UseItem = 16,
    PostCast = 32,

}

function CommonAI:constructor(entity, overallStrategy, heroStrategy, thinkInterval, skillThresholds)
    -- 初始化策略
    self.global_strategy = overallStrategy or {"默认策略"}
    self.hero_strategy = heroStrategy or {"默认策略"}
    self.skillThresholds = skillThresholds or {}
    self.canReleaseIceBlast = false
    self:Ini_MediumPrioritySkills()
    self:Ini_DisabledSkills()
    self:Ini_HighPrioritySkills()
    self:Ini_SkillAoeRadius()
    self:Ini_SkillCastRange()
    self:Ini_SkillTargetTeam()
    self:Init_DodgableSkills()
    self:Init_DodgeSkills()
    self.toggleItems = {}
    self.autoCastItems = {}
    self.autoCastSkills = {}
    self.toggleSkills = {}
    self.entity = entity
    self:SetState(AIStates.Idle)
    self.lastSkillCastTimes = {} --某个技能的上一次释放时间
    self.morphling_next_morph_time = 0  -- 记录下次允许变身的时间
    self.SkillcastCount = 0 --技能的施法次数
    self.lastKnownPosition = nil--敌人上一次的位置
    self.currentTimer = nil  -- 初始化 currentTimer 属性
    self.id = tostring(entity:entindex())  -- 添加唯一标识符
    self.hasWaited = false  -- 添加一个标志来跟踪是否已经等待过
    self.nextThinkTime = thinkInterval or 0.1  -- 使用传入的间隔时间或默认值
    self.enemyUsedAbility = false  -- 对手是否放过技能
    self.needToDodge = false
end

function CommonAI.new(entity, overallStrategy, heroStrategy, thinkInterval,skillThresholds)
    local instance = setmetatable({}, CommonAI)  -- 直接使用 CommonAI 作为元表
    instance:constructor(entity, overallStrategy, heroStrategy, thinkInterval,skillThresholds)
    return instance
end

function CommonAI:Think(entity)
    self.entity = entity  -- 设置当前实体


    -- 检查实体是否存在
    if not entity or entity:IsNull() then
        self:log("[AI] 实体不存在，终止AI - Entity: " .. (entity and entity:GetName() or "nil"))
        return nil  -- 彻底停止AI循环
    end


    if self:containsStrategy(self.global_strategy, "仅仅控制召唤物") then
        self:log("仅仅控制召唤物")
        if self.entity:IsRealHero() then
            return nil
        end
    end

    if self.shouldStop == true then
        self:log("[AI] shouldStop为true，当前状态: " .. tostring(self.currentState))
        if self.currentState ~= AIStates.Idle then
            -- 设置状态为Idle
            self.currentState = AIStates.Idle
            self.pendingSpellCast = nil
            -- 记录日志
            entity:Stop()
            self:log("[AI] 执行停止命令，英雄: " .. entity:GetName())
            self:log("[STORM_TEST]收到停止指令，切换到Idle状态")
            
            -- 重置shouldStop标志
            self.shouldStop = false
        end
    end

    if hero_duel.EndDuel then
        self:log("[AI] 决斗结束，终止AI - 英雄: " .. entity:GetName())
        return nil
    end

    -- 英雄死亡继续循环，但不执行后续AI逻辑
    if not entity:IsAlive() then
        self:log("[AI] 英雄已死亡，等待复活 - 英雄: " .. entity:GetName())
        return 1  -- 1秒后继续检查
    end

    self.shouldturn = nil
    self:ProcessPendingSpellCast()
    self.target = nil
    self.attackTarget = nil

    if self.currentState == AIStates.Channeling and 
    self:IsSpecialChannelingHero(entity) then
     if not entity:IsChanneling() then
         self:log("特殊英雄持续施法结束，设置为空闲状态")
         self:SetState(AIStates.Idle)
     end
    elseif self.currentState == AIStates.CastSpell or 
            (self.currentState == AIStates.Channeling and 
            not self:IsSpecialChannelingHero(entity)) then
        self:log("正在施法中，跳过本次 AI 思考过程")
        return self.nextThinkTime
    end

    self:log("开始寻找目标...")
    
    -- 初始化变量
    local target, enemyHeroCount = self:FindHeroTarget(entity)
    self.enemyHeroCount = enemyHeroCount
    
    -- 1. 获取最后手段目标(无敌单位)
    self.lastResortTarget = self:FindNearestEnemyLastResort(entity)
    if self.lastResortTarget then
        self:log("找到无敌目标:", self.lastResortTarget:GetUnitName())
    end

    -- 2. 获取优先攻击目标
    local preferredTargets = {
        "npc_dota_unit_tombstone",
        "npc_dota_phoenix_sun", 
        "npc_dota_pugna_nether_ward",
        "npc_dota_juggernaut_healing_ward",
    }
    self.attackTarget = self:FindPreferredTarget(entity, preferredTargets)
    if self.attackTarget then
        self:log("找到优先攻击目标:", self.attackTarget:GetUnitName())
    end

    -- 3. 检查是否优先打小僵尸
    if self:containsStrategy(self.global_strategy, "优先打小僵尸") then
        self.attackTarget = self:FindPreferredTarget(entity, {
            "npc_dota_unit_undying_zombie_torso",
            "npc_dota_unit_undying_zombie"
        })
    end

    -- 4. 主要目标查找逻辑
    if not target or self:containsStrategy(self.global_strategy, "谁近打谁") then

        self:log("未找到英雄目标，寻找普通单位")
        target = self:FindTarget(entity)
        
        if target then
            self:log("找到普通目标")
        elseif self:containsStrategy(self.global_strategy, "攻击无敌单位") then
            self:log("转为攻击无敌单位")
            target = self.lastResortTarget
        end
    end

    -- 5. 特殊情况处理：卡尔和SD
    if not target and (entity:GetUnitName() == "npc_dota_hero_invoker" or 
                      entity:GetUnitName() == "npc_dota_hero_shadow_demon") then
        if self.lastResortTarget and
           (self.lastResortTarget:HasModifier("modifier_invoker_tornado") or 
            self.lastResortTarget:HasModifier("modifier_shadow_demon_disruption")) then
            target = self.lastResortTarget
            self:log("卡尔/SD特殊模式")
        end
    end

    -- 6. 最终目标确定
    if target then
        self.target = target

    elseif not self.attackTarget then
        return self.nextThinkTime
    end

    
    self.Ally = self:FindNearestNoSelfAlly(entity)

    -- -- 处理特定英雄的特殊逻辑 这里是火猫有魂的情况下
    -- self:AdjustAbilityCastRangeForSpecialHeroes(entity, target)

    if self:IsWeakIllusion(entity) then
        if self:containsStrategy(self.global_strategy, "不要优先拆墓碑、棒子") then
        
        elseif self:containsStrategy(self.global_strategy, "优先打小僵尸") then
            target = self.attackTarget
        else 
            -- Find nearest attackable target
            local units = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetAbsOrigin(),
                nil,
                1500, -- Search radius
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                FIND_CLOSEST,
                false
            )
            
            -- 如果找到非幻象英雄单位
            for _, unit in pairs(units) do
                if self:CanAttackTarget(entity, unit) then
                    target = unit
                    break
                end
            end

            -- 如果没找到非幻象英雄单位，寻找其他单位
            if not target then
                units = FindUnitsInRadius(
                    entity:GetTeamNumber(),
                    entity:GetAbsOrigin(),
                    nil,
                    1500, -- Search radius
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_CLOSEST,
                    false
                )
                
                for _, unit in pairs(units) do
                    if self:CanAttackTarget(entity, unit) then
                        target = unit
                        break
                    end
                end
            end
        end
    
        if target then 
            if target:IsInvulnerable() then
                -- 如果目标无敌,移动到目标位置
                local order = {
                    UnitIndex = self.entity:entindex(),
                    OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                    TargetIndex = target:entindex(),
                    Position = target:GetAbsOrigin()
                }
                ExecuteOrderFromTable(order)
                self:log("目标无敌,移动到目标位置")
            elseif not self:IsUnableToAttack(entity, target) then
                -- 目标不是无敌且可以攻击,执行攻击命令
                local order = {
                    UnitIndex = self.entity:entindex(),
                    OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                    TargetIndex = target:entindex(),
                    Position = target:GetAbsOrigin()
                }
                ExecuteOrderFromTable(order)
                self:log("弱幻象单位开始移动并攻击目标")
            else
                self:log("弱幻象单位当前无法攻击目标")
            end
        end
        return 1
    end


    if self:containsStrategy(self.global_strategy, "辅助模式") then
        if entity and entity:IsMoving() then
            return self.nextThinkTime
        end
    end

    local skill, castRange, aoeRadius
    if target then
        skill, castRange, aoeRadius = self:FindBestAbilityToUse(entity,target)
    end

    if skill then
        skill, castRange, aoeRadius = self:HandleEarthSpiritLogic(entity, skill, castRange, aoeRadius)
        
        local abilityInfo = self:GetAbilityInfo(skill, castRange, aoeRadius)

        -- 处理施法后移动的逻辑
        if target and self.currentState == AIStates.PostCast then
            local returnValue = self:HandlePostCastMovement(entity, target, abilityInfo)
            if returnValue ~= nil then
                return returnValue
            end
        end

        self:log(string.format("准备施放技能 %s", abilityInfo.abilityName))
        target = self.target
        if target then
            -- 处理特殊技能的逻辑
            local result = self:AdjustAbilityTarget(entity, abilityInfo, target)
            if result ~= false then
                target = result
            end

            

            local targetInfo = self:GetTargetInfo(target, entity)
            
            self:log("敌人信息获取完毕")

            -- 检查是否能施放技能
            if not self:IsUnableToCastAbility(entity,skill) then
                -- 根据技能类型进行施法
                if bit.band(abilityInfo.abilityBehavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
                    self:HandleUnitTargetAbility(entity, abilityInfo, target, targetInfo)
                elseif bit.band(abilityInfo.abilityBehavior, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
                    self:HandlePointTargetAbility(entity, abilityInfo, target, targetInfo)
                elseif bit.band(abilityInfo.abilityBehavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
                    self:HandleNoTargetAbility(entity, abilityInfo, target, targetInfo)
                else
                    self:log("未知的技能类型")
                end
            else
                -- 处理无法施法的情况
                self:HandleUnableToCast(entity, target, abilityInfo, targetInfo)
            end
        else
            -- 处理没有找到目标的情况
            if self.attackTarget then
                self:log("没有找到目标，但是有攻击目标1")
                return self:HandleAttack(self.attackTarget)
            else
                self:HandleNoTargetFound(entity)
            end
        end
    else

        if target then 
            self:log("攻击target")
            return self:HandleAttack(target)
        elseif self.attackTarget then
            self:log("有攻击目标2")
            return self:HandleAttack(self.attackTarget)
        else
            return self.nextThinkTime
        end
        self:log("没有找到技能，执行攻击逻辑")

        
    end

    return self.nextThinkTime
end


function CommonAI:HandleEarthSpiritLogic(entity, skill, castRange, aoeRadius)
    local stoneCallerAbility = entity:FindAbilityByName("earth_spirit_stone_caller")
    local stone_charger = 0

    if stoneCallerAbility then
        if entity:GetHeroFacetID() ~= 2 then
            stone_charger = stoneCallerAbility:GetCurrentAbilityCharges()
        else
            if stoneCallerAbility:IsFullyCastable() then
                stone_charger = 1
            else 
                stone_charger = 0
            end
        end
    end

--[[     if skill:GetName() == "earth_spirit_rolling_boulder" then
        if stone_charger > 0 then
            local entityPos = entity:GetAbsOrigin()
            local targetPos = self.target:GetAbsOrigin()
            local direction = (targetPos - entityPos):Normalized()
            local distanceToTarget = (targetPos - entityPos):Length2D()
            
            -- 调整搜索距离
            local searchDistance = math.min(distanceToTarget, 950)
            local endPoint = entityPos + direction * searchDistance
            local width = 180
    
            local unitsInLine = FindUnitsInLine(
                entity:GetTeamNumber(),
                entityPos,
                endPoint,
                nil,
                width,
                DOTA_UNIT_TARGET_TEAM_BOTH,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE
            )
    
            local validStoneFound = false
            for _, unit in pairs(unitsInLine) do
                if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                    validStoneFound = true
                    break
                end
            end
    
            if not validStoneFound then
                skill = stoneCallerAbility
                self.earthSpiritStonePosition = "脚底下"  -- 设置标志变量，表示石头应该放在脚底下
                castRange = self:GetSkillCastRange(entity, stoneCallerAbility)
                aoeRadius = 0  -- 直接将 aoeRadius 设置为 0
            else
                -- 如果找到有效的石头，可以在这里添加相应的逻辑
                self:log("找到有效的石头，距离：" .. tostring(searchDistance))
            end
        else
            self:log("没有可用的石头召唤次数")
        end

    else ]]
    if skill:GetName() == "earth_spirit_boulder_smash" then
        if stone_charger > 0 then
            local searchRadius = 200
            
            local unitsAround = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetAbsOrigin(),
                nil,
                searchRadius,
                DOTA_UNIT_TARGET_TEAM_BOTH,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                FIND_ANY_ORDER,
                false
            )
        
            local validStoneFound = false
            for _, unit in pairs(unitsAround) do
                if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                    validStoneFound = true
                    break
                end
            end
        
            if not validStoneFound then
                skill = stoneCallerAbility
                self.earthSpiritStonePosition = "脚底下"  -- 设置标志变量，表示石头应该放在脚底下
                castRange = self:GetSkillCastRange(entity, stoneCallerAbility)
                aoeRadius = 0  -- 直接将 aoeRadius 设置为 0
                self:log("未找到有效的石头或被石化单位，替换为石头召唤技能")
            end
        else
            self:log("没有可用的石头召唤次数，施法距离保持不变")
        end
    elseif skill:GetName() == "earth_spirit_geomagnetic_grip" then
        local enemyPos = self.target:GetAbsOrigin()
        local heroPos = entity:GetAbsOrigin()
        local direction = (enemyPos - heroPos):Normalized()
    
        -- 检查敌人周围150码是否有石头
        local enemyNearbyStone = FindUnitsInRadius(
            entity:GetTeamNumber(),
            enemyPos,
            nil,
            150,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false
        )
        
        local stoneNearEnemy = false
        for _, unit in pairs(enemyNearbyStone) do
            if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                stoneNearEnemy = true
                break
            end
        end
        
        -- 如果敌人周围没有石头，检查直线区域
        if not stoneNearEnemy then
            local lineStart = enemyPos
            local lineEnd = enemyPos + direction * (castRange - (enemyPos - heroPos):Length2D())
            local lineWidth = 200
            
            local unitsInLine = FindUnitsInLine(
                entity:GetTeamNumber(),
                lineStart,
                lineEnd,
                nil,
                lineWidth,
                DOTA_UNIT_TARGET_TEAM_BOTH,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE
            )
            
            local stoneInLine = false
            for _, unit in pairs(unitsInLine) do
                if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                    stoneInLine = true
                    break
                end
            end
            
            -- 如果直线区域内也没有石头，并且有可用的石头召唤次数
            if not stoneInLine and stone_charger > 0 then
                local stoneCallerAbility = entity:FindAbilityByName("earth_spirit_stone_caller")
                if stoneCallerAbility then
                    skill = stoneCallerAbility
                    self.earthSpiritStonePosition = "敌人身后"  -- 设置标志变量，表示石头应该放在脚底下
                    castRange = self:GetSkillCastRange(entity, stoneCallerAbility)
                    aoeRadius = 0  -- 直接将 aoeRadius 设置为 0
                    self:log("未找到有效的石头或被石化单位，替换为石头召唤技能")
                end
            end
        end
    end

    return skill, castRange, aoeRadius
end



function CommonAI:HandlePostCastMovement(entity, target, abilityInfo)
    if not entity:IsFeared() and not entity:IsTaunted() then
        if entity:GetUnitName() == "npc_dota_hero_templar_assassin" or entity:GetUnitName() == "npc_dota_hero_life_stealer" or entity:GetUnitName() == "npc_dota_hero_riki" then

            local order = {
                UnitIndex = self.entity:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = target:entindex(),
                Position = target:GetAbsOrigin()
            }
            ExecuteOrderFromTable(order)

            self:SetState(AIStates.Attack)
            self:log("近战英雄施法后继续追击")
        elseif entity:GetUnitName() == "npc_dota_hero_leshrac" then
            entity:MoveToPosition(target:GetOrigin())
            self:SetState(AIStates.Idle)
            self:log("拉席克，没事走走")
            
            -- 计算拉席克和目标之间的距离
            local distance = (entity:GetOrigin() - target:GetOrigin()):Length2D()
            
            -- 如果距离大于300，才返回0.1
            if distance > 300 then
                return 0.1
            end
        else
            --entity:MoveToPosition(target:GetOrigin())
            self:SetState(AIStates.Idle)
            self:log("其他英雄移动到目标位置")
        end

        if abilityInfo.abilityName == "leshrac_split_earth" or abilityInfo.abilityName == "oracle_fortunes_end" or abilityInfo.abilityName == "void_spirit_aether_remnant" or (abilityInfo.abilityName == "slark_pounce" and self:containsStrategy(self.hero_strategy, "跳慢点") )then
            self:log("朝向敌人移动")
            entity:MoveToPosition(target:GetOrigin())
            self:SetState(AIStates.Idle)
            return 0.01
        end
    end
end

function CommonAI:FindClosestTreeForAbility(entity, abilityName)
    -- 获取对应技能的施法范围
    local ability = entity:FindAbilityByName(abilityName)
    local castRange = math.max(400, self:GetSkillCastRange(entity, ability))  -- 确保最小搜索范围为400
    
    self:log(string.format("【树木搜索】开始为技能 %s 搜索树木，原始施法范围: %d，实际搜索范围: %d", 
        abilityName, 
        self:GetSkillCastRange(entity, ability),
        castRange))
    
    local trees = GridNav:GetAllTreesAroundPoint(entity:GetAbsOrigin(), castRange, true)
    local closestTree = nil
    local closestDistance = math.huge

    self:log(string.format("【树木搜索】找到树木数量: %d", #trees))

    for _, tree in pairs(trees) do
        local treePos = tree:GetAbsOrigin()
        local distance = (treePos - entity:GetAbsOrigin()):Length2D()
        if distance < closestDistance then
            closestTree = tree
            closestDistance = distance
            self:log(string.format("【树木搜索】更新最近的树木，距离: %.0f", closestDistance))
        end
    end

    if closestTree then
        self:log(string.format("【树木搜索】已为技能 %s 找到最近的树木，距离: %.0f", abilityName, closestDistance))
        self.treetarget = closestTree
    else
        self:log(string.format("【树木搜索】在技能 %s 的 %d 范围内没有找到可用的树木", abilityName, castRange))
        self.treetarget = nil
    end
    return self.target
end

function CommonAI:AdjustAbilityTarget(entity, abilityInfo, target)
    -- 处理特定技能的特殊逻辑，例如 muerta_dead_shot
    if abilityInfo.abilityName == "muerta_dead_shot" then
        return self:HandleMuertaDeadShot(entity,abilityInfo.skill)
    elseif abilityInfo.abilityName == "tiny_tree_grab" then
        return self:FindClosestTreeForAbility(entity, "tiny_tree_grab")
    elseif abilityInfo.abilityName == "furion_force_of_nature" then
        return self:FindClosestTreeForAbility(entity, "furion_force_of_nature")
    elseif abilityInfo.abilityName == "shredder_timber_chain" then
        return self:HandleShredderTimberChain(entity)
    elseif abilityInfo.abilityName == "earth_spirit_geomagnetic_grip" then
        return self:HandleEarthSpiritGeomagneticGrip(entity)
    else 
        self.treetarget = nil
    end
    return false
end

function CommonAI:HandleEarthSpiritGeomagneticGrip(entity)
    local ability = entity:FindAbilityByName("earth_spirit_geomagnetic_grip")
    if not ability then 
        self:log("未找到地磁抓捕技能")
        return false 
    end

    local castRange = ability:GetCastRange(Vector(0,0,0), nil)
    local enemyPos = self.target:GetAbsOrigin()
    local heroPos = entity:GetAbsOrigin()
    local direction = (enemyPos - heroPos):Normalized()

    self:log("开始检查敌人周围150码是否有石头")
    -- 检查敌人周围150码是否有石头
    local enemyNearbyStone = FindUnitsInRadius(
        entity:GetTeamNumber(),
        enemyPos,
        nil,
        150,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
        FIND_ANY_ORDER,
        false
    )
    
    for _, unit in pairs(enemyNearbyStone) do
        if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
            self:log("在敌人周围150码找到石头或被石化单位")
            return unit
        end
    end
    
    self:log("敌人周围150码没有找到石头，开始检查直线区域")
    -- 如果敌人周围没有石头，检查直线区域
    local lineStart = enemyPos
    local lineEnd = enemyPos + direction * (castRange - (enemyPos - heroPos):Length2D())
    local lineWidth = 200
    
    local unitsInLine = FindUnitsInLine(
        entity:GetTeamNumber(),
        lineStart,
        lineEnd,
        nil,
        lineWidth,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE
    )
    
    for _, unit in pairs(unitsInLine) do
        if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
            self:log("在直线区域找到石头或被石化单位")
            return unit
        end
    end
    
    self:log("没有找到任何石头或被石化单位")
    return false
end


function CommonAI:HandleShredderTimberChain(entity)
    local ability = entity:FindAbilityByName("shredder_timber_chain")
    if not ability then
        self:log("找不到伐木机的钩锁技能")
        return false
    end

    local aoeRadius = self:GetSkillAoeRadius(ability)
    local castRange = self:GetSkillCastRange(entity, ability)
    local totalRange = aoeRadius + castRange

    local trees = GridNav:GetAllTreesAroundPoint(entity:GetAbsOrigin(), totalRange, true)
    local validTrees = {}

    for _, tree in pairs(trees) do
        local treePos = tree:GetAbsOrigin()
        local direction = (treePos - entity:GetAbsOrigin()):Normalized()
        local endPos = entity:GetAbsOrigin() + direction * (treePos - entity:GetAbsOrigin()):Length2D()

        local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
        local targetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
        local targetFlags = DOTA_UNIT_TARGET_FLAG_NONE
        local enemies = FindUnitsInLine(
            entity:GetTeamNumber(),
            entity:GetAbsOrigin(),
            endPos,
            nil,
            225,  -- 宽度225的矩形范围
            targetTeam,
            targetType,
            targetFlags
        )

        for _, enemy in pairs(enemies) do
            if not enemy:IsDebuffImmune() then
                table.insert(validTrees, {tree = tree, distance = (treePos - entity:GetAbsOrigin()):Length2D()})
                break
            end
        end
    end

    if #validTrees > 0 then
        table.sort(validTrees, function(a, b) return a.distance < b.distance end)
        self:log("已经为伐木机找到了最近的有效树木目标")
        return validTrees[1].tree
    else
        self:log("伐木机周围没有找到符合条件的树木")
        return false
    end
end


    -- if target:HasModifier("modifier_muerta_dead_shot_fear") then
    --     -- 如果目标被恐惧，在目标前方300单位处寻找树木
    --     local targetForward = target:GetForwardVector():Normalized()
    --     searchCenter = target:GetAbsOrigin() + targetForward * 300
    -- else
    --     -- 否则直接以目标位置为中心寻找树木
    --     searchCenter = target:GetAbsOrigin()
    -- end


function CommonAI:HandleMuertaDeadShot(entity, ability)
    local searchCenter = self.target:GetAbsOrigin()
    local searchRadius = self:GetSkillCastRange(entity, ability)
    local trees = GridNav:GetAllTreesAroundPoint(searchCenter, searchRadius, true)
    local validTrees = {}
    
    self:log("搜索到树木总数: " .. #trees)
    
    -- 计算从自己到敌人的方向向量
    local entityPos = entity:GetOrigin()
    local targetPos = self.target:GetAbsOrigin()
    local dirToEnemy = (targetPos - entityPos):Normalized()
    local entityForward = entity:GetForwardVector()
    
    -- 计算自己当前朝向与敌人方向的夹角(弧度)
    local angleToEnemy = math.acos(entityForward:Dot(dirToEnemy))
    self:log("当前朝向与敌人方向夹角: " .. math.deg(angleToEnemy) .. "度")
    
    -- 给每棵树分配一个唯一ID，用于稳定排序
    local treeCount = 0
    local frontalTrees = {}  -- 前方的树
    local otherTrees = {}    -- 其他方向的树
    local behindEnemyTrees = {}  -- 敌人身后的树
    
    for _, tree in pairs(trees) do
        local treePos = tree:GetAbsOrigin()
        local treeDistanceToPlayer = (treePos - entityPos):Length2D()
        
        -- 确保树在自己的施法范围内
        if treeDistanceToPlayer <= searchRadius then
            treeCount = treeCount + 1
            
            -- 计算从自己到树的方向
            local dirToTree = (treePos - entityPos):Normalized()
            -- 计算从自己到树的方向与自己到敌人方向的夹角(弧度)
            local angleToTree = math.acos(dirToTree:Dot(dirToEnemy))
            
            -- 计算从敌人到树的方向向量
            local enemyToTreeVector = (treePos - targetPos):Normalized()
            -- 计算敌人到树的方向与自己到敌人方向的夹角(弧度)
            local angleEnemyToTree = math.acos(enemyToTreeVector:Dot(dirToEnemy * -1))
            -- 判断树是否在敌人身后 (夹角小于90度表示在敌人身后形成钝角)
            local isBehindEnemy = math.deg(angleEnemyToTree) < 90
            
            local treeInfo = {
                tree = tree, 
                distance = treeDistanceToPlayer,
                position = treePos,
                id = treeCount,
                angle = angleToTree,    -- 保存夹角
                behindEnemy = isBehindEnemy  -- 是否在敌人身后
            }
            
            -- 如果策略是"往前弹射"且树在敌人身后
            if self:containsStrategy(self.hero_strategy, "往前弹射") and isBehindEnemy then
                table.insert(behindEnemyTrees, treeInfo)
                self:log("找到敌人背后的树 ID:" .. treeCount)
            -- 其他情况按原来的逻辑处理
            elseif math.deg(angleToTree) < 60 then
                table.insert(frontalTrees, treeInfo)
            else
                table.insert(otherTrees, treeInfo)
            end
        end
    end
    
    self:log("前方树木数量: " .. #frontalTrees .. ", 其他方向树木数量: " .. #otherTrees .. ", 敌人身后树木数量: " .. #behindEnemyTrees)
    
    -- 确定使用哪组树
    local treesToUse = nil
    if self:containsStrategy(self.hero_strategy, "往前弹射") then
        if #behindEnemyTrees > 0 then
            treesToUse = behindEnemyTrees
            self:log("使用敌人身后的树木")
        else
            self:log("未找到敌人身后的树木，不选择任何树木")
            self.treetarget = nil
            return self.target
        end
    else
        treesToUse = #frontalTrees > 0 and frontalTrees or otherTrees
    end
    
    if treesToUse and #treesToUse > 0 then
        -- 排序：优先按角度排序(角度小的优先)，然后按距离排序(距离远的优先)
        table.sort(treesToUse, function(a, b)
            -- 如果角度差异很小，按距离排序
            if math.abs(a.angle - b.angle) < 0.2 then  -- 约10度差异
                if math.abs(a.distance - b.distance) < 0.1 then
                    -- 如果距离也很接近，使用ID排序保证稳定性
                    return a.id < b.id
                else
                    -- 距离远的优先
                    return a.distance > b.distance
                end
            else
                -- 角度小的优先
                return a.angle < b.angle
            end
        end)
        
        local selectedTree = treesToUse[1]
        local treePos = selectedTree.position
        
        self:log("选中树木: " .. 
                (treesToUse == behindEnemyTrees and "敌人身后" or 
                (treesToUse == frontalTrees and "前方" or "其他方向")) ..
                " ID:" .. selectedTree.id .. 
                " 距离:" .. string.format("%.2f", selectedTree.distance) .. 
                " 角度:" .. string.format("%.2f", math.deg(selectedTree.angle)) .. "度" ..
                " 位置:(" .. string.format("%.2f", treePos.x) .. 
                "," .. string.format("%.2f", treePos.y) .. 
                "," .. string.format("%.2f", treePos.z) .. ")" ..
                (selectedTree.behindEnemy and " (在敌人身后)" or ""))
        
        self.treetarget = selectedTree.tree
    else
        self:log("未找到合适的树木目标")
        self.treetarget = nil
    end
    
    return self.target
end


function CommonAI:ClampPositionToRect(position, left, right, top, bottom)
    if position.x < left then
        position.x = left
    elseif position.x > right then
        position.x = right
    end
    if position.y > top then
        position.y = top
    elseif position.y < bottom then
        position.y = bottom
    end
    return position
end

function CommonAI:HandleUnitTargetAbility(entity, abilityInfo, target, targetInfo)

    if self:isSelfCastAbility(abilityInfo.abilityName) then --只对自己释放的技能
        if self:isSelfCastAbilityWithRange(abilityInfo.abilityName) then
            -- 对自己释放但需要考虑范围的技能
            if abilityInfo.aoeRadius > 0 then
                local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.aoeRadius)


                if self:IsInRange(target, totalRange) then
                    entity:CastAbilityOnTarget(entity, abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, entity)
                else
                    -- 敌人不在施法范围内
                    if self.currentState ~= AIStates.Channeling then
                        -- 移动到施法距离内
                        self:MoveToRange(targetInfo.targetPos, totalRange)
                        self:SetState(AIStates.Seek)
                        self:log(string.format("不在施法范围内，移动到施法范围，进入Seek状态，目标距离: %.2f，施法距离: %.2f", targetInfo.distance, abilityInfo.castRange))
                    end
                end
            end
        else
            self:log("对自己施放的技能，无需考虑范围")
            if abilityInfo.abilityName == "lich_frost_shield" then
                local targetToCast = FindSuitableTarget(entity, abilityInfo, "modifier_lich_frost_shield", true, "friendly")
                if targetToCast then
                    if log then
                        log(string.format("巫妖技能检查: 选择目标 %s", targetToCast:GetUnitName()))
                    end
                    entity:CastAbilityOnTarget(targetToCast, abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, entity)
                else
                    if log then
                        log("巫妖技能检查: 未找到合适的目标")
                    end
                end
            else
                entity:CastAbilityOnTarget(entity, abilityInfo.skill, 0)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, entity)
            end
        end

    elseif abilityInfo.targetTeam ~= DOTA_UNIT_TARGET_TEAM_FRIENDLY then
        if abilityInfo.castRange > 0 then
            local currentTarget = self.treetarget or target
            local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.castRange)

            if self:IsInRange(currentTarget, totalRange) then
                -- 敌人在施法范围内
                self:HandleEnemyTargetAction(entity, currentTarget, abilityInfo, targetInfo)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, currentTarget)
            else
                -- 敌人不在施法范围内
                if self:HandleEnemyTargetOutofRangeAction(entity, currentTarget, abilityInfo, targetInfo) then
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, currentTarget)
                elseif self.currentState ~= AIStates.Channeling then
                    -- 移动到施法距离内
                    local targetPosition = self.treetarget and self.treetarget:GetAbsOrigin() or targetInfo.targetPos
                    self:MoveToRange(targetPosition, totalRange)
                    self:SetState(AIStates.Seek)
                    self:log(string.format("不在施法范围内，移动到施法范围，进入Seek状态，目标距离: %.2f，施法距离: %.2f", targetInfo.distance, abilityInfo.castRange))
                end
            end
        end
    else
        self:log("对队友释放的技能")
        if abilityInfo.abilityName == "clinkz_death_pact" then
            -- 使用FindNearestNoSelfAllyLastResort搜索ally
            local lastResortAlly = self:FindNearestNoSelfAllyLastResort(entity)
            if lastResortAlly then
                self:log("找到目标了")
                entity:CastAbilityOnTarget(lastResortAlly, abilityInfo.skill, 0)
            else
                -- 如果没有找到ally，可以在这里添加日志或其他处理
                self:log("没有找到可用的目标来使用死亡契约")
            end
        end
        self:HandleAllyTargetAbility(entity, abilityInfo,targetInfo)
    end
end

function CommonAI:HandlePointTargetAbility(entity, abilityInfo, target, targetInfo)
    if abilityInfo.targetTeam ~= DOTA_UNIT_TARGET_TEAM_FRIENDLY then
        local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.aoeRadius)
        if self:IsInRange(target, totalRange) then
            -- 敌人在施法范围内
            self:HandleEnemyPoint_InCastRange(entity, target, abilityInfo, targetInfo)
            self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
        elseif self:IsInRange(target, self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.castRange + abilityInfo.aoeRadius)) then
            -- 敌人在作用范围内
            self:HandleEnemyPoint_InAoeRange(entity, target, abilityInfo, targetInfo)
            self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
        else
            -- 敌人不在范围内
            if self:HandleEnemyPoint_OutofRangeAction(entity, target, abilityInfo, targetInfo) then
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
            else
                -- 移动到施法距离内
                local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.castRange + abilityInfo.aoeRadius)
                self:MoveToRange(targetInfo.targetPos, totalRange)
                self:SetState(AIStates.Seek)
                self:log(string.format("不在施法范围内，移动到施法范围，进入Seek状态，目标距离: %.2f，施法距离+作用范围: %.2f", targetInfo.distance, totalRange))
            end
        end
    elseif self:isSelfCastAbility(abilityInfo.abilityName) then
        -- 对自己释放技能

        self:log("对自己施放技能")
        entity:CastAbilityOnPosition(entity:GetAbsOrigin(), abilityInfo.skill, 0)

        self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
    else
        self:HandleAllyPointAbility(entity, abilityInfo, targetInfo)
    end
end

function CommonAI:HandleNoTargetAbility(entity, abilityInfo, target, targetInfo)
    self:log("无目标技能")
    -- 修改：如果radius不等于零，并且小于150，就令它等于150
    if abilityInfo.aoeRadius ~= 0 and abilityInfo.aoeRadius < 150 then
        abilityInfo.aoeRadius = 150
    end
    local totalRange = self:GetSkillRangeThreshold(abilityInfo.skill, entity, abilityInfo.castRange + abilityInfo.aoeRadius)
    if  totalRange == 0 then
        self:log(string.format("技能: %s 没有作用范围，直接释放", abilityInfo.abilityName))
        entity:CastAbilityNoTarget(abilityInfo.skill, 0)
        self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
    else

        if self:IsInRange(target, totalRange) then

            if abilityInfo.abilityName == "zuus_heavenly_jump" and self.needToDodge == true then
                local heroPosition = self.entity:GetAbsOrigin()
                local dirToEnemy = (target:GetAbsOrigin() - heroPosition):Normalized()
                local heroForward = self.entity:GetForwardVector()
                local angle = math.deg(math.acos(heroForward:Dot(dirToEnemy)))
            
                if angle < 30 then
                    -- 如果角度小于30度，从英雄和敌人的连线往北偏转30度移动200码
                    local radians = math.rad(30)
                    local cos = math.cos(radians)
                    local sin = math.sin(radians)
                    
                    -- 计算旋转后的向量（逆时针旋转，所以用负的sin）
                    local rotatedX = dirToEnemy.x * cos + dirToEnemy.y * sin
                    local rotatedY = -dirToEnemy.x * sin + dirToEnemy.y * cos
                    local moveDirection = Vector(rotatedX, rotatedY, dirToEnemy.z):Normalized()
                    
                    local movePosition = heroPosition + moveDirection * 200
                    self.entity:MoveToPosition(movePosition)
                    self:log("Zeus正在从敌人方向往北偏转30°移动200码")
                else
                    -- 如果角度大于等于30度，直接释放技能
                    self:log("Zeus直接释放Heavenly Jump")
                    entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
                end
            elseif abilityInfo.abilityName == "invoker_ice_wall" and not self:containsStrategy(self.hero_strategy, "正面冰墙") then
                local heroPosition = self.entity:GetAbsOrigin()
                local targetPosition = target:GetAbsOrigin()
                local distanceToTarget = (targetPosition - heroPosition):Length2D()
                local heroForward = self.entity:GetForwardVector()
                
                -- 圆的半径
                local circleRadius = 300
                
                -- 计算切点
                -- cos(theta) = r/d，其中theta是圆心角的一半
                local cosTheta = circleRadius / distanceToTarget
                local theta = math.acos(cosTheta)
                
                -- 计算从圆心到敌人的基准角度
                local baseAngle = math.atan2(targetPosition.y - heroPosition.y, targetPosition.x - heroPosition.x)
                
                -- 计算右侧切点的角度（基准角度减去theta）
                local tangentAngle = baseAngle - theta
                
                -- 计算切点位置
                local tangentPoint = Vector(
                    heroPosition.x + circleRadius * math.cos(tangentAngle),
                    heroPosition.y + circleRadius * math.sin(tangentAngle),
                    heroPosition.z
                )
                
                -- 计算应该面向的方向（从英雄到切点的方向）
                local dirToTangent = (tangentPoint - heroPosition):Normalized()
                local currentAngle = math.deg(math.acos(heroForward:Dot(dirToTangent)))
                
                if currentAngle > 5 then
                    -- 需要调整方向，向切点方向移动
                    local movePosition = heroPosition + dirToTangent * 50
                    self:log("Invoker正在调整到切点方向")
                    self.entity:MoveToPosition(movePosition)
                    return
                end
                
                -- 角度合适，直接释放技能
                self:log("Invoker释放Ice Wall")
                entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)

            elseif abilityInfo.abilityName == "rattletrap_power_cogs" then
                local heroPosition = self.entity:GetAbsOrigin()
                local dirToEnemy = (target:GetAbsOrigin() - heroPosition):Normalized()
                local heroForward = self.entity:GetForwardVector()
                local angle = math.deg(math.acos(heroForward:Dot(dirToEnemy)))
                local distanceToEnemy = (target:GetAbsOrigin() - heroPosition):Length2D()
                local hasCogImmune = self.entity:HasModifier("modifier_rattletrap_cog_immune")
                
                if angle < 45 then
                    -- 如果角度小于45度，说明基本面对着敌人，直接放技能
                    self:log("发条面对敌人，直接释放齿轮")
                    entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
                else
                    -- 如果没有齿轮免疫，直接放技能
                    if not hasCogImmune then
                        self:log("发条没有齿轮免疫，直接释放齿轮")
                        entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                        self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
                    -- 如果有齿轮免疫且距离大于400，需要转身面对敌人
                    elseif distanceToEnemy > 500 then
                        self:log("发条需要转身面对敌人")
                        local movePosition = target:GetAbsOrigin()
                        local order = {
                            UnitIndex = self.entity:entindex(),
                            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                            TargetIndex = self.target and self.target:entindex(),
                            Position = movePosition
                        }
                        ExecuteOrderFromTable(order)
                    else
                        -- 距离小于400且有齿轮免疫，直接放技能
                        self:log("发条直接释放齿轮")
                        entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                        self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
                    end
                end
            elseif abilityInfo.abilityName == "slark_pounce" then
                local heroPosition = self.entity:GetAbsOrigin()
                local dirToEnemy = (target:GetAbsOrigin() - heroPosition):Normalized()
                local heroForward = self.entity:GetForwardVector()
                local angle = math.deg(math.acos(heroForward:Dot(dirToEnemy)))
                local distanceToEnemy = (target:GetAbsOrigin() - heroPosition):Length2D()
                
                if angle < 20 or distanceToEnemy < 100 then
                    -- 如果角度小于45度或距离小于100，直接释放技能
                    self:log("小鱼人面对敌人或距离足够近，直接跳跃")
                    entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
                else
                    -- 需要转身面对敌人
                    self:log("小鱼人需要转身面对敌人")
                    local movePosition = target:GetAbsOrigin()
                    local order = {
                        UnitIndex = self.entity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                        TargetIndex = self.target and self.target:entindex(),
                        Position = movePosition
                    }
                    ExecuteOrderFromTable(order)
                end
            else
                self:log(string.format("技能: %s 敌人在作用范围内，直接释放", abilityInfo.abilityName))
                entity:CastAbilityNoTarget(abilityInfo.skill, 0)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
            end
        else
            self:MoveToRange(targetInfo.targetPos, totalRange)
            self:SetState(AIStates.Seek)
            self:log(string.format("技能: %s 敌人不在作用范围内，移动到作用范围，目标距离: %.2f，作用范围: %.2f", abilityInfo.abilityName, targetInfo.distance, abilityInfo.aoeRadius + abilityInfo.castRange))
        end
    end
end

function CommonAI:HandleAllyTargetAbility(entity, abilityInfo, targetInfo)
    if not self.Ally then
        return false
    end
    self:log("对队友放的")
    self:log(string.format("找到友军目标 %s 准备施放技能 %s", self.Ally:GetUnitName(), abilityInfo.abilityName))
    if abilityInfo.castRange > 0 then
        if self:IsInRange(self.Ally, abilityInfo.castRange) then
            -- 友军在范围内
            if abilityInfo.abilityName == "brewmaster_void_astral_pull" then
                self:log(string.format("友军在施法范围内，准备施放技能: %s", abilityInfo.abilityName))
                CommonAI:CastVectorSkillToUnitAndPoint(entity, abilityInfo.skill, self.Ally, targetInfo.targetPos)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, self.Ally:GetOrigin(), abilityInfo.castPoint)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, abilityInfo.target)
            elseif abilityInfo.abilityName == "dawnbreaker_solar_guardian" then
                print("")
                local order = {
                    UnitIndex = entity:entindex(),
                    OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
                    Position = self.Ally:GetOrigin(),
                    AbilityIndex = abilityInfo.skill:entindex(),
                    Queue = false
                }
                ExecuteOrderFromTable(order)
                self:log("使用 ExecuteOrderFromTable 释放破晓辰星终极技能")
            elseif abilityInfo.abilityName == "marci_companion_run" then 

                CommonAI:CastVectorSkillToUnitAndPoint(entity, abilityInfo.skill, self.Ally, targetInfo.targetPos)
        
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, targetInfo.targetPos, abilityInfo.castPoint)
            else
                self:log(string.format("友军在施法范围内，准备施放技能: %s", abilityInfo.abilityName))
                entity:CastAbilityOnTarget(self.Ally, abilityInfo.skill, 0)
                abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, self.Ally:GetOrigin(), abilityInfo.castPoint)
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, abilityInfo.target)
            end
        else
            -- 友军不在范围内
            self:MoveToRange(self.Ally:GetOrigin(), abilityInfo.castRange)
            self:SetState(AIStates.Seek)
            self:log(string.format("友军不在施法范围内，移动到施法范围，目标距离: %.2f，施法距离: %.2f", targetInfo.distance, abilityInfo.castRange))
        end
    end
end

function CommonAI:HandleAllyPointAbility(entity, abilityInfo, targetInfo)
    if not self.Ally then
        return false
    end
    
    self:log("对队友放的")
    self:log(string.format("找到友军目标 %s 准备施放技能 %s", self.Ally:GetUnitName(), abilityInfo.abilityName))
    if abilityInfo.castRange > 0 then
        if self:IsInRange(self.Ally, abilityInfo.castRange) then
            -- 友军在范围内
            self:log(string.format("友军在施法范围内，准备施放技能: %s", abilityInfo.abilityName))
            entity:CastAbilityOnPosition(self.Ally:GetOrigin(), abilityInfo.skill, 0)
            abilityInfo.castPoint = CommonAI:calculateAdjustedCastPoint(entity, self.Ally:GetOrigin(), abilityInfo.castPoint)
            self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, abilityInfo.target)
        else
            -- 友军不在范围内
            self:MoveToRange(self.Ally:GetOrigin(), abilityInfo.castRange)
            self:SetState(AIStates.Seek)
            self:log(string.format("友军不在施法范围内，移动到施法范围，目标距离: %.2f，施法距离: %.2f", targetInfo.distance, abilityInfo.castRange))
        end
    end
end

function CommonAI:HandleUnableToCast(entity, target, abilityInfo, targetInfo)
    -- 检查是否有特殊无敌状态
    if entity:HasModifier("modifier_void_spirit_dissimilate_phase") or 
       entity:HasModifier("modifier_dawnbreaker_solar_guardian_air_time") or 
       entity:HasModifier("modifier_snapfire_mortimer_kisses") then
        self:log("正在执行特殊无敌技能")
        if self.currentState ~= AIStates.CastSpell and self.currentState ~= AIStates.Channeling then
            local order = {
                UnitIndex = entity:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                TargetIndex = target:entindex(),
                AbilityIndex = abilityInfo.skill:GetEntityIndex(),
                Position = targetInfo.targetPos
            }
            ExecuteOrderFromTable(order)
        end
    else
        if self:containsStrategy(self.global_strategy, "不在骨法棒子里放技能") and self.attackTarget then
            print("不在骨法棒子里放技能")
            self:HandleAttack(self.attackTarget)
        else
            self:HandleAttack(target)
        end
        
    end
end

function CommonAI:HandleNoTargetFound(entity)
    self:log("没有找到目标，进入待机状态")
    self:SetState(AIStates.Idle)
    return self.nextThinkTime
end

function CommonAI:AdjustAbilityCastRangeForSpecialHeroes(entity, target)
    -- 特定英雄的特殊逻辑处理，例如 npc_dota_hero_ember_spirit

    if entity:GetUnitName() == "npc_dota_hero_ember_spirit" and target then
        local remnants = FindUnitsInRadius(
            entity:GetTeamNumber(),
            target:GetAbsOrigin(),
            nil,
            400,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false
        )

        for _, remnant in pairs(remnants) do
            if remnant:GetUnitName() == "npc_dota_ember_spirit_remnant" then
                self:log("有残焰在附近，可以远程捆")
                self.specificRadius.ember_spirit_searing_chains = 2000
                break
            else
                self.specificRadius.ember_spirit_searing_chains = nil
            end
        end
    end
end

function CommonAI:HandleAttack(target, abilityInfo, targetInfo)
    -- 首先判断单位是否可以攻击
    if self:IsUnableToAttack(self.entity, target) then
        self:log("目标无法攻击")
        return self.nextThinkTime
    end


    -- 检查是否是维萨吉魔像且启用了小鸟挡箭策略
    if string.find(self.entity:GetUnitName(), "npc_dota_visage_familiar") and 
       self:containsStrategy(self.hero_strategy, "小鸟挡箭") then
        return self:HandleFamiliarGuard()
    end

    -- 特殊移动状态处理
    if self.entity:HasModifier("modifier_primal_beast_trample") then
        local targetPos = target:GetAbsOrigin()
        local selfPos = self.entity:GetAbsOrigin()
        local currentForward = self.entity:GetForwardVector()
        local maxRadius = 230
        local minRadius = 100
        
        -- 计算当前与目标的距离
        local currentDistance = (targetPos - selfPos):Length2D()
        
        -- 确保半径在100-230之间
        local radius = currentDistance
        if currentDistance < minRadius then
            radius = minRadius
        elseif currentDistance > maxRadius then
            radius = maxRadius
        end
        
        -- 获取当前位置到目标的方向
        local dirToTarget = (targetPos - selfPos):Normalized()
        
        -- 计算当前朝向与目标方向的夹角（弧度）
        local currentAngle = math.atan2(currentForward.y, currentForward.x)
        
        -- 在当前朝向的方向上寻找下一个点（顺时针或逆时针）
        -- 使用较小的角度增量，确保平滑移动
        local rotateAngle = math.pi/6 -- 30度
        
        -- 根据当前朝向选择旋转方向
        local crossProduct = currentForward.x * dirToTarget.y - currentForward.y * dirToTarget.x
        if crossProduct < 0 then
            rotateAngle = -rotateAngle -- 逆时针旋转
        end
        
        -- 计算下一个目标点
        local nextAngle = currentAngle + rotateAngle
        local nextPoint = Vector(
            targetPos.x + radius * math.cos(nextAngle),
            targetPos.y + radius * math.sin(nextAngle),
            targetPos.z
        )
        
        self.entity:MoveToPosition(nextPoint)
        self:log(string.format("以%d半径绕行，旋转角度：%.2f", radius, math.deg(rotateAngle)))
        
        return self.nextThinkTime

    elseif self.entity:HasModifier("modifier_pangolier_gyroshell") or self.entity:HasModifier("modifier_rattletrap_jetpack") then
        local order = {
            UnitIndex = self.entity:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            TargetIndex = target:entindex(),
            AbilityIndex = abilityInfo and abilityInfo.skill and abilityInfo.skill:GetEntityIndex(),
            Position = targetInfo and targetInfo.targetPos or target:GetAbsOrigin()
        }
        ExecuteOrderFromTable(order)
        self:log("有modifier_pangolier_gyroshell修饰器，移动到目标位置")
        return self.nextThinkTime
    elseif self.entity:HasModifier("modifier_mars_bulwark_active") then
        local myPos = self.entity:GetAbsOrigin()
        local targetPos = target:GetAbsOrigin()
        local distance = (targetPos - myPos):Length2D()
        local myForward = self.entity:GetForwardVector()
        local dirToTarget = (targetPos - myPos):Normalized()
        
        -- 计算反方向延伸150码的位置
        local extendedPos = targetPos + (-myForward * 150)
        
        local order = {
            UnitIndex = self.entity:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = extendedPos
        }
        ExecuteOrderFromTable(order)
        self:log(string.format("有modifier_mars_bulwark_active修饰器，距离%.2f，移动到延伸位置", distance))
        return self.nextThinkTime
    elseif self.entity:HasModifier("modifier_weaver_shukuchi") and not target:HasModifier("modifier_shukuchi_geminate_attack_mark") then
        local order = {
            UnitIndex = self.entity:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            TargetIndex = target:entindex(),
            AbilityIndex = abilityInfo and abilityInfo.skill and abilityInfo.skill:GetEntityIndex(),
            Position = targetInfo and targetInfo.targetPos or target:GetAbsOrigin()
        }
        ExecuteOrderFromTable(order)
        self:log("有modifier_weaver_shukuchi修饰器且目标无标记，移动到目标位置")
        return self.nextThinkTime
    elseif self.entity:HasModifier("modifier_leshrac_diabolic_edict") then
        local myPos = self.entity:GetAbsOrigin()
        local targetPos = target:GetAbsOrigin()
        local distance = (targetPos - myPos):Length2D()
        
        if distance > 450 then
            local order = {
                UnitIndex = self.entity:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                TargetIndex = target:entindex(),
                Position = targetPos
            }
            ExecuteOrderFromTable(order)
            self:log(string.format("有modifier_leshrac_diabolic_edict修饰器，距离%.2f大于450，移动到目标位置", distance))
            return self.nextThinkTime
        end
    end


    if self:containsStrategy(self.global_strategy, "不要优先拆墓碑、棒子") then
        self:log("不要优先拆墓碑、棒子")
    elseif self:containsStrategy(self.global_strategy, "优先打小僵尸") and self.attackTarget then
        target = self.attackTarget
    elseif self.attackTarget then 
        target = self.attackTarget
    end

    if not target then
        self:log("没有target")
        return self.nextThinkTime
    end


    local function IsInAttackRange(self, target)
        local attackRange = self.entity:Script_GetAttackRange()
        local distance = (target:GetAbsOrigin() - self.entity:GetAbsOrigin()):Length2D()
        return distance <= attackRange
    end

    if not IsInAttackRange(self, target) then
        local myPos = self.entity:GetAbsOrigin()
        local targetPos = target:GetAbsOrigin()
        local direction = (targetPos - myPos):Normalized()
        local attackRange = self.entity:Script_GetAttackRange()
        local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + 
        DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD +
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
        
        -- 获取范围内所有单位
        local units = FindUnitsInRadius(
            self.entity:GetTeamNumber(),
            myPos,
            nil,
            attackRange,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            flags,
            FIND_ANY_ORDER,
            false
        )
        
        local nearestCog = nil
        local nearestDistance = attackRange
        
        for _, unit in pairs(units) do
            if unit:GetUnitName() == "npc_dota_rattletrap_cog" then
                local cogPos = unit:GetAbsOrigin()
                local cogToSelf = (cogPos - myPos):Normalized()  -- 归一化向量
                
                -- 严格检查是否在正前方60度范围内（cos30≈0.866）
                local dotProduct = direction:Dot(cogToSelf)
                if dotProduct >= 0.7 then  -- 对应30度夹角
                    local distance = (cogPos - myPos):Length2D()
                    if distance < nearestDistance then
                        nearestCog = unit
                        nearestDistance = distance
                    end
                end
            end
        end
        
        if nearestCog then
            target = nearestCog
            self:log("找到正前方齿轮，优先攻击")
        end
    end


    
    -- 检查目标是否无敌
    if not self:CanAttackTarget(self.entity, target) then
        print("对面无敌了")
        -- 目标无敌时移动到攻击范围边缘
        local targetPos = targetInfo and targetInfo.targetPos or target:GetAbsOrigin()
        local myPos = self.entity:GetAbsOrigin()
        local attackRange = self.entity:Script_GetAttackRange()
        local currentDistance = (targetPos - myPos):Length2D()
        
        -- 只有当前距离大于攻击范围时才移动
        if currentDistance > attackRange then
            -- 计算从自己到目标的方向向量
            local direction = (targetPos - myPos):Normalized()
            -- 计算在攻击范围边缘的位置（目标位置向后偏移攻击距离）
            local movePos = targetPos - direction * attackRange
            
            local order = {
                UnitIndex = self.entity:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                TargetIndex = target:entindex(),
                Position = movePos,
                Queue = false
            }
            ExecuteOrderFromTable(order)
        end
    else
        -- 已在攻击状态
        if self.entity:IsAttacking() then
            self:log("已经在攻击状态")
            
            -- 获取当前攻击目标
            local currentTarget = self.entity:GetAttackTarget()
            
            if currentTarget then
                -- 如果当前目标是英雄,检查骷髅王大招效果
                if currentTarget:IsHero() and not currentTarget:IsIllusion() then
                    -- 检查当前目标是否有骷髅王大招特效
                    local hasSkeletonKingModifier = currentTarget:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
                    
                    if hasSkeletonKingModifier then
                        -- 寻找周围其他敌方单位
                        local nearbyUnits = FindUnitsInRadius(self.entity:GetTeamNumber(),
                                                            self.entity:GetOrigin(),
                                                            nil,
                                                            self.entity:Script_GetAttackRange() + 300,
                                                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                                                            DOTA_UNIT_TARGET_ALL,
                                                            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
                                                            DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                                                            FIND_ANY_ORDER,
                                                            false)
                                                            
                        -- 检查是否有其他没有该特效的敌人
                        for _, unit in pairs(nearbyUnits) do
                            if unit ~= currentTarget and not unit:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") then
                                -- 发出停止攻击指令
                                self.entity:Stop()
                                self:log("目标有骷髅王大招特效且有其他目标,停止当前攻击")
                                return self.nextThinkTime
                            end
                        end
                    end
                -- 如果当前目标不是英雄且不等于目标target,切换到target
                elseif currentTarget ~= target and not self:containsStrategy(self.global_strategy, "谁近打谁") then
                    self:log("当前目标非英雄且不是指定目标,切换攻击到指定目标")
                    self:SetState(AIStates.Attack)
                    local order = {
                        UnitIndex = self.entity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                        TargetIndex = target:entindex(),
                        Position = targetInfo and targetInfo.targetPos or target:GetAbsOrigin()
                    }
                    ExecuteOrderFromTable(order)
                    return self.nextThinkTime

                end
            end
            
            return self.nextThinkTime
        end

        -- 定义特殊技能表

        local SPECIAL_ABILITIES = {
            ["spawnlord_master_freeze"] = true
        }

        -- 检查是否拥有特殊技能且非冷却状态
        for abilityName in pairs(SPECIAL_ABILITIES) do
            local ability = self.entity:FindAbilityByName(abilityName)
            if ability then
                self:log("检查技能:" .. abilityName)
                if ability:IsFullyCastable() then
                    self:log("技能 " .. abilityName .. " 可用且非冷却,返回")
                    return self.nextThinkTime
                else
                    self:log("技能 " .. abilityName .. " 在冷却中或不可用")
                end
            end
        end
                
        if self:containsStrategy(self.global_strategy, "谁近打谁") then
            local targetName = "unknown"
            if target and type(target.GetUnitName) == "function" then
                targetName = target:GetUnitName()
            end
            self:log("进入攻击状态，攻击目标:", targetName)
            self:SetState(AIStates.Attack)
            self.entity:MoveToTargetToAttack(target)
        else
        -- 目标不是无敌时正常执行攻击
            self:SetState(AIStates.Attack)
            local order = {
                UnitIndex = self.entity:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = target:entindex(),
                Position = targetInfo and targetInfo.targetPos or target:GetAbsOrigin()
            }
            ExecuteOrderFromTable(order)
        end
    end



    
    return self.nextThinkTime
end

function CommonAI:CanAttackTarget(entity, target)
    -- 检查目标是否无法被选中或无敌
    if target:IsUnselectable() or target:IsInvulnerable() then
        return false
    end
    
    -- 检查目标是否处于虚无状态
    local isTargetEthereal = target:HasModifier("modifier_muerta_pierce_the_veil_buff") 
        or target:HasModifier("modifier_pugna_decrepify")
        or target:HasModifier("modifier_ghost_state")
        or target:HasModifier("modifier_item_ethereal_blade_ethereal")
        or target:HasModifier("modifier_necrolyte_ghost_shroud_active")
        
    -- 如果目标处于虚无状态，检查攻击者是否有可以攻击虚无单位的buff
    if isTargetEthereal then
        local canAttackEthereal = entity:HasModifier("modifier_item_revenants_brooch_active") 
            or entity:HasModifier("modifier_muerta_supernatural")
        
        if not canAttackEthereal then
            return false
        end
    end


    local distance = (entity:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
    if target and type(target.FindModifierByName) == "function" then
        local magneticFieldModifier = target:FindModifierByName("modifier_arc_warden_magnetic_field_evasion")
        if magneticFieldModifier and distance > 300 then
            -- 检查是否有金箍棒
            local hasMonkeyKingBar = false
            for i = 0, 8 do
                local item = entity:GetItemInSlot(i)
                if item and item:GetName() == "item_monkey_king_bar" then
                    hasMonkeyKingBar = true
                    break
                end
            end
            
            if not hasMonkeyKingBar then
                self:log("目标处于磁场效果中且距离过远,且没有金箍棒")
                return false
            end
        end
    end
    return true
end


function CommonAI:HandleFamiliarGuard()
    -- 寻找维萨吉本体
    local units = FindUnitsInRadius(
        self.entity:GetTeamNumber(),
        self.entity:GetAbsOrigin(),
        nil,
        1500, -- 搜索范围可以根据需要调整
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    local visage = nil
    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_dota_hero_visage" then
            visage = unit
            break
        end
    end

    if visage then
        local visagePos = visage:GetAbsOrigin()
        local visageForward = visage:GetForwardVector()
        local targetPos = visagePos + visageForward * 50
        
        self.entity:MoveToPosition(targetPos)
        self:log("维萨吉魔像移动到本体前方50码处")
        return self.nextThinkTime
    end

    return self.nextThinkTime
end