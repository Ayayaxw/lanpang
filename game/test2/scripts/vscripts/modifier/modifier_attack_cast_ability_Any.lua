modifier_attack_cast_ability_Any = class({})

function modifier_attack_cast_ability_Any:IsHidden()
    return false
end

function modifier_attack_cast_ability_Any:IsDebuff()
    return false
end

function modifier_attack_cast_ability_Any:IsPurgable()
    return false
end

function modifier_attack_cast_ability_Any:OnCreated()
    if not IsServer() then return end
    -- 启动定时器处理队列

    -- 定义特殊技能处理方式（共享是可以的，因为这只是规则定义）
    if not modifier_attack_cast_ability_Any.special_abilities then
        modifier_attack_cast_ability_Any.special_abilities = {
            -- 技能名称 = 处理方式
            ["morphling_waveform"] = "farthest_enemy" -- 优先选择最远的敌人
            -- 可以在这里添加更多特殊技能
        }
    end
    
    -- 每个实例拥有自己的队列和计数器
    self.spell_queue = {}
    self.current_frame_count = 0
    self.current_time = 0
    if self:GetParent():GetUnitName() == "npc_dota_hero_sand_king" then
        self.max_spells_per_frame = 1
    else
        self.max_spells_per_frame = 5
    end
    self.frame_duration = 0.01 -- 约30帧每秒
    
    self:StartIntervalThink(0.01) -- 大约1帧的时间
end

function modifier_attack_cast_ability_Any:OnIntervalThink()
    if not IsServer() then return end
    self:ProcessQueue()
end

function modifier_attack_cast_ability_Any:ProcessQueue()
    if #self.spell_queue == 0 then
        return
    end
    
    -- 获取当前游戏时间
    local current_time = GameRules:GetGameTime()
    
    -- 检查是否是新的帧时间
    local time_diff = current_time - self.current_time
    if time_diff >= self.frame_duration then
        self.current_time = current_time
        self.current_frame_count = 0
    end
    
    -- 处理队列中的技能，每帧最多处理max_spells_per_frame个
    local spells_processed = 0
    local i = 1
    while i <= #self.spell_queue and 
          spells_processed < self.max_spells_per_frame and
          self.current_frame_count < self.max_spells_per_frame do
        
        local spell_data = self.spell_queue[i]
        
        -- 检查目标是否已死亡或无效
        if spell_data.target and (spell_data.target:IsNull() or not spell_data.target:IsAlive()) then
            -- 如果目标已死亡，尝试找周围300码内的新目标
            local parent = spell_data.parent
            local targetTeam = spell_data.targetTeam
            local targetType = spell_data.targetType
            local behavior = spell_data.behavior
            local lastPosition = spell_data.target:IsNull() and parent:GetAbsOrigin() or spell_data.target:GetAbsOrigin()
            
            -- 根据不同类型的技能处理目标死亡情况
            if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
                -- 无目标技能直接施放
                table.remove(self.spell_queue, i)
                Main:ExecuteSpellCast(spell_data)
                spells_processed = spells_processed + 1
                self.current_frame_count = self.current_frame_count + 1
            elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
                -- 点目标技能，对着死亡目标的位置施放
                spell_data.lastPosition = lastPosition  -- 保存死亡目标的位置
                table.remove(self.spell_queue, i)
                Main:ExecuteSpellCast(spell_data)
                spells_processed = spells_processed + 1
                self.current_frame_count = self.current_frame_count + 1
            elseif targetType == DOTA_UNIT_TARGET_TYPE.TREE then
                -- 树木目标技能，重新寻找附近的树木
                local trees = GridNav:GetAllTreesAroundPoint(parent:GetAbsOrigin(), 500, false)
                if #trees > 0 then
                    -- 随机选择一棵树
                    spell_data.target = trees[RandomInt(1, #trees)]
                    table.remove(self.spell_queue, i)
                    Main:ExecuteSpellCast(spell_data)
                    spells_processed = spells_processed + 1
                    self.current_frame_count = self.current_frame_count + 1
                else
                    -- 没找到树木，移除此技能
                    table.remove(self.spell_queue, i)
                end
            elseif targetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
                -- 友方技能目标死亡时，转为对自己施放
                spell_data.target = parent
                table.remove(self.spell_queue, i)
                Main:ExecuteSpellCast(spell_data)
                spells_processed = spells_processed + 1
                self.current_frame_count = self.current_frame_count + 1
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
                    table.remove(self.spell_queue, i)
                    Main:ExecuteSpellCast(spell_data)
                    
                    spells_processed = spells_processed + 1
                    self.current_frame_count = self.current_frame_count + 1
                else
                    -- 没找到新目标，移除此技能
                    table.remove(self.spell_queue, i)
                end
            else
                -- 其他情况，移除此技能
                table.remove(self.spell_queue, i)
            end
        else
            -- 目标有效，正常施法
            table.remove(self.spell_queue, i)
            Main:ExecuteSpellCast(spell_data)
            
            spells_processed = spells_processed + 1
            self.current_frame_count = self.current_frame_count + 1
        end
    end
end



function modifier_attack_cast_ability_Any:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_attack_cast_ability_Any:OnAttackLanded(params)
    if not IsServer() then return end
    
    -- 确保是单位自己的攻击
    if params.attacker ~= self:GetParent() then return end
    
    local parent = self:GetParent()
    local target = params.target
    
    local specialSkills = {
        npc_dota_hero_pangolier = {"pangolier_swashbuckle"},


        npc_dota_hero_dazzle = {"dazzle_nothl_projection"},
        npc_dota_hero_life_stealer = {"life_stealer_infest"},
        npc_dota_hero_crystal_maiden = {"crystal_maiden_freezing_field"},
        npc_dota_hero_invoker = {"invoker_deafening_blast"},
        npc_dota_hero_nevermore = {"nevermore_shadowraze3", "nevermore_shadowraze1", "nevermore_shadowraze2"},
        npc_dota_hero_naga_siren = {"naga_siren_song_of_the_siren"},
    }

    local ability = nil
    local heroName = parent:GetUnitName()
    if specialSkills[heroName] then
        --随机一个技能
        ability = parent:FindAbilityByName(specialSkills[heroName][RandomInt(1, #specialSkills[heroName])])
    end

    if not ability then
        print("没有找到特殊技能")
        ability = CommonAI:GetRandomUltiSkill(parent)
    end

    if not ability or ability:IsNull() or ability:GetLevel() < 1 or ability:IsPassive() == true then
        return
    end
    
    -- 获取技能名称
    local abilityName = ability:GetAbilityName()
    
    -- 检查是否有modifier_ember_spirit_sleight_of_fist_caster且技能是ember_spirit_sleight_of_fist
    if parent:HasModifier("modifier_ember_spirit_sleight_of_fist_caster") and abilityName == "ember_spirit_sleight_of_fist" then
        return
    end
    
    local behavior = CommonAI:GetSkill_Behavior(ability)
    local targetTeam = CommonAI:GetSkillTargetTeam(ability)
    local targetType = CommonAI:GetSkillTargetType(ability)
    local is_self_cast = CommonAI:isSelfCastAbility(abilityName)
    
    -- 检查目标是否是敌对单位，如果是就从周围300范围内随机选择一个目标
    local finalTarget = target

    -- 根据不同技能类型处理目标选择
    if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
        -- 无目标技能不需要设置目标
        finalTarget = nil
    elseif targetTeam == DOTA_UNIT_TARGET_TEAM.FRIENDLY then
        -- 友方技能默认对自己施放
        finalTarget = parent
    elseif targetType == DOTA_UNIT_TARGET_TYPE.TREE then
        -- 树木目标技能，寻找周围500码范围内的树木
        local trees = GridNav:GetAllTreesAroundPoint(parent:GetAbsOrigin(), 500, false)
        if #trees > 0 then
            -- 随机选择一棵树
            finalTarget = trees[RandomInt(1, #trees)]
        end
    else
        -- 检查是否是特殊处理的技能
        local special_behavior = modifier_attack_cast_ability_Any.special_abilities[abilityName]
        
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
    table.insert(self.spell_queue, {
        parent = parent,
        ability = ability,
        target = finalTarget,
        behavior = behavior,
        targetTeam = targetTeam,
        targetType = targetType,
        abilityName = abilityName,
        is_self_cast = is_self_cast
    })
end