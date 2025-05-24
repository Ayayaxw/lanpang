function Main:PrintEverythingAboutUnit(event)
    local playerID = event.PlayerID
    local unitEntIndex = event.unit_ent_index
    local unit = EntIndexToHScript(unitEntIndex)
    local PREFIX = "【打印单位信息】"

    -- 查找所有的npc_dota_thinker单位
    local enemyVariant = Convars:GetInt("dota_hero_demo_default_enemy_variant")
    print("敌对单位变体：" .. enemyVariant)

    
    if unit:IsBarracks() then
        print(PREFIX .. string.format("【单位】%s 是守卫", unit:GetUnitName()))
    else
        print(PREFIX .. string.format("【单位】%s 不是守卫", unit:GetUnitName()))
    end

    --打印该单位是不是守卫IsWard
    if unit:IsWard() then
        print(PREFIX .. string.format("【单位】%s 是ward", unit:GetUnitName()))
    else
        print(PREFIX .. string.format("【单位】%s 不是ward", unit:GetUnitName()))
    end

    if unit:IsZombie() then
        print(PREFIX .. string.format("【单位】%s 是zombie", unit:GetUnitName()))
    else
        print(PREFIX .. string.format("【单位】%s 不是zombie", unit:GetUnitName()))
    end
    
    if unit:IsOther() then
        print(PREFIX .. string.format("【单位】%s 是other", unit:GetUnitName()))
    else
        print(PREFIX .. string.format("【单位】%s 不是other", unit:GetUnitName()))
    end
    
    if unit:IsHero() then
        print(PREFIX .. string.format("【单位】%s 是英雄", unit:GetUnitName()))
    else
        print(PREFIX .. string.format("【单位】%s 不是英雄", unit:GetUnitName()))
    end

    if unit:IsConsideredHero() then
        print(PREFIX .. string.format("【单位】%s 是ConsideredHero", unit:GetUnitName()))
    else
        print(PREFIX .. string.format("【单位】%s 不是ConsideredHero", unit:GetUnitName()))
    end
    
    

    print(PREFIX .. string.format("【单位坐标】%s 当前坐标：X=%.2f, Y=%.2f, Z=%.2f", unit:GetUnitName(), unit:GetOrigin().x, unit:GetOrigin().y, unit:GetOrigin().z))
    --打印是否是幻象
    if unit:IsIllusion() then
        print(PREFIX .. string.format("【单位】%s 是幻象", unit:GetUnitName()))
    end

    onwer = unit:GetRealOwner()
    if onwer then print(PREFIX .. "主人是，",onwer:GetUnitName())

    end
    if unit and IsValidEntity(unit) then
        -- 打印单位身上的所有物品
        print(PREFIX .. string.format("【单位物品】%s 当前携带的物品：", unit:GetUnitName()))
        for i = 0, 16 do
            local item = unit:GetItemInSlot(i)
            if item then
                print(PREFIX .. string.format("    槽位 %d: %s", i, item:GetName()))
            end
        end

        -- 打印所有技能，按类别分类
        print(PREFIX .. string.format("【单位技能】%s 的所有技能：", unit:GetUnitName()))
        
        -- 创建三个分类数组
        local normalAbilities = {}
        local hiddenAbilities = {}
        local talentAbilities = {}
        
        -- 遍历所有技能并分类
        for i = 0, unit:GetAbilityCount() - 1 do
            local ability = unit:GetAbilityByIndex(i)
            if ability then
                local abilityName = ability:GetAbilityName()
                local activeStatus = ability:GetToggleState() and "[已激活]" or ""
                local targetType = ability:GetAbilityTargetType()
                local targetTypeStr = ""
                
                -- 获取升级所需英雄等级和是否可被偷取
                local heroLevelRequired = ability.GetHeroLevelRequiredToUpgrade and ability:GetHeroLevelRequiredToUpgrade() or "N/A"
                local isStealable = ability.IsStealable and ability:IsStealable() or false
                
                -- 转换数字目标类型为可读字符串
                if bit.band(targetType, DOTA_UNIT_TARGET_HERO) ~= 0 then
                    targetTypeStr = targetTypeStr .. "HERO "
                end
                if bit.band(targetType, DOTA_UNIT_TARGET_CREEP) ~= 0 then
                    targetTypeStr = targetTypeStr .. "CREEP "
                end
                if bit.band(targetType, DOTA_UNIT_TARGET_BUILDING) ~= 0 then
                    targetTypeStr = targetTypeStr .. "BUILDING "
                end
                if bit.band(targetType, DOTA_UNIT_TARGET_COURIER) ~= 0 then
                    targetTypeStr = targetTypeStr .. "COURIER "
                end
                if bit.band(targetType, DOTA_UNIT_TARGET_BASIC) ~= 0 then
                    targetTypeStr = targetTypeStr .. "BASIC "
                end
                if bit.band(targetType, DOTA_UNIT_TARGET_OTHER) ~= 0 then
                    targetTypeStr = targetTypeStr .. "OTHER "
                end
                if bit.band(targetType, DOTA_UNIT_TARGET_TREE) ~= 0 then
                    targetTypeStr = targetTypeStr .. "TREE "
                end
                if bit.band(targetType, DOTA_UNIT_TARGET_CUSTOM) ~= 0 then
                    targetTypeStr = targetTypeStr .. "CUSTOM "
                end
                if bit.band(targetType, DOTA_UNIT_TARGET_SELF) ~= 0 then
                    targetTypeStr = targetTypeStr .. "SELF "
                end
                
                if targetTypeStr == "" then
                    targetTypeStr = "NONE"
                end
                
                local abilityInfo = {
                    index = i,
                    name = abilityName,
                    activeStatus = activeStatus,
                    targetTypeStr = targetTypeStr,
                    targetType = targetType,
                    heroLevelRequired = heroLevelRequired,
                    isStealable = isStealable
                }
                
                -- 根据类别分组
                if string.find(abilityName, "special_bonus_") == 1 then
                    table.insert(talentAbilities, abilityInfo)
                elseif ability:IsHidden() then
                    table.insert(hiddenAbilities, abilityInfo)
                else
                    table.insert(normalAbilities, abilityInfo)
                end
            end
        end
        
        -- 打印非隐藏技能
        print(PREFIX .. "  [非隐藏技能]")
        for _, abilityInfo in ipairs(normalAbilities) do
            print(PREFIX .. string.format("    - %d:%s %s [目标类型: %s (%d)] [升级所需等级: %s] [可被偷取: %s]", 
                abilityInfo.index,
                abilityInfo.name, 
                abilityInfo.activeStatus, 
                abilityInfo.targetTypeStr, 
                abilityInfo.targetType,
                tostring(abilityInfo.heroLevelRequired),
                abilityInfo.isStealable and "是" or "否"))
        end
        
        -- 打印隐藏技能
        print(PREFIX .. "  [隐藏技能]")
        for _, abilityInfo in ipairs(hiddenAbilities) do
            print(PREFIX .. string.format("    - %d:%s %s [目标类型: %s (%d)] [升级所需等级: %s] [可被偷取: %s]", 
                abilityInfo.index,
                abilityInfo.name, 
                abilityInfo.activeStatus, 
                abilityInfo.targetTypeStr, 
                abilityInfo.targetType,
                tostring(abilityInfo.heroLevelRequired),
                abilityInfo.isStealable and "是" or "否"))
        end
        
        -- 打印天赋技能
        print(PREFIX .. "  [天赋技能]")
        for _, abilityInfo in ipairs(talentAbilities) do
            print(PREFIX .. string.format("    - %d:%s %s [目标类型: %s (%d)] [升级所需等级: %s] [可被偷取: %s]", 
                abilityInfo.index,
                abilityInfo.name, 
                abilityInfo.activeStatus, 
                abilityInfo.targetTypeStr, 
                abilityInfo.targetType,
                tostring(abilityInfo.heroLevelRequired),
                abilityInfo.isStealable and "是" or "否"))
        end

        -- 查找最近的单位
        local nearbyUnits = FindUnitsInRadius(
            unit:GetTeamNumber(),
            unit:GetAbsOrigin(),
            nil,
            99999, -- 搜索范围设为最大以找到最近的单位
            DOTA_UNIT_TARGET_TEAM_BOTH,  -- 搜索所有队伍
            DOTA_UNIT_TARGET_ALL,        -- 搜索所有类型单位
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,                -- 按距离排序
            false
        )

        -- 找到最近的非自身单位
        local closestUnit = nil
        local closestDistance = 99999
        for _, nearbyUnit in pairs(nearbyUnits) do
            if nearbyUnit ~= unit then
                local distance = (nearbyUnit:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D()
                closestUnit = nearbyUnit
                closestDistance = distance
                break  -- 因为已经按距离排序，第一个非自身单位就是最近的
            end
        end

        if closestUnit then
            print(PREFIX .. string.format("【最近单位】%s 最近的单位是 %s，距离 %.0f", 
                unit:GetUnitName(),
                closestUnit:GetUnitName(),
                closestDistance
            ))
        else
            print(PREFIX .. string.format("【最近单位】%s 附近没有其他单位", unit:GetUnitName()))
        end

    

        local unitName = unit:GetUnitName()
        local modifiers = {}
        local unitModifiers = unit:FindAllModifiers()
        
        -- 在后端打印modifier详细信息
        print(PREFIX .. string.format("【单位Modifier】%s 的所有modifier：", unitName))
        for _, modifier in pairs(unitModifiers) do
            local modifierName = modifier:GetName()
            local remainingTime = modifier:GetRemainingTime()
            local duration = modifier:GetDuration()
            local stackCount = modifier:GetStackCount()
            
            -- 获取modifier的创造者和所属技能
            local caster = modifier:GetCaster()
            local ability = modifier:GetAbility()
            local casterInfo = caster and caster:GetUnitName() or "未知"
            local abilityInfo = ability and ability:GetAbilityName() or "未知"
            
            -- 后端打印
            print(PREFIX .. string.format("    - %s [持续时间: %.1f/%.1f] [层数: %d] [施法者: %s] [技能: %s]", 
                modifierName, 
                remainingTime, 
                duration, 
                stackCount,
                casterInfo,
                abilityInfo
            ))
            
            -- 保持原来的逻辑，把modifier信息添加到数组中用于发送给前端
            table.insert(modifiers, {
                name = modifierName,
                remaining_time = remainingTime,
                duration = duration,
                stack_count = stackCount
            })
        end
        
        local ownerPlayerID = unit:GetPlayerOwnerID()
        local teamNumber = unit:GetTeamNumber()
        
        local facetID = nil
        if unit.GetHeroFacetID then
            facetID = unit:GetHeroFacetID()
            print(PREFIX .. string.format("【单位】%s 的facetID是 %d", unit:GetUnitName(), facetID))
        end

        -- Add new unit information
        local isHero = unit:IsHero()
        local IsRealHero = unit:IsRealHero()
        local isIllusion = unit:IsIllusion()
        local isSummoned = unit:IsSummoned()

        -- Get child units
        local childUnits = {}
        local children = unit:GetChildren()
        for _, child in pairs(children) do
            -- 检查是否是单位（通过尝试调用IsUnit方法）
            if IsValidEntity(child) and child.IsUnit and child:IsUnit() then
                table.insert(childUnits, {
                    name = child:GetUnitName(),
                    ent_index = child:GetEntityIndex(),
                    is_summoned = child:IsSummoned()
                })
            end
        end

        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "response_unit_info", {
            unit_name = unitName,
            modifiers = modifiers,
            owner_player_id = ownerPlayerID,
            team_number = teamNumber,
            facet_id = facetID,
            is_hero = isHero,
            is_true_hero = IsRealHero,
            is_illusion = isIllusion,
            is_summoned = isSummoned,
            child_units = childUnits
        })
    end
end