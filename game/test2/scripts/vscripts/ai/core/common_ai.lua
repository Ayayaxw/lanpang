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

function CommonAI:constructor(entity, overallStrategy, heroStrategy, thinkInterval)
    -- 初始化策略
    self.global_strategy = overallStrategy or {"默认策略"}
    self.hero_strategy = heroStrategy or {"默认策略"}

    self.canReleaseIceBlast = false
    self:Ini_MediumPrioritySkills()
    self:Ini_DisabledSkills()
    self:Ini_HighPrioritySkills()
    self:Ini_SkillAoeRadius()
    self:Ini_SkillCastRange()
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

function CommonAI.new(entity, overallStrategy, heroStrategy, thinkInterval)
    local instance = setmetatable({}, CommonAI)  -- 直接使用 CommonAI 作为元表
    instance:constructor(entity, overallStrategy, heroStrategy, thinkInterval)
    return instance
end

function CommonAI:Think(entity)
    self.entity = entity  -- 设置当前实体

    -- 检查实体是否存在
    if not entity or entity:IsNull() then
        self:log("[AI] 实体不存在，终止AI")
        return nil  -- 彻底停止AI循环
    end

    if self.shouldStop == true then
        if self.currentState ~= AIStates.Idle then
            -- 设置状态为Idle
            self.currentState = AIStates.Idle
            self.pendingSpellCast = nil
            -- 记录日志
            entity:Stop()
            self:log("[STORM_TEST]收到停止指令，切换到Idle状态")
            
            -- 重置shouldStop标志
            self.shouldStop = false
        end
    end
    
    if hero_duel.EndDuel then
        return nil
    end

    -- 英雄死亡继续循环，但不执行后续AI逻辑
    if not entity:IsAlive() then
        return 1  -- 1秒后继续检查
    end

    self.shouldturn = nil
    self:ProcessPendingSpellCast()

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

    local target, enemyHeroCount = self:FindHeroTarget(entity)

    -- 获取最后手段目标,保存在新变量中
    self.lastResortTarget = self:FindNearestEnemyLastResort(entity)
    
    self.attackTarget = self:FindPreferredTarget(entity, {
        "npc_dota_unit_tombstone",
        "npc_dota_phoenix_sun", 
        "npc_dota_pugna_nether_ward",
        "npc_dota_juggernaut_healing_ward",
    })
    
    if self:containsStrategy(self.global_strategy, "优先打小僵尸") then
        self.attackTarget, enemyHeroCount = self:FindPreferredTarget(entity, {
            "npc_dota_unit_undying_zombie_torso",
            "npc_dota_unit_undying_zombie"
        })
    end
    self.enemyHeroCount = enemyHeroCount
    if target then
        self:log("找到英雄目标了，敌人数量：" .. self.enemyHeroCount)
    else
        self:log("没有找到英雄目标")
        -- 如果没有找到英雄单位，再寻找普通单位
        target = self:FindTarget(entity)
        if target then
            self:log("找到普通目标了")
        else
            if self:containsStrategy(self.global_strategy, "攻击无敌单位") then
                self:log("是时候攻击无敌单位")
                target = self.lastResortTarget
            end
        end
    end
    if target then
        self.target = target
        if not self.attackTarget then
            self.attackTarget = target
        end
    elseif (entity:GetUnitName() == "npc_dota_hero_invoker" or entity:GetUnitName() == "npc_dota_hero_shadow_demon") and 
        self.lastResortTarget and
        (self.lastResortTarget:HasModifier("modifier_invoker_tornado") or 
         self.lastResortTarget:HasModifier("modifier_shadow_demon_disruption")) then
        self.target = self.lastResortTarget
        target = self.lastResortTarget
        print("卡尔模式")
    else
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
            target = self.attackTarget
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
        return 0.5
    end


    if self:containsStrategy(self.global_strategy, "辅助模式") then
        if entity and entity:IsMoving() then
            return self.nextThinkTime
        end
    end



    local skill, castRange, aoeRadius = self:FindBestAbilityToUse(entity,target)

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
        if target then
            
            -- 处理特殊技能的逻辑
            local result = self:AdjustAbilityTarget(entity, abilityInfo, target)
            if result ~= false then
                target = result
            end
            --self.target = target

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
            self:HandleNoTargetFound(entity)
        end
    else
        -- 没有找到技能，执行攻击逻辑
        print("没有找到技能，执行攻击逻辑")
        return self:HandleAttack(target)
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

function CommonAI:HandleTinyTreeGrab(entity)
    local searchRadius = 400  -- Tree Grab 的搜索范围
    local trees = GridNav:GetAllTreesAroundPoint(entity:GetAbsOrigin(), searchRadius, true)
    local closestTree = nil
    local closestDistance = math.huge

    for _, tree in pairs(trees) do
        local treePos = tree:GetAbsOrigin()
        local distance = (treePos - entity:GetAbsOrigin()):Length2D()
        if distance < closestDistance then
            closestTree = tree
            closestDistance = distance
        end
    end

    if closestTree then
        self:log("已经为小小找到了最近的树木目标")
        self.treetarget = closestTree
    else
        self:log("小小周围没有找到可抓取的树木")
        self.treetarget = nil
    end
    return self.target
end

function CommonAI:AdjustAbilityTarget(entity, abilityInfo, target)
    -- 处理特定技能的特殊逻辑，例如 muerta_dead_shot
    if abilityInfo.abilityName == "muerta_dead_shot" then
        return self:HandleMuertaDeadShot(entity,abilityInfo.skill)
    elseif abilityInfo.abilityName == "tiny_tree_grab" then
        return self:HandleTinyTreeGrab(entity)
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
    local closestTree = nil
    local closestDistance = math.huge

    for _, tree in pairs(trees) do
        local treePos = tree:GetAbsOrigin()
        local treeDistanceToPlayer = (treePos - entity:GetOrigin()):Length2D()
        if treeDistanceToPlayer < closestDistance then
            closestTree = tree
            closestDistance = treeDistanceToPlayer
        end
    end

    if closestTree then
        self:log("已经为琼英碧灵找好了树木目标")
        self.treetarget = closestTree
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
                if self:IsInRange(target, abilityInfo.aoeRadius) then
                    entity:CastAbilityOnTarget(entity, abilityInfo.skill, 0)
                    self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, entity)
                else
                    -- 敌人不在施法范围内
                    if self.currentState ~= AIStates.Channeling then
                        -- 移动到施法距离内
                        self:MoveToRange(targetInfo.targetPos, abilityInfo.aoeRadius)
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
            if self:IsInRange(currentTarget, abilityInfo.castRange) then
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
                    self:MoveToRange(targetPosition, abilityInfo.castRange)
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
        if self:IsInRange(target, abilityInfo.castRange) then
            -- 敌人在施法范围内
            self:HandleEnemyPoint_InCastRange(entity, target, abilityInfo, targetInfo)
            self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
        elseif self:IsInRange(target, abilityInfo.castRange + abilityInfo.aoeRadius) then
            -- 敌人在作用范围内
            self:HandleEnemyPoint_InAoeRange(entity, target, abilityInfo, targetInfo)
            self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
        else
            -- 敌人不在范围内
            if self:HandleEnemyPoint_OutofRangeAction(entity, target, abilityInfo, targetInfo) then
                self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
            else
                -- 移动到施法距离内
                self:MoveToRange(targetInfo.targetPos, abilityInfo.castRange + abilityInfo.aoeRadius)
                self:SetState(AIStates.Seek)
                self:log(string.format("不在施法范围内，移动到施法范围，进入Seek状态，目标距离: %.2f，施法距离+作用范围: %.2f", targetInfo.distance, abilityInfo.castRange + abilityInfo.aoeRadius))
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
    
    if abilityInfo.aoeRadius == 0 and abilityInfo.castRange == 0 then
        self:log(string.format("技能: %s 没有作用范围，直接释放", abilityInfo.abilityName))
        entity:CastAbilityNoTarget(abilityInfo.skill, 0)
        self:OnSpellCast(entity, abilityInfo.skill, abilityInfo.castPoint, abilityInfo.channelTime, target)
    else
        if self:IsInRange(target, abilityInfo.aoeRadius + abilityInfo.castRange) then

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
            self:MoveToRange(targetInfo.targetPos, abilityInfo.aoeRadius + abilityInfo.castRange)
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
        self:HandleAttack(target)
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

    elseif self.entity:HasModifier("modifier_pangolier_gyroshell") or self.entity:HasModifier("modifier_rattletrap_jetpack") or self.entity:HasModifier("modifier_mars_bulwark_active") then
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
    end


    if self:containsStrategy(self.global_strategy, "不要优先拆墓碑、棒子") then
        
    elseif self:containsStrategy(self.global_strategy, "优先打小僵尸") then
        target = self.attackTarget
    else 
        target = self.attackTarget
    end

    if not target then
        return self.nextThinkTime
    end

    -- 检查目标是否无敌
    if not self:CanAttackTarget(self.entity, target) then
        print("对面无敌了")
        -- 目标无敌时只移动不设置攻击状态
        local order = {
            UnitIndex = self.entity:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            TargetIndex = target:entindex(),
            Position = targetInfo and targetInfo.targetPos or target:GetAbsOrigin()
        }
        ExecuteOrderFromTable(order)
    else
                -- 已在攻击状态
        if self.entity:IsAttacking() then
            self:log("已经在攻击状态")
            return self.nextThinkTime
        end
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

    local targetName = "unknown"
    if target and type(target.GetUnitName) == "function" then
        targetName = target:GetUnitName()
    end
    self:log("进入攻击状态，攻击目标:", targetName)
    
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