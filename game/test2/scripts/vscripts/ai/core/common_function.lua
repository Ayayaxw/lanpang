


function CommonAI:log(...)
    if DEBUG_MODE then
        local currentTime = GameRules:GetGameTime()
        local stateName = CommonAI:GetStateName(self.currentState)
        local entityName = "未知实体"
        local nameSource = ""
        
        if self.entity then
            if self.entity.GetUnitName then
                entityName = self.entity:GetUnitName()
                nameSource = "UnitName"
            else
                entityName = self.entity:GetName()
                nameSource = "Name"
            end
        end
        
        print(string.format("[%.2f] AI [%s] [%s(%s)] [%s]: ", currentTime, self.id, entityName, nameSource, stateName), ...)
    end
end

function CommonAI:GetStateName(state)
    for name, value in pairs(AIStates) do
        if value == state then
            return name
        end
    end
    return "Unknown"
end


function CommonAI:containsStrategy(strategies, targetStrategy)
    if type(strategies) == "table" then
        for _, strategy in pairs(strategies) do
            if strategy == targetStrategy then
                return true
            end
        end
    end
    return false
end

function CommonAI:IsSpecialChannelingHero(entity)
    local heroName = entity:GetUnitName()
    
    -- Pugna 和 Lion 不需要额外条件
    if heroName == "npc_dota_hero_pugna" then
        return true
    end
    if heroName == "npc_dota_hero_lion" then
        return true
    end
    if heroName == "npc_dota_hero_warlock" then
        return true
    end
    if heroName == "npc_dota_hero_riki" then
        return true
    end
    if heroName == "npc_dota_hero_drow_ranger" then
        return true
    end
    if heroName == "npc_dota_hero_puck" and self:containsStrategy(self.hero_strategy, "相位转移打伤害") then
        local phase_shift = entity:FindAbilityByName("puck_phase_shift")
        if phase_shift and phase_shift:GetCooldownTimeRemaining() < 0.4 then
            entity:MoveToPosition(entity:GetAbsOrigin())
            return true
        end
    end
    
    -- Lich 需要神杖
    if heroName == "npc_dota_hero_lich" then
        return entity:HasScepter()
    end
    
    -- Bane 需要没有幻象禁锢modifier且有神杖
    if heroName == "npc_dota_hero_bane" then
        print("bane特殊施法")
        return not entity:HasModifier("modifier_bane_fiends_grip_illusion") and entity:HasScepter()
    end
    
    return false
end

function CommonAI:IsItemReady(item)
    local owner = item:GetCaster()  -- 获取物品的持有者
    local itemName = item:GetAbilityName()  -- 只调用一次 GetAbilityName
    local itemSlot = item:GetItemSlot()

    -- 判断物品是否因缠绕效果无法使用
    local function IsItemDisabledByRoot(unit, ability)
        -- 获取单位是否被缠绕
        local isRooted = unit:IsRooted()

        -- 如果单位被缠绕，进一步检查物品是否受影响
        if isRooted then
            -- 获取物品的行为属性
            local abilityBehavior = ability:GetBehavior()

            -- 检查 abilityBehavior 是否为 nil
            if abilityBehavior == nil then
                self:log("错误：物品 " .. itemName .. " 的 abilityBehavior 为 nil")
                return false
            end
            
            -- 检查物品行为是否包含DOTA_ABILITY_BEHAVIOR_ROOT_DISABLE
            if bit.band(abilityBehavior, DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES) ~= 0 then
                self:log("物品 " .. itemName .. " 因缠绕效果无法使用")
                return true
            end
        end
        
        return false
    end

    -- 检查物品是否隐藏
    if item:IsHidden() then
        self:log("物品 " .. itemName .. " 处于隐藏状态，无法使用")
        return false
    end

    -- 检查单位是否处于物品禁用状态
    if owner:IsMuted() then
        self:log("单位处于物品禁用状态，无法使用物品")
        return false
    end

    -- 检查物品冷却
    if not item:IsCooldownReady() then
        self:log("物品 " .. itemName .. " 正在冷却中，无法使用")
        return false
    end

    -- 检查物品魔法值
    if not item:IsOwnersManaEnough() then
        self:log("物品 " .. itemName .. " 因魔法值不足无法使用")
        return false
    end

    -- 检查物品是否可完全使用
    if not item:IsFullyCastable() then
        self:log("物品 " .. itemName .. " 无法完全使用")
        return false
    end

    -- 检查物品是否因缠绕效果无法使用
    if IsItemDisabledByRoot(owner, item) then
        return false
    end

    -- 检查物品充能数量（对于有充能的物品）
    if item:RequiresCharges() and item:GetCurrentCharges() <= 0 then
        self:log("物品 " .. itemName .. " 充能不足，无法使用")
        return false
    end

    -- 新增检查:装备槽位和英雄限制
    if itemSlot >= 6 and itemSlot <= 8 then
        if owner:GetUnitName() ~= "npc_dota_hero_techies" or owner:GetHeroFacetID() ~= 3 then
            self:log("物品 " .. itemName .. " 在槽位" .. itemSlot .. "且英雄限制，无法使用")
            return false
        end
    end

    self:log("物品 " .. itemName .. " 检查通过，可以使用")
    return true
end

function CommonAI:IsSkillReady(skill)
    local owner = skill:GetCaster()  -- 获取技能的施法者
    local isInvoker = self.entity:GetUnitName() == "npc_dota_hero_invoker"
    local abilityName = skill:GetAbilityName()  -- 只调用一次 GetAbilityName

    -- 判断技能是否因缠绕效果无法使用
    local function IsAbilityDisabledByRootOrLeash(unit, ability)
        -- Check if unit is rooted
        local isRooted = unit:IsRooted()
        
        -- Check if unit is leashed
        local hasLeashModifier = unit:IsLeashed()
        
        -- If unit is rooted or leashed, check ability behavior
        if isRooted or hasLeashModifier then
            local abilityBehavior = ability:GetBehavior()
            
            if abilityBehavior == nil then
                return false
            end
            
            if bit.band(abilityBehavior, DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES) ~= 0 then
                return true
            end
        end
        
        return false
    end

    -- 检查技能是否隐藏（排除特定技能）
    if not isInvoker and skill:IsHidden() then
        self:log("技能 " .. abilityName .. " 处于隐藏状态，无法使用")
        return false
    end

    -- 检查技能冷却
    if not skill:IsCooldownReady() then
        self:log("技能 " .. abilityName .. " 正在冷却中，无法使用")
        return false
    end

    -- 检查技能魔法值
    if not skill:IsOwnersManaEnough() then
        self:log("技能 " .. abilityName .. " 因魔法值不足无法施放")
        return false
    end

    -- 检查技能是否可完全施放
    if not skill:IsFullyCastable() then
        self:log("技能 " .. abilityName .. " 无法完全施放")
        return false
    end

    -- 检查技能是否因缠绕效果无法使用
    if IsAbilityDisabledByRootOrLeash(owner, skill) then
        return false
    end

    self:log("技能 " .. abilityName .. " 检查通过，可以使用")
    return true
end




function CommonAI:MoveToRange(targetPosition, range)
    if self:containsStrategy(self.global_strategy, "原地不动") then
        self:log("策略:原地不动,禁止移动")
        --如果self.entity被沉默了，不return
        if not self.entity:IsSilenced() then
            return
        end

        
    end

    local target = self.target
    local myPos = self.entity:GetAbsOrigin()
    local targetPos = target:GetAbsOrigin()
    local direction = (targetPos - myPos):Normalized()
    local attackRange = self.entity:Script_GetAttackRange()
    
    -- 获取范围内所有单位
    local units = FindUnitsInRadius(
        self.entity:GetTeamNumber(),
        myPos,
        nil,
        attackRange,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    
    local nearestCog = nil
    local nearestDistance = attackRange
    
    for _, unit in pairs(units) do
        if unit:GetUnitName() == "npc_dota_rattletrap_cog" then
            local cogPos = unit:GetAbsOrigin()
            local cogToSelf = cogPos - myPos
            
            -- 检查是否在朝向敌人的方向
            local dotProduct = direction:Dot(cogToSelf:Normalized())
            if dotProduct > 0 then
                local distance = (cogPos - myPos):Length2D()
                if distance < nearestDistance then
                    nearestCog = unit
                    nearestDistance = distance
                end
            end
        end
    end
    
    if nearestCog then
        -- 检查是否可以攻击
        if self:IsUnableToAttack(self.entity, nearestCog) then
            return self.nextThinkTime
        end
        
        -- 检查是否已经在攻击这个目标
        if not (self.entity:IsAttacking() and self.entity:GetAttackTarget() == nearestCog) then
            self:SetState(AIStates.Attack)
            local order = {
                UnitIndex = self.entity:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = nearestCog:entindex(),
                Position = nearestCog:GetAbsOrigin()
            }
            ExecuteOrderFromTable(order)
            
        end
        return 
    end


    local distance = (self.entity:GetOrigin() - targetPosition):Length2D()
    
    if distance > range then
        local movePosition = targetPosition + (self.entity:GetOrigin() - targetPosition):Normalized() * (range-50)
        
        if self.entity:HasModifier("modifier_pangolier_gyroshell") or self.entity:HasModifier("modifier_snapfire_mortimer_kisses") or self.entity:HasModifier("modifier_rattletrap_jetpack")  then
            local order = {
                UnitIndex = self.entity:entindex(),
                OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
                TargetIndex = self.target and self.target:entindex(),
                Position = movePosition
            }
            ExecuteOrderFromTable(order)
            self:log("滚滚老奶奶跟随")
        else
            if not self.entity:IsChanneling() then

                if self:containsStrategy(self.global_strategy, "谁近打谁") then
                    local isTargetClosest = false
                    -- 检查当前目标是否就是最近的目标
                    local entities = FindUnitsInRadius(
                        self.entity:GetTeamNumber(),
                        self.entity:GetAbsOrigin(),
                        nil,
                        999999,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_ALL,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_CLOSEST,
                        false
                    )
                    if #entities > 0 and entities[1] == target then
                        isTargetClosest = true
                    end
                
                    if isTargetClosest then
                        -- 如果目标是最近的单位,执行移动
                        self.entity:MoveToPosition(movePosition)
                        self:log(string.format("目标是最近单位,移动至距离 %s %d 范围内的位置 %s", tostring(targetPosition), range, tostring(movePosition)))
                    else
                        -- 如果目标不是最近的单位,执行原有的攻击逻辑
                        if self.entity:IsAttacking() then
                            return self.nextThinkTime
                        else
                            self:SetState(AIStates.Attack)
                            local order = {
                                UnitIndex = self.entity:entindex(),
                                OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                                TargetIndex = target:entindex(),
                                Position = targetPosition
                            }
                            ExecuteOrderFromTable(order)
                        end
                    end
                else
                    self.entity:MoveToPosition(movePosition)
                    self:log(string.format("移动至距离 %s %d 范围内的位置 %s", tostring(targetPosition), range, tostring(movePosition)))
                end
            end
        end
    else
        self:log("已在施法范围内，无需移动")
    end
end

function CommonAI:IsWeakIllusion(entity)
    -- 定义弱单位列表
    local weakUnits = {
        "npc_dota_creep"
    }
    
    -- 检查是否在弱单位列表中
    local unitName = entity:GetUnitName()
    local isWeakUnit = false
    for _, name in ipairs(weakUnits) do
        if string.find(unitName, name) then
            isWeakUnit = true
            break
        end
    end

    if isWeakUnit or
       (entity:IsIllusion() and 
       not entity:HasModifier("modifier_vengefulspirit_hybrid_special") and 
       not entity:HasModifier("modifier_morphling_replicate_morphed_illusions_effect")) then
        return true
    end
    return false
end


function CommonAI:IsUnableToCastAbility(entity, skill)
    local function printReason(reason)
        self:log("实体处于负面状态: " .. reason)
    end

    local isItem = skill and skill:IsItem()

    -- 特殊技能判断
    if skill and not isItem then
        -- 军团压制期间可以放压倒性优势
        if skill:GetAbilityName() == "legion_commander_overwhelming_odds" and entity:HasModifier("modifier_legion_commander_duel") then
            print("可以压倒性优势了")
            return false
        end
        
        -- 格挡状态下可以取消格挡
        if entity:HasModifier("modifier_kez_shodo_sai_parry") then
            if skill:GetAbilityName() == "kez_shodo_sai_parry_cancel" then
                return false
            else 
                return true
            end
        end
    end

    -- 老奶奶大招距离判断
    if entity:HasModifier("modifier_snapfire_mortimer_kisses") then
        local distanceToTarget = (self.target:GetOrigin() - entity:GetOrigin()):Length2D()
        if distanceToTarget > 300 then
            printReason("受到老奶奶大招效果且目标距离大于300")
            return true
        end
    end

    if self:IsWeakIllusion(entity) then
        printReason("是幻象单位")
        return true
    end

    -- 物品检查muted状态
    if isItem and entity:IsMuted() then
        printReason("被禁用物品")
        return true
    end

    -- 技能检查沉默状态(非沉默术士)
    if not isItem then
        local isSilencedButNotSilencer = entity:IsSilenced() and entity:GetUnitName() ~= "npc_dota_hero_silencer"
        if isSilencedButNotSilencer then
            printReason("被沉默（非沉默术士）")
            return true
        end
    end

    -- 控制效果判断
    if entity:IsHexed() then
        printReason("被妖术")
        return true
    end

    if entity:IsTaunted() then
        printReason("被嘲讽")
        return true
    end

    if entity:IsFeared() then
        printReason("被恐惧")
        return true
    end

    -- 负面modifier统一判断
    local negativeModifiers = {
        ["modifier_nevermore_requiem_fear"] = "影魔魂之挽歌恐惧",
        ["modifier_dark_willow_debuff_fear"] = "邪精灵恐惧",
        ["modifier_terrorblade_fear"] = "恐怖利刃恐惧",
        ["modifier_winter_wyvern_winters_curse"] = "寒冬飞龙冬天诅咒",
        ["modifier_void_spirit_aether_remnant_pull"] = "虚空之灵以太残影拉扯",
        ["modifier_brewmaster_primal_split_delay"] = "酒仙合体",
        ["modifier_meepo_megameepo"] = "米波合体",
        ["modifier_witch_doctor_voodoo_switcheroo"] = "巫医变形",
        ["modifier_dawnbreaker_solar_guardian_disable"] = "破晓晨星大招",
        ["modifier_dazzle_nothl_projection_physical_body_debuff"] = "戴泽灵魂状态",

    }

    for modifierName, description in pairs(negativeModifiers) do
        if entity:HasModifier(modifierName) then
            printReason("受到" .. description .. "效果")
            return true
        end
    end

    -- 特殊挑战模式判断
    if self:containsStrategy(self.global_strategy, "不在骨法棒子里放技能") and entity:HasModifier("modifier_pugna_nether_ward_aura") then
        return true
    end

    return false
end


function CommonAI:IsUnableToAttack(entity, target)

    if self:containsStrategy(self.global_strategy, "禁用普攻") then
        return true
    end
	
    

    local UNABLE_TO_ATTACK_MODIFIERS = {
        ["modifier_meepo_megameepo"] = true,
        ["modifier_hoodwink_sharpshooter_windup"] = true,
        ["modifier_spirit_breaker_charge_of_darkness"] = true,

    }

    local function printReason(reason)
        self:log("实体无法攻击: " .. reason)
    end

    -- 恐惧状态
    if entity:IsFeared() then
        printReason("处于恐惧状态")
        return true
    end
    
    -- 嘲讽状态
    if entity:IsTaunted() then
        printReason("处于嘲讽状态")
        return true
    end
    
    for modifierName, _ in pairs(UNABLE_TO_ATTACK_MODIFIERS) do
        if entity:HasModifier(modifierName) then
            printReason("有无法攻击的modifier: " .. modifierName)
            return true
        end
    end

    -- 施法或引导状态，但排除神杖大招的Bane
    local isChannelingBaneScepter = entity:GetUnitName() == "npc_dota_hero_bane" and 
                                   entity:HasScepter() and 
                                   entity:FindAbilityByName("bane_fiends_grip"):IsChanneling()

    if (self.currentState == AIStates.CastSpell or 
        self.currentState == AIStates.Channeling or 
        entity:IsChanneling()) and 
        not isChannelingBaneScepter then
        printReason("当前状态: " .. self.currentState)
        return true
    end
    -- 检查磁场效果
    local distance = (entity:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()

    -- 检查原地不动策略
    if self:containsStrategy(self.global_strategy, "原地不动") then
        local attackRange = entity:Script_GetAttackRange()
        if distance > attackRange then
            printReason("原地不动策略，目标超出攻击范围")
            if not self.entity:IsSilenced() then
                return true
            end

        end
    end
    
    return false
end




function CommonAI:calculateAdjustedCastPoint(caster, targetPosition, originalCastPoint)
    -- 获取施法人的前进方向和位置
    return originalCastPoint

    -- local forwardVector = caster:GetForwardVector()
    -- local casterPosition = caster:GetOrigin()

    -- -- 计算指向目标的方向向量
    -- local newDirection = (targetPosition - casterPosition):Normalized()

    -- -- 当前方向与目标方向的夹角（度）
    -- local angleDifference = math.deg(math.acos(forwardVector:Dot(newDirection)))
    -- self:log("当前方向与目标方向的夹角: " .. string.format("%.2f", angleDifference) .. " 度")

    -- -- 目标角度差
    -- local requiredAngle = 11.5
    -- self:log("目标角度差: " .. requiredAngle .. " 度")

    -- -- 获取转身速率
    -- local turnRate = self:getTurnRate(caster)
    -- self:log("英雄转身速率: " .. string.format("%.2f", turnRate))

    -- -- 计算转到与目标方向相差11.5°以内所需的时间
    -- local turnTime = 0
    -- if angleDifference > requiredAngle then
    --     turnTime = math.max(0, (0.03 * math.pi * (angleDifference - requiredAngle)) / (turnRate * 180))+0.1
    --     self:log("需要转身时间: " .. string.format("%.3f", turnTime) .. " 秒")
    -- else
    --     self:log("无需额外转身，已在所需角度范围内")
    -- end

    -- -- 确保adjustedCastPoint不小于originalCastPoint
    -- local adjustedCastPoint = math.max(originalCastPoint, originalCastPoint + turnTime) 
    -- self:log("原始施法前摇时间: " .. string.format("%.3f", originalCastPoint) .. " 秒")
    -- self:log("调整后的施法前摇时间: " .. string.format("%.3f", adjustedCastPoint) .. " 秒")

    -- --这段代码有问题，先注释掉
    -- return originalCastPoint
end

-- function CommonAI:calculateAdjustedCastPoint(caster, targetPosition, originalCastPoint)
--     local forwardVector = caster:GetForwardVector()
--     local casterPosition = caster:GetOrigin()
    
--     -- 检查 targetPosition 是否为 Vector 对象
--     local function isVector(v)
--         return type(v) == "userdata" or (type(v) == "table" and type(v.x) == "number" and type(v.y) == "number" and type(v.z) == "number")
--     end

--     -- 确保 targetPosition 是一个 Vector 对象
--     if not isVector(targetPosition) then
--         -- self:log(string.format("[STORM_TEST] 错误：targetPosition 不是有效的 Vector 对象。类型: %s, 值: %s", type(targetPosition), tostring(targetPosition)))
--         return originalCastPoint, 0
--     end

--     -- 确保我们使用的是 Vector 对象的 x, y, z 属性
--     local targetX, targetY, targetZ = targetPosition.x, targetPosition.y, targetPosition.z
--     local newDirection = Vector(targetX - casterPosition.x, targetY - casterPosition.y, targetZ - casterPosition.z):Normalized()
    
--     local dotProduct = forwardVector:Dot(newDirection)
--     local angleDifference = math.deg(math.acos(math.min(1, math.max(-1, dotProduct))))
--     local requiredAngle = 11.5
--     local turnRate = self:getTurnRate(caster)
    
--     local turnTime = 0
--     if angleDifference > requiredAngle then
--         turnTime = (angleDifference - requiredAngle) / (turnRate * 180) + 0.1
--     end
    
--     local adjustedCastPoint = math.max(originalCastPoint, turnTime)
    
--     self:log(string.format("[STORM_TEST] 英雄朝向: (%.2f, %.2f, %.2f)", forwardVector.x, forwardVector.y, forwardVector.z))
--     self:log(string.format("[STORM_TEST] 目标方向: (%.2f, %.2f, %.2f)", newDirection.x, newDirection.y, newDirection.z))
--     self:log(string.format("[STORM_TEST] 点积: %.4f", dotProduct))
--     self:log(string.format("[STORM_TEST] 角度差: %.2f 度", angleDifference))
--     self:log(string.format("[STORM_TEST] 预计转身时间: %.3f 秒", turnTime))
--     self:log(string.format("[STORM_TEST] 预计总施法前摇时间: %.3f 秒", adjustedCastPoint))
    
--     return adjustedCastPoint, turnTime
-- end

function CommonAI:calculateTurnTime(caster, targetPosition, castPosition)
    local forwardVector = caster:GetForwardVector()
    
    -- 确保 targetPosition 和 castPosition 是 Vector 对象
    local function ensureVector(v)
        if type(v) == "userdata" then
            return v
        elseif type(v) == "table" and type(v.x) == "number" and type(v.y) == "number" and type(v.z) == "number" then
            return Vector(v.x, v.y, v.z)
        else
            self:log(string.format("[STORM_TEST] 错误：无法转换为 Vector 对象。类型: %s, 值: %s", type(v), tostring(v)))
            return nil
        end
    end

    local vectorTarget = ensureVector(targetPosition)
    local vectorCast = ensureVector(castPosition)
    if not vectorTarget or not vectorCast then
        return 0
    end

    local newDirection = (vectorTarget - vectorCast):Normalized()
    local dotProduct = forwardVector:Dot(newDirection)
    local angleDifference = math.deg(math.acos(math.min(1, math.max(-1, dotProduct))))
    local requiredAngle = 11.5  -- Dota 2 中英雄开始施法所需的最小角度
    local turnRate = self:getTurnRate(caster)
    
    local turnTime = 0
    if angleDifference > requiredAngle then
        -- 使用新的公式计算转身时间
        turnTime = (math.rad(angleDifference - requiredAngle) * 0.03) / turnRate
    end
    
    -- 添加一个小的延迟来模拟服务器延迟和游戏引擎处理时间
    local serverDelay = 0.033
    turnTime = turnTime + serverDelay
    
    self:log(string.format("[STORM_TEST] 英雄朝向: (%.2f, %.2f, %.2f)", forwardVector.x, forwardVector.y, forwardVector.z))
    self:log(string.format("[STORM_TEST] 目标方向: (%.2f, %.2f, %.2f)", newDirection.x, newDirection.y, newDirection.z))
    self:log(string.format("[STORM_TEST] 点积: %.4f", dotProduct))
    self:log(string.format("[STORM_TEST] 角度差: %.2f 度", angleDifference))
    self:log(string.format("[STORM_TEST] 转身速率: %.4f", turnRate))
    self:log(string.format("[STORM_TEST] 预计转身时间: %.3f 秒", turnTime))
    
    return turnTime
end


function CommonAI:getTurnRate(caster)
    local turnRate = 0.7 -- 默认值
    local unitName = caster:GetUnitName()

    if caster:IsRealHero() then
        -- 从英雄 KV 表中查找
        local heroData = Main.heroListKV[unitName]
        if heroData and heroData.MovementTurnRate then
            turnRate = heroData.MovementTurnRate
        end
    else
        -- 从单位 KV 表中查找
        local unitData = Main.unitListKV[unitName]
        if unitData and unitData.MovementTurnRate then
            turnRate = unitData.MovementTurnRate
        end
    end
    self:log(string.format("[CommonAI] Turn rate for %s: %.2f (Source: %s)", unitName, turnRate, source))

    return turnRate
end



-- 辅助函数：检查表中是否包含特定元素
function CommonAI:tableContains(table, element)
    --允许检查表是不是空的
    if table == nil or table == {} then
        return false
    end
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end



function CommonAI:SetState(newState)
    self.currentState = newState
    self:log("状态更改: " .. newState)
end