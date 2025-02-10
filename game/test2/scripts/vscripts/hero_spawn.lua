-- hero_spawn.lua
hero_spawn = {}

function hero_spawn.setupAdvancementCompetitors()
    -- 等待十秒

    Timers:CreateTimer(10.0, function()
        -- 英雄起始坐标和间隔设置
        local startX, startY, startZ = -1400, 1000, 0
        local horizontalSpacing = 200
        local groupSpacing = 300
        local groupSize = 2
        local currentX, currentY = startX, startY

        -- 为每个英雄分配新位置和道具
        for index, heroName in ipairs(advancementCompetitors) do
            if index % groupSize == 1 and index ~= 1 then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((index - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_GOODGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale()) -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0)) -- 朝南

        end
    end)
end

function hero_spawn.setupAdvancementCompetitors1()
    -- 等待十秒
    local goodguys = {
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_hoodwink",
        "npc_dota_hero_morphling",
        "npc_dota_hero_ursa",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_riki",
        "npc_dota_hero_ember_spirit"
    }
    
    local badguys = {
        "npc_dota_hero_nevermore",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_luna",
        "npc_dota_hero_spectre",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_razor",
        "npc_dota_hero_terrorblade"
    }
    
    Timers:CreateTimer(10.0, function()
        -- 英雄起始坐标和间隔设置
        local startX, startY, startZ = -1450, 700, 0
        local horizontalSpacing = 180
        local groupSpacing = 250
        local groupSize = 2
        local currentX, currentY = startX, startY

        -- 好人阵容配置
        for index, heroName in ipairs(goodguys) do
            if index % groupSize == 1 and index ~= 1 then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((index - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_GOODGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale())  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end

        -- 根据好人英雄数量计算坏人起始位置
        local badguyStartIndex = #goodguys + 1
        if #goodguys % groupSize == 1 then  -- 最后一个好人单独一组
            badguyStartIndex = badguyStartIndex + 1
        end

        -- 重置坏人阵容的起始位置
        currentX = startX + (math.floor((badguyStartIndex - 1) / groupSize) * (groupSpacing + (groupSize - 1) * horizontalSpacing))

        -- 坏人阵容配置
        for index, heroName in ipairs(badguys) do
            local totalIndex = index + badguyStartIndex - 1
            if totalIndex % groupSize == 1 and totalIndex ~= badguyStartIndex then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((totalIndex - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_BADGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale())  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end
    end)
end


function hero_spawn.setupAdvancementCompetitors2()
    -- 等待十秒
    local goodguys = {
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_morphling",
        "npc_dota_hero_riki",
        "npc_dota_hero_ember_spirit"
    }
    
    local badguys = {
        "npc_dota_hero_hoodwink",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_luna",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_razor",
        "npc_dota_hero_ursa"
    }
    
    

    Timers:CreateTimer(10.0, function()
        -- 英雄起始坐标和间隔设置
        local startX, startY, startZ = -1300, 500, 0
        local horizontalSpacing = 200
        local groupSpacing = 300
        local groupSize = 2
        local currentX, currentY = startX, startY

        -- 好人阵容配置
        for index, heroName in ipairs(goodguys) do
            if index % groupSize == 1 and index ~= 1 then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((index - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_GOODGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() *1.1)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end

        -- 根据好人英雄数量计算坏人起始位置
        local badguyStartIndex = #goodguys + 1
        if #goodguys % groupSize == 1 then  -- 最后一个好人单独一组
            badguyStartIndex = badguyStartIndex + 1
        end

        -- 重置坏人阵容的起始位置
        currentX = startX + (math.floor((badguyStartIndex - 1) / groupSize) * (groupSpacing + (groupSize - 1) * horizontalSpacing))

        -- 坏人阵容配置
        for index, heroName in ipairs(badguys) do
            local totalIndex = index + badguyStartIndex - 1
            if totalIndex % groupSize == 1 and totalIndex ~= badguyStartIndex then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((totalIndex - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_BADGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() * 1.1)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end
    end)
end

function hero_spawn.setupAdvancementCompetitors3()
    -- 等待十秒
    local goodguys = {
        "npc_dota_hero_morphling",
        "npc_dota_hero_ember_spirit"
    }
    
    local badguys = {
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_ursa",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_luna",
        "npc_dota_hero_riki",
        "npc_dota_hero_razor"
    }
    
    
    

    Timers:CreateTimer(10.0, function()
        -- 英雄起始坐标和间隔设置
        local startX, startY, startZ = -900, 100, 0
        local horizontalSpacing = 200
        local groupSpacing = 300
        local groupSize = 2
        local currentX, currentY = startX, startY

        -- 好人阵容配置
        for index, heroName in ipairs(goodguys) do
            if index % groupSize == 1 and index ~= 1 then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((index - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_GOODGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() *1.2)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end

        -- 根据好人英雄数量计算坏人起始位置
        local badguyStartIndex = #goodguys + 1
        if #goodguys % groupSize == 1 then  -- 最后一个好人单独一组
            badguyStartIndex = badguyStartIndex + 1
        end

        -- 重置坏人阵容的起始位置
        currentX = startX + (math.floor((badguyStartIndex - 1) / groupSize) * (groupSpacing + (groupSize - 1) * horizontalSpacing))

        -- 坏人阵容配置
        for index, heroName in ipairs(badguys) do
            local totalIndex = index + badguyStartIndex - 1
            if totalIndex % groupSize == 1 and totalIndex ~= badguyStartIndex then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((totalIndex - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_BADGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() * 1.2)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end
    end)
end

function hero_spawn.setupAdvancementCompetitors4()
    -- 等待十秒
    local goodguys = {
        "npc_dota_hero_morphling"
    }
    
    local badguys = {
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_razor"
    }
    
    
    

    Timers:CreateTimer(10.0, function()
        -- 英雄起始坐标和间隔设置
        local startX, startY, startZ = -700, -200, 0
        local horizontalSpacing = 200
        local groupSpacing = 300
        local groupSize = 2
        local currentX, currentY = startX, startY

        -- 好人阵容配置
        for index, heroName in ipairs(goodguys) do
            if index % groupSize == 1 and index ~= 1 then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((index - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_GOODGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() *1.5)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end

        -- 根据好人英雄数量计算坏人起始位置
        local badguyStartIndex = #goodguys + 1
        if #goodguys % groupSize == 1 then  -- 最后一个好人单独一组
            badguyStartIndex = badguyStartIndex + 1
        end

        -- 重置坏人阵容的起始位置
        currentX = startX + (math.floor((badguyStartIndex - 1) / groupSize) * (groupSpacing + (groupSize - 1) * horizontalSpacing))

        -- 坏人阵容配置
        for index, heroName in ipairs(badguys) do
            local totalIndex = index + badguyStartIndex - 1
            if totalIndex % groupSize == 1 and totalIndex ~= badguyStartIndex then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((totalIndex - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_BADGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() * 1.2)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end
    end)
end

function hero_spawn.setupAdvancementCompetitors5()
    -- 等待十秒
    local goodguys = {
        "npc_dota_hero_morphling"
    }
    
    local badguys = {
        "npc_dota_hero_ember_spirit",

    }

    Timers:CreateTimer(15.0, function()
        -- 英雄起始坐标和间隔设置
        local startX, startY, startZ = -500, -400, 0
        local horizontalSpacing = 200
        local groupSpacing = 300
        local groupSize = 2
        local currentX, currentY = startX, startY

        -- 好人阵容配置
        for index, heroName in ipairs(goodguys) do
            if index % groupSize == 1 and index ~= 1 then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((index - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_GOODGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() *2)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end

        -- 根据好人英雄数量计算坏人起始位置
        local badguyStartIndex = #goodguys + 1
        if #goodguys % groupSize == 1 then  -- 最后一个好人单独一组
            badguyStartIndex = badguyStartIndex + 1
        end

        -- 重置坏人阵容的起始位置
        currentX = startX + (math.floor((badguyStartIndex - 1) / groupSize) * (groupSpacing + (groupSize - 1) * horizontalSpacing))

        -- 坏人阵容配置
        for index, heroName in ipairs(badguys) do
            local totalIndex = index + badguyStartIndex - 1
            if totalIndex % groupSize == 1 and totalIndex ~= badguyStartIndex then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((totalIndex - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_BADGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            if newHero:GetUnitName() ~= "npc_dota_hero_monkey_king" then
                newHero:AddItemByName("item_ultimate_scepter_2")
            end
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() * 2)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end
    end)
end


function hero_spawn.setupAdvancementCompetitors6()
    -- 等待十秒
    local goodguys = {
        "npc_dota_hero_earth_spirit"
    }
    
    local badguys = {
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_tusk",
        "npc_dota_hero_sven"
    }

    Timers:CreateTimer(10.0, function()
        -- 英雄起始坐标和间隔设置
        local startX, startY, startZ = -100, -200, 0
        local horizontalSpacing = 100
        local groupSpacing = 200
        local groupSize = 2
        local currentX, currentY = startX, startY

        -- 好人阵容配置
        for index, heroName in ipairs(goodguys) do
            if index % groupSize == 1 and index ~= 1 then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((index - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_GOODGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            newHero:AddItemByName("item_ultimate_scepter_2")
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() * 1.5)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end

        -- 根据好人英雄数量计算坏人起始位置
        local badguyStartIndex = #goodguys + 1
        if #goodguys % groupSize == 1 then  -- 最后一个好人单独一组
            badguyStartIndex = badguyStartIndex + 1
        end

        -- 重置坏人阵容的起始位置
        currentX = startX + (math.floor((badguyStartIndex - 1) / groupSize) * (groupSpacing + (groupSize - 1) * horizontalSpacing))

        -- 坏人阵容配置
        for index, heroName in ipairs(badguys) do
            local totalIndex = index + badguyStartIndex - 1
            if totalIndex % groupSize == 1 and totalIndex ~= badguyStartIndex then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((totalIndex - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_BADGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            newHero:AddItemByName("item_ultimate_scepter_2")
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() * 1.1)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end
    end)
end

function hero_spawn.setupAdvancementCompetitors7()
    -- 等待十秒
    local goodguys = {
        "npc_dota_hero_earth_spirit"
    }
    
    local badguys = {
        "npc_dota_hero_earthshaker",
    }

    Timers:CreateTimer(15.0, function()
        -- 英雄起始坐标和间隔设置
        local startX, startY, startZ = -0, -600, 0
        local horizontalSpacing = 100
        local groupSpacing = 200
        local groupSize = 2
        local currentX, currentY = startX, startY

        -- 好人阵容配置
        for index, heroName in ipairs(goodguys) do
            if index % groupSize == 1 and index ~= 1 then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((index - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_GOODGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            newHero:AddItemByName("item_ultimate_scepter_2")
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() * 1.5)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end

        -- 根据好人英雄数量计算坏人起始位置
        local badguyStartIndex = #goodguys + 1
        if #goodguys % groupSize == 1 then  -- 最后一个好人单独一组
            badguyStartIndex = badguyStartIndex + 1
        end

        -- 重置坏人阵容的起始位置
        currentX = startX + (math.floor((badguyStartIndex - 1) / groupSize) * (groupSpacing + (groupSize - 1) * horizontalSpacing))

        -- 坏人阵容配置
        for index, heroName in ipairs(badguys) do
            local totalIndex = index + badguyStartIndex - 1
            if totalIndex % groupSize == 1 and totalIndex ~= badguyStartIndex then
                currentX = currentX + groupSpacing + (groupSize - 1) * horizontalSpacing
            end
            local positionVector = Vector(currentX + ((totalIndex - 1) % groupSize) * horizontalSpacing, currentY, startZ)

            -- 创建英雄并设置属性
            local newHero = CreateUnitByName(heroName, positionVector, true, nil, nil, DOTA_TEAM_BADGUYS)
            newHero:SetControllableByPlayer(0, true)
            HeroMaxLevel(newHero)
            newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 99999})
            newHero:AddItemByName("item_ultimate_scepter_2")
            newHero:AddItemByName("item_aghanims_shard")
            newHero:SetModelScale(newHero:GetModelScale() * 1.5)  -- 体积缩小20%
            newHero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        end
    end)
end

return hero_spawn