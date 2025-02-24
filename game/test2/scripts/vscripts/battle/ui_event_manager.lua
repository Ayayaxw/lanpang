
function Main:MonitorUnitsStatus()
    -- 计算队伍基础状态的函数
    local function calculateTeamStats(team)
        local totalHealth = 0
        local totalMaxHealth = 0
        local totalMana = 0
        local totalMaxMana = 0
        local totalAverageDamage = 0
        local totalArmor = 0
        local totalAttackSpeed = 0
        local totalMagicResistance = 0
        local totalMoveSpeed = 0
        local totalStrength = 0
        local totalAgility = 0
        local totalIntellect = 0
        local heroCount = #team
    
        for i, hero in ipairs(team) do
            if hero and not hero:IsNull() then
                totalHealth = totalHealth + (hero:IsAlive() and hero:GetHealth() or 0)
                totalMaxHealth = totalMaxHealth + hero:GetMaxHealth()
                totalMana = totalMana + hero:GetMana()
                totalMaxMana = totalMaxMana + hero:GetMaxMana()
                totalAverageDamage = totalAverageDamage + hero:GetAverageTrueAttackDamage(nil)
                totalArmor = totalArmor + hero:GetPhysicalArmorValue(false)
                totalAttackSpeed = totalAttackSpeed + hero:GetAttackSpeed(false)
                totalMagicResistance = totalMagicResistance + hero:Script_GetMagicalArmorValue(false, nil)
                
                local baseSpeed = hero:GetBaseMoveSpeed()
                local moveSpeedModifier = hero:GetMoveSpeedModifier(baseSpeed, false)
                totalMoveSpeed = totalMoveSpeed + moveSpeedModifier
                
                totalStrength = totalStrength + hero:GetStrength()
                totalAgility = totalAgility + hero:GetAgility()
                totalIntellect = totalIntellect + hero:GetIntellect(false)
            end
        end
    
        local stats = {
            currentHealth = totalHealth,
            maxHealth = totalMaxHealth,
            currentMana = totalMana,
            maxMana = totalMaxMana,
            averageDamage = math.floor(totalAverageDamage / heroCount + 0.5),
            armor = math.floor(totalArmor / heroCount + 0.5),
            attackSpeed = math.floor((totalAttackSpeed / heroCount) * 100),
            magicResistance = string.format("%.2f%%", (totalMagicResistance / heroCount) * 100),
            moveSpeed = math.floor(totalMoveSpeed / heroCount + 0.5),
            strength = math.floor(totalStrength / heroCount + 0.5),
            agility = math.floor(totalAgility / heroCount + 0.5),
            intellect = math.floor(totalIntellect / heroCount + 0.5)
        }
    
        return stats
    end

    -- 收集基础状态数据
    local statsData = {
        Left = calculateTeamStats(self.leftTeam),
        Right = calculateTeamStats(self.rightTeam)
    }

    -- 发送基础状态数据到前端
    CustomGameEventManager:Send_ServerToAllClients("update_unit_status", statsData)
    
    -- 调用技能状态监控函数
    --self:MonitorAbilitiesStatus()
end


function Main:ClearAbilitiesPanel()
    -- 发送清理信号到前端
    CustomGameEventManager:Send_ServerToAllClients("clear_abilities_panels", {})
    CustomGameEventManager:Send_ServerToAllClients("hide_hero_chaos_container", {})
    CustomGameEventManager:Send_ServerToAllClients("hide_hero_chaos_score", {})

end

function Main:MonitorAbilitiesStatus(hero,enableOverlapDetection)
    if not hero or hero:IsNull() then 
        --print("[技能监控] 英雄对象为空或无效")
        return 
    end
    
    --print("[技能监控] 开始监控英雄:", hero:GetUnitName())
    
    local function getHeroType(heroName)
        --print("[英雄类型] 正在查找英雄类型:", heroName)
        for _, heroData in pairs(heroes_precache) do
            if heroData.name == heroName then
                --print("[英雄类型] 找到英雄类型:", heroData.type)
                return heroData.type
            end
        end
        --print("[英雄类型] 未找到类型，使用默认值(1)")
        return 1
    end
    
    local function calculateAbilitiesStatus(hero)
        --print("[技能状态] 开始计算英雄技能状态:", hero:GetUnitName())
        local heroAbilities = {}
        local sortedAbilities = {}
        local abilityCount = 0
        
        local totalAbilities = hero:GetAbilityCount()
        for abilitySlot = 0, totalAbilities - 1 do
            local ability = hero:GetAbilityByIndex(abilitySlot)
            if ability and not ability:IsNull() and not ability:IsHidden() then
                --print(string.format("[技能信息] 槽位 %d: %s", abilitySlot, ability:GetAbilityName()))
                
                local isPassiveAndNotLearnable = 
                    bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_PASSIVE) ~= 0 and 
                    bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) ~= 0
                
                if not string.find(ability:GetAbilityName(), "special_bonus") and 
                   not (ability:IsPassive() and ability:GetMaxLevel() == 1) and
                   bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_INNATE_UI) == 0 and
                   not isPassiveAndNotLearnable then
                    
                    abilityCount = abilityCount + 1
                    -- print(string.format("[技能详情] %s: 等级=%d, 冷却时间=%.1f, 魔法消耗=%d", 
                    --     ability:GetAbilityName(),
                    --     ability:GetLevel(),
                    --     ability:GetCooldownTimeRemaining(),
                    --     ability:GetManaCost(-1)
                    -- ))
    
                    local abilityData = {
                        slot = abilitySlot,
                        data = {
                            id = ability:GetAbilityName(),
                            cooldown = math.floor(ability:GetCooldownTimeRemaining() * 10) / 10,
                            manaCost = ability:GetManaCost(-1),
                            level = ability:GetLevel(),
                            isPassive = ability:IsPassive(),
                            isActivated = ability:IsActivated(),
                            charges = ability:GetCurrentAbilityCharges(),
                            maxCharges = ability:GetMaxAbilityCharges(ability:GetLevel()),
                            chargeRestoreTime = ability:GetAbilityChargeRestoreTime(ability:GetLevel()),
                            hasEnoughMana = hero:GetMana() >= ability:GetManaCost(-1),
                            slot = abilitySlot
                        }
                    }
                    table.insert(sortedAbilities, abilityData)
                    --print(string.format("[技能数据] 已添加技能数据: %s", ability:GetAbilityName()))
                else
                    --print(string.format("[技能过滤] 技能被过滤掉: %s", ability:GetAbilityName()))
                end
            end
        end
        
        --print(string.format("[技能统计] 总共找到 %d 个有效技能", abilityCount))
        
        table.sort(sortedAbilities, function(a, b)
            return a.slot < b.slot
        end)
        --print("[技能排序] 技能已按槽位排序")
        
        for index, abilityData in ipairs(sortedAbilities) do
            heroAbilities[index] = abilityData.data
            --print(string.format("[技能索引] 索引 %d: %s", index, abilityData.data.id))
        end
        
        return heroAbilities
    end

    local heroName = hero:GetUnitName()
    --print("[英雄信息] 正在处理英雄:", heroName)
    local heroType = getHeroType(heroName)
    --print("[英雄信息] 获取到英雄类型:", heroType)

    local abilitiesData = {
        abilities = calculateAbilitiesStatus(hero),
        entityId = hero:GetEntityIndex(),
        teamId = hero:GetTeamNumber(),
        enableOverlapDetection = enableOverlapDetection
    }

    CustomGameEventManager:Send_ServerToAllClients("update_abilities_status", abilitiesData)
    --print("[发送数据] 数据已发送到前端")
end


function Main:StartTextMonitor(entity, text, fontSize, color)
    if not entity or entity:IsNull() then return end
    if not text or not fontSize or not color then return end

    -- 直接发送更新
    self:SendTextUpdate(entity, text, fontSize, color)
end

-- 更新文本内容
function Main:UpdateText(entity, text, fontSize, color)
    if not entity or entity:IsNull() then return end
    if not text or not fontSize or not color then return end
    
    -- 直接发送更新
    self:SendTextUpdate(entity, text, fontSize, color)
end

-- 发送文本更新到前端
function Main:SendTextUpdate(entity, text, fontSize, color)
    if not entity or entity:IsNull() then return end
    if not text or not fontSize or not color then return end
    
    local entityId = entity:GetEntityIndex()
    
    CustomGameEventManager:Send_ServerToAllClients("update_floating_text", {
        entityId = entityId,
        teamId = entity:GetTeamNumber(),
        text = text,
        fontSize = fontSize,
        color = color
    })
end

-- 清理指定实体的文本
function Main:ClearFloatingText(entity)
    if not entity or entity:IsNull() then return end

    CustomGameEventManager:Send_ServerToAllClients("clear_floating_text", {
        entityId = entity:GetEntityIndex()
    })
end

-- 清理所有文本
function Main:ClearAllFloatingText()
    CustomGameEventManager:Send_ServerToAllClients("clear_all_floating_text", {})
end

-- 在你的游戏逻辑中定时调用这个函数
function Main:StartAbilitiesMonitor(hero,enableOverlapDetection)
    if not hero or hero:IsNull() then return end
    
    local entityId = hero:GetEntityIndex()
    local timerName = "AbilitiesMonitor_" .. entityId
    
    -- 如果已经在监控中，先停止
    if Timers.timers[timerName] then
        Timers:RemoveTimer(timerName)
    end
    
    -- 创建新的监控定时器
    Timers:CreateTimer(timerName, {
        useGameTime = true,
        endTime = 0.1,
        callback = function()
            if not hero or hero:IsNull() then return nil end
            self:MonitorAbilitiesStatus(hero,false)
            return 0.1
        end
    })
end


function Main:StopAbilitiesMonitor(hero)
    print("[StopAbilitiesMonitor] Starting...")
    
    -- 增加entityId参数支持
    if type(hero) == "number" then
        print("[StopAbilitiesMonitor] Received entityId:", hero)
        hero = EntIndexToHScript(hero)
    end
    
    if not hero then
        print("[StopAbilitiesMonitor] Error: hero is nil")
        -- 尝试从追踪列表中获取entityId
        local entityId = hero
        if entityId then
            print("[StopAbilitiesMonitor] Attempting to remove panel using entityId:", entityId)
            -- 停止定时器
            local timerName = "AbilitiesMonitor_" .. entityId
            if Timers.timers[timerName] then
                print("[StopAbilitiesMonitor] Removing timer:", timerName)
                Timers:RemoveTimer(timerName)
            end
            
            -- 发送移除信号到前端
            CustomGameEventManager:Send_ServerToAllClients("remove_hero_abilities_panel", {
                entityId = entityId
            })
        end
        return
    end
    
    if hero:IsNull() then
        print("[StopAbilitiesMonitor] Error: hero is null")
        return
    end
    
    local entityId = hero:GetEntityIndex()
    print("[StopAbilitiesMonitor] Stopping monitor for hero entity:", entityId)
    
    -- 停止定时器
    local timerName = "AbilitiesMonitor_" .. entityId
    if Timers.timers[timerName] then
        print("[StopAbilitiesMonitor] Removing timer:", timerName)
        Timers:RemoveTimer(timerName)
    end
    
    -- 发送移除信号到前端
    print("[StopAbilitiesMonitor] Sending remove panel event for entity:", entityId)
    CustomGameEventManager:Send_ServerToAllClients("remove_hero_abilities_panel", {
        entityId = entityId
    })
    
    print("[StopAbilitiesMonitor] Completed for hero entity:", entityId)
end


function Main:SendHeroAndFacetData(leftHeroName, rightHeroName, LeftFacetID, RightFacetID,limitTime)
    -- 将单个 facet 数据转换为可序列化的格式
    local function convertSingleFacetToSerializable(heroName, facetID)
        local heroData = heroesFacets[heroName]
        if heroData and heroData["Facets"] then
            local facet = heroData["Facets"][facetID]  -- 使用整数索引访问 facet

            if facet then
                -- 准备序列化的 Facet 数据
                return {
                    [tostring(facetID)] = {
                        name = facet["name"],
                        color = facet["Color"],
                        gradientId = facet["GradientID"],
                        icon = facet["Icon"],
                        abilityName = facet["AbilityName"] or ""
                    }
                }
            else
                print("未找到 ID 对应的 Facet: ", facetID)
            end
        else
            print("未找到英雄或 Facets 数据：", heroName)
        end
        return {}
    end
    
    local serializedLeftFacet = convertSingleFacetToSerializable(leftHeroName, LeftFacetID)
    local serializedRightFacet = convertSingleFacetToSerializable(rightHeroName, RightFacetID)

    -- 打印即将发送的 Facet 数据
    print("即将发送的左侧英雄 Facet 数据：", serializedLeftFacet)
    print("即将发送的右侧英雄 Facet 数据：", serializedRightFacet)

    -- 发送事件，包含指定的 facet 数据和 AbilityName
    CustomGameEventManager:Send_ServerToAllClients("show_hero", {
        selfFacets = serializedLeftFacet,
        opponentFacets = serializedRightFacet,
        Time = limitTime,
    })
end

function Main:SendLeftHeroData(leftHeroName, LeftFacetID)
    -- 将单个 facet 数据转换为可序列化的格式
    local function convertSingleFacetToSerializable(heroName, facetID)
        local heroData = heroesFacets[heroName]
        if heroData and heroData["Facets"] then
            local facet = heroData["Facets"][facetID]  -- 使用整数索引访问 facet

            if facet then
                -- 准备序列化的 Facet 数据
                return {
                    [tostring(facetID)] = {
                        name = facet["name"],
                        color = facet["Color"],
                        gradientId = facet["GradientID"],
                        icon = facet["Icon"],
                        abilityName = facet["AbilityName"] or ""
                    }
                }
            else
                print("未找到 ID 对应的 Facet: ", facetID)
            end
        else
            print("未找到英雄或 Facets 数据：", heroName)
        end
        return {}
    end

    -- 使用 DOTA 2 API 根据英雄名称获取 hero ID
    local heroID = DOTAGameManager:GetHeroIDByName(leftHeroName)
    
    if not heroID then
        print("无法找到英雄 ID：", leftHeroName)
        return
    end

    local serializedLeftFacet = convertSingleFacetToSerializable(leftHeroName, LeftFacetID)

    -- 打印即将发送的数据
    print("即将发送的左侧英雄数据：", "Hero ID:", heroID, "Facet 数据:", serializedLeftFacet)

    -- 发送事件，包含左侧英雄的 hero ID 和 facet 数据
    CustomGameEventManager:Send_ServerToAllClients("show_left_hero", {
        heroID = heroID,
        facets = serializedLeftFacet
    })
end


