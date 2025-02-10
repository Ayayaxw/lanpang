function Main:Init_HeroChaos()
    local ability_modifiers = {

        npc_dota_hero_pangolier = {
            -- pangolier_shield_crash = {
            --     AbilityCooldown = 0,
            --     AbilityManaCost = 0,
            -- }
        },

    }
    self:UpdateAbilityModifiers(ability_modifiers)

    local heroesGroup1 = {
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_meepo",
        "npc_dota_hero_muerta",
        "npc_dota_hero_kez",
    }
    
    local heroesGroup2 = {
        "npc_dota_hero_ursa",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_elder_titan",
        "npc_dota_hero_morphling",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_slark",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_slardar",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_silencer",
        "npc_dota_hero_doom_bringer"
    }
    
    -- 打乱英雄顺序
    ShuffleList(heroesGroup1)
    ShuffleList(heroesGroup2)

    local heroesCreated = {}
    self.heroData = {}  -- 初始化heroData表

    -- 初始化英雄数据
    for _, heroName in ipairs(heroesGroup1) do
        table.insert(self.heroData, { name = self:GetHeroChineseName(heroName), damage = 0, team = 1 })
    end
    for _, heroName in ipairs(heroesGroup2) do
        table.insert(self.heroData, { name = self:GetHeroChineseName(heroName), damage = 0, team = 2 })
    end

    -- 将英雄数据转换为JSON字符串
    local heroDataJson = json.encode(self.heroData)

    hero_duel.EndDuel = false
    -- 使用GameEvents将数据发送给前端JS
    Timers:CreateTimer(5, function()
        CustomGameEventManager:Send_ServerToAllClients("initialize_hero_data", {heroData = heroDataJson})
    end)

    -- 添加日志以调试事件发送
    print("Sending hero data to clients:", heroDataJson)

    Timers:CreateTimer(10, function()
        if #heroesGroup1 > 0 then
            local createdHeroes = PositionHeroesAdaptive(heroesGroup1, Vector(1100, 300, 0), DOTA_TEAM_GOODGUYS, 0, true, false)
            for _, hero in ipairs(createdHeroes) do
                table.insert(heroesCreated, hero)
            end
        end
        if #heroesGroup2 > 0 then
            local createdHeroes = PositionHeroesAdaptive(heroesGroup2, Vector(-900, 300, 0), DOTA_TEAM_BADGUYS, 1, false, true)
            for _, hero in ipairs(createdHeroes) do
                table.insert(heroesCreated, hero)
            end
        end
        
        Timers:CreateTimer(11, function()
            CustomGameEventManager:Send_ServerToAllClients("start_countdown", {})
        end)

        Timers:CreateTimer(15, function()
            AssignAIToHeroes(heroesCreated)
        end)
    end)
end



function PositionHeroesAdaptive(heroList, centerPosition, teamID, playerID, isRightSide, giveModifier)
    local heroesCreated = {}
    local totalHeroes = #heroList
    local columns = 1
    local spacing = 300
    local columnSpacing = 300

    if totalHeroes > 10 then
        columns = 3
        spacing = 300
        columnSpacing = 300
    elseif totalHeroes > 5 then
        columns = 2
        spacing = 300
        columnSpacing = 300
    end

    local heroesPerColumn = math.ceil(totalHeroes / columns)
    local offsetY = centerPosition.y - (heroesPerColumn - 1) * spacing / 2

    for i, heroName in ipairs(heroList) do
        local column = math.floor((i - 1) / heroesPerColumn)
        local row = (i - 1) % heroesPerColumn
        
        local x = centerPosition.x + column * columnSpacing * (isRightSide and -1 or 1)
        local y = offsetY + row * spacing
        local position = Vector(x, y, 0)
        
        local hero = CreateAndLevelmaxHero(heroName, position, playerID, teamID, isRightSide, giveModifier)

        if hero then
            table.insert(heroesCreated, hero)
            print("英雄添加到列表:", hero:GetUnitName(), "位置:", hero:GetAbsOrigin())
        else
            print("英雄创建失败:", heroName)
        end
    end

    return heroesCreated
end

function PositionHeroes(spacing,heroList, centerPosition, teamID, playerID, isRightSide, columnOffset,giveModifier)

    local offsetY = centerPosition.y - (#heroList - 1) * spacing / 2 -- 竖向排列
    local heroesCreated = {}

    for i, heroName in ipairs(heroList) do
        local x = centerPosition.x + columnOffset
        local y = offsetY + i * spacing
        local position = Vector(x, y, 0)
        local hero = CreateAndLevelmaxHero(heroName, position, playerID, teamID, isRightSide,giveModifier)

        if hero then
            table.insert(heroesCreated, hero)
            print("英雄添加到列表:", hero:GetUnitName(), "位置:", hero:GetAbsOrigin())
        else
            print("英雄创建失败:", heroName)
        end
    end

    return heroesCreated
end

function AssignAIToHeroes(heroesCreated)
    for _, hero in ipairs(heroesCreated) do
        local initialDelay = math.random(0, 100) / 100
        CreateAIForHero(hero, {"默认策略"}, {"默认策略"}, "AI",0.1)
        -- hero:SetContextThink("AIThink", function() return HeroAI:Think(hero) end, initialDelay)
    end
end

function CreateAndLevelmaxHero(heroName, position, playerID, teamID, isRightSide,giveModifier)
    local hero = CreateUnitByName(heroName, position, true, nil, nil, teamID or DOTA_TEAM_GOODGUYS)

    if isRightSide then
        hero:SetForwardVector(Vector(-1, 0, 0)) -- 右边的英雄朝左
    else
        hero:SetForwardVector(Vector(1, 0, 0))  -- 左边的英雄朝右
    end

    hero:SetControllableByPlayer(-1, true)
    hero:AddItemByName("item_ultimate_scepter_2")
    hero:AddItemByName("item_aghanims_shard")
    HeroMaxLevel(hero)
    hero:AddItemByName("item_attribute_amplifier_5x")
    -- hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
    -- -- hero:AddNewModifier(hero, nil, "modifier_no_cooldown_SecondSkill", {})
    -- hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = 15})
    -- hero:AddNewModifier(hero, nil, "modifier_damage_reduction_100", {duration = 15})
    if giveModifier == false  then
        Timers:CreateTimer(1, function()

            
        end)
    else
        Timers:CreateTimer(1, function()

            -- hero:AddNewModifier(hero, nil, "modifier_attribute_amplifier", {})
            
        end)
    end

    if heroName == "npc_dota_hero_nevermore" then
        local necromasteryAbility = hero:FindAbilityByName("nevermore_necromastery")
        if necromasteryAbility and necromasteryAbility:GetLevel() > 0 then
            local maxSouls = 25
            hero:SetModifierStackCount("modifier_nevermore_necromastery", hero, maxSouls)
        else
            -- 如果没有找到技能或技能未升级，可以在这里处理错误或者记录日志
            print("错误：未能找到影魔的灵魂积累技能或技能未升级！")
        end
    end
    return hero
end

function ShuffleList(list)
    for i = #list, 2, -1 do
        local j = RandomInt(1, i)
        list[i], list[j] = list[j], list[i]
    end
end
