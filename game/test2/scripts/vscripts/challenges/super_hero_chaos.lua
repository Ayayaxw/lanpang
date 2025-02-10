function Main:Cleanup_super_hero_chaos()

end



function Main:Init_super_hero_chaos(event, playerID)
    -- 初始化全局变量
    self.showTeamPanel = true
    self.isTestMode = false
    self.heroesPerTeam = 1  -- 每个队伍初始传送的英雄数量，作为独立参数
    self.preCreatePerTeam = 3  -- 每个队伍初始创建的英雄数量，作为独立参数
    self.currentDeployIndex = 1  -- 当前部署的英雄索引
    hero_duel.EndDuel = false  -- 标记战斗是否结束
    self.currentTimer = (self.currentTimer or 0) + 1
    self.currentMatchID = self:GenerateUniqueID() 
    self.SPAWN_POINT_FAR = Vector(-12686, 15127, 128)
    self.ARENA_CENTER = Vector(150, 150, 128)
    self.SPAWN_DISTANCE = 500

    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS,DOTA_TEAM_CUSTOM_1,DOTA_TEAM_CUSTOM_2,DOTA_TEAM_CUSTOM_3,DOTA_TEAM_CUSTOM_4} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    SendCameraPositionToJS(Main.largeSpawnCenter, 1)

    -- 定义不同的队伍类型配置
    local TEAM_CONFIGS = {
        ATTRIBUTE = {
            [1] = {type = "1", name = "力量"},
            [2] = {type = "2", name = "敏捷"},
            [4] = {type = "4", name = "智力"},
            [8] = {type = "8", name = "全才"}
        },
        
        TOURNAMENT = {
            [1] = {type = "1", name = "被奴役的人马"},
            [2] = {type = "2", name = "农场主"}
        }
        -- 可以在这里添加更多的队伍配置
    }

    -- 设置当前使用的队伍配置类型
    self.teamConfig = "ATTRIBUTE"  -- 可以是 "ATTRIBUTE" 或 "TOURNAMENT" 或其他配置
    
    -- 设置实际使用的队伍类型
    self.teamTypes = TEAM_CONFIGS[self.teamConfig]

    self.heroSequence = {}

    -- 队伍对应关系
    local teamMapping = {
        [1] = DOTA_TEAM_BADGUYS,    -- 1 = 红色队伍
        [2] = DOTA_TEAM_GOODGUYS,   -- 2 = 绿色队伍
        [4] = DOTA_TEAM_CUSTOM_1,   -- 4 = 蓝色队伍
        [8] = DOTA_TEAM_CUSTOM_2    -- 8 = 紫色队伍
    }
    
    -- 根据 teamTypes 创建对应的 heroSequence
    for typeNum, typeInfo in pairs(self.teamTypes) do
        self.heroSequence[typeNum] = {
            sequence = {},
            currentIndex = 1,
            totalCount = 0,
            teamStats = {
                kills = 0,
                damage = 0,
                deaths = 0
            },
            team = teamMapping[typeNum]
        }
    end

    self.heroFacets = {
        npc_dota_hero_faceless_void = 3,  -- 虚空假面
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
        npc_dota_hero_sniper = 2,
        npc_dota_hero_lion = 2,
        npc_dota_hero_lone_druid = 3,
        -- 可以继续添加其他英雄的命石设置
    }

    self.createUnitHeroes = {
        ["npc_dota_hero_kez"] = true,
        ["npc_dota_hero_riki"] = true,
        ["npc_dota_hero_spirit_breaker"] = true,
        ["npc_dota_hero_magnataur"] = true,
        ["npc_dota_hero_techies"] = true,
        ["npc_dota_hero_disruptor"] = true,
        ["npc_dota_hero_bane"] = true,
        ["npc_dota_hero_venomancer"] = true,
        ["npc_dota_hero_night_stalker"] = true,
        ["npc_dota_hero_ogre_magi"] = true,
        ["npc_dota_hero_troll_warlord"] = true,
        ["npc_dota_hero_alchemist"] = true,
        ["npc_dota_hero_bounty_hunter"] = true,
        ["npc_dota_hero_templar_assassin"] = true,
        ["npc_dota_hero_skeleton_king"] = true,
        ["npc_dota_hero_ringmaster"] = true,
        ["npc_dota_hero_pangolier"] = true,
        ["npc_dota_hero_dark_willow"] = true,
        ["npc_dota_hero_monkey_king"] = true,
        ["npc_dota_hero_oracle"] = true,
        ["npc_dota_hero_phoenix"] = true,
        ["npc_dota_hero_legion_commander"] = true,
        ["npc_dota_hero_skywrath_mage"] = true,
        ["npc_dota_hero_abaddon"] = true,
    }


    self.testModeHeroes = {
        [1] = { -- 力量英雄
            {name = "npc_dota_hero_tusk", chinese = "巨牙海民"},
        },
        [2] = { -- 敏捷英雄
            {name = "npc_dota_hero_kez", chinese = "凯"},
        },
        [4] = {{
            name = "npc_dota_hero_muerta", chinese = "琼英碧灵"},
        }, -- 智力英雄
        [8] = {{name = "npc_dota_hero_vengefulspirit", chinese = "复仇之魂"}},  -- 全才英雄
    }
    self:InitializeHeroSequence()--初始化英雄序列

    self:InitialPreCreateHeroes()--预创建英雄
    Timers:CreateTimer(10, function()
        self:Initialize_Hero_Chaos_UI()
        self:Initial_Hero_Chaos_DeployHeroes()
        self:UpdateTeamPanelData()
        self:Start_Hero_Chaos_ScoreBoardMonitor()
        --self:CreateAllTeamHeroes()
        end)
end


function Main:SendKillFeedToClient(killer, killed)
    if not killer or not killed then 
        print("[Arena] Error: killer or killed is nil")
        return 
    end

    -- 定义团队类型

    -- 收集击杀数据
    local killerType = nil
    local killedType = nil
    local killerData = nil
    local killedData = nil

    -- 遍历团队类型来找到击杀者和被击杀者的数据
    for heroType, _ in pairs(self.teamTypes) do
        if self.heroSequence[heroType] then
            -- 遍历该类型的所有英雄
            for i = 1, #self.heroSequence[heroType].sequence do
                if self.heroSequence[heroType].sequence[i] and 
                   self.heroSequence[heroType].sequence[i].entity then
                    local hero = self.heroSequence[heroType].sequence[i].entity
                    if hero:GetUnitName() == killer:GetUnitName() then
                        killerType = heroType
                        killerData = self.heroSequence[heroType].sequence[i]
                    elseif hero:GetUnitName() == killed:GetUnitName() then
                        killedType = heroType
                        killedData = self.heroSequence[heroType].sequence[i]
                    end
                end
            end
        end
    end

    -- 检查是否找到了所有需要的数据
    if not killerType or not killedType or not killerData or not killedData then
        print("[Arena] Error: Could not find complete killer or victim data")
        print("KillerType:", killerType)
        print("KilledType:", killedType)
        print("KillerData:", killerData)
        print("KilledData:", killedData)
        return
    end

    -- 构建击杀数据
    local killData = {
        killer_hero = killer:GetUnitName(),
        killer_name = killerData.chinese,
        killer_type = self.teamTypes[killerType].type,
        victim_hero = killed:GetUnitName(),
        victim_name = killedData.chinese,
        victim_type = self.teamTypes[killedType].type
    }

    print("[Arena] Sending kill feed data:")
    DeepPrintTable(killData)
    
    -- 发送数据到前端
    CustomGameEventManager:Send_ServerToAllClients("hero_chaos_kill_feed", killData)
end



function Main:PlayVictoryEffects(killer)
    if not killer then return end

    -- 清理周围的树木，创造特效空间
    GridNav:DestroyTreesAroundPoint(killer:GetOrigin(), 500, false)

    -- 让英雄面向屏幕
    killer:SetForwardVector(Vector(0, -1, 0))
    self:gradual_slow_down(killer:GetAbsOrigin(), killer:GetAbsOrigin())
    -- 播放胜利动作
    killer:StartGesture(ACT_DOTA_VICTORY)
    
    -- 播放胜利音效
    EmitSoundOn("Hero_LegionCommander.Duel.Victory", killer)

    -- 创建胜利光环特效
    local particle = ParticleManager:CreateParticle(
        "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf",
        PATTACH_OVERHEAD_FOLLOW,
        killer
    )
    ParticleManager:SetParticleControl(particle, 0, killer:GetAbsOrigin())
    
    -- 创建聚光灯特效
    local spotlightParticle = ParticleManager:CreateParticle(
        "particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf",
        PATTACH_ABSORIGIN,
        killer
    )
    ParticleManager:SetParticleControl(spotlightParticle, 0, killer:GetAbsOrigin())

    -- 延迟释放特效
    Timers:CreateTimer(5.0, function()
        ParticleManager:DestroyParticle(particle, false)
        ParticleManager:DestroyParticle(spotlightParticle, false)
        ParticleManager:ReleaseParticleIndex(particle)
        ParticleManager:ReleaseParticleIndex(spotlightParticle)
    end)

    -- 可以添加额外的胜利特效
    local surroundingParticle = ParticleManager:CreateParticle(
        "particles/generic_gameplay/rune_doubledamage.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        killer
    )
    ParticleManager:SetParticleControl(surroundingParticle, 0, killer:GetAbsOrigin())
    
    -- 5秒后释放环绕特效
    Timers:CreateTimer(5.0, function()
        ParticleManager:DestroyParticle(surroundingParticle, false)
        ParticleManager:ReleaseParticleIndex(surroundingParticle)
    end)
end



function table.shuffle(tbl)
    local size = #tbl
    local shuffled = {}
    for i, v in ipairs(tbl) do
        shuffled[i] = v
    end
    -- 加入一个随机偏移，避免在同一帧内的调用产生相似结果
    local offset = RandomInt(1, 100)
    for i = size, 2, -1 do
        local j = RandomInt(1, i)
        -- 使用偏移量来影响随机选择
        if offset % 2 == 0 then
            j = (j % i) + 1
        end
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
    --hero:AddNewModifier(hero, nil, "modifier_reduced_ability_cost", {})
    HeroMaxLevel(hero)
    hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
    hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
    hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})


    -- hero:AddItemByName("item_trident")
    -- hero:AddItemByName("item_ultimate_orb")
    -- hero:AddItemByName("item_ultimate_orb")
    -- hero:AddItemByName("item_heart")
    -- hero:AddItemByName("item_heart")
    -- hero:AddItemByName("item_heart")
    -- hero:AddItemByName("item_heart")
    -- hero:AddItemByName("item_heart")
    -- hero:AddItemByName("item_heart")

    -- 添加装备
    -- 
    -- local bkb = hero:AddItemByName("item_black_king_bar")
    -- -- 使用BKB
    -- hero:CastAbilityNoTarget(bkb, -1)
    
    print(string.format("英雄战斗状态设置完成: %s", hero:GetUnitName()))
end

function Main:SetupInitialBuffs(hero)
    if not hero then
        print("错误：SetupInitialBuffs收到了空的英雄实体")
        return false
    end
    
    hero:AddNewModifier(hero, nil, "modifier_invulnerable", {})
    hero:AddNewModifier(hero, nil, "modifier_wearable", {})
end


function Main:Initial_Hero_Chaos_DeployHeroes()
    local heroTypes = {}
    -- 从teamTypes中获取所有type
    for type, _ in pairs(self.teamTypes) do
        table.insert(heroTypes, type)
    end
    
    -- 为每个队伍传送指定数量的英雄
    for _, heroType in ipairs(heroTypes) do
        -- 检查该类型实际可用的英雄数量
        local availableHeroes = #(self.heroSequence[heroType].sequence)
        -- 使用实际可用数量和预期数量中的较小值
        local heroesToDeploy = math.min(availableHeroes, self.heroesPerTeam)
        
        -- 添加延迟以确保英雄按顺序部署
        for i = 1, heroesToDeploy do
            -- 创建闭包来保存当前的 i 值
            local currentIndex = i
            Timers:CreateTimer((i - 1) * 0.1, function()
                self.currentDeployIndex = currentIndex  -- 设置当前部署索引
                self:DeployHero(heroType, true)
                
                if currentIndex < heroesToDeploy then
                    self.heroSequence[heroType].currentIndex = self.heroSequence[heroType].currentIndex + 1
                end
            end)
        end
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

    -- 检查是否在不删除列表中
    if self.createUnitHeroes[hero:GetUnitName()] then
        print(string.format("[Arena] 英雄 %s 在保留列表中，跳过删除", hero:GetUnitName()))
        heroData.entity = nil
        

        
        hero:SetAbsOrigin(Vector(10000, 10000, 0))
        -- Timers:CreateTimer(1, function()
        --     if callback then callback() end
        -- end)
        return 
    end

    if not hero:IsAlive() then
        hero:RespawnHero(false, false)
    end

    local playerID = hero:GetPlayerOwnerID()
    if hero:IsHero() and not hero:IsClone() and hero:GetPlayerOwner() then
        
        DisconnectClient(playerID, true)
        UTIL_Remove(hero)
        GameRules:ResetPlayer( playerID )
    else
        hero:Destroy()
    end

    -- 清除实体引用
    heroData.entity = nil

    Timers:CreateTimer(1, function()
        if callback then callback() end
    end)
end

function Main:CheckForVictory(winnerType)
    print("[Arena] 检查胜利条件 - 获胜者类型:", winnerType)
    
    -- 检查所有其他队伍是否已经全部阵亡
    for heroType, data in pairs(self.heroSequence) do
        if heroType ~= winnerType then
            print(string.format("[Arena] 检查队伍 %d: 死亡数 %d, 总英雄数 %d", 
                heroType, 
                data.teamStats.deaths or 0, 
                #data.sequence))
            
            -- 如果有任何队伍的死亡数小于总人数，说明还没结束
            if (data.teamStats.deaths or 0) < #data.sequence then
                print("[Arena] 该队伍还有存活英雄，未达到胜利条件")
                return false
            end
        end
    end
    
    print("[Arena] 所有其他队伍都已全部阵亡，达到胜利条件")
    return true
end

function Main:OnUnitKilled_super_hero_chaos(killedUnit, args)
    if not killedUnit or not killedUnit:IsRealHero() then return end

    -- 获取被击杀英雄的类型和相关信息
    local killedHeroType = nil
    local heroToProcess = nil
    local killedHeroIndex = nil  -- 添加这个变量来存储被击杀英雄的索引
    
    -- 特殊处理米波及其分身
    if killedUnit:GetUnitName() == "npc_dota_hero_meepo" then
        for type, data in pairs(self.heroSequence) do
            if data and data.sequence then
                for i = 1, #data.sequence do  -- 遍历整个序列
                    if data.sequence[i] and data.sequence[i].entity then
                        local currentHero = data.sequence[i].entity
                        if currentHero and currentHero:GetUnitName() == "npc_dota_hero_meepo" and 
                           killedUnit:GetTeamNumber() == currentHero:GetTeamNumber() then
                            killedHeroType = type
                            heroToProcess = currentHero  -- 使用本体进行后续处理
                            killedHeroIndex = i  -- 记录索引
                            break
                        end
                    end
                end
                if killedHeroType then break end
            end
        end
    else
        for type, data in pairs(self.heroSequence) do
            if data and data.sequence then
                for i = 1, #data.sequence do  -- 遍历整个序列
                    if data.sequence[i] and data.sequence[i].entity then
                        local currentHero = data.sequence[i].entity
                        if currentHero == killedUnit then
                            killedHeroType = type
                            heroToProcess = killedUnit
                            killedHeroIndex = i  -- 记录索引
                            break
                        end
                    end
                end
                if killedHeroType then break end
            end
        end
    end

    if not killedHeroType or not heroToProcess or not killedHeroIndex then
        print("[Arena] 警告：无法确定死亡英雄的类型、处理目标或索引")
        return
    end

    -- 在确认真实死亡前，先找到真正的击杀者和对应数据
    local killer = args.entindex_attacker and EntIndexToHScript(args.entindex_attacker)
    local realKiller = nil
    local killerType = nil
    local killerData = nil
    local killerTeamData = nil
    
    if killer and IsValidEntity(killer) then
        realKiller = self:GetRealOwner(killer)
        if realKiller then
            local killerTeam = realKiller:GetTeamNumber()
            local killerHeroName = realKiller:GetUnitName()

            for type, data in pairs(self.heroSequence) do
                if data and data.sequence then
                    -- 搜索整个序列
                    for i = 1, #data.sequence do
                        if data.sequence[i] and data.sequence[i].entity then
                            local hero = data.sequence[i].entity
                            if hero:GetTeamNumber() == killerTeam and
                               hero:GetUnitName() == killerHeroName then
                                killerType = type
                                killerData = data.sequence[i]
                                killerTeamData = data
                                break
                            end
                        end
                    end
                    if killerType then break end
                end
            end
        end
    end
        
        if self.heroSequence[killedHeroType] then
            local indexToClean = killedHeroIndex
            
            -- 记录死亡数
            if not self.heroSequence[killedHeroType].teamStats then
                self.heroSequence[killedHeroType].teamStats = {}
            end
            self.heroSequence[killedHeroType].teamStats.deaths = (self.heroSequence[killedHeroType].teamStats.deaths or 0) + 1
            
            self:StopAbilitiesMonitor(heroToProcess)
            
            -- 增加 currentIndex，为下一个英雄做准备
            local nextIndex = (self.heroSequence[killedHeroType].currentIndex or 1) + 1
            if nextIndex <= #self.heroSequence[killedHeroType].sequence then
                self.heroSequence[killedHeroType].currentIndex = nextIndex
                -- 部署新的英雄
                self:DeployHero(killedHeroType, false)
            else
                print(string.format("[Arena] 警告：队伍 %d 已无可用英雄", killedHeroType))
            end
            
            -- 在更新完被击杀者状态后，再处理击杀者数据和胜利检查
            if realKiller and killerType and killerData and killerTeamData then
                --self:KamiBlessing(realKiller)
                -- local newHealth = realKiller:GetHealth() + realKiller:GetMaxHealth() / 3
                -- if newHealth > realKiller:GetMaxHealth() then
                --     newHealth = realKiller:GetMaxHealth()
                -- end
                
                -- local newMana = realKiller:GetMana() + realKiller:GetMaxMana()  / 3
                -- if newMana > realKiller:GetMaxMana() then
                --     newMana = realKiller:GetMaxMana()
                -- end
                
                -- realKiller:SetHealth(newHealth)
                -- realKiller:SetMana(newMana)
                

                -- local particle = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf", PATTACH_ABSORIGIN_FOLLOW, realKiller)
                -- ParticleManager:SetParticleControl(particle, 0, realKiller:GetAbsOrigin())
                -- ParticleManager:ReleaseParticleIndex(particle)
                -- 重置所有技能冷却和充能
                -- for i = 0, realKiller:GetAbilityCount() - 1 do
                --     local ability = realKiller:GetAbilityByIndex(i)
                --     if ability then
                --         -- 降低技能总冷却的一半时间
                --         local currentCooldown = ability:GetCooldownTimeRemaining()
                --         if currentCooldown > 0 then
                --             local totalCooldown = ability:GetCooldown(ability:GetLevel())
                --             ability:EndCooldown()
                --             -- 当前剩余冷却时间减去总冷却的一半
                --             local newCooldown = math.max(0, currentCooldown - totalCooldown * 0.5)
                --             ability:StartCooldown(newCooldown)
                --         end
                        
                --         -- 充能点数回复一半
                --         local maxCharges = ability:GetMaxAbilityCharges(ability:GetLevel())
                --         if maxCharges > 0 then
                --             local currentCharges = ability:GetCurrentAbilityCharges()
                --             local chargesToRestore = math.floor((maxCharges - currentCharges) * 0.5)
                --             ability:SetCurrentAbilityCharges(currentCharges + chargesToRestore)
                --         end
                --     end
                -- end


                killerData.kills = (killerData.kills or 0) + 1
                
                if not killerTeamData.teamStats then
                    killerTeamData.teamStats = {}
                end
                killerTeamData.teamStats.kills = (killerTeamData.teamStats.kills or 0) + 1
                
                self:UpdateTeamPanelData()
                self:SendKillFeedToClient(realKiller, heroToProcess)
                
                if self:CheckForVictory(killerType) then
                    self:PlayVictoryEffects(realKiller)
                    hero_duel.EndDuel = true
                end
            end
                        -- 清理附近掉落的物品
            local nearby_items = Entities:FindAllByClassnameWithin("dota_item_drop", killedUnit:GetAbsOrigin(), 300)
            for _, item in pairs(nearby_items) do
                if not item:IsNull() then
                    UTIL_Remove(item)
                end
            end
            -- 使用正确的索引进行清理
            Timers:CreateTimer(5, function()
                self:CleanupHeroAndSummons(killedHeroType, indexToClean, function()
                    self:PreCreateHeroes(killedHeroType)
                end)
            end)
        else
            print("[Arena] 警告：无法找到被击杀英雄的队伍数据")
        end
    -- end)
end
-- 在初始化时
function Main:InitializeHeroSequence()
    -- local heroesGroup1 = {
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
    --     "npc_dota_hero_centaur",
        
    -- }
    
    -- local heroesGroup2 = {
    --     "npc_dota_hero_faceless_void",
    --     "npc_dota_hero_juggernaut",
    --     "npc_dota_hero_winter_wyvern",
    --     "npc_dota_hero_viper",
    --     "npc_dota_hero_kez",
    --     "npc_dota_hero_windrunner",
    --     "npc_dota_hero_magnataur",
    --     "npc_dota_hero_razor",
    --     "npc_dota_hero_dark_seer",
    --     "npc_dota_hero_death_prophet",
    --     "npc_dota_hero_monkey_king",
    --     "npc_dota_hero_dragon_knight",
    --     "npc_dota_hero_ogre_magi",
    --     "npc_dota_hero_bloodseeker",
    --     "npc_dota_hero_batrider",
    --     "npc_dota_hero_necrolyte",
    --     "npc_dota_hero_doom_bringer",
    --     "npc_dota_hero_visage",
    --     "npc_dota_hero_ursa",
    --     "npc_dota_hero_silencer",
    --     "npc_dota_hero_ember_spirit",
    --     "npc_dota_hero_pangolier",
    --     "npc_dota_hero_jakiro",
    --     "npc_dota_hero_shadow_shaman",
    --     "npc_dota_hero_nevermore",
    --     "npc_dota_hero_phantom_lancer",
    --     "npc_dota_hero_sand_king",
    --     "npc_dota_hero_techies",
    --     "npc_dota_hero_witch_doctor",
    --     "npc_dota_hero_huskar",
    --     "npc_dota_hero_luna",
    --     "npc_dota_hero_venomancer",
    --     "npc_dota_hero_arc_warden",
    --     "npc_dota_hero_clinkz"
    -- }
    
    -- 创建一个查找表来确定英雄类型

        -- Group3: 筛选英雄池。当Group1和Group2都不启用时，
    -- 使用原始type分类方式，但只使用这个组里列出的英雄
    local heroesGroup3 = {
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_tiny",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_elder_titan",
        "npc_dota_hero_axe",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_sven",
        "npc_dota_hero_weaver",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_razor",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_morphling",
        "npc_dota_hero_slark",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_meepo",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_lich",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_disruptor",
        "npc_dota_hero_warlock",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_pugna",
        "npc_dota_hero_lina",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_invoker",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_enigma"
    }
    local useOriginalType = not heroesGroup1 and not heroesGroup2
    local useGroup3Filter = heroesGroup3 ~= nil
    local heroTypeMap = {}
    local group3Set = {}
    
    if useGroup3Filter then
        -- 将 group3 的英雄加入集合中用于快速查找
        for _, heroName in ipairs(heroesGroup3) do
            group3Set[heroName] = true
        end
    end
    
    -- if not useOriginalType then
    --     if heroesGroup1 then
    --         for _, heroName in ipairs(heroesGroup1) do
    --             heroTypeMap[heroName] = 1
    --         end
    --     end
    --     if heroesGroup2 then
    --         for _, heroName in ipairs(heroesGroup2) do
    --             heroTypeMap[heroName] = 2
    --         end
    --     end
    -- end

    -- 只遍历 self.teamTypes 中定义的类型
    for heroType, typeInfo in pairs(self.teamTypes) do
        local heroPool = {}
        local typeNum = tonumber(typeInfo.type)

        -- 直接使用原始列表
        if typeNum == 1 and heroesGroup1 then
            -- 处理第一组英雄
            for _, heroName in ipairs(heroesGroup1) do
                for _, hero in ipairs(heroes_precache) do
                    if hero.name == heroName then
                        table.insert(heroPool, {
                            name = hero.name,
                            chinese = hero.chinese,
                            entity = nil,
                            kills = 0,
                            damage = 0
                        })
                        break  -- 找到对应的英雄信息后就跳出内层循环
                    end
                end
            end
        elseif typeNum == 2 and heroesGroup2 then
            -- 处理第二组英雄
            for _, heroName in ipairs(heroesGroup2) do
                for _, hero in ipairs(heroes_precache) do
                    if hero.name == heroName then
                        table.insert(heroPool, {
                            name = hero.name,
                            chinese = hero.chinese,
                            entity = nil,
                            kills = 0,
                            damage = 0
                        })
                        break  -- 找到对应的英雄信息后就跳出内层循环
                    end
                end
            end
        else
            -- 如果没有指定组，使用原始type分类
            local heroCount = 0
            for _, hero in ipairs(heroes_precache) do
                if hero.type == typeNum then
                    table.insert(heroPool, {
                        name = hero.name,
                        chinese = hero.chinese,
                        entity = nil,
                        kills = 0,
                        damage = 0
                    })
                    heroCount = heroCount + 1
                    if heroCount >= 100 then 
                        break
                    end
                end
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
            self.heroSequence[heroType].sequence = sequence
        else
            -- 非测试模式，直接随机打乱所有英雄
            self.heroSequence[heroType].sequence = table.shuffle(heroPool)
        end
        
        -- 设置总数和初始索引
        self.heroSequence[heroType].totalCount = #self.heroSequence[heroType].sequence
        self.heroSequence[heroType].currentIndex = 1
        
        -- 输出日志以便调试
        print(string.format("[Arena] 类型 %d 的英雄池大小: %d", heroType, #self.heroSequence[heroType].sequence))
        for i = 1, math.min(5, #self.heroSequence[heroType].sequence) do
            print(string.format("%d: %s (%s)", 
                i, 
                self.heroSequence[heroType].sequence[i].name,
                self.heroSequence[heroType].sequence[i].chinese))
        end
    end
end


function Main:OnAttack_super_hero_chaos(keys)
    local attacker = EntIndexToHScript(keys.entindex_attacker)
    local victim = EntIndexToHScript(keys.entindex_killed)
    local damage = keys.damage

    -- 如果目标无效或者是友军，直接返回
    if not victim or attacker:GetTeamNumber() == victim:GetTeamNumber() then
        return
    end

    -- 获取实际应该记录伤害的英雄实体
    local damageOwner = self:GetRealOwner(attacker)

    -- 如果没找到有效的伤害归属者，直接返回
    if not damageOwner then
        return
    end

    -- 获取攻击者的团队和英雄名称
    local attackerTeam = damageOwner:GetTeamNumber()
    local attackerHeroName = damageOwner:GetUnitName()

    -- 遍历所有英雄类型
    for heroType, data in pairs(self.heroSequence) do
        if data and data.sequence then
            -- 搜索整个序列
            for i = 1, #data.sequence do
                if data.sequence[i] and data.sequence[i].entity then
                    local heroData = data.sequence[i]
                    -- 判定逻辑：团队相同且单位名称相同
                    if heroData.entity:GetTeamNumber() == attackerTeam and 
                       heroData.entity:GetUnitName() == attackerHeroName then
                        
                        -- 更新英雄个人伤害
                        heroData.damage = (heroData.damage or 0) + math.ceil(damage)
                        
                        -- 更新团队总伤害
                        if not data.teamStats then
                            data.teamStats = { damage = 0, kills = 0 }
                        end
                        data.teamStats.damage = (data.teamStats.damage or 0) + math.ceil(damage)
                        
                        
                        break  
                    end
                end
            end
        end
    end
end