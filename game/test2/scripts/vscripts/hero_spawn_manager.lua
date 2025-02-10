HeroSpawnManager = {}

-- 英雄配置
HeroSpawnManager.heroConfigs = {
    {
        goodguys = {
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_lina",
            "npc_dota_hero_rubick",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_witch_doctor",
            "npc_dota_hero_muerta",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_jakiro",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_silencer",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_zuus",
            "npc_dota_hero_furion",
            "npc_dota_hero_puck",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_pugna",
            "npc_dota_hero_lion",
            "npc_dota_hero_disruptor",
            "npc_dota_hero_lich",
            "npc_dota_hero_tinker",
            "npc_dota_hero_crystal_maiden",
            "npc_dota_hero_oracle",
            "npc_dota_hero_skywrath_mage",
        },
    },
    {
        goodguys = {
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_lich",
            "npc_dota_hero_oracle",
            "npc_dota_hero_disruptor",
            "npc_dota_hero_pugna",
            "npc_dota_hero_puck",
            "npc_dota_hero_jakiro",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_silencer",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_muerta",
            "npc_dota_hero_rubick",
            
        },
        badguys = {
            "npc_dota_hero_lion",
            "npc_dota_hero_tinker",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_furion",
            "npc_dota_hero_zuus",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_witch_doctor",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_crystal_maiden",
            "npc_dota_hero_lina",
            
        },
    },
    {
        goodguys = {
            "npc_dota_hero_puck",
            "npc_dota_hero_silencer",
            "npc_dota_hero_rubick",
            "npc_dota_hero_muerta",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_oracle",
            "npc_dota_hero_pugna",
            
        },
        badguys = {
            "npc_dota_hero_lina",
            "npc_dota_hero_lich",
            "npc_dota_hero_jakiro",
            "npc_dota_hero_disruptor",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_lion",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_necrolyte",
            
        },
    },
    {
        goodguys = {
            "npc_dota_hero_oracle",
            "npc_dota_hero_pugna",
            "npc_dota_hero_silencer",
            "npc_dota_hero_muerta",
            
        },
        badguys = {
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_lina",
            "npc_dota_hero_disruptor",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_rubick",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_puck",
            
        },
    },
    {
        goodguys = {
            "npc_dota_hero_oracle",
            "npc_dota_hero_silencer",
        },
        badguys = {
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_pugna",
            "npc_dota_hero_rubick",
            "npc_dota_hero_muerta",
            "npc_dota_hero_puck",
            "npc_dota_hero_lina",
            "npc_dota_hero_queenofpain",

        },
    },
    {
        goodguys = {
            "npc_dota_hero_oracle"

        },
        badguys = {
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_puck",
            "npc_dota_hero_muerta",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_silencer",
        
        },
    },
    {
        goodguys = {
            "npc_dota_hero_oracle"

        },
        badguys = {

            "npc_dota_hero_puck",
            "npc_dota_hero_muerta",

            "npc_dota_hero_silencer",
        
        },
    },
    {
        goodguys = {
            "npc_dota_hero_oracle"

        },
        badguys = {
            "npc_dota_hero_silencer",
        },
    },





    -- 可以继续添加更多配置...
}

-- 通用设置
HeroSpawnManager.settings = {
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
function HeroSpawnManager:spawnHero(heroName, position, isGoodGuys, scale)
    local newHero = CreateUnitByName(heroName, position, true, nil, nil, isGoodGuys and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS)
    newHero:SetControllableByPlayer(0, true)
    HeroMaxLevel(newHero)
    newHero:AddNewModifier(newHero, nil, "modifier_disarmed", {})
    if heroName ~= "npc_dota_hero_monkey_king" then
        newHero:AddItemByName("item_ultimate_scepter_2")
    end
    newHero:AddItemByName("item_aghanims_shard")
    newHero:AddNewModifier(newHero, nil, "modifier_damage_reduction_100", {})
    newHero:AddNewModifier(newHero, nil, "modifier_break", {})
    newHero:SetModelScale(scale)
    newHero:SetForwardVector(Vector(0, -1, 0))
    return newHero
end

-- 生成一排英雄
function HeroSpawnManager:spawnRow(config, rowIndex)
    local settings = self.settings
    local rowSpacing = settings.defaultHeroWidth * 1.5
    local startY = settings.startY - (rowIndex - 1) * rowSpacing

    local function calculateTeamWidth(team, scale)
        if not team then return 0 end
        local heroCount = #team
        local scaledHeroWidth = settings.defaultHeroWidth * scale
        local totalHeroWidth = heroCount * scaledHeroWidth
        local groupCount = math.ceil(heroCount / settings.groupSize)
        local scaledGroupSpacing = math.min(scaledHeroWidth * 1.8, settings.maxGroupSpacing)
        local totalGroupSpacing = (groupCount - 1) * scaledGroupSpacing
        return totalHeroWidth + totalGroupSpacing
    end

    local function spawnTeam(team, isGoodGuys, startX, scale)
        if not team then return startX end
        local heroCount = #team
        local scaledHeroWidth = settings.defaultHeroWidth * scale
        local scaledGroupSpacing = math.min(scaledHeroWidth * 1.8, settings.maxGroupSpacing)
        
        local currentX = startX
        for index, heroName in ipairs(team) do
            if index % settings.groupSize == 1 and index ~= 1 then
                currentX = currentX + scaledGroupSpacing
            end
            local position = Vector(currentX + scaledHeroWidth / 2, startY, settings.startZ)
            self:spawnHero(heroName, position, isGoodGuys, scale)   
            currentX = currentX + scaledHeroWidth
        end
        return currentX
    end

    -- 检查是否每个阵营只有一个英雄
    local isSingleHeroPerTeam = (config.goodguys and #config.goodguys == 1) and (config.badguys and #config.badguys == 1)
    
    local totalAvailableWidth = settings.totalWidth
    local goodGuysWidth = calculateTeamWidth(config.goodguys, 1)
    local badGuysWidth = calculateTeamWidth(config.badguys, 1)
    local totalTeamWidth = goodGuysWidth + badGuysWidth + settings.teamSeparation

    local scale
    if isSingleHeroPerTeam then
        scale = 3  -- 如果每个阵营只有一个英雄，将比例设置为3
    else
        scale = math.min(2, totalAvailableWidth / totalTeamWidth)
    end
    
    -- 使用实际缩放后的宽度重新计算
    local scaledGoodGuysWidth = calculateTeamWidth(config.goodguys, scale)
    local scaledBadGuysWidth = calculateTeamWidth(config.badguys, scale)
    local scaledTotalWidth = scaledGoodGuysWidth + scaledBadGuysWidth + settings.teamSeparation * scale
    
    local leftStartX = settings.centerX - scaledTotalWidth / 2

    local currentX = leftStartX
    if config.goodguys then
        currentX = spawnTeam(config.goodguys, true, currentX, scale)
    end

    currentX = currentX + settings.teamSeparation * scale

    if config.badguys then
        spawnTeam(config.badguys, false, currentX, scale)
    end
end

-- 压缩现有英雄，排除特定单位
function HeroSpawnManager:compressExistingHeroes()
    local allHeroes = HeroList:GetAllHeroes()
    for _, hero in pairs(allHeroes) do
        -- 检查该单位是否是我们要排除的单位
        if hero ~= Main.caipan then
            local currentPos = hero:GetAbsOrigin()
            hero:SetAbsOrigin(Vector(currentPos.x - self.settings.compressAmount, currentPos.y, currentPos.z))
        end
    end
end

-- 主函数
function HeroSpawnManager:setup()
    local rowCount = #self.heroConfigs
    local currentRow = 1

    local function spawnNextRow()
        if currentRow <= rowCount then
            self:spawnRow(self.heroConfigs[currentRow], currentRow)
            currentRow = currentRow + 1
            return self.settings.spawnInterval
        end
    end

    local function compressAndSpawn()
        self:compressExistingHeroes()
        return spawnNextRow()
    end

    Timers:CreateTimer(0, spawnNextRow)
    -- Timers:CreateTimer(self.settings.compressInterval, compressAndSpawn)
end

return HeroSpawnManager