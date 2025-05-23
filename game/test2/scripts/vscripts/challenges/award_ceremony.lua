function Main:Init_award_ceremony(heroName, heroFacet,playerID, heroChineseName)
    local spawnOrigin = Vector(43, -300, 256)  -- 假设的生成位置，您可以根据需要调整
    SpawnFourHeroes()
    --DisplayHeroes()

end


function SpawnFourHeroes()
    -- 四个排名位置及其对应的英雄池


    local rank1Heroes = { 
        "npc_dota_hero_abyssal_underlord"
    }
    local rank2Heroes = { 
        "npc_dota_hero_night_stalker"
    }
    local rank3Heroes = { 
        "npc_dota_hero_sven"
    }
    local rank4Heroes = { 
        "npc_dota_hero_pudge"
    }

    local positions = {
        Vector(767.79, 6149.44, 384.00),    -- 第一名位置
        Vector(1028.40, 6142.33, 256.00),   -- 第二名位置
        Vector(505.00, 6144.75, 128.00),    -- 第三名位置
        Vector(1335.26, 6084.06, 0.00)      -- 第四名位置
    }
    
    -- 英雄池列表
    local heroPoolsByRank = {rank1Heroes, rank2Heroes, rank3Heroes, rank4Heroes}
    
    -- 查找米波所在的位置
    local meepoRank = nil
    local meepoIndex = nil
    
    for rankIndex, heroPool in ipairs(heroPoolsByRank) do
        for heroIdx, heroName in ipairs(heroPool) do
            if heroName == "npc_dota_hero_meepo" then
                meepoRank = rankIndex
                meepoIndex = heroIdx
                break
            end
        end
        if meepoRank then break end
    end



    -- 分两阶段创建英雄：先创建米波，然后创建其他英雄
    Timers:CreateTimer(1, function()
        -- 如果存在米波，先创建米波
        if meepoRank then
            local meepoPool = heroPoolsByRank[meepoRank]
            table.remove(meepoPool, meepoIndex) -- 从原列表中移除米波
            
            local spawnPos = positions[meepoRank]
            local meepoHero = CreateUnitByName("npc_dota_hero_meepo", spawnPos, true, nil, nil, DOTA_TEAM_GOODGUYS)
            
            -- 设置为该排名位置的基础英雄
            heroPoolsByRank[meepoRank].baseHero = meepoHero
            SetupHero(meepoHero, meepoRank == 1)
            meepoHero:SetForwardVector(Vector(0, 1, 0))
            
            -- 等待米波设置完成后，创建其余英雄
            Timers:CreateTimer(0.5, function()
                SpawnRemainingHeroes(heroPoolsByRank, positions)
            end)
        else
            -- 如果没有米波，直接创建所有英雄
            SpawnRemainingHeroes(heroPoolsByRank, positions)
        end
    end)
end


function SetupHero(newHero, isFirst)
    newHero:SetControllableByPlayer(0, true)
    

    newHero:StartGesture(ACT_DOTA_VICTORY)
    

    
    HeroMaxLevel(newHero)
    newHero:AddNewModifier(newHero, nil, "modifier_disarmed", {})
    newHero:AddNewModifier(newHero, nil, "modifier_damage_reduction_100", {})
    newHero:AddNewModifier(newHero, nil, "modifier_break", {})
    newHero:AddNewModifier(newHero, nil, "modifier_phased", {})
    newHero:AddItemByName("item_rapier")
    newHero:AddItemByName("item_rapier")
    newHero:AddItemByName("item_rapier")
    newHero:AddItemByName("item_rapier")
    newHero:AddItemByName("item_rapier")
    newHero:AddItemByName("item_rapier")
    newHero:AddItemByName("item_trident")
    -- 神杖和魔晶
    newHero:SetForwardVector(Vector(0, -1, 0))
    newHero:AddNewModifier(newHero, nil, "modifier_item_aghanims_shard", {})
    newHero:AddNewModifier(newHero, nil, "modifier_item_ultimate_scepter_consumed", {})
    
    -- 米波特殊处理
    if newHero:GetUnitName() == "npc_dota_hero_meepo" then
        local ability = newHero:FindAbilityByName("meepo_megameepo")
        if ability then
            ability:OnSpellStart()
        else
            print("米波没有第五个技能")
        end
    end

    if isFirst then
        local particleName = "particles/events/ti6_teams/teleport_start_ti6_lvl3_mvp_phoenix.vpcf"
        local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, newHero)
        ParticleManager:SetParticleControl(particle, 0, newHero:GetAbsOrigin())
    end
end

-- 创建除米波外的所有其他英雄
function SpawnRemainingHeroes(heroPoolsByRank, positions)
    for i = 1, 4 do
        local heroPool = heroPoolsByRank[i]
        if heroPool and #heroPool > 0 then
            local baseHero = heroPool.baseHero -- 获取可能已经创建的米波作为基础
            
            for heroIndex, heroName in ipairs(heroPool) do
                local spawnPos = positions[i]
                local playerId = 0
                local FacetID = 2
                local spawnPosition = spawnPos
                local team = DOTA_TEAM_GOODGUYS
                local isControllableByPlayer = true
                local newHero = nil
                CreateHero(playerId, heroName, FacetID, spawnPosition, team, isControllableByPlayer, 
                function(hero)
                    newHero = hero

                    if not baseHero then
                        -- 如果没有预先创建的基础英雄(米波)，把第一个英雄作为基础
                        baseHero = newHero
                        SetupHero(newHero, i == 1)
                    else
                        -- 将后续英雄附加到基础英雄
                        newHero:AddNewModifier(
                            newHero,
                            nil,
                            "modifier_stack_units",
                            {parent_unit = baseHero:entindex()}
                        )
                        -- 设置初始高度偏移
                       -- newHero:SetAbsOrigin(spawnPos + Vector(0, 0, 150 * (heroIndex)))
                    end
                end
                )


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

        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_omniknight", 
        "npc_dota_hero_doom_bringer", 
    
        "npc_dota_hero_spirit_breaker", 
        "npc_dota_hero_slardar", 
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_obsidian_destroyer", 
        "npc_dota_hero_jakiro", 
        "npc_dota_hero_muerta",
    
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_axe",
        "npc_dota_hero_legion_commander", 
        "npc_dota_hero_tusk",
    
        "npc_dota_hero_kunkka"
    
    
    
        }
        
        local heroesGroup2 = {
        "npc_dota_hero_sniper", 
    
        "npc_dota_hero_gyrocopter", 
    
        "npc_dota_hero_juggernaut", 
        "npc_dota_hero_weaver", 
    
        "npc_dota_hero_shadow_shaman", 
        "npc_dota_hero_faceless_void", 
        "npc_dota_hero_drow_ranger", 
        "npc_dota_hero_razor",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_naga_siren", 
        "npc_dota_hero_broodmother", 
        "npc_dota_hero_kez",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_phantom_lancer", 
        "npc_dota_hero_hoodwink",
        "npc_dota_hero_pangolier", 
        "npc_dota_hero_brewmaster", 
    
    
        }
        
    
    -- 动态计算河道宽度（基础500，人数差每多1个减少50，最小200）
    local diff = math.abs(#heroesGroup1 - #heroesGroup2)
    local riverWidth = math.max(200, 500 - diff * 50)  -- 最小保持200宽度
    local baseSpacing = 250
    local maxPerRow = 4
    
    -- 使用场地中心点
    local center = Main.largeSpawnCenter
    
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
    
    -- 调整后的对峙位置（基于场地中心）
    local winnersBase = center + Vector(-riverWidth/2 - formationWidth1/2 - 500, 0, 0)
    local losersBase = center + Vector(riverWidth/2 + formationWidth2/2 + 500, 0, 0)
    
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
