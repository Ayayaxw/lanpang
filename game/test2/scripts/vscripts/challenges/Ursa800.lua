function Main:Cleanup_Ursa800()

end

function Main:Init_Ursa800(event, playerID)
    -- 技能修改器
    self.ursaPool = {}
    self.currentUrsaIndex = 1
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    hero_duel.killCount = 0    -- 初始化击杀计数器
    print("[DEBUG] Kill count reset to:", hero_duel.killCount) -- 添加调试打印
    local ability_modifiers = {
        npc_dota_hero_ursa = {
            ursa_earthshock = {
                AbilityCooldown = 0.2,
            },
        },
    }
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    -- 设置英雄配置
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_small", {})
                HeroMaxLevel(hero)
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


    self:UpdateAbilityModifiers(ability_modifiers)

    -- 设置游戏速度
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer
    self.PlayerChineseName = heroChineseName

    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 99999, true)

    -- 定义时间参数
    self.duration = 5         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 100        -- 限定时间为准备时间结束后的一分钟
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

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择红方]",
        {localize = true, text = opponentHeroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(opponentHeroName, opponentFacetId)}
    )


    -- 发送初始化消息给前端
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["剩余时间"] = self.limitTime,
        ["击杀数量"] = "0"  -- 添加击杀数初始值
    }
    local order = {"挑战英雄", "剩余时间", "击杀数量"}
    SendInitializationMessage(data, order)




    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.smallDuelArea, DOTA_TEAM_GOODGUYS, false, function(playerHero)
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

    -- 赛前准备
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = {self.leftTeamHero1}
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
        end
    end)

    -- 给英雄添加小礼物

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    -- 赛前限制
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        -- 给双方英雄添加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.duration - 5 })
            end
        end
    end)

    -- 发送摄像机位置给前端
    SendCameraPositionToJS(Main.smallDuelArea, 1)

    -- 监视战斗状态并开始计时
--[[     Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        Timers:CreateTimer(0.1, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

            return 0.01
        end)

        self:SendHeroAndFacetData(heroName, opponentHeroName, selfFacetId, opponentFacetId, self.limitTime)
        Timers:CreateTimer(2, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 0.5")
        end)
        Timers:CreateTimer(3, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 1")
        end)
    end) ]]

    -- 比赛即将开始
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 比赛开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.startTime = GameRules:GetGameTime() -- 记录开始时间
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)



    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:PreSpawnUrsas()
    end)

    -- 比赛开始后才开始传送拍拍熊
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:StartUrsaDeployment()
    end)

    -- 限定时间结束后的操作
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true

        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})

        -- 对英雄再次施加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.endduration })
            end
        end
    end)
end

function Main:StartUrsaDeployment()
    Timers:CreateTimer(function()
        if hero_duel.EndDuel then return end
        
        if self.currentUrsaIndex <= #self.ursaPool then
            -- 每次只召唤一只拍拍熊
            local ursa = self.ursaPool[self.currentUrsaIndex]
            if ursa and not ursa:IsNull() then
                ursa:RemoveModifierByName("modifier_invisible")
                ursa:RemoveModifierByName("modifier_invulnerable")
                ursa:AddNewModifier(ursa, nil, "modifier_auto_elevation_small", {})
                
                FindClearSpaceForUnit(ursa, self.smallDuelAreaRight, true)
                ursa:SetForwardVector(Vector(-1, 0, 0))
                ursa:AddNewModifier(ursa, nil, "modifier_truesight_vision", {})
                
                -- 保存AI名称到单位
                local aiName = "ursa_" .. self.currentUrsaIndex
                ursa.aiName = aiName
                
                -- 创建AI
                CreateAIForHero(
                    ursa,
                    {},
                    {"用跳赶路"},
                    aiName,
                    0.5
                )
            end
            
            self.currentUrsaIndex = self.currentUrsaIndex + 1
            return 0.33  -- 每0.33秒生成一只
        end
        
        return nil
    end)
end

function Main:PreSpawnUrsas()
    local spawnPoint = Vector(20000, 20000, 128) -- 远离视野的位置
    self.ursaPool = {}
    self.currentUrsaIndex = 1
    local totalUrsas = 300 -- 根据限定时间确定要生成的拍拍熊数量
    PrecacheModel("models/heroes/ursa/ursa.vmdl", context)
    for i = 1, totalUrsas do
        local ursaUnit = CreateUnitByName(
            "npc_dota_hero_ursa",
            spawnPoint,
            true,
            nil,
            nil,
            DOTA_TEAM_BADGUYS
        )
        
        if ursaUnit then
            -- 升级到2级
            ursaUnit:HeroLevelUp(false) -- 升一级，不播放特效
            
            -- 学习一技能和二技能
            local ability1 = ursaUnit:GetAbilityByIndex(0)
            local ability2 = ursaUnit:GetAbilityByIndex(2)
            if ability1 then ability1:SetLevel(1) end
            if ability2 then ability2:SetLevel(1) end
                            -- 设置朝向西边
            ursaUnit:SetForwardVector(Vector(-1, 0, 0))
            -- 添加无冷却、无敌和隐身效果
            --ursaUnit:AddNewModifier(ursaUnit, nil, "modifier_no_cooldown_FirstSkill", {})
            ursaUnit:AddNewModifier(ursaUnit, nil, "modifier_invisible", {})
            ursaUnit:AddNewModifier(ursaUnit, nil, "modifier_invulnerable", {})
            --ursaUnit:AddNewModifier(ursaUnit, nil, "modifier_item_aghanims_shard", {})
            ursaUnit:AddNewModifier(ursaUnit, nil, "modifier_kv_editor", {})
            ursaUnit:AddNewModifier(ursaUnit, nil, "modifier_no_cooldown_FirstSkill", {})
            
            -- 存入池中
            table.insert(self.ursaPool, ursaUnit)
        end
    end
end




function Main:OnUnitKilled_Ursa800(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)
    print("死了")
    if hero_duel.EndDuel or not killedUnit:IsRealHero() then
        return
    end

    self:ProcessHeroDeath_Ursa800(killedUnit, killer)
end






function Main:ProcessHeroDeath_Ursa800(killedUnit, killer)
    print("ProcessHeroDeath_Ursa800 called for unit: ", killedUnit:GetUnitName())
    
    -- IsHeroTrulyDead(killedUnit, function(isDead)
    --     print("IsHeroTrulyDead callback - isDead: ", isDead)
    --     if not isDead then
    --         print("Unit not truly dead, returning")
    --         return
    --     end

        local isPlayerHero = (killedUnit == self.leftTeamHero1 or (self:isMeepoClone(killedUnit) and killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS))
        print("Is player hero killed: ", isPlayerHero)
        print("Current EndDuel status: ", hero_duel.EndDuel)
        print("Current Timer: ", self.currentTimer)

        if isPlayerHero then
            if killer then
                -- 给击杀者播放胜利特效
                GridNav:DestroyTreesAroundPoint(killer:GetOrigin(), 500, false)
                killer:SetForwardVector(Vector(0, -1, 0))
                
                -- 添加胜利动画
                killer:StartGesture(ACT_DOTA_VICTORY)
                
                -- 播放胜利音效
                EmitSoundOn("Hero_LegionCommander.Duel.Victory", killer)
                
                -- 添加胜利特效
                self:gradual_slow_down(killedUnit:GetOrigin(), killer:GetOrigin())
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, killer)
                ParticleManager:SetParticleControl(particle, 0, killer:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)
                
                -- 添加聚光灯特效
                local particle1 = ParticleManager:CreateParticle("particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", PATTACH_ABSORIGIN, killer)
                ParticleManager:SetParticleControl(particle1, 0, killer:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle1)
            end


            print("Player hero died, processing game end")
            
            -- 计算剩余时间（假设总时间是300秒）
            local totalTime = 100
            local currentTime = GameRules:GetGameTime() - self.startTime
            local remainingTime = math.max(0, totalTime - currentTime)
            
            local formattedTime = string.format("%02d:%02d.%02d", 
                math.floor(remainingTime / 60),
                math.floor(remainingTime % 60),
                math.floor((remainingTime * 100) % 100))
            
            print("Remaining time: ", remainingTime)
            print("Formatted remaining time: ", formattedTime)
            print("Kill count: ", hero_duel.killCount)

            -- 设置结束标志
            print("Setting EndDuel to true")
            hero_duel.EndDuel = true
            print("Incrementing currentTimer")
            self.currentTimer = self.currentTimer + 1

            -- 发送更新分数事件，使用剩余时间
            CustomGameEventManager:Send_ServerToAllClients("update_score", {
                ["剩余时间"] = formattedTime
            })

            -- 记录结果
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战失败]剩余时间:" .. formattedTime .. ",击杀数:" .. hero_duel.killCount
            )

            -- 结束决斗并更新UI
            print("Sending final score update to clients")
            CustomGameEventManager:Send_ServerToAllClients("update_final_score", {
                result = "defeat",
                survivalTime = formattedTime,
                killCount = hero_duel.killCount
            })
        else
            print("Ursa died, updating kill count")
            if killer then
                -- 播放金币特效
                local particle = ParticleManager:CreateParticle("particles/generic_gameplay/lasthit_coins_local.vpcf", PATTACH_ABSORIGIN, killedUnit)
                ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)
                -- 播放金币音效
                EmitSoundOn("General.Coins", killer)
            end
            -- 一秒后清理AI和实体
            Timers:CreateTimer(1.0, function()
                -- 停止实体的AI思考
                if killedUnit and not killedUnit:IsNull() then
                    killedUnit:SetContextThink("AIThink", nil, 0)
                end
                
                -- 移除AI引用
                if killedUnit.ai then
                    killedUnit.ai = nil
                end
                
                -- 从AIs表中移除
                if AIs[killedUnit] then
                    AIs[killedUnit] = nil
                end
                
                -- 移除实体
                if killedUnit and not killedUnit:IsNull() then
                    killedUnit:RemoveSelf()
                end
            end)
            
            -- 更新击杀数并发送给前端
            hero_duel.killCount = hero_duel.killCount + 1
            local data = {
                ["击杀数量"] = hero_duel.killCount
            }
            CustomGameEventManager:Send_ServerToAllClients("update_score", data)
        end
    --end)
end

function Main:OnNPCSpawned_Ursa800(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end