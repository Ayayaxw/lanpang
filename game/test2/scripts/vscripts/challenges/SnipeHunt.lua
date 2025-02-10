-- 清理函数
function Main:Cleanup_SnipeHunt()

end

-- 初始化函数
function Main:Init_SnipeHunt(event, playerID)
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

    SendCameraPositionToJS(Main.SnipeCenter, 1)

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
                hero:AddNewModifier(hero, nil, "modifier_sniper_kill_bonus", {})
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

    local ability_modifiers = {}
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
        self:DeploySnipers(timerId)  -- 传入 timerId
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
            ["剩余时间"] = "0",
            ["当前得分"] = tostring(finalScore)
        })
    
        -- 添加英雄胜利效果
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            -- 添加限制效果
            local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
            for _, modifier in ipairs(modifiers) do
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.endduration })
            end
            
            -- 胜利特效
            EmitSoundOn("endAegis.Timer", self.leftTeamHero1)
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
    end)
end


-- 部署狙击手到战场
function Main:DeploySnipers(timerId)
    local startPos = Vector(8550, -8796.45, 128.00)
    local endPos = Vector(8550, 7131.07, 128.00)
    local totalSnipers = 100
    local distanceStep = (endPos.y - startPos.y) / (totalSnipers - 1)
    
    hero_duel.sniperPool = {}
    
    for i = 1, totalSnipers do
        local pos = Vector(startPos.x, startPos.y + distanceStep * (i - 1), startPos.z)
        local sniper = CreateUnitByName(
            "sniper",
            pos,
            true,
            nil,
            nil,
            DOTA_TEAM_BADGUYS
        )
        
        if sniper then
            -- 移除狙击手原有的可穿戴装备
            local wearable = sniper:FirstMoveChild()
            while wearable ~= nil do
                if wearable:GetClassname() == "dota_item_wearable" then
                    local nextWearable = wearable:NextMovePeer()
                    UTIL_Remove(wearable)
                    wearable = nextWearable
                else
                    wearable = wearable:NextMovePeer()
                end
            end
            
            -- 创建可穿戴假人
            local dummy = CreateUnitByName(
                "npc_dota_hero_sniper_wearable_dummy",
                sniper:GetAbsOrigin(),
                false,
                sniper,
                sniper,
                DOTA_TEAM_BADGUYS
            )
            
            if dummy then
                dummy:SetControllableByPlayer(-1, false)
                dummy:FollowEntity(sniper, true)

                dummy:AddNewModifier(dummy, nil, "modifier_wearable", {})
                sniper.wearableDummy = dummy
            end
    
            -- 升到7级
            for i = 1, 6 do
                sniper:HeroLevelUp(false)
            end
            
            -- 设置技能等级
            local headshot = sniper:FindAbilityByName("sniper_headshot")
            local assassinate = sniper:FindAbilityByName("sniper_assassinate")
    
            if headshot then
                headshot:SetLevel(4)
            end
            
            if assassinate then
                assassinate:SetLevel(1)
            end
    
            sniper:SetForwardVector(Vector(-1, 0, 0))
            sniper:AddNewModifier(sniper, nil, "modifier_rooted", {})
            table.insert(hero_duel.sniperPool, sniper)
        end
    end
end

-- 死亡判定函数
function Main:OnUnitKilled_SnipeHunt(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    
    if hero_duel.EndDuel then return end

    -- 玩家死亡判定
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        -- 计算剩余时间
        local endTime = GameRules:GetGameTime()
        local timeSpent = endTime - hero_duel.startTime
        local remainingTime = self.limitTime - timeSpent
        local formattedTime = string.format("%02d:%02d.%02d", 
            math.floor(remainingTime / 60),
            math.floor(remainingTime % 60),
            math.floor((remainingTime * 100) % 100))
        
        -- 更新显示剩余时间和得分
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["剩余时间"] = formattedTime,
            ["击杀数量"] = tostring(hero_duel.killCount),
            ["最终得分"] = tostring(hero_duel.killCount)
        })
        
        -- 向裁判发送消息
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败]击杀数:" .. hero_duel.killCount .. ",最终得分:" .. hero_duel.killCount
        )

        hero_duel.EndDuel = true
        return
    end

    -- 狙击手死亡判定部分的修改
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
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

function Main:OnNPCSpawned_SnipeHunt(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end