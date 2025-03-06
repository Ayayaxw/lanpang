function Main:Init_award_ceremony(heroName, heroFacet,playerID, heroChineseName)
    local spawnOrigin = Vector(43, -300, 256)  -- 假设的生成位置，您可以根据需要调整
    SpawnFourHeroes()
    --DisplayHeroes()

end


function SpawnFourHeroes()
    local heroData = {
        {name = "npc_dota_hero_meepo", position = Vector(767.79, 6149.44, 384.00)},
        {name = "npc_dota_hero_mars", position = Vector(767.79, 6149.44, 384.00)},
        --{name = "npc_dota_hero_earthshaker", position = Vector(767.79, 6149.44, 384.00)},
        --{name = "npc_dota_hero_necrolyte", position = Vector(1028.40, 6142.33, 256.00)},
        {name = "npc_dota_hero_pugna", position = Vector(505.00, 6144.75, 128.00)},
        --{name = "npc_dota_hero_ember_spirit", position = Vector(505.00, 6144.75, 128.00)},
        {name = "npc_dota_hero_phantom_assassin", position = Vector(1335.26, 6084.06, 0.00)}
    }

    local function SetupHero(newHero, isFirst)
        newHero:SetControllableByPlayer(0, true)
        newHero:StartGesture(ACT_DOTA_VICTORY)
        HeroMaxLevel(newHero)
        newHero:AddNewModifier(newHero, nil, "modifier_disarmed", {})
        newHero:AddNewModifier(newHero, nil, "modifier_damage_reduction_100", {})
        newHero:AddNewModifier(newHero, nil, "modifier_break", {})

        if isFirst then
            local particleName = "particles/events/ti6_teams/teleport_start_ti6_lvl3_mvp_phoenix.vpcf"
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, newHero)
            ParticleManager:SetParticleControl(particle, 0, newHero:GetAbsOrigin())
        end
    end

    for i, data in ipairs(heroData) do
        local newHero = CreateUnitByName(data.name, data.position, true, nil, nil, DOTA_TEAM_GOODGUYS)
        SetupHero(newHero, i <= 1)  -- 只给第一个英雄加特效
        newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
    end
end


function DisplayHeroes()
    local heroesGroup1 = {
        "npc_dota_hero_slardar",
        "npc_dota_hero_windrunner", 
        "npc_dota_hero_phoenix",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_puck",
        "npc_dota_hero_huskar",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_ember_spirit"
    }
    
    local heroesGroup2 = {
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_tinker",
        "npc_dota_hero_sniper",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_rubick",
        "npc_dota_hero_invoker",
        "npc_dota_hero_zuus"
    }
    
    local centerX = 0      -- 中心X坐标，根据需要调整
    local centerY = 0      -- 中心Y坐标，根据需要调整
    local spacing = 200    -- 英雄之间的间距
    local rowGap = 300     -- 两排之间的距离
    
    -- 计算起始位置使两组英雄居中对齐
    local winnersWidth = (#heroesGroup1 - 1) * spacing
    local losersWidth = (#heroesGroup2 - 1) * spacing
    local winnersStartX = centerX - winnersWidth / 2
    local losersStartX = centerX - losersWidth / 2
    
    -- 创建胜利者（下排）
    for i, heroName in ipairs(heroesGroup1) do
        local posX = winnersStartX + (i-1) * spacing
        local posY = centerY - rowGap/2
        local unit = CreateUnitByName(heroName, Vector(posX, posY, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
        -- 设置单位朝南
        unit:SetForwardVector(Vector(0, -1, 0))
        -- 设置单位为缴械状态
        unit:AddNewModifier(unit, nil, "modifier_disarmed", {})
    end
    
    -- 创建失败者（上排）
    for i, heroName in ipairs(heroesGroup2) do
        local posX = losersStartX + (i-1) * spacing
        local posY = centerY + rowGap/2
        local unit = CreateUnitByName(heroName, Vector(posX, posY, 0), true, nil, nil, DOTA_TEAM_BADGUYS)
        -- 设置单位朝南
        unit:SetForwardVector(Vector(0, -1, 0))
        -- 设置单位为缴械状态
        unit:AddNewModifier(unit, nil, "modifier_disarmed", {})
    end
end
