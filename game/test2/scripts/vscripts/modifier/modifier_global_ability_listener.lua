
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
    return { MODIFIER_EVENT_ON_ABILITY_EXECUTED }
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
        local ability = params.ability
        local caster = params.unit

        if ability and caster and not ability:IsItem() then
            -- 如果施法者是英雄(包括幻象)
            if caster:IsHero() then
                local message = PrintManager:FormatAbilityMessage(caster, ability)
                PrintManager:PrintMessage(message)
                
                -- 记录使用过技能的英雄
                Main.heroesUsedAbility[caster:GetEntityIndex()] = true
            end
        end

        self:CheckForDodgeableAbility(caster, ability)
    end
end

function modifier_global_ability_listener:CheckForRubick(caster, ability)
    if not Main or not Main.currentArenaHeroes then 
        return 
    end

    local leftHero = Main.currentArenaHeroes[1]
    local rightHero = Main.currentArenaHeroes[2]

    if not leftHero or not rightHero then 
        return 
    end

    local rubick, opponent

    if leftHero:GetUnitName() == "npc_dota_hero_rubick" then
        rubick = leftHero
        opponent = rightHero
    elseif rightHero:GetUnitName() == "npc_dota_hero_rubick" then
        rubick = rightHero
        opponent = leftHero
    end

    if rubick and opponent and caster == opponent then
        local rubickAIWrapper = AIs[rubick]
        if rubickAIWrapper and rubickAIWrapper.ai then
            local rubickAI = rubickAIWrapper.ai
            rubickAI.enemyUsedAbility = true
            
            if rubickAI.OnOpponentCastAbility then
                rubickAI:OnOpponentCastAbility(ability)
            end
        end
    end
end

function modifier_global_ability_listener:NotifyRubickAI(caster, ability)
    local arenaHeroes = hero_duel.currentArenaHeroes
    if not arenaHeroes then 
        return 
    end

    local rubick, opponent
    
    for i = 1, 2 do
        local hero = arenaHeroes[i]
        if hero and hero:IsAlive() then
            if hero:GetUnitName() == "npc_dota_hero_rubick" then
                rubick = hero
            else
                opponent = hero
            end
        end
    end

    if rubick and opponent and caster == opponent then
        local rubickAIWrapper = AIs[rubick]
        if rubickAIWrapper and rubickAIWrapper.ai then
            local rubickAI = rubickAIWrapper.ai
            rubickAI.enemyUsedAbility = true
        end
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