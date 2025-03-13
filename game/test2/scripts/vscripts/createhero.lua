
function CreateHero(playerId, heroName, FacetID, spawnPosition, team, isControllableByPlayer, callback)
    local hPlayer = PlayerResource:GetPlayer(playerId)
    
    if hPlayer == nil then
        print("错误：未找到玩家")
        return nil
    end

    -- 调用函数创建指定的英雄，并配置相关属性
    DebugCreateHeroWithVariant(hPlayer, heroName, FacetID, team, false,
        function(hero)
            if isControllableByPlayer then
                hero:SetControllableByPlayer(playerId, true)
            
                hPlayer:SetAssignedHeroEntity(hero)
            else
                -- 尝试将控制权设置为无效玩家ID，通常使用-1来实现不可控制
                hero:SetControllableByPlayer(playerId, false)
            end
            
            hero:SetRespawnPosition(spawnPosition)
            FindClearSpaceForUnit(hero, spawnPosition, true)
            hero:SetIdleAcquire(true)
            hero:SetAcquisitionRange(1000)
            
            
            print(heroName .. " 已创建，带有命石 " .. FacetID)
            
            if callback then
                callback(hero)  -- 使用回调函数处理英雄对象
            end
        end)
end

function CreateHeroHeroChaos(playerId, heroName, FacetID, spawnPosition, team, isControllableByPlayer, parentHero, callback)
    local hPlayer = PlayerResource:GetPlayer(playerId)
    -- 使用传入的母体创建目标英雄
    local hero = CreateUnitByName(
        heroName,
        spawnPosition,
        true,
        hPlayer,
        parentHero,
        team
    )

    if isControllableByPlayer then
        hero:SetControllableByPlayer(playerId, true)
    
        hPlayer:SetAssignedHeroEntity(hero)
    else
        -- 尝试将控制权设置为无效玩家ID，通常使用-1来实现不可控制
        --hero:SetControllableByPlayer(playerId, false)
    end

    if not hero then
        print("错误：创建单位失败 " .. heroName)
        return
    end

    -- 设置重生点并调整位置
    hero:SetRespawnPosition(spawnPosition)
    FindClearSpaceForUnit(hero, spawnPosition, true)

    -- 设置AI行为参数
    hero:SetIdleAcquire(true)
    hero:SetAcquisitionRange(1000)

    print(heroName .. " 已创建，命石ID: " .. FacetID)

    -- 执行回调函数
    if callback then
        callback(hero)
    end
end


function CreateHeroWithoutPlayer(playerId, heroName, FacetID, spawnPosition, team, isControllableByPlayer, callback)
    -- 计算临时英雄的偏移位置
    local offsetX = math.random(100, 200) * (math.random(0, 1) == 0 and 1 or -1)
    local offsetY = math.random(100, 200) * (math.random(0, 1) == 0 and 1 or -1)
    local tempPosition = Vector(
        spawnPosition.x + offsetX,
        spawnPosition.y + offsetY,
        spawnPosition.z
    )

    -- 首先创建临时英雄
    CreateHero(playerId, "npc_dota_hero_axe", FacetID, tempPosition, team, true,
        function(tempHero)
            if not tempHero then
                print("错误：临时英雄创建失败")
                return
            end

            local tempPlayerId = tempHero:GetPlayerID()

            -- 使用临时英雄创建目标英雄
            CreateHeroHeroChaos(playerId, heroName, FacetID, spawnPosition, team, isControllableByPlayer, tempHero,
                function(realHero)
                    if not realHero then
                        print("错误：目标英雄创建失败 " .. heroName)
                        return
                    end

                    -- 先删除临时英雄，确认删除后再执行回调
                    if tempPlayerId then
                        
                        -- 延迟执行回调，确保临时英雄已被删除
                        Timers:CreateTimer(0.03, function()
                            DisconnectClient(tempPlayerId, true)
                            Timers:CreateTimer(0.6, function()
                                if callback then
                                    callback(realHero)
                                end
                            end)
                        end)
                    end
                end)
            end)
end

function CreateParentHeroesWithFacets(callback)
    local playerId = 0
    local spawnPosition = Main.largeSpawnCenter
    
    local teams = {
        DOTA_TEAM_GOODGUYS,
        DOTA_TEAM_BADGUYS, 
        DOTA_TEAM_CUSTOM_1,
        DOTA_TEAM_CUSTOM_2
    }
    
    local allHeroes = {
        good = {},
        bad = {},
        custom1 = {},
        custom2 = {}
    }
    local tempHeroes = {}
    local heroCount = 0
    local expectedCount = 20 -- 4个队伍 x 5个facet

    -- 为每个team创建5个不同facet的英雄
    for _, team in ipairs(teams) do
        for facetId = 1, 5 do
            -- 根据facetId决定英雄名称
            local heroName = (facetId == 2) and "npc_dota_hero_ursa" or "npc_dota_hero_chen"
            
            -- 计算偏移位置
            local offsetX = math.random(100, 200) * (math.random(0, 1) == 0 and 1 or -1)
            local offsetY = math.random(100, 200) * (math.random(0, 1) == 0 and 1 or -1)
            local tempPosition = Vector(
                spawnPosition.x + offsetX,
                spawnPosition.y + offsetY,
                spawnPosition.z
            )

            -- 创建临时英雄
            CreateHero(playerId, heroName, facetId, tempPosition, team, true,
                function(tempHero)
                    if not tempHero then
                        print("错误：临时英雄创建失败")
                        return
                    end

                    local tempPlayerId = tempHero:GetPlayerID()
                    table.insert(tempHeroes, {hero = tempHero, playerId = tempPlayerId})

                    -- 使用临时英雄创建目标英雄
                    CreateHeroHeroChaos(playerId, heroName, facetId, spawnPosition, team, true, tempHero,
                        function(realHero)
                            if not realHero then
                                print("错误：目标英雄创建失败 " .. heroName)
                                return
                            end

                            -- 添加modifier_wearable
                            --realHero:AddNewModifier(realHero, nil, "modifier_wearable", {})
                            --添加无敌modifier
                            realHero:AddNewModifier(realHero, nil, "modifier_invulnerable", {})

                            heroCount = heroCount + 1
                            
                            -- 按照队伍和facetId存储英雄
                            if team == DOTA_TEAM_GOODGUYS then
                                allHeroes.good[facetId] = realHero
                            elseif team == DOTA_TEAM_BADGUYS then
                                allHeroes.bad[facetId] = realHero
                            elseif team == DOTA_TEAM_CUSTOM_1 then
                                allHeroes.custom1[facetId] = realHero
                            elseif team == DOTA_TEAM_CUSTOM_2 then
                                allHeroes.custom2[facetId] = realHero
                            end

                            -- 当所有英雄都创建完成后
                            if heroCount == expectedCount then
                                -- 延迟执行断开连接
                                Timers:CreateTimer(0.03, function()
                                    -- 断开所有临时英雄的连接
                                    for _, tempData in ipairs(tempHeroes) do
                                        DisconnectClient(tempData.playerId, true)
                                    end

                                    -- 等待所有断开连接完成后回调
                                    Timers:CreateTimer(1, function()
                                        if callback then
                                            callback(allHeroes)
                                        end
                                    end)
                                end)
                            end
                        end)
                end)
        end
    end
end

function CreateAIForHero(heroEntity, overallStrategy, heroStrategy, aiName, thinkInterval,SkillThresholds)

    local heroName = heroEntity:GetUnitName()
    local heroAI
    

    heroAI = CommonAI.new(heroEntity, overallStrategy or {"默认策略"}, heroStrategy or {"默认策略"}, thinkInterval, SkillThresholds)

    
    if heroAI then
        --print("成功创建AI实例: " .. heroEntity:GetUnitName())
        
        AIs[heroEntity] = {
            ai = heroAI,
            name = aiName or heroEntity:GetUnitName()
        }

        heroEntity:SetContextThink("AIThink", function() 
            if AIs[heroEntity] then
                return AIs[heroEntity].ai:Think(heroEntity) 
            else
                --print("AI实例为空: " .. heroEntity:GetUnitName())
                return 1.0  -- 1秒后重试
            end
        end, 0)
    else
        --print("创建AI实例失败: " .. heroEntity:GetUnitName())
        return
    end
end



-- Evaluate the state of the game
-- function Main:OnThink()
--     --return xiaowanyi:OnThink()
-- end
