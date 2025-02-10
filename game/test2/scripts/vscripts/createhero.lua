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

    -- 使用传入的母体创建目标英雄
    local hero = CreateUnitByName(
        heroName,
        spawnPosition,
        true,
        parentHero,
        parentHero,
        team
    )
    local hPlayer = PlayerResource:GetPlayer(playerId)
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