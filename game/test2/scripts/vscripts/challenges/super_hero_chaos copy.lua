function Main:Cleanup_super_hero_chaos()
    self.DeleteCurrentArenaHeroes()
    Timers:CreateTimer(1, function()
    self.ClearAllUnitsExcept()
    end)
end


function Main:Init_super_hero_chaos(event, playerID)
    -- 初始化全局变量

    hero_duel.EndDuel = false  -- 标记战斗是否结束
    self.currentTimer = (self.currentTimer or 0) + 1
    self.currentMatchID = self:GenerateUniqueID() 
    self.SPAWN_POINT_FAR = Vector(-12686, 15127, 128)
    self.ARENA_CENTER = Vector(150, 150, 128)
    self.SPAWN_DISTANCE = 500
    SendCameraPositionToJS(Main.largeSpawnCenter, 1)

    self.isTestMode = false

    self.heroSequence = {
        [1] = {  -- 力量
            sequence = {},  -- {name="xxx", chinese="xxx", entity=nil, kills=0, damage=0}
            currentIndex = 1,  -- 当前场上英雄的索引
            totalCount = 0,    -- 总英雄数
            teamStats = {
                kills = 0,     -- 团队总击杀数
                damage = 0     -- 团队总伤害
            },
            team = DOTA_TEAM_BADGUYS  -- 红色队伍
        },
        [2] = {  -- 敏捷
            sequence = {},
            currentIndex = 1,
            totalCount = 0,
            teamStats = {
                kills = 0,
                damage = 0
            },
            team = DOTA_TEAM_GOODGUYS  -- 绿色队伍
        },
        [4] = {  -- 智力
            sequence = {},
            currentIndex = 1,
            totalCount = 0,
            teamStats = {
                kills = 0,
                damage = 0
            },
            team = DOTA_TEAM_CUSTOM_1  -- 蓝色队伍
        },
        [8] = {  -- 全才
            sequence = {},
            currentIndex = 1,
            totalCount = 0,
            teamStats = {
                kills = 0,
                damage = 0
            },
            team = DOTA_TEAM_CUSTOM_2  -- 紫色队伍
        }
    }

    self.heroFacets = {
        npc_dota_hero_faceless_void = 2,  -- 虚空假面
        npc_dota_hero_life_stealer = 2,   -- 噬魂鬼
        npc_dota_hero_mirana = 2,
        npc_dota_hero_windrunner = 3,
        npc_dota_hero_earthshaker = 2,
        npc_dota_hero_tinker = 2,
        npc_dota_hero_huskar = 3,
        npc_dota_hero_death_prophet = 2,
        npc_dota_hero_sand_king = 2,
        npc_dota_hero_winter_wyvern = 2,
        npc_dota_hero_leshrac = 2,
        npc_dota_hero_phantom_assassin = 2,
        -- 可以继续添加其他英雄的命石设置
    }
    self.testModeHeroes = {
        [1] = { -- 力量英雄
            {name = "npc_dota_hero_tusk", chinese = "巨牙海民"},
        },
        [2] = { -- 敏捷英雄
            {name = "npc_dota_hero_ember_spirit", chinese = "灰烬之灵"},
        },
        [4] = {{
            name = "npc_dota_hero_muerta", chinese = "琼英碧灵"},
        }, -- 智力英雄
        [8] = {{name = "npc_dota_hero_wisp", chinese = "艾欧"}},  -- 全才英雄
    }

    self:InitializeHeroSequence()--初始化英雄序列

    self:InitialPreCreateHeroes()--预创建英雄
    Timers:CreateTimer(10, function()
        self:InitializeUI()
        self:InitialDeployHeroes()
        --self:CreateAllTeamHeroes()
        end)
end

function Main:InitializeHeroSequence()
    for heroType, data in pairs(self.heroSequence) do
        local heroPool = {}
        
        -- 从heroes_precache中获取该属性的所有英雄
        for _, hero in ipairs(heroes_precache) do
            if hero.type == heroType then
                table.insert(heroPool, {
                    name = hero.name,
                    chinese = hero.chinese,
                    entity = nil,
                    kills = 0,
                    damage = 0
                })
            end
        end
        
        -- 如果是测试模式，处理测试英雄
        if self.isTestMode and self.testModeHeroes[heroType] then
            local sequence = {}
            -- 首先添加测试英雄
            for i, testHero in ipairs(self.testModeHeroes[heroType]) do
                table.insert(sequence, {
                    name = testHero.name,
                    chinese = testHero.chinese,
                    entity = nil,
                    kills = 0,
                    damage = 0
                })
            end
            
            -- 随机打乱剩余英雄池并添加到序列中
            local remainingPool = table.shuffle(heroPool)
            for _, hero in ipairs(remainingPool) do
                -- 检查是否已经在测试英雄中
                local isDuplicate = false
                for _, testHero in ipairs(sequence) do
                    if testHero.name == hero.name then
                        isDuplicate = true
                        break
                    end
                end
                if not isDuplicate then
                    table.insert(sequence, hero)
                end
            end
            data.sequence = sequence
        else
            -- 非测试模式，直接随机打乱所有英雄
            data.sequence = table.shuffle(heroPool)
        end
        
        data.totalCount = #data.sequence
        data.currentIndex = 1
    end
end

function Main:GetSpawnPointForType(heroType, isInitialSpawn)
    if isInitialSpawn then
        -- 初始英雄使用固定位置
        local angle = 0
        if heroType == 1 then angle = 0
        elseif heroType == 2 then angle = math.pi/2
        elseif heroType == 4 then angle = math.pi
        elseif heroType == 8 then angle = 3*math.pi/2
        end
        
        local x = self.ARENA_CENTER.x + self.SPAWN_DISTANCE * math.cos(angle)
        local y = self.ARENA_CENTER.y + self.SPAWN_DISTANCE * math.sin(angle)
        return Vector(x, y, self.ARENA_CENTER.z)
    else
        -- 后续英雄使用随机位置
        local randomAngle = RandomFloat(0, 2 * math.pi)
        local x = self.ARENA_CENTER.x + 600 * math.cos(randomAngle)
        local y = self.ARENA_CENTER.y + 600 * math.sin(randomAngle)
        return Vector(x, y, self.ARENA_CENTER.z)
    end
end

function Main:PreCreateHeroes(heroType)
    local data = self.heroSequence[heroType]
    if not data then
        print(string.format("[Arena] 错误：无效的英雄属性类型: %d", heroType))
        return false
    end

    -- 从当前索引开始查找未创建的英雄
    for i = data.currentIndex, data.totalCount do
        local heroData = data.sequence[i]
        
        if not heroData.entity then
            -- 找到了一个未创建的英雄
            local heroName = heroData.name
            
            print(string.format("[Arena] 准备创建英雄: %s (序号: %d)", 
                heroData.chinese, i))
            
            -- 使用CreateHero创建
            local facet = self.heroFacets[heroName] or 1
            print(string.format("[Arena] 命石: %d", facet))
            
            CreateHero(
                0,
                heroName, 
                facet,
                self.SPAWN_POINT_FAR,
                data.team,
                false,
                function(createdHero)
                    if not createdHero then
                        print(string.format("[Arena] 错误：创建英雄失败: %s", heroData.chinese))
                        return
                    end
                    
                    -- 编织者特殊处理
                    if heroName == "npc_dota_hero_weaver" then
                        print("[Arena] 检测到编织者，立即升至最高等级")
                        HeroMaxLevel(createdHero)
                    end
                    
                    -- 记录创建的英雄实体
                    heroData.entity = createdHero
                    
                    -- 设置初始状态
                    self:SetupInitialBuffs(createdHero)
                    
                    print(string.format("[Arena] 成功创建英雄: %s", heroData.chinese))
                end
            )
            return true  -- 成功开始创建一个英雄
        else
            print(string.format("[Arena] 英雄已存在，继续查找下一个: %s", heroData.chinese))
        end
    end

    print(string.format("[Arena] 提示：属性 %d 的英雄已全部创建完成", heroType))
    return false
end

function Main:InitialPreCreateHeroes()
    local heroTypes = {1, 2, 4, 8}  -- 力量、敏捷、智力、全才
    local heroesPerType = 4         -- 每种属性预创建5个
    local totalTime = 10            -- 总时间10秒
    local interval = totalTime / (#heroTypes * heroesPerType)  -- 计算每个英雄的创建间隔
    
    local currentIndex = 0
    for _, heroType in ipairs(heroTypes) do
        for i = 1, heroesPerType do
            Timers:CreateTimer(interval * currentIndex, function()
                self:PreCreateHeroes(heroType)
            end)
            currentIndex = currentIndex + 1
        end
    end
end

function table.shuffle(tbl)
    local size = #tbl
    local shuffled = {}
    for i, v in ipairs(tbl) do
        shuffled[i] = v
    end
    for i = size, 2, -1 do
        local j = RandomInt(1, i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    return shuffled
end

function Main:SetupCombatBuffs(hero)
    if not hero then
        print("错误：SetupCombatBuffs收到了空的英雄实体")
        return false
    end
    
    print(string.format("正在设置英雄战斗状态: %s", hero:GetUnitName()))
    
    HeroMaxLevel(hero)
    hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
    hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
    hero:AddNewModifier(hero, nil, "modifier_truesight_all", {})
    
    print(string.format("英雄战斗状态设置完成: %s", hero:GetUnitName()))
end

function Main:SetupInitialBuffs(hero)
    if not hero then
        print("错误：SetupInitialBuffs收到了空的英雄实体")
        return false
    end
    
    hero:AddNewModifier(hero, nil, "modifier_invulnerable", {})
    hero:AddNewModifier(hero, nil, "modifier_invisible", {})
end

function Main:DeployHero(heroType, isInitialSpawn)
    local data = self.heroSequence[heroType]
    if not data then return end
    self:UpdateUIData(heroType)

    -- 初始化等待计数器
    local waitCount = 0
    local MAX_WAIT_TIME = 10 -- 最多等待10秒

    -- 检查当前位置是否有可用的英雄，如果没有则等待
    local function waitForHero()
        waitCount = waitCount + 1
        
        -- 超过最大等待时间
        if waitCount > MAX_WAIT_TIME then
            print(string.format("[Arena] 错误：等待属性 %d 当前位置 %d 的英雄超时", heroType, data.currentIndex))
            return nil -- 停止等待
        end

        local heroData = data.sequence[data.currentIndex]
        if not heroData or not heroData.entity then
            print(string.format("[Arena] 等待属性 %d 当前位置 %d 的英雄就绪...（%d/%d）", 
                heroType, data.currentIndex, waitCount, MAX_WAIT_TIME))
            return 1 -- 1秒后重试
        end

        -- 找到可用英雄，开始部署流程
        local hero = heroData.entity
        local spawnPoint = self:GetSpawnPointForType(heroType, isInitialSpawn)
        
        -- 根据英雄类型选择特效
        local particleName = ""
        if heroType == 1 then -- 力量英雄，红色
            particleName = "particles/red/teleport_start_ti6_lvl2.vpcf"
        elseif heroType == 2 then -- 敏捷英雄，绿色
            particleName = "particles/green/teleport_start_ti8_lvl2.vpcf"
        elseif heroType == 4 then -- 智力英雄，蓝色
            particleName = "particles/blue/teleport_start_ti7_lvl3.vpcf"
        elseif heroType == 8 then -- 全才英雄，紫色
            particleName = "particles/purple/teleport_start_ti9_lvl2.vpcf"
        end
        
        -- 播放传送特效
        local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 0, spawnPoint)
        
        -- 3秒后开始传送
        Timers:CreateTimer(3.0, function()
            -- 移除隐身相关的buff
            if hero:HasModifier("modifier_invisible") then
                hero:RemoveModifierByName("modifier_invisible")
            end

            -- 1秒后执行其他操作
            Timers:CreateTimer(1.0, function()
                -- 移除无敌状态
                if hero:HasModifier("modifier_invulnerable") then
                    hero:RemoveModifierByName("modifier_invulnerable")
                end

                -- 传送到指定位置
                FindClearSpaceForUnit(hero, spawnPoint, true)
                
                -- 清理传送特效
                ParticleManager:DestroyParticle(particle, false)
                ParticleManager:ReleaseParticleIndex(particle)
                
                -- 创建AI并设置战斗状态
                CreateAIForHero(hero)
                self:SetupCombatBuffs(hero)
                
                -- 执行英雄特殊效果
                local heroStrategy = hero.ai and hero.ai.heroStrategy or nil
                self:HeroBenefits(hero:GetUnitName(), hero, heroStrategy)
                
                -- 米波特殊处理
                if hero:GetUnitName() == "npc_dota_hero_meepo" then
                    Timers:CreateTimer(0.1, function()
                        local meepos = FindUnitsInRadius(
                            hero:GetTeam(),
                            hero:GetAbsOrigin(),
                            nil,
                            FIND_UNITS_EVERYWHERE,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_HERO,
                            DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
                            FIND_ANY_ORDER,
                            false
                        )
                        
                        for _, meepo in pairs(meepos) do
                            if meepo:HasModifier("modifier_meepo_divided_we_stand") and 
                               meepo:IsRealHero() and 
                               meepo ~= hero then
                                local overallStrategy = hero.ai and hero.ai.overallStrategy or nil
                                local heroStrategy = hero.ai and hero.ai.heroStrategy or nil
                                CreateAIForHero(meepo, overallStrategy, heroStrategy)
                            end
                        end
                    end)
                end
                
                self:StartAbilitiesMonitor(hero)
            end)
        end)

        return nil -- 不再继续等待
    end

    -- 开始等待循环
    Timers:CreateTimer(waitForHero)
end

function Main:InitialDeployHeroes()
    local heroTypes = {1, 2, 4, 8}  -- 力量、敏捷、智力、全才
    
    -- 每个属性传送一个英雄
    for _, heroType in ipairs(heroTypes) do
        self:DeployHero(heroType, true)
    end
end

function Main:CleanupHeroAndSummons(heroType, heroIndex, callback)
    if not self.heroSequence[heroType] then
        print(string.format("[Arena] 警告：未找到类型 %d 的队伍数据", heroType))
        if callback then callback() end
        return
    end

    local data = self.heroSequence[heroType]
    local heroData = data.sequence[heroIndex]

    if not heroData or not heroData.entity then
        print(string.format("[Arena] 警告：未找到类型 %d 索引 %d 的英雄数据", heroType, heroIndex))
        if callback then callback() end
        return
    end

    local hero = heroData.entity
    if hero:IsNull() then
        print("[Arena] 警告：英雄实体已失效")
        if callback then callback() end
        return
    end

    if not hero:IsAlive() then
        hero:RespawnHero(false, false)
    end

    local playerID = hero:GetPlayerOwnerID()
    if hero:IsHero() and not hero:IsClone() and hero:GetPlayerOwner() then
        UTIL_Remove(hero)
        DisconnectClient(playerID, true)
    else
        hero:Destroy()
    end

    -- 清除实体引用
    heroData.entity = nil

    Timers:CreateTimer(1, function()
        if callback then callback() end
    end)
end

function Main:OnUnitKilled_super_hero_chaos(killedUnit, args)
    if not killedUnit or not killedUnit:IsRealHero() then return end

    -- 获取被击杀英雄的类型和相关信息
    local killedHeroType = nil
    local heroToProcess = nil
    
    -- 获取击杀者信息
    local killer = args.entindex_attacker and EntIndexToHScript(args.entindex_attacker)
    local killerType = nil

    -- 特殊处理米波及其分身
    if killedUnit:GetUnitName() == "npc_dota_hero_meepo" then
        -- 如果是米波(本体或分身)，需要找到米波本体对应的类型
        for type, data in pairs(self.heroSequence) do
            if data and data.sequence and data.currentIndex and data.sequence[data.currentIndex] then
                local currentHero = data.sequence[data.currentIndex].entity
                if currentHero and currentHero:GetUnitName() == "npc_dota_hero_meepo" and 
                   killedUnit:GetTeamNumber() == currentHero:GetTeamNumber() then
                    killedHeroType = type
                    heroToProcess = currentHero  -- 使用本体进行后续处理
                    break
                end
            end
        end
    else
        -- 普通英雄直接查找
        for type, data in pairs(self.heroSequence) do
            if data and data.sequence and data.currentIndex and data.sequence[data.currentIndex] then
                local currentHero = data.sequence[data.currentIndex].entity
                if currentHero == killedUnit then
                    killedHeroType = type
                    heroToProcess = killedUnit
                    break
                end
            end
        end
    end

    -- 获取击杀者类型
    if killer and killer:IsRealHero() then
        for type, data in pairs(self.heroSequence) do
            if data and data.sequence and data.currentIndex and data.sequence[data.currentIndex] then
                local currentHero = data.sequence[data.currentIndex].entity
                if currentHero and currentHero:GetTeamNumber() == killer:GetTeamNumber() then
                    killerType = type
                    break
                end
            end
        end
    end

    if not killedHeroType or not heroToProcess then
        print("[Arena] 警告：无法确定死亡英雄的类型或处理目标")
        return
    end

    -- 确认是否真实死亡


    -- 1. 更新击杀者统计
    if killerType and self.heroSequence[killerType] and 
        self.heroSequence[killerType].sequence and 
        self.heroSequence[killerType].currentIndex and
        self.heroSequence[killerType].sequence[self.heroSequence[killerType].currentIndex] then
        
        -- 更新击杀者个人击杀数
        local killerData = self.heroSequence[killerType].sequence[self.heroSequence[killerType].currentIndex]
        killerData.kills = (killerData.kills or 0) + 1
        
        -- 更新击杀者团队击杀数
        if not self.heroSequence[killerType].teamStats then
            self.heroSequence[killerType].teamStats = {}
        end
        self.heroSequence[killerType].teamStats.kills = (self.heroSequence[killerType].teamStats.kills or 0) + 1
        
        self:UpdateUIData(killerType)
    end

    -- 2. 检查并更新被击杀者序列索引
    if self.heroSequence[killedHeroType] then
        -- 记录当前要清理的英雄的索引
        local indexToClean = self.heroSequence[killedHeroType].currentIndex
        
        -- 更新索引到下一个英雄
        self.heroSequence[killedHeroType].currentIndex = (self.heroSequence[killedHeroType].currentIndex or 1) + 1
    
        -- 3. 停止技能监控
        self:StopAbilitiesMonitor(heroToProcess)
    
        -- 4. 部署新英雄
        self:DeployHero(killedHeroType, false)
    
        -- 5. 延迟清理和创建新英雄
        Timers:CreateTimer(10, function()
            -- 传递英雄类型和记录的索引
            self:CleanupHeroAndSummons(killedHeroType, indexToClean, function()
                -- 创建新的预备英雄
                self:PreCreateHeroes(killedHeroType)
            end)
        end)
    else
        print("[Arena] 警告：无法找到被击杀英雄的队伍数据")
    end

end

-- 在初始化时
function Main:InitializeUI()
    print("[Arena] Starting UI initialization...")
    
    -- 第一步：显示容器
    print("[Arena] Sending show_hero_chaos_container event")
    CustomGameEventManager:Send_ServerToAllClients("show_hero_chaos_container", {})
    
    -- 第二步：设置需要的面板
    local activeTypes = {1, 2, 4, 8}
    print("[Arena] Sending setup_hero_chaos_panels event with types:", table.concat(activeTypes, ", "))
    CustomGameEventManager:Send_ServerToAllClients("setup_hero_chaos_panels", {
        types = activeTypes
    })
    

    print("[Arena] UI initialization completed")
end

-- 当需要更新UI数据时
function Main:UpdateUIData(heroType)
    local heroSequence = self.heroSequence[heroType]
    if not heroSequence then return end

    -- 获取当前英雄
    local currentData = heroSequence.sequence[heroSequence.currentIndex]
    local currentHero = currentData and currentData.entity and currentData.entity:GetUnitName()
    
    -- 获取下一个英雄
    local nextHeroIndex = heroSequence.currentIndex + 1
    local nextHeroData = heroSequence.sequence[nextHeroIndex]
    local nextHero = nextHeroData and nextHeroData.entity and nextHeroData.entity:GetUnitName()

    -- 计算已死亡英雄数量（currentIndex 从 1 开始，所以需要减 1）
    local deadHeroes = heroSequence.currentIndex - 1

    -- 构建数据
    local data = {
        type = heroType,
        currentHero = currentHero,
        nextHero = nextHero,
        remainingHeroes = #heroSequence.sequence - heroSequence.currentIndex + 1,
        totalHeroes = #heroSequence.sequence,
        kills = heroSequence.teamStats.kills or 0,
        deadHeroes = deadHeroes  -- 添加已死亡英雄数量
    }
    
    print(string.format("[Arena] Sending update_team_data for type %d:", heroType))
    print(string.format("Current Hero: %s", currentHero))
    print(string.format("Next Hero: %s", nextHero))
    print(string.format("Dead Heroes: %d", deadHeroes))
    DeepPrintTable(data)
    
    CustomGameEventManager:Send_ServerToAllClients("update_team_data", data)
end
-- function Main:OnNPCSpawned_super_hero_chaos(spawnedUnit, event)
--     if spawnedUnit:IsRealHero() and spawnedUnit:HasModifier("modifier_arc_warden_tempest_double") then
--         spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_no_cooldown_SecondSkill", {}) 
--     end
-- end