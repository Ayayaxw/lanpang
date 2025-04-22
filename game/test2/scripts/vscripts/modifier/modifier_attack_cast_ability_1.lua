modifier_attack_cast_ability_1 = class({})

function modifier_attack_cast_ability_1:IsHidden()
    return false
end

function modifier_attack_cast_ability_1:IsDebuff()
    return false
end

function modifier_attack_cast_ability_1:IsPurgable()
    return false
end

-- 技能队列相关变量

-- 特殊技能表，记录需要特殊处理的技能


function modifier_attack_cast_ability_1:OnCreated()
    if not IsServer() then return end
    -- 启动定时器处理队列

    modifier_attack_cast_ability_1.special_abilities = {
        -- 技能名称 = 处理方式
        ["morphling_waveform"] = "farthest_enemy" -- 优先选择最远的敌人
        -- 可以在这里添加更多特殊技能
    }
    modifier_attack_cast_ability_1.spell_queue = {}
    modifier_attack_cast_ability_1.current_frame_count = 0
    modifier_attack_cast_ability_1.current_time = 0
    modifier_attack_cast_ability_1.max_spells_per_frame = 5
    modifier_attack_cast_ability_1.frame_duration = 0.01 -- 约30帧每秒
    modifier_attack_cast_ability_1.queue_active = false
    CommonAI:Ini_SkillBehavior()
    CommonAI:Ini_SkillTargetTeam()
    self:StartIntervalThink(0.01) -- 大约1帧的时间
end

function modifier_attack_cast_ability_1:OnIntervalThink()
    if not IsServer() then return end
    self:ProcessQueue()
end

function modifier_attack_cast_ability_1:ProcessQueue()
    if #modifier_attack_cast_ability_1.spell_queue == 0 then
        return
    end
    
    -- 获取当前游戏时间
    local current_time = GameRules:GetGameTime()
    
    -- 检查是否是新的帧时间
    local time_diff = current_time - modifier_attack_cast_ability_1.current_time
    if time_diff >= modifier_attack_cast_ability_1.frame_duration then
        modifier_attack_cast_ability_1.current_time = current_time
        modifier_attack_cast_ability_1.current_frame_count = 0
    end
    
    -- 处理队列中的技能，每帧最多处理max_spells_per_frame个
    local spells_processed = 0
    local i = 1
    while i <= #modifier_attack_cast_ability_1.spell_queue and 
          spells_processed < modifier_attack_cast_ability_1.max_spells_per_frame and
          modifier_attack_cast_ability_1.current_frame_count < modifier_attack_cast_ability_1.max_spells_per_frame do
        
        local spell_data = modifier_attack_cast_ability_1.spell_queue[i]
        
        -- 检查目标是否已死亡或无效
        if spell_data.target and (spell_data.target:IsNull() or not spell_data.target:IsAlive()) then
            -- 如果目标已死亡，尝试找周围300码内的新目标
            local parent = spell_data.parent
            local targetTeam = spell_data.targetTeam
            local behavior = spell_data.behavior
            local lastPosition = spell_data.target:IsNull() and parent:GetAbsOrigin() or spell_data.target:GetAbsOrigin()
            
            -- 根据不同类型的技能处理目标死亡情况
            if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
                -- 无目标技能直接施放
                table.remove(modifier_attack_cast_ability_1.spell_queue, i)
                self:CastQueuedSpell(spell_data)
                spells_processed = spells_processed + 1
                modifier_attack_cast_ability_1.current_frame_count = modifier_attack_cast_ability_1.current_frame_count + 1
            elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
                -- 点目标技能，对着死亡目标的位置施放
                spell_data.lastPosition = lastPosition  -- 保存死亡目标的位置
                table.remove(modifier_attack_cast_ability_1.spell_queue, i)
                self:CastQueuedSpell(spell_data)
                spells_processed = spells_processed + 1
                modifier_attack_cast_ability_1.current_frame_count = modifier_attack_cast_ability_1.current_frame_count + 1
            elseif targetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
                -- 友方技能目标死亡时，转为对自己施放
                spell_data.target = parent
                table.remove(modifier_attack_cast_ability_1.spell_queue, i)
                self:CastQueuedSpell(spell_data)
                spells_processed = spells_processed + 1
                modifier_attack_cast_ability_1.current_frame_count = modifier_attack_cast_ability_1.current_frame_count + 1
            elseif targetTeam == DOTA_UNIT_TARGET_TEAM_ENEMY or targetTeam == DOTA_UNIT_TARGET_TEAM_BOTH then
                -- 敌方技能寻找新目标
                local nearbyUnits = FindUnitsInRadius(
                    parent:GetTeamNumber(),
                    lastPosition,
                    nil,
                    500,
                    DOTA_UNIT_TARGET_TEAM_ENEMY, 
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                
                -- 如果找到新目标，更新目标并施法
                if #nearbyUnits > 0 then
                    spell_data.target = nearbyUnits[RandomInt(1, #nearbyUnits)]
                    table.remove(modifier_attack_cast_ability_1.spell_queue, i)
                    self:CastQueuedSpell(spell_data)
                    
                    spells_processed = spells_processed + 1
                    modifier_attack_cast_ability_1.current_frame_count = modifier_attack_cast_ability_1.current_frame_count + 1
                else
                    -- 没找到新目标，移除此技能
                    table.remove(modifier_attack_cast_ability_1.spell_queue, i)
                end
            else
                -- 其他情况，移除此技能
                table.remove(modifier_attack_cast_ability_1.spell_queue, i)
            end
        else
            -- 目标有效，正常施法
            table.remove(modifier_attack_cast_ability_1.spell_queue, i)
            self:CastQueuedSpell(spell_data)
            
            spells_processed = spells_processed + 1
            modifier_attack_cast_ability_1.current_frame_count = modifier_attack_cast_ability_1.current_frame_count + 1
        end
    end
end

function modifier_attack_cast_ability_1:CastQueuedSpell(spell_data)
    local parent = spell_data.parent
    local ability = spell_data.ability
    local target = spell_data.target
    local behavior = spell_data.behavior
    local targetTeam = spell_data.targetTeam
    local abilityName = spell_data.abilityName
    
    -- 检查实体是否有效
    if not parent or parent:IsNull() or not ability or ability:IsNull() then
        return
    end
    
    if spell_data.is_self_cast then
        parent:SetCursorCastTarget(parent)
        ability:OnSpellStart()
        return
    end
    
    if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
        ability:OnSpellStart()
    elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
        if targetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
            parent:SetCursorPosition(parent:GetAbsOrigin())
        else
            -- 使用目标位置或保存的死亡位置
            local position = (target and not target:IsNull()) and target:GetAbsOrigin() or spell_data.lastPosition
            parent:SetCursorPosition(position)
        end
        ability:OnSpellStart()
    elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
        if targetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
            parent:SetCursorCastTarget(parent)
        else
            -- 检查目标有效性
            if not target or target:IsNull() then
                return
            end
            parent:SetCursorCastTarget(target)
        end
        ability:OnSpellStart()
    else
        -- 检查目标有效性
        if not target or target:IsNull() then
            return
        end
        parent:SetCursorCastTarget(target)
        ability:OnSpellStart()
    end
end

function modifier_attack_cast_ability_1:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_attack_cast_ability_1:OnAttackLanded(params)
    if not IsServer() then return end
    
    -- 确保是单位自己的攻击
    if params.attacker ~= self:GetParent() then return end
    
    local parent = self:GetParent()
    local target = params.target
    
    -- 获取单位的第一个技能（index 0）
    local ability = CommonAI:GetRandomFirstSkill(parent)
    if not ability or ability:IsNull() or ability:GetLevel() < 1 or ability:IsPassive() == true then
        return
    end
    
    -- 获取技能名称
    local abilityName = ability:GetAbilityName()
    local behavior = CommonAI:GetSkill_Behavior(ability)
    local targetTeam = CommonAI:GetSkillTargetTeam(ability)
    local is_self_cast = CommonAI:isSelfCastAbility(abilityName)
    
    -- 检查目标是否是敌对单位，如果是就从周围300范围内随机选择一个目标
    local finalTarget = target
    print("技能targetTeam: " .. targetTeam)
    -- 根据不同技能类型处理目标选择
    if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
        -- 无目标技能不需要设置目标
        print("无目标技能")
        finalTarget = nil
    elseif targetTeam == DOTA_UNIT_TARGET_TEAM.FRIENDLY then
        print("友方技能")
        -- 友方技能默认对自己施放
        finalTarget = parent
    else
        -- 检查是否是特殊处理的技能
        print("技能名称: " .. abilityName)
        local special_behavior = modifier_attack_cast_ability_1.special_abilities[abilityName]
        
        -- 敌方技能寻找周围300码范围的敌人
        local nearbyUnits = FindUnitsInRadius(
            parent:GetTeamNumber(),
            target:GetAbsOrigin(),
            nil,
            300,
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )
        
        -- 如果找到单位，根据技能的特殊处理方式选择目标
        if #nearbyUnits > 0 then
            if special_behavior == "farthest_enemy" then
                -- 选择最远的敌人
                print("选择最远的敌人")
                local farthestDistance = -1
                local farthestTarget = nil
                local parentPos = parent:GetAbsOrigin()
                
                for _, unit in pairs(nearbyUnits) do
                    local distance = (unit:GetAbsOrigin() - parentPos):Length2D()
                    if distance > farthestDistance then
                        farthestDistance = distance
                        farthestTarget = unit
                    end
                end
                
                finalTarget = farthestTarget
            else
                -- 默认随机选择一个目标
                finalTarget = nearbyUnits[RandomInt(1, #nearbyUnits)]
            end
        end
    end
    
    -- 将技能信息添加到队列
    table.insert(modifier_attack_cast_ability_1.spell_queue, {
        parent = parent,
        ability = ability,
        target = finalTarget,
        behavior = behavior,
        targetTeam = targetTeam,
        abilityName = abilityName,
        is_self_cast = is_self_cast
    })
end
