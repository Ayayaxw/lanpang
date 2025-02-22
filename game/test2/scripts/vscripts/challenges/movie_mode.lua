function Main:Cleanup_movie_mode()

end



function Main:Init_movie_mode(heroName, heroFacet,playerID, heroChineseName)
    local spawnOrigin = Vector(43, -300, 256)  -- 假设的生成位置，您可以根据需要调整
    -- CreateTenAxes()
    --SetupStrengthHeroesScene()
    --SpawnHeroFormations(spawnOrigin)
    --CreateShowcaseScene()
    --SpawnDuelHeroes()
    ---SpawnDiagonalHeroes()--四人斜角排列
    --zongjuesai()--总决赛
    --TestHeroAI()
    --SpawnHeroGrid()--方阵
    --TestCreateTenHeroes()
    --CreateUrsaFormation()
    --PreSpawnStaticCouriers()
    --PreSpawnStaticHeroes()--出场英雄展示
    --CreateAllTeamHeroes()
    --self:TestHeroCreation()
    --SpawnHeroesInFormation()
    --PreSpawnTwoGroupsHeroes()--胜负英雄展示
    --SpawnFourHeroes()--颁奖
    --self:CreateHeroLegion()
    --CreateHeroWithClones()
    --CreateTestHeroes()
    --PrintFirstHeroKV()
    --CreateTestHeroes2()
    --SpawnAndControlAntimage(0)
    --CycleHeroes()
    --Create10RandomHeroes()
    --SpawnHeroesSequence()
    --CreateTestHeroes()
    --SpawnAllNeutralCreeps()   
    --CreateCentaurAndCastSpell()
    --CreateHeroFormation()
    --TestCustomRolling()
    --CreateHeroRows()
    --SpawnAxeBattle()
    --SpawnSimpleHeroGrid()--四人循环赛
    --SetupBristlebackAndLinaScene()
    --SetupRingmasterScene()
    -- SetupHeroMatrix()
    --CreateAxeWithAbility()
    SpawnAllCreepsAndHeroes()
end


function SpawnAllCreepsAndHeroes()
    hero_duel.EndDuel = false

    -- 创建我方蓝胖
    CreateHero(
        0, -- playerId
        "npc_dota_hero_meepo",
        1, -- FacetID
        Main.waterFall_Center, -- 在中心点创建
        DOTA_TEAM_GOODGUYS,  
        true, -- isControllableByPlayer
        function(hero)
            if hero then
                print("食人魔魔法师创建成功")
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                --hero:AddNewModifier(hero, nil, "modifier_invulnerable", {}) -- 添加无敌状态

                hero:SetForwardVector(Vector(0, -1, 0)) -- 朝南
                HeroMaxLevel(hero)
                
                -- 在蓝胖旁边创建中立王
                local kingPos = Vector(Main.waterFall_Center.x + 200, Main.waterFall_Center.y, 128)
                local king = CreateUnitByName(
                    "npc_dota_neutral_king",
                    kingPos,
                    true,
                    nil,
                    nil,
                    DOTA_TEAM_GOODGUYS
                )
                king:SetForwardVector(Vector(0, -1, 0)) -- 朝南
                king:SetControllableByPlayer(0, true) -- 玩家可控制
            end
        end
    )

    local total_creeps = #neutral_units
    local radius = 800
    local delay_per_spawn = 2.0 / total_creeps
    local angle_per_unit = 360 / total_creeps
    local first_unit_created = false

    for i = 1, total_creeps do
        if neutral_units[i] then
            local angle = math.rad(angle_per_unit * (i-1))
            local x = Main.waterFall_Center.x + radius * math.cos(angle)
            local y = Main.waterFall_Center.y + radius * math.sin(angle)
            
            Timers:CreateTimer(delay_per_spawn * (i-1), function()
                print("正在生成: " .. neutral_units[i])
                local unit = CreateUnitByName(
                    neutral_units[i],
                    Vector(x, y, 128),
                    true,
                    nil,
                    nil,
                    DOTA_TEAM_GOODGUYS
                )
                
                unit:SetControllableByPlayer(0, true)
                
                -- 计算朝向圆心的向量
                local direction = Vector(Main.waterFall_Center.x - x, Main.waterFall_Center.y - y, 0)
                direction = direction:Normalized()
                unit:SetForwardVector(direction)
            
                -- 升级所有技能到4级
                local currentUnit = unit  -- 显式保存当前单位的引用
                Timers:CreateTimer(0.5, function()
                    for abilityIndex = 0, 15 do
                        local ability = unit:GetAbilityByIndex(abilityIndex)
                        if ability then
                            if ability:GetName() == "neutral_upgrade" then
                                currentUnit:RemoveAbility("neutral_upgrade")
                            elseif ability:GetName() ~= "stack_units" then
                                ability:SetLevel(4)
                            end
                        end
                    end
                end)
            end)
        end
    end
end





function SpawnAllNeutralCreeps1()
    local neutral_units = {
        [1] = "npc_dota_neutral_kobold",
        [2] = "npc_dota_neutral_kobold_tunneler",
        [3] = "npc_dota_neutral_kobold_taskmaster",
        [4] = "npc_dota_neutral_centaur_outrunner",
        [5] = "npc_dota_neutral_centaur_khan",
        [6] = "npc_dota_neutral_fel_beast",
        [7] = "npc_dota_neutral_polar_furbolg_champion",
        [8] = "npc_dota_neutral_polar_furbolg_ursa_warrior",
        [9] = "npc_dota_neutral_warpine_raider",
        [10] = "npc_dota_neutral_mud_golem",
        [11] = "npc_dota_neutral_mud_golem_split",
        [13] = "npc_dota_neutral_ogre_mauler",
        [14] = "npc_dota_neutral_ogre_magi",
        [15] = "npc_dota_neutral_giant_wolf",
        [16] = "npc_dota_neutral_alpha_wolf",
        [17] = "npc_dota_neutral_wildkin",
        [18] = "npc_dota_neutral_enraged_wildkin",
        [19] = "npc_dota_neutral_satyr_soulstealer",
        [20] = "npc_dota_neutral_satyr_hellcaller",

        [23] = "npc_dota_neutral_prowler_acolyte",
        [24] = "npc_dota_neutral_prowler_shaman",
        [25] = "npc_dota_neutral_rock_golem",
        [26] = "npc_dota_neutral_granite_golem",
        [27] = "npc_dota_neutral_ice_shaman",
        [28] = "npc_dota_neutral_frostbitten_golem",
        [29] = "npc_dota_neutral_big_thunder_lizard",
        [30] = "npc_dota_neutral_small_thunder_lizard",
        [31] = "npc_dota_neutral_gnoll_assassin",
        [32] = "npc_dota_neutral_ghost",
        [33] = "npc_dota_neutral_dark_troll",
        [34] = "npc_dota_neutral_dark_troll_warlord",
        [35] = "npc_dota_neutral_satyr_trickster",
        [36] = "npc_dota_neutral_forest_troll_berserker",
        [37] = "npc_dota_neutral_forest_troll_high_priest",
        [38] = "npc_dota_neutral_harpy_scout",
        [39] = "npc_dota_neutral_harpy_storm",
        [40] = "npc_dota_neutral_black_drake",
        [41] = "npc_dota_neutral_black_dragon",
        [42] = "npc_dota_neutral_tadpole",
        [43] = "npc_dota_neutral_froglet",
        [44] = "npc_dota_neutral_grown_frog",
        [45] = "npc_dota_neutral_ancient_frog",
        [46] = "npc_dota_neutral_froglet_mage",
        [47] = "npc_dota_neutral_grown_frog_mage",
        [48] = "npc_dota_neutral_ancient_frog_mage",
    }
    
    local total_creeps = #neutral_units
    local side_length = math.ceil(math.sqrt(total_creeps))
    local delay_per_spawn = 2.0 / total_creeps
    
    -- 修改起始位置到左上角
    local start_x = -(side_length * 128) / 2
    local start_y = (side_length * 128) / 2
    
    for i = 1, total_creeps do
        local row = math.floor((i-1) / side_length)
        local col = (i-1) % side_length
        local x = start_x + (col * 128)
        local y = start_y - (row * 128) -- 向下为负
        
        Timers:CreateTimer(delay_per_spawn * (i-1), function()
            print("正在生成: " .. neutral_units[i])
            local unit = CreateUnitByName(
                neutral_units[i],
                Vector(x, y, 128),
                true,
                nil,
                nil,
                DOTA_TEAM_NEUTRALS
            )
            
            local angle = math.atan2(y, x)
            unit:SetForwardVector(Vector(-math.cos(angle), -math.sin(angle), 0))
        end)
    end
end


function CreateAxeWithAbility()
    print("开始创建斧王...")  -- 检查函数是否被调用
    
    local playerId = 0
    local spawnPos = Vector(0, 0, 128)
    
    CreateHero(
        playerId,
        "npc_dota_hero_witch_doctor",
        2,
        spawnPos,
        DOTA_TEAM_GOODGUYS,
        true,
        function(hero)
            print("英雄创建回调被触发")  -- 检查回调是否被触发
            
            if hero then
                print("英雄对象存在")  -- 检查英雄是否成功创建
            else
                print("错误：英雄对象为空")
                return
            end
            hero:AddNewModifier(hero, nil, "modifier_custom_unicycle", {})
            -- 添加技能并立即检查
            hero:AddAbility("ringmaster_summon_unicycle")
            print("尝试添加技能")
            
            local ability = hero:FindAbilityByName("ringmaster_summon_unicycle")
            if ability then
                ability:SetLevel(1)
                print("成功添加技能 ringmaster_summon_unicycle")
            else
                print("警告：未能找到技能 ringmaster_summon_unicycle")
            end
            
            -- 延迟检查
            Timers:CreateTimer(0.03, function()
                print("执行延迟检查")
                local checkAbility = hero:FindAbilityByName("ringmaster_summon_unicycle")
                if checkAbility then
                    print("确认：技能添加成功，当前等级：" .. checkAbility:GetLevel())
                else
                    print("错误：技能添加失败，未在英雄身上找到该技能")
                end
            end)
        end
    )
end



function Main:CreateHeroLegion()
    hero_duel.EndDuel = false
    -- 创建主控英雄
    local mainSpawnPos = Vector(0, 0, 0)  -- 设置生成位置
    local mainPlayerId = 0  -- 设置玩家ID
    
    CreateHero(mainPlayerId, "npc_dota_hero_meepo", 1, mainSpawnPos, DOTA_TEAM_GOODGUYS, true, 
    function(mainHero)
        mainHero:AddNewModifier(mainHero, nil, "modifier_item_aghanims_shard", {})
        mainHero:AddNewModifier(mainHero, nil, "modifier_item_ultimate_scepter_consumed", {})
        local ultimate = mainHero:GetAbilityByIndex(5)
        if ultimate then
            mainHero:RemoveAbility(ultimate:GetName())
        end
        -- 添加stack_heroes技能并升级
        mainHero:AddAbility("stack_heroes")
        local stackAbility = mainHero:FindAbilityByName("stack_heroes")
        if stackAbility then
            stackAbility:SetLevel(1)
        end
        HeroMaxLevel(mainHero)
        
        for i = 1, 10 do
            local angle = (360/10) * i
            local radius = 200
            local spawnPos = Vector(
                mainSpawnPos.x + radius * math.cos(math.rad(angle)),
                mainSpawnPos.y + radius * math.sin(math.rad(angle)),
                mainSpawnPos.z
            )
            
            CreateHeroHeroChaos(mainPlayerId, heroes_precache[i].name, 1, spawnPos, DOTA_TEAM_GOODGUYS, false, mainHero,
                function(cloneHero)
                    cloneHero:AddNewModifier(cloneHero, nil, "modifier_item_aghanims_shard", {})
                    cloneHero:AddNewModifier(cloneHero, nil, "modifier_item_ultimate_scepter_consumed", {})
                    HeroMaxLevel(cloneHero)
                    
                    Timers:CreateTimer(2.0, function()
                        if cloneHero:HasModifier("modifier_meepo_megameepo") then
                            -- 给拥有megameepo modifier的单位添加魔法免疫和debuff免疫
                            cloneHero:AddNewModifier(cloneHero, nil, "modifier_magic_immune", {})
                            cloneHero:AddNewModifier(cloneHero, nil, "modifier_debuff_immune", {})
                        end
                        CreateAIForHero(cloneHero, {"超大米波模式"}, nil, "cloneHero" .. i)
                    end)
                end)
        end

        local dummySpawnPos = Vector(0, 400, 0)
        axe = CreateUnitByName("npc_dota_hero_axe", dummySpawnPos, true, nil, nil, DOTA_TEAM_BADGUYS)
        axe:AddNewModifier(axe, nil, "modifier_damage_reduction_100", {})
        HeroMaxLevel(axe)
    end)
end
-- 创建10个随机英雄的函数
function Create10RandomHeroes()
    local heroList = {
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe", 
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe",
        "npc_dota_hero_axe"
    }
    -- 随机打乱英雄列表
    for i = #heroList, 2, -1 do
        local j = math.random(i)
        heroList[i], heroList[j] = heroList[j], heroList[i]
    end
    
    -- 选择前10个英雄创建
    for i = 1, 20 do
        -- 随机生成1或2作为命石ID
        local facetId = math.random(1, 2)
        
        -- 计算不同的出生点位置(这里简单用了间隔)
        local spawnPos = Vector(i * 100, 0, 128)
        
        CreateHero(
            0,                  -- player0
            heroList[i],        -- 随机选择的英雄
            facetId,            -- 随机命石ID
            spawnPos,           -- 出生点
            DOTA_TEAM_GOODGUYS, -- 天辉队伍
            false,               -- 可被控制
            function(hero)
                print(string.format("英雄 %s 创建完成", heroList[i]))
                -- 可以在这里添加额外的英雄设置
            end
        )
    end
end



function SpawnHeroesSequence()
    local firstHeroSpawnPos = Vector(0, 0, 0)  -- 第一个英雄的出生点
    local secondHeroSpawnPos = Vector(100, 0, 0)  -- 第二个英雄的出生点
    local playerId = 0  -- 初始玩家ID
    local heroName = "npc_dota_hero_crystal_maiden"  -- 示例英雄名称
    local facetId = 1
    local team = DOTA_TEAM_GOODGUYS

    -- 创建第一个英雄
    CreateHero(playerId, heroName, facetId, firstHeroSpawnPos, team, true, 
        function(firstHero)
            if firstHero then
                print("第一个英雄创建成功")
                
                -- 获取第一个英雄的playerID
                local parentHeroPlayerId = firstHero:GetPlayerID()
                print("第一个英雄的PlayerID: " .. parentHeroPlayerId)

                -- 创建第二个英雄
                CreateHeroHeroChaos(parentHeroPlayerId, "npc_dota_hero_meepo", facetId, secondHeroSpawnPos, team, true, firstHero,
                    function(secondHero)
                        if secondHero then
                            print("第二个英雄创建成功")
                            
                            -- 5秒后断开第二个英雄的连接
                            Timers:CreateTimer(5.0, function()
                                local secondHeroPlayerId = secondHero:GetPlayerID()
                                print("第二个英雄的PlayerID: " .. secondHeroPlayerId)
                                DisconnectClient(secondHeroPlayerId, true)
                                print("已断开第二个英雄的连接")
                                
                                -- 再等5秒后断开第一个英雄的连接
                                Timers:CreateTimer(5.0, function()
                                    local currentFirstHeroPlayerId = firstHero:GetPlayerID()
                                    print("断开连接前第一个英雄的PlayerID: " .. currentFirstHeroPlayerId)
                                    
                                    -- 使用PlayerResource检查玩家是否还存在
                                    local hPlayer = PlayerResource:GetPlayer(currentFirstHeroPlayerId)
                                    if hPlayer then
                                        print("第一个英雄的玩家实体仍然存在")
                                    else
                                        print("第一个英雄的玩家实体已不存在")
                                    end
                                    
                                    DisconnectClient(currentFirstHeroPlayerId, true)
                                    print("已断开第一个英雄的连接")
                                end)
                            end)
                        end
                    end)
            end
        end)
end

function CycleHeroes()
    local function CreateHeroSequence(playerId, currentFacet)
        if currentFacet > 5 then
            print("所有英雄序列已完成")
            return
        end
        
        print(string.format("开始第 %d 轮测试", currentFacet))

        CreateHero(playerId, "npc_dota_hero_chen", currentFacet, Vector(0,0,0), DOTA_TEAM_GOODGUYS, true,
        function(parentHero)
            local availableHeroes = {}
            local addedHeroes = {} -- 用于追踪已添加的英雄
            local priorityHeroes = {
                "npc_dota_hero_disruptor",
                "npc_dota_hero_dark_seer",
                "npc_dota_hero_crystal_maiden",
                "npc_dota_hero_mars",
                "npc_dota_hero_terrorblade",
                "npc_dota_hero_grimstroke",
                "npc_dota_hero_meepo",
                "npc_dota_hero_monkey_king",
                "npc_dota_hero_weaver"
            }
            
            -- 先检查优先英雄
            for _, heroName in ipairs(priorityHeroes) do
                if heroesFacets[heroName] and heroesFacets[heroName]["Facets"] and 
                   heroesFacets[heroName]["Facets"][currentFacet] then
                    table.insert(availableHeroes, heroName)
                    addedHeroes[heroName] = true -- 标记该英雄已被添加
                    print(string.format("添加优先英雄: %s", heroName))
                end
            end
            
            -- 再添加其他英雄，排除已添加的优先英雄
            for heroName, heroData in pairs(heroesFacets) do
                if not addedHeroes[heroName] and -- 检查是否已添加
                   heroData["Facets"] and 
                   heroData["Facets"][currentFacet] and 
                   heroName ~= "npc_dota_hero_meepo" and 
                   heroName ~= "npc_dota_hero_monkey_king" then
                    table.insert(availableHeroes, heroName)
                    print(string.format("添加普通英雄: %s", heroName))
                end
            end

            local currentHero = nil
            local keepCurrentHero = false

            local function ProcessNextHero(index)
                print(string.format("处理第 %d/%d 个英雄", index, #availableHeroes))
                
                if index > #availableHeroes then
                    if currentHero and not keepCurrentHero then
                        print(string.format("删除最后一个英雄: %s", currentHero:GetUnitName()))
                        UTIL_Remove(currentHero)
                    end
                    
                    local playerID = parentHero:GetPlayerID()
                    print("删除父英雄 Chen")
                    UTIL_Remove(parentHero)
                    DisconnectClient(playerID, true)
                    
                    Timers:CreateTimer(0.1, function()
                        CreateHeroSequence(playerId, currentFacet + 1)
                    end)
                    return
                end

                if currentHero and not keepCurrentHero then
                    print(string.format("删除上一个英雄: %s", currentHero:GetUnitName()))
                    UTIL_Remove(currentHero)
                end

                local heroName = availableHeroes[index]
                keepCurrentHero = (heroName == "npc_dota_hero_meepo" or heroName == "npc_dota_hero_monkey_king" or heroName == "npc_dota_hero_mars") 
                print(string.format("开始创建英雄: %s (保留=%s)", heroName, tostring(keepCurrentHero)))
                
                CreateHeroHeroChaos(playerId, heroName, currentFacet, Vector(0,0,0), DOTA_TEAM_GOODGUYS, true, parentHero,
                
                function(hero)
                    currentHero = hero
                    print(string.format("英雄创建完成: %s", heroName))
                    HeroMaxLevel(hero)
                    hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                    hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                    Timers:CreateTimer(1.0, function()
                        ProcessNextHero(index + 1)
                    end)
                end)
            end

            Timers:CreateTimer(5.0, function()
                if #availableHeroes > 0 then
                    print(string.format("第 %d 轮共有 %d 个英雄需要测试", currentFacet, #availableHeroes))
                    ProcessNextHero(1)
                else
                    print(string.format("第 %d 轮没有可用英雄，进入下一轮", currentFacet))
                    local playerID = parentHero:GetPlayerID()
                    UTIL_Remove(parentHero)
                    DisconnectClient(playerID, true)
                    
                    Timers:CreateTimer(0.1, function()
                        CreateHeroSequence(playerId, currentFacet + 1)
                    end)
                end
            end)
        end)
    end
    
    CreateHeroSequence(0, 1)
end


function CreateTestHeroes2()
    local TEAM = DOTA_TEAM_GOODGUYS
    local SPAWN_POINT = Vector(0, 0, 128)
    local PARENT_SPAWN_POINT = Vector(-500, 0, 128)
    local hPlayer = PlayerResource:GetPlayer(0)
    
    -- Create parent heroes (Chen with different facets)
    local parentHeroes = {}
    
    local function CreateParentHeroes(callback)
        local remaining = 5
        
        for facet = 1, 5 do
            DebugCreateHeroWithVariant(hPlayer, "npc_dota_hero_chen", facet, TEAM, false,
                function(parentHero)
                    if parentHero then
                        parentHero:SetAbsOrigin(PARENT_SPAWN_POINT)
                        parentHeroes[facet] = parentHero
                        
                        remaining = remaining - 1
                        if remaining == 0 and callback then
                            callback()
                        end
                    end
                end)
        end
    end

    -- Create test heroes after parent heroes are created
    CreateParentHeroes(function()
        local spawnOffset = 200  -- Space between spawned heroes
        local currentOffset = 0
        
        -- Convert heroes table to array for sequential creation
        local heroesToCreate = {}
        for heroName, heroData in pairs(heroesFacets) do
            if heroData.Facets then
                for facetId, facetData in pairs(heroData.Facets) do
                    table.insert(heroesToCreate, {
                        name = heroName,
                        facetId = facetId
                    })
                end
            end
        end
        
        -- Create heroes sequentially with delay
        local function CreateNextHero(index)
            if index <= #heroesToCreate then
                local heroInfo = heroesToCreate[index]
                local spawnPos = Vector(SPAWN_POINT.x + currentOffset, SPAWN_POINT.y, SPAWN_POINT.z)
                -- Use corresponding facet parent
                local parentHero = parentHeroes[heroInfo.facetId]
                
                if parentHero then
                    CreateHeroHeroChaos(
                        0,              
                        heroInfo.name,       
                        heroInfo.facetId,    
                        spawnPos,       
                        TEAM,           
                        false,          
                        parentHero,     
                        function(hero)
                            if hero then
                                HeroMaxLevel(hero)
                                -- Select the hero for the player
                                PlayerResource:ReplaceHeroWith(0, hero:GetUnitName(), 0, 0)
                            end
                            
                            currentOffset = currentOffset + spawnOffset
                            -- Schedule next hero creation after 1 second
                            Timers:CreateTimer(1.0, function()
                                CreateNextHero(index + 1)
                            end)
                        end
                    )
                end
            end
        end
        
        -- Start creating heroes
        CreateNextHero(1)
    end)
end

function PrintHeroFacetsCount()
    for heroName, heroData in pairs(Main.heroListKV) do
        if type(heroData) == "table" and heroData.Facets then
            local count = 0
            for _ in pairs(heroData.Facets) do
                count = count + 1
            end
            if count > 0 then
                print(string.format("%s has %d facets", heroName, count))
            end
        end
    end
end
function PrintFirstHeroKV()
    for heroName, heroData in pairs(Main.heroListKV) do
        if type(heroData) == "table" then
            print("Hero Name: " .. heroName)
            DeepPrintTable(heroData)
            return -- 只打印第一个就返回
        end
    end
end

function CreateTestHeroes()
    
    -- 队伍映射
    local teamMapping = {
        [1] = DOTA_TEAM_BADGUYS,    -- 红队
        [2] = DOTA_TEAM_GOODGUYS,   -- 绿队
        [4] = DOTA_TEAM_CUSTOM_1,   -- 蓝队
        [8] = DOTA_TEAM_CUSTOM_2    -- 紫队
    }
    
    -- 测试用的出生点
    local spawnPoints = {
        [DOTA_TEAM_BADGUYS] = Vector(-500, -500, 128),
        [DOTA_TEAM_GOODGUYS] = Vector(-500, 500, 128),
        [DOTA_TEAM_CUSTOM_1] = Vector(500, -500, 128),
        [DOTA_TEAM_CUSTOM_2] = Vector(500, 500, 128)
    }

    -- 母体生成点
    local PARENT_SPAWN_POINT = Vector(0, 0, 128)
    
    -- 要创建的英雄名称
    local heroName = "npc_dota_hero_axe"
    
    -- 为每个阵营创建母体
    local parentHeroes = {}
    local hPlayer = PlayerResource:GetPlayer(0)

    -- 创建四个阵营的母体函数
    local function CreateParentHeroes(callback)
        local remaining = 4
        
        for heroType, team in pairs(teamMapping) do
            DebugCreateHeroWithVariant(hPlayer, "npc_dota_hero_chen", 1, team, false,
                function(parentHero)
                    if parentHero then
                        parentHero:SetAbsOrigin(PARENT_SPAWN_POINT)
                        parentHeroes[heroType] = parentHero
                        
                        remaining = remaining - 1
                        if remaining == 0 and callback then
                            callback()
                        end
                    end
                end)
        end
    end

    -- 创建母体后开始创建测试英雄
    CreateParentHeroes(function()
        -- 为每个队伍创建英雄
        for type, team in pairs(teamMapping) do
            local spawnPos = spawnPoints[team]
            
            -- 每个队伍创建10个英雄，前5个用母体方式，后5个直接创建
            for i = 1, 10 do
                if i <= 5 then
                    -- 使用母体方式创建前5个
                    local parentHero = parentHeroes[type]
                    if parentHero then
                        CreateHeroHeroChaos(
                            0,              
                            heroName,       
                            1,              
                            spawnPos,       
                            team,           
                            false,          
                            parentHero,     
                            function(hero)
                                if hero then
                                    HeroMaxLevel(hero)
                                end
                            end
                        )
                    end
                else
                    -- 直接用CreateUnitByName创建后5个
                    local hero = CreateUnitByName(
                        heroName,
                        spawnPos,
                        true,
                        nil,
                        nil,
                        team
                    )
                    
                    if hero then
                        hero:SetControllableByPlayer(-1, false)
                        HeroMaxLevel(hero)
                    end
                end
            end
        end
    end)
end

function CreateHeroWithClones()
    -- 设置默认值
    local playerId = 0
    local heroName = "npc_dota_hero_crystal_maiden"
    local FacetID = 2
    local centralPosition = Vector(0, 0, 128)

    -- 创建玩家操控的主英雄
    CreateHero(
        playerId,
        heroName, 
        FacetID,
        centralPosition,
        DOTA_TEAM_GOODGUYS,
        true,
        function(mainHero)
            -- 初始化计数器和定时器
            local currentIndex = 1
            local radius = 200
            
            Timers:CreateTimer(function()
                if currentIndex <= #heroes_precache then
                    -- 计算位置
                    local angle = currentIndex * (2 * math.pi / #heroes_precache)
                    local offset = Vector(
                        radius * math.cos(angle),
                        radius * math.sin(angle),
                        0
                    )
                    local clonePosition = centralPosition + offset
                    
                    -- 创建英雄
                    local clone = CreateUnitByName(
                        heroes_precache[currentIndex].name,
                        clonePosition,
                        true,
                        mainHero,
                        mainHero,
                        DOTA_TEAM_GOODGUYS
                    )
                    
                    if clone then
                        clone:SetControllableByPlayer(playerId, true)
                        local hPlayer = PlayerResource:GetPlayer(playerId)
                        hPlayer:SetAssignedHeroEntity(hero)
                    end
                    
                    currentIndex = currentIndex + 1
                    return 0.1 -- 0.5秒后继续执行
                else
                    -- 所有英雄创建完成后，移除主英雄并断开连接
                    UTIL_Remove(mainHero)
                    DisconnectClient(playerId, true)
                    print("已创建所有英雄并移除主英雄")
                    return nil -- 停止定时器
                end
            end)
        end
    )
end


function SpawnAxeBattle()
    local playerID = 0
    local team_good = DOTA_TEAM_GOODGUYS
    local team_bad = DOTA_TEAM_BADGUYS
    
    -- 生成好斧王
    CreateHero(
        playerID,
        "npc_dota_hero_axe",
        1, -- facet id
        Vector(-200, 0, 128),
        team_good,
        true,
        function(good_axe)
            -- 给好斧王三把圣剑
            for i = 1, 3 do
                good_axe:AddItemByName("item_trident")
                good_axe:AddItemByName("item_heart")
            end

        end
    )
    
    -- 生成坏斧王
    CreateHero(
        playerID,
        "npc_dota_hero_axe",
        1, -- facet id
        Vector(200, 0, 128),
        team_bad,
        true,
        function(bad_axe)
            -- 给坏斧王分裂被动技能
            bad_axe:AddAbility("divide_on_death")
            bad_axe:FindAbilityByName("divide_on_death"):SetLevel(1)

        end
    )
    
    -- 打印提示信息
    print("已生成好斧王(带3个圣剑)和坏斧王(带分裂技能)")
    print("好斧王位置: (-200, 0)")
    print("坏斧王位置: (200, 0)")
end



function CreateCentaurAndCastSpell()
    local centaur = CreateUnitByName("npc_dota_hero_centaur", Vector(0, 0, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    
    -- 立即将英雄等级提升到最高
    HeroMaxLevel(centaur)
    
    -- 等待一帧确保单位创建完成
    Timers:CreateTimer(0.01, function()
        -- 释放一技能
        local ability = centaur:FindAbilityByName("centaur_hoof_stomp")
        if ability then
            print("开始施法时间:", GameRules:GetGameTime())
            ExecuteOrderFromTable({
                UnitIndex = centaur:entindex(),
                OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                AbilityIndex = ability:entindex()
            })
        end
    end)
    
    -- 使用多个时间点检查
    local checkTimes = {0.02, 0.05, 0.08, 0.1, 0.15}
    for _, delay in ipairs(checkTimes) do
        Timers:CreateTimer(delay, function()
            local ability = centaur:FindAbilityByName("centaur_hoof_stomp")
            local isInAbilityPhase = false
            local isChanneling = false
            local isActive = false
            local currentActiveAbility = nil
            local isAutoCast = false
            local isToggled = false
            
            if ability then
                isInAbilityPhase = ability:IsInAbilityPhase()
                isChanneling = centaur:IsChanneling()
                isActive = centaur:HasAnyActiveAbilities()
                currentActiveAbility = centaur:GetCurrentActiveAbility()
                isAutoCast = ability:GetAutoCastState()
                isToggled = ability:GetToggleState()
            end
            
            print(string.format("\n检查时间 %.2f:", delay))
            print("技能前摇状态:", isInAbilityPhase)
            print("持续施法状态:", isChanneling)
            print("是否有激活技能:", isActive)
            print("当前激活的技能:", currentActiveAbility and currentActiveAbility:GetName() or "无")
            print("当前激活的技能类型:", type(currentActiveAbility))
            print("自动施法状态:", isAutoCast)
            print("开关状态:", isToggled)
        end)
    end
end
local function CalculateAngle(center, position)
    local dx = position.x - center.x
    local dy = position.y - center.y
    return math.atan2(dy, dx)
end

function TestCustomRolling()
    local lastAngle = nil
    local totalRotation = 0
    local laps = 0
    local TWO_PI = 2 * math.pi
    local bloodseeker = nil

    CreateHero(0, "npc_dota_hero_centaur", 1, Main.largeSpawnCenter + Vector(0, -500, 0), DOTA_TEAM_GOODGUYS, false, function(playerHero)
        playerHero:RemoveAbility("centaur_rawhide")

        -- 创建mofang单位

        
        local mofang = CreateUnitByName("mofang", Main.largeSpawnCenter, true, nil, nil, DOTA_TEAM_GOODGUYS)
        mofang:AddNewModifier(mofang, nil, "modifier_custom_out_of_game", {})
        mofang:AddNewModifier(mofang, nil, "modifier_rooted", {})
        mofang:SetHullRadius(450)
        

        local function MoveMango()
            if not IsValidEntity(bloodseeker) then return end
            
            -- 创建芒果在魔方位置
            local mango = CreateItem("item_famango", nil, nil)
            local container = CreateItemOnPositionSync(mofang:GetAbsOrigin(), mango)
            
            -- 播放音效PauseMinigame.TI10.Lose
            EmitSoundOn("PauseMinigame.TI10.Lose", mofang)
            --EmitSoundOn("ui.ready_check.yes", mofang)
            
            -- 设置定时器来移动芒果
            local startPos = mofang:GetAbsOrigin()
            local duration = 1.2
            local startTime = GameRules:GetGameTime()
            
            Timers:CreateTimer(function()
                if not IsValidEntity(container) or not IsValidEntity(bloodseeker) then
                    if IsValidEntity(container) then
                        UTIL_Remove(container)
                    end
                    return nil
                end
        
                local currentTime = GameRules:GetGameTime()
                local elapsed = currentTime - startTime
                local progress = elapsed / duration
                
                if progress >= 1.0 then
                    UTIL_Remove(container)
                    local new_mango = CreateItem("item_famango", bloodseeker, bloodseeker)
                    bloodseeker:AddItem(new_mango)
                    return nil
                else
                    -- 获取血魔当前位置
                    local currentEndPos = bloodseeker:GetAbsOrigin()
                    -- 线性插值计算当前位置
                    local newPos = startPos + (currentEndPos - startPos) * progress
                    -- 增加抛物线高度
                    newPos.z = startPos.z + math.sin(progress * math.pi) * 400
                    container:SetAbsOrigin(newPos)
                    return 0.03
                end
            end)
        end

        mofang:SetContextThink("MofangFaceThink", function()
            if IsValidEntity(playerHero) and IsValidEntity(mofang) then
                local heroPos = playerHero:GetAbsOrigin()
                local mofangPos = mofang:GetAbsOrigin()
                local direction = (heroPos - mofangPos):Normalized()

                mofang:SetForwardVector(direction)
                
                local currentAngle = CalculateAngle(Main.largeSpawnCenter, heroPos)
                
                if lastAngle then
                    local angleDiff = currentAngle - lastAngle
                    if angleDiff > math.pi then
                        angleDiff = angleDiff - TWO_PI
                    elseif angleDiff < -math.pi then
                        angleDiff = angleDiff + TWO_PI
                    end
                    
                    totalRotation = totalRotation + angleDiff
                    
                    local newLaps = math.floor(math.abs(totalRotation) / TWO_PI)
                    if newLaps > laps then
                        print("完成圈数: " .. newLaps)
                        laps = newLaps
                        MoveMango()
                    end
                end
                
                lastAngle = currentAngle
                
                return 0.03
            end
            return nil
        end, 0)

        HeroMaxLevel(playerHero)

        playerHero:AddNewModifier(playerHero, nil, "modifier_custom_rolling", {
            x = Main.largeSpawnCenter.x,
            y = Main.largeSpawnCenter.y,
            z = Main.largeSpawnCenter.z,
            radius = 500
        })
        
        playerHero:AddNewModifier(playerHero, nil, "modifier_custom_coil", {
            x = Main.largeSpawnCenter.x,
            y = Main.largeSpawnCenter.y,
            z = Main.largeSpawnCenter.z,
            radius = 500
        })
    end)
    
    CreateHero(0, "npc_dota_hero_bloodseeker", 1, Main.largeSpawnCenter + Vector(0, -500, 0), DOTA_TEAM_BADGUYS, false, function(playerHero)
        bloodseeker = playerHero
        HeroMaxLevel(playerHero)
        local player = PlayerResource:GetPlayer(0)
        playerHero:SetControllableByPlayer(0, true)
        player:SetAssignedHeroEntity(playerHero)
    end)
end



function TestGyroshell()
    -- 获取第一个玩家
    local playerID = 0
    local hero = CreateUnitByName("npc_dota_hero_axe", Vector(0,0,128), true, nil, nil, DOTA_TEAM_GOODGUYS)
    
    if hero then
        -- 将英雄分配给玩家
        hero:SetControllableByPlayer(playerID, true)
        -- 设置为玩家的主要英雄
        PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_axe", 0, 0)
        
        -- 添加modifier
        hero:AddNewModifier(hero, nil, "modifier_pangolier_gyroshell", {duration = -1})
    end
end



function CreateHeroFormation()
    local centerPos = Vector(111.74, 600, 128.00)
    local COLUMN_SPACING = 400  -- 列之间的间距
    local HERO_SPACING = 150   -- 同列英雄之间的间距
    
    -- 定义每列的英雄
    local columns = {
        { -- 第一列 (好人)
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_drow_ranger", 
        "npc_dota_hero_spectre",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_ursa",
        "npc_dota_hero_slark",
        "npc_dota_hero_morphling"
        },
        { -- 第二列 (坏人)
        "npc_dota_hero_riki",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_viper",
        "npc_dota_hero_kez",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_troll_warlord", 
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_antimage",
        "npc_dota_hero_hoodwink",

        },
        { -- 第三列 (坏人)
        "npc_dota_hero_sniper",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_meepo",
        "npc_dota_hero_weaver",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_razor",
        "npc_dota_hero_luna",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_ember_spirit",
        }
    }
    
    -- 计算起始位置（使整体阵型居中）
    local startX = centerPos.x - COLUMN_SPACING
    local startY = centerPos.y - ((math.max(#columns[1], #columns[2], #columns[3]) - 1) * HERO_SPACING) / 2
    
    -- 朝北的向量
    local northDirection = Vector(0, -1, 0)
    
    -- 创建所有英雄
    for colIndex, column in ipairs(columns) do
        local currentX = startX + (colIndex - 1) * COLUMN_SPACING
        
        for rowIndex, heroName in ipairs(column) do
            local currentY = startY + (rowIndex - 1) * HERO_SPACING
            local spawnPos = Vector(currentX, currentY, centerPos.z)
            
            -- 根据列数决定队伍
            local team = colIndex == 1 and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
            
            -- 创建英雄并设置朝向
            local hero = CreateUnitByName(heroName, spawnPos, true, nil, nil, team)
            if hero then
                hero:SetForwardVector(northDirection)
                
                -- 添加缴械modifier
                hero:AddNewModifier(hero, nil, "modifier_disarmed", {})
                
                -- 设置英雄等级为最高级(30级)
                while hero:GetLevel() < 30 do
                    hero:HeroLevelUp(true)
                end
            end
        end
    end
end

function CreateHeroRows()
    local centerPos = Vector(111.74, 1292.53, 128.00)
    local heroList = {
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_marci",
        "npc_dota_hero_kez",
        "npc_dota_hero_lina",
        "npc_dota_hero_morphling",
        "npc_dota_hero_invoker",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_brewmaster",
        "npc_dota_hero_shadow_shaman"
    }

    local heroSpacing = 128 -- 同组内两个英雄之间的间距
    local groupSpacing = 256 -- 不同组之间的间距
    local rowOffset = 256 -- 左右两排之间的横向距离
    local depthOffset = 300 -- 前后两排之间的纵向距离
    local heroesPerSection = 6 -- 每个区域放6个英雄（3组）

    for i = 1, #heroList, 2 do
        local groupIndex = math.floor((i-1)/2)
        local section = math.floor((i-1)/heroesPerSection)
        local groupIndexInSection = groupIndex % (heroesPerSection/2)
        
        local yPos = centerPos.y - (groupIndexInSection * (heroSpacing + groupSpacing))
        local xOffset = section * depthOffset
        
        -- 创建左边的英雄（好人）
        local leftHero = CreateUnitByName(heroList[i], Vector(centerPos.x - rowOffset - xOffset, yPos, centerPos.z), true, nil, nil, DOTA_TEAM_GOODGUYS)
        if leftHero then
            leftHero:AddNewModifier(nil, nil, "modifier_disarmed", {})
        end

        -- 如果还有下一个英雄，创建它的左右两个实例
        if heroList[i+1] then
            local yPosNext = yPos - heroSpacing
            
            -- 创建左边的第二个英雄
            local leftHero2 = CreateUnitByName(heroList[i+1], Vector(centerPos.x - rowOffset - xOffset, yPosNext, centerPos.z), true, nil, nil, DOTA_TEAM_GOODGUYS)
            if leftHero2 then
                leftHero2:AddNewModifier(nil, nil, "modifier_disarmed", {})
            end

            -- 创建右边的第二个英雄
            local rightHero2 = CreateUnitByName(heroList[i+1], Vector(centerPos.x + rowOffset + xOffset, yPosNext, centerPos.z), true, nil, nil, DOTA_TEAM_BADGUYS)
            if rightHero2 then
                rightHero2:AddNewModifier(nil, nil, "modifier_disarmed", {})
                HeroMaxLevel(rightHero2)
                rightHero2:SetForwardVector(Vector(-1, 0, 0))
            end
        end

        -- 创建右边的英雄（坏人）
        local rightHero = CreateUnitByName(heroList[i], Vector(centerPos.x + rowOffset + xOffset, yPos, centerPos.z), true, nil, nil, DOTA_TEAM_BADGUYS)
        if rightHero then
            rightHero:AddNewModifier(nil, nil, "modifier_disarmed", {})
            HeroMaxLevel(rightHero)
            rightHero:SetForwardVector(Vector(-1, 0, 0))
        end
    end
end


function SpawnAllNeutralCreeps()
    local creeps = {
        "npc_dota_neutral_wildkin",--枭兽
        "npc_dota_neutral_enraged_wildkin",--枭兽撕裂者
        "npc_dota_neutral_centaur_outrunner",--半人马猎手
        "npc_dota_neutral_centaur_khan",--半人马撕裂者
        "npc_dota_neutral_ogre_mauler",--食人魔拳手
        "npc_dota_neutral_ogre_magi", -- 食人魔冰霜法师
        "npc_dota_neutral_satyr_trickster", --萨特放逐者
        "npc_dota_neutral_satyr_soulstealer", --萨特窃神者
        "npc_dota_neutral_satyr_hellcaller", --萨特苦难使者
        "npc_dota_neutral_dark_troll",--丘陵巨魔
        "npc_dota_neutral_forest_troll_berserker",--丘陵巨魔狂战士
        "npc_dota_neutral_forest_troll_high_priest", --丘陵巨魔牧师
        "npc_dota_neutral_dark_troll_warlord", --黑暗巨魔召唤法师
        "npc_dota_neutral_polar_furbolg_ursa_warrior",--地狱熊怪粉碎者
        "npc_dota_neutral_polar_furbolg_champion",--地狱熊怪
        "npc_dota_neutral_alpha_wolf",--头狼
        "npc_dota_neutral_giant_wolf",--巨狼
        "npc_dota_neutral_harpy_scout",--鹰身女妖侦察者
        "npc_dota_neutral_harpy_storm",--鹰身女妖风暴巫师
        "npc_dota_neutral_kobold",--狗头人
        "npc_dota_neutral_kobold_tunneler",--狗头人士兵
        "npc_dota_neutral_kobold_taskmaster",--狗头人长官
        "npc_dota_neutral_mud_golem",--泥土傀儡
        "npc_dota_neutral_fel_beast",--魔能之魂
        "npc_dota_neutral_ghost",--鬼魂
        "npc_dota_neutral_gnoll_assassin",--豺狼人刺客
        "npc_dota_neutral_warpine_raider",--斗松掠夺者
        "npc_dota_neutral_black_drake",--远古黑蜉蝣
        "npc_dota_neutral_black_dragon",--远古黑龙
        "npc_dota_neutral_granite_golem",--远古花岗岩傀儡
        "npc_dota_neutral_rock_golem",--远古岩石傀儡
        "npc_dota_neutral_ice_shaman",--远古寒冰萨满
        "npc_dota_neutral_frostbitten_golem",--远古霜害傀儡
        "npc_dota_neutral_elder_jungle_stalker",--远古潜行者长老
        "npc_dota_neutral_jungle_stalker",--远古潜行者
        "npc_dota_neutral_prowler_acolyte",--远古侍僧潜行者
        "npc_dota_neutral_prowler_shaman",--远古萨满潜行者
        "npc_dota_neutral_small_thunder_lizard",--远古岚肤兽
        "npc_dota_neutral_big_thunder_lizard"--远古雷肤兽
    }
    
    local total_creeps = #creeps
    local side_length = math.ceil(math.sqrt(total_creeps))
    local delay_per_spawn = 2.0 / total_creeps
    
    -- 修改起始位置到左上角
    local start_x = -(side_length * 128) / 2
    local start_y = (side_length * 128) / 2
    
    for i = 1, total_creeps do
        local row = math.floor((i-1) / side_length)
        local col = (i-1) % side_length
        local x = start_x + (col * 128)
        local y = start_y - (row * 128) -- 向下为负
        
        Timers:CreateTimer(delay_per_spawn * (i-1), function()
            print("正在生成: " .. creeps[i])
            local unit = CreateUnitByName(
                creeps[i],
                Vector(x, y, 128),
                true,
                nil,
                nil,
                DOTA_TEAM_NEUTRALS
            )
            
            local angle = math.atan2(y, x)
            unit:SetForwardVector(Vector(-math.cos(angle), -math.sin(angle), 0))
        end)
    end
end

function Main:TestHeroCreation()
    self.ARENA_CENTER = Vector(150, 150, 128)
    local totalHeroes = 200 
    local currentIndex = 0
    local testedHeroes = {} -- 用于记录测试过的英雄
    local PARALLEL_COUNT = 5 -- 并行创建数量

    local function PrintGameState()
        print("\n========== 游戏状态信息 ==========")
        
        -- 玩家信息
        print("\n----- 玩家信息 -----")
        local playerCount = 0
        for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            local player = PlayerResource:GetPlayer(i)
            if player then
                playerCount = playerCount + 1
                print(string.format("玩家 %d:", i))
                print(string.format("  - 连接状态: %s", PlayerResource:GetConnectionState(i)))
                print(string.format("  - 队伍: %d", PlayerResource:GetTeam(i)))
                print(string.format("  - 英雄: %s", PlayerResource:GetSelectedHeroName(i)))
                print(string.format("  - 击杀: %d", PlayerResource:GetKills(i)))
                print(string.format("  - 死亡: %d", PlayerResource:GetDeaths(i)))
                print(string.format("  - 助攻: %d", PlayerResource:GetAssists(i)))
            end
        end
        print(string.format("总玩家数: %d", playerCount))

        -- 单位信息
        print("\n----- 详细单位列表 -----")
        local allUnits = Entities:FindAllByClassname("npc_dota_*")
        local unitStats = {
            total = 0,
            heroes = {},
            creeps = {},
            buildings = {},
            others = {}
        }

        for _, unit in pairs(allUnits) do
            if unit and not unit:IsNull() then
                unitStats.total = unitStats.total + 1
                local unitName = unit:GetUnitName()
                local unitClass = unit:GetClassname()
                local teamName = unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and "天辉" or 
                               unit:GetTeamNumber() == DOTA_TEAM_BADGUYS and "夜魇" or 
                               "中立"
                
                local unitInfo = string.format("名称: %-30s | 类名: %-30s | 队伍: %s", 
                    unitName, unitClass, teamName)

                if unit:IsHero() then
                    table.insert(unitStats.heroes, unitInfo)
                elseif unit:IsCreep() then
                    table.insert(unitStats.creeps, unitInfo)
                elseif unit:IsBuilding() then
                    table.insert(unitStats.buildings, unitInfo)
                else
                    table.insert(unitStats.others, unitInfo)
                end
            end
        end

        print("\n英雄单位:")
        for _, info in ipairs(unitStats.heroes) do
            print(info)
        end

        print("\n小兵单位:")
        for _, info in ipairs(unitStats.creeps) do
            print(info)
        end

        print("\n建筑单位:")
        for _, info in ipairs(unitStats.buildings) do
            print(info)
        end

        print("\n其他单位:")
        for _, info in ipairs(unitStats.others) do
            print(info)
        end

        print("\n----- 单位详细属性 -----")
        for _, unit in pairs(allUnits) do
            if unit and not unit:IsNull() then
                print(string.format("\n单位: %s", unit:GetUnitName()))
                
                local modifiers = unit:FindAllModifiers()
                if #modifiers > 0 then
                    print("  - 拥有的modifier:")
                    for _, modifier in pairs(modifiers) do
                        if modifier then
                            print(string.format("    * %s (剩余时间: %.1f)", 
                                modifier:GetName(), 
                                modifier:GetRemainingTime()
                            ))
                        end
                    end
                end

                if unit:IsHero() then
                    print("  - 技能列表:")
                    for i = 0, unit:GetAbilityCount() - 1 do
                        local ability = unit:GetAbilityByIndex(i)
                        if ability then
                            print(string.format("    * %s (等级: %d)", 
                                ability:GetAbilityName(), 
                                ability:GetLevel()
                            ))
                        end
                    end
                end
            end
        end

        print("\n================================\n")
    end

    -- 先创建木桩(Axe)
    CreateHero(
        0,
        "npc_dota_hero_axe",
        0,
        self.ARENA_CENTER + Vector(100, 0, 0),
        DOTA_TEAM_GOODGUYS,
        false,
        function(dummyHero)
            if not dummyHero then
                print("[Test] 错误：创建木桩(Axe)失败")
                return
            end


            print("[Test] 成功创建木桩(Axe)")
            self:SetupCombatBuffs(dummyHero)
            dummyHero:AddNewModifier(dummyHero, nil, "modifier_damage_reduction_100", {})

            local function createHeroGroup()
                local completedCount = 0
                local activeHeroes = {}

                for i = 1, PARALLEL_COUNT do
                    currentIndex = currentIndex + 1
                    if currentIndex > totalHeroes then
                        if completedCount >= #activeHeroes then
                            print("[Test] 所有英雄测试完成!")
                            PrintGameState()
                        end
                        return
                    end

                    local heroInfo = heroes_precache[currentIndex]
                    if not heroInfo or not heroInfo.name then
                        print(string.format("[Test] 错误：无法获取第 %d 个英雄的信息", currentIndex))
                        completedCount = completedCount + 1
                        return
                    end

                    table.insert(testedHeroes, heroInfo.name)
                    print(string.format("[Test] 正在测试第 %d/%d 个英雄: %s (%s)", 
                        currentIndex, totalHeroes, heroInfo.chinese, heroInfo.name))

                    -- 计算不同的生成位置
                    local offset = Vector(150 * math.cos(2 * math.pi * i / PARALLEL_COUNT),
                                       150 * math.sin(2 * math.pi * i / PARALLEL_COUNT),
                                       0)
                    local spawnPos = self.ARENA_CENTER + offset

                    CreateHero(
                        0,
                        heroInfo.name,
                        1,
                        spawnPos,
                        DOTA_TEAM_BADGUYS,
                        true,
                        function(hero)
                            if not hero then
                                print(string.format("[Test] 错误：创建英雄失败: %s", heroInfo.chinese))
                                completedCount = completedCount + 1
                                if completedCount >= PARALLEL_COUNT then
                                    Timers:CreateTimer(1, createHeroGroup)
                                end
                                return
                            end
                            local player = PlayerResource:GetPlayer(0)
                            hero:SetControllableByPlayer(0, true)
                            -- player:SetAssignedHeroEntity(hero)
                            table.insert(activeHeroes, hero)
                            print("[Test] 状态: 设置战斗buff")
                            self:SetupCombatBuffs(hero)

                            Timers:CreateTimer(1, function()
                                if not hero:IsNull() then
                                    if not hero:IsAlive() then
                                        hero:RespawnHero(false, false)
                                    end
                                    
                                    local playerID = hero:GetPlayerOwnerID()
                                    if hero:IsHero() and not hero:IsClone() and hero:GetPlayerOwner() then
                                        UTIL_Remove(hero)

                                        DisconnectClient(playerID, true)

                                    else
                                        
                                    end
                                end
                                
                                completedCount = completedCount + 1
                                if completedCount >= PARALLEL_COUNT then
                                    Timers:CreateTimer(1, createHeroGroup)
                                end
                            end)
                        end
                    )
                end
            end

            print("[Test] 开始英雄创建测试")
            print(string.format("[Test] 总共要测试 %d 个英雄", totalHeroes))
            createHeroGroup()
        end
    )
end

function SpawnHeroesInFormation()
    -- 边界间距
    local BOUNDARY_MARGIN = 200
    -- 区域之间的间隔
    local SECTION_GAP = 150

    -- 计算实际可用区域
    local totalWidth = (Main.northEast.x - Main.northWest.x) - (BOUNDARY_MARGIN * 2)
    local totalHeight = (Main.northWest.y - Main.southWest.y) - (BOUNDARY_MARGIN * 2)
    local sectionWidth = (totalWidth - (SECTION_GAP * 3)) / 4

    -- 按type分类英雄
    local heroesByType = {
        [1] = {},
        [2] = {},
        [4] = {},
        [8] = {}
    }

    for _, hero in pairs(heroes_precache) do
        if heroesByType[hero.type] then
            table.insert(heroesByType[hero.type], hero)
        end
    end

    -- 创建英雄的函数
    local function CreateHeroInPosition(heroData, position, team)
        local hero = CreateUnitByName(
            heroData.name,
            position,
            true,
            nil,
            nil,
            team
        )
        if hero then
            -- 设置朝向南方
            hero:SetAngles(0, 180, 0)
            hero:SetForwardVector(Vector(0, -1, 0))

            -- 添加缴械效果
            hero:AddNewModifier(
                hero,
                nil,
                "modifier_disarmed",
                {duration = -1}
            )

            -- 移除所有技能
            for i = 0, 15 do
                local ability = hero:GetAbilityByIndex(i)
                if ability then
                    hero:RemoveAbility(ability:GetAbilityName())
                end
            end

            -- 升级到最高等级
            HeroMaxLevel(hero)
        end
    end

    -- 为每个区域创建英雄
    local delay = 0
    for sectionIndex = 1, 4 do
        local heroList = heroesByType[sectionIndex == 1 and 1 or sectionIndex == 2 and 2 or sectionIndex == 3 and 4 or 8]
        local team = sectionIndex == 1 and DOTA_TEAM_GOODGUYS or 
                    sectionIndex == 2 and DOTA_TEAM_BADGUYS or 
                    sectionIndex == 3 and DOTA_TEAM_CUSTOM_1 or 
                    DOTA_TEAM_CUSTOM_2

        -- 计算该区域的起始和结束X坐标（考虑边界间距和区域间隔）
        local startX = Main.northWest.x + BOUNDARY_MARGIN + 
                      (sectionWidth * (sectionIndex - 1)) + 
                      (SECTION_GAP * (sectionIndex - 1))
        local endX = startX + sectionWidth

        -- 计算行数和每行间距
        local heroCount = #heroList
        local heroesPerRow = 4
        local rows = math.ceil(heroCount / heroesPerRow)
        
        -- 计算Y轴可用空间并确定间距
        local usableHeight = totalHeight
        local ySpacing = usableHeight / (rows + 1)
        local xSpacing = sectionWidth / (heroesPerRow + 1)

        -- 放置英雄
        for i, heroData in ipairs(heroList) do
            local row = math.ceil(i / heroesPerRow)
            local col = ((i - 1) % heroesPerRow) + 1
            
            local x = startX + (col * xSpacing)
            local y = Main.northWest.y - BOUNDARY_MARGIN - (row * ySpacing)
            local position = Vector(x, y, Main.northWest.z)

            -- 使用计时器延迟生成
            Timers:CreateTimer(delay, function()
                CreateHeroInPosition(heroData, position, team)
            end)
            delay = delay + 0.1
        end
    end
end

function CreateAllTeamHeroes()
    -- 英雄池
    local heroPool = {
        "npc_dota_hero_axe",
        "npc_dota_hero_lina",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_zuus",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_lion",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_lich",
        "npc_dota_hero_dazzle"
    }
    

    
    -- 为其他5个队伍各创建1个英雄
    local otherTeams = {
        DOTA_TEAM_GOODGUYS,
        DOTA_TEAM_BADGUYS,
        DOTA_TEAM_CUSTOM_1,
        DOTA_TEAM_CUSTOM_2,
        DOTA_TEAM_CUSTOM_3,
        DOTA_TEAM_CUSTOM_4
    }
    
    for _, team in ipairs(otherTeams) do
        local randomHero = heroPool[RandomInt(1, #heroPool)]
        local randomFacet = RandomInt(1, 2)
        local spawnPos = Vector(RandomInt(-200, 200), RandomInt(-200, 200), 128)
        CreateHero(0, randomHero, randomFacet, spawnPos, team, false)
    end
end

function PreSpawnTwoGroupsHeroes()
    local heroesGroup1 = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_slark",
        "npc_dota_hero_meepo",
        "npc_dota_hero_morphling",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_medusa",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_lich",
        "npc_dota_hero_invoker",
        "npc_dota_hero_pugna",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_axe",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_elder_titan",
        "npc_dota_hero_visage",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_dark_seer"
    }
    
    local heroesGroup2 = {
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_ursa",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_mars",
        "npc_dota_hero_slardar",
        "npc_dota_hero_huskar",
        "npc_dota_hero_lycan",
        "npc_dota_hero_kez",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_obsidian_destroyer"
    }
    
    local heroPool = {}
    local centerPoint = Vector(Main.largeSpawnCenter.x, Main.largeSpawnCenter.y + 500, 0)  -- 中心点向北移动500码
    local spacing = 200  -- 英雄之间的间距
    local groupSpacing = 1000  -- 两组之间的间距
    
    -- 计算每个组的行列数（尽量接近正方形）
    local function calculateGridSize(groupSize)
        local rows = math.ceil(math.sqrt(groupSize))
        local cols = math.ceil(groupSize / rows)
        return rows, cols
    end

    -- 生成一组英雄
    local function spawnHeroGroup(heroes, startPos, isGoodGuys)
        local rows, cols = calculateGridSize(#heroes)
        local groupWidth = (cols - 1) * spacing
        local groupHeight = (rows - 1) * spacing
        local startX = startPos.x - groupWidth/2
        local startY = startPos.y - groupHeight/2
        local groundHeight = GetGroundHeight(Vector(startPos.x, startPos.y, 0), nil)
        
        local heroIndex = 1
        for i = 0, rows-1 do
            for j = 0, cols-1 do
                if heroIndex <= #heroes then
                    local spawnX = startX + (j * spacing)
                    local spawnY = startY + (i * spacing)
                    local spawnPos = Vector(spawnX, spawnY, groundHeight)
                    
                    local hero = CreateUnitByName(
                        heroes[heroIndex],
                        spawnPos,
                        true,
                        nil,
                        nil,
                        isGoodGuys and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
                    )
                    
                    if hero then
                        -- 设置玩家0为控制者
                        hero:SetControllableByPlayer(0, true)
                        
                        -- 移除所有技能
                        for i = 0, 15 do
                            local ability = hero:GetAbilityByIndex(i)
                            if ability then
                                hero:RemoveAbility(ability:GetAbilityName())
                            end
                        end
                        
                        -- 添加其他设置
                        HeroMaxLevel(hero)
                        hero:AddNewModifier(hero, nil, "modifier_disarmed", {})
                        hero:SetForwardVector(Vector(0, -1, 0)) -- 朝南
                        --hero:AddItemByName("item_ultimate_scepter")
                        hero:AddItemByName("item_aghanims_shard")
                        
                        table.insert(heroPool, hero)
                        heroIndex = heroIndex + 1
                    end
                end
            end
        end
    end

    -- 计算两组的生成位置
    local leftPos = Vector(centerPoint.x - groupSpacing/2, centerPoint.y, 0)
    local rightPos = Vector(centerPoint.x + groupSpacing/2, centerPoint.y, 0)

    -- 生成两组英雄
    spawnHeroGroup(heroesGroup1, leftPos, true)   -- 左边天辉
    spawnHeroGroup(heroesGroup2, rightPos, false) -- 右边夜魇

    return heroPool
end


function PreSpawnStaticHeroes()
    local heroes = {
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_riki",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_medusa",
        "npc_dota_hero_furion",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_enigma",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_warlock",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_luna",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_tiny",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_kez",
        "npc_dota_hero_elder_titan",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_pangolier",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_monkey_king"
    }
    
    local heroPool = {}
    local centerPoint = Vector(Main.largeSpawnCenter.x, Main.largeSpawnCenter.y + 500, 0)  -- 中心点向北移动500码
    local spacing = 200  -- 英雄之间的间距增加到200
    local gridSize = 6   -- 6x6的网格
    
    -- 计算起始位置(让整个方阵以新的中心点为中心)
    local startX = centerPoint.x - (spacing * (gridSize-1))/2
    local startY = centerPoint.y - (spacing * (gridSize-1))/2
    local groundHeight = GetGroundHeight(Vector(centerPoint.x, centerPoint.y, 0), nil)

    -- 生成英雄方阵
    local heroIndex = 1
    for i = 0, gridSize-1 do
        for j = 0, gridSize-1 do
            -- 如果还有英雄可以生成
            if heroIndex <= #heroes then
                local spawnX = startX + (i * spacing)
                local spawnY = startY + (j * spacing)
                local spawnPos = Vector(spawnX, spawnY, groundHeight)
                
                -- 创建英雄
                local hero = CreateUnitByName(
                    heroes[heroIndex],
                    spawnPos,
                    true,
                    nil,
                    nil,
                    DOTA_TEAM_GOODGUYS
                )
                
                if hero then
                    -- 设置玩家0为控制者
                    hero:SetControllableByPlayer(0, true)
                    
                    -- 添加其他设置
                    HeroMaxLevel(hero)
                    hero:AddNewModifier(hero, nil, "modifier_disarmed", {})
                    hero:SetForwardVector(Vector(0, -1, 0)) -- 朝南
                    hero:AddItemByName("item_ultimate_scepter")
                    hero:AddItemByName("item_aghanims_shard")
                    
                    table.insert(heroPool, hero)
                    heroIndex = heroIndex + 1
                end
            end
        end
    end

    return heroPool
end


function PreSpawnStaticCouriers()
    courierPool = {}
    local center = Main.largeSpawnCenter
    local spacing = 100  -- 信使之间的间距
    local gridSize = 10 -- 10x10的网格
    
    -- 计算起始位置(让整个方阵以中心点为中心)
    local startX = center.x - (spacing * (gridSize-1))/2
    local startY = center.y - (spacing * (gridSize-1))/2
    local groundHeight = GetGroundHeight(Vector(center.x, center.y, 0), nil)

    -- 生成10x10方阵的信使
    for i = 0, gridSize-1 do
        for j = 0, gridSize-1 do
            local spawnX = startX + (i * spacing)
            local spawnY = startY + (j * spacing)
            local spawnPos = Vector(spawnX, spawnY, groundHeight)
            
            local courierUnit = CreateUnitByName(
                "npc_dota_courier",
                spawnPos,
                true,
                nil,
                nil,
                DOTA_TEAM_GOODGUYS  -- 改为天辉方
            )
            
            if courierUnit then
                -- 设置玩家0为控制者
                courierUnit:SetControllableByPlayer(0, true)
                -- 设置朝南方向
                courierUnit:SetForwardVector(Vector(0, -1, 0))
                table.insert(courierPool, courierUnit)
            end
        end
    end

    -- 在方阵下方300码处生成单独的信使
    local bottomCourierY = startY + 1200
    local bottomCourierPos = Vector(center.x, bottomCourierY, groundHeight)
    
    local bottomCourier = CreateUnitByName(
        "npc_dota_courier",
        bottomCourierPos,
        true,
        nil,
        nil,
        DOTA_TEAM_GOODGUYS  -- 改为天辉方
    )
    
    if bottomCourier then
        -- 设置玩家0为控制者
        bottomCourier:SetControllableByPlayer(0, true)
        -- 设置朝南方向
        bottomCourier:SetForwardVector(Vector(0, -1, 0))
        table.insert(courierPool, bottomCourier)
    end

    -- 为玩家0创建一个斧王在(-1000, -1000)位置
    local axeGroundHeight = GetGroundHeight(Vector(-1000, -1000, 0), nil)

    CreateHero(0, "npc_dota_hero_axe", 1, self.largeSpawnCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
    end)
end

function zongjuesai()
    -- 英雄列表
    local heroes = {
        -- 第一组
        "npc_dota_hero_omniknight",
        
        -- 第二组
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_morphling",
        
        -- 第三组
        "npc_dota_hero_puck", 
        "npc_dota_hero_disruptor",
        
        -- 第四组
        "npc_dota_hero_pangolier",
        "npc_dota_hero_mirana",
        "npc_dota_hero_invoker",
    }

    local centerX = -100
    local centerY = 1000
    local centerZ = 128.00
    
    local spacing = 250        -- 同组英雄间距
    local groupSpacing = 500   -- 组间距离
    
    -- 生成英雄函数
    local function CreateAndSetupHero(heroName, position, team)
        local hero = CreateUnitByName(heroName, position, true, nil, nil, team)
        if hero then
            HeroMaxLevel(hero)
            hero:AddNewModifier(hero, nil, "modifier_disarmed", {})
            hero:SetForwardVector(Vector(0, -1, 0)) -- 朝南
            hero:AddItemByName("item_ultimate_scepter")
            hero:AddItemByName("item_aghanims_shard")
            hero:StartGesture(ACT_DOTA_VICTORY)
        end
        return hero
    end

    local currentX = centerX - 1000  -- 起始位置偏左
    local currentGroup = 1
    local heroCount = #heroes
    local i = 1
    
    while i <= heroCount do
        -- 确定当前在哪个组
        local groupSize
        if currentGroup == 1 then
            groupSize = 1
        elseif currentGroup == 2 then
            groupSize = 2  
        elseif currentGroup == 3 then
            groupSize = 2
        else
            groupSize = 3
        end
        
        -- 生成当前组的英雄
        for j = 1, groupSize do
            if i <= heroCount then
                local position = Vector(currentX, centerY, centerZ)
                CreateAndSetupHero(heroes[i], position, DOTA_TEAM_GOODGUYS)
                currentX = currentX + spacing
                i = i + 1
            end
        end
        
        -- 添加组间距
        currentX = currentX + groupSpacing - spacing
        currentGroup = currentGroup + 1
    end
end



function SpawnDiagonalHeroes()
    -- 英雄列表
    local heroes = {
        -- 第一组
        "npc_dota_hero_omniknight",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_treant",

        -- 第二组
        "npc_dota_hero_slark",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_morphling",
        "npc_dota_hero_troll_warlord",
        
        -- 第三组
        "npc_dota_hero_puck",
        "npc_dota_hero_muerta",
        "npc_dota_hero_disruptor",
        "npc_dota_hero_skywrath_mage",

        -- 第四组
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_mirana",
        "npc_dota_hero_pangolier",
        "npc_dota_hero_invoker",
    }


    local centerX = 128
    local centerY = 435
    local centerZ = 128.00
    local frontRadius = 400    -- 前排英雄到中心的距离
    local backRadius = 600     -- 后排英雄到中心的距离
    local backLineSpacing = 150  -- 后排英雄之间的横向间距

    -- 生成英雄函数
    local function CreateAndSetupHero(heroName, position, team, facing)
        local hero = CreateUnitByName(heroName, position, true, nil, nil, team)
        if hero then
            HeroMaxLevel(hero)
            hero:AddNewModifier(hero, nil, "modifier_disarmed", {})
            hero:SetForwardVector(facing)
            hero:AddItemByName("item_ultimate_scepter")
            hero:AddItemByName("item_aghanims_shard")
            hero:StartGesture(ACT_DOTA_VICTORY)
        end
        return hero
    end

    -- 为四个对角方向分别生成英雄
    for quadrant = 0, 3 do
        -- 计算基础角度（45, 135, 225, 315度）
        local baseAngle = math.pi / 4 + (math.pi / 2 * quadrant)
        
        -- 确定这个象限的队伍（交替使用天辉和夜魇）
        local team = (quadrant % 2 == 0) and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS

        -- 生成前排英雄
        local frontX = centerX + frontRadius * math.cos(baseAngle)
        local frontY = centerY + frontRadius * math.sin(baseAngle)
        local frontPos = Vector(frontX, frontY, centerZ)
        local frontFacing = Vector(centerX - frontX, centerY - frontY, 0):Normalized()
        CreateAndSetupHero(heroes[quadrant * 4 + 1], frontPos, team, frontFacing)

        -- 生成后排三个英雄
        for i = 0, 2 do
            -- 计算后排英雄的位置
            -- 首先找到垂直于基本方向的向量
            local perpAngle = baseAngle + math.pi / 2
            local offsetX = (i - 1) * backLineSpacing * math.cos(perpAngle)
            local offsetY = (i - 1) * backLineSpacing * math.sin(perpAngle)

            -- 计算最终位置
            local posX = centerX + backRadius * math.cos(baseAngle) + offsetX
            local posY = centerY + backRadius * math.sin(baseAngle) + offsetY
            local position = Vector(posX, posY, centerZ)
            
            -- 计算朝向向量（指向中心点）
            local facing = Vector(centerX - posX, centerY - posY, 0):Normalized()
            
            -- 创建英雄
            CreateAndSetupHero(heroes[quadrant * 4 + 2 + i], position, team, facing)
        end
    end
end


function SpawnDuelHeroes()
    -- 英雄列表
    local heroes = {
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_mirana",
        "npc_dota_hero_morphling",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_pangolier",
        "npc_dota_hero_muerta",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_invoker",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_disruptor",
        "npc_dota_hero_treant",
        "npc_dota_hero_slark",
        "npc_dota_hero_puck",

    }

    -- 定义基准点和间距
    local startX = 120
    local startY = 1200
    local endY = -600
    local Z = 128.00
    local heroSpacing = 300
    local sideOffset = 200  -- 英雄离中线的距离

    -- 计算Y轴总距离和每组英雄的间距
    local totalYDistance = startY - endY
    local pairsCount = #heroes / 2
    local ySpacing = totalYDistance / (pairsCount - 1)

    -- 生成英雄函数
    local function CreateAndSetupHero(heroName, position, team, facing)
        local hero = CreateUnitByName(heroName, position, true, nil, nil, team)
        if hero then
            -- 设置等级
            HeroMaxLevel(hero)
            
            -- 添加缴械效果
            hero:AddNewModifier(hero, nil, "modifier_disarmed", {})
            
            -- 设置朝向
            hero:SetForwardVector(facing)
            
            -- 添加神杖和魔晶
            hero:AddItemByName("item_ultimate_scepter")
            hero:AddItemByName("item_aghanims_shard")
        end
        return hero
    end

    -- 生成英雄对
    for i = 0, pairsCount - 1 do
        local currentY = startY - (i * ySpacing)
        
        -- 左边英雄（天辉）
        local leftPos = Vector(startX - sideOffset, currentY, Z)
        local leftHero = CreateAndSetupHero(
            heroes[i * 2 + 1], 
            leftPos, 
            DOTA_TEAM_GOODGUYS, 
            Vector(1, 0, 0)  -- 朝右
        )

        -- 右边英雄（夜魇）
        local rightPos = Vector(startX + sideOffset, currentY, Z)
        local rightHero = CreateAndSetupHero(
            heroes[i * 2 + 2], 
            rightPos, 
            DOTA_TEAM_BADGUYS, 
            Vector(-1, 0, 0)  -- 朝左
        )
    end
end

function TestHeroAI()
    -- 创建两个英雄
    local hero1 = CreateUnitByName("npc_dota_hero_crystal_maiden", Vector(0, 200, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    local hero2 = CreateUnitByName("npc_dota_hero_lina", Vector(0, -200, 0), true, nil, nil, DOTA_TEAM_BADGUYS)
    
    -- 给予物品和等级
    for _, hero in pairs({hero1, hero2}) do
        hero:AddItemByName("item_ultimate_scepter_2")
        hero:AddItemByName("item_aghanims_shard")
        HeroMaxLevel(hero)
        hero:AddItemByName("item_attribute_amplifier_5x")
        hero:SetForwardVector((Vector(0,0,0) - hero:GetOrigin()):Normalized())
    end
    
    -- 延迟1秒后添加AI，用不同的参数组合测试
    Timers:CreateTimer(1.0, function()
        -- 测试完整参数
        CreateAIForHero(hero1, 
            {""}, 
            {""}, 
            "冰女测试AI", 
            0.1
        )
        
        -- 测试部分参数
        CreateAIForHero(hero2, 
            {"激进"}, 
            {"打架"}, 
            "火女AI",
            0.1
        )
    end)
end

function CreateShowcaseScene()
    -- 首先定义英雄组
    local heroesTopThree = {  -- 2-4名
        -- "npc_dota_hero_sven",
        -- "npc_dota_hero_magnataur",
        -- "npc_dota_hero_meepo"
    }

    local heroesGroup1 = {
        "npc_dota_hero_ursa",
        "npc_dota_hero_meepo",
        "npc_dota_hero_muerta",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_brewmaster"
    }
    
    local heroesGroup2 = {
        "npc_dota_hero_morphling",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_elder_titan",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_slark",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_slardar",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_silencer",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_luna",
        "npc_dota_hero_razor"
    }
    
    

    -- 定义区域边界
    local leftTop = Vector(-1545.49, 1304.38, 128.00)
    local rightTop = Vector(1807.50, 1315.75, 128.00)
    local leftBottom = Vector(-1554.88, -783.70, 128.00)
    local rightBottom = Vector(1805.30, -786.40, 128.00)

    -- 计算中心和范围
    local totalWidth = rightTop.x - leftTop.x
    local centerX = (leftTop.x + rightTop.x) / 2
    local northY = leftTop.y - 100  -- 最北边的起始位置

    -- 添加禁用效果的函数
    local function AddDisablingModifiers(hero)
        if hero and not hero:IsNull() then
            hero:AddNewModifier(hero, nil, "modifier_rooted", {})
            hero:AddNewModifier(hero, nil, "modifier_disarmed", {})
            
        end
    end

    -- 第一列：并列第一（最左边）
    local column1X = centerX - totalWidth/4  -- 左半场中心
    local heroSpacing = 200
    
    for i, heroName in ipairs(heroesGroup1) do
        local position = Vector(column1X, northY - (i-1) * heroSpacing, 128.00)
        local hero = CreateUnitByName(heroName, position, true, nil, nil, DOTA_TEAM_GOODGUYS)
        if hero then
            hero:SetForwardVector(Vector(0, -1, 0))
            Timers:CreateTimer(0.1, function()
                if hero and not hero:IsNull() then
                    AddDisablingModifiers(hero)
                    hero:StartGesture(ACT_DOTA_VICTORY)
                    local particle = ParticleManager:CreateParticle("particles/econ/events/ti10/fountain_effect_ti10.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
                    return nil
                end
            end)
        end
    end

    -- 第二列：2-4名（中间）
    local column2X = centerX  -- 地图中心
    
    for i, heroName in ipairs(heroesTopThree) do
        local position = Vector(column2X, northY - (i-1) * heroSpacing, 128.00)
        local hero = CreateUnitByName(heroName, position, true, nil, nil, DOTA_TEAM_BADGUYS)
        if hero then
            hero:SetForwardVector(Vector(0, -1, 0))
            Timers:CreateTimer(0.1, function()
                if hero and not hero:IsNull() then
                    AddDisablingModifiers(hero)
                    hero:StartGesture(ACT_DOTA_VICTORY)
                    local particle = ParticleManager:CreateParticle("particles/econ/events/ti9/ti9_monkey_king_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
                    return nil
                end
            end)
        end
    end

    -- 第三列：其他参赛选手（最右边）
    local column3X = centerX + totalWidth/4  -- 右半场中心
    local rowSpacing = 180
    local colSpacing = 180
    local heroesPerRow = 7
    local rightStartX = column3X - (heroesPerRow * colSpacing) / 2

    for i, heroName in ipairs(heroesGroup2) do
        local row = math.floor((i-1) / heroesPerRow)
        local col = (i-1) % heroesPerRow
        local position = Vector(
            rightStartX + col * colSpacing,
            northY - row * rowSpacing,
            128.00
        )
        local hero = CreateUnitByName(heroName, position, true, nil, nil, DOTA_TEAM_BADGUYS)
        if hero then
            hero:SetForwardVector(Vector(0, -1, 0))
            Timers:CreateTimer(0.1, function()
                if hero and not hero:IsNull() then
                    AddDisablingModifiers(hero)
                    return nil
                end
            end)
        end
    end
end

function CreateUrsaFormation()
    -- 定义场地四个角坐标
    local cornerCoords = {
        Vector(-1545.49, 1304.38, 128.00),  -- 左上
        Vector(1807.50, 1315.75, 128.00),   -- 右上
        Vector(-1554.88, -783.70, 128.00),  -- 左下
        Vector(1805.30, -786.40, 128.00)    -- 右下
    }

    -- 定义边界
    local minX = math.min(cornerCoords[1].x, cornerCoords[3].x)  
    local maxX = math.max(cornerCoords[2].x, cornerCoords[4].x)  
    local minY = math.min(cornerCoords[3].y, cornerCoords[4].y)  
    local maxY = math.max(cornerCoords[1].y, cornerCoords[2].y)  
    
    -- 计算区域大小
    local width = maxX - minX
    local height = maxY - minY
    local midY = (maxY + minY) / 2  -- 中点Y坐标
    
    -- 计算网格大小 (300个单位)
    local totalCount = 300
    local halfCount = totalCount / 2
    
    -- 分别计算上下区域的行列数
    local heightHalf = height / 2
    local rowsPerHalf = math.floor(math.sqrt(halfCount * (heightHalf/width)))
    local colsPerHalf = math.ceil(halfCount / rowsPerHalf)
    
    -- 计算间距
    local xSpacing = width / (colsPerHalf + 1)
    local ySpacingHalf = heightHalf / (rowsPerHalf + 1)
    
    -- 创建拍拍熊池
    local ursaPool = {}
    local currentCount = 0
    
    -- 计算生成间隔
    local totalTime = 10.0  -- 10秒内完成
    local interval = totalTime / totalCount
    
    -- 创建定时器进行分批生成
    local isNorthSection = true  -- 先生成北部
    local row = 1
    local col = 1
    
    Timers:CreateTimer(function()
        if currentCount >= totalCount then
            return nil
        end
        
        -- 计算位置
        local x = minX + (col * xSpacing)
        local y
        if isNorthSection then
            y = midY + (row * ySpacingHalf)  -- 北部
        else
            y = midY - (row * ySpacingHalf)  -- 南部
        end
        
        -- 创建拍拍熊
        local ursa = CreateUnitByName(
            "npc_dota_hero_ursa",
            Vector(x, y, 128),
            true,
            nil,
            nil,
            DOTA_TEAM_BADGUYS
        )
        
        -- 设置朝向（朝北）
        ursa:SetForwardVector(Vector(0, 1, 0))
        
        -- 升级到1级
        while ursa:GetLevel() < 1 do
            ursa:HeroLevelUp(false) -- 升一级，不播放特效
        end
        
        -- 添加无敌和隐身修饰器
        ursa:AddNewModifier(ursa, nil, "modifier_invulnerable", {})

        
        table.insert(ursaPool, ursa)
        currentCount = currentCount + 1
        
        -- 更新行列计数
        col = col + 1
        if col > colsPerHalf then
            col = 1
            row = row + 1
            
            -- 如果当前区域的行都填充完了，切换到另一个区域
            if row > rowsPerHalf then
                if isNorthSection then
                    isNorthSection = false  -- 切换到南部
                    row = 1
                    col = 1
                end
            end
        end
        
        -- 继续定时器
        return interval
    end)
    
    return ursaPool
end

function TestCreateTenHeroes()
    local spawnPosition = Vector(0, 0, 128)
    local spacing = 200
    local heroes = {
        "npc_dota_hero_invoker",
        "npc_dota_hero_lina", 
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_pudge",
        "npc_dota_hero_axe",
        "npc_dota_hero_sniper",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_zuus",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_axe"
    }
    
    -- Store created heroes
    local createdHeroes = {}
    local LOG_PREFIX = "[TestCreateTenHeroes] "

    -- Clean up previously created heroes
    local function ClearPreviousHeroes()
        print(LOG_PREFIX .. "Starting to clean up previous heroes...")
        for index, hero in ipairs(createdHeroes) do
            if hero and not hero:IsNull() and hero.GetPlayerID then
                local playerID = hero:GetPlayerID()
                print(LOG_PREFIX .. "Cleaning up hero for player ID " .. playerID)
                
                if hero:IsHero() and not hero:IsClone() and hero:GetPlayerOwner() and hero:GetPlayerOwnerID() ~= 0 then
                    DisconnectClient(playerID, true)
                else
                    if hero and not hero:IsNull() then
                        hero:RemoveSelf()
                    end
                end
            else
                print(LOG_PREFIX .. "Error: Invalid hero entity at index " .. index)
            end
        end
        createdHeroes = {}
        print(LOG_PREFIX .. "Cleanup completed")
    end

    local function CreateNextHero(index)
        if index > #heroes then
            print(LOG_PREFIX .. "\nAll heroes created successfully!")
            return
        end

        print(LOG_PREFIX .. "\nPreparing to create hero #" .. index .. ": " .. heroes[index])

        local position = Vector(
            spawnPosition.x + spacing * math.floor((index-1)/2),
            spawnPosition.y + spacing * ((index-1) % 2),
            spawnPosition.z
        )

        local player = PlayerResource:GetPlayer(0)
        if not player then
            print(LOG_PREFIX .. "Error: Player 0 not found!")
            return
        end

        print(LOG_PREFIX .. "Creating hero using player 0: " .. heroes[index])
        DebugCreateHeroWithVariant(player, heroes[index], 1, DOTA_TEAM_GOODGUYS, false,
            function(hero)
                if hero then
                    print(LOG_PREFIX .. "Hero created successfully: " .. hero:GetUnitName())
                    
                    -- Set hero properties
                    hero:SetControllableByPlayer(0, true)
                    hero:SetRespawnPosition(position)
                    FindClearSpaceForUnit(hero, position, true)
                    hero:SetIdleAcquire(true)
                    hero:SetAcquisitionRange(1000)
                    
                    -- Add hero to records
                    table.insert(createdHeroes, hero)
                    
                    print(LOG_PREFIX .. "Hero properties set")
                    print(LOG_PREFIX .. "Current position: " .. tostring(hero:GetAbsOrigin()))
                    
                    -- Disconnect previous hero's player if not first hero
                    if index > 1 then
                        local previousHero = createdHeroes[index-1]
                        if previousHero and not previousHero:IsNull() and previousHero.GetPlayerID then
                            local playerID = previousHero:GetPlayerID()
                            if playerID ~= 0 then
                                print(LOG_PREFIX .. "Disconnecting previous hero's player (ID: " .. playerID .. ")")
                                DisconnectClient(playerID, true)
                            end
                        end
                    end
                    
                    -- Delay next hero creation
                    Timers:CreateTimer(0.5, function()
                        CreateNextHero(index + 1)
                    end)
                else
                    print(LOG_PREFIX .. "Error: Failed to create hero: " .. heroes[index])
                end
            end)
    end

    -- Start execution
    print(LOG_PREFIX .. "\nStarting hero creation process...")
    ClearPreviousHeroes()
    
    Timers:CreateTimer(1.0, function()
        print(LOG_PREFIX .. "Beginning hero creation...")
        CreateNextHero(1)
    end)
end

function SpawnFourHeroes()
    local heroData = {
        {name = "npc_dota_hero_sand_king", position = Vector(767.79, 6149.44, 384.00)},
        --{name = "npc_dota_hero_earthshaker", position = Vector(767.79, 6149.44, 384.00)},
        {name = "npc_dota_hero_witch_doctor", position = Vector(1028.40, 6142.33, 256.00)},
        {name = "npc_dota_hero_leshrac", position = Vector(505.00, 6144.75, 128.00)},
        --{name = "npc_dota_hero_ember_spirit", position = Vector(505.00, 6144.75, 128.00)},
        {name = "npc_dota_hero_sven", position = Vector(1335.26, 6084.06, 0.00)}
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

function SpawnSimpleHeroGrid()
    local heroes = {
        "npc_dota_hero_omniknight",
        
        -- 第二组
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_morphling",
        
        -- 第三组
        "npc_dota_hero_disruptor",
        
        -- 第四组
        "npc_dota_hero_pangolier",
        "npc_dota_hero_mirana",
        "npc_dota_hero_invoker",
        "npc_dota_hero_puck",
    }
    
    local function SetupHero(newHero)
        newHero:SetControllableByPlayer(0, true)
        HeroMaxLevel(newHero)
        newHero:AddNewModifier(newHero, nil, "modifier_disarmed", {})
        newHero:AddNewModifier(newHero, nil, "modifier_damage_reduction_100", {})
        newHero:AddNewModifier(newHero, nil, "modifier_break", {})
    end
    
    -- Center point
    local centerX = -700
    local centerY = 1200
    
    -- Spawn badguys (horizontal row, facing south)
    for i, heroName in ipairs(heroes) do
        local position = Vector(centerX + 250 + (i-1) * 250, centerY, 0)
        local newHero = CreateUnitByName(heroName, position, true, nil, nil, DOTA_TEAM_BADGUYS)
        SetupHero(newHero)
        newHero:SetForwardVector(Vector(0, -1, 0))  -- Facing south
    end
    
    -- Spawn goodguys (vertical column, from north to south, facing east)
    for i, heroName in ipairs(heroes) do
        local position = Vector(centerX, centerY - 250 - (i-1) * 250, 0)
        local newHero = CreateUnitByName(heroName, position, true, nil, nil, DOTA_TEAM_GOODGUYS)
        SetupHero(newHero)
        newHero:SetForwardVector(Vector(1, 0, 0))  -- Facing east
    end
end


function CreateTenAxes()
    local axeCount = 0
    local spawnInterval = 0.5
    local totalAxes = 10
    local heroName = "npc_dota_hero_axe"
    local FacetID = 1
    local team = DOTA_TEAM_GOODGUYS
    local isControllableByPlayer = true
    local playerIdToControl = 0  -- 始终使用玩家0

    local function RemoveExcessBots()
        for i = 1, DOTA_MAX_TEAM_PLAYERS - 1 do
            if PlayerResource:IsValidPlayer(i) then
                print("移除机器人玩家 ID: " .. i)
                DisconnectClient(i, true)
            end
        end
    end

    local function PrintPlayerList()
        print("当前玩家列表:")
        local playerCount = PlayerResource:GetPlayerCount()
        print("玩家总数: " .. playerCount)
        
        for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            if PlayerResource:IsValidPlayer(i) then
                local playerName = PlayerResource:GetPlayerName(i)
                local hero = PlayerResource:GetSelectedHeroEntity(i)
                local heroName = hero and hero:GetUnitName() or "无英雄"
                print(string.format("玩家 ID: %d, 名称: %s, 英雄: %s", i, playerName, heroName))
            else
                print("玩家 ID " .. i .. " 无效")
            end
        end
    end

    local function SpawnNextAxe()
        if axeCount < totalAxes then
            axeCount = axeCount + 1
            local spawnPosition = Vector(0, 128 * axeCount, 128)
            
            print("尝试创建斧王 #" .. axeCount .. " 给玩家ID: " .. playerIdToControl)

            CreateHero(playerIdToControl, heroName, FacetID, spawnPosition, team, isControllableByPlayer,
                function(hero)
                    if hero then
                        print("斧王 #" .. axeCount .. " 已生成，分配给玩家ID: " .. playerIdToControl)

                        -- 确保英雄被正确分配给玩家0
                        local player = PlayerResource:GetPlayer(playerIdToControl)
                        if player then
                            player:SetAssignedHeroEntity(hero)
                        else
                            print("警告: 未找到玩家实体，无法分配英雄")
                        end

                        -- 移除多余的机器人
                        RemoveExcessBots()

                        -- 打印当前玩家列表
                        PrintPlayerList()

                        -- 如果还有斧王需要生成，则安排下一个
                        if axeCount < totalAxes then
                            Timers:CreateTimer(spawnInterval, SpawnNextAxe)
                        else
                            print("所有" .. totalAxes .. "个斧王已生成完毕")
                        end
                    else
                        print("创建斧王失败")
                    end
                end
            )
        end
    end

    print("开始生成斧王进程")
    PrintPlayerList()  -- 在开始生成之前打印一次玩家列表
    SpawnNextAxe()
end


function CreateAndControlOgreMagi()
    -- 创建 Ogre Magi 英雄
    local hero = CreateUnitByName("npc_dota_hero_ogre_magi", Vector(0, 0, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    
    -- 将英雄交给玩家0控制
    local player = PlayerResource:GetPlayer(0)
    if player then
        hero:SetControllableByPlayer(0, true)
    end
    
    -- 获取原始模型比例
    local originalScale = hero:GetModelScale()
        -- 倒置英雄
        hero:SetModelScale(-originalScale)
    hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
    hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
    HeroMaxLevel(hero)

    hero:AddNewModifier(hero, nil, "modifier_constant_height_adjustment", {height_adjustment = 250})
    
    return hero
end

function SetupHeroMatrix()
    local center = Vector(43, 255, 256)
    local spacing = 200  -- 英雄之间的间距

    local allies = {
        "razor", "ogre_magi", "luna", "lina", "mars", 
        "meepo", "obsidian_destroyer", "death_prophet", 
        "slark", "slardar", "marci", "shadow_shaman", 
        "nevermore", "necrolyte", 
        "lich", "tinker", "riki", "viper", "juggernaut", "shredder", "undying", "ringmaster"
    }

    local enemies = {
        "monkey_king", "primal_beast", "muerta", "chaos_knight", "doom_bringer",
        "ursa", "shadow_demon", "terrorblade", "spectre", "pugna", 
        "phantom_assassin", "troll_warlord", "nyx_assassin", "morphling"
    }

    local function SetupHero(hero)
        if hero and IsValidEntity(hero) then
            HeroMaxLevel(hero)  -- 假设最大等级是30
            hero:AddNewModifier(hero, nil, "modifier_disarmed", {})

            hero:AddItemByName("item_aghanims_shard")
        else
            print("Warning: Attempted to setup an invalid hero")
        end
    end

    local heroMatrix = {}

    -- 创建友方英雄
    for i, heroName in ipairs(allies) do
        local row = math.ceil(i / 5)
        local col = (i - 1) % 5 + 1
        local pos = center + Vector((col - 3) * spacing, (row - 3) * spacing, 0)
        local hero = CreateUnitByName("npc_dota_hero_" .. heroName, pos, true, nil, nil, DOTA_TEAM_GOODGUYS)
        if hero and IsValidEntity(hero) then
            SetupHero(hero)
            hero:SetForwardVector(Vector(0, 0, 0))
            table.insert(heroMatrix, hero)
        else
            print("Failed to create hero: " .. heroName)
        end
    end

    -- 创建敌方英雄
    for i, heroName in ipairs(enemies) do
        local row = math.ceil(i / 5) + 5
        local col = (i - 1) % 5 + 1
        local pos = center + Vector((col - 3) * spacing, (row - 3) * spacing, 0)
        local hero = CreateUnitByName("npc_dota_hero_" .. heroName, pos, true, nil, nil, DOTA_TEAM_BADGUYS)
        if hero and IsValidEntity(hero) then
            SetupHero(hero)
            hero:SetForwardVector(Vector(0, -1, 0))  -- 朝南
        else
            print("Failed to create hero: " .. heroName)
        end
    end

    -- 10秒后替换友方英雄为bristleback
    Timers:CreateTimer(10, function()
        for i, hero in ipairs(heroMatrix) do
            if hero and IsValidEntity(hero) then
                local playerID = hero:GetPlayerOwnerID()
                local pos = hero:GetAbsOrigin()
                local newHero = PlayerResource:ReplaceHeroWith(0, "npc_dota_hero_bristleback", 0, 0)
                
                if newHero and IsValidEntity(newHero) then
                    SetupHero(newHero)
                    newHero:SetAbsOrigin(pos)
                    newHero:SetForwardVector(Vector(0, 0, 0))
                    -- 更新heroMatrix中的引用
                    heroMatrix[i] = newHero
                else
                    print("Failed to replace hero with Bristleback for player " .. 0)
                end
            else
                print("Invalid hero in heroMatrix at index " .. i)
            end
        end
        print("All allied heroes have been replaced with Bristleback.")
    end)

    print("Hero matrix created successfully!")
end
function SpawnHeroFormations(origin)
    local leftHeroes = {
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_silencer",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_pugna"
    }

    local rightHeroes = {
        "npc_dota_hero_sven",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_morphling",
        "npc_dota_hero_pangolier",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_marci",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_slark",
        "npc_dota_hero_muerta",
        "npc_dota_hero_lich",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_meepo",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_spectre",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_mars",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_pudge",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_elder_titan",
        "npc_dota_hero_zuus",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_furion",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_luna",
        "npc_dota_hero_medusa"
    }

    local heroSpacing = 200
    local formationSpacing = 0
    local leftSize = math.ceil(math.sqrt(#leftHeroes))
    local rightSize = math.ceil(math.sqrt(#versatileHeroes))

    -- Calculate the southernmost point
    local maxSouthY = math.max(
        origin.y - (leftSize - 1) * heroSpacing / 2,
        origin.y - (rightSize - 1) * heroSpacing / 2
    )

    -- Spawn left heroes
    SpawnHeroSquare(leftHeroes, Vector(origin.x - formationSpacing/2, maxSouthY, origin.z), leftSize, heroSpacing, true)

    -- Spawn right heroes
    SpawnHeroSquare(versatileHeroes, Vector(origin.x + formationSpacing/2, maxSouthY, origin.z), rightSize, heroSpacing, false)
end

function SpawnHeroSquare(heroes, southCenterPosition, size, spacing, isLeft)
    for i = 1, #heroes do
        local row = math.floor((i-1) / size)
        local col = (i-1) % size
        local position = Vector(
            southCenterPosition.x + (col - size/2 + 0.5) * spacing,
            southCenterPosition.y + row * spacing,
            southCenterPosition.z
        )
        SpawnHero(heroes[i], position, isLeft)
    end
end


function SpawnHero(heroName, position, isLeft)
    local hero = CreateUnitByName(heroName, position, true, nil, nil, DOTA_TEAM_GOODGUYS)
    hero:SetControllableByPlayer(0, true)
    hero:SetForwardVector(Vector(0, -1, 0))  -- Face south

    HeroMaxLevel(hero)
    hero:AddItemByName("item_ultimate_scepter_2")
    hero:AddItemByName("item_aghanims_shard")

    -- 将英雄分配给玩家0
    local player = PlayerResource:GetPlayer(0)
    if player then
        player:SetAssignedHeroEntity(hero)
    end

    if isLeft then
        -- local particleName = "particles/events/ti6_teams/teleport_start_ti6_lvl3_mvp_phoenix.vpcf"
        -- local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, hero)
        -- ParticleManager:SetParticleControl(particle, 0, hero:GetAbsOrigin())
        -- hero:AddNewModifier(hero, nil, "modifier_no_cooldown_SecondSkill", {height_adjustment = 300})

        
        

        -- Make victory gesture
        -- hero:StartGesture(ACT_DOTA_VICTORY)
    end
end

function SetupBristlebackAndLinaScene()
    local center = Vector(43, 255, 256)
    local distance = 800

    local function SetupHero(hero, isPlayerControlled)
        -- 设置英雄最大等级
        HeroMaxLevel(hero)  -- 假设最大等级是30
        hero:AddItemByName("item_ultimate_scepter_2")
        hero:AddItemByName("item_aghanims_shard")
        if isPlayerControlled then
            -- 让玩家0控制这个英雄
            hero:SetControllableByPlayer(0, true)
            
            -- 设置英雄为玩家0的主要英雄（如果这是第一个被控制的英雄）
            if PlayerResource:GetPlayer(0):GetAssignedHero() == nil then
                PlayerResource:GetPlayer(0):SetAssignedHeroEntity(hero)
            end
        end
    end



    -- 创建一个友方 Bristleback
    local ally_bristle = CreateUnitByName("npc_dota_hero_bristleback", center + Vector(0, distance, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    SetupHero(ally_bristle, true)
    ally_bristle:SetForwardVector(Vector(0, 0, 0))

    -- 创建两个友方 Lina
    local ally_lina1 = CreateUnitByName("npc_dota_hero_lina", center + Vector(0, -distance, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    SetupHero(ally_lina1, true)
    
    local ally_lina2 = CreateUnitByName("npc_dota_hero_lina", center + Vector(distance, distance, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    SetupHero(ally_lina2, true)


    -- 创建两个敌方 Bristleback
    local enemy_bristle1 = CreateUnitByName("npc_dota_hero_bristleback", center + Vector(distance, 0, 0), true, nil, nil, DOTA_TEAM_BADGUYS)
    SetupHero(enemy_bristle1, true)

    local enemy_bristle2 = CreateUnitByName("npc_dota_hero_bristleback", center + Vector(-distance, 0, 0), true, nil, nil, DOTA_TEAM_BADGUYS)
    SetupHero(enemy_bristle2, true)
    enemy_bristle2:SetForwardVector(Vector(0, 0, 0))
    print("Heroes created successfully! Player 0 can now control the allied heroes.")
end




function SetupRingmasterScene()
    local heroes = {
        "razor", "ogre_magi", "monkey_king", "luna", "lina", "mars", "primal_beast", "muerta", 
        "meepo", "chaos_knight", "doom_bringer", "obsidian_destroyer", "death_prophet", "ursa", 
        "slark", "slardar", "marci", "shadow_shaman", "shadow_demon", "terrorblade", "spectre", 
        "nevermore", "pugna", "necrolyte", "phantom_assassin", "troll_warlord", "nyx_assassin", 
        "lich", "morphling", "tinker", "riki", "viper", "juggernaut", "shredder", "undying","bristleback"
    }

    local center = Vector(43, 255, 256)
    local radius = 500
    local ringmaster_pos = Vector(256.58, 1536.43, 384.00)

    local function SetupHero(hero)
        -- 设置英雄最大等级
        HeroMaxLevel(hero)
        
        -- 添加缴械状态
        hero:AddNewModifier(hero, nil, "modifier_disarmed", {})

        -- 如果不是 Ringmaster，降低移动速度
        if hero:GetName() ~= "npc_dota_hero_ringmaster" then
            hero:SetBaseMoveSpeed(100)
        end
    end

    local function SpawnHeroes()
        local angle_step = 360 / #heroes
        for i, hero_name in ipairs(heroes) do
            local angle = math.rad(i * angle_step)
            local pos = Vector(
                center.x + radius * math.cos(angle),
                center.y + radius * math.sin(angle),
                center.z
            )
            local newHero = CreateUnitByName("npc_dota_hero_" .. hero_name, pos, true, nil, nil, DOTA_TEAM_GOODGUYS)
            SetupHero(newHero)
            
            -- 设置英雄朝向圆心
            local direction = (center - pos):Normalized()
            newHero:SetForwardVector(direction)
        end
    end

    local function SpawnRingmaster()
        local ringmaster = CreateUnitByName("npc_dota_hero_ringmaster", ringmaster_pos, true, nil, nil, DOTA_TEAM_BADGUYS)
        SetupHero(ringmaster)
        
        -- 设置Ringmaster朝南
        ringmaster:SetForwardVector(Vector(0, -1, 0))
        
        return ringmaster
    end

    local function CastRingmasterAbility(ringmaster)
        ringmaster:CastAbilityOnPosition(center, ringmaster:FindAbilityByName("ringmaster_tame_the_beasts"), -1)
    end

    local function RandomMovement(unit)
        local new_pos = Vector(
            unit:GetOrigin().x + RandomFloat(-1000, 1000),
            unit:GetOrigin().y + RandomFloat(-1000, 1000),
            unit:GetOrigin().z
        )
        unit:MoveToPosition(new_pos)
    end

    local function StartRandomMovement()
        local allHeroes = HeroList:GetAllHeroes()
        for _, hero in pairs(allHeroes) do
            if hero:GetName() ~= "npc_dota_hero_ringmaster" then
                -- 在开始随机移动之前，设置朝向为 Vector(0, 0, 0)
                RandomMovement(hero)
            end
        end
    end

    Timers:CreateTimer(function()
        SpawnHeroes()
        local ringmaster = SpawnRingmaster()

        Timers:CreateTimer(10, function()
            CastRingmasterAbility(ringmaster)
        end)

        Timers:CreateTimer(11.15, function()
            -- 只在开始随机移动前设置一次朝向
            local allHeroes = HeroList:GetAllHeroes()
            for _, hero in pairs(allHeroes) do
                if hero:GetName() ~= "npc_dota_hero_ringmaster" then
                    hero:SetForwardVector(Vector(0, 0, 0))
                end
            end

            -- 开始定期随机移动
            Timers:CreateTimer(function()
                StartRandomMovement()
                return 1  -- 每0.2秒重复一次随机移动
            end)
        end)
    end)
end

function SetupStrengthHeroesScene()
    local heroes = {
        "alchemist", "axe", "bristleback", "centaur", "chaos_knight", "dawnbreaker", "doom_bringer", 
        "dragon_knight", "earthshaker", "elder_titan", "earth_spirit", "huskar", "kunkka", 
        "legion_commander", "life_stealer", "mars", "night_stalker", "ogre_magi", "omniknight", 
        "primal_beast", "pudge", "slardar", "shredder", "spirit_breaker", "sven", "tidehunter", 
        "tiny", "treant", "tusk", "abyssal_underlord", "undying", "skeleton_king"
    }

    local center = Vector(43, 255, 256)
    local radius = 500

    local function SetupHero(hero)
        -- 设置英雄最大等级
        HeroMaxLevel(hero)
        
        -- 添加缴械状态
        hero:AddNewModifier(hero, nil, "modifier_disarmed", {})

        -- 降低移动速度
        hero:SetBaseMoveSpeed(100)

        -- 设置英雄头朝下倒立
        hero:SetForwardVector(Vector(0, 0, -1))  -- 头朝下
        hero:AddNewModifier(hero, nil, "modifier_constant_height_adjustment", {height_adjustment = 300})
        hero:SetAngles(180, 0, 0)  -- 旋转180度，实现倒立
    end

    local function SpawnHeroes()
        local angle_step = 360 / #heroes
        for i, hero_name in ipairs(heroes) do
            local angle = math.rad(i * angle_step)
            local pos = Vector(
                center.x + radius * math.cos(angle),
                center.y + radius * math.sin(angle),
                center.z
            )
            local newHero = CreateUnitByName("npc_dota_hero_" .. hero_name, pos, true, nil, nil, DOTA_TEAM_GOODGUYS)
            SetupHero(newHero)
        end
    end

    local function RandomMovement(unit)
        local new_pos = Vector(
            unit:GetOrigin().x + RandomFloat(-1000, 1000),
            unit:GetOrigin().y + RandomFloat(-1000, 1000),
            unit:GetOrigin().z
        )
        unit:MoveToPosition(new_pos)
    end

    local function StartRandomMovement()
        local allHeroes = HeroList:GetAllHeroes()
        for _, hero in pairs(allHeroes) do
            RandomMovement(hero)
        end
    end

    Timers:CreateTimer(function()
        SpawnHeroes()

        -- 等待10秒后开始随机移动
        Timers:CreateTimer(10, function()
            -- 开始定期随机移动
            Timers:CreateTimer(function()
                StartRandomMovement()
                return 1  -- 每1秒重复一次随机移动
            end)
        end)
    end)
end