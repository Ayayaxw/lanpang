function CommonAI:ShouldDodgeSkill(entity)
    print("[AI_DEBUG] ShouldDodgeSkill 函数开始执行")
    
    if not entity or not entity:IsAlive() then
        print("[AI_DEBUG] 实体无效或已死亡，函数在此结束，返回 false")
        return false
    end
    
    print("[AI_DEBUG] 实体有效且存活: " .. entity:GetUnitName())
    
    -- 检查是否有敌方英雄最近开始施法
    if not Main.heroLastCastAbility then
        print("[AI_DEBUG] Main.heroLastCastAbility 不存在，函数在此结束，返回 false")
        return false
    end
    
    print("[AI_DEBUG] Main.heroLastCastAbility 存在，继续检查")
    
    -- 需要躲避的技能表
    local dodgeableSkills = {
        "pudge_meat_hook",
        "muerta_dead_shot",
        "rattletrap_hookshot",
        "rattletrap_rocket_flare",
    }
    
    local current_time = GameRules:GetGameTime()
    local entity_team = entity:GetTeamNumber()
    
    print(string.format("[AI_DEBUG] 当前时间: %.3f, 实体队伍: %d", current_time, entity_team))
    print("[AI_DEBUG] 开始遍历所有英雄的技能记录")
    
    local heroCount = 0
    -- 遍历所有英雄的技能记录，查找敌方的需要躲避的技能
    for heroIndex, heroAbilities in pairs(Main.heroLastCastAbility) do
        heroCount = heroCount + 1
        print(string.format("[AI_DEBUG] 检查英雄 %d 的技能记录", heroIndex))
        
        -- 遍历需要躲避的技能表
        for skillIndex, skillName in ipairs(dodgeableSkills) do
            print(string.format("[AI_DEBUG] 检查技能: %s (第%d个躲避技能)", skillName, skillIndex))
            
            if heroAbilities[skillName] then
                print(string.format("[AI_DEBUG] 找到技能记录: %s", skillName))
                local skill_record = heroAbilities[skillName]
                
                -- 检查是否有前摇开始时间记录，如果没有则使用普通时间记录
                local skill_time = skill_record.start_time or skill_record.time
                if skill_time then
                    if skill_record.start_time then
                        print(string.format("[AI_DEBUG] 技能有前摇开始时间记录: %.3f", skill_record.start_time))
                    else
                        print(string.format("[AI_DEBUG] 技能没有前摇开始时间，使用普通时间记录: %.3f", skill_record.time))
                    end
                    local time_since_start = current_time - skill_time
                    print(string.format("[AI_DEBUG] 距离技能开始时间已过: %.3f 秒", time_since_start))
                    
                    -- 检查是否在5秒内且是敌方英雄
                    if time_since_start <= 1.0 then
                        print("[AI_DEBUG] 技能在5秒内，检查施法者队伍")
                        -- 获取施法者实体来检查队伍
                        local caster = EntIndexToHScript(heroIndex)
                        if caster and caster:IsAlive() and caster:GetTeamNumber() ~= entity_team then
                            print(string.format("[AI_DEBUG] 施法者是敌方英雄: %s (队伍: %d)", caster:GetUnitName(), caster:GetTeamNumber()))
                            -- 获取当前可用的躲避技能
                            local availableEvasionSkills = self:GetAvailableEvasionSkills(entity)
                            local heroName = entity:GetUnitName()
                            
                            print(string.format("[AI_DEBUG] 获取到 %d 个可用躲避技能", #availableEvasionSkills))
                            
                            if #availableEvasionSkills > 0 then
                                local evasionSkillName = availableEvasionSkills[1] -- 取第一个可用技能
                                print(string.format("[AI_DEBUG] 使用躲避技能: %s", evasionSkillName))
                                local dodgeSkill = entity:FindAbilityByName(evasionSkillName)
                                
                                if dodgeSkill then
                                    print("[AI_DEBUG] 找到躲避技能实体，开始计算时机")
                                    -- 计算精确的躲避时机
                                    local skill_cast_point = skill_record.cast_point or 0.3 -- 默认前摇时间
                                    local dodge_cast_point = dodgeSkill:GetCastPoint()
                                    
                                    local optimal_dodge_start_time
                                    if skill_record.start_time then
                                        -- 如果有前摇开始时间，使用精确计算
                                        optimal_dodge_start_time = skill_record.start_time + skill_cast_point + 0.03 - dodge_cast_point
                                        print(string.format("[AI] %s前摇开始时间: %.3f, 前摇: %.3f, 躲避技能前摇: %.3f", 
                                            skillName, skill_record.start_time, skill_cast_point, dodge_cast_point))
                                    else
                                        -- 如果只有普通时间，认为技能已经释放完成，立即躲避
                                        optimal_dodge_start_time = skill_record.time + 0.03 - dodge_cast_point
                                        print(string.format("[AI] %s释放完成时间: %.3f, 躲避技能前摇: %.3f", 
                                            skillName, skill_record.time, dodge_cast_point))
                                    end
                                    
                                    local time_until_optimal = optimal_dodge_start_time - current_time
                                    
                                    print(string.format("[AI] 最佳躲避开始时间: %.3f, 当前时间: %.3f, 还需等待: %.3f秒", 
                                        optimal_dodge_start_time, current_time, time_until_optimal))
                                    
                                    -- 如果已经到了最佳躲避时机（允许0.01秒的误差）
                                    if time_until_optimal <= 0.01 then
                                        print("[AI] 检测到" .. skillName .. "开始施法，到达最佳躲避时机，且拥有可用的躲避技能: " .. evasionSkillName .. "，应该躲避")
                                        print("[AI_DEBUG] 函数在此结束，返回 true (应该躲避)")
                                        -- 设置躲避标志位
                                        self.shouldUseDodgeSkills = true
                                        self.currentAvailableDodgeSkills = availableEvasionSkills
                                        return true
                                    else
                                        print(string.format("[AI] 检测到%s开始施法，但还需等待 %.3f 秒才到最佳躲避时机", skillName, time_until_optimal))
                                        print("[AI_DEBUG] 时机未到，继续检查其他技能")
                                    end
                                else
                                    print("[AI_DEBUG] 未找到躲避技能实体，继续检查其他技能")
                                end
                            else
                                print("[AI] 检测到" .. skillName .. "开始施法但该英雄没有可用的躲避技能: " .. heroName)
                                print("[AI_DEBUG] 没有可用躲避技能，继续检查其他技能")
                            end
                        else
                            if not caster then
                                print("[AI_DEBUG] 施法者实体无效，继续检查其他技能")
                            elseif not caster:IsAlive() then
                                print("[AI_DEBUG] 施法者已死亡，继续检查其他技能")
                            else
                                print(string.format("[AI_DEBUG] 施法者是友方英雄 (队伍: %d)，继续检查其他技能", caster:GetTeamNumber()))
                            end
                        end
                    else
                        print(string.format("[AI_DEBUG] 技能超过5秒时限 (%.3f秒)，继续检查其他技能", time_since_start))
                    end
                else
                    print("[AI_DEBUG] 技能既没有前摇开始时间记录也没有普通时间记录，继续检查其他技能")
                end
            else
                print(string.format("[AI_DEBUG] 英雄没有 %s 技能记录", skillName))
            end
        end
        print(string.format("[AI_DEBUG] 英雄 %d 的所有躲避技能检查完毕", heroIndex))
    end
    
    print(string.format("[AI_DEBUG] 所有英雄检查完毕，共检查了 %d 个英雄", heroCount))
    print("[AI_DEBUG] 函数在此结束，返回 false (不需要躲避)")
    return false
end
