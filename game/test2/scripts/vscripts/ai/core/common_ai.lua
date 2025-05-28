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
require("ai/skill/AutoUpgradeHeroAbilities")
require("ai/skill/OnSpellCast")
require("ai/skill/ShouldDodgeSkill")


require("ai/skill/SkillHandlers/EnemyTarget_InRange")
require("ai/skill/SkillHandlers/EnemyTarget_OutOfRange")

require("ai/skill/SkillHandlers/EnemyPoint_InCastRange")
require("ai/skill/SkillHandlers/EnemyPoint_InAoeRange")
require("ai/skill/SkillHandlers/EnemyPoint_OutOfRange")

require("ai/skill/SkillHandlers/AllyTarget_InRange")
require("ai/skill/SkillHandlers/AllyTarget_OutOfRange")
require("ai/skill/SkillHandlers/HandleAbility_function")

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
require("ai/skill/SkillInfo/GetSkill_Behavior")
require("ai/skill/SkillInfo/GetSkill_TargetType")

require("ai/skill/SkillInfo/GetSkill_AvoidableSkills")
require("ai/skill/SkillInfo/GetSkill_EvasionSkills")
require("ai/skill/SkillInfo/GetSkill_NumberMapping")


AIStates = {
    Idle = 0,
    Seek = 1,
    Attack = 2,
    CastSpell = 4,
    Channeling = 8,
    UseItem = 16,
    PostCast = 32,

}

function CommonAI:constructor(entity, overallStrategy, heroStrategy, thinkInterval, otherSettings)
    -- 初始化策略
    self.global_strategy = overallStrategy or {"默认策略"}
    self.hero_strategy = heroStrategy or {"默认策略"}
    if otherSettings then
        self.skillThresholds = otherSettings.skillThresholds or {}
    end
    self.canReleaseIceBlast = false
    self:Ini_MediumPrioritySkills()
    self:Ini_DisabledSkills()
    self:Ini_HighPrioritySkills()
    self:Ini_SkillAoeRadius()
    self:Ini_SkillCastRange()
    self:Ini_SkillTargetTeam()
    self:Init_AvoidableSkills()
    self:Init_EvasionSkills()
    self:Ini_SkillBehavior()
    self:Ini_SkillTargetType()
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
    
    -- 躲避技能相关变量
    self.needToDodge = false
    self.dodgeableAbilities = nil
    self.lastDodgeTime = 0  -- 上次躲避的时间，防止频繁躲避
    
    -- 新增：躲避技能队列和模式标志
    self.dodgeSkillQueue = {}  -- 需要释放的躲避技能队列
    self.isDodgeMode = false   -- 是否处于躲避模式
end

function CommonAI.new(entity, overallStrategy, heroStrategy, thinkInterval,otherSettings)
    local instance = setmetatable({}, CommonAI)  -- 直接使用 CommonAI 作为元表
    instance:constructor(entity, overallStrategy, heroStrategy, thinkInterval,otherSettings)
    return instance
end



function CommonAI:Think(entity)
    self.entity = entity  -- 设置当前实体

    if hero_duel.EndDuel then
        self:log("[AI] 决斗结束，终止AI - 英雄: " .. entity:GetName())
        return nil
    elseif not entity:IsAlive() then
        self:log("[AI] 英雄已死亡，等待复活 - 英雄: " .. entity:GetName())
        return 0.5  -- 1秒后继续检查
    elseif self:containsStrategy(self.global_strategy, "仅仅控制召唤物") and not self.entity:IsRealHero() then
        self:log("仅仅控制召唤物")
        return nil
    elseif not entity or entity:IsNull() then
        self:log("[AI] 实体不存在，终止AI - Entity: " .. (entity and entity:GetName() or "nil"))
        return nil  -- 彻底停止AI循环        
    elseif self:containsStrategy(self.global_strategy, "辅助模式") and entity:IsMoving() then
        return self.nextThinkTime
    end

    -- 躲避技能判断 - 在所有其他逻辑之前进行
    if self:containsStrategy(self.global_strategy, "躲技能模式") and self:ShouldDodgeSkill(entity) then
        -- 躲避逻辑已在ShouldDodgeSkill中设置标志位
        self:log("[AI] 需要躲避，已设置躲避标志位")
    else
        -- 重置躲避标志位
        self:log("躲避检测未通过")
        self.shouldUseDodgeSkills = false
        self.currentAvailableDodgeSkills = nil
    end

    if entity:IsMoving() and self:containsStrategy(self.global_strategy, "原地不动") then
        self:log("英雄正在移动")
        entity:Stop()
    end

    if entity:IsRealHero() then
        if entity:GetAbilityPoints() > 0 then
            Main:AutoUpgradeHeroAbilities(entity)
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

    local temptime  = self:ProcessPendingSpellCast() 
    if temptime then
        self:log("有移动后施法指令，直接返回")
        return temptime
    end

    self.target = nil
    self.attackTarget = nil
    self.isSpecialChannelingHero = self:IsSpecialChannelingHero(entity)

    if self.currentState == AIStates.Channeling and 
    self.isSpecialChannelingHero then
     if not entity:IsChanneling() then
         self:log("特殊英雄持续施法结束，设置为空闲状态")
         self:SetState(AIStates.Idle)
     end
    elseif self.currentState == AIStates.CastSpell or 
            (self.currentState == AIStates.Channeling and not self.isSpecialChannelingHero) then
        self:log("正在施法中，跳过本次 AI 思考过程")
        return self.nextThinkTime
    end
    
    -- 使用新的目标查找函数
    local targetResults = self:FindAiBestTargets(entity)
    
    if self:containsStrategy(self.global_strategy, "朝无敌单位移动") and targetResults.target:IsInvulnerable() then
        self.entity:MoveToPosition(targetResults.lastResortTarget:GetOrigin())
        return self.nextThinkTime
    end



    
    -- 如果是弱AI单位且已处理完毕，直接返回
    if targetResults.isWeakAIHandled then
        return 1
    end
    
    -- 设置找到的目标
    local target = targetResults.target
    self.attackTarget = targetResults.attackTarget
    self.lastResortTarget = targetResults.lastResortTarget

    -- 7. 最终目标确定
    if target then
        self.target = target
    elseif not self.attackTarget then
        if entity:IsAttacking() then
            entity:Stop()
        end
        if not entity:IsChanneling() then
            entity:Stop()
        end
        return self.nextThinkTime
    end





    self.Ally = self:FindNearestNoSelfAlly(entity)

    local skill, castRange, aoeRadius
    if target and not self:containsStrategy(self.global_strategy, "禁用所有技能") then
        skill, castRange, aoeRadius = self:FindBestAbilityToUse(entity,target)
    end

    if skill then
        skill, castRange, aoeRadius = self:HandleEarthSpiritLogic(entity, skill, castRange, aoeRadius)
        
        local abilityInfo = self:GetAbilityInfo(skill, castRange, aoeRadius)



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
    local searchRadius = self:GetSkillCastRange(entity, ability)*2
    local trees = GridNav:GetAllTreesAroundPoint(searchCenter, searchRadius, true)
    local validTrees = {}
    
    self:log("搜索到树木总数: " .. #trees)
    
    -- 计算从自己到敌人的方向向量
    local entityPos = entity:GetAbsOrigin()
    local targetPos = self.target:GetAbsOrigin()
    
    -- 打印玩家和敌人的坐标
    self:log("玩家位置: (" .. string.format("%.2f", entityPos.x) .. 
            "," .. string.format("%.2f", entityPos.y) .. 
            "," .. string.format("%.2f", entityPos.z) .. ")")
    self:log("敌人位置: (" .. string.format("%.2f", targetPos.x) .. 
            "," .. string.format("%.2f", targetPos.y) .. 
            "," .. string.format("%.2f", targetPos.z) .. ")")
    self:log("搜索中心(敌人位置): (" .. string.format("%.2f", searchCenter.x) .. 
            "," .. string.format("%.2f", searchCenter.y) .. 
            "," .. string.format("%.2f", searchCenter.z) .. ")")
    self:log("搜索半径: " .. string.format("%.2f", searchRadius))
    
    -- 打印所有搜索到的树木信息（不管是否在施法范围内）
    self:log("=== 所有搜索到的树木原始信息 ===")
    for i, tree in pairs(trees) do
        local treePos = tree:GetAbsOrigin()
        local treeDistanceToPlayer = (treePos - entityPos):Length2D()
        local treeDistanceToEnemy = (treePos - targetPos):Length2D()
        self:log("树木" .. i .. " 位置:(" .. string.format("%.2f", treePos.x) .. 
                "," .. string.format("%.2f", treePos.y) .. 
                "," .. string.format("%.2f", treePos.z) .. ")" ..
                " 到玩家距离:" .. string.format("%.2f", treeDistanceToPlayer) ..
                " 到敌人距离:" .. string.format("%.2f", treeDistanceToEnemy) ..
                " 施法范围:" .. string.format("%.2f", searchRadius))
    end
    self:log("=== 原始树木信息打印完毕 ===")
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
    local lineTrees = {}     -- 直线上的树
    
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
            
            -- 计算树到玩家-敌人连线的垂直距离
            local lineVector = dirToEnemy  -- 连线方向向量
            local treeVector = treePos - entityPos  -- 从玩家到树的向量
            -- 计算树在连线上的投影长度
            local projectionLength = treeVector:Dot(lineVector)
            -- 计算投影点
            local projectionPoint = entityPos + lineVector * projectionLength
            -- 计算垂直距离
            local perpendicularDistance = (treePos - projectionPoint):Length2D()
            
            local treeInfo = {
                tree = tree, 
                distance = treeDistanceToPlayer,
                position = treePos,
                id = treeCount,
                angle = angleToTree,    -- 保存夹角
                behindEnemy = isBehindEnemy,  -- 是否在敌人身后
                perpendicularDistance = perpendicularDistance  -- 到连线的垂直距离
            }
            
            -- 如果策略是"射直线上的树"
            if self:containsStrategy(self.hero_strategy, "射直线上的树") then
                table.insert(lineTrees, treeInfo)
                self:log("找到直线上的树 ID:" .. treeCount .. 
                        " 位置:(" .. string.format("%.2f", treePos.x) .. 
                        "," .. string.format("%.2f", treePos.y) .. 
                        "," .. string.format("%.2f", treePos.z) .. ")" ..
                        " 垂直距离:" .. string.format("%.2f", perpendicularDistance) ..
                        " 到玩家距离:" .. string.format("%.2f", treeDistanceToPlayer))
            -- 如果策略是"往前弹射"且树在敌人身后
            elseif self:containsStrategy(self.hero_strategy, "往前弹射") and isBehindEnemy then
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
    
    self:log("前方树木数量: " .. #frontalTrees .. ", 其他方向树木数量: " .. #otherTrees .. ", 敌人身后树木数量: " .. #behindEnemyTrees .. ", 直线上树木数量: " .. #lineTrees)
    
    -- 确定使用哪组树
    local treesToUse = nil
    if self:containsStrategy(self.hero_strategy, "射直线上的树") then
        -- 打印所有搜索到的树的详细信息
        self:log("=== 所有搜索到的树木信息 ===")
        for _, tree in pairs(trees) do
            local treePos = tree:GetAbsOrigin()
            local treeDistanceToPlayer = (treePos - entityPos):Length2D()
            
            if treeDistanceToPlayer <= searchRadius then
                -- 计算垂直距离
                local lineVector = dirToEnemy
                local treeVector = treePos - entityPos
                local projectionLength = treeVector:Dot(lineVector)
                local projectionPoint = entityPos + lineVector * projectionLength
                local perpendicularDistance = (treePos - projectionPoint):Length2D()
                
                self:log("树木位置:(" .. string.format("%.2f", treePos.x) .. 
                        "," .. string.format("%.2f", treePos.y) .. 
                        "," .. string.format("%.2f", treePos.z) .. ")" ..
                        " 垂直距离:" .. string.format("%.2f", perpendicularDistance) ..
                        " 到玩家距离:" .. string.format("%.2f", treeDistanceToPlayer))
            end
        end
        self:log("=== 树木信息打印完毕 ===")
        
        if #lineTrees > 0 then
            treesToUse = lineTrees
            self:log("使用直线上的树木")
        else
            self:log("未找到直线上的树木，不选择任何树木")
            self.treetarget = nil
            return self.target
        end
    elseif self:containsStrategy(self.hero_strategy, "往前弹射") then
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
        -- 根据策略选择不同的排序方式
        if self:containsStrategy(self.hero_strategy, "射直线上的树") then
            -- 射直线上的树：按垂直距离排序(垂直距离近的优先)
            table.sort(treesToUse, function(a, b)
                if math.abs(a.perpendicularDistance - b.perpendicularDistance) < 0.1 then
                    -- 如果垂直距离很接近，使用ID排序保证稳定性
                    return a.id < b.id
                else
                    -- 垂直距离近的优先
                    return a.perpendicularDistance < b.perpendicularDistance
                end
            end)
        else 
            -- 射最近的树：按距离排序(距离近的优先)
            table.sort(treesToUse, function(a, b)
                if math.abs(a.distance - b.distance) < 0.1 then
                    -- 如果距离很接近，使用ID排序保证稳定性
                    return a.id < b.id
                else
                    -- 距离近的优先
                    return a.distance < b.distance
                end
            end)

        end
        
        local selectedTree = treesToUse[1]
        local treePos = selectedTree.position
        
        self:log("选中树木: " .. 
                (treesToUse == lineTrees and "直线上" or
                (treesToUse == behindEnemyTrees and "敌人身后" or 
                (treesToUse == frontalTrees and "前方" or "其他方向"))) ..
                " ID:" .. selectedTree.id .. 
                " 距离:" .. string.format("%.2f", selectedTree.distance) .. 
                " 角度:" .. string.format("%.2f", math.deg(selectedTree.angle)) .. "度" ..
                (treesToUse == lineTrees and (" 垂直距离:" .. string.format("%.2f", selectedTree.perpendicularDistance)) or "") ..
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

function CommonAI:HandleUnableToCast(entity, target, abilityInfo, targetInfo)
    -- 检查是否有特殊无敌状态
    if entity:HasModifier("modifier_void_spirit_dissimilate_phase") or 
       entity:HasModifier("modifier_dawnbreaker_solar_guardian_air_time") or 
       entity:HasModifier("modifier_snapfire_mortimer_kisses") then
        self:log("正在执行特殊无敌技能")
        if self.currentState ~= AIStates.CastSpell and self.currentState ~= AIStates.Channeling and not self:containsStrategy(self.global_strategy, "原地不动") then
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


function CommonAI:HandleAttack(target, abilityInfo, targetInfo)
    -- 首先判断单位是否可以攻击

    if self:containsStrategy(self.global_strategy, "禁用普攻") then
        self:log("禁用普攻")
        --如果正在普攻，stop
        self.entity:SetIdleAcquire(false)

        if self.entity:IsAttacking() and not self.entity:IsTaunted() then
            self:log("正在普攻，stop")
            self.entity:Stop()
        end
        return self.nextThinkTime

    end

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
        if not self:containsStrategy(self.global_strategy, "不要优先拆墓碑、棒子") then
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

        if self:containsStrategy(self.global_strategy, "原地不动") then
            return self.nextThinkTime
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
    elseif self:IsTargetInMagneticField(self.entity, target) then
        return self.nextThinkTime
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



    return true
end


function CommonAI:IsTargetInMagneticField(entity, target)
    local distance = (entity:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
    if target and type(target.FindModifierByName) == "function" then
        local magneticFieldModifier = target:FindModifierByName("modifier_arc_warden_magnetic_field_evasion")
        if magneticFieldModifier and not magneticFieldModifier:IsDebuff() then
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
                self:log("目标处于磁场效果中，查找磁场thinker")
                
                -- 全局查找所有thinker（只查找一次）
                local allThinkers = Entities:FindAllByClassname("npc_dota_thinker")
                local magneticFieldThinker = nil
                local entityHasMagneticField = entity:FindModifierByName("modifier_arc_warden_magnetic_field_evasion")
                
                -- 在同一个循环中处理距离检查和查找最近的thinker
                for _, thinker in pairs(allThinkers) do
                    if thinker and not thinker:IsNull() and thinker:HasModifier("modifier_arc_warden_magnetic_field_thinker_evasion") then
                        local entityPos = entity:GetAbsOrigin()
                        local thinkerPos = thinker:GetAbsOrigin()
                        local thinkerDistance = (entityPos - thinkerPos):Length2D()
                        
                        -- 如果entity有磁场modifier且距离小于250码，则无需移动
                        if entityHasMagneticField and thinkerDistance < 250 then
                            self:log("entity有磁场modifier且距离磁场thinker小于250码，无需移动")
                            return false
                        end
                        
                        -- 记录第一个找到的磁场thinker用于后续移动
                        if not magneticFieldThinker then
                            magneticFieldThinker = thinker
                        end
                    end
                end
                
                -- 如果entity有磁场modifier但距离所有thinker都大于等于250码
                if entityHasMagneticField then
                    self:log("entity有磁场modifier但距离所有thinker都大于等于250码，需要处理移动")
                end
                
                -- 处理移动逻辑
                if magneticFieldThinker then
                    local entityPos = entity:GetAbsOrigin()
                    local thinkerPos = magneticFieldThinker:GetAbsOrigin()
                    local thinkerDistance = (entityPos - thinkerPos):Length2D()
                    
                    if thinkerDistance > 200 then
                        self:log("距离磁场thinker超过100码，移动到100码范围内")
                        -- 计算从thinker到entity的方向向量
                        local direction = (entityPos - thinkerPos):Normalized()
                        -- 计算距离thinker 100码的目标位置
                        local movePosition = thinkerPos + direction * 200
                        
                        local order = {
                            UnitIndex = entity:entindex(),
                            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                            Position = movePosition,
                            Queue = false
                        }
                        ExecuteOrderFromTable(order)
                        return true
                    else
                        self:log("已在磁场thinker 100码范围内，无需移动")
                    end
                else
                    self:log("未找到磁场thinker，使用原来的方法")
                    -- 计算目标的朝向向量
                    local targetForward = target:GetForwardVector():Normalized()
                    -- 计算目标身后100码的位置
                    local movePosition = target:GetAbsOrigin() - targetForward * 200
                    
                    local order = {
                        UnitIndex = entity:entindex(),
                        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                        TargetIndex = target:entindex(),
                        Position = movePosition,
                        Queue = false
                    }
                    ExecuteOrderFromTable(order)
                    return true
                end
                
                return true
            end
        end
    end

    return false
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
