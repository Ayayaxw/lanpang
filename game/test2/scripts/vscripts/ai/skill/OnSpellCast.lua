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

    -- 记录当前的施法位置
    local castPosition = self.lastTryCastPosition
    print("asdqwe记录施法的位置",self.lastTryCastPosition)
    
    if castPosition then
        self:log(string.format("记录施法位置: %.2f, %.2f, %.2f", 
            castPosition.x, castPosition.y, castPosition.z))
    else
        self:log("施法位置不存在")
    end

    self.pendingSpellCast = {
        hero = hero,
        skill = skill,
        castPoint = castPoint,
        channelTime = channelTime,
        target = target,
        castPosition = castPosition
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

        if not skill then
            self:log("技能对象为 nil，无法继续")
            self:SetState(AIStates.Idle)
            self.pendingSpellCast = nil
            return
        end

        local skillName = skill:GetAbilityName()
        self:log(string.format("检查施法: %s, channelTime: %.2f", skillName, channelTime))

        -- 检查是否在前摇状态或已经在持续施法状态
        if skill:IsInAbilityPhase() or hero:IsChanneling() then
            -- 获取当前正在施法的技能
            local currentCastingAbility = hero:GetCurrentActiveAbility()
            
            if currentCastingAbility and currentCastingAbility:GetAbilityName() == skillName then
                self:log("检测到施法开始")
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
            self.pendingSpellCast = nil  -- 清除待处理的施法请求

            if skillName ~= "storm_spirit_ball_lightning" and self.shouldStop then
                self:log(string.format("检测到 shouldStop 为 true，中断施法并设置为空闲状态: %s", skillName))
                self:SetState(AIStates.Idle)
                self.shouldStop = false
                return
            end

            if not self.shouldStop and self.needToDodge then
                self.needToDodge = false
            end

            local function checkAbilityPhase()
                if self.spellCastCounter ~= currentSpellCastId then return end

                if skillName ~= "storm_spirit_ball_lightning" and self.shouldStop then
                    self:log(string.format("检测到 shouldStop 为 true，中断施法并设置为空闲状态: %s", skillName))
                    self:SetState(AIStates.Idle)
                    self.shouldStop = false
                    return
                end

                if not self.shouldStop and self.needToDodge then
                    self.needToDodge = false
                end

                if not skill then
                    self:log("技能对象为 nil，无法继续")
                    self:SetState(AIStates.Idle)
                    return
                end

                if skill:IsInAbilityPhase() then
                    -- 还在前摇，继续检查
                    self:log(string.format("还在前摇中: %s", skillName))
                    Timers:CreateTimer(0.01, checkAbilityPhase)
                    return
                end

                -- 前摇结束，现在更新lastCastPosition
                if castPosition then
                    self.lastCastPosition = castPosition
                    print("asdqwe施法成功的位置", self.lastCastPosition)
                    self:log(string.format("前摇结束，更新 lastCastPosition 为: %.2f, %.2f, %.2f", 
                        castPosition.x, castPosition.y, castPosition.z))
                end

                if self.currentState ~= AIStates.CastSpell and self.currentState ~= AIStates.Channeling then
                    self:log(string.format("施法前摇被中断: %s", skillName))
                    self:SetState(AIStates.Idle)
                    return 
                end

                self:log(string.format("施法前摇结束: %s, channelTime: %.2f", skillName, channelTime))

                if channelTime > 0 then
                    if not hero:IsChanneling() then
                        self:log(string.format("持续施法被立即打断: %s", skillName))
                        self:SetState(AIStates.Idle)
                        return
                    end

                    self:SetState(AIStates.Channeling)
                    local function checkChanneling()
                        if self.spellCastCounter ~= currentSpellCastId then return end

                        if skillName ~= "storm_spirit_ball_lightning" and self.shouldStop then
                            self:log(string.format("检测到 shouldStop 为 true，中断施法并设置为空闲状态: %s", skillName))
                            self:SetState(AIStates.Idle)
                            self.shouldStop = false
                            return
                        end

                        if not self.shouldStop and self.needToDodge then
                            self.needToDodge = false
                        end

                        if hero:GetUnitName() == "npc_dota_hero_pugna" or 
                           hero:GetUnitName() == "npc_dota_hero_lich" or 
                           hero:GetUnitName() == "npc_dota_hero_riki" or 
                           
                           (skillName == "bane_fiends_grip" and hero:HasScepter()) then
                            self:log(string.format("特殊英雄持续施法，结束监听状态: %s", skillName))
                            self:SetState(AIStates.Idle)
                            return
                        end

                        if not hero:IsChanneling() then
                            self:log(string.format("持续施法被打断: %s", skillName))
                            self:SetState(AIStates.Idle)
                            return 
                        end

                        channelTime = channelTime - 0.1
                        self:log(string.format("持续施法中: %s, 剩余时间: %.2f", skillName, channelTime))
                        if channelTime > 0 then
                            Timers:CreateTimer(0.1, checkChanneling)
                        else
                            self:SetState(AIStates.PostCast)
                            self:log(string.format("持续施法结束，进入后摇状态: %s", skillName))
                        end
                    end
                    Timers:CreateTimer(0.1, checkChanneling)
                else
                    self:SetState(AIStates.PostCast)
                    self:log(string.format("施法结束，进入后摇状态: %s", skillName))
                end
            end

            -- 开始检查施法过程
            if hero:IsChanneling() then
                -- 如果已经在持续施法，直接检查持续施法状态
                checkAbilityPhase()
            else
                -- 否则等待施法前摇结束后再检查
                if skillName == "storm_spirit_ball_lightning" then
                    if hero:IsNull() or not hero:IsAlive() or not hero:HasModifier("modifier_storm_spirit_ball_lightning") then
                    end
                end
                Timers:CreateTimer(castPoint, checkAbilityPhase)
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
            end
        end
    end
end