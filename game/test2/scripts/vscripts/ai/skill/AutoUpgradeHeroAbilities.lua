function Main:AutoUpgradeHeroAbilities(hero)
    -- 获取英雄等级
    local heroLevel = hero:GetLevel()
    local heroName = hero:GetUnitName()
    local facetID = hero:GetHeroFacetID() or 0
    local isOgreMagi = heroName == "npc_dota_hero_ogre_magi" and facetID == 2
    
    -- 收集英雄的所有技能
    local allAbilities = {}
    local talentAbilities = {}
    local normalAbilities = {}
    local ultimateAbility = nil
    
    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability and not ability:IsNull() then
            local abilityName = ability:GetAbilityName()
            
            -- 排除等级要求大于英雄当前等级的技能
            if ability:GetHeroLevelRequiredToUpgrade() <= heroLevel then
                -- 排除属性加成技能
                if abilityName ~= "special_bonus_attributes" then
                    table.insert(allAbilities, ability)
                    
                    -- 分类技能：天赋、终极技能、普通技能
                    if string.find(abilityName, "special_bonus") then
                        table.insert(talentAbilities, ability)
                    elseif ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
                        ultimateAbility = ability
                    else
                        table.insert(normalAbilities, ability)
                    end
                end
            end
        end
    end
    
    -- 排序天赋技能（按照技能索引顺序）
    table.sort(talentAbilities, function(a, b)
        for i, ability in ipairs(allAbilities) do
            if ability == a then return true end
            if ability == b then return false end
        end
        return false
    end)
    
    -- 尝试升级技能的主逻辑
    local upgraded = false
    
    -- 优先升级终极技能
    if ultimateAbility and ultimateAbility:CanAbilityBeUpgraded() then
        upgraded = Main:upgradeAbilityWithOrder(hero, ultimateAbility)
    end
    
    -- 如果终极技能无法升级，检查天赋技能
    if not upgraded then
        local talentIndex = nil
        
        -- 根据英雄类型和等级确定可升级的天赋索引
        if isOgreMagi then
            -- 食人魔魔法师特殊天赋等级要求
            if heroLevel >= 29 and talentAbilities[8] and talentAbilities[8]:GetLevel() == 0 and talentAbilities[8]:CanAbilityBeUpgraded() then
                talentIndex = 8
            elseif heroLevel >= 28 and talentAbilities[6] and talentAbilities[6]:GetLevel() == 0 and talentAbilities[6]:CanAbilityBeUpgraded() then
                talentIndex = 6
            elseif heroLevel >= 27 and talentAbilities[4] and talentAbilities[4]:GetLevel() == 0 and talentAbilities[4]:CanAbilityBeUpgraded() then
                talentIndex = 4
            elseif heroLevel >= 26 and talentAbilities[2] and talentAbilities[2]:GetLevel() == 0 and talentAbilities[2]:CanAbilityBeUpgraded() then
                talentIndex = 2
            elseif heroLevel >= 24 and talentAbilities[7] and talentAbilities[7]:GetLevel() == 0 and talentAbilities[7]:CanAbilityBeUpgraded() then
                talentIndex = 7
            elseif heroLevel >= 19 and talentAbilities[5] and talentAbilities[5]:GetLevel() == 0 and talentAbilities[5]:CanAbilityBeUpgraded() then
                talentIndex = 5
            elseif heroLevel >= 14 and talentAbilities[3] and talentAbilities[3]:GetLevel() == 0 and talentAbilities[3]:CanAbilityBeUpgraded() then
                talentIndex = 3
            elseif heroLevel >= 9 and talentAbilities[1] and talentAbilities[1]:GetLevel() == 0 and talentAbilities[1]:CanAbilityBeUpgraded() then
                talentIndex = 1
            end
        else
            -- 标准天赋等级要求
            if heroLevel >= 30 and talentAbilities[8] and talentAbilities[8]:GetLevel() == 0 and talentAbilities[8]:CanAbilityBeUpgraded() then
                talentIndex = 8
            elseif heroLevel >= 29 and talentAbilities[6] and talentAbilities[6]:GetLevel() == 0 and talentAbilities[6]:CanAbilityBeUpgraded() then
                talentIndex = 6
            elseif heroLevel >= 28 and talentAbilities[4] and talentAbilities[4]:GetLevel() == 0 and talentAbilities[4]:CanAbilityBeUpgraded() then
                talentIndex = 4
            elseif heroLevel >= 27 and talentAbilities[2] and talentAbilities[2]:GetLevel() == 0 and talentAbilities[2]:CanAbilityBeUpgraded() then
                talentIndex = 2
            elseif heroLevel >= 25 and talentAbilities[7] and talentAbilities[7]:GetLevel() == 0 and talentAbilities[7]:CanAbilityBeUpgraded() then
                talentIndex = 7
            elseif heroLevel >= 20 and talentAbilities[5] and talentAbilities[5]:GetLevel() == 0 and talentAbilities[5]:CanAbilityBeUpgraded() then
                talentIndex = 5
            elseif heroLevel >= 15 and talentAbilities[3] and talentAbilities[3]:GetLevel() == 0 and talentAbilities[3]:CanAbilityBeUpgraded() then
                talentIndex = 3
            elseif heroLevel >= 10 and talentAbilities[1] and talentAbilities[1]:GetLevel() == 0 and talentAbilities[1]:CanAbilityBeUpgraded() then
                talentIndex = 1
            end
        end
        
        -- 如果有可升级的天赋，进行升级
        if talentIndex and talentAbilities[talentIndex] then
            upgraded = Main:upgradeAbilityWithOrder(hero, talentAbilities[talentIndex])
        end
    end
    
    -- 如果没有可升级的天赋，升级普通技能
    if not upgraded and #normalAbilities > 0 then
        -- 按照等级要求从低到高排序普通技能
        table.sort(normalAbilities, function(a, b)
            return a:GetHeroLevelRequiredToUpgrade() < b:GetHeroLevelRequiredToUpgrade()
        end)
        
        for _, ability in ipairs(normalAbilities) do
            if ability:CanAbilityBeUpgraded() then
                upgraded = Main:upgradeAbilityWithOrder(hero, ability)
                if upgraded then
                    break
                end
            end
        end
    end
    
    return upgraded
end

function Main:upgradeAbilityWithOrder(hero, ability)
    if ability and hero then

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
            return true
        else
            return false
        end
    end
    return false
end

function Main:IsLearnableAbility(ability)
    if ability:IsNull() or ability:IsHidden() then
        return false
    end
    
    local behavior = ability:GetBehavior()
    if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_SKIP_FOR_KEYBINDS) ~= 0 then
        return false
    end
    
    -- 尝试获取MaxLevel，如果为1则跳过
    local maxLevel = 0
    pcall(function() maxLevel = ability:GetSpecialValueFor("MaxLevel") end)
    if maxLevel == 1 then
        return false
    end
    
    -- 尝试获取Innate，如果为1则跳过
    local innate = 0
    pcall(function() innate = ability:GetSpecialValueFor("Innate") end)
    if innate == 1 then
        return false
    end
    
    return true
end

