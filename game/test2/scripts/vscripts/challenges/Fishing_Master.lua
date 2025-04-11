function Main:Init_Fishing_Master(event, playerID)
    -- 技能修改器
    self.courierPool = {}
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    hero_duel.killCount = 0    -- 初始化击杀计数器

    local ability_modifiers = {
    }

    
    self:SetDamagePanelEnabled(true)

    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                local heroName = hero:GetUnitName()

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
    local selfSkillThresholds = self:getDefaultIfEmpty(event.selfSkillThresholds)
    local otherSettings = {skillThresholds = selfSkillThresholds}

    local heroName = self:GetHeroNames(selfHeroId)


    self:UpdateAbilityModifiers(ability_modifiers)

    -- 设置游戏速度
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer

    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 99999, true)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 100        
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
        ["挑战英雄"] = heroName,
        ["剩余时间"] = self.limitTime,
        ["击杀数量"] = "0",
        ["当前总分"] = "0"  -- 添加当前总分
    }
    local order = {"挑战英雄", "剩余时间", "击杀数量", "当前总分"}
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.waterFall_Center, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        -- 如果启用了AI，为玩家英雄创建AI
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 1, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1",0.01, otherSettings)

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

    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        local ability_modifiers = {
            npc_dota_hero_slark = {
                slark_pounce =
                {
                    AbilitySound = {
                        value = ""
                    },
    
    
                    AbilityValues = {
                        essence_stacks = {
                            value = 2
                        },
                        pounce_distance = {
                            value = 200
                        },
                        AbilityCooldown = {
                            value = 1
                        },
                        pounce_acceleration = {
                            value = 1000
                        },
                        leash_duration = {
                            value = 0
                        },
                        pounce_speed = {
                            value = 300
                        },
                        AbilityManaCost = {
                            value = 0
                        },
                    }
                },
            }
        }
    
        self:UpdateAbilityModifiers(ability_modifiers)
    end)

    local teams = { DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    -- 赛前限制
    Timers:CreateTimer(3, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:PrepareHeroForDuel(
            self.leftTeamHero1,                     -- 英雄单位
            self.waterFall_Center,      -- 左侧决斗区域坐标
            self.duration - 3,                      -- 限制效果持续20秒
            Vector(0, 1, 0)          -- 朝向北侧
        )
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

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )

        for _, slark in pairs(self.golemPool) do
            if slark and not slark:IsNull() then
                slark:AddNewModifier(slark, nil, "modifier_slark_shadow_dance_persistent", {fade_time = 0.5})
                self:StartSlarkAI(slark)
            end
        end



    end)

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:PreSpawnGolem()
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
        local finalScore = hero_duel.killCount

        -- 记录结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败],最终得分:" .. finalScore
        )
        local data = {
            ["击杀数量"] = hero_duel.killCount,
            ["当前总分"] = finalScore
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)

    
        -- 播放胜利效果
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self:PlayDefeatAnimation(self.leftTeamHero1)
        end
    end)
end

function Main:PreSpawnGolem()
    -- 获取矩形区域中心点
    local left = self.largeSpawnArea_northWest.x
    local right = self.largeSpawnArea_northEast.x
    local top = self.largeSpawnArea_northWest.y
    local bottom = self.largeSpawnArea_southWest.y
    local centerX = (left + right) / 2
    local centerY = (top + bottom) / 2
    local centerPos = Vector(centerX, centerY, self.largeSpawnArea_northWest.z)
    
    -- 直接创建100个Slark单位
    local slarkPool = {}
    
    for i = 1, 100 do
        local slark = CreateUnitByName("slark", centerPos, true, nil, nil, DOTA_TEAM_BADGUYS)
        if slark then
            table.insert(slarkPool, slark)
        end
    end
    
    self.golemPool = slarkPool

    
    -- 添加缴械效果并重新分布Slark单位
    self:DisarmAndRepositionGolems()
end

-- 修改函数：添加缴械效果并重新分布Slark单位
function Main:DisarmAndRepositionGolems()
    if not self.golemPool or #self.golemPool == 0 then

        return
    end
    

    -- 给所有Slark添加6秒缴械效果
    for _, slark in pairs(self.golemPool) do
        if slark and not slark:IsNull() then
            -- 添加缴械效


            slark:SetUnitName("npc_dota_hero_slark")
            slark:AddNewModifier(slark, nil, "modifier_disarmed", {})
            slark:AddNewModifier(slark, nil, "modifier_damage_reduction_100", { duration = 6.0 })
            slark:SetAcquisitionRange(5000)
            --slark:SetControllableByPlayer(0, false)
            slark:AddNewModifier(slark, nil, "modifier_kv_editor", {})
            --给与缴械效果
            slark:AddNewModifier(slark, nil, "modifier_phased", {})

            for i = 1, 9 do
                slark:HeroLevelUp(false)
            end

            
            -- 升级 slark_pounce 1级
            
            local pounce_ability = slark:FindAbilityByName("slark_pounce")
            if pounce_ability then
                pounce_ability:SetLevel(1)
            end
            
            -- 升级 slark_essence_shift 1级（假设默认0级）
            local essence_shift_ability = slark:FindAbilityByName("slark_essence_shift")
            if essence_shift_ability then
                essence_shift_ability:SetLevel(4)
            end
            
            -- 升级 slark_shadow_dance 3级
            local shadow_dance_ability = slark:FindAbilityByName("slark_shadow_dance")
            if shadow_dance_ability then
                shadow_dance_ability:SetLevel(3)
            end
            
            local rage_ability = slark:FindAbilityByName("life_stealer_rage")
            if rage_ability then
                rage_ability:SetLevel(4)
            end

        end
    end
    
    -- 设置三个圆的半径，可以根据Slark数量动态调整
    local slarkCount = #self.golemPool
    
    -- 根据总数动态分配三个圆的半径和每个圆的Slark数量
    local smallRadius = 600
    local mediumRadius = 800
    local largeRadius = 1000
    
    -- 根据Slark总数动态分配到三个圆上的数量
    local smallCircleCount = math.floor(slarkCount * 0.2)  -- 小圈20%
    local mediumCircleCount = math.floor(slarkCount * 0.3) -- 中圈30%
    local largeCircleCount = slarkCount - smallCircleCount - mediumCircleCount -- 大圈剩余的
    

    -- Slark中心位置
    local center = Main.waterFall_Center
    
    -- 分布小圈Slark
    for i = 1, smallCircleCount do
        local angle = (i-1) * (360 / smallCircleCount)
        local x = center.x + smallRadius * math.cos(angle * math.pi / 180)
        local y = center.y + smallRadius * math.sin(angle * math.pi / 180)
        local newPos = Vector(x, y, center.z)
        
        local slark = self.golemPool[i]
        if slark and not slark:IsNull() then
            FindClearSpaceForUnit(slark, newPos, true)
            
            -- 让Slark面朝圆心
            local direction = (center - newPos):Normalized()
            slark:SetForwardVector(direction)
        end
    end
    
    -- 分布中圈Slark
    for i = 1, mediumCircleCount do
        local angle = (i-1) * (360 / mediumCircleCount)
        local x = center.x + mediumRadius * math.cos(angle * math.pi / 180)
        local y = center.y + mediumRadius * math.sin(angle * math.pi / 180)
        local newPos = Vector(x, y, center.z)
        
        local slark = self.golemPool[smallCircleCount + i]
        if slark and not slark:IsNull() then
            FindClearSpaceForUnit(slark, newPos, true)
            
            -- 让Slark面朝圆心
            local direction = (center - newPos):Normalized()
            slark:SetForwardVector(direction)
        end
    end
    
    -- 分布大圈Slark
    for i = 1, largeCircleCount do
        local angle = (i-1) * (360 / largeCircleCount)
        local x = center.x + largeRadius * math.cos(angle * math.pi / 180)
        local y = center.y + largeRadius * math.sin(angle * math.pi / 180)
        local newPos = Vector(x, y, center.z)
        
        local slark = self.golemPool[smallCircleCount + mediumCircleCount + i]
        if slark and not slark:IsNull() then
            FindClearSpaceForUnit(slark, newPos, true)
            
            -- 让Slark面朝圆心
            local direction = (center - newPos):Normalized()
            slark:SetForwardVector(direction)
        end
    end
    

end

function Main:OnUnitKilled_Fishing_Master(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel then return end

    -- 先检查是否是玩家英雄死亡
    if killedUnit == self.leftTeamHero1 then
        hero_duel.EndDuel = true
        
        -- 停止所有定时器
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount),
            ["当前总分"] = tostring(hero_duel.killCount)
        })
        
        -- 播放失败动画
        self:PlayDefeatAnimation(killer)
        local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS}
        self:CreateTrueSightWards(teams)
        -- 记录比赛结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败],最终得分:" .. hero_duel.killCount
        )


    end

    if killedUnit:GetUnitName() == "npc_dota_hero_slark" then
        local function CalculateCurrentScore()
            return hero_duel.killCount
        end

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

        -- 更新击杀数和得分
        hero_duel.killCount = hero_duel.killCount + 1
        local currentScore = CalculateCurrentScore() -- 只计算击杀得分
        local data = {
            ["击杀数量"] = hero_duel.killCount,
            ["当前总分"] = currentScore
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)

        -- 检查是否击败了所有Slark
        if hero_duel.killCount >= #self.golemPool and not hero_duel.EndDuel then
            hero_duel.EndDuel = true
            local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS}
            self:CreateTrueSightWards(teams)
            -- 计算剩余时间并加入总分
            local elapsedTime = GameRules:GetGameTime() - self.startTime
            local remainingTime = math.max(0, self.limitTime - elapsedTime)
            local timeBonus = math.floor(remainingTime) -- 剩余的每秒1分
            local killScore = hero_duel.killCount
            local finalScore = killScore + timeBonus
            
            self:PlayVictoryEffects(self.leftTeamHero1)
            
            -- 记录结果
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功],最终得分:" .. finalScore
            )
            
            -- 更新前端显示
            data = {
                ["击杀数量"] = hero_duel.killCount,
                ["当前总分"] = finalScore
            }
            CustomGameEventManager:Send_ServerToAllClients("update_score", data)
        end
    end
end



function Main:StartSlarkAI(slark)
    if not slark or slark:IsNull() then
        return
    end
    hero_duel.slark_ai_attack = false
    -- 基础思考间隔时间
    local baseThinkInterval = 1
    
    -- 添加随机初始延迟，使AI错开行动
    local initialDelay = RandomFloat(0.0, 2.0)
    -- 给每个AI添加一点随机性的思考间隔
    local thinkVariation = RandomFloat(-0.02, 0.05)
    local thinkInterval = baseThinkInterval + thinkVariation
    

    -- 创建标记变量，记录是否曾经检测到过歌声效果
    local hasExperiencedSong = false
    
    Timers:CreateTimer(initialDelay, function()
        -- 检查游戏结束或单位无效
        if hero_duel.EndDuel then
            return nil
        end
        
        if not slark or slark:IsNull() or not slark:IsAlive() then
            return nil
        end

        -- 检查玩家英雄是否存在
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() and self.leftTeamHero1:IsAlive() then
            -- 检查是否当前有歌声效果
            local hasSongModifier = slark:HasModifier("modifier_naga_siren_song_of_the_siren")
            
            -- 如果当前有歌声效果，标记为已经体验过歌声
            if hasSongModifier then
                hasExperiencedSong = true
                slark:RemoveModifierByName("modifier_slark_shadow_dance_persistent")
                slark:RemoveModifierByName("modifier_slark_fade_transition")

            end
            
            -- 如果已经体验过歌声效果（不管当前是否还有），就改变行为
            if hasExperiencedSong then
                -- 检查英雄是否为拉比克
                if self.leftTeamHero1:GetUnitName() == "npc_dota_hero_rubick" then
                    -- 如果是拉比克，移除缴械效果并直接攻击
                    slark:RemoveModifierByName("modifier_disarmed")
                    slark:AddNewModifier(slark, nil, "modifier_debuff_immune", {})
                    --颜色变红
                    if not slark:HasModifier("modifier_life_stealer_rage") then
                        local rage_ability = slark:FindAbilityByName("life_stealer_rage")
                        if rage_ability then
                            rage_ability:OnSpellStart()
                        end
                    end

                    if not hero_duel.slark_ai_attack then   
                        hero_duel.slark_ai_attack = true
                        CustomGameEventManager:Send_ServerToAllClients("ShowHorrorMessage", {})  
                    end

                    local order = {
                        UnitIndex = slark:entindex(),
                        OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                        TargetIndex = self.leftTeamHero1:entindex(),
                        Position = self.leftTeamHero1:GetAbsOrigin()
                    }
                    ExecuteOrderFromTable(order)
                    return thinkInterval
                else
                    -- 不是拉比克，继续围着英雄转圈
                    local heroPos = self.leftTeamHero1:GetAbsOrigin()
                    
                    -- 初始化或更新当前角度（保存在slark单位上）
                    if not slark.currentCircleAngle then
                        slark.currentCircleAngle = 0
                    else
                        -- 每次增加一小段角度（顺时针）
                        slark.currentCircleAngle = slark.currentCircleAngle - math.pi/18  -- 每次减少10度，负值表示顺时针
                    end
                    
                    -- 使用固定半径250
                    local radius = 500
                    local targetPos = heroPos + Vector(
                        math.cos(slark.currentCircleAngle) * radius,
                        math.sin(slark.currentCircleAngle) * radius,
                        0
                    )
                    
                    slark:MoveToPosition(targetPos)
                    return 0.05  -- 使用固定间隔，确保平滑移动
                end
            end
        end
        
        -- 检查控制状态
        local is_controlled = slark:IsStunned() or 
        slark:IsHexed() or 
        slark:IsTaunted() or 
        slark:IsFeared() or
        slark:IsNightmared() or
        slark:IsOutOfGame() or
        slark:IsCommandRestricted()


        if is_controlled then

            return thinkInterval
        end

        local aliveSlarkCount = 0
        for _, s in pairs(self.golemPool or {}) do
            if s and not s:IsNull() and s:IsAlive() then
                aliveSlarkCount = aliveSlarkCount + 1
            end
        end
        if aliveSlarkCount <= 10 and self.leftTeamHero1 and not self.leftTeamHero1:IsNull() and self.leftTeamHero1:IsAlive() then
            if not hero_duel.slark_ai_attack then
                hero_duel.slark_ai_attack = true
                CustomGameEventManager:Send_ServerToAllClients("ShowHorrorMessage", {})
            end
            
            slark:RemoveModifierByName("modifier_disarmed")
            slark:RemoveModifierByName("modifier_slark_shadow_dance_persistent")
            slark:RemoveModifierByName("modifier_slark_fade_transition")
            
            -- 激活狂暴效果
            if not slark:HasModifier("modifier_life_stealer_rage") then
                local rage_ability = slark:FindAbilityByName("life_stealer_rage")
                if rage_ability then
                    rage_ability:OnSpellStart()
                end
            end
            
            -- 添加免疫效果
            slark:AddNewModifier(slark, nil, "modifier_debuff_immune", {})
            
            -- 命令攻击玩家英雄
            local order = {
                UnitIndex = slark:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                TargetIndex = self.leftTeamHero1:entindex(),
                Position = self.leftTeamHero1:GetAbsOrigin()
            }
            ExecuteOrderFromTable(order)
            return thinkInterval
        end

        -- 如果没有体验过歌声效果，则执行正常的AI行为
        
        -- 获取技能引用
        local pounceAbility = slark:FindAbilityByName("slark_pounce")
        local shadowDanceAbility = slark:FindAbilityByName("slark_shadow_dance")
        
        -- 检查Essence Shift叠加
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() and self.leftTeamHero1:IsAlive() then
            local debuffModifiers = self.leftTeamHero1:FindAllModifiersByName("modifier_slark_essence_shift_debuff")
            local debuffCount = #debuffModifiers
            
            if debuffCount >= 150 then
                --颜色变红
                if not hero_duel.slark_ai_attack then   
                    hero_duel.slark_ai_attack = true
                    CustomGameEventManager:Send_ServerToAllClients("ShowHorrorMessage", {})  
                end

                if not slark:HasModifier("modifier_life_stealer_rage") then
                    local rage_ability = slark:FindAbilityByName("life_stealer_rage")
                    if rage_ability then
                        rage_ability:OnSpellStart()
                    end
                end
                slark:RemoveModifierByName("modifier_disarmed")
                local order = {
                    UnitIndex = slark:entindex(),
                    OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                    TargetIndex = self.leftTeamHero1:entindex(),
                    Position = self.leftTeamHero1:GetAbsOrigin()
                }
                ExecuteOrderFromTable(order)
                return thinkInterval
            end
        end
        
        -- 检查跳跃技能
        if pounceAbility and pounceAbility:IsFullyCastable() and not slark:IsSilenced() and not CommonAI:IsUnableToCastAbility(slark, pounceAbility) then
            if RandomInt(1, 100) <= 80 then
                slark:CastAbilityNoTarget(pounceAbility, 0)
                return thinkInterval
            end
        end
        
        -- 随机移动
        local currentPos = slark:GetAbsOrigin()
        local center = Main.waterFall_Center
        local distance = (currentPos - center):Length2D()  -- 计算到中心的2D距离
        
        -- 计算朝中心移动的概率
        local probability = 0
        if distance > 800 then
            -- 使用clamp确保在800-1200范围内插值
            local t = (math.min(distance, 1200) - 800) / 400
            probability = t * 0.5  -- 最高50%概率
        end
        
        local targetPos
        if RandomFloat(0, 1) <= probability then
            -- 朝中心方向移动
            local toCenter = center - currentPos
            local direction = toCenter:Normalized()
            local moveDistance = RandomInt(200, 300)
            
            -- 确保不会移动到中心另一侧（可选）
            local maxMove = toCenter:Length2D()
            moveDistance = math.min(moveDistance, maxMove)
            
            targetPos = currentPos + direction * moveDistance
        else
            -- 原始随机移动
            local randomOffset = Vector(
                RandomInt(-300, 300),
                RandomInt(-300, 300),
                0
            )
            targetPos = currentPos + randomOffset
        end
        
        slark:MoveToPosition(targetPos)
        
        return thinkInterval + RandomFloat(-0.02, 0.02)
    end)
end