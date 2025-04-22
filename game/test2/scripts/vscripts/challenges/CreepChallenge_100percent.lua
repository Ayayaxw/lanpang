function Main:Init_CreepChallenge_100percent(event, playerID)
    -- 基础参数初始化
    self.currentMatchID = self:GenerateUniqueID()    
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1 
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    -- 定义时间参数
    self.duration = 10         
    self.endduration = 10      
    self.limitTime = 100       
    hero_duel.EndDuel = false  
    hero_duel.killCount = 0    
    
    -- 设置摄像机位置
    self:SendCameraPositionToJS(Main.largeSpawnCenter, 1)

    -- local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    -- self:CreateTrueSightWards(teams)
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})


                if hero:GetUnitName() == "npc_dota_hero_tidehunter" then
                    hero:AddNewModifier(hero, nil, "modifier_attack_auto_cast_ability", {ability_index = 2})
                    hero:RemoveAbility("special_bonus_unique_tidehunter_8")
                end
                -- hero:AddNewModifier(hero, nil, "modifier_reduced_ability_cost", {})
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
                if hero:GetUnitName() ~= "ward" then
                    Timers:CreateTimer(0.1, function()
                        hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                    end)
                end
            end,
        }
    }

    -- 获取玩家数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)

    -- 获取英雄名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)

    self:StandardizeAbilityPercentages()
    local ability_modifiers = {

        npc_dota_hero_omniknight = {
            omniknight_purification = {
                AbilityValues = {
                    recast_effectiveness_pct = {
                        special_bonus_shard = 100
                    }
                }
            },
            omniknight_degen_aura = {
                AbilityValues = {
                    bonus_damage_per_stack = {
                        special_bonus_facet_omniknight_omnipresent = 100
                    }
                }
            }
        },

        npc_dota_hero_necrolyte = {
            necrolyte_heartstopper_aura = {
                AbilityValues = {
                    aura_damage = {
                        value = 100,
                        special_bonus_unique_necrophos_2 = "+100"
                    }
                }
            }
        },

        npc_dota_hero_drow_ranger = {
            drow_ranger_trueshot = {
                AbilityValues = {
                    trueshot_agi_bonus_base = 100,
                    trueshot_agi_bonus_per_level = 100
                }
            },
            drow_ranger_vantage_point = {
                AbilityValues = {
                    damage_bonus =  100
                }
            }
        },
        npc_dota_hero_magnataur = {
            magnataur_empower = {
                AbilityValues = {
                    bonus_damage_pct=
                    {
                        value = 100,
                        special_bonus_unique_magnus_2 = 100
                    },
                    cleave_damage_pct=
                    {
                        value = 100,
                        special_bonus_unique_magnus_2 = 100
                    },


                    self_multiplier_bonus_max_stacks = {
                        value = 100
                    },
                    self_multiplier_bonus_per_stack = {
                        value = 100
                    }
                }
            }
        },

        



        -- npc_dota_hero_shredder = {
        --     shredder_whirling_death = {
        --         AbilityValues = {
        --             stat_loss_universal =
        --             {
        --                 value = 100,
        --                 special_bonus_unique_timbersaw_5 = 100
        --             },
        --             stat_loss_pct=
        --             {
        --                 value = 100,
        --                 special_bonus_unique_timbersaw_5 = 100
        --             }
        --         }
        --     }
        -- }


    }
    self:UpdateAbilityModifiers(ability_modifiers)
    -- 播报初始化
    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[技能百分百大战熊猫]"
    )

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择英雄]",
        {localize = true, text = heroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(heroName, selfFacetId)}
    )

    -- 前端显示初始化
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["击杀数量"] = "0",

        ["火猫护甲"] = "0",
        ["蓝猫魔抗"] = "0",
        ["土猫血量"] = "0",
        ["剩余时间"] = self.limitTime,
    }
    local order = {"挑战英雄", "击杀数量", "火猫护甲", "蓝猫魔抗", "土猫血量","剩余时间"}
    hero_duel.creepCount = 0
    hero_duel.survivalTime = 0
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, Main.largeSpawnCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        
        self.leftTeamHero1 = playerHero

        self:StartTextMonitor(self.leftTeamHero1, "击杀数:0", 20, "#FFFFFF")
        self.currentArenaHeroes[1] = playerHero
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

                
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1")
                return nil
            end)
        end
        -- 给予90%减CD
        playerHero:AddNewModifier(playerHero, nil, "modifier_cooldown_reduction_90", {})
    end)

    -- 赛前准备时间
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = {self.leftTeamHero1}
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
    end)


    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)
    

    Timers:CreateTimer(self.duration-5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        FindClearSpaceForUnit(self.leftTeamHero1, Main.largeSpawnCenter, true)
        self:DisableHeroWithModifiers(self.leftTeamHero1, 5)
        self:ResetUnit(self.leftTeamHero1)
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


    -- 开始信号
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 正式开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.startTime = GameRules:GetGameTime()
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})

        -- 开始生成超级兵定时器
        self:StartSpawning_CreepChallenge_100percent(timerId)



        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    -- 时间结束判定
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true
    
        if hero_duel.killCount >= 100 then
            self:PlayVictoryEffects(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功]",
                "最终得分:" .. hero_duel.killCount
            )
        else
            self:PlayDefeatAnimation(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战失败]",
                "最终得分:" .. hero_duel.killCount
            )
        end
    end)
end

-- 精灵单位生成函数
function Main:StartSpawning_CreepChallenge_100percent(timerId)
    local spiritUnits = {"custom_ember_spirit", "custom_storm_spirit", "custom_earth_spirit"}
    
    -- 初始化各类型精灵的属性增强计数器
    hero_duel.emberSpiritLevel = 0  -- 火猫等级
    hero_duel.stormSpiritLevel = 0  -- 蓝猫等级
    hero_duel.earthSpiritLevel = 0  -- 土猫等级
    
    -- 初始生成若干个精灵单位
    for i = 1, 9 do
        -- 为每个位置轮流生成三种精灵
        local unitIndex = (i % 3) + 1
        local unitName = spiritUnits[unitIndex]
        
        local angle = RandomFloat(0, 360)
        local radius = 300
        local spawnPos = Vector(
            Main.largeSpawnCenter.x + radius * math.cos(angle * math.pi / 180),
            Main.largeSpawnCenter.y + radius * math.sin(angle * math.pi / 180),
            Main.largeSpawnCenter.z
        )
        
        self:SpawnSpirit(unitName, spawnPos, timerId)
    end
end

-- 生成单个精灵单位的函数
function Main:SpawnSpirit(unitName, spawnPos, timerId)
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
    
    -- 检查场上单位数量上限
    if hero_duel.creepCount >= 100 then
        return
    end
    
    local unit = CreateUnitByName(
        unitName,
        spawnPos,
        true,
        nil,
        nil,
        DOTA_TEAM_BADGUYS
    )
    
    -- 根据单位类型和当前等级增强属性
    local attributeValue = 0
    
    if unitName == "custom_ember_spirit" then
        -- 火猫增强敏捷
        attributeValue = 10 * hero_duel.emberSpiritLevel
        unit:AddNewModifier(unit, nil, "modifier_attribute_boost", { value = attributeValue, attribute_type = "agility" })
        local armor = unit:GetPhysicalArmorValue(false)
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["火猫护甲"] = tostring(math.floor(armor))
        })
        
        -- 添加敏捷属性文本显示
        self:StartTextMonitor(unit, "敏捷：" .. tostring(attributeValue+100), 18, "minion_agility")
    elseif unitName == "custom_storm_spirit" then
        -- 蓝猫增强智力
        attributeValue = 10 * hero_duel.stormSpiritLevel
        unit:AddNewModifier(unit, nil, "modifier_attribute_boost", { value = attributeValue, attribute_type = "intelligence" })
        local magicResist = unit:Script_GetMagicalArmorValue(false,nil) * 100
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["蓝猫魔抗"] = tostring(math.floor(magicResist)) .. "%"
        })
        
        -- 添加智力属性文本显示
        self:StartTextMonitor(unit, "智力：" .. tostring(attributeValue+100), 18, "minion_intelligence")
    elseif unitName == "custom_earth_spirit" then
        -- 土猫增强力量
        attributeValue = 10 * hero_duel.earthSpiritLevel
        unit:AddNewModifier(unit, nil, "modifier_attribute_boost", { value = attributeValue, attribute_type = "strength" })
        local health = unit:GetMaxHealth()
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["土猫血量"] = tostring(health)
        })
        
        -- 添加力量属性文本显示
        self:StartTextMonitor(unit, "力量：" .. tostring(attributeValue+100), 18, "minion_strength")
    end
    
    unit:AddNewModifier(unit, nil, "modifier_phased", {})
    
    local direction = (Main.largeSpawnCenter - spawnPos):Normalized()
    unit:SetForwardVector(direction)
    
    hero_duel.creepCount = hero_duel.creepCount + 1
    
    -- 更新前端显示场上数量
    CustomGameEventManager:Send_ServerToAllClients("update_score", {
        ["场上数量"] = tostring(hero_duel.creepCount)
    })
end

-- 单位死亡判定
function Main:OnUnitKilled_CreepChallenge_100percent(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    if not killedUnit or killedUnit:IsNull() or hero_duel.EndDuel then return end

    -- 玩家死亡判定
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        hero_duel.EndDuel = true  -- 在发送消息前先设置结束标志
        
        if hero_duel.killCount >= 1000 then
            self:PlayVictoryEffects(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功]",
                "最终得分:" .. hero_duel.killCount
            )
        else
            self:PlayDefeatAnimation(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战失败]",
                "最终得分:" .. hero_duel.killCount
            )
        end
        
        return
    end

    -- 精灵单位死亡判定
    local unitName = killedUnit:GetUnitName()
    if unitName == "custom_ember_spirit" or unitName == "custom_storm_spirit" or unitName == "custom_earth_spirit" then
        -- 再次检查游戏是否已结束（以防在处理过程中游戏结束）
        if hero_duel.EndDuel then return end
        
        local killer = EntIndexToHScript(args.entindex_attacker)
        local particle = ParticleManager:CreateParticle("particles/generic_gameplay/lasthit_coins_local.vpcf", PATTACH_ABSORIGIN, killedUnit)
        ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)
        EmitSoundOn("General.Coins", killer)

        hero_duel.killCount = hero_duel.killCount + 1
        hero_duel.creepCount = hero_duel.creepCount - 1
        self:StartTextMonitor(self.leftTeamHero1, "击杀数:" .. hero_duel.killCount, 20, "#FFFFFF")

        -- 更新前端显示
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["击杀数量"] = tostring(hero_duel.killCount),
            ["场上数量"] = tostring(hero_duel.creepCount)
        })
        
        -- 增加对应精灵类型的等级
        if unitName == "custom_ember_spirit" then
            hero_duel.emberSpiritLevel = hero_duel.emberSpiritLevel + 1
        elseif unitName == "custom_storm_spirit" then
            hero_duel.stormSpiritLevel = hero_duel.stormSpiritLevel + 1
        elseif unitName == "custom_earth_spirit" then
            hero_duel.earthSpiritLevel = hero_duel.earthSpiritLevel + 1
        end
        
        -- 2秒后移除尸体
        Timers:CreateTimer(2, function()
            if not killedUnit:IsNull() then
                killedUnit:RemoveSelf()
            end
        end)
        
        -- 立即生成一个新的同类型精灵
        Timers:CreateTimer(0.2, function()
            local angle = RandomFloat(0, 360)
            local radius = 800
            local spawnPos = Vector(
                Main.largeSpawnCenter.x + radius * math.cos(angle * math.pi / 180),
                Main.largeSpawnCenter.y + radius * math.sin(angle * math.pi / 180),
                Main.largeSpawnCenter.z
            )
            
            self:SpawnSpirit(unitName, spawnPos, self.currentTimer)
        end)
    end
end