function Main:AutoUpgradeHeroAbilities(hero)
    print("尝试自动升级技能")
    local level = hero:GetLevel()
    local heroName = hero:GetUnitName()
    local facetID = hero:GetHeroFacetID() or 0
    -- 特殊英雄处理
    local isOgreMagi = heroName == "npc_dota_hero_ogre_magi" and facetID == 2
    local isInvoker = heroName == "npc_dota_hero_invoker"
    local isMeepo = heroName == "npc_dota_hero_meepo"
    
    print("英雄名称: " .. heroName .. ", 当前等级: " .. level .. ", facetID: " .. facetID)
    
    -- 卡尔元素球技能的名称
    local quasName = "invoker_quas"
    local wexName = "invoker_wex"
    local exortName = "invoker_exort"
    
    -- 收集所有技能
    local allAbilities = {}
    local talentAbilities = {}
    local normalAbilities = {}
    local ultimateAbility = nil
    
    -- 检查技能是否应该被跳过（不直接升级）
    local function shouldSkipAbility(ability)
        if ability:IsNull() or ability:IsHidden() then
            return true
        end
        
        -- 检查技能行为是否包含SKIP_FOR_KEYBINDS
        local behavior = ability:GetBehavior()
        if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_SKIP_FOR_KEYBINDS) ~= 0 then
            print("跳过SKIP_FOR_KEYBINDS技能: " .. ability:GetAbilityName())
            return true
        end
        
        -- 尝试获取MaxLevel，如果为1则跳过
        local maxLevel = 0
        pcall(function() maxLevel = ability:GetSpecialValueFor("MaxLevel") end)
        if maxLevel == 1 then
            print("跳过MaxLevel=1技能: " .. ability:GetAbilityName())
            return true
        end
        
        -- 尝试获取Innate，如果为1则跳过
        local innate = 0
        pcall(function() innate = ability:GetSpecialValueFor("Innate") end)
        if innate == 1 then
            print("跳过Innate=1技能: " .. ability:GetAbilityName())
            return true
        end
        
        return false
    end
    
    -- 获取天赋等级要求
    local function getTalentLevels()
        if isMeepo then
            return {11, 15, 20, 25} -- 米波特殊处理
        elseif isOgreMagi then
            return {9, 14, 19, 24} -- 食人魔特殊处理
        else
            return {10, 15, 20, 25} -- 标准天赋等级
        end
    end
    
    -- 获取大招等级要求
    local function getUltLevels()
        if isMeepo then
            return {3, 10, 17} -- 米波特殊处理
        else
            return {6, 12, 18} -- 标准大招等级
        end
    end
    
    -- 收集英雄的所有技能
    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability and not ability:IsNull() then
            local abilityName = ability:GetAbilityName()
            
            table.insert(allAbilities, ability)
            
            -- 分类技能
            if string.find(abilityName, "special_bonus") then
                table.insert(talentAbilities, ability)
            elseif not ability:IsHidden() and ability:CanAbilityBeUpgraded() and not shouldSkipAbility(ability) then
                -- 如果是祈求者，只处理前三个技能
                if isInvoker then
                    if i <= 2 then
                        table.insert(normalAbilities, ability)
                    end
                else
                    -- 非祈求者处理普通技能和大招
                    if ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
                        ultimateAbility = ability
                    else
                        table.insert(normalAbilities, ability)
                    end
                end
            end
        end
    end
    
    -- 打印收集到的技能
    print("收集到 " .. #normalAbilities .. " 个普通技能, " .. #talentAbilities .. " 个天赋技能")
    
    -- 打印普通技能信息
    for i, ability in ipairs(normalAbilities) do
        print("普通技能 #" .. i .. ": " .. ability:GetAbilityName() .. ", 当前等级: " .. ability:GetLevel() .. ", 可升级: " .. tostring(ability:CanAbilityBeUpgraded()))
    end
    
    -- 打印天赋技能信息
    for i, ability in ipairs(talentAbilities) do
        print("天赋技能 #" .. i .. ": " .. ability:GetAbilityName() .. ", 当前等级: " .. ability:GetLevel() .. ", 可升级: " .. tostring(ability:CanAbilityBeUpgraded()))
    end
    
    -- 如果有大招，打印大招信息
    if ultimateAbility then
        print("大招: " .. ultimateAbility:GetAbilityName() .. ", 当前等级: " .. ultimateAbility:GetLevel() .. ", 可升级: " .. tostring(ultimateAbility:CanAbilityBeUpgraded()))
    end
    
    -- 排序天赋 (按照技能索引顺序)
    table.sort(talentAbilities, function(a, b)
        for i, ability in ipairs(allAbilities) do
            if ability == a then return true end
            if ability == b then return false end
        end
        return false
    end)
    
    -- 获取卡尔元素球调整后的等级，根据facetID调整优先级
    local function getInvokerAdjustedLevel(ability)
        local name = ability:GetAbilityName()
        local level = ability:GetLevel()
        
        if facetID == 5 and name == exortName then -- 火球facet
            return level - 1
        elseif facetID == 4 and name == wexName then -- 雷球facet
            return level - 1
        elseif facetID == 3 and name == quasName then -- 冰球facet
            return level - 1
        end
        
        return level
    end
    
    -- 卡尔元素球优先级排序
    local function sortInvokerAbilities()
        table.sort(normalAbilities, function(a, b)
            local aName = a:GetAbilityName()
            local bName = b:GetAbilityName()
            
            local aAdjustedLevel = getInvokerAdjustedLevel(a)
            local bAdjustedLevel = getInvokerAdjustedLevel(b)
            
            if aAdjustedLevel ~= bAdjustedLevel then
                return aAdjustedLevel < bAdjustedLevel
            end
            
            -- 按照facetID决定元素球优先级
            if facetID == 5 then -- 火球facet：Exort > Wex > Quas
                if aName == exortName then return true end
                if bName == exortName then return false end
                if aName == wexName then return true end
                if bName == wexName then return false end
            elseif facetID == 4 then -- 雷球facet：Wex > Quas > Exort
                if aName == wexName then return true end
                if bName == wexName then return false end
                if aName == quasName then return true end
                if bName == quasName then return false end
            elseif facetID == 3 then -- 冰球facet：Quas > Exort > Wex
                if aName == quasName then return true end
                if bName == quasName then return false end
                if aName == exortName then return true end
                if bName == exortName then return false end
            end
            
            for i, ability in ipairs(allAbilities) do
                if ability == a then return true end
                if ability == b then return false end
            end
            return false
        end)
        
        print("卡尔技能排序后结果：")
        for i, ability in ipairs(normalAbilities) do
            print("#" .. i .. ": " .. ability:GetAbilityName() .. ", 当前等级: " .. ability:GetLevel() .. ", 调整后等级: " .. getInvokerAdjustedLevel(ability))
        end
    end
    
    -- 标准技能排序
    local function sortNormalAbilities()
        table.sort(normalAbilities, function(a, b)
            if a:GetLevel() ~= b:GetLevel() then
                return a:GetLevel() < b:GetLevel()
            end
            
            for i, ability in ipairs(allAbilities) do
                if ability == a then return true end
                if ability == b then return false end
            end
            return false
        end)
        
        print("普通技能排序后结果：")
        for i, ability in ipairs(normalAbilities) do
            print("#" .. i .. ": " .. ability:GetAbilityName() .. ", 当前等级: " .. ability:GetLevel())
        end
    end
    
    -- 按特定规则排序技能
    if isInvoker and facetID >= 3 and facetID <= 5 then
        sortInvokerAbilities()
    else
        sortNormalAbilities()
    end
    
    -- 使用ExecuteOrderFromTable升级技能的函数
    local function upgradeAbilityWithOrder(ability)
        if ability and ability:CanAbilityBeUpgraded() and not shouldSkipAbility(ability) then
            local abilityName = ability:GetAbilityName()
            print("尝试升级技能: " .. abilityName .. ", 当前等级: " .. ability:GetLevel())
            
            local oldLevel = ability:GetLevel()
            
            local order = {
                UnitIndex = hero:entindex(),
                OrderType = DOTA_UNIT_ORDER_TRAIN_ABILITY,
                AbilityIndex = ability:entindex(),
                Queue = false
            }
            
            ExecuteOrderFromTable(order)
            
            -- 验证升级是否成功
            if ability:GetLevel() > oldLevel then
                print("成功升级技能: " .. abilityName .. ", 新等级: " .. ability:GetLevel())
                return true
            else
                print("升级技能失败: " .. abilityName .. ", 等级未变: " .. ability:GetLevel())
                return false
            end
        else
            if ability then
                if shouldSkipAbility(ability) then
                    print("技能应被跳过: " .. ability:GetAbilityName())
                else
                    print("技能无法升级: " .. ability:GetAbilityName() .. ", 原因: CanAbilityBeUpgraded = " .. tostring(ability:CanAbilityBeUpgraded()))
                end
            else
                print("技能为空，无法升级")
            end
        end
        return false
    end
    
    -- 升级技能并处理后续排序
    local function upgradeAndSort(ability)
        local result = upgradeAbilityWithOrder(ability)
        if result then
            print("技能升级成功，重新排序技能")
            -- 技能升级后根据英雄类型重新排序
            if isInvoker and facetID >= 3 and facetID <= 5 then
                sortInvokerAbilities()
            else
                sortNormalAbilities()
            end
            return true
        end
        return false
    end
    
    -- 升级天赋技能
    local function upgradeTalent(index)
        if talentAbilities[index] and talentAbilities[index]:CanAbilityBeUpgraded() then
            local result = upgradeAbilityWithOrder(talentAbilities[index])
            if result then
                print("英雄" .. heroName .. "学习天赋" .. index .. "成功")
                return true
            end
        else
            if talentAbilities[index] then
                print("天赋无法升级: " .. talentAbilities[index]:GetAbilityName() .. ", 原因: CanAbilityBeUpgraded = " .. tostring(talentAbilities[index]:CanAbilityBeUpgraded()))
            else
                print("天赋索引 " .. index .. " 不存在")
            end
        end
        return false
    end
    
    -- 检查英雄是否有未学习但已达到等级要求的天赋或大招
    local function checkAndUpgradePriorityAbilities()
        print("检查是否有优先升级的天赋或大招")
        -- 检查未学习的天赋
        local talentLevels = getTalentLevels()
        
        -- 检查每一对天赋
        for i = 1, 4 do
            local requiredLevel = talentLevels[i]
            local leftIndex = i * 2 - 1
            local rightIndex = i * 2
            
            -- 如果英雄等级已达到或超过此天赋要求
            if level >= requiredLevel then
                print("英雄等级 " .. level .. " 已达到或超过天赋要求 " .. requiredLevel)
                -- 检查左侧天赋
                if talentAbilities[leftIndex] and talentAbilities[leftIndex]:GetLevel() == 0 and talentAbilities[leftIndex]:CanAbilityBeUpgraded() then
                    print("检测到左侧天赋可升级: " .. talentAbilities[leftIndex]:GetAbilityName())
                    if upgradeAbilityWithOrder(talentAbilities[leftIndex]) then
                        print("英雄"..heroName.."已达到"..requiredLevel.."级，补学左侧天赋")
                        return true
                    end
                else
                    if talentAbilities[leftIndex] then
                        print("左侧天赋无法升级: " .. talentAbilities[leftIndex]:GetAbilityName() .. ", 等级: " .. talentAbilities[leftIndex]:GetLevel() .. ", CanAbilityBeUpgraded: " .. tostring(talentAbilities[leftIndex]:CanAbilityBeUpgraded()))
                    end
                end
                
                -- 如果英雄等级已达到或超过27级（可以学习第二个天赋）
                if level >= (26 + i) then
                    print("英雄等级 " .. level .. " 已达到或超过高级天赋要求 " .. (26 + i))
                    -- 检查右侧天赋
                    if talentAbilities[rightIndex] and talentAbilities[rightIndex]:GetLevel() == 0 and talentAbilities[rightIndex]:CanAbilityBeUpgraded() then
                        print("检测到右侧天赋可升级: " .. talentAbilities[rightIndex]:GetAbilityName())
                        if upgradeAbilityWithOrder(talentAbilities[rightIndex]) then
                            print("英雄"..heroName.."已达到"..tostring(26+i).."级，补学右侧天赋")
                            return true
                        end
                    else
                        if talentAbilities[rightIndex] then
                            print("右侧天赋无法升级: " .. talentAbilities[rightIndex]:GetAbilityName() .. ", 等级: " .. talentAbilities[rightIndex]:GetLevel() .. ", CanAbilityBeUpgraded: " .. tostring(talentAbilities[rightIndex]:CanAbilityBeUpgraded()))
                        end
                    end
                end
            end
        end
        
        -- 检查大招（卡尔不需要检查大招）
        if ultimateAbility and not isInvoker then
            print("检查大招: " .. ultimateAbility:GetAbilityName() .. ", 当前等级: " .. ultimateAbility:GetLevel())
            -- 大招等级门槛
            local ultLevels = getUltLevels()
            
            -- 检查英雄等级是否足够学习大招的各个等级
            for i, requiredLevel in ipairs(ultLevels) do
                if level >= requiredLevel and ultimateAbility:GetLevel() < i and ultimateAbility:CanAbilityBeUpgraded() then
                    print("英雄等级 " .. level .. " 已达到大招要求 " .. requiredLevel .. ", 当前大招等级: " .. ultimateAbility:GetLevel() .. ", 目标等级: " .. i)
                    if upgradeAbilityWithOrder(ultimateAbility) then
                        print("英雄"..heroName.."已达到"..requiredLevel.."级，补学大招第"..i.."级")
                        return true
                    end
                end
            end
        end
        
        -- 卡尔特殊处理：如果卡尔跳级了，计算并分配所有可用的技能点到元素球上
        if isInvoker then
            print("卡尔特殊处理，检查是否有可用技能点")
            -- 计算可用技能点
            local availableSkillPoints = level - 1  -- 1级不加点
            
            -- 减去已经使用的技能点
            for _, ability in ipairs(normalAbilities) do
                availableSkillPoints = availableSkillPoints - ability:GetLevel()
            end
            
            -- 如果有可用技能点，则分配到元素球上
            if availableSkillPoints > 0 then
                -- 先确保技能已按照优先级排序
                sortInvokerAbilities()
                
                print("卡尔跳级检测：有"..availableSkillPoints.."个可用技能点")
                
                -- 分配技能点
                for i = 1, availableSkillPoints do
                    if #normalAbilities > 0 and normalAbilities[1]:CanAbilityBeUpgraded() then
                        print("卡尔分配第 " .. i .. " 个技能点到: " .. normalAbilities[1]:GetAbilityName())
                        if upgradeAbilityWithOrder(normalAbilities[1]) then
                            print("卡尔升级"..normalAbilities[1]:GetAbilityName().."成功")
                            sortInvokerAbilities()
                            return true
                        end
                    else
                        if #normalAbilities > 0 then
                            print("卡尔技能无法升级: " .. normalAbilities[1]:GetAbilityName() .. ", 原因: CanAbilityBeUpgraded = " .. tostring(normalAbilities[1]:CanAbilityBeUpgraded()))
                        else
                            print("卡尔没有可用的普通技能")
                        end
                    end
                end
            else
                print("卡尔没有可用技能点: 当前等级 " .. level .. ", 已使用技能点: " .. (level - 1 - availableSkillPoints))
            end
        end
        
        print("没有找到需要优先升级的技能")
        return false
    end
    
    -- 处理标准天赋升级
    local function handleStandardTalentUpgrade()
        print("处理标准天赋升级")
        -- 根据等级选择对应的天赋索引
        local talentIndex = nil
        
        if level >= 10 and level < 15 then
            talentIndex = 1
            print("英雄等级 " .. level .. ", 可升级10级天赋")
        elseif level >= 15 and level < 20 then
            talentIndex = 3
            print("英雄等级 " .. level .. ", 可升级15级天赋")
        elseif level >= 20 and level < 25 then
            talentIndex = 5
            print("英雄等级 " .. level .. ", 可升级20级天赋")
        elseif level >= 25 and level < 27 then
            talentIndex = 7
            print("英雄等级 " .. level .. ", 可升级25级天赋")
        elseif level == 27 then
            talentIndex = 2
            print("英雄等级27, 可升级10级右侧天赋")
        elseif level == 28 then
            talentIndex = 4
            print("英雄等级28, 可升级15级右侧天赋")
        elseif level == 29 then
            talentIndex = 6
            print("英雄等级29, 可升级20级右侧天赋")
        elseif level == 30 then
            talentIndex = 8
            print("英雄等级30, 可升级25级右侧天赋")
        end
        
        if talentIndex and talentAbilities[talentIndex] and talentAbilities[talentIndex]:CanAbilityBeUpgraded() then
            print("尝试升级天赋索引 " .. talentIndex .. ": " .. talentAbilities[talentIndex]:GetAbilityName())
            return upgradeTalent(talentIndex)
        else
            if talentIndex and talentAbilities[talentIndex] then
                print("天赋无法升级: " .. talentAbilities[talentIndex]:GetAbilityName() .. ", 原因: CanAbilityBeUpgraded = " .. tostring(talentAbilities[talentIndex]:CanAbilityBeUpgraded()))
            elseif talentIndex then
                print("天赋索引 " .. talentIndex .. " 不存在")
            else
                print("当前等级 " .. level .. " 没有对应的天赋索引")
            end
        end
        
        return false
    end
    
    -- 计算剩余技能点函数
    local function calculateRemainingSkillPoints()
        -- 普通英雄的技能点计算
        local usedPoints = 0
        
        -- 计算已使用的普通技能点
        for _, ability in ipairs(normalAbilities) do
            usedPoints = usedPoints + ability:GetLevel()
        end
        
        -- 如果有大招，加上大招的点数
        if ultimateAbility then
            usedPoints = usedPoints + ultimateAbility:GetLevel()
        end
        
        -- 计算已使用的天赋点数
        for _, ability in ipairs(talentAbilities) do
            usedPoints = usedPoints + ability:GetLevel()
        end
        
        -- 计算总技能点 (每级一个技能点)
        local totalPoints = level
        
        -- 返回剩余技能点
        return totalPoints - usedPoints
    end
    
    -- 尝试升级技能的主逻辑
    local upgraded = false
    
    -- 计算并打印剩余技能点
    local remainingPoints = calculateRemainingSkillPoints()
    print("当前等级: " .. level .. ", 剩余技能点: " .. remainingPoints)
    
    -- 首先尝试补加之前跳过的天赋或大招
    upgraded = checkAndUpgradePriorityAbilities()
    
    -- 如果没有补加天赋或大招，按照常规逻辑加点
    if not upgraded then
        print("没有优先升级的技能，尝试按照常规逻辑加点")
        -- 处理特殊英雄
        if isOgreMagi then
            print("处理食人魔特殊加点")
            -- 食人魔魔法师特殊处理
            if level == 2 then
                -- 2级时连续升级3次
                for i = 1, 3 do
                    if #normalAbilities > 0 and normalAbilities[1]:CanAbilityBeUpgraded() then
                        print("食人魔2级，第" .. i .. "次尝试升级技能")
                        upgraded = upgradeAndSort(normalAbilities[1]) or upgraded
                    end
                end
            elseif level == 9 or level == 14 or level == 19 or level == 24 then
                -- 食人魔魔法师天赋升级时间
                local talentIndex = level == 9 and 1 or (level == 14 and 3 or (level == 19 and 5 or 7))
                print("食人魔等级 " .. level .. ", 尝试升级天赋索引 " .. talentIndex)
                upgraded = upgradeTalent(talentIndex) or upgraded
            elseif level == 6 or level == 12 or level == 18 then
                -- 大招升级
                if ultimateAbility and ultimateAbility:CanAbilityBeUpgraded() then
                    print("食人魔等级 " .. level .. ", 尝试升级大招")
                    upgraded = upgradeAbilityWithOrder(ultimateAbility) or upgraded
                end
            end
        elseif isMeepo then
            print("处理米波特殊加点")
            -- 米波特殊处理
            local ultLevels = getUltLevels()
            local talentLevels = getTalentLevels()
            
            if level == ultLevels[1] or level == ultLevels[2] or level == ultLevels[3] then
                -- 米波大招升级时间
                if ultimateAbility and ultimateAbility:CanAbilityBeUpgraded() then
                    print("米波等级 " .. level .. ", 尝试升级大招")
                    upgraded = upgradeAbilityWithOrder(ultimateAbility) or upgraded
                end
            elseif level == talentLevels[1] or level == talentLevels[2] or
                   level == talentLevels[3] or level == talentLevels[4] then
                -- 天赋升级时间
                local talentIndex = nil
                if level == talentLevels[1] then talentIndex = 1
                elseif level == talentLevels[2] then talentIndex = 3
                elseif level == talentLevels[3] then talentIndex = 5
                elseif level == talentLevels[4] then talentIndex = 7
                end
                
                if talentIndex then
                    print("米波等级 " .. level .. ", 尝试升级天赋索引 " .. talentIndex)
                    upgraded = upgradeTalent(talentIndex) or upgraded
                end
            elseif level >= 27 and level <= 30 then
                -- 27-30级补充天赋
                local talentIndex = level - 25
                print("米波等级 " .. level .. ", 尝试升级天赋索引 " .. (talentIndex * 2))
                upgraded = upgradeTalent(talentIndex * 2) or upgraded
            else
                -- 其他等级升级普通技能
                if #normalAbilities > 0 and normalAbilities[1]:CanAbilityBeUpgraded() then
                    print("米波等级 " .. level .. ", 尝试升级普通技能")
                    upgraded = upgradeAndSort(normalAbilities[1]) or upgraded
                end
            end
        elseif isInvoker then
            print("处理卡尔特殊加点")
            -- 卡尔的标准升级逻辑
            if level == 2 then
                -- 2级时卡尔升级一个技能点
                if #normalAbilities > 0 and normalAbilities[1]:CanAbilityBeUpgraded() then
                    print("卡尔2级加点开始")
                    upgraded = upgradeAndSort(normalAbilities[1]) or upgraded
                    
                    if upgraded then
                        print("卡尔2级成功升级：" .. normalAbilities[1]:GetAbilityName())
                    else
                        print("卡尔2级升级失败")
                    end
                end
            else
                -- 处理标准天赋升级和普通技能升级
                upgraded = handleStandardTalentUpgrade()
                
                -- 如果没有升级天赋，尝试升级普通技能
                if not upgraded and level > 2 and #normalAbilities > 0 and normalAbilities[1]:CanAbilityBeUpgraded() then
                    print("卡尔等级 " .. level .. ", 没有合适的天赋，尝试升级普通技能")
                    upgraded = upgradeAndSort(normalAbilities[1]) or upgraded
                end
            end
        else
            print("处理标准加点逻辑")
            -- 标准升级逻辑
            -- 处理标准天赋升级
            upgraded = handleStandardTalentUpgrade()
            
            -- 处理大招升级
            if not upgraded then
                local ultLevels = getUltLevels()
                for i, requiredLevel in ipairs(ultLevels) do
                    if level == requiredLevel and ultimateAbility and ultimateAbility:GetLevel() < i and ultimateAbility:CanAbilityBeUpgraded() then
                        print("英雄等级 " .. level .. ", 尝试升级大招到第" .. i .. "级")
                        upgraded = upgradeAbilityWithOrder(ultimateAbility) or upgraded
                        break
                    end
                end
            end
            
            -- 处理普通技能升级
            if not upgraded and #normalAbilities > 0 and normalAbilities[1]:CanAbilityBeUpgraded() then
                print("英雄等级 " .. level .. ", 尝试升级排序首位的普通技能: " .. normalAbilities[1]:GetAbilityName())
                upgraded = upgradeAndSort(normalAbilities[1]) or upgraded
            end
        end
    end
    
    if not upgraded then
        -- 如果没有正常升级，再次尝试补点
        print("没有正常升级技能，再次尝试补点")
        upgraded = checkAndUpgradePriorityAbilities()
    end
    
    -- 再次计算剩余技能点
    remainingPoints = calculateRemainingSkillPoints()
    print("升级后剩余技能点: " .. remainingPoints)
    
    -- 如果还有剩余技能点，尝试继续升级
    if remainingPoints > 0 then
        print("还有剩余技能点，尝试继续升级普通技能")
        -- 重新计算可用技能点，并确保所有技能均匀升级
        local maxTries = 20  -- 防止无限循环
        local tryCount = 0
        
        while remainingPoints > 0 and tryCount < maxTries do
            tryCount = tryCount + 1
            local anyUpgraded = false
            
            -- 尝试升级普通技能
            if #normalAbilities > 0 then
                -- 先排序，确保低等级技能优先升级
                if isInvoker and facetID >= 3 and facetID <= 5 then
                    sortInvokerAbilities()
                else
                    sortNormalAbilities()
                end
                
                print("尝试升级排序后技能列表中的技能")
                for i, ability in ipairs(normalAbilities) do
                    if ability:CanAbilityBeUpgraded() and not shouldSkipAbility(ability) then
                        local oldLevel = ability:GetLevel()
                        if upgradeAbilityWithOrder(ability) then
                            anyUpgraded = true
                            print("成功升级技能: " .. ability:GetAbilityName() .. " 从 " .. oldLevel .. " 到 " .. ability:GetLevel())
                            break  -- 每次只升级一个技能，然后重新排序
                        end
                    end
                end
            end
            
            -- 如果无法升级普通技能，尝试升级大招
            if not anyUpgraded and ultimateAbility and ultimateAbility:CanAbilityBeUpgraded() then
                anyUpgraded = upgradeAbilityWithOrder(ultimateAbility)
            end
            
            -- 如果所有尝试都失败，退出循环
            if not anyUpgraded then
                print("没有可升级的技能了，结束升级过程")
                break
            end
            
            -- 更新剩余技能点
            remainingPoints = calculateRemainingSkillPoints()
            print("本轮升级后剩余技能点: " .. remainingPoints)
        end
    end
    
    print("技能升级过程结束，是否成功升级: " .. tostring(upgraded))
end