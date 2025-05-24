-- modifier_global_ability_listener.lua
if modifier_global_ability_listener == nil then
    modifier_global_ability_listener = class({})
end

function modifier_global_ability_listener:IsHidden()
    return true
end

function modifier_global_ability_listener:IsPurgable()
    return false
end

function modifier_global_ability_listener:RemoveOnDeath()
    return false
end

function modifier_global_ability_listener:DeclareFunctions()
    return { 
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_DEATH_COMPLETED,
        MODIFIER_EVENT_ON_ATTACK_FINISHED
    }
end

function modifier_global_ability_listener:GetHeroChineseName(heroName)
    for _, hero in ipairs(heroes_precache) do
        if hero.name == heroName then
            return hero.chinese
        end
    end
    return "未知英雄"
end

function modifier_global_ability_listener:OnAbilityExecuted(params)
    if IsServer() then
        print("有单位在放技能")
        DeepPrintTable(params)
        
        -- 尝试获取更多施法信息
        local ability = params.ability
        local caster = params.unit
        
        if ability and caster then
            print("施法单位: " .. caster:GetUnitName())
            print("施法技能: " .. ability:GetAbilityName())
            
            -- 尝试获取施法位置
            local cursor_position = ability:GetCursorPosition()
            if cursor_position then
                print("施法目标位置: ", cursor_position.x, cursor_position.y, cursor_position.z)
            end
            
            -- 获取施法单位当前位置
            local caster_position = caster:GetAbsOrigin()
            print("施法单位位置: ", caster_position.x, caster_position.y, caster_position.z)
            
            -- 尝试获取目标单位
            local cursor_target = ability:GetCursorTarget()

        end

        if ability and caster and not ability:IsItem() then
            print("技能名称: " .. ability:GetAbilityName())
            print("施法者名称: " .. caster:GetUnitName())
            
            -- 如果施法者是英雄(包括幻象)
            if caster:IsHero() then
                print("施法者是英雄: " .. caster:GetUnitName())
                local message = PrintManager:FormatAbilityMessage(caster, ability)
                PrintManager:PrintMessage(message)
                
                -- 记录使用过技能的英雄
                Main.heroesUsedAbility[caster:GetEntityIndex()] = true
                print("已记录英雄使用技能: " .. caster:GetEntityIndex())
                
                -- 初始化英雄技能记录表
                if not Main.heroLastCastAbility then
                    Main.heroLastCastAbility = {}
                    print("初始化英雄技能记录表")
                end
                
                local heroIndex = caster:GetEntityIndex()
                -- 初始化该英雄的技能记录表
                if not Main.heroLastCastAbility[heroIndex] then
                    Main.heroLastCastAbility[heroIndex] = {}
                    print("初始化英雄 " .. caster:GetUnitName() .. " 的技能记录表")
                end

                local abilityName = ability:GetAbilityName()
                print("记录技能 " .. abilityName .. " 的释放时间")
                
                -- 获取目标位置和目标单位
                local cursor_position = ability:GetCursorPosition()
                local cursor_target = ability:GetCursorTarget()
                local target_unit_name = cursor_target and cursor_target.GetUnitName and cursor_target:GetUnitName() or nil
                local target_unit_index = cursor_target and cursor_target:GetEntityIndex() or nil
                
                -- 记录该英雄每个技能最近一次释放的信息
                Main.heroLastCastAbility[heroIndex][abilityName] = {
                    time = GameRules:GetGameTime(),
                    cursor_position = cursor_position,
                    target_unit_index = target_unit_index,
                    caster_position = caster:GetAbsOrigin()
                }
                print("当前游戏时间: " .. GameRules:GetGameTime())
                
                -- 打印记录的信息
                if cursor_position then
                    print("已记录施法目标位置: ", cursor_position.x, cursor_position.y, cursor_position.z)
                end
                if target_unit_name then
                    print("已记录施法目标单位: " .. target_unit_name)
                end
            else
                print("施法者不是英雄: " .. caster:GetUnitName())
            end
        else
            if not ability then
                print("无效的技能对象")
            end
            if not caster then
                print("无效的施法者对象")
            end
            if ability and ability:IsItem() then
                print("这是一个物品技能: " .. ability:GetAbilityName())
            end
        end

        self:CheckForDodgeableAbility(caster, ability)
        print("检查完可躲避技能")
    end
end

function modifier_global_ability_listener:CheckForDodgeableAbility(caster, ability)
    if not Main or not Main.currentArenaHeroes then 
        --print("失败：Main 或 currentArenaHeroes 不存在")
        return 
    end

    local arenaHeroes = Main.currentArenaHeroes
    local player, aiHero

    for i = 1, 2 do
        local hero = arenaHeroes[i]
        if hero and hero:IsAlive() then
            if hero == caster then
                player = hero
            else
                aiHero = hero
            end
        end
    end

    if not player or not aiHero then
        return
    end

    --print("释放技能的玩家：" .. player:GetUnitName())
    --print("AI控制的英雄：" .. aiHero:GetUnitName())

    local aiWrapper = AIs[aiHero]
    if not aiWrapper or not aiWrapper.ai then
        --print("失败：AI包装器或AI实例不存在")
        return
    end

    local ai = aiWrapper.ai
    if not ai.DodgableSkills then
        --print("失败：AI 的 DodgableSkills 不存在")
        return
    end

    local abilityName = ability:GetAbilityName()
    --print("检查的技能名称：" .. abilityName)

    if ai.DodgableSkills[abilityName] then
        --print("该技能在可躲避列表中")
        local dodgeableAbilities = self:GetHeroDodgeableAbilities(aiHero)
        --print("AI 英雄可用的躲避技能数量：" .. #dodgeableAbilities)

        if #dodgeableAbilities > 0 then
            ai.needToDodge = true
            ai.shouldStop = true
            ai.dodgeableAbilities = dodgeableAbilities
           -- print("已经将躲避信息发送给 AI")
            --print("设置 needToDodge 为 true")
            --print("设置 shouldStop 为 true")
            --print("可用的躲避技能：")
            for _, abilityName in ipairs(dodgeableAbilities) do
                print("  - " .. abilityName)
            end

            if ai.OnNeedToDodge then
                --print("调用 AI 的 OnNeedToDodge 函数")
                ai:OnNeedToDodge(ability, dodgeableAbilities)
            else
                --print("AI 没有 OnNeedToDodge 函数")
            end
        else
            --print("AI 英雄没有可用的躲避技能")
        end
    else
        --print("该技能不在可躲避列表中")
    end

    --print("检查可躲避技能结束")
end

function modifier_global_ability_listener:GetHeroDodgeableAbilities(hero)
    local dodgeableAbilities = {}
    local ai = AIs[hero].ai
    
    if not ai or not ai.DodgeSkills then
        print("Error: AI or AI.DodgeSkills not found for hero", hero:GetUnitName())
        return dodgeableAbilities
    end

    if not self.lastCastAbilityName then
        print("Error: lastCastAbilityName is not set")
        return dodgeableAbilities
    end

    for i = 0, hero:GetAbilityCount() - 1 do
        local ability = hero:GetAbilityByIndex(i)
        if ability and ability:GetAbilityName() then
            local abilityName = ability:GetAbilityName()
            if ai.DodgeSkills[abilityName] and ability:IsFullyCastable() then
                if ai:CanDodge(abilityName, self.lastCastAbilityName) then
                    table.insert(dodgeableAbilities, abilityName)
                end
            end
        end
    end
    return dodgeableAbilities
end

function modifier_global_ability_listener:OnAttackFinished(params)
    if IsServer() then
        print("有单位完成攻击动作，弹道已发射")
        local attacker = params.attacker
        local target = params.target
        
        if attacker and target then
            print("攻击者名称: " .. attacker:GetUnitName())
            print("目标名称: " .. target:GetUnitName())
            
            -- 如果攻击者是英雄(包括幻象)
            if attacker:IsHero() then
                print("攻击者是英雄: " .. attacker:GetUnitName())
                -- 这里可以添加类似技能记录的逻辑
                
                -- 记录发起攻击的英雄
                if not Main.heroesAttacked then
                    Main.heroesAttacked = {}
                end
                Main.heroesAttacked[attacker:GetEntityIndex()] = true
                print("已记录英雄发起攻击: " .. attacker:GetEntityIndex())
                
                -- 如果需要记录攻击时间等信息，可以参照技能记录的方式
                if not Main.heroLastAttack then
                    Main.heroLastAttack = {}
                end
                
                local heroIndex = attacker:GetEntityIndex()
                if not Main.heroLastAttack[heroIndex] then
                    Main.heroLastAttack[heroIndex] = {}
                end
                
                Main.heroLastAttack[heroIndex] = {
                    target = target:GetUnitName(),
                    time = GameRules:GetGameTime(),
                    damage = params.damage,
                    ranged_attack = params.ranged_attack
                }
                print("当前游戏时间: " .. GameRules:GetGameTime())
            else
                print("攻击者不是英雄: " .. attacker:GetUnitName())
            end
        else
            if not attacker then
                print("无效的攻击者对象")
            end
            if not target then
                print("无效的目标对象")
            end
        end
    end
end