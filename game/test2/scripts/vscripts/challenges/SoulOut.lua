function Main:Init_SoulOut(event, playerID)
    -- 技能修改器
    self.courierPool = {}
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    hero_duel.killCount = 0    -- 初始化击杀计数器
    print("[DEBUG] Kill count reset to:", hero_duel.killCount) -- 添加调试打印

    -- 设置英雄配置
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)

    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                local heroName = hero:GetUnitName()

                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})

                
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})

            end,
        },
        FRIENDLY = {
            function(hero)
                hero:SetForwardVector(Vector(1, 0, 0))
                -- 可以在这里添加更多友方英雄特定的操作
            end,
        },
        ENEMY = {
            function(hero)
                hero:SetForwardVector(Vector(-1, 0, 0))
                -- 可以在这里添加敌方英雄特定的操作
            end,
        },
        BATTLEFIELD = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_waterfall", {})
            end,
        }
    }

    -- 从 event 中获取新的数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)


    -- 获取玩家和对手的英雄名称及中文名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)
    local ability_modifiers = {

    }
    

    

    -- 设置游戏速度
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer
    self.PlayerChineseName = heroChineseName

    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 99999, true)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 9999        
    hero_duel.EndDuel = false  -- 标记战斗是否结束

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[新挑战]"
    )

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择绿方]",
        {localize = true, text = heroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(heroName, selfFacetId)}
    )

    -- 发送初始化消息给前端
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["存活时间"] = "0",
        ["击杀数量"] = "0",
        ["当前总分"] = "0"  -- 添加当前总分
    }
    local order = {"挑战英雄", "存活时间", "击杀数量", "当前总分"}
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.waterFall_Center, DOTA_TEAM_BADGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        -- 如果启用了AI，为玩家英雄创建AI
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1")

                return nil
            end)
        else
            -- 处理非 AI 情况
        end
    end)


    -- 给英雄添加小礼物
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroPreparation(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroBenefits(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
        self:UpdateAbilityModifiers(ability_modifiers)
    end)

    -- 赛前限制
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:PrepareHeroForDuel(
            self.leftTeamHero1,                     -- 英雄单位
            
            self.waterFall_Center + Vector(0, -500, 0),      --向南移动500码 
            self.duration - 5,                      -- 限制效果持续20秒
            --朝向北侧
            Vector(0, 1, 0)     
        )
        self.leftTeamHero1:AddAbility("dazzle_nothl_projection")
        local ability = self.leftTeamHero1:FindAbilityByName("dazzle_nothl_projection")
        if ability then
            ability:SetLevel(3)
            
            -- 计算前方500码的位置
            local forward = self.leftTeamHero1:GetForwardVector()
            local origin = self.leftTeamHero1:GetAbsOrigin()
            local targetPos = origin + forward * 500
            
            -- 设置目标位置并释放技能
            self.leftTeamHero1:SetCursorPosition(targetPos)
            ability:OnSpellStart()
        end
    end)

    -- 发送摄像机位置给前端
    self:SendCameraPositionToJS(Main.waterFall_Center, 1)

    -- 比赛即将开始
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 比赛开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeamHero1:CalculateStatBonus(true)
        self.startTime = GameRules:GetGameTime() -- 记录开始时间
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
        Timers:CreateTimer(function()
            if hero_duel.EndDuel or self.currentTimer ~= timerId then return end
            local currentTime = math.floor(GameRules:GetGameTime() - self.startTime)
            local currentScore = hero_duel.killCount * 3 + currentTime
            
            local updateData = {
                ["当前总分"] = currentScore
            }
            CustomGameEventManager:Send_ServerToAllClients("update_score", updateData)
            return 1.0 -- 每秒更新
        end)



        
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:PreSpawnProwler()
    end)


    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        self:SendLeftHeroData(heroName, selfFacetId)
        Timers:CreateTimer(2, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 0.5")
        end)
        Timers:CreateTimer(3, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 1")
        end)
    end)

    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true
    
        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
    
        -- 计算最终得分
        local finalScore = hero_duel.killCount * 3 + self.limitTime  -- 基础击杀得分

        -- 对英雄再次施加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.endduration })
            end
        end
    
        -- 记录结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战完成]击杀数:" .. hero_duel.killCount .. ",最终得分:" .. finalScore
        )
        local data = {
            ["击杀数量"] = hero_duel.killCount,
            ["存活时间"] = self.limitTime,
            ["当前总分"] = finalScore
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)
        -- 播放胜利效果
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self:PlayVictoryEffects(self.leftTeamHero1)
        end
    end)
end

function Main:PreSpawnProwler()
    -- 在Main.waterFall_Center北方800码处创建10个敌对的npc_dota_neutral_prowler_shaman
    local centerPoint = Vector(Main.waterFall_Center.x, Main.waterFall_Center.y + 800, 128)
    local spacing = 150  -- 单位之间的横向间距
    local totalUnits = 1
    local startX = centerPoint.x - (spacing * (totalUnits-1))/2  -- 计算起始位置使整个队列居中
    
    -- 创建一个全局表来存储每个单位的出生位置
    if not Main.prowlerSpawnPositions then
        Main.prowlerSpawnPositions = {}
    end
    
    local spawned_units = {}
    
    for i = 1, totalUnits do
        local spawnPosition = Vector(startX + (i-1) * spacing, centerPoint.y, 128)
        local unit = CreateUnitByName("npc_dota_neutral_prowler_shaman", spawnPosition, true, nil, nil, DOTA_TEAM_GOODGUYS)
        
        if unit then
            -- 保存这个单位的出生位置
            Main.prowlerSpawnPositions[unit:GetEntityIndex()] = spawnPosition

            unit:SetForwardVector(Vector(0, -1, 0))
            -- 给予8秒的无敌和缴械状态
            unit:AddNewModifier(unit, nil, "modifier_invulnerable", {duration = 8})
            unit:AddNewModifier(unit, nil, "modifier_disarmed", {duration = 8})
            
            -- 移除neutral_upgrade技能
            if unit:HasAbility("neutral_upgrade") then
                unit:RemoveAbility("neutral_upgrade")
            end
            
            -- 保存单位以便延迟给予AI
            table.insert(spawned_units, unit)



        end
    end
    
    -- 8秒后给予AI
    Timers:CreateTimer(8, function()
        for _, unit in pairs(spawned_units) do
            if unit and unit:IsAlive() then
                -- 应用AI
                CreateAIForHero(unit, {"谁近打谁"}, {"默认策略"}, "野怪AI", 0.1)
            end
        end
    end)
end

function Main:OnUnitKilled_SoulOut(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel then return end
    local survivalTime = math.floor(GameRules:GetGameTime() - self.startTime)
    local finalScore = hero_duel.killCount * 3 + survivalTime
    
    -- 先检查是否是玩家英雄死亡
    if killedUnit == self.leftTeamHero1 then
        hero_duel.EndDuel = true

        local data = {
            ["击杀数量"] = hero_duel.killCount,
            ["存活时间"] = survivalTime,
            ["当前总分"] = finalScore
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)
        
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战完成]击杀数:" .. hero_duel.killCount .. ",最终得分:" .. finalScore
        )
        self:PlayDefeatAnimation(self.leftTeamHero1)

        return
    end
    
    -- 检查是否是野怪(prowler)死亡
    if killedUnit:GetUnitName() == "npc_dota_neutral_prowler_shaman" then
        hero_duel.killCount = (hero_duel.killCount or 0) + 1
        
        local data = {
            ["击杀数量"] = hero_duel.killCount,
            ["当前总分"] = finalScore
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)

        -- 获取该单位的出生位置
        local spawnPosition = Main.prowlerSpawnPositions[killedUnit:GetEntityIndex()]
        
        -- 在创建新单位后，需要为新单位保存出生位置
        if spawnPosition then
            Timers:CreateTimer(1, function()
                -- 创建新单位
                local newUnit = CreateUnitByName("npc_dota_neutral_prowler_shaman", spawnPosition, true, nil, nil, DOTA_TEAM_BADGUYS)
                
                if newUnit then
                    -- 为新单位保存出生位置  
                    Main.prowlerSpawnPositions[newUnit:GetEntityIndex()] = spawnPosition  -- 添加这行
                    newUnit:SetForwardVector(Vector(0, -1, 0))
                    newUnit:SetControllableByPlayer(1, false)
                    newUnit:SetOwner(nil)
                    newUnit:SetControllableByPlayer(-1, false) -- 旧 API 兼容写法


                    -- 移除neutral_upgrade技能
                    if newUnit:HasAbility("neutral_upgrade") then
                        newUnit:RemoveAbility("neutral_upgrade")
                    end
                    
                    -- 直接给予AI
                    CreateAIForHero(newUnit, {"谁近打谁"}, {"默认策略"}, "野怪AI", 0.1)
                    
                    -- 播放复活特效
                    local particleID = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, newUnit)
                    ParticleManager:ReleaseParticleIndex(particleID)
                    
                    -- 播放复活音效
                    EmitSoundOn("Hero_LoneDruid.BattleCry.Bear", newUnit)
                end
            end)
        end
    end
end

function Main:OnNPCSpawned_SoulOut(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
        
        -- 检查单位是否有指定的modifier
        Timers:CreateTimer(1, function()
        local modifier = spawnedUnit:FindModifierByName("modifier_dazzle_nothl_projection_soul_debuff")
        if modifier then
            -- 设置modifier持续时间为无限(-1表示永久持续)
            modifier:SetDuration(-1, true)
        end
    end)
    end
end