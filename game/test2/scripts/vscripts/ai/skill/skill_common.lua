local DOTA_UNIT_TARGET = {
    NONE = 0,
    HERO = 1,
    CREEP = 2,
    BUILDING = 4,
    COURIER = 16,
    BASIC = 18,
    HEROES_AND_CREEPS = 19,
    OTHER = 32,
    ALL = 55,
    TREE = 64,
    CUSTOM = 128,
    SELF = 256
}

DOTA_UNIT_TARGET_TEAM = {
    NONE = 0,
    FRIENDLY = 1,
    ENEMY = 2,
    BOTH = 3,
    CUSTOM = 4
}
local DOTA_ABILITY_BEHAVIOR = {
    LAST_RESORT_POINT = -2147483648,
    NONE = 0,
    HIDDEN = 1,
    PASSIVE = 2,
    NO_TARGET = 4,
    UNIT_TARGET = 8,
    POINT = 16,
    AOE = 32,
    NOT_LEARNABLE = 64,
    CHANNELLED = 128,
    ITEM = 256,
    TOGGLE = 512,
    DIRECTIONAL = 1024,
    IMMEDIATE = 2048,
    AUTOCAST = 4096,
    OPTIONAL_UNIT_TARGET = 8192,
    OPTIONAL_POINT = 16384,
    OPTIONAL_NO_TARGET = 32768,
    AURA = 65536,
    ATTACK = 131072,
    DONT_RESUME_MOVEMENT = 262144,
    ROOT_DISABLES = 524288,
    UNRESTRICTED = 1048576,
    IGNORE_PSEUDO_QUEUE = 2097152,
    IGNORE_CHANNEL = 4194304,
    DONT_CANCEL_MOVEMENT = 8388608,
    DONT_ALERT_TARGET = 16777216,
    DONT_RESUME_ATTACK = 33554432,
    NORMAL_WHEN_STOLEN = 67108864,
    IGNORE_BACKSWING = 134217728,
    RUNE_TARGET = 268435456,
    DONT_CANCEL_CHANNEL = 536870912,
    VECTOR_TARGETING = 1073741824
}


function CommonAI:GetAbilityInfo(skill, castRange, aoeRadius)
    local abilityName = skill:GetAbilityName()
    
    local targetTeam = self:GetSkillTargetTeam(skill)
    local distance = self.target and (self.target:GetAbsOrigin() - self.entity:GetAbsOrigin()):Length2D() or 0
    local finalAbilityBehavior = self:GetAbilityBehavior(skill, distance, aoeRadius)

    -- 获取正确的channelTime
    local channelTime = self:getChannelTime(skill)

    local info = {
        skill = skill,
        targetType = skill:GetAbilityTargetType(),
        targetTeam = targetTeam,
        castPoint = self:GetRealCastPoint(skill),
        channelTime = channelTime,
        abilityBehavior = finalAbilityBehavior,
        abilityName = abilityName,
        castRange = castRange,
        aoeRadius = aoeRadius
    }
    
    if abilityName == "oracle_fortunes_end" then
        info.channelTime = 0
    end

    -- 辅助函数，用于将数字转换为对应的名称
    local function getBehaviorName(behavior)
        local names = {}
        for name, value in pairs(DOTA_ABILITY_BEHAVIOR) do
            if bit.band(behavior, value) ~= 0 then
                table.insert(names, "DOTA_ABILITY_BEHAVIOR_" .. name)
            end
        end
        return table.concat(names, ", ")
    end

    local function getTargetTypeName(targetType)
        local names = {}
        for name, value in pairs(DOTA_UNIT_TARGET) do
            if bit.band(targetType, value) ~= 0 then
                table.insert(names, "DOTA_UNIT_TARGET_" .. name)
            end
        end
        return table.concat(names, ", ")
    end

    local function getTargetTeamName(targetTeam)
        local names = {}
        for name, value in pairs(DOTA_UNIT_TARGET_TEAM) do
            if targetTeam == value then
                table.insert(names, "DOTA_UNIT_TARGET_TEAM_" .. name)
                break
            end
        end
        return table.concat(names, ", ")
    end

    self:log(string.format("技能: %s", info.abilityName))
    self:log(string.format("施法前摇时间 (GetCastPoint): %.2f", info.castPoint))
    self:log(string.format("技能引导时间 (GetChannelTime): %.2f", info.channelTime))
    self:log(string.format("施法距离 (GetCastRange): %.2f", info.castRange))
    self:log(string.format("作用范围 (aoeRadius): %.2f", info.aoeRadius))
    self:log(string.format("目标类型 (GetAbilityTargetType): %s", getTargetTypeName(info.targetType)))
    self:log(string.format("目标队伍 (GetSkillTargetTeam): %s", getTargetTeamName(info.targetTeam)))
    self:log(string.format("技能行为 (GetBehavior): %s", getBehaviorName(info.abilityBehavior)))
    if self.target then
        local realHeroStr = self.target:IsTempestDouble() and "(假)" or "(真)"
        self:log(string.format("目标单位: %s%s", self.target:GetUnitName(), realHeroStr))
    else
        self:log("目标单位: 无")
    end
    return info
end

function CommonAI:GetAbilityBehavior(skill, distance, aoeRadius)
    local abilityName = skill:GetAbilityName()
    local abilityBehavior = skill:GetBehavior()

    -- 定义常量
    local abilityBehaviorOverrides = {
        riki_tricks_of_the_trade = DOTA_ABILITY_BEHAVIOR.POINT,
        warlock_upheaval = DOTA_ABILITY_BEHAVIOR.POINT,
        death_prophet_carrion_swarm = DOTA_ABILITY_BEHAVIOR.POINT,
        sandking_burrowstrike = DOTA_ABILITY_BEHAVIOR.POINT,
        venomancer_plague_ward = DOTA_ABILITY_BEHAVIOR.POINT,
        earthshaker_enchant_totem = DOTA_ABILITY_BEHAVIOR.POINT,
        abyssal_underlord_firestorm = DOTA_ABILITY_BEHAVIOR.POINT,
        undying_tombstone = DOTA_ABILITY_BEHAVIOR.POINT,
        tidehunter_gush = DOTA_ABILITY_BEHAVIOR.POINT,
        phoenix_supernova = DOTA_ABILITY_BEHAVIOR.NO_TARGET,
        invoker_deafening_blast = DOTA_ABILITY_BEHAVIOR.NO_TARGET,
        luna_eclipse = DOTA_ABILITY_BEHAVIOR.POINT,
        earth_spirit_geomagnetic_grip = DOTA_ABILITY_BEHAVIOR.POINT,
        phoenix_icarus_dive = DOTA_ABILITY_BEHAVIOR.POINT,
        dragon_knight_breathe_fire = DOTA_ABILITY_BEHAVIOR.POINT,

        furion_wrath_of_nature = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET,
        dawnbreaker_solar_guardian = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET,
    }

    -- 检查ES跳距离并修改behavior
    local finalAbilityBehavior = abilityBehaviorOverrides[abilityName] or abilityBehavior

    if abilityName == "phoenix_supernova" and self.Ally and self.entity:HasScepter() then
        finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET
    end

    if abilityName == "invoker_sun_strike" and self.entity:HasScepter() then
        finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET
    end

    -- 只有当前技能是ES图腾时才检查
    if abilityName == "earthshaker_enchant_totem" then

        if distance < aoeRadius or self:containsStrategy(self.hero_strategy, "边走边图腾") then
            print("施法距离够了")
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET
        elseif self:containsStrategy(self.hero_strategy, "原地图腾") then
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET
        else
            print("图腾起飞")
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.POINT
        end

    end

    -- 只有当前技能是火雨时才检查
    if abilityName == "abyssal_underlord_firestorm" then
        if self:containsStrategy(self.hero_strategy, "对自己放火雨") then
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.TARGET
        end
    end

    -- 只有当前技能是松鼠技能时才检查
    if abilityName == "hoodwink_acorn_shot" then
        if self:containsStrategy(self.hero_strategy, "对地板放栗子") then
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.POINT
        end
    end

    -- 只有当前技能是树人技能时才检查
    if abilityName == "treant_leech_seed" then
        if self:containsStrategy(self.global_strategy, "防守策略") then
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.POINT
        end
    end

    -- 检查是否为 disruptor_thunder_strike
    if abilityName == "disruptor_thunder_strike" then
        local caster = skill:GetCaster()
        if caster:HasModifier("modifier_item_aghanims_shard") then
            finalAbilityBehavior = DOTA_ABILITY_BEHAVIOR.POINT
        end
    end

    return finalAbilityBehavior
end

function CommonAI:getChannelTime(skill)
    local channelTime = skill:GetChannelTime()
    
    if channelTime == 0 then
        local kv = skill:GetAbilityKeyValues()
        
        -- 检查AbilityValues中的channel_time
        if kv.AbilityValues and kv.AbilityValues.channel_time then
            if type(kv.AbilityValues.channel_time) == "table" then
                if kv.AbilityValues.channel_time.value then
                    channelTime = kv.AbilityValues.channel_time.value
                end
            else
                channelTime = kv.AbilityValues.channel_time
            end
        -- 如果没有找到channel_time，检查AbilityChannelTime
        elseif kv.AbilityChannelTime then
            if type(kv.AbilityChannelTime) == "table" then
                channelTime = kv.AbilityChannelTime.value or 0
            else
                channelTime = kv.AbilityChannelTime or 0
            end
        end

        -- 如果channelTime是一个字符串（例如"2.4 3.0 3.6 4.2"），我们需要解析它
        if type(channelTime) == "string" then
            local values = {}
            for value in channelTime:gmatch("%S+") do
                table.insert(values, tonumber(value))
            end
            channelTime = values[skill:GetLevel()] or values[#values]  -- 使用当前等级的值，如果没有则使用最后一个值
        end
    end

    return channelTime
end


function CommonAI:GetTargetInfo(target, entity)
    -- 更新目标最后已知位置
    self.lastKnownPosition = target:GetOrigin()

    -- 计算方向并存储在变量中
    local targetDirection = (target:GetOrigin() - entity:GetOrigin()):Normalized()

    -- 创建包含目标信息的表
    local info = {
        target = target,
        distance = (entity:GetOrigin() - target:GetOrigin()):Length2D(),
        targetPos = target:GetOrigin(),
        lastKnownPosition = self.lastKnownPosition,
        targetDirection = targetDirection
    }

    -- 检查目标是否有 GetUnitName 方法
    if target.GetUnitName then
        info.name = target:GetUnitName()
        -- 添加真假英雄的判断
        local realHeroStr = target:IsTempestDouble() and "(假)" or "(真)"
        info.name = info.name .. realHeroStr
    else
        info.name = "Unknown"
    end

    -- 记录日志
    self:log(string.format("目标名字: %s", info.name))
    self:log(string.format("目标距离: %.2f", info.distance))
    self:log(string.format("目标位置: %s", tostring(info.targetPos)))
    self:log(string.format("最后已知位置: %s", tostring(info.lastKnownPosition)))
    self:log(string.format("目标方向: %s", tostring(info.targetDirection)))

    return info
end


function CommonAI:FindBestItemToUse(entity, target)
    local maxCombinedRange = 0
    local maxCastRange = 0
    local bestItem = nil
    local bestAoERadius = 0
    local allItems = {}
    local heroName = entity:GetUnitName()
    local entityPosition
    local targetPosition

    self:CheckItemConditions(entity)


    -- 日志记录
    self:log("查找最佳物品开始 for entity: " .. (entity and entity:GetUnitName() or "nil"))

    if target then
        entityPosition = entity:GetAbsOrigin()
        targetPosition = target:GetAbsOrigin()
    end

    -- 检查物品栏位 1-8
    for i = 0, 8 do
        local item = entity:GetItemInSlot(i)
        if item then
            local itemName = item:GetAbilityName()

            table.insert(allItems, {name = itemName, priority = 3, index = i})

        end
    end

    -- 检查中立物品栏位 (16)
    local neutralItem = entity:GetItemInSlot(16)
    if neutralItem then
        local neutralItemName = neutralItem:GetAbilityName()
        table.insert(allItems, {name = neutralItemName, priority = 3, index = 16})

    end

    -- 按优先级排序
    table.sort(allItems, function(a, b) return a.priority < b.priority end)

    -- 遍历所有物品
    local potentialItems = {}
    for _, itemInfo in ipairs(allItems) do
        local item = entity:GetItemInSlot(itemInfo.index)
        
        if item then
            local itemName = item:GetAbilityName()
            if self.disabledItems and self:tableContains(self.disabledItems, itemName) then
                self:log(string.format("忽略禁用的物品 %s", itemName))
                goto continue
            end
            -- 检查物品是否可用
            if not self:IsItemReady(item) then
                self:log(string.format("物品 %s 不能使用", itemName))
                goto continue
            end

            -- 忽略被动物品
            if bit.band(item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_PASSIVE) ~= 0 then
                self:log(string.format("忽略被动物品 %s", itemName))
                goto continue
            end

            -- 忽略已经设置为自动施法或切换的物品
            if self.autoCastItems[itemName] or self.toggleItems[itemName] then
                self:log(string.format("忽略已经处理过的物品 %s", itemName))
                goto continue
            end

            local castRange = item:GetCastRange(entity:GetOrigin(), nil)
            local aoeRadius = self:GetItemAoeRadius(item)

            -- 处理自动施法物品
            if bit.band(item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AUTOCAST) ~= 0 then
                self:log(string.format("检测到自动施法物品: %s", itemName))
                
                if entity:IsMuted() and not entity:IsDebuffImmune() then
                    self:log("英雄处于沉默状态且无减益免疫，跳过物品切换")
                    goto continue
                end

                if not item:GetAutoCastState() then
                    item:ToggleAutoCast()
                    self.autoCastItems[itemName] = true
                    self:log(string.format("物品 %s 已设置为自动施法", itemName))
                end
                goto continue
            end

            -- 处理开关类物品
            if bit.band(item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_TOGGLE) ~= 0 then
                self:log(string.format("检测到开关类物品: %s", itemName))
                
                if entity:IsMuted() and not entity:IsDebuffImmune() then
                    self:log("英雄处于沉默状态且无减益免疫，跳过物品切换")
                    goto continue
                end

                if not item:GetToggleState() then
                    item:ToggleAbility()
                    self.toggleItems[itemName] = true
                    self:log(string.format("物品 %s 已开启", itemName))
                end
                goto continue
            end

            local isInRange = true
            local targetTeam = self:GetSkillTargetTeam(item)


            if bit.band(targetTeam, DOTA_UNIT_TARGET_TEAM_FRIENDLY) ~= 0 and self.Ally then
                local distanceToTarget = (self.Ally:GetAbsOrigin() - entityPosition):Length2D()
                if bit.band(item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
                    isInRange = distanceToTarget <= (castRange + aoeRadius)
                elseif bit.band(item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
                    isInRange = distanceToTarget <= castRange
                elseif bit.band(item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
                    isInRange = distanceToTarget <= aoeRadius
                end
            -- 否则判断敌方目标
            elseif target then
                local distanceToTarget = (targetPosition - entityPosition):Length2D()
                if bit.band(item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
                    isInRange = distanceToTarget <= (castRange + aoeRadius)
                elseif bit.band(item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
                    isInRange = distanceToTarget <= castRange
                elseif bit.band(item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
                    isInRange = distanceToTarget <= aoeRadius
                end
            end
            -- 所有物品都加入待选列表
            table.insert(potentialItems, {
                item = item,
                castRange = castRange,
                aoeRadius = aoeRadius,
                itemName = itemName
            })

            ::continue::
        end
    end

    -- 在所有待选物品中筛选
    for _, itemData in ipairs(potentialItems) do
        local item = itemData.item
        local itemName = itemData.itemName
        local castRange = itemData.castRange
        local aoeRadius = itemData.aoeRadius

        -- 如果物品没有作用范围和施法范围，且是无目标使用物品，则无条件将其作为best物品
        if castRange == 0 and aoeRadius == 0 and 
        bit.band(item:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
            bestItem = item
            maxCastRange = 0
            bestAoERadius = 0
            if DEBUG_MODE == 1 then
                self:log(string.format("物品 %s 被无条件选择", itemName))
            end
            break
        end

        -- 更新最佳物品（基于施法距离）
        local combinedRange = castRange + aoeRadius
        if combinedRange > maxCombinedRange then
            maxCombinedRange = combinedRange
            bestItem = item
            maxCastRange = castRange
            bestAoERadius = aoeRadius
        end
    end

    if DEBUG_MODE == 1 and bestItem then
        self:log(string.format("选择的最佳物品是 %s，施法距离为 %d", bestItem:GetAbilityName(), maxCastRange))
    elseif DEBUG_MODE == 1 then
        self:log("没有可用的物品")
    end
    
    if bestItem then
        self:log(string.format("物品 %s 的作用范围为 %d", bestItem:GetAbilityName(), bestAoERadius))
        self:log(string.format("物品 %s 的施法距离为 %d", bestItem:GetAbilityName(), maxCastRange))
        return bestItem, maxCastRange, bestAoERadius
    else
        self:log("没有物品了")
        return nil, 0, 0
    end
end


-- 更新禁用技能列表


function CommonAI:FindBestAbilityToUse(entity, target)
    -- 基础初始化
    local maxCombinedRange = 0
    local maxCastRange = 0
    local bestSkill = nil
    local bestAoERadius = 0
    local allSkills = {}
    local heroName = entity:GetUnitName()
    
    -- 日志记录
    self:log("查找最大范围技能开始 for entity: " .. (entity and entity:GetUnitName() or "nil"))
    
    -- 检查禁用技能列表
    self:CheckSkillConditions(entity, heroName)
    
    -- 更新基于策略的技能优先级
    self:UpdateSkillPriorityBasedOnStrategy()




    if target then
        entityPosition = entity:GetAbsOrigin()
        targetPosition = target:GetAbsOrigin()
        
        -- 使用原生API获取技能索引
        if self.highPrioritySkills[heroName] then
            for index, skillName in ipairs(self.highPrioritySkills[heroName]) do
                local adjustedPriority = 1 + (index - 1) * 0.1
                local ability = entity:FindAbilityByName(skillName)
                if ability then
                    table.insert(allSkills, {
                        name = skillName, 
                        priority = adjustedPriority, 
                        index = ability:GetAbilityIndex()  -- 使用GetAbilityIndex原生方法
                    })
                end
            end
        end
    
        -- 添加中等优先级技能（使用相同方法）
        if self.mediumPrioritySkills[heroName] then
            for index, skillName in ipairs(self.mediumPrioritySkills[heroName]) do
                local adjustedPriority = 2 + (index - 1) * 0.1
                local ability = entity:FindAbilityByName(skillName)
                if ability then
                    table.insert(allSkills, {
                        name = skillName,
                        priority = adjustedPriority,
                        index = ability:GetAbilityIndex()  -- 使用原生方法获取索引
                    })
                end
            end
        end
    end
    -- 从 allSkills 中移除不需要的技能
    for i = #allSkills, 1, -1 do
        local skill = allSkills[i]
        if self:shouldRemoveAbility(skill.index) then
            table.remove(allSkills, i)
        end
    end
    
    -- 添加普通技能
    for i = 0, entity:GetAbilityCount() - 1 do
        local ability = entity:GetAbilityByIndex(i)  -- 使用GetAbilityByIndex原生方法
        if ability then
            local abilityName = ability:GetAbilityName()
            if not self:shouldRemoveAbility(ability:GetAbilityIndex()) and  -- 使用GetAbilityIndex
               not self:IsInPriorityLists(abilityName, heroName) then
                table.insert(allSkills, {
                    name = abilityName, 
                    priority = 3, 
                    index = ability:GetAbilityIndex()  -- 直接获取技能索引
                })
            end
        end
    end
    
    -- 按优先级排序
    table.sort(allSkills, function(a, b) return a.priority < b.priority end)
    -- 遍历所有技能
    local potentialSkills = {}
    for _, skillInfo in ipairs(allSkills) do
        
        local ability
        if skillInfo.index then
            ability = entity:GetAbilityByIndex(skillInfo.index)
        else
            ability = entity:FindAbilityByName(skillInfo.name)
        end

        if ability then
            local abilityName = ability:GetAbilityName()
            if self.disabledSkills[heroName] and self:IsDisabledSkill(abilityName, heroName) then
                self:log(string.format("忽略禁用的技能 %s", abilityName))
                goto continue
            end
            if self.target ~= nil then  -- 只在target存在时才进行后续判断
                -- 再次检查target是否有效
                if IsValidEntity(self.target) then
                    -- 获取技能的目标队伍类型
                    local targetTeam = self:GetSkillTargetTeam(ability)
                    -- 只有敌方技能才进行非英雄单位的判断
                    if targetTeam == DOTA_UNIT_TARGET_TEAM.ENEMY then
                        if not self.target:IsHero() and bit.band(ability:GetAbilityTargetFlags(), DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO) ~= 0 then
                            self:log(string.format("技能 %s 不能对非英雄单位使用", abilityName))
                            goto continue
                        end
                    end
                else
                    self:log("目标实体无效")
                    goto continue
                end
            end

            -- 忽略名称为 generic_hidden 或以 special_bonus 开头的技能
            if abilityName == "generic_hidden" or abilityName:find("^special_bonus") then
                self:log(string.format("忽略技能 %s", abilityName))
                goto continue
            end

            -- 忽略被动技能
            if bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_PASSIVE) ~= 0 then
                self:log(string.format("忽略被动技能 %s", abilityName))
                goto continue
            end

            -- 检查技能是否可用
            if not self:IsSkillReady(ability) then
                self:log(string.format("技能 %s 不能使用", abilityName))
                goto continue
            end

            -- 忽略已经设置为自动施法或切换的技能
            if self.autoCastSkills[abilityName] or self.toggleSkills[abilityName] then
                self:log(string.format("忽略已经处理过的技能 %s", abilityName))
                goto continue
            end
            

            local castRange = self:GetSkillCastRange(entity, ability)
            local aoeRadius = self:GetSkillAoeRadius(ability)


            if ability:IsHidden() then
                self:log(string.format("想放的技能 %s 被隐藏了", ability:GetName()))
                local invokerSkills = {
                    invoker_cold_snap = {Q = 3, W = 0, E = 0},
                    invoker_ghost_walk = {Q = 2, W = 1, E = 0},
                    invoker_tornado = {Q = 1, W = 2, E = 0},
                    invoker_emp = {Q = 0, W = 3, E = 0},
                    invoker_alacrity = {Q = 0, W = 2, E = 1},
                    invoker_chaos_meteor = {Q = 0, W = 1, E = 2},
                    invoker_sun_strike = {Q = 0, W = 0, E = 3},
                    invoker_forge_spirit = {Q = 1, W = 0, E = 2},
                    invoker_ice_wall = {Q = 2, W = 0, E = 1},
                    invoker_deafening_blast = {Q = 1, W = 1, E = 1}
                }

                -- 检查当前技能是否是卡尔的技能之一
                if heroName == "npc_dota_hero_invoker" and invokerSkills[abilityName] then
                    -- 检查是否已有两个可用的召唤技能
                    local availableSkills = 0
                    for skillName, _ in pairs(invokerSkills) do
                        local skill = entity:FindAbilityByName(skillName)
                        if skill and not skill:IsHidden() and self:IsSkillReady(skill) then
                            availableSkills = availableSkills + 1
                            if availableSkills >= 2 then
                                goto continue
                            end
                        end
                    end
                
                    self:log(string.format("检测到卡尔技能：%s", abilityName))
                    
                    local currentOrbs = {
                        Q = #entity:FindAllModifiersByName("modifier_invoker_quas_instance"),
                        W = #entity:FindAllModifiersByName("modifier_invoker_wex_instance"),
                        E = #entity:FindAllModifiersByName("modifier_invoker_exort_instance")
                    }
                    
                    self:log(string.format("当前元素球状态：Q:%d, W:%d, E:%d", currentOrbs.Q, currentOrbs.W, currentOrbs.E))
                
                    local requiredOrbs = invokerSkills[abilityName]
                    self:log(string.format("技能 %s 需要的元素球：Q:%d, W:%d, E:%d", abilityName, requiredOrbs.Q, requiredOrbs.W, requiredOrbs.E))
                
                    -- 检查是否需要添加新的元素
                    for element, count in pairs(requiredOrbs) do
                        if currentOrbs[element] < count then
                            self:log(string.format("缺少元素：%s，当前数量：%d，需要数量：%d", element, currentOrbs[element], count))
                            local elementAbility
                            if element == "Q" then
                                elementAbility = "invoker_quas"
                            elseif element == "W" then
                                elementAbility = "invoker_wex"
                            elseif element == "E" then
                                elementAbility = "invoker_exort"
                            end
                            ability = entity:FindAbilityByName(elementAbility)
                            self:log(string.format("准备释放技能：%s", elementAbility))
                            return ability, 0, 0
                        end
                    end
                
                    -- 所有元素都齐全，释放invoke
                    local invokeAbility = entity:FindAbilityByName("invoker_invoke")
                    if self:IsSkillReady(invokeAbility) then
                        self:log("所有需要的元素球都已准备就绪，准备释放 invoke")
                        return invokeAbility, 0, 0
                    else
                        goto continue
                    end
                else
                    self:log(string.format("跳过隐藏的技能 %s", abilityName))
                    goto continue
                end
            end


            -- 处理自动施法技能
            if bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_AUTOCAST) ~= 0 and abilityName ~= "ogre_magi_bloodlust" then
                self:log(string.format("检测到自动施法技能: %s", abilityName))
                
                -- 检查是否处于沉默且没有减益免疫
                if entity:IsSilenced() and not entity:IsDebuffImmune() then
                    self:log("英雄处于沉默状态且无减益免疫，跳过技能切换")
                    goto continue
                end
            
                if abilityName == "enchantress_impetus" then
                    ability:ToggleAutoCast()
                    self:log(string.format("技能 %s 已设置为自动施法", abilityName))
                else
                    if not ability:GetAutoCastState() then
                        ability:ToggleAutoCast()
                        self.autoCastSkills[abilityName] = true
                        self:log(string.format("技能 %s 已设置为自动施法", abilityName))
                    end
                end
                goto continue
            end

            -- 处理开关类技能
            -- 在文件开头定义技能表
            local TOGGLE_SKILLS = {
                -- 直接切换的技能（不需要特殊条件）
                direct_toggle = {
                    ["morphling_morph_str"] = true,
                    ["morphling_morph_agi"] = true,
                    ["medusa_split_shot"] = true,
                    ["mars_bulwark"] = true,
                    ["wisp_spirits_in"] = true,
                    ["wisp_spirits_out"] = true,
                },
                
                -- 需要目标在范围内才开启的技能
                range_dependent = {
                    ["leshrac_pulse_nova"] = 1200,  -- 值表示所需范围
                },
                
                -- 默认开启的技能（其他所有toggle技能）
                default_on = true
            }

            -- 修改原来的代码
            if bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_TOGGLE) ~= 0 then
                self:log(string.format("检测到开关类技能: %s", abilityName))
                
                -- 检查是否处于沉默且没有减益免疫
                if entity:IsSilenced() and not entity:IsDebuffImmune() then
                    self:log("英雄处于沉默状态且无减益免疫，跳过技能切换")
                    goto continue
                end
                
                -- 处理直接切换的技能
                if TOGGLE_SKILLS.direct_toggle[abilityName] then
                    ability:ToggleAbility()
                    self:log(string.format("技能 %s 已切换状态", abilityName))
                -- 处理需要检查范围的技能
                elseif TOGGLE_SKILLS.range_dependent[abilityName] then
                    local required_range = TOGGLE_SKILLS.range_dependent[abilityName]
                    if target and self:IsInRange(target, required_range) then
                        if not ability:GetToggleState() then
                            ability:ToggleAbility()
                            self.toggleSkills[abilityName] = true
                            self:log(string.format("技能 %s 已开启", abilityName))
                        end
                    end
                -- 处理默认开启的技能
                else
                    if not ability:GetToggleState() then
                        ability:ToggleAbility()
                        self.toggleSkills[abilityName] = true
                        self:log(string.format("技能 %s 已开启", abilityName))
                    end
                end
                goto continue
            end




            
            local isInRange = true
            local targetTeam = self:GetSkillTargetTeam(ability)

            -- 如果是友方技能且有队友，用队友位置
            if bit.band(targetTeam, DOTA_UNIT_TARGET_TEAM_FRIENDLY) ~= 0 and self.Ally then
                local distanceToTarget = (self.Ally:GetAbsOrigin() - entityPosition):Length2D()
                if bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
                    isInRange = distanceToTarget <= (castRange + aoeRadius)
                elseif bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
                    isInRange = distanceToTarget <= castRange
                elseif bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
                    isInRange = distanceToTarget <= aoeRadius
                end
            -- 否则判断敌方目标
            elseif target then
                local distanceToTarget = (targetPosition - entityPosition):Length2D()
                if bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
                    isInRange = distanceToTarget <= (castRange + aoeRadius)
                elseif bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
                    isInRange = distanceToTarget <= castRange
                elseif bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
                    if castRange == 0 and aoeRadius == 0 then
                        isInRange = true
                    else
                        isInRange = distanceToTarget <= aoeRadius
                    end
                end
            end


            -- 如果是最高优先级技能且在范围内，直接返回
            if skillInfo.priority < 2 and isInRange then
                self:log(string.format("选择了最高优先级的技能 %s，施法距离为 %d", ability:GetAbilityName(), castRange))
                return ability, castRange, aoeRadius
            end

            -- 如果是次优先级技能且在范围内，直接返回
            if skillInfo.priority < 3 and isInRange then
                self:log(string.format("选择了第二优先级的技能 %s，施法距离为 %d", ability:GetAbilityName(), castRange))
                return ability, castRange, aoeRadius
            end

            -- 所有技能都加入待选列表（包括超出范围的高优先级技能）
            table.insert(potentialSkills, {
                ability = ability,
                castRange = castRange,
                aoeRadius = aoeRadius,
                abilityName = abilityName
            })

            ::continue::

        end
    end

    
    -- 在所有待选技能中筛选
    for _, skillData in ipairs(potentialSkills) do
        local ability = skillData.ability
        local abilityName = skillData.abilityName
        local castRange = skillData.castRange
        local aoeRadius = skillData.aoeRadius

        -- 处理自身施法技能
        if self:isSelfCastAbility(abilityName) and not self:isSelfCastAbilityWithRange(abilityName) then
            if DEBUG_MODE == 1 then
                self:log(string.format("技能 %s 是对自己释放但不需要选择范围的技能，优先选择", abilityName))
            end
            return ability, castRange, aoeRadius
        end

        -- 特殊处理 pugna_decrepify
        if not target and abilityName == "pugna_decrepify" then
            return ability, castRange, aoeRadius
        end

        -- 如果技能是大招，没有作用范围和施法范围，且是无目标施法技能，则无条件将其作为best技能
        if castRange == 0 and aoeRadius == 0 and 
        bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
            bestSkill = ability
            maxCastRange = 0
            bestAoERadius = 0
            if DEBUG_MODE == 1 then
                self:log(string.format("技能 %s 作为大招被无条件选择", abilityName))
            end
            return bestSkill, maxCastRange, bestAoERadius
        end

        -- 更新最佳技能（基于施法距离）
        local combinedRange = castRange + aoeRadius
        if combinedRange > maxCombinedRange then
            maxCombinedRange = combinedRange
            bestSkill = ability
            maxCastRange = castRange
            bestAoERadius = aoeRadius
        end
    end

    if DEBUG_MODE == 1 and bestSkill then
        self:log(string.format("选择的最佳技能是 %s，施法距离为 %d", bestSkill:GetAbilityName(), maxCastRange))
    elseif DEBUG_MODE == 1 then
        self:log("没有可用的技能")
    end
    

    local bestItem, itemCastRange, itemAoERadius = self:FindBestItemToUse(entity, target)
    local targetDistance = (target:GetAbsOrigin() - entity:GetAbsOrigin()):Length2D()
    local itemTotalRange = itemCastRange + itemAoERadius
    if bestItem and itemTotalRange >= targetDistance then
        bestSkill = bestItem
        maxCastRange = itemCastRange
        bestAoERadius = itemAoERadius
        return bestSkill, maxCastRange, bestAoERadius
    end
    
    if not bestSkill and not bestItem then
        return nil, 0, 0
    elseif not bestSkill then
        bestSkill = bestItem
        maxCastRange = itemCastRange  
        bestAoERadius = itemAoERadius
    elseif not bestItem then
        -- bestSkill的数据保持不变
    else
        -- 两边都有数据时比较
        local skillTotalRange = maxCastRange + bestAoERadius
    
        -- 否则比较totalRange,选择较大的
        if itemTotalRange > skillTotalRange then
            bestSkill = bestItem
            maxCastRange = itemCastRange
            bestAoERadius = itemAoERadius
        end
    end

    if bestSkill then
        self:log(string.format("技能 %s 的作用范围为 %d", bestSkill:GetAbilityName(), bestAoERadius))
        self:log(string.format("技能 %s 的施法距离为 %d", bestSkill:GetAbilityName(), maxCastRange))
        return bestSkill, maxCastRange, bestAoERadius
    else
        if heroName == "npc_dota_hero_invoker" then
            -- 获取当前三个元素数量
            local currentOrbs = {
                Q = #self.entity:FindAllModifiersByName("modifier_invoker_quas_instance"),
                W = #self.entity:FindAllModifiersByName("modifier_invoker_wex_instance"),
                E = #self.entity:FindAllModifiersByName("modifier_invoker_exort_instance")
            }
    
            -- 检查策略和对应元素球
            local targetElement
            if self:containsStrategy(self.hero_strategy, "常驻冰球") then
                targetElement = "Q"
            elseif self:containsStrategy(self.hero_strategy, "常驻雷球") then
                targetElement = "W"
            elseif self:containsStrategy(self.hero_strategy, "常驻火球") then
                targetElement = "E"
            else
                targetElement = "E"  -- 默认保持火球
            end
    
            -- 如果对应元素球不够3个，则释放对应技能
            if currentOrbs[targetElement] < 3 then
                local elementAbilityName
                if targetElement == "Q" then
                    elementAbilityName = "invoker_quas"
                elseif targetElement == "W" then
                    elementAbilityName = "invoker_wex"
                elseif targetElement == "E" then
                    elementAbilityName = "invoker_exort"
                end
    
                local elementAbility = self.entity:FindAbilityByName(elementAbilityName)
                if elementAbility then
                    return elementAbility, 0, 0
                end
            end
    
            -- 如果已经有3个对应元素球了，返回nil
            return nil, 0, 0
        end
    
        self:log("没有技能了")
        return nil, 0, 0
    end
end

function CommonAI:IsInPriorityLists(abilityName, heroName)
    if self.highPrioritySkills[heroName] and self:tableContains(self.highPrioritySkills[heroName], abilityName) then
        self:log(string.format("技能 %s 在高优先级列表中", abilityName))
        return true
    end
    if self.mediumPrioritySkills[heroName] and self:tableContains(self.mediumPrioritySkills[heroName], abilityName) then
        self:log(string.format("技能 %s 在中优先级列表中", abilityName))
        return true
    end
    --self:log(string.format("技能 %s 不在任何优先级列表中", abilityName))
    return false
end

function CommonAI:IsInRange(target, range)
    local distance = (self.entity:GetOrigin() - target:GetOrigin()):Length2D()
    if DEBUG_MODE then
        self:log(string.format("检查是否在范围内：目标距离: %.2f，施法距离: %.2f", distance, range))
    end
    return distance <= range
end


function CommonAI:CastVectorSkillToUnitAndPoint(caster, ability, target, targetPoint)
    -- 检查施法者是否存在
    if not caster then
        self:log("施法者为nil")
        return
    end

    -- 检查技能是否存在
    if not ability then
        self:log("技能为nil")
        return
    end

    -- 检查目标是否存在
    if not target then
        self:log("目标为nil")
        return
    end

    -- 检查目标点是否有效
    if not targetPoint then
        self:log("目标点为nil")
        return
    end

    self:log("施法者: " .. caster:GetUnitName())
    self:log("技能: " .. ability:GetAbilityName())
    self:log("目标: " .. target:GetUnitName())
    self:log("目标点: " .. tostring(targetPoint))

    -- 获取技能索引
    local abilityIndex = ability:GetEntityIndex()
    self:log("技能索引: " .. abilityIndex)

    local order1 = {
        UnitIndex = caster:entindex(),
        OrderType = DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION,
        TargetIndex = target:entindex(), -- may not be necessary
        AbilityIndex = abilityIndex,
        Position = targetPoint, -- target AoE point
    }
    local order2 = {
        UnitIndex = caster:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
        TargetIndex = target:entindex(), -- unit to leap to
        AbilityIndex = abilityIndex,
        Position = targetPoint, -- may not be necessary
    }
    ExecuteOrderFromTable(order1)
    ExecuteOrderFromTable(order2)
end


-- 释放矢量技能，第一个目标是地点，第二个目标也是地点
function CommonAI:CastVectorSkillToTwoPoints(caster, ability, startPoint, endPoint)
    self:log("释放两个地点的矢量技能")
    -- 检查施法者是否存在
    if not caster then
        self:log("施法者为nil")
        return
    end

    -- 检查技能是否存在
    if not ability then
        self:log("技能为nil")
        return
    end

    -- 检查起始点是否有效
    if not startPoint then
        self:log("起始点为nil")
        return
    end

    -- 检查结束点是否有效
    if not endPoint then
        self:log("结束点为nil")
        return
    end

    self:log("施法者: " .. caster:GetUnitName())
    self:log("技能: " .. ability:GetAbilityName())
    self:log("起始点: " .. tostring(startPoint))
    self:log("结束点: " .. tostring(endPoint))

    -- 获取技能索引
    local abilityIndex = ability:GetEntityIndex()
    self:log("技能索引: " .. abilityIndex)

    local order1 = {
        UnitIndex = caster:entindex(),
        OrderType = DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION,
        TargetIndex = caster:entindex(), -- no target unit
        AbilityIndex = abilityIndex,
        Position = endPoint, -- first target point
    }
    local order2 = {
        UnitIndex = caster:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        TargetIndex = caster:entindex(), -- no target unit
        AbilityIndex = abilityIndex,
        Position = startPoint, -- second target point
    }
    ExecuteOrderFromTable(order1)
    ExecuteOrderFromTable(order2)
end
