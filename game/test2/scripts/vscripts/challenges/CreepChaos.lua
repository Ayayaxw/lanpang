function Main:Init_CreepChaos(event, playerID)
    -- 1. 基础参数初始化
    self.currentMatchID = self:GenerateUniqueID()    
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1 
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)
    
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS}
    self:CreateTrueSightWards(teams)

    self.duration = 10
    self.endduration = 10
    self.limitTime = 60
    self.leftTeamHeroes = {}
    self.rightTeamHeroes = {}
    hero_duel.EndDuel = false
    hero_duel.killCount = 0
    hero_duel.totalEnemyUnits = 0  -- 用于记录总敌人数量
    self:SendCameraPositionToJS(Main.waterFall_Center, 1)
    hero_duel.finalScore = 0
    -- 修改前端观众播报，添加得分显示

    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = 5})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
            end,
        },
        FRIENDLY = {
            function(hero)
                hero:SetForwardVector(Vector(1, 0, 0))
            end,
        },
        ENEMY = {
            function(hero)
                hero:SetForwardVector(Vector(-1, 0, 0))
            end,
        },
        BATTLEFIELD = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_waterfall", {})
            end,
        }
    }

    -- 3. 获取双方数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["击杀数量"] = "0",
        ["剩余时间"] = self.limitTime,
        ["当前得分"] = "0",
    }
    local order = {"挑战英雄", "击杀数量", "剩余时间", "当前得分"}
    SendInitializationMessage(data, order)
    -- 2. 英雄配置
    -- 4. 播报系统
    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[新挑战]"
    )

    CreateHero(playerID, heroName, selfFacetId, self.waterFall_Left, DOTA_TEAM_GOODGUYS, true, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        self.leftTeam = {self.leftTeamHero1}
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                -- 为主Meepo启用AI
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1")
                return nil
            end)
        end
    end)


        -- 创建敌方主要单位(King)
    local king = CreateUnitByName("npc_dota_neutral_king", self.waterFall_Right, true, nil, nil, DOTA_TEAM_BADGUYS)
    self.rightTeamHero1 = king
    self.rightTeam = {self.rightTeamHero1}
    self.currentArenaHeroes[2] = king
    hero_duel.totalEnemyUnits = 1
    
    -- 创建每种类型的野怪
    for _, unitName in ipairs(neutral_units) do
        local creepUnit = CreateUnitByName(unitName, self.waterFall_Right, true, nil, nil, DOTA_TEAM_BADGUYS)
        creepUnit:SetControllableByPlayer(0, true)
        creepUnit:RemoveAbility("neutral_upgrade")
        table.insert(self.rightTeam, creepUnit)
        hero_duel.totalEnemyUnits = hero_duel.totalEnemyUnits + 1
    end

    -- 为所有敌方单位启用AI的定时器
    Timers:CreateTimer(self.duration - 0.7, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        -- 为King启用AI
        CreateAIForHero(self.rightTeamHero1, {"禁用一技能"}, {"默认策略"}, "rightTeamHero1")
        
        -- 为所有野怪启用AI
        for _, creep in pairs(self.rightTeam) do
            if creep ~= self.rightTeamHero1 and IsValidEntity(creep) then
                CreateAIForHero(creep, {"默认策略"}, {"默认策略"}, "neutral_creep")
            end
        end
        return nil
    end)
    
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        -- 让右边的米波释放技能
        if self.rightTeamHero1 and IsValidEntity(self.rightTeamHero1) then
            local stackAbility = self.rightTeamHero1:FindAbilityByName("stack_units")
            if stackAbility then
                stackAbility:OnSpellStart()
            end
        end

        -- 准备一个英雄进入左侧决斗区域
        self:PrepareHeroForDuel(
            self.leftTeamHero1,                     -- 英雄单位
            self.waterFall_Left,      -- 左侧决斗区域坐标
            self.duration - 5,                      -- 限制效果持续20秒
            Vector(1, 0, 0)          -- 朝向右侧
        )
    
        self:PrepareHeroForDuel(
            self.rightTeamHero1,        
            self.waterFall_Right,     
            self.duration - 5,           
            Vector(-1, 0, 0)         
        )

    end)

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroPreparation(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroBenefits(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
    end)
    -- 6. 赛前准备
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
    end)



    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.startTime = GameRules:GetGameTime() -- 记录开始时间
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
        self:MonitorUnitsStatus()

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)


    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
    
        self:SendLeftHeroData(heroName, selfFacetId)
        
        -- 慢动作效果
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
        
        -- 时间到时，最终得分就是击杀数
        hero_duel.finalScore = hero_duel.killCount
        
        -- 更新前端显示
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["剩余时间"] = "0",
            ["当前得分"] = tostring(hero_duel.finalScore)
        })
    
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败],最终得分:" .. hero_duel.finalScore
        )
        


        self:DisableHeroWithModifiers(self.leftTeamHero1, self.endduration)
        self:DisableHeroWithModifiers(self.rightTeamHero1, self.endduration)

    end)
end


-- 获取英雄类型
function Main:GetHeroType(heroId)
    for _, heroData in pairs(heroes_precache) do
        if heroData.id == heroId then
            return heroData.type
        end
    end
    return 1 -- 默认类型
end

function Main:OnUnitKilled_CreepChaos(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel then
        return
    end

    -- 如果绿方英雄死亡
    if killedUnit == self.leftTeamHero1 then
        hero_duel.EndDuel = true
        
        -- 停止所有定时器
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount),
            ["当前得分"] = tostring(hero_duel.killCount)
        })
        
        -- 播放失败动画
        self:PlayDefeatAnimation(self.leftTeamHero1)
        
        -- 记录比赛结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败],最终得分:" .. hero_duel.finalScore

        )

        -- 禁用所有英雄
        self:DisableHeroWithModifiers(self.leftTeamHero1, self.endduration)
        self:DisableHeroWithModifiers(self.rightTeamHero1, self.endduration)

    -- 检查红方单位死亡情况
    elseif killedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS and table.contains(self.rightTeam, killedUnit) then
        -- 增加击杀计数
        hero_duel.killCount = hero_duel.killCount + 1
        -- 基础得分等于击杀数
        hero_duel.finalScore = hero_duel.killCount

        -- 更新前端显示
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount),
            ["当前得分"] = tostring(hero_duel.finalScore)
        })

        -- 特效和音效
        local particle = ParticleManager:CreateParticle("particles/generic_gameplay/lasthit_coins_local.vpcf", PATTACH_ABSORIGIN, killedUnit)
        ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)
        EmitSoundOn("General.Coins", killer)
        
        -- 检查是否全部击杀完成
        if hero_duel.killCount >= hero_duel.totalEnemyUnits then
            hero_duel.EndDuel = true
            
            -- 计算剩余时间和最终得分
            local timeSpent = GameRules:GetGameTime() - hero_duel.startTime
            local remainingTime = math.max(0, self.limitTime - timeSpent)
            local formattedTime = string.format("%02d:%02d.%02d", 
                math.floor(remainingTime / 60),
                math.floor(remainingTime % 60),
                math.floor((remainingTime * 100) % 100))
            
            -- 全部击杀完成后，最终得分 = 击杀数 + 剩余时间
            hero_duel.finalScore = hero_duel.killCount + math.floor(remainingTime)
            
            -- 更新前端显示
            CustomGameEventManager:Send_ServerToAllClients("update_score", {
                ["剩余时间"] = formattedTime,
                ["当前得分"] = tostring(hero_duel.finalScore)
            })
            
            self:PlayVictoryEffects(self.leftTeamHero1)
            
            -- 发送胜利消息
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功],最终得分:" .. hero_duel.finalScore
            )
        end
    end
end

-- NPC生成时应用战场配置
function Main:OnNPCSpawned_CreepChaos(spawnedUnit, event)
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end