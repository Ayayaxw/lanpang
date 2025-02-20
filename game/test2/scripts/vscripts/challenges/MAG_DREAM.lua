function Main:Cleanup_MAG_DREAM()

end

function Main:Init_MAG_DREAM(event, playerID)
    -- 技能修改器
    self.ursaPool = {}
    self.currentUrsaIndex = 1
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    hero_duel.killCount = 0    -- 初始化击杀计数器
    local ability_modifiers = {
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
    self.duration = 10         -- 赛前准备时间
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


    -- 发送初始化消息给前端
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["击杀数量"] = "0",
        ["剩余时间"] = self.limitTime,
        ["当前得分"] = "0",
    }
    local order = {"挑战英雄", "击杀数量","剩余时间", "当前得分"}
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
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
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

    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 比赛开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.startTime = GameRules:GetGameTime() -- 记录开始时间
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    Timers:CreateTimer(2, function()
        local player_hero = self.leftTeamHero1
        if not player_hero or player_hero:IsNull() then return end
        local center_pos = player_hero:GetAbsOrigin()
        
        local spawn_x = center_pos.x + 1125
        local base_pos = Vector(spawn_x, center_pos.y, center_pos.z)
        
        -- 创建猛犸战士(友方)
        CreateHero(0, "npc_dota_hero_magnataur", 1, base_pos, DOTA_TEAM_GOODGUYS, false, function(magnus)
            magnus:SetForwardVector(Vector(-1, 0, 0))
            HeroMaxLevel(magnus)
            magnus:AddNewModifier(magnus, nil, "modifier_item_aghanims_shard", {})
            magnus:AddNewModifier(magnus, nil, "modifier_item_ultimate_scepter_consumed", {})
            magnus:AddNewModifier(magnus, nil, "modifier_disarmed", {})
            self.magnus = magnus
        end)
        
        -- 创建5个不同的敌方英雄
        self.enemies = {}
        local enemy_heroes = {
            {name = "npc_dota_hero_earthshaker", items = {"item_heart", "item_assault","item_travel_boots_2","item_greater_crit","item_blink"}},  -- 撼地者：龙心+强袭
            {name = "npc_dota_hero_medusa", items = {"item_skadi", "item_mjollnir","item_monkey_king_bar","item_travel_boots_2","item_greater_crit","item_blink"}},         -- 美杜莎：冰眼+龙心
            {name = "npc_dota_hero_mars", items = {"item_heart", "item_assault","item_travel_boots_2","item_blink"}},         -- 马尔斯：龙心+强袭
            {name = "npc_dota_hero_omniknight", items = {"item_heart", "item_pipe","item_travel_boots_2","item_solar_crest"}},      -- 全能骑士：龙心+笛子
            {name = "npc_dota_hero_antimage", items = {"item_bfury", "item_heart","item_monkey_king_bar","item_moon_shard","item_travel_boots_2"}}        -- 敌法师：狂战+龙心
        }
        
        for i = 1, 5 do
            local offset_y = (i - 3) * 150
            local enemy_pos = Vector(base_pos.x, base_pos.y + offset_y, base_pos.z)
            CreateHero(0, enemy_heroes[i].name, 1, enemy_pos, DOTA_TEAM_BADGUYS, false, function(enemy)
                enemy:SetForwardVector(Vector(-1, 0, 0))
                HeroMaxLevel(enemy)
                enemy:AddNewModifier(enemy, nil, "modifier_item_aghanims_shard", {})
                enemy:AddNewModifier(enemy, nil, "modifier_item_ultimate_scepter_consumed", {})
                enemy:AddNewModifier(enemy, nil, "modifier_disarmed", {})
                
                -- 添加两件装备
                for _, item_name in ipairs(enemy_heroes[i].items) do
                    local item = CreateItem(item_name, enemy, enemy)
                    enemy:AddItem(item)
                end
                
                table.insert(self.enemies, enemy)
            end)
        end
    end)


    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        -- 专门移除缴械效果

        -- 释放大招
        Timers:CreateTimer(0, function()
            local ability = self.magnus:FindAbilityByName("magnataur_reverse_polarity")
            if ability then
                self.magnus:CastAbilityNoTarget(ability, -1)
            end
        end)
        
        -- 释放冲锋
        Timers:CreateTimer(0.4, function()
            local ability = self.magnus:FindAbilityByName("magnataur_skewer")
            if ability then
                self.magnus:CastAbilityOnPosition(self.leftTeamHero1:GetAbsOrigin(), ability, -1)
            end
            self.magnus:RemoveModifierByName("modifier_disarmed")
            for _, enemy in pairs(self.enemies) do
                enemy:RemoveModifierByName("modifier_disarmed")
            end
            
        end)
        
        -- 释放强化
        Timers:CreateTimer(1, function()
            local ability = self.magnus:FindAbilityByName("magnataur_empower")
            if ability then
                local target = self.leftTeamHero1:IsRangedAttacker() and self.magnus or self.leftTeamHero1
                self.magnus:CastAbilityOnTarget(target, ability, -1)
            end
        end)
        
        -- 添加AI
        Timers:CreateTimer(2.5, function()
            CreateAIForHero(self.magnus, {"禁用一技能","禁用三技能","禁用四技能"}, {""}, "magnus_ai", 0.1)
            for i, enemy in ipairs(self.enemies) do
                CreateAIForHero(enemy, {}, {""}, "enemy_ai_" .. i, 0.1)
            end
        end)
    end)

    -- 限定时间结束后的操作
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true

        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("update_score", {["剩余时间"] = "0"})

        -- 对英雄再次施加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.endduration })
            end
            if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
                self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, modifier, { duration = self.endduration })
            end
        end
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
            self.leftTeamHero1:AddNewModifier(hero, nil, "modifier_damage_reduction_100", {duration = self.endduration})
        end
        local finalScore = math.floor(hero_duel.currentScore)
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战成功]击杀数:" .. hero_duel.killCount .. ",最终得分:" .. finalScore
        )

        
    end)
end

function Main:OnUnitKilled_MAG_DREAM(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)
    
    if not killedUnit or killedUnit:IsNull() then return end

    -- 判断是否是玩家或友方猛犸死亡
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        -- 检查玩家和猛犸是否都已死亡
        local allGoodGuysDead = true
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() and self.leftTeamHero1:IsAlive() then
            allGoodGuysDead = false
        end
        if self.magnus and not self.magnus:IsNull() and self.magnus:IsAlive() then
            allGoodGuysDead = false
        end

        -- 只有当双方都死亡时才结束游戏
        if not allGoodGuysDead then
            return
        end

        -- 计算最终得分
        local totalDamagePercent = 0
        local killedCount = 0
        
        -- 计算所有敌方英雄受到的伤害百分比
        for _, enemy in pairs(self.enemies) do
            if not enemy:IsNull() then
                local healthPercent = (enemy:GetMaxHealth() - enemy:GetHealth()) / enemy:GetMaxHealth() * 100
                totalDamagePercent = totalDamagePercent + healthPercent
                
                if not enemy:IsAlive() then
                    killedCount = killedCount + 1
                end
            else
                totalDamagePercent = totalDamagePercent + 100
                killedCount = killedCount + 1
            end
        end

        local finalScore = totalDamagePercent + (killedCount * 100) -- 添加击杀奖励

        -- 计算剩余时间
        local endTime = GameRules:GetGameTime()
        local timeSpent = endTime - hero_duel.startTime
        local remainingTime = self.limitTime - timeSpent
        local formattedTime = string.format("%02d:%02d.%02d", 
            math.floor(remainingTime / 60),
            math.floor(remainingTime % 60),
            math.floor((remainingTime * 100) % 100))

        -- 发送记录消息
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败]击杀数:" .. killedCount .. ",最终得分:" .. math.floor(finalScore)
        )
        
        -- 更新前端显示
        local data = {
            ["击杀数量"] = killedCount,
            ["当前得分"] = tostring(math.floor(finalScore)),
            ["剩余时间"] = formattedTime
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)

        if killer and not killer:IsNull() and killer:IsAlive() then
            -- 添加限制效果
            local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
            for _, modifier in ipairs(modifiers) do
                killer:AddNewModifier(killer, nil, modifier, { duration = self.endduration })
            end
            
            -- 胜利特效
            EmitSoundOn("Hero_LegionCommander.Duel.Victory", killer)
            self:gradual_slow_down(killer:GetOrigin(), killer:GetOrigin())
            
            -- 胜利粒子效果
            local particle = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", 
                PATTACH_OVERHEAD_FOLLOW, 
                killer
            )
            ParticleManager:SetParticleControl(particle, 0, killer:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)
            
            -- 聚光灯效果
            local particle1 = ParticleManager:CreateParticle(
                "particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", 
                PATTACH_ABSORIGIN, 
                killer
            )
            ParticleManager:SetParticleControl(particle1, 0, killer:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle1)
            
            -- 胜利动作和伤害减免
            killer:StartGesture(ACT_DOTA_VICTORY)
            killer:AddNewModifier(killer, nil, "modifier_damage_reduction_100", {duration = self.endduration})
        end


        hero_duel.EndDuel = true
        return
    end
    
    -- 判断是否是敌方英雄死亡
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
        -- 计算当前总得分
        local totalDamagePercent = 0
        local killedCount = 0
        
        for _, enemy in pairs(self.enemies) do
            if not enemy:IsNull() then
                local healthPercent = (enemy:GetMaxHealth() - enemy:GetHealth()) / enemy:GetMaxHealth() * 100
                totalDamagePercent = totalDamagePercent + healthPercent
                
                if not enemy:IsAlive() then
                    killedCount = killedCount + 1
                end
            else
                totalDamagePercent = totalDamagePercent + 100
                killedCount = killedCount + 1
            end
        end
        
        local currentScore = totalDamagePercent + (killedCount * 100) -- 添加击杀奖励
        
        -- 如果击杀了所有敌人，加上剩余时间
        if killedCount == 5 then
            local endTime = GameRules:GetGameTime()
            local timeSpent = endTime - hero_duel.startTime
            local remainingTime = self.limitTime - timeSpent
            if remainingTime > 0 then
                currentScore = currentScore + remainingTime * 10
                -- 格式化剩余时间显示
                local formattedTime = string.format("%02d:%02d.%02d", 
                    math.floor(remainingTime / 60),
                    math.floor(remainingTime % 60),
                    math.floor((remainingTime * 100) % 100))
                
                -- 更新前端显示并结束游戏
                local data = {
                    ["击杀数量"] = killedCount,
                    ["当前得分"] = tostring(math.floor(currentScore)),
                    ["剩余时间"] = formattedTime
                }
                CustomGameEventManager:Send_ServerToAllClients("update_score", data)
            end

            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功]最终得分:" .. math.floor(currentScore)
            )



            -- 确定胜利者并播放胜利动画
            local victor = nil
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() and self.leftTeamHero1:IsAlive() then
                victor = self.leftTeamHero1
            elseif self.magnus and not self.magnus:IsNull() and self.magnus:IsAlive() then
                victor = self.magnus
            end

            if victor then
                -- 添加限制效果
                local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
                for _, modifier in ipairs(modifiers) do
                    victor:AddNewModifier(victor, nil, modifier, { duration = self.endduration })
                end
                
                -- 胜利特效
                EmitSoundOn("Hero_LegionCommander.Duel.Victory", victor)
                self:gradual_slow_down(victor:GetOrigin(), victor:GetOrigin())
                
                -- 胜利粒子效果
                local particle = ParticleManager:CreateParticle(
                    "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", 
                    PATTACH_OVERHEAD_FOLLOW, 
                    victor
                )
                ParticleManager:SetParticleControl(particle, 0, victor:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)
                
                -- 聚光灯效果
                local particle1 = ParticleManager:CreateParticle(
                    "particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", 
                    PATTACH_ABSORIGIN, 
                    victor
                )
                ParticleManager:SetParticleControl(particle1, 0, victor:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle1)
                
                -- 胜利动作和伤害减免
                victor:StartGesture(ACT_DOTA_VICTORY)
                victor:AddNewModifier(victor, nil, "modifier_damage_reduction_100", {duration = self.endduration})
            end

            hero_duel.EndDuel = true

            
            return
        end

        -- 更新前端显示
        local data = {
            ["击杀数量"] = killedCount,
            ["当前得分"] = tostring(math.floor(currentScore))
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)
    end
end

function Main:OnNPCSpawned_MAG_DREAM(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end