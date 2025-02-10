banjiang = {}

-- 函数：在指定坐标创建三个英雄并朝向玩家
function banjiang:CreateHeroes(hero1_name, hero2_name, hero3_name)
    -- 创建第一个英雄并设置朝向和装备
    local hero1 = CreateUnitByName(hero1_name, Vector(150, 2400, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    hero1:SetForwardVector(Vector(0, -1, 0))
    hero1:AddItemByName("item_ultimate_scepter_2")
    hero1:AddItemByName("item_aghanims_shard")
    hero1:SetControllableByPlayer(0, true)  -- 设置英雄由第一个玩家控制
    HeroMaxLevel(hero1)

    -- 创建第二个英雄并设置朝向和装备
    local hero2 = CreateUnitByName(hero2_name, Vector(-400, 2400, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    hero2:SetForwardVector(Vector(0, -1, 0))
    hero2:AddItemByName("item_ultimate_scepter_2")
    hero2:AddItemByName("item_aghanims_shard")
    hero2:SetControllableByPlayer(0, true)  -- 设置英雄由第一个玩家控制
    HeroMaxLevel(hero2)

    -- 创建第三个英雄并设置朝向和装备
    local hero3 = CreateUnitByName(hero3_name, Vector(650, 2400, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    hero3:SetForwardVector(Vector(0, -1, 0))
    hero3:AddItemByName("item_ultimate_scepter_2")
    hero3:AddItemByName("item_aghanims_shard")
    hero3:SetControllableByPlayer(0, true)  -- 设置英雄由第一个玩家控制
    HeroMaxLevel(hero3)
end

-- 函数：根据英雄类型生成英雄
function banjiang:SpawnAllHeroes(heroType)
    local baseLocation = Vector(-400, -600, 0)  -- 基础位置，开始生成英雄的地点
    local interval = 200  -- 英雄之间的间隔
    local team = DOTA_TEAM_GOODGUYS  -- 分配到好人队伍，根据需要进行更改
    local heroesToSpawn = heroCategories[heroType] or heroCategories["strength"]  -- 如果未指定类型或类型不匹配，则默认为力量型

    local numPerRow = math.ceil(math.sqrt(#heroesToSpawn))  -- 计算每行的英雄数
    local currentRow = 0  -- 当前行数
    local currentColumn = 0  -- 当前列数

    for index, heroName in ipairs(heroesToSpawn) do
        local spawnX = baseLocation.x + (currentColumn * interval)
        local spawnY = baseLocation.y + (currentRow * interval)
        local spawnLocation = Vector(spawnX, spawnY, 0)

        local hero = CreateUnitByName(heroName, spawnLocation, true, nil, nil, team)
        hero:SetForwardVector(Vector(0, -1, 0))  -- 设置英雄面向的方向
        hero:SetControllableByPlayer(0, false)  -- 设置英雄由第一个玩家控制
        
        -- 升满级别
        HeroMaxLevel(hero)
        -- 添加 A 杖和魔晶
        hero:AddItemByName("item_ultimate_scepter_2")
        hero:AddItemByName("item_aghanims_shard")

        currentColumn = currentColumn + 1
        if currentColumn >= numPerRow then
            currentColumn = 0
            currentRow = currentRow + 1
        end
    end
end

-- 函数：生成所选类型的英雄
function banjiang:SpawnSelectedHeroes()
    local baseLocation = Vector(-300, -300, 0)  -- 基础位置，开始生成英雄的地点
    local interval = 150  -- 英雄之间的间隔
    local team = DOTA_TEAM_GOODGUYS  -- 分配到好人队伍，根据需要进行更改

    local heroCategories = {
        ["strength"] = {
            "npc_dota_hero_tidehunter"
        },
        ["agility"] = {
            "npc_dota_hero_bloodseeker", "npc_dota_hero_phantom_assassin", "npc_dota_hero_meepo"
        },
        ["intelligence"] = {
            "npc_dota_hero_necrolyte"
        },
        ["universal"] = {
            "npc_dota_hero_dazzle"
        }
    }

    local function spawnHeroes(heroList, baseLocation)
        local numPerRow = math.ceil(math.sqrt(#heroList))  -- 计算每行的英雄数
        local currentRow = 0  -- 当前行数
        local currentColumn = 0  -- 当前列数

        for _, heroName in ipairs(heroList) do
            local spawnX = baseLocation.x + (currentColumn * interval)
            local spawnY = baseLocation.y + (currentRow * interval)
            local spawnLocation = Vector(spawnX, spawnY, 0)

            local hero = CreateUnitByName(heroName, spawnLocation, true, nil, nil, team)
            hero:SetForwardVector(Vector(0, -1, 0))  -- 设置英雄面向的方向
            hero:SetControllableByPlayer(0, false)  -- 设置英雄由第一个玩家控制
            
            -- 升满级别
            HeroMaxLevel(hero)
            -- 添加 A 杖和魔晶
            hero:AddItemByName("item_ultimate_scepter_2")
            hero:AddItemByName("item_aghanims_shard")

            currentColumn = currentColumn + 1
            if currentColumn >= numPerRow then
                currentColumn = 0
                currentRow = currentRow + 1
            end
        end
    end

    -- 设置每个属性类别的初始位置
    local strengthLocation = Vector(baseLocation.x, baseLocation.y, baseLocation.z)
    local agilityLocation = Vector(baseLocation.x + 600, baseLocation.y, baseLocation.z)
    local intelligenceLocation = Vector(baseLocation.x, baseLocation.y + 600, baseLocation.z)
    local universalLocation = Vector(baseLocation.x + 600, baseLocation.y + 600, baseLocation.z)

    -- 生成每个类别的英雄
    spawnHeroes(heroCategories["strength"], strengthLocation)
    spawnHeroes(heroCategories["agility"], agilityLocation)
    spawnHeroes(heroCategories["intelligence"], intelligenceLocation)
    spawnHeroes(heroCategories["universal"], universalLocation)
end

return banjiang
