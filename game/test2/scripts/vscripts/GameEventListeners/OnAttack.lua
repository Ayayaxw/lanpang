function Main:OnAttack(keys)
    local attacker = EntIndexToHScript(keys.entindex_attacker)
    local victim = EntIndexToHScript(keys.entindex_killed)
    local damage = keys.damage
    local ability = nil
    if keys.entindex_inflictor then
        ability = EntIndexToHScript(keys.entindex_inflictor)
    end

    local attacker = keys.entindex_attacker and EntIndexToHScript(keys.entindex_attacker)
    local target = keys.entindex_killed and EntIndexToHScript(keys.entindex_killed)
    local inflictor = keys.entindex_inflictor and EntIndexToHScript(keys.entindex_inflictor)
    
    -- 如果攻击者或目标为空，则返回
    if not attacker or not target then
        return
    end

    local damage = keys.damage

    -- 记录所有单位的攻击信息
    local attackerName = attacker:GetUnitName()
    local targetName = target:GetUnitName()
    local damageRounded = string.format("%.2f", damage or 0)

    -- 追踪技能伤害
    if hero_duel.damagePanelEnabled and inflictor then
        -- 获取技能名称
        local abilityName = inflictor:GetName()
        
        -- 确定攻击者的属性
        local attribute = "All"
        if attacker:IsHero() then
            local heroData = Main.heroListKV[attackerName]
            if heroData then
                local attributePrimary = heroData["AttributePrimary"]
                local attributeType = GetHeroTypeFromAttribute(attributePrimary)
                
                if attributeType == 1 then
                    attribute = "Strength"
                elseif attributeType == 2 then
                    attribute = "Agility"
                elseif attributeType == 4 then
                    attribute = "Intelligence"
                elseif attributeType == 8 then
                    attribute = "All"
                end
            end
        end
        
        -- 为这个技能+攻击者组合创建唯一键
        local abilityKey = abilityName .. "_" .. attacker:GetEntityIndex()
        
        -- 获取当前时间
        local currentTime = GameRules:GetGameTime()
        
        -- 如果这个技能已经在追踪中
        if hero_duel.abilityDamageTracker[abilityKey] then
            -- 更新技能信息
            local abilityInfo = hero_duel.abilityDamageTracker[abilityKey]
            local previousDamage = abilityInfo.damage
            abilityInfo.damage = abilityInfo.damage + damage
            abilityInfo.lastDamageTime = currentTime
        else
            -- 为这个技能创建新条目
            hero_duel.abilityDamageTracker[abilityKey] = {
                abilityName = abilityName,
                attackerName = attacker:GetUnitName(),
                attribute = attribute,
                damage = damage,
                lastDamageTime = currentTime
            }
        end
    end

    -- 处理特定英雄之间的交互
    if self.leftTeamHero1 and self.rightTeamHero1 then
        local attacker = keys.entindex_attacker and EntIndexToHScript(keys.entindex_attacker)
        local target = keys.entindex_killed and EntIndexToHScript(keys.entindex_killed)
        local inflictor = keys.entindex_inflictor and EntIndexToHScript(keys.entindex_inflictor)
        -- 如果attacker或target为nil，则直接返回
        if not attacker or not target then
            return
        end
    
        local damage = keys.damage
    
        if (attacker == self.leftTeamHero1 and target == self.rightTeamHero1) or
           (attacker == self.rightTeamHero1 and target == self.leftTeamHero1) then
            
            local attackerName = attacker:GetUnitName()
            local targetName = target:GetUnitName()
            local damageRounded = string.format("%.2f", damage or 0)
            local eventData = {
                attacker = attackerName,
                target = targetName,
                damage = damageRounded,
            }
    
            -- 根据Inflictor判断攻击类型和来源
            if inflictor then
                eventData.attackType = "ability_attack"
                eventData.abilityName = inflictor:GetName()
            else
                eventData.attackType = "normal_attack"
                eventData.abilityName = nil
            end

            if attacker == self.leftTeamHero1 then
                CustomGameEventManager:Send_ServerToAllClients("left_hero_attack_info", eventData)
            else
                CustomGameEventManager:Send_ServerToAllClients("right_hero_attack_info", eventData)
            end
        end
    end

    local attacker = EntIndexToHScript(keys.entindex_attacker)
    if attacker and attacker:GetUnitName() == self.currentHeroName then
        local ability = attacker:GetCurrentActiveAbility()
        if ability then
            local message = PrintManager:FormatAbilityMessage(attacker, ability)
            PrintManager:PrintMessage(message)
        end
    end

    local challengeId = self.currentChallenge

    -- 查找对应的挑战模式名称
    local challengeName
    for name, id in pairs(Main.Challenges) do
        if id == challengeId then
            challengeName = name
            break
        end
    end

    if challengeName then
        -- 构建处理函数的名称
        local challengeFunctionName = "OnAttack_" .. challengeName
        if self[challengeFunctionName] then
            -- 调用对应的处理函数
            self[challengeFunctionName](self, keys)
        end
    end
end

-- 检查过期技能的函数
function Main:CheckExpiredAbilities()
    if not hero_duel.damagePanelEnabled then 
        return 
    end
    
    local currentTime = GameRules:GetGameTime()
    local keysToRemove = {}
    
    -- 检查每个技能
    local count = 0
    for key, abilityInfo in pairs(hero_duel.abilityDamageTracker) do
        count = count + 1
        -- 如果距离上次伤害超过5秒
        local timeSinceLastDamage = currentTime - abilityInfo.lastDamageTime
        if timeSinceLastDamage > 5 then
            table.insert(keysToRemove, key)
        end
    end
    
    -- 移除过期技能
    for _, key in ipairs(keysToRemove) do
        hero_duel.abilityDamageTracker[key] = nil
    end
end

-- 查找最高伤害技能的函数
function Main:FindHighestDamagingAbility()
    if not hero_duel.damagePanelEnabled then 
        return nil 
    end
    
    local highestDamage = 1000 -- 最低阈值
    local highestAbility = nil
    
    for key, abilityInfo in pairs(hero_duel.abilityDamageTracker) do
        if abilityInfo.damage > highestDamage then
            highestDamage = abilityInfo.damage
            highestAbility = abilityInfo
        end
    end
    
    return highestAbility
end


function Main:UpdateDamagePanel()
    if not hero_duel.damagePanelEnabled then 
        print("[伤害面板] 面板已禁用，跳过更新")
        return 
    end
    
    -- 检查过期技能
    --print("[伤害面板] 开始检查过期技能...")
    self:CheckExpiredAbilities()
    
    -- 查找最高伤害技能
    --print("[伤害面板] 开始查找最高伤害技能...")
    local highestAbility = self:FindHighestDamagingAbility()
    
    -- 如果没有技能造成超过1000点伤害，不做任何操作
    if not highestAbility then
        --print("[伤害面板] 未找到超过1000点伤害的技能，跳过更新")
        return
    end
    
    -- print(string.format("[伤害面板] 找到最高伤害技能: %s, 伤害值: %.2f", 
    --     highestAbility.abilityName, 
    --     highestAbility.damage
    -- ))
    
    -- 如果最高伤害技能发生变化，发送完整更新
    if not hero_duel.currentHighestAbility or hero_duel.currentHighestAbility.abilityName ~= highestAbility.abilityName then
        print(string.format("[伤害面板] 最高伤害技能发生变化，发送完整更新数据 - 技能: %s, 属性: %s, 伤害: %.2f",
            highestAbility.abilityName,
            highestAbility.attribute,
            highestAbility.damage
        ))
        
        local eventData = {
            ability_name = highestAbility.abilityName,
            attribute = highestAbility.attribute,
            initial_damage = math.floor(highestAbility.damage)
        }
        
        CustomGameEventManager:Send_ServerToAllClients("damage_panel_update_initial", eventData)
        hero_duel.currentHighestAbility = table.deepcopy(highestAbility)
    -- 如果是同一个技能但伤害发生变化
    elseif hero_duel.currentHighestAbility.damage ~= highestAbility.damage then
        print(string.format("[伤害面板] 技能伤害发生变化 - 技能: %s, 旧伤害: %.2f, 新伤害: %.2f",
            highestAbility.abilityName,
            hero_duel.currentHighestAbility.damage,
            highestAbility.damage
        ))
        
        local eventData = {
            damage = math.floor(highestAbility.damage)
        }
        
        CustomGameEventManager:Send_ServerToAllClients("damage_panel_update_damage", eventData)
        hero_duel.currentHighestAbility.damage = highestAbility.damage
    end
end

function Main:StartDamagePanelTimer()
    print("[伤害面板] 启动伤害面板更新定时器")
    Timers:CreateTimer(function()
        if hero_duel.damagePanelEnabled then
            self:UpdateDamagePanel()
            return 1 -- 1秒后再次运行
        else
            print("[伤害面板] 面板已禁用，停止定时器")
            return nil -- 如果功能被禁用则停止定时器
        end
    end)
end

-- 启用/禁用伤害面板的函数
function Main:SetDamagePanelEnabled(enabled)
    hero_duel.damagePanelEnabled = enabled
    
    if enabled and not hero_duel.damagePanelTimerStarted then
        self:StartDamagePanelTimer()
        hero_duel.damagePanelTimerStarted = true
    end
end