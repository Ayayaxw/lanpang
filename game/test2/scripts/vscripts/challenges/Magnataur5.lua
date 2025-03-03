function Main:Init_Magnataur5(event, playerID)
    -- 技能修改器
    self.courierPool = {}
    self.currentcourierIndex = 1
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    hero_duel.killCount = 0    -- 初始化击杀计数器
    print("[DEBUG] Kill count reset to:", hero_duel.killCount) -- 添加调试打印
    local ability_modifiers = {
        npc_dota_hero_magnataur = {
            magnataur_skewer = {
                AbilityValues = {
                    AbilityCooldown = 3,
                }
            },
            magnataur_horn_toss = {
                AbilityValues = {
                    AbilityCooldown = 3,
                }
            },
        },
    }
    -- 设置英雄配置
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
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
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})
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
    self.limitTime = 60        -- 限定时间为准备时间结束后的一分钟
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
        ["击杀数量"] = "0",
        ["当前总分"] = "0"  -- 添加当前总分
    }
    local order = {"挑战英雄", "剩余时间", "击杀数量", "当前总分"}
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.largeSpawnCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
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
        self.rightTeam = {self.rightTeamHero1}
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 2 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_disarmed", { duration = 3 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_silence", { duration = 3 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = 3 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_break", { duration = 3 })
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
            if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
                self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, modifier, { duration = self.duration - 5 })
            end
        end
    end)

    -- 发送摄像机位置给前端
    self:SendCameraPositionToJS(Main.largeSpawnCenter, 1)

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

        -- 在这里激活马格纳斯的AI
        self:ActivateMagnusAI()

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:PreSpawnMagnatars()
    end)

    -- 比赛开始后才开始传送拍拍熊
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        --self:StartcourierDeployment()
    end)

    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true
    
        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
    
        -- 计算最终得分
        local finalScore = hero_duel.killCount * 10  -- 基础击杀得分
    
        -- 存活到时间结束的奖励
        finalScore = finalScore + 100  -- 完成挑战奖励
    
        -- 对英雄再次施加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.endduration })
            end
        end
    
        -- 停止所有马格纳斯的AI
        if self.magnusPool then
            for _, magnus in pairs(self.magnusPool) do
                if magnus and not magnus:IsNull() then
                    magnus:SetContextThink("MagnusAI", nil, 0)
                    if magnus.ai then magnus.ai = nil end
                    if AIs[magnus] then AIs[magnus] = nil end
                    -- 可选：给马格纳斯添加眩晕效果
                    magnus:AddNewModifier(magnus, nil, "modifier_stunned", {})
                end
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
            ["当前总分"] = finalScore
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)
        -- 结束决斗并更新UI，显示胜利和得分
        CustomGameEventManager:Send_ServerToAllClients("update_final_score", {
            result = "victory",
            survivalTime = "01:00.00",  -- 满时间
            killCount = hero_duel.killCount,
            finalScore = finalScore
        })
    
        -- 播放胜利效果
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            -- 播放胜利音效
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = self.endduration })
            EmitSoundOn("Hero_LegionCommander.Duel.Victory", self.leftTeamHero1)
            self:gradual_slow_down(self.leftTeamHero1:GetOrigin(), self.leftTeamHero1:GetOrigin())
            
            -- 添加胜利特效
            local particle = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", 
                PATTACH_OVERHEAD_FOLLOW, 
                self.leftTeamHero1
            )
            ParticleManager:SetParticleControl(particle, 0, self.leftTeamHero1:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)
            
            -- 添加聚光灯特效
            local particle1 = ParticleManager:CreateParticle(
                "particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", 
                PATTACH_ABSORIGIN, 
                self.leftTeamHero1
            )
            ParticleManager:SetParticleControl(particle1, 0, self.leftTeamHero1:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle1)
            
            -- 胜利动画
            self.leftTeamHero1:StartGesture(ACT_DOTA_VICTORY)
        end
    end)
end

function Main:PreSpawnMagnatars()
    local centerPoint = Vector(self.largeSpawnCenter.x, self.largeSpawnCenter.y, self.largeSpawnCenter.z)  -- 向北移动500码
    local radius = 800  -- 五边形的半径
    local magnusPool = {}

    -- 生成五个马格纳斯在五边形的顶点上
    for i = 1, 10 do
        -- 计算十边形顶点的角度和位置
        local angle = (i - 1) * 36  -- 360/10 = 36度
        local radian = math.rad(angle)
        local spawnX = centerPoint.x + radius * math.cos(radian)
        local spawnY = centerPoint.y + radius * math.sin(radian)
        local spawnPos = Vector(spawnX, spawnY, centerPoint.z)
        
        -- 创建马格纳斯
        local magnus = CreateUnitByName(
            "npc_dota_hero_magnataur",
            spawnPos,
            true,
            nil,
            nil,
            DOTA_TEAM_BADGUYS
        )
        
        if magnus then 
            -- 设置基本属性
            magnus:AddNewModifier(magnus, nil, "modifier_kv_editor", {})
            magnus:AddNewModifier(magnus, nil, "modifier_item_aghanims_shard", {})
            magnus:AddNewModifier(magnus, nil, "modifier_item_ultimate_scepter_consumed", {})
            magnus:AddNewModifier(magnus, nil, "modifier_disarmed", {})
            HeroMaxLevel(magnus)
            
            -- 添加6个能量之球物品
            for j = 1, 6 do
                magnus:AddItemByName("item_energy_booster")
            end
            
            -- 设置朝向中心点
            local direction = (centerPoint - spawnPos):Normalized()
            magnus:SetForwardVector(direction)
            
            table.insert(magnusPool, magnus)
        end
    end
    
    self.magnusPool = magnusPool
end


function Main:ActivateMagnusAI()
    if not self.magnusPool then return end

    for _, magnus in pairs(self.magnusPool) do
        if magnus and not magnus:IsNull() and magnus:IsAlive() then
            magnus:SetContextThink("MagnusAI", function()
                -- 检查基本状态
                if not magnus:IsAlive() or hero_duel.EndDuel then
                    return nil
                end

                local hero = self.leftTeamHero1
                if not hero or hero:IsNull() then return 0.1 end

                -- 获取技能
                local skewer = magnus:FindAbilityByName("magnataur_skewer")
                local hornToss = magnus:FindAbilityByName("magnataur_horn_toss")
                
                -- 检查是否正在施法或被控制
                if magnus:IsChanneling() or 
                   (skewer and skewer:IsInAbilityPhase()) or 
                   (hornToss and hornToss:IsInAbilityPhase()) or
                   CommonAI:IsUnableToCastAbility(magnus, nil) then
                    return 0.1
                end

                -- 获取英雄位置
                local heroPos = hero:GetAbsOrigin()
                local magnusPos = magnus:GetAbsOrigin()

                -- Skewer逻辑
                if skewer and skewer:IsFullyCastable() then
                    local castRange = CommonAI:GetSkillCastRange(magnus, skewer)
                    local direction = (heroPos - magnusPos):Normalized()
                    local targetPoint = magnusPos + direction * castRange
                    
                    magnus:CastAbilityOnPosition(targetPoint, skewer, magnus:GetPlayerOwnerID())
                    return 0.1
                end

                -- Horn Toss逻辑 - 当Skewer在冷却中时使用
                if hornToss and hornToss:IsFullyCastable() and skewer and not skewer:IsFullyCastable() then
                    magnus:CastAbilityNoTarget(hornToss, magnus:GetPlayerOwnerID())
                    return 0.1
                end

                return 0.1
            end, 0)
        end
    end
end


function Main:OnUnitKilled_Magnataur5(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel then return end

    -- 先检查是否是玩家英雄死亡
    if killedUnit == self.leftTeamHero1 then
        self:ProcessHeroDeath_Magnataur5(killedUnit, killer)
        return -- 英雄死亡后直接返回，不再处理其他逻辑
    end

    -- 如果不是英雄死亡，检查是否是马格纳斯死亡
    if killedUnit:GetUnitName() == "npc_dota_hero_magnataur" then
        self:ProcessHeroDeath_Magnataur5(killedUnit, killer)
    end
end

function Main:ProcessHeroDeath_Magnataur5(killedUnit, killer)
    local function CalculateCurrentScore()
        -- 击杀得分：每个猛犸20分
        return hero_duel.killCount * 10
    end

    local function CalculateFinalScore()
        local score = hero_duel.killCount * 10  -- 基础击杀得分
    
        -- 如果击杀了所有猛犸或者时间到了，额外加100分
        if hero_duel.killCount >= 10 or (not killedUnit == self.leftTeamHero1) then
            score = score + 100
            
            -- 加入剩余时间得分
            local currentTime = GameRules:GetGameTime() - self.startTime
            local remainingTime = math.max(0, self.limitTime - currentTime)
            score = score + math.floor(remainingTime)
        end
        
        return math.floor(score)
    end
    
    print("ProcessHeroDeath_Magnataur5 called for unit: ", killedUnit:GetUnitName())
    


        -- 只有英雄本体死亡才结束游戏
        if killedUnit == self.leftTeamHero1 then
            print("Player hero died, processing game end")
            
            -- 立即停止计时器和设置结束标志
            hero_duel.EndDuel = true
            self.currentTimer = self.currentTimer + 1
            CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})

            -- 停止所有马格纳斯的AI
            if self.magnusPool then
                for _, magnus in pairs(self.magnusPool) do
                    if magnus and not magnus:IsNull() then
                        magnus:SetContextThink("MagnusAI", nil, 0)
                        if magnus.ai then magnus.ai = nil end
                        if AIs[magnus] then AIs[magnus] = nil end
                    end
                end
            end
            -- 计算剩余时间和最终得分
            local currentTime = GameRules:GetGameTime() - self.startTime
            local remainingTime = math.max(0, self.limitTime - currentTime)
            local formattedTime = string.format("%02d:%02d.%02d", 
                math.floor(remainingTime / 60),
                math.floor(remainingTime % 60),
                math.floor((remainingTime * 100) % 100))
            
            local finalScore = CalculateCurrentScore()

            -- 给击杀者播放胜利效果
            if killer then
                GridNav:DestroyTreesAroundPoint(killer:GetOrigin(), 500, false)
                killer:SetForwardVector(Vector(0, -1, 0))
                killer:StartGesture(ACT_DOTA_VICTORY)
                EmitSoundOn("Hero_LegionCommander.Duel.Victory", killer)
                
                self:gradual_slow_down(killedUnit:GetOrigin(), killer:GetOrigin())
                local particle = ParticleManager:CreateParticle(
                    "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", 
                    PATTACH_OVERHEAD_FOLLOW, 
                    killer
                )
                ParticleManager:SetParticleControl(particle, 0, killer:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)
                
                local particle1 = ParticleManager:CreateParticle(
                    "particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", 
                    PATTACH_ABSORIGIN, 
                    killer
                )
                ParticleManager:SetParticleControl(particle1, 0, killer:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle1)
            end



            -- 计算最终得分（包含血量和剩余时间）
            local finalScore = CalculateFinalScore()
            
            -- 记录结果
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战失败]剩余时间:" .. formattedTime .. ",最终得分:" .. finalScore
            )
            -- 发送最终结果给前端
            CustomGameEventManager:Send_ServerToAllClients("update_final_score", {
                result = "defeat",
                survivalTime = formattedTime,
                killCount = hero_duel.killCount,
                finalScore = finalScore
            })

            -- 确保所有计时器都停止
            Timers:RemoveTimer("MagnusAI")
            return
        end

        -- 马格纳斯死亡的处理
        if killedUnit:GetUnitName() == "npc_dota_hero_magnataur" then
            -- 播放击杀特效
            if killer then
                local particle = ParticleManager:CreateParticle(
                    "particles/generic_gameplay/lasthit_coins_local.vpcf", 
                    PATTACH_ABSORIGIN, 
                    killedUnit
                )
                ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)
                EmitSoundOn("General.Coins", killer)
            end

            -- 清理AI和实体
            Timers:CreateTimer(1.0, function()
                if killedUnit and not killedUnit:IsNull() then
                    killedUnit:SetContextThink("AIThink", nil, 0)
                    if killedUnit.ai then killedUnit.ai = nil end
                    if AIs[killedUnit] then AIs[killedUnit] = nil end
                    killedUnit:RemoveSelf()
                end
            end)
            
            -- 更新击杀数和得分
            hero_duel.killCount = hero_duel.killCount + 1
            local currentScore = CalculateCurrentScore() -- 只计算击杀得分
            local data = {
                ["击杀数量"] = hero_duel.killCount,
                ["当前总分"] = currentScore
            }
            CustomGameEventManager:Send_ServerToAllClients("update_score", data)

            -- 检查是否完成全部击杀
            if hero_duel.killCount >= 10 and not hero_duel.EndDuel then
                hero_duel.EndDuel = true
                CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})

                -- 计算最终得分
                local currentTime = GameRules:GetGameTime() - self.startTime
                local remainingTime = math.max(0, self.limitTime - currentTime)
                local formattedTime = string.format("%02d:%02d.%02d", 
                    math.floor(remainingTime / 60),
                    math.floor(remainingTime % 60),
                    math.floor((remainingTime * 100) % 100))

                local finalScore = CalculateFinalScore()

                -- 记录结果
                self:createLocalizedMessage(
                    "[LanPang_RECORD][",
                    self.currentMatchID,
                    "]",
                    "[挑战成功]剩余时间:" .. formattedTime .. ",最终得分:" .. finalScore
                )
                local data = {
                    ["击杀数量"] = hero_duel.killCount,
                    ["当前总分"] = finalScore
                }
                CustomGameEventManager:Send_ServerToAllClients("update_score", data)
                -- 发送胜利消息
                CustomGameEventManager:Send_ServerToAllClients("update_final_score", {
                    result = "victory",
                    survivalTime = formattedTime,
                    killCount = hero_duel.killCount,
                    finalScore = finalScore
                })

                -- 播放胜利效果
                if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                    self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = self.endduration })
                    EmitSoundOn("Hero_LegionCommander.Duel.Victory", self.leftTeamHero1)
                    self:gradual_slow_down(self.leftTeamHero1:GetOrigin(), self.leftTeamHero1:GetOrigin())
                    
                    local particle = ParticleManager:CreateParticle(
                        "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", 
                        PATTACH_OVERHEAD_FOLLOW, 
                        self.leftTeamHero1
                    )
                    ParticleManager:SetParticleControl(particle, 0, self.leftTeamHero1:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(particle)
                    
                    local particle1 = ParticleManager:CreateParticle(
                        "particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", 
                        PATTACH_ABSORIGIN, 
                        self.leftTeamHero1
                    )
                    ParticleManager:SetParticleControl(particle1, 0, self.leftTeamHero1:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(particle1)
                    
                    self.leftTeamHero1:StartGesture(ACT_DOTA_VICTORY)
                end
            end
        end
end

function Main:OnNPCSpawned_Magnataur5(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end