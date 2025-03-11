-- 初始化函数
function Main:Init_Mine_Challenge(event, playerID)
    -- 基础参数初始化
    self.currentMatchID = self:GenerateUniqueID()    
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1 
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 120       -- 比赛时间
    hero_duel.EndDuel = false
    hero_duel.killCount = 0    -- 击杀计数
    hero_duel.currentScore = 0 -- 当前得分

    self:SendCameraPositionToJS(Main.SnipeCenter, 1)

    -- 英雄配置
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation", {})
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

            end,
        }
    }

    local ability_modifiers = {
        npc_dota_hero_techies = {
            techies_land_mines = {
                AbilityValues = {
                    proximity_threshold = 0
                }
            }
        }
    }



    self:UpdateAbilityModifiers(ability_modifiers)

    -- 数据获取
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)

    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)

    -- 播报系统设置
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

    -- 前端显示设置
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["击杀数量"] = "0",
        ["剩余时间"] = self.limitTime,
        ["最终得分"] = "0",  -- 最终得分初始等于击杀数
    }
    local order = {"挑战英雄", "击杀数量", "剩余时间", "最终得分"}
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.SnipeCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1")
                return nil
            end)
        end
    end)

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:DeployMine(timerId)  -- 传入 timerId
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



    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

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

    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    
    -- 比赛开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.startTime = GameRules:GetGameTime()
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    -- 比赛结束判定
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true
    
        -- 直接使用当前分数作为最终分数
        local finalScore = math.floor(hero_duel.currentScore)
        
        -- 结束播报
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战结束]击杀数:" .. hero_duel.killCount .. ",最终得分:" .. finalScore
        )
    
        -- 更新显示
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["当前得分"] = tostring(finalScore)
        })
    
        self:PlayVictoryEffects(self.leftTeamHero1)
    end)
end

-- 部署地雷到战场
function Main:DeployMine(timerId)
    local startPos = Vector(8550, -8796.45, 128.00)
    local endPos = Vector(8550, 7131.07, 128.00)
    local totalMines = 100
    local distanceStep = (endPos.y - startPos.y) / (totalMines - 1)
    
    -- 创建地雷池
    hero_duel.minePool = {}
    
    -- 创建一个炸弹人英雄
    local techies = CreateUnitByName(
        "npc_dota_hero_techies",
        endPos,
        true,
        nil,
        nil,
        DOTA_TEAM_BADGUYS
    )
    
    if techies then
        -- 最大等级
        HeroMaxLevel(techies)
        techies:AddNewModifier(techies, nil, "modifier_kv_editor", {})
        -- 查找地雷技能
        local landMineAbility = techies:FindAbilityByName("techies_land_mines")
        
        if landMineAbility then
            landMineAbility:SetLevel(4)
            
            -- 在每个位置放置地雷
            for i = 1, totalMines do
                local pos = Vector(startPos.x, startPos.y + distanceStep * (i - 1), startPos.z)
                
                -- 设置光标位置并释放技能
                techies:SetCursorPosition(pos)
                landMineAbility:OnSpellStart()
                
                -- 短暂延迟确保技能释放完成
                Timers:CreateTimer(0.03, function()
                    -- 继续下一个地雷
                    return nil
                end)
            end
        end
        
        -- 隐藏技师英雄（可选）
        --techies:AddNoDraw()
        
        -- 保存技师引用，以便后续使用
        hero_duel.techiesHero = techies
    end
end

-- 死亡判定函数
function Main:OnUnitKilled_Mine_Challenge(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    
    if hero_duel.EndDuel then return end

    -- 玩家死亡判定
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        -- 计算剩余时间
        --先记下死亡的地点
        --等待0.03秒
        Timers:CreateTimer(0.03, function()
            local deathPos = killedUnit:GetAbsOrigin()
            killedUnit:RespawnHero(false, false)
            killedUnit:RemoveModifierByName("modifier_fountain_invulnerability")
            killedUnit:SetAbsOrigin(deathPos)
        end)
        return
    end

    -- 地雷死亡判定
    if killedUnit:GetUnitName() == "npc_dota_techies_land_mine" then
        hero_duel.killCount = hero_duel.killCount + 1
        local killer = EntIndexToHScript(args.entindex_attacker)
        local particle = ParticleManager:CreateParticle("particles/generic_gameplay/lasthit_coins_local.vpcf", PATTACH_ABSORIGIN, killedUnit)
        ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)
        -- 播放金币音效
        EmitSoundOn("General.Coins", killer)
        -- 更新显示
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount),
            ["最终得分"] = tostring(hero_duel.killCount)
        })

        -- 检查是否全部击杀完成
        if hero_duel.killCount >= 100 then
            -- 计算剩余时间
            local endTime = GameRules:GetGameTime()
            local timeSpent = endTime - hero_duel.startTime
            local remainingTime = self.limitTime - timeSpent
            local formattedTime = string.format("%02d:%02d.%02d", 
                math.floor(remainingTime / 60),
                math.floor(remainingTime % 60),
                math.floor((remainingTime * 100) % 100))
            
            -- 计算最终得分（击杀数 + 剩余时间）
            local finalScore = hero_duel.killCount
            if remainingTime > 0 then
                finalScore = finalScore + remainingTime
            end
            
            -- 更新显示最终得分和剩余时间
            CustomGameEventManager:Send_ServerToAllClients("update_score", {
                ["剩余时间"] = formattedTime,
                ["击杀数量"] = tostring(hero_duel.killCount),
                ["最终得分"] = tostring(math.floor(finalScore))
            })

            -- 结束播报
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战完成]击杀数:100,最终得分:" .. math.floor(finalScore)
            )

            -- 添加胜利效果
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                -- 添加限制效果
                local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
                for _, modifier in ipairs(modifiers) do
                    self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.endduration })
                end
                
                -- 胜利特效
                EmitSoundOn("Hero_LegionCommander.Duel.Victory", self.leftTeamHero1)
                self:gradual_slow_down(self.leftTeamHero1:GetOrigin(), self.leftTeamHero1:GetOrigin())
                
                -- 胜利粒子效果
                local particle = ParticleManager:CreateParticle(
                    "particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", 
                    PATTACH_OVERHEAD_FOLLOW, 
                    self.leftTeamHero1
                )
                ParticleManager:SetParticleControl(particle, 0, self.leftTeamHero1:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)
                
                -- 聚光灯效果
                local particle1 = ParticleManager:CreateParticle(
                    "particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", 
                    PATTACH_ABSORIGIN, 
                    self.leftTeamHero1
                )
                ParticleManager:SetParticleControl(particle1, 0, self.leftTeamHero1:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle1)
                
                -- 胜利动作和伤害减免
                self.leftTeamHero1:StartGesture(ACT_DOTA_VICTORY)
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_damage_reduction_100", {duration = self.endduration})
            end

            hero_duel.EndDuel = true
        end
    end
end

function Main:OnNPCSpawned_Mine_Challenge(spawnedUnit, event)
    -- 检查是否是地雷单位
    if spawnedUnit:GetUnitName() == "npc_dota_techies_land_mine" then
        -- 将地雷添加到地雷池中
        table.insert(hero_duel.minePool, spawnedUnit)
        spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_anti_invisible", {})
        
        -- 可以在这里对地雷进行额外设置
        spawnedUnit:SetForwardVector(Vector(-1, 0, 0))
    end
    
    -- 原有逻辑保留
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end