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

    -- 初始化伤害消息队列
    if not Main.damageMessageQueue then
        Main.damageMessageQueue = {}
        Main.lastDamageBroadcastTime = 0
    end
    
    -- 同时维护两种合并规则的队列
    if not Main.attackerAbilityQueue then
        Main.attackerAbilityQueue = {}  -- 攻击者+技能为键 (原规则)
    end
    
    if not Main.abilityTargetQueue then
        Main.abilityTargetQueue = {}  -- 技能+目标为键 (新规则)
    end

    -- 初始化实体类型计数表
    if not Main.entityCounters then
        Main.entityCounters = {}
    end
    
    -- 构建伤害事件的唯一键：攻击者ID + 技能名称(如果有)
    local abilityName = "普通攻击"
    local abilityLocalized = "普通攻击"
    
    if inflictor then
        abilityName = inflictor:GetName()
        abilityLocalized = {localize = true, text = "DOTA_Tooltip_Ability_" .. abilityName}
    end
    
    -- 获取当前的秒数时间戳 - 用于创建每一秒的新计数表
    local timestamp = math.floor(GameRules:GetGameTime())
    local timestampKey = tostring(timestamp)
    
    -- 确保存在当前时间戳的计数表
    if not Main.entityCounters[timestampKey] then
        Main.entityCounters[timestampKey] = {
            attackers = {},
            targets = {}
        }
        
        -- 如果是新的一秒，清理旧的计数表（保留最近30秒的数据）
        local timeToKeep = 30
        for oldTimestamp, _ in pairs(Main.entityCounters) do
            if tonumber(oldTimestamp) < timestamp - timeToKeep then
                Main.entityCounters[oldTimestamp] = nil
            end
        end
    end
    
    -- 记录本次攻击的攻击者和目标
    local attackerKey = attackerName .. "_" .. attacker:GetEntityIndex()
    local targetKey = targetName .. "_" .. target:GetEntityIndex()
    
    Main.entityCounters[timestampKey].attackers[attackerKey] = {
        name = attackerName,
        entityId = attacker:GetEntityIndex()
    }
    
    Main.entityCounters[timestampKey].targets[targetKey] = {
        name = targetName,
        entityId = target:GetEntityIndex()
    }
    
    -- 原规则的键：攻击者类型 + 技能
    local attackerAbilityKey = attackerName .. "_" .. abilityName
    
    -- 新规则的键：技能 + 目标类型
    local abilityTargetKey = abilityName .. "_" .. targetName
    
    -- 1. 更新原规则队列 (攻击者+技能 -> 目标)
    if not Main.attackerAbilityQueue[attackerAbilityKey] then
        Main.attackerAbilityQueue[attackerAbilityKey] = {
            attackerName = {localize = true, text = attackerName},
            abilityName = abilityLocalized,
            targets = {},
            totalDamage = 0
        }
    end
    
    -- 更新目标和伤害信息
    if not Main.attackerAbilityQueue[attackerAbilityKey].targets[targetName] then
        Main.attackerAbilityQueue[attackerAbilityKey].targets[targetName] = {
            count = 1,
            name = {localize = true, text = targetName},
            damage = damage
        }
    else
        Main.attackerAbilityQueue[attackerAbilityKey].targets[targetName].count = Main.attackerAbilityQueue[attackerAbilityKey].targets[targetName].count + 1
        Main.attackerAbilityQueue[attackerAbilityKey].targets[targetName].damage = Main.attackerAbilityQueue[attackerAbilityKey].targets[targetName].damage + damage
    end
    
    -- 更新总伤害
    Main.attackerAbilityQueue[attackerAbilityKey].totalDamage = Main.attackerAbilityQueue[attackerAbilityKey].totalDamage + damage
    
    -- 2. 更新新规则队列 (技能+目标 -> 攻击者)
    if not Main.abilityTargetQueue[abilityTargetKey] then
        Main.abilityTargetQueue[abilityTargetKey] = {
            abilityName = abilityLocalized,
            targetName = {localize = true, text = targetName},
            attackers = {},
            totalDamage = 0,
            targetIsHero = target:IsHero(),
            targetStartHealth = target:GetHealth(),
            targetCurrentHealth = target:GetHealth()
        }
    end
    
    -- 更新攻击者和伤害信息
    if not Main.abilityTargetQueue[abilityTargetKey].attackers[attackerName] then
        Main.abilityTargetQueue[abilityTargetKey].attackers[attackerName] = {
            count = 1,
            name = {localize = true, text = attackerName},
            damage = damage
        }
    else
        Main.abilityTargetQueue[abilityTargetKey].attackers[attackerName].count = Main.abilityTargetQueue[abilityTargetKey].attackers[attackerName].count + 1
        Main.abilityTargetQueue[abilityTargetKey].attackers[attackerName].damage = Main.abilityTargetQueue[abilityTargetKey].attackers[attackerName].damage + damage
    end
    
    -- 更新总伤害和目标当前血量
    Main.abilityTargetQueue[abilityTargetKey].totalDamage = Main.abilityTargetQueue[abilityTargetKey].totalDamage + damage
    Main.abilityTargetQueue[abilityTargetKey].targetCurrentHealth = target:GetHealth()
    
    -- 检查是否需要广播伤害消息（每秒一次）
    local currentTime = GameRules:GetGameTime()
    if currentTime - Main.lastDamageBroadcastTime >= 1.0 then
        self:BroadcastDamageMessages()
        Main.lastDamageBroadcastTime = currentTime
    end

    -- 追踪技能伤害
    if hero_duel.damagePanelEnabled and inflictor then
        -- 获取技能名称
        local abilityName = inflictor:GetName()
        
        -- 获取真正的攻击者（主人）
        local realAttacker = attacker:GetRealOwner()
        
        -- 如果没有主人，则不记录伤害
        if not realAttacker then
            return
        end
        
        -- 确定攻击者的属性
        local attribute = "All"
        if realAttacker:IsHero() then
            local heroData = Main.heroListKV[realAttacker:GetUnitName()]
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
        local abilityKey = abilityName .. "_" .. realAttacker:GetEntityIndex()
        
        -- 获取当前时间
        local currentTime = GameRules:GetGameTime()
        
        -- 如果这个技能已经在追踪中
        if hero_duel.abilityDamageTracker[abilityKey] then
            -- 更新技能信息
            local abilityInfo = hero_duel.abilityDamageTracker[abilityKey]
            local previousDamage = abilityInfo.damage
            abilityInfo.damage = abilityInfo.damage + damage
            abilityInfo.lastDamageTime = currentTime
            
            -- 检查是否产生了新的最高伤害，满足间隔条件时立即更新
            self:CheckAndUpdateDamagePanel()
        else
            -- 为这个技能创建新条目
            hero_duel.abilityDamageTracker[abilityKey] = {
                abilityName = abilityName,
                attackerName = realAttacker:GetUnitName(),
                attribute = attribute,
                damage = damage,
                lastDamageTime = currentTime
            }
            
            -- 检查是否产生了新的最高伤害，满足间隔条件时立即更新
            self:CheckAndUpdateDamagePanel()
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

    -- local attacker = EntIndexToHScript(keys.entindex_attacker)
    -- if attacker then
    --     local ability = attacker:GetCurrentActiveAbility()
    --     if ability then
    --         local message = PrintManager:FormatAbilityMessage(attacker, ability)
    --         PrintManager:PrintMessage(message)
    --     end
    -- end

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

-- 新增函数：广播队列中的所有伤害消息
function Main:BroadcastDamageMessages()
    if not Main.currentMatchID then return end
    
    -- 创建消息合并表
    local combinedMessages = {}
    
    -- 获取当前的时间戳
    local currentTimestamp = math.floor(GameRules:GetGameTime())
    local timestampKey = tostring(currentTimestamp)
    
    -- 计算当前秒内不重复的攻击者和目标数量
    local uniqueAttackerCounts = {}
    local uniqueTargetCounts = {}
    
    -- 只处理当前秒的数据
    if Main.entityCounters[timestampKey] then
        -- 先创建用于存储不重复ID的表
        local uniqueAttackerIds = {}
        local uniqueTargetIds = {}
        
        for attackerKey, attackerInfo in pairs(Main.entityCounters[timestampKey].attackers) do
            local attackerName = attackerInfo.name
            local attackerId = attackerInfo.entityId
            
            -- 为每种攻击者类型初始化ID集合
            if not uniqueAttackerIds[attackerName] then
                uniqueAttackerIds[attackerName] = {}
            end
            
            -- 记录ID
            uniqueAttackerIds[attackerName][attackerId] = true
        end
        
        for targetKey, targetInfo in pairs(Main.entityCounters[timestampKey].targets) do
            local targetName = targetInfo.name
            local targetId = targetInfo.entityId
            
            -- 为每种目标类型初始化ID集合
            if not uniqueTargetIds[targetName] then
                uniqueTargetIds[targetName] = {}
            end
            
            -- 记录ID
            uniqueTargetIds[targetName][targetId] = true
        end
        
        -- 然后计算每种类型的不重复ID数量
        for attackerName, ids in pairs(uniqueAttackerIds) do
            local count = 0
            for _ in pairs(ids) do
                count = count + 1
            end
            uniqueAttackerCounts[attackerName] = count
        end
        
        for targetName, ids in pairs(uniqueTargetIds) do
            local count = 0
            for _ in pairs(ids) do
                count = count + 1
            end
            uniqueTargetCounts[targetName] = count
        end
        
        -- 调试输出
        for name, count in pairs(uniqueAttackerCounts) do
            print("[伤害统计] 攻击者: " .. name .. ", 不重复数量: " .. count)
        end
        
        for name, count in pairs(uniqueTargetCounts) do
            print("[伤害统计] 目标: " .. name .. ", 不重复数量: " .. count)
        end
    end
    
    -- 1. 先处理原规则的消息：攻击者+技能 -> 多目标
    if Main.attackerAbilityQueue then
        for attackerAbilityKey, attackData in pairs(Main.attackerAbilityQueue) do
            -- 获取攻击者名称
            local attackerNameText = ""
            if type(attackData.attackerName) == "table" and attackData.attackerName.text then
                attackerNameText = attackData.attackerName.text
            else
                attackerNameText = tostring(attackData.attackerName)
            end
            
            -- 遍历每种目标类型
            for targetName, targetData in pairs(attackData.targets) do
                local messageKey = attackerNameText .. "_" .. 
                                  (type(attackData.abilityName) == "table" and attackData.abilityName.text or attackData.abilityName) .. "_" .. 
                                  (type(targetData.name) == "table" and targetData.name.text or targetName)
                
                -- 检查是否已存在相同类型的消息
                if not combinedMessages[messageKey] then
                    -- 计算目标的不重复数量
                    local uniqueTargetCount = uniqueTargetCounts[targetName] or 1
                    
                    combinedMessages[messageKey] = {
                        attackerName = attackData.attackerName,
                        abilityName = attackData.abilityName,
                        targetName = targetData.name,
                        count = targetData.count,
                        uniqueCount = uniqueTargetCount,
                        damage = targetData.damage,
                        targetIsHero = false, -- 原规则不支持此特性
                        messageType = "original"
                    }
                else
                    -- 合并相同类型的消息
                    combinedMessages[messageKey].count = combinedMessages[messageKey].count + targetData.count
                    combinedMessages[messageKey].damage = combinedMessages[messageKey].damage + targetData.damage
                end
            end
        end
        
        -- 清空原规则队列
        Main.attackerAbilityQueue = {}
    end
    
    -- 2. 再处理新规则的消息：技能+目标 -> 多攻击者
    if Main.abilityTargetQueue then
        for abilityTargetKey, attackData in pairs(Main.abilityTargetQueue) do
            -- 获取目标名称
            local targetNameText = ""
            if type(attackData.targetName) == "table" and attackData.targetName.text then
                targetNameText = attackData.targetName.text
            else
                targetNameText = tostring(attackData.targetName)
            end
            
            -- 遍历每种攻击者类型
            for attackerName, attackerData in pairs(attackData.attackers) do
                local messageKey = attackerName .. "_" .. 
                                  (type(attackData.abilityName) == "table" and attackData.abilityName.text or attackData.abilityName) .. "_" .. 
                                  targetNameText
                
                -- 检查是否已存在相同类型的消息（攻击者+技能+目标）
                if not combinedMessages[messageKey] then
                    -- 计算攻击者的不重复数量
                    local uniqueAttackerCount = uniqueAttackerCounts[attackerName] or 1
                    
                    -- 创建新的消息对象
                    combinedMessages[messageKey] = {
                        attackerName = attackerData.name,
                        abilityName = attackData.abilityName,
                        targetName = attackData.targetName,
                        count = attackerData.count,
                        uniqueCount = uniqueAttackerCount,
                        damage = attackerData.damage,
                        targetIsHero = attackData.targetIsHero,
                        targetStartHealth = attackData.targetStartHealth,
                        targetCurrentHealth = attackData.targetCurrentHealth,
                        messageType = "new"
                    }
                else
                    -- 合并相同类型的消息
                    local existingMsg = combinedMessages[messageKey]
                    existingMsg.count = existingMsg.count + attackerData.count
                    existingMsg.damage = existingMsg.damage + attackerData.damage
                    
                    -- 如果已有消息不包含血量信息但当前消息有，则添加
                    if attackData.targetIsHero and not existingMsg.targetIsHero then
                        existingMsg.targetIsHero = true
                        existingMsg.targetStartHealth = attackData.targetStartHealth
                        existingMsg.targetCurrentHealth = attackData.targetCurrentHealth
                    end
                end
            end
        end
        
        -- 清空新规则队列
        Main.abilityTargetQueue = {}
    end
    
    -- 3. 发送所有合并后的消息
    for _, messageData in pairs(combinedMessages) do
        local damageRounded = string.format("%.2f", messageData.damage or 0)
        
        local messageElements = {
            "[LanPang_RECORD][",
            Main.currentMatchID,
            "]",
            "[伤害事件]",
        }
        
        -- 根据消息类型决定如何显示攻击者和数量
        if messageData.messageType == "new" then
            -- 新规则：显示格式为 "攻击者X数量的技能对目标造成伤害"
            table.insert(messageElements, messageData.attackerName)
            -- 只有当不重复攻击者数量大于1时才显示数量
            if messageData.uniqueCount and messageData.uniqueCount > 1 then
                table.insert(messageElements, " X" .. messageData.uniqueCount)
            end
        else
            -- 原规则：显示格式为 "攻击者的技能对目标X数量造成伤害"
            table.insert(messageElements, messageData.attackerName)
        end
        
        -- 添加技能和目标信息
        table.insert(messageElements, "的")
        table.insert(messageElements, messageData.abilityName)
        table.insert(messageElements, "对")
        table.insert(messageElements, messageData.targetName)
        
        -- 对于原规则，数量显示在目标名称后面
        -- 只有当不重复目标数量大于1时才显示数量
        if messageData.messageType == "original" and messageData.uniqueCount and messageData.uniqueCount > 1 then
            table.insert(messageElements, " X" .. messageData.uniqueCount)
        end
        
        table.insert(messageElements, "共计造成了")
        table.insert(messageElements, damageRounded)
        table.insert(messageElements, "点伤害")
        
        -- 如果目标是英雄，添加血量变化信息
        if messageData.targetIsHero then
            local startHealth = math.floor(messageData.targetStartHealth)
            local endHealth = math.floor(messageData.targetCurrentHealth)
            table.insert(messageElements, "（" .. startHealth .. "->" .. endHealth .. "）")
        end
        
        -- 发送本次消息
        if Main.createLocalizedMessage then
            Main:createLocalizedMessage(unpack(messageElements))
        end
    end
    
    -- 每次广播后清空计数表
    Main.entityCounters[timestampKey] = nil
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
    
    -- 记录当前更新时间
    hero_duel.lastUpdateTime = GameRules:GetGameTime()
    
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

-- 新增：检查并更新伤害面板（当产生新的伤害时调用）
function Main:CheckAndUpdateDamagePanel()
    if not hero_duel.damagePanelEnabled then 
        return 
    end
    
    -- 获取当前时间
    local currentTime = GameRules:GetGameTime()
    
    -- 检查是否满足最小更新间隔条件（1秒）
    if not hero_duel.lastUpdateTime or (currentTime - hero_duel.lastUpdateTime) >= 0.1 then
        self:UpdateDamagePanel()
    end
end

function Main:StartDamagePanelTimer()
    print("[伤害面板] 启动伤害面板更新定时器")
    
    -- 初始化最后更新时间
    hero_duel.lastUpdateTime = GameRules:GetGameTime()
    
    Timers:CreateTimer(function()
        if hero_duel.damagePanelEnabled then
            -- 定时更新仍然保留，以确保过期技能被移除
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
    
    -- 当启用面板时，确保初始化最后更新时间
    if enabled then
        hero_duel.lastUpdateTime = hero_duel.lastUpdateTime or GameRules:GetGameTime()
    end
    
    if enabled and not hero_duel.damagePanelTimerStarted then
        self:StartDamagePanelTimer()
        hero_duel.damagePanelTimerStarted = true
    end
end