function Main:Init_Skill_Probability_100(event, playerID)
    -- 技能修改器

    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    self.HERO_CONFIG = {
        ALL = {
            function(hero)

                hero:AddNewModifier(hero, nil, "modifier_rooted", {duration = 5})
                HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                --如果英雄是npc_dota_hero_tidehunter，给他modifier
                if hero:GetUnitName() == "npc_dota_hero_tidehunter" then
                    hero:AddNewModifier(hero, nil, "modifier_attack_auto_cast_ability", {ability_index = 2})
                    hero:RemoveAbility("special_bonus_unique_tidehunter_8")
                end

                --如果英雄是npc_dota_hero_doom_bringer，给他modifier
                if hero:GetUnitName() == "npc_dota_hero_doom_bringer" then
                    hero:AddNewModifier(hero, nil, "modifier_reset_passive_ability_cooldown", {})
                end

                --如果英雄是npc_dota_hero_naga_siren，给他modifier
                if hero:GetUnitName() == "npc_dota_hero_naga_siren" then
                    hero:RemoveAbility("naga_siren_eelskin")

                    hero:AddAbility("naga_siren_eelskin")

                end
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
        }
        ,
        BATTLEFIELD = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_small", {})
                
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                if hero:GetUnitName() == "npc_dota_hero_naga_siren" then
                    hero:RemoveAbility("naga_siren_eelskin")

                    hero:AddAbility("naga_siren_eelskin")

                end
            end,
        }
    }
    local ability_modifiers = {
        npc_dota_hero_pangolier = {
            pangolier_fortune_favors_the_bold =
            {
                AbilityValues = {
                    chance_reduce = {
                        value = -100
                    }
                }
            },

            pangolier_lucky_shot =
            {
                AbilityValues = {
                    chance_pct = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_hoodwink = {
            hoodwink_mistwoods_wayfarer = {
                AbilityValues = {
                    redirect_chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_dark_seer = {
            dark_seer_normal_punch = {
                AbilityValues = {
                    AbilityCooldown = {
                        value = 0
                    }
                }
            },
        },

        npc_dota_hero_legion_commander = {
            legion_commander_moment_of_courage = {
                AbilityValues = {
                    trigger_chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_troll_warlord = {
            troll_warlord_berserkers_rage  = {
                AbilityValues = {
                    ensnare_chance = 100,
                    maim_chance = 100
                }
            },
            troll_warlord_whirling_axes_melee = {
                AbilityValues = {
                    blind_pct = 100
                }
            },
        },

        npc_dota_hero_skeleton_king = {
            skeleton_king_mortal_strike = {
                AbilityValues = {
                    AbilityCooldown = 0 ,
                }
            },
            skeleton_king_spectral_blade = {
                AbilityValues = {
                    curse_cooldown = {
                        value = 0,
                    },
                    curse_delay = {
                        value = 0,
                    },
                }
            },
        },
        npc_dota_hero_tusk = {
            special_bonus_unique_tusk_4 = {
                AbilityValues = {
                    value = {
                        value = 100
                    }
                }
            }
        },
        npc_dota_hero_axe = {
            axe_counter_helix = {
                AbilityValues = {
                    AbilityCooldown = {
                        value = 0
                    },
                    trigger_attacks = {
                        value = 0
                    },
                }
            },
        },
        npc_dota_hero_slardar = {
            slardar_bash = {
                AbilityValues = {
                    attack_count = {
                        value = 0
                    }
                }
            },
        },
        npc_dota_hero_kunkka = {
            kunkka_tidebringer = {
                AbilityValues = {
                    AbilityCooldown = 0,
                }
            },
        },
        npc_dota_hero_doom_bringer = {
            doom_bringer_infernal_blade = {
                AbilityValues = {
                    AbilityCooldown = 0,
                }
            },
            berserker_troll_break = {
                AbilityValues = {
                    AbilityCooldown = 0,
                }
            },
            spawnlord_master_freeze = {
                AbilityValues = {
                    AbilityCooldown = 0,
                }
            },

            big_thunder_lizard_wardrums_aura =
            {
                AbilityValues = {
                    accuracy =  {
                        value = 100,
                    }
                }
            },
            alpha_wolf_critical_strike={
                AbilityValues = {
                    crit_chance = {
                        value = 100,
                    }
                }
            },
            
        },
        npc_dota_hero_chaos_knight = {
            chaos_knight_reins_of_chaos = {
                AbilityValues = {
                    bonus_illusion_chance = {
                        value = 100
                    }
                }
            },
            chaos_knight_chaos_strike = {
                AbilityValues = {
                    chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_dawnbreaker = {
            dawnbreaker_luminosity = {
                AbilityValues = {
                    attack_count = {
                        value = 0
                    }
                }
            },
        },
        npc_dota_hero_spirit_breaker = {
            spirit_breaker_greater_bash = {
                AbilityValues = {
                    AbilityCooldown ={
                        value = 0
                    },
                    chance_pct = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_ogre_magi = {
            ogre_magi_multicast = {
                AbilityValues = {
                    multicast_4_times = {
                        value = 100
                    }
                }
            },
            special_bonus_unique_ogre_magi_3 = {
                AbilityValues = {
                    value = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_juggernaut = {
            juggernaut_blade_dance = {
                AbilityValues = {
                    blade_dance_crit_chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_kez = {
            kez_shodo_sai = {
                AbilityValues = {
                    sai_proc_vuln_chance = {
                        value = 100
                    }
                }
            },
            kez_falcon_rush = {
                AbilityValues = {
                    buff_evasion_pct = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_drow_ranger = {
            drow_ranger_marksmanship = {
                AbilityValues = {
                    chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_naga_siren = {
            naga_siren_rip_tide = {
                AbilityValues = {
                    hits = {
                        value = 0
                    }
                }
            },
            naga_siren_eelskin = {
                AbilityValues = {
                    evasion_per_naga = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_sniper = {
            sniper_headshot = {
                AbilityValues = {
                    proc_chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_broodmother = {
            broodmother_incapacitating_bite = {
                AbilityValues = {
                    miss_chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_faceless_void = {
            special_bonus_unique_faceless_void_4 = {
                AbilityValues = {
                    dodge_chance_pct = {
                        value = 100
                    }
                }
            },
            faceless_void_time_lock = {
                AbilityValues = {
                    chance_pct = {
                        value = 100
                    }
                }
            },

        },
        npc_dota_hero_monkey_king = {
            monkey_king_jingu_mastery = {
                AbilityValues = {
                    required_hits = {
                        value = 0
                    }
                }
            },
        },

        npc_dota_hero_shadow_shaman = {
            shadow_shaman_voodoo_hands = {
                AbilityValues = {
                    AbilityCooldown = {
                        value = 0
                    }
                }
            },
        },
        npc_dota_hero_disruptor = { 
            disruptor_electromagnetic_repulsion = {
                AbilityValues = {
                    damage_threshold = 1,
                    AbilityCooldown = {
                        value = 0
                    }
                }
            },
        },
        npc_dota_hero_jakiro = {
            jakiro_liquid_fire = {
                AbilityValues = {
                    AbilityCooldown = {
                        value = 0
                    }
                }
            },
            jakiro_liquid_ice = {
                AbilityValues = {
                    AbilityCooldown = {
                        value = 0
                    }
                }
            },  
        },
        npc_dota_hero_obsidian_destroyer = {
            obsidian_destroyer_equilibrium = {
                AbilityValues = {
                    proc_chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_snapfire = {
            snapfire_buckshot = {
                AbilityValues = {
                    miss_chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_phantom_assassin = {
            phantom_assassin_immaterial = {
                AbilityValues = {
                    evasion_base = {
                        value = 100
                    }
                }
            },
            phantom_assassin_coup_de_grace = {
                AbilityValues = {
                    crit_chance = {
                        value = 100
                    },
                    dagger_crit_chance = {
                        value = 100
                    },
                    attacks_to_proc = {
                        value = 0
                    },
                    attacks_to_proc_creeps = {
                        value = 0
                    },
                }
            },
        },
        npc_dota_hero_weaver = {
            weaver_geminate_attack = {
                AbilityValues = {
                    AbilityCooldown = {
                        value = 0
                    }
                }
            },
        },
        npc_dota_hero_gyrocopter = {
            gyrocopter_flak_cannon = {
                AbilityValues = {
                    sidegunner_fire_rate = {
                        value = 0
                    }
                }
            },
        },
        npc_dota_hero_muerta = {
            muerta_gunslinger = {
                AbilityValues = {
                    double_shot_chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_enigma = {
            enigma_splitting_image = {
                AbilityValues = {
                    damage_threshold = 0 ,
                    eidolon_spawns = 999,
                }
            },
        },
        npc_dota_hero_phantom_lancer = {
            phantom_lancer_phantom_edge = {
                AbilityValues = {
                    min_distance = {
                        value = 0
                    },
                    AbilityCooldown = {
                        value = 0
                    }
                }
            },
            phantom_lancer_juxtapose = {
                AbilityValues = {
                    proc_chance_pct = {
                        value = 100
                    },
                    illusion_proc_chance_pct = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_treant = {
            treant_natures_guise = {
                AbilityValues = {
                    shard_cooldown ={
                        value = 0
                    },
                    cooldown_time = {
                        value = 0
                    }
                }
            },
        },
        npc_dota_hero_brewmaster = {
            brewmaster_drunken_brawler = {
                AbilityValues = {
                    dodge_chance = {
                        value = 100
                    },
                    crit_chance = {
                        value = 100
                    }
                }
            },
        },
        npc_dota_hero_omniknight = {
            omniknight_hammer_of_purity = {
                AbilityValues = {
                    AbilityCooldown = {
                        value = 0
                    }
                }

            },
        },
        npc_dota_hero_razor = {
            razor_storm_surge = {
                AbilityValues = {
                    strike_pct_chance = {
                        value = 100
                    },
                    strike_internal_cd = {
                        value = 0
                    }
                }
            },
        },

    }
    self:UpdateAbilityModifiers(ability_modifiers)

    -- 从 event 中获取新的数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local opponentHeroId = event.opponentHeroId or -1
    local opponentFacetId = event.opponentFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local opponentAIEnabled = (event.opponentAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local opponentEquipment = event.opponentEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)
    local opponentOverallStrategy = self:getDefaultIfEmpty(event.opponentOverallStrategies)
    local opponentHeroStrategy = self:getDefaultIfEmpty(event.opponentHeroStrategies)
    local selfSkillThresholds = event.selfSkillThresholds or {}
    local opponentSkillThresholds = event.opponentSkillThresholds or {}

    -- 获取玩家和对手的英雄名称及中文名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)
    local opponentHeroName, opponentChineseName = self:GetHeroNames(opponentHeroId)

    -- 设置AI英雄信息
    self.AIheroName = opponentHeroName
    self.FacetId = opponentFacetId
    local timerId = self.currentTimer
    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 0, false)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 100        -- 限定时间为准备时间结束后的一分钟


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
        ["对手英雄"] = opponentChineseName,
        ["剩余时间"] = self.limitTime,
    }
    local order = {"挑战英雄", "对手英雄", "剩余时间"}
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
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1",0.01,selfSkillThresholds)
                return nil
            end)
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
                CreateAIForHero(self.rightTeamHero1, opponentOverallStrategy, opponentHeroStrategy,"rightTeamHero1",0.01,opponentSkillThresholds)
                return nil
            end)
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
        self:PrepareHeroForDuel(
            self.leftTeamHero1,                     -- 英雄单位
            self.smallDuelAreaLeft,      -- 左侧决斗区域坐标
            self.duration - 5,                      -- 限制效果持续20秒
            Vector(1, 0, 0)          -- 朝向右侧
        )

        self:PrepareHeroForDuel(
            self.rightTeamHero1,        
            self.smallDuelAreaRight,     
            self.duration - 5,           
            Vector(-1, 0, 0)         
        )

    end)

    -- 发送摄像机位置给前端
    self:SendCameraPositionToJS(Main.smallDuelArea, 1)


    -- 监视战斗状态并开始计时
    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        Timers:CreateTimer(0.01, function()
            self:MonitorUnitsStatus()
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
    end)

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
        self:MonitorUnitsStatus()
        self:StartAbilitiesMonitor(self.rightTeamHero1,true)
        self:StartAbilitiesMonitor(self.leftTeamHero1,true)
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    -- 限定时间结束后的操作
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true

        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})

        self:DisableHeroWithModifiers(self.leftTeamHero1, self.endduration)
        self:DisableHeroWithModifiers(self.rightTeamHero1, self.endduration)
    end)
end


function Main:OnUnitKilled_Skill_Probability_100(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)

    if hero_duel.EndDuel or not killedUnit:IsRealHero() then
        print("Unit killed: " .. killedUnit:GetUnitName() .. " (not processed)")
        return
    end

    self:ProcessHeroDeath(killedUnit)
end


function Main:OnNPCSpawned_Skill_Probability_100(spawnedUnit, event)
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end

function Main:OnAbilityUsed_Skill_Probability_100(event)
    print("技能释放事件")
    local caster = EntIndexToHScript(event.caster_entindex)
    --详细打印event的所有信息，event是表
    for k, v in pairs(event) do
        print(k, v)
    end
    


    local target = caster:GetCursorCastTarget()
    if target then
        print("目标实体:", target:GetName(), "实体索引:", target:GetEntityIndex())
    end

    --如果英雄释放的技能是chaos_knight_reality_rift，让英雄对目标施加持续三秒的缴械、沉默和破坏效果
    if event.abilityname == "chaos_knight_reality_rift" then
        target:AddNewModifier(caster, nil, "modifier_break", {duration = 3})
        target:AddNewModifier(caster, nil, "modifier_silence", {duration = 3})
        target:AddNewModifier(caster, nil, "modifier_disarmed", {duration = 3})
    end
    

end


