function Main:Init_award_ceremony(heroName, heroFacet,playerID, heroChineseName)
    local spawnOrigin = Vector(43, -300, 256)  -- 假设的生成位置，您可以根据需要调整
    --SpawnFourHeroes()
    DisplayHeroes()

end


function SpawnFourHeroes()
    -- 四个排名位置及其对应的英雄池
    local rank1Heroes = {"npc_dota_hero_gyrocopter"}
    local rank2Heroes = {    
        "npc_dota_hero_sven",
        "npc_dota_hero_tidehunter",

    }
    --允许表格为空
    local rank3Heroes = {}
    local rank4Heroes = {
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_spectre",
        "npc_dota_hero_luna",
        "npc_dota_hero_sand_king",
    }
    
    -- 排名位置坐标
    local positions = {
        Vector(767.79, 6149.44, 384.00),    -- 第一名位置
        Vector(1028.40, 6142.33, 256.00),   -- 第二名位置
        Vector(505.00, 6144.75, 128.00),    -- 第三名位置
        Vector(1335.26, 6084.06, 0.00)      -- 第四名位置
    }
    
    -- 英雄池列表
    local heroPoolsByRank = {rank1Heroes, rank2Heroes, rank3Heroes, rank4Heroes}

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
--每个表所有英雄都要上台

    for i = 1, 4 do
        local heroPool = heroPoolsByRank[i]
        if heroPool and #heroPool > 0 then
            local baseHero = nil  -- 基础英雄（第一个）
            
            for heroIndex, heroName in ipairs(heroPool) do
                local spawnPos = positions[i]
                local newHero = CreateUnitByName(heroName, spawnPos, true, nil, nil, DOTA_TEAM_GOODGUYS)
                
                if heroIndex == 1 then
                    baseHero = newHero  -- 记录第一个英雄作为基础
                    SetupHero(newHero, i == 1)
                else
                    -- 将后续英雄附加到基础英雄
                    newHero:AddNewModifier(
                        newHero,
                        nil,
                        "modifier_stack_units",
                        {parent_unit = baseHero:entindex()}  -- 传递父单位索引
                    )
                    -- 设置初始高度偏移
                    newHero:SetAbsOrigin(spawnPos + Vector(0, 0, 150 * (heroIndex - 1)))
                end
                
                newHero:SetForwardVector(Vector(0, -1, 0))
            end
        end
    end
end

function Main:OnNPCSpawned_award_ceremony(spawnedUnit, event)
    --所有出生的单位都朝南
    spawnedUnit:SetForwardVector(Vector(0, -1, 0))

end


function DisplayHeroes()
    local heroesGroup1 = {
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_sven",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_spectre",
        "npc_dota_hero_luna",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_axe",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_marci",
        "npc_dota_hero_lion",
        "npc_dota_hero_tiny",
        "npc_dota_hero_medusa",
        "npc_dota_hero_kez",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_mars",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_meepo",
        "npc_dota_hero_weaver",
        "npc_dota_hero_morphling"
    }
    
    local heroesGroup2 = {
        "npc_dota_hero_warlock",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_huskar",
        "npc_dota_hero_warlock",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_troll_warlord",

        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_tusk",
        "npc_dota_hero_pudge",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_warlock",    
        "npc_dota_hero_nevermore",
        "npc_dota_hero_pangolier",
        "npc_dota_hero_ember_spirit",

        "npc_dota_hero_silencer",
        "npc_dota_hero_enigma",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_elder_titan",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_crystal_maiden"
    }
    
    local riverWidth = 1000  -- 河道宽度
    local baseSpacing = 250  -- 基础间距
    local maxPerRow = 4      -- 每行最多英雄数
    
    -- 计算胜利者方阵
    local rows1 = math.ceil(#heroesGroup1 / maxPerRow)
    local cols1 = math.min(#heroesGroup1, maxPerRow)
    local formationWidth1 = (cols1 - 1) * baseSpacing
    local formationHeight1 = (rows1 - 1) * baseSpacing
    
    -- 计算失败者方阵
    local rows2 = math.ceil(#heroesGroup2 / maxPerRow)
    local cols2 = math.min(#heroesGroup2, maxPerRow)
    local formationWidth2 = (cols2 - 1) * baseSpacing
    local formationHeight2 = (rows2 - 1) * baseSpacing
    
    -- 设置对峙位置（胜利者在左，失败者在右，中间隔河）
    local winnersBase = Vector(-riverWidth/2 - formationWidth1/2 - 500, 0, 0)
    local losersBase = Vector(riverWidth/2 + formationWidth2/2 + 500, 0, 0)
    
    -- 创建胜利者方阵（面朝右）
    for i, heroName in ipairs(heroesGroup1) do
        local row = math.floor((i-1)/maxPerRow)
        local col = (i-1) % maxPerRow
        local pos = winnersBase + Vector(
            col * baseSpacing,
            row * baseSpacing - formationHeight1/2,
            0
        )
        local unit = CreateUnitByName(heroName, pos, true, nil, nil, DOTA_TEAM_GOODGUYS)
        unit:SetForwardVector(Vector(1, 0, 0))  -- 面朝右
        unit:AddNewModifier(unit, nil, "modifier_disarmed", {})
    end
    
    -- 创建失败者方阵（面朝左）
    for i, heroName in ipairs(heroesGroup2) do
        local row = math.floor((i-1)/maxPerRow)
        local col = (i-1) % maxPerRow
        local pos = losersBase + Vector(
            -col * baseSpacing,  -- 反向排列
            row * baseSpacing - formationHeight2/2, 
            0
        )
        local unit = CreateUnitByName(heroName, pos, true, nil, nil, DOTA_TEAM_BADGUYS)
        unit:SetForwardVector(Vector(-1, 0, 0))  -- 面朝左
        unit:AddNewModifier(unit, nil, "modifier_disarmed", {})
    end
end
