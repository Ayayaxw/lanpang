function CommonAI:OnSpellCast(hero, skill, castPoint, channelTime, target)
    local waitTime = self.nextThinkTime
    
    if self.currentState == AIStates.CastSpell or self.currentState == AIStates.Channeling then
        self:log("已经在施法中，忽略新的施法请求")
        return waitTime
    end

    if not skill then
        self:log("技能对象为 nil，无法施法")
        return waitTime
    end

    self:log("发出施法指令: " .. skill:GetAbilityName())

    -- 不再依赖 lastTryCastPosition，施法位置将由全局监听器记录
    local castPosition = nil
    self:log("施法位置将由全局监听器自动记录")

    self.pendingSpellCast = {
        hero = hero,
        skill = skill,
        castPoint = castPoint,
        channelTime = channelTime,
        target = target,
        castPosition = castPosition,
        spellCastId = self.spellCastCounter,  -- 添加施法ID用于验证
        startTime = GameRules:GetGameTime()   -- 记录开始尝试施法的时间
    }

    return waitTime
end

function CommonAI:ProcessPendingSpellCast()
    if self.pendingSpellCast then
        local hero = self.pendingSpellCast.hero
        local skill = self.pendingSpellCast.skill
        local castPoint = self.pendingSpellCast.castPoint
        local channelTime = self.pendingSpellCast.channelTime
        local castPosition = self.pendingSpellCast.castPosition
        local currentSpellCastId = self.pendingSpellCast.spellCastId
        local startTime = self.pendingSpellCast.startTime
        local target = self.pendingSpellCast.target
        if not skill then
            self:log("技能对象为 nil，无法继续")
            self:SetState(AIStates.Idle)
            self.pendingSpellCast = nil
            return nil
        end

        local skillName = skill:GetAbilityName()
        local heroIndex = hero:GetEntityIndex()
        local currentTime = GameRules:GetGameTime()
        
        self:log(string.format("检查施法: %s, channelTime: %.2f", skillName, channelTime))

        -- 首先检查全局监听器是否已经记录了这次技能释放
        local hasExecuted, executedTime = self:CheckAbilityExecutedInGlobalListener(heroIndex, skillName, startTime)

        -- 检查是否在前摇状态或已经在持续施法状态
        if skill:IsInAbilityPhase() or hero:IsChanneling() then
            -- 获取当前正在施法的技能
            local currentCastingAbility = hero:GetCurrentActiveAbility()
            
            if currentCastingAbility and currentCastingAbility:GetAbilityName() == skillName then
                self:log("检测到施法开始")
                
                -- 记录前摇开始时间到技能记录系统
                if skill:IsInAbilityPhase() then
                    self:log(string.format("[前摇监听] 检测到技能前摇开始: %s", skillName))
                    
                    -- 直接在现有数据结构中记录前摇开始时间
                    local current_time = GameRules:GetGameTime()
                    local cast_point = skill:GetCastPoint()
                    
                    -- 确保数据结构存在
                    if not Main.heroLastCastAbility then
                        Main.heroLastCastAbility = {}
                    end
                    if not Main.heroLastCastAbility[heroIndex] then
                        Main.heroLastCastAbility[heroIndex] = {}
                    end
                    if not Main.heroLastCastAbility[heroIndex][skillName] then
                        Main.heroLastCastAbility[heroIndex][skillName] = {}
                    end
                    
                    -- 记录前摇开始时间和相关信息
                    Main.heroLastCastAbility[heroIndex][skillName].start_time = current_time
                    Main.heroLastCastAbility[heroIndex][skillName].cast_point = cast_point
                    Main.heroLastCastAbility[heroIndex][skillName].caster_name = hero:GetUnitName()
                    
                    self:log(string.format("[前摇监听] 已记录技能前摇开始时间: %s, 开始时间: %.3f, 前摇时长: %.3f", 
                        skillName, current_time, cast_point))
                end
            else
                self:log("当前施法的技能与记录的不匹配")
            end

            -- 进入施法状态或持续施法状态
            if hero:IsChanneling() then
                self:SetState(AIStates.Channeling)
                self:log(string.format("检测到持续施法，设置为持续施法状态: %s, channelTime: %.2f", skillName, channelTime))
            else
                self:SetState(AIStates.CastSpell)
                self:log(string.format("检测到前摇，设置为施法状态: %s, channelTime: %.2f", skillName, channelTime))
            end


        else
            -- 检查技能是否在冷却中，如果是，说明技能已经被释放但可能立即被打断
            if skill:GetCooldownTimeRemaining() > 0 then
                self:log(string.format("技能已释放但可能被立即打断，进入空闲状态: %s", skillName))
                self:SetState(AIStates.Idle)
                self.pendingSpellCast = nil
            elseif castPoint == 0 then
                self:SetState(AIStates.PostCast)
                self:log(string.format("0抬手技能，推测已经释放完毕。: %s", skillName))

                self.pendingSpellCast = nil
            else
                -- 未进入前摇，也不在持续施法，等待下一次 Think     
                self:log(string.format("未检测到前摇或持续施法，继续等待: %s, channelTime: %.2f", skillName, channelTime))

                self:SetState(AIStates.Idle)
                self.pendingSpellCast = nil

            end
        end

        if hasExecuted and not hero:IsChanneling() then
            self:log(string.format("全局监听器确认技能已释放完成: %s, 释放时间: %.3f", skillName, executedTime))            
            -- 清理待处理的施法请求
            self.pendingSpellCast = nil
            self:SetState(AIStates.Idle)
            -- 处理施法后移动的逻辑
            if target then
                self:log("施法后移动开始")
            end


            if target and not self:containsStrategy(self.global_strategy, "禁用施法后移动行为") then
                if not hero:IsFeared() and not hero:IsTaunted() then
                    if hero:GetUnitName() == "npc_dota_hero_templar_assassin" or hero:GetUnitName() == "npc_dota_hero_life_stealer" or hero:GetUnitName() == "npc_dota_hero_riki" then
                        
                        local order = {
                            UnitIndex = hero:entindex(),
                            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                            TargetIndex = target:entindex(),
                            Position = target:GetAbsOrigin()
                        }
                        ExecuteOrderFromTable(order)
            
                        self:SetState(AIStates.Attack)
                        self:log("近战英雄施法后继续追击")
                    elseif hero:GetUnitName() == "npc_dota_hero_leshrac" then
                        hero:MoveToPosition(target:GetOrigin())
                        self:SetState(AIStates.Idle)
                        self:log("拉席克，没事走走")
                        
                        -- 计算拉席克和目标之间的距离
                        local distance = (hero:GetOrigin() - target:GetOrigin()):Length2D()
                        
                        -- 如果距离大于300，才返回0.1
                        if distance > 300 then
                            return 0.1
                        end
                    elseif hero:GetUnitName() == "npc_dota_hero_storm_spirit" and self:containsStrategy(self.hero_strategy, "折叠飞") and skillName == "storm_spirit_ball_lightning" then
                        -- 风暴之灵折叠飞策略处理
                        self:log("风暴之灵折叠飞策略，执行施法后移动")
                        
                        -- 获取施法时的位置（从全局记录中获取）
                        local castPosition = hero:GetAbsOrigin()
                        local targetPosition = nil
                        
                        -- 尝试从施法记录中获取目标位置
                        if Main.heroLastCastAbility and Main.heroLastCastAbility[hero:GetEntityIndex()] and 
                           Main.heroLastCastAbility[hero:GetEntityIndex()]["storm_spirit_ball_lightning"] then
                            targetPosition = Main.heroLastCastAbility[hero:GetEntityIndex()]["storm_spirit_ball_lightning"].cursor_position
                        end
                        
                        if targetPosition then
                            -- 计算从当前位置朝向施法目标位置的方向
                            local direction = (targetPosition - castPosition):Normalized()
                            -- 计算前进100码的目标位置
                            local movePosition = castPosition - direction * 100
                            
                            self:log(string.format("风暴之灵当前位置: (%.2f, %.2f, %.2f)", castPosition.x, castPosition.y, castPosition.z))
                            self:log(string.format("风暴之灵施法目标位置: (%.2f, %.2f, %.2f)", targetPosition.x, targetPosition.y, targetPosition.z))
                            self:log(string.format("风暴之灵移动目标位置: (%.2f, %.2f, %.2f)", movePosition.x, movePosition.y, movePosition.z))
                            
                            local targetPos = hero:GetAbsOrigin() - hero:GetForwardVector() * 100
                            self:log("风暴之灵发出转身指令")
                            hero:CastAbilityOnPosition(movePosition,hero:FindAbilityByName("storm_spirit_ball_lightning"),-1)
                            Timers:CreateTimer(0.15, function()
                                hero:Stop()
                            end)
                            self:SetState(AIStates.Idle)
            
                            return 0.15 
            
            
                        else
                            self:log("无法获取风暴之灵施法目标位置，跳过移动指令")
                        end
                    else
                        --entity:MoveToPosition(target:GetOrigin())
                        self:SetState(AIStates.Idle)
                        self:log("其他英雄移动到目标位置")
                    end
            
                    if skillName == "leshrac_split_earth" or skillName == "oracle_fortunes_end" or skillName == "void_spirit_aether_remnant" or (skillName == "slark_pounce" and self:containsStrategy(self.hero_strategy, "跳慢点") )then
                        self:log("朝向敌人移动")
                        hero:MoveToPosition(target:GetOrigin())
                        self:SetState(AIStates.Idle)
                        return 0.01
                    end
                end
            end
            self:log("施法后移动结束")





            return nil
        end



    end
end

-- 检查全局监听器是否已经记录了技能释放
function CommonAI:CheckAbilityExecutedInGlobalListener(heroIndex, skillName, startTime)
    if not Main.heroLastCastAbility or 
       not Main.heroLastCastAbility[heroIndex] or 
       not Main.heroLastCastAbility[heroIndex][skillName] then
        return false, nil
    end
    
    local abilityRecord = Main.heroLastCastAbility[heroIndex][skillName]
    
    -- 检查是否有释放时间记录，且释放时间在我们开始尝试施法之后
    if abilityRecord.time and abilityRecord.time >= startTime then
        return true, abilityRecord.time
    end
    
    return false, nil
end

-- 从全局记录表中获取指定技能的最后施法位置
function CommonAI:GetLastCastPositionFromGlobal(entity, skillName)
    if not Main.heroLastCastAbility then
        return nil
    end
    
    local heroIndex = entity:GetEntityIndex()
    if not Main.heroLastCastAbility[heroIndex] or 
       not Main.heroLastCastAbility[heroIndex][skillName] then
        return nil
    end
    
    local abilityRecord = Main.heroLastCastAbility[heroIndex][skillName]
    
    -- 返回施法目标位置，如果没有则返回施法者位置
    if abilityRecord.cursor_position then
        return abilityRecord.cursor_position
    elseif abilityRecord.caster_position then
        return abilityRecord.caster_position
    end
    
    return nil
end