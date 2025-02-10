function Main:Cleanup_Work_Work_2()

end

function Main:Init_Work_Work_2(heroName, heroFacet,playerID, heroChineseName)
    -- local ability_modifiers = {
    --     npc_dota_hero_bristleback = {
    --         bristleback_bristleback = {
    --             side_angle = 360,
    --             back_angle = 180
    --         }
    --     },
    -- }
    -- self:UpdateAbilityModifiers(ability_modifiers)


    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    SendToServerConsole("host_timescale 1")          --游戏速度
    self.currentTimer = (self.currentTimer or 0) + 1 --计时器
    local timerId = self.currentTimer     
    
    PlayerResource:SetGold(playerID, 0, false)

    --赛前准备时间
    self.duration = 10
    --赛后庆祝时间
    self.endduration = 10
    -- 限定时间为准备时间结束后的一分钟
    self.limitTime = 60 
    hero_duel.EndDuel = false  

    --赛前播报

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
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(heroName, heroFacet)}
    )

    enemyChineseName=self:GetHeroChineseName(Main.AIheroName)

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择红方]",
        {localize = true, text = Main.AIheroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(Main.AIheroName, self.FacetId)}
    )

    -- 准备要发送的数据
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["对手英雄"] = enemyChineseName,
        ["剩余时间"] = self.limitTime,
    }
    -- 准备要发送的顺序信息
    local order = {"挑战英雄", "对手英雄","剩余时间"}

    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.smallDuelAreaLeft, DOTA_TEAM_GOODGUYS, false, function(playerHero)
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

    -- 创建对手英雄
    CreateHero(playerID, opponentHeroName, opponentFacetId, self.smallDuelAreaRight, DOTA_TEAM_BADGUYS, false, function(opponentHero)
        self:ConfigureHero(opponentHero, false, playerID)
        self:EquipHeroItems(opponentHero, opponentEquipment)
        self.rightTeamHero1 = opponentHero
        self:ListenHeroHealth(self.rightTeamHero1)
        self.currentArenaHeroes[2] = self.rightTeamHero1
        -- 如果启用了AI，为对手英雄创建AI
        if opponentAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.rightTeamHero1, opponentOverallStrategy, opponentHeroStrategy,"rightTeamHero1")
                
                -- 检查是否为米波，如果是，为克隆体也创建AI
                if opponentHeroName == "npc_dota_hero_meepo" then
                    Timers:CreateTimer(0.3, function()
                        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                        local meepos = FindUnitsInRadius(
                            DOTA_TEAM_BADGUYS,
                            opponentHero:GetAbsOrigin(),
                            nil,
                            FIND_UNITS_EVERYWHERE,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_HERO,
                            DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
                            FIND_ANY_ORDER,
                            false
                        )
                        for _, meepo in pairs(meepos) do
                            if meepo:HasModifier("modifier_meepo_divided_we_stand") and meepo:IsRealHero() and meepo ~= opponentHero then
                                CreateAIForHero(meepo, opponentOverallStrategy, opponentHeroStrategy, "rightTeamHero1_clone")
                            end
                        end
                    end)
                end
                
                return nil
            end)
        else
            -- 处理非 AI 情况
        end
    end)


    --两秒赛前自由准备
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = {self.leftTeamHero1}
        self.rightTeam = {self.rightTeamHero1}
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
        end
    end)

    --英雄小礼物

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


    --赛前静止
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_disarmed", { duration = self.duration-5 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_silence", { duration = self.duration-5 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = self.duration-5 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_break", { duration = self.duration-5 })

        end

        if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
            self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_kv_editor", {})
            self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_disarmed", { duration = self.duration-5 })
            self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_silence", { duration = self.duration-5 })
            self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_rooted", { duration = self.duration-5 })
            self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_break", { duration = self.duration-5 })

        end
    end)



    SendCameraPositionToJS(Main.smallDuelArea, 1)


    local challengedHeroChineseName = self:GetHeroChineseName(Main.AIheroName);
    CustomGameEventManager:Send_ServerToAllClients("reset_timer", {remaining = self.limitTime - self.duration, heroChineseName = heroChineseName ,challengedHeroChineseName=challengedHeroChineseName})

    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        Timers:CreateTimer(0.1, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            
            self:MonitorUnitsStatus()
            return 0.01
        end)


        self:SendHeroAndFacetData(heroName, Main.AIheroName, heroFacet, self.FacetId,self.limitTime)
        Timers:CreateTimer(1.1, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[入场动画]"
            )
            
        end)
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

    --比赛开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.startTime = GameRules:GetGameTime() -- 记录开始时间
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
        self:MonitorUnitsStatus()

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[开始战斗]"
        )
    


        print("[DOTA_RECORD] " .. heroChineseName .. ": 开始战斗")
    end)
    

    -- 限定时间结束后执行的操作
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true

        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[计时结束]"
        )
        -- 对英雄再次施加缠绕、缴械、禁锢和破坏效果
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_disarmed", { duration = self.endduration })
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_silence", { duration = self.endduration })
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = self.endduration })
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_break", { duration = self.endduration })
        self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_disarmed", { duration = self.endduration })
        self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_silence", { duration = self.endduration })
        self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_rooted", { duration = self.endduration })
        self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_break", { duration = self.endduration })
    end)
end



function Main:OnUnitKilled_Work_Work_2(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)

    if not hero_duel.EndDuel and killedUnit:IsRealHero() then
        --左边赢了
        local endTime = GameRules:GetGameTime() -- 记录结束时间
        local timeSpent = endTime - self.startTime -- 计算花费的时间（浮点数）
        local remainingTime = self.limitTime - timeSpent -- 计算剩余时间（浮点数）
        local minutes = math.floor(remainingTime / 60)
        local seconds = math.floor(remainingTime % 60)
        local milliseconds = math.floor((remainingTime * 100) % 100)
        local formattedTime = string.format("%02d:%02d.%02d", minutes, seconds, milliseconds)
        local finalScore = math.floor(remainingTime) + 100 -- 最终得分等于取整的剩余时间加100
        local heroName 
        if killedUnit == self.rightTeamHero1  then

            finalScore = math.floor(remainingTime) + 100 -- 最终得分等于取整的剩余时间加100
            self.leftTeamHero1:SetForwardVector(Vector(0, -1, 0))

            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_damage_reduction_100", { duration = self.endduration })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = self.endduration })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_disable_healing", { duration = self.endduration })

            self.leftTeamHero1:StartGesture(ACT_DOTA_VICTORY)

            RotateHero(self.leftTeamHero1)
            EmitSoundOn("Hero_LegionCommander.Duel.Victory", self.leftTeamHero1)

            
            heroName = self.leftTeamHero1:GetUnitName()

            self:gradual_slow_down(killedUnit:GetOrigin() , self.leftTeamHero1:GetOrigin())
            

            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self.leftTeamHero1)

            ParticleManager:SetParticleControl(particle, 0, self.leftTeamHero1:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)

            local particle1 = ParticleManager:CreateParticle("particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", PATTACH_ABSORIGIN, self.leftTeamHero1)
            ParticleManager:SetParticleControl(particle1, 0, self.leftTeamHero1:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle1)

            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[比赛结束]获胜者:绿方,",
                {localize = true, text = heroName}

            )

        elseif killedUnit == self.leftTeamHero1 then
            --右边赢了

            finalScore = math.floor((self.rightTeamHero1:GetHealth() / self.rightTeamHero1:GetMaxHealth()) * 100)


            self.rightTeamHero1:SetForwardVector(Vector(0, -1, 0))
            

            self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_damage_reduction_100", { duration = self.endduration })
            self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_rooted", { duration = self.endduration })
            self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_disable_healing", { duration = self.endduration })
            
            self.rightTeamHero1:StartGesture(ACT_DOTA_VICTORY)


            heroName = self.rightTeamHero1:GetUnitName()

            self:gradual_slow_down(killedUnit:GetOrigin() , self.rightTeamHero1:GetOrigin())

            RotateHero(self.rightTeamHero1)
            EmitSoundOn("Hero_LegionCommander.Duel.Victory", self.rightTeamHero1)
            local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_OVERHEAD_FOLLOW, self.rightTeamHero1)
            ParticleManager:SetParticleControl(particle, 0, self.rightTeamHero1:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)

            local particle1 = ParticleManager:CreateParticle("particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", PATTACH_ABSORIGIN, self.rightTeamHero1)
            ParticleManager:SetParticleControl(particle1, 0, self.rightTeamHero1:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle1)


            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[比赛结束]获胜者:红方,",
                {localize = true, text = heroName}
            )

        else
            return
        end

        hero_duel.EndDuel = true
        local data = {
            ["剩余时间"] = formattedTime
        }
        print("剩余时间",formattedTime)
        
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)
        self:MonitorUnitsStatus()

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[玩家得分]",
            tostring(finalScore)
        )

    end
end


