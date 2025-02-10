function Main:Cleanup_HeroDisplay()

end

function Main:Init_HeroDisplay(heroName, heroFacet,playerID, heroChineseName)
    HeroDisplay_setup()
end

HeroDisplay_heroConfigs = {
    {
        goodguys = {
            "npc_dota_hero_ogre_magi",
        },
        badguys = {
            "npc_dota_hero_magnataur",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_magnataur",
        },
    },
}
-- 通用设置
HeroDisplay_settings = {
    startZ = 256,
    groupSize = 2,
    rowSpacing = 200,  -- 行间距
    compressAmount = 300,  -- 压缩量
    spawnInterval = 30,  -- 生成间隔（秒）
    compressInterval = 20,  -- 压缩间隔（秒）
    totalWidth = 3300,  -- 场地总宽度
    centerX = 100,  -- 场地中心点X坐标
    defaultHeroWidth = 150,  -- 默认英雄宽度
    startY = 1086,  -- 起始Y坐标
    maxGroupSpacing = 300,  -- 最大小组间隔
    teamSeparation = 300  -- 阵营之间的间隔
}

-- 生成单个英雄
function HeroDisplay_spawnHero(heroName, position, isGoodGuys, scale)
    local newHero = CreateUnitByName(heroName, position, true, nil, nil, isGoodGuys and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS)
    newHero:SetControllableByPlayer(0, true)
    -- 检查英雄是否是米波
    if heroName ~= "npc_dota_hero_meepo" then
        HeroMaxLevel(newHero)
    end
    newHero:AddNewModifier(newHero, nil, "modifier_disarmed", {})
    newHero:AddNewModifier(newHero, nil, "modifier_damage_reduction_100", {})
    newHero:AddNewModifier(newHero, nil, "modifier_break", {})
    newHero:SetModelScale(scale)
    if heroName == "npc_dota_hero_ogre_magi" then
        newHero:SetModelScale(0.5)
    end
    newHero:SetForwardVector(Vector(0, -1, 0))
    return newHero
end

-- 生成一排英雄
function HeroDisplay_spawnRow(config, rowIndex, previousRowHeroCounts)
    local settings = HeroDisplay_settings
    local rowSpacing = settings.defaultHeroWidth * 1.5
    local startY = settings.startY - (rowIndex - 1) * rowSpacing
    local spawnedHeroes = {}  -- List to collect heroes spawned in this row

    -- Function to calculate the width of a team
    local function calculateTeamWidth(team, scale, previousCount)
        local heroCount = 0
        if team and #team > 0 then
            heroCount = #team
        elseif previousCount and previousCount > 0 then
            heroCount = previousCount
        else
            heroCount = 0
        end
        if heroCount == 0 then return 0 end
        local scaledHeroWidth = settings.defaultHeroWidth * scale
        local totalHeroWidth = heroCount * scaledHeroWidth
        local groupCount = math.ceil(heroCount / settings.groupSize)
        local scaledGroupSpacing = math.min(scaledHeroWidth * 1.8, settings.maxGroupSpacing)
        local totalGroupSpacing = (groupCount - 1) * scaledGroupSpacing
        return totalHeroWidth + totalGroupSpacing
    end

    -- Determine hero counts using previous counts if necessary
    local goodGuysHeroCount = (config.goodguys and #config.goodguys > 0) and #config.goodguys or previousRowHeroCounts.goodguys
    local badGuysHeroCount = (config.badguys and #config.badguys > 0) and #config.badguys or previousRowHeroCounts.badguys

    -- Check if both hero counts are zero; if so, nothing to do
    if goodGuysHeroCount == 0 and badGuysHeroCount == 0 then
        return spawnedHeroes
    end

    -- Function to calculate total width with scaling
    local function calculateTotalTeamWidth(scale)
        local goodGuysWidth = calculateTeamWidth(config.goodguys, scale, previousRowHeroCounts.goodguys)
        local badGuysWidth = calculateTeamWidth(config.badguys, scale, previousRowHeroCounts.badguys)
        local teamSeparation = (goodGuysWidth > 0 and badGuysWidth > 0) and settings.teamSeparation * scale or 0
        return goodGuysWidth + badGuysWidth + teamSeparation
    end

    -- Determine the scale
    local totalAvailableWidth = settings.totalWidth
    local scale = 1
    local scaledTotalWidth = calculateTotalTeamWidth(scale)

    if scaledTotalWidth > totalAvailableWidth then
        scale = totalAvailableWidth / scaledTotalWidth
    end
    scale = math.min(scale, 2)  -- Limit the maximum scale

    scaledTotalWidth = calculateTotalTeamWidth(scale)
    local leftStartX = settings.centerX - scaledTotalWidth / 2
    local currentX = leftStartX

    -- Function to spawn a team
    local function spawnTeam(team, isGoodGuys, startX, scale, heroCount)
        local heroesToSpawn = team or {}
        if heroCount == 0 then
            return startX
        end

        local scaledHeroWidth = settings.defaultHeroWidth * scale
        local scaledGroupSpacing = math.min(scaledHeroWidth * 1.8, settings.maxGroupSpacing)
        
        local currentX = startX
        local index = 1
        while index <= heroCount do
            if index % settings.groupSize == 1 and index ~= 1 then
                currentX = currentX + scaledGroupSpacing
            end
            local position = Vector(currentX + scaledHeroWidth / 2, startY, settings.startZ)
            if heroesToSpawn[index] then
                local heroName = heroesToSpawn[index]
                local hero = HeroDisplay_spawnHero(heroName, position, isGoodGuys, scale)
                table.insert(spawnedHeroes, hero)
            end
            -- Even if there's no hero to spawn, we still allocate space
            currentX = currentX + scaledHeroWidth
            index = index + 1
        end
        return currentX
    end

    -- Spawn Good Guys
    if goodGuysHeroCount > 0 then
        currentX = spawnTeam(config.goodguys, true, currentX, scale, goodGuysHeroCount)
    end

    -- Add team separation if both sides have heroes
    if goodGuysHeroCount > 0 and badGuysHeroCount > 0 then
        currentX = currentX + settings.teamSeparation * scale
    end

    -- Spawn Bad Guys
    if badGuysHeroCount > 0 then
        currentX = spawnTeam(config.badguys, false, currentX, scale, badGuysHeroCount)
    end

    return spawnedHeroes
end


-- 主函数
function HeroDisplay_setup()
    local rowCount = #HeroDisplay_heroConfigs
    local currentRow = 1
    local previousRowHeroes = nil  -- To keep track of heroes from the previous row
    local previousRowHeroCounts = { goodguys = 0, badguys = 0 }

    local function spawnNextRow()
        if currentRow <= rowCount then
            -- Apply modifier to heroes from the previous row
            if previousRowHeroes then
                for _, hero in pairs(previousRowHeroes) do
                    hero:AddNewModifier(hero, nil, "modifier_invulnerable", {})
                end
            end

            -- Spawn the current row and update previousRowHeroes
            local currentRowHeroes = HeroDisplay_spawnRow(HeroDisplay_heroConfigs[currentRow], currentRow, previousRowHeroCounts)

            -- Update previousRowHeroCounts only if the current row has heroes for that side
            local currentConfig = HeroDisplay_heroConfigs[currentRow]
            if currentConfig.goodguys and #currentConfig.goodguys > 0 then
                previousRowHeroCounts.goodguys = #currentConfig.goodguys
            end
            if currentConfig.badguys and #currentConfig.badguys > 0 then
                previousRowHeroCounts.badguys = #currentConfig.badguys
            end

            previousRowHeroes = currentRowHeroes
            currentRow = currentRow + 1
            return HeroDisplay_settings.spawnInterval
        end
    end

    Timers:CreateTimer(0, spawnNextRow)
    -- Timers:CreateTimer(self.settings.compressInterval, compressAndSpawn)
end

return HeroSpawnManager