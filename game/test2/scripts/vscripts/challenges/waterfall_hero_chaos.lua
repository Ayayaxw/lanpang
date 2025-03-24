function Main:Init_waterfall_hero_chaos(event, playerID)
    -- 初始化全局变量
    self.showTeamPanel = true  
    self.isTestMode = false
    self.heroesPerTeam = 3  -- 每个队伍初始传送的英雄数量，作为独立参数
    self.preCreatePerTeam = 3 -- 每个队伍初始创建的英雄数量，作为独立参数
    self.currentDeployIndex = 1  -- 当前部署的英雄索引


    self.ARENA_CENTER = Main.waterFall_Center
    self.SPAWN_DISTANCE = 500

    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS,DOTA_TEAM_CUSTOM_1,DOTA_TEAM_CUSTOM_2,DOTA_TEAM_CUSTOM_3,DOTA_TEAM_CUSTOM_4} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    self:SendCameraPositionToJS(self.ARENA_CENTER, 1)


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

    -- 定义不同的队伍类型配置
    local TEAM_CONFIGS = {
        ATTRIBUTE = {
            [1] = {type = "1", name = "力量"},
            [2] = {type = "2", name = "敏捷"},
            [4] = {type = "4", name = "智力"},
            [8] = {type = "8", name = "全才"}
        },
        
        TOURNAMENT = {
            [1] = {type = "1", name = "力量"},
            [2] = {type = "2", name = "敏捷"}
        }
        -- 可以在这里添加更多的队伍配置
    }

    -- 设置当前使用的队伍配置类型
    self.teamConfig = "TOURNAMENT"  -- 可以是 "ATTRIBUTE" 或 "TOURNAMENT" 或其他配置
    
    -- 设置实际使用的队伍类型
    self.teamTypes = TEAM_CONFIGS[self.teamConfig]

    self.heroSequence = {}

    -- 队伍对应关系
    local teamMapping = {
        [1] = DOTA_TEAM_BADGUYS,    -- 1 = 红色队伍
        [2] = DOTA_TEAM_GOODGUYS,   -- 2 = 绿色队伍
        [4] = DOTA_TEAM_CUSTOM_1,   -- 4 = 蓝色队伍
        [8] = DOTA_TEAM_CUSTOM_2    -- 8 = 紫色队伍
    }
    
    -- 根据 teamTypes 创建对应的 heroSequence
    for typeNum, typeInfo in pairs(self.teamTypes) do
        self.heroSequence[typeNum] = {
            sequence = {},
            currentIndex = 1,
            totalCount = 0,
            teamStats = {
                kills = 0,
                damage = 0,
                deaths = 0
            },
            team = teamMapping[typeNum]
        }
    end

    self.heroFacets = {
        npc_dota_hero_faceless_void = 3,  -- 虚空假面
        npc_dota_hero_life_stealer = 4,   -- 噬魂鬼
        --帕吉3
        npc_dota_hero_pudge = 3,
        --斯拉达2
        npc_dota_hero_slardar = 2,
        npc_dota_hero_night_stalker = 3,
        npc_dota_hero_chaos_knight = 4,
        npc_dota_hero_lycan = 2,
        npc_dota_hero_primal_beast = 3,
        --炼金术师2
        npc_dota_hero_alchemist = 2,
        npc_dota_hero_sven = 2,
        npc_dota_hero_earthshaker = 2,
        --修补匠2
        npc_dota_hero_tinker = 2,
        --哈斯卡3
        npc_dota_hero_huskar = 3,
        --死亡先知2
        npc_dota_hero_death_prophet = 2,
        npc_dota_hero_sand_king = 2,
        npc_dota_hero_winter_wyvern = 4,
        npc_dota_hero_leshrac = 2,
        npc_dota_hero_phantom_assassin = 2,
        npc_dota_hero_sniper = 1,
        npc_dota_hero_lion = 2,
        npc_dota_hero_lone_druid = 3,
        npc_dota_hero_mirana = 3,
        npc_dota_hero_marci = 3,

        npc_dota_hero_invoker = 5,
        npc_dota_hero_jakiro = 4,
        npc_dota_hero_dazzle = 2,
        npc_dota_hero_arc_warden = 3,
        npc_dota_hero_troll_warlord= 2,
        --马格纳斯3
        npc_dota_hero_magnataur= 3,
        --先知2
        npc_dota_hero_furion = 2,
        npc_dota_hero_enigma = 2,
        npc_dota_hero_windrunner = 5,
        -- 可以继续添加其他英雄的命石设置
    }

    self.testModeHeroes = {
        [1] = { -- 力量英雄
            {name = "npc_dota_hero_tusk", chinese = "巨牙海民"},
        },
        [2] = { -- 敏捷英雄
            {name = "npc_dota_hero_kez", chinese = "凯"},
        },
        [4] = {{
            name = "npc_dota_hero_muerta", chinese = "琼英碧灵"},
        }, -- 智力英雄
        [8] = {{name = "npc_dota_hero_vengefulspirit", chinese = "复仇之魂"}},  -- 全才英雄
    }
    self:InitializeWaterfallHeroSequence()--初始化英雄序列

    self:InitialPreWaterFallCreateHeroes()--预创建英雄
    Timers:CreateTimer(10, function()
        self:Initialize_waterfall_hero_chaos_UI()
        self:Initial_waterfall_hero_chaos_DeployHeroes()
        self:UpdateWaterFallTeamPanelData()
        self:Start_waterfall_hero_chaos_ScoreBoardMonitor()
        --self:CreateAllTeamHeroes()
        end)
end



function Main:SetupWaterFallCombatBuffs(hero)
    if not hero then
        print("错误：SetupWaterFallCombatBuffs收到了空的英雄实体")
        return false
    end
    
    print(string.format("正在设置英雄战斗状态: %s", hero:GetUnitName()))
    
    HeroMaxLevel(hero)
    hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
    hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
    hero:AddNewModifier(hero, nil, "modifier_auto_elevation_waterfall", {})

    if hero:GetUnitName() == "npc_dota_hero_naga_siren" then
        hero:RemoveAbility("naga_siren_eelskin")

        hero:AddAbility("naga_siren_eelskin")

    end
    if hero:GetUnitName() == "npc_dota_hero_tidehunter" then
        hero:AddNewModifier(hero, nil, "modifier_attack_auto_cast_ability", {ability_index = 2})
        hero:RemoveAbility("special_bonus_unique_tidehunter_8")
    end

    --如果英雄是npc_dota_hero_doom_bringer，给他modifier
    if hero:GetUnitName() == "npc_dota_hero_doom_bringer" then
        hero:AddNewModifier(hero, nil, "modifier_reset_passive_ability_cooldown", {})
    end
    -- 查找英雄type
    local heroName = hero:GetUnitName()
    local heroType = nil
    
    for _, heroData in pairs(heroes_precache) do
        if heroData.name == heroName then
            heroType = heroData.type
            break
        end
    end
    
    print(string.format("英雄战斗状态设置完成: %s", hero:GetUnitName()))
end

function Main:SetupInitialBuffs(hero)
    if not hero then
        print("错误：SetupInitialBuffs收到了空的英雄实体")
        return false
    end

    hero:AddNewModifier(hero, nil, "modifier_invulnerable", {})
    hero:AddNewModifier(hero, nil, "modifier_wearable", {})
end


function Main:Initial_waterfall_hero_chaos_DeployHeroes()
    local heroTypes = {}
    -- 从teamTypes中获取所有type
    for type, _ in pairs(self.teamTypes) do
        table.insert(heroTypes, type)
    end
    
    -- 为每个队伍传送指定数量的英雄
    for _, heroType in ipairs(heroTypes) do
        -- 检查该类型实际可用的英雄数量
        local availableHeroes = #(self.heroSequence[heroType].sequence)
        -- 使用实际可用数量和预期数量中的较小值
        local heroesToDeploy = math.min(availableHeroes, self.heroesPerTeam)
        
        -- 添加延迟以确保英雄按顺序部署
        for i = 1, heroesToDeploy do
            -- 创建闭包来保存当前的 i 值
            local currentIndex = i
            Timers:CreateTimer((i - 1) * 0.1, function()
                self.currentDeployIndex = currentIndex  -- 设置当前部署索引
                self:DeployWaterFallHero(heroType, true)
                
                if currentIndex < heroesToDeploy then
                    self.heroSequence[heroType].currentIndex = self.heroSequence[heroType].currentIndex + 1
                end
            end)
        end
    end
end

function Main:CleanupWaterFallHeroAndSummons(heroType, heroIndex, callback)
    if not self.heroSequence[heroType] then
        print(string.format("[Arena] 警告：未找到类型 %d 的队伍数据", heroType))
        if callback then callback() end
        return
    end

    local data = self.heroSequence[heroType]
    local heroData = data.sequence[heroIndex]

    if not heroData or not heroData.entity then
        print(string.format("[Arena] 警告：未找到类型 %d 索引 %d 的英雄数据", heroType, heroIndex))
        if callback then callback() end
        return
    end



    local hero = heroData.entity
    if hero:IsNull() then
        print("[Arena] 警告：英雄实体已失效")
        if callback then callback() end
        return
    end

    if heroData then
        heroData.isDead = true  -- 新增死亡标记
        heroData.entity = nil   -- 原有清理逻辑
    end

    Timers:CreateTimer(10, function()
        local targetPos = Vector(10000, 10000, 0)
        hero:SetAbsOrigin(targetPos)
        
        -- 移除AI
        hero:SetContextThink("AIThink", nil, 0)
        if AIs and AIs[hero] then
            AIs[hero] = nil
        end
        
        -- 使用FindUnitsInRadius搜索整个地图的单位
        local allUnits = FindUnitsInRadius(
            hero:GetTeamNumber(),
            self.ARENA_CENTER,
            nil,
            5000, -- 足够大的半径以覆盖整个地图
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            --所有单位
            DOTA_UNIT_TARGET_FLAG_NONE,
            
            FIND_ANY_ORDER,
            false
        )
        
        local cleanedCount = 0
        for _, unit in pairs(allUnits) do
            if unit and not unit:IsNull() and unit ~= hero and unit:IsAlive() then
                local owner = unit:GetRealOwner()
                if owner == hero then
                    unit:SetAbsOrigin(targetPos)
                    unit:ForceKill(false)
                    cleanedCount = cleanedCount + 1
                end
            end
        end
        
        print(string.format("[Arena] 已清理 %d 个属于英雄 %s 的召唤物", 
            cleanedCount, hero:GetUnitName()))
    end)

    Timers:CreateTimer(60, function()
        if not hero:IsNull() then
            print(string.format("正在准备清理: %s (EntityIndex: %d)", 
                hero:GetName(),           -- 英雄名字
                hero:GetEntityIndex()     -- 实体索引
            ))
            --如果单位死了，先复活再移除
            if not hero:IsAlive() then
                hero:RespawnHero(false, false)
            end
            --UTIL_Remove(hero)
        end
    end)

    if callback then callback() end
end


function Main:OnUnitKilled_waterfall_hero_chaos(killedUnit, args)
    if not killedUnit or not killedUnit:IsRealHero() then return end

    -- 获取被击杀英雄的类型和相关信息
    local killedHeroType = nil
    local heroToProcess = nil
    local killedHeroIndex = nil  -- 添加这个变量来存储被击杀英雄的索引
    
    for type, data in pairs(self.heroSequence) do
        if data and data.sequence then
            for i = 1, #data.sequence do  -- 遍历整个序列
                if data.sequence[i] and data.sequence[i].entity then
                    local currentHero = data.sequence[i].entity
                    if currentHero == killedUnit then
                        killedHeroType = type
                        heroToProcess = killedUnit
                        killedHeroIndex = i  -- 记录索引
                        break
                    end
                end
            end
            if killedHeroType then break end
        end
    end

    if not killedHeroType or not heroToProcess or not killedHeroIndex then
        print("[Arena] 警告：无法确定死亡英雄的类型、处理目标或索引")
        return
    end

    -- 在确认真实死亡前，先找到真正的击杀者和对应数据
    local killer = args.entindex_attacker and EntIndexToHScript(args.entindex_attacker)
    local realKiller = nil
    local killerType = nil
    local killerData = nil
    local killerTeamData = nil
    
    if killer and IsValidEntity(killer) then
        realKiller = killer:GetRealOwner()
        if realKiller then
            local killerTeam = realKiller:GetTeamNumber()
            local killerHeroName = realKiller:GetUnitName()

            for type, data in pairs(self.heroSequence) do
                if data and data.sequence then
                    -- 搜索整个序列
                    for i = 1, #data.sequence do
                        if data.sequence[i] and data.sequence[i].entity then
                            local hero = data.sequence[i].entity
                            if hero:GetTeamNumber() == killerTeam and
                               hero:GetUnitName() == killerHeroName then
                                killerType = type
                                killerData = data.sequence[i]
                                killerTeamData = data
                                break
                            end
                        end
                    end
                    if killerType then break end
                end
            end
        end
    end
        
        if self.heroSequence[killedHeroType] then
            local indexToClean = killedHeroIndex
            
            -- 记录死亡数
            if not self.heroSequence[killedHeroType].teamStats then
                self.heroSequence[killedHeroType].teamStats = {}
            end
            self.heroSequence[killedHeroType].teamStats.deaths = (self.heroSequence[killedHeroType].teamStats.deaths or 0) + 1
            
            self:StopAbilitiesMonitor(heroToProcess)
            
            -- 增加 currentIndex，为下一个英雄做准备
            local nextIndex = (self.heroSequence[killedHeroType].currentIndex or 1) + 1
            if nextIndex <= #self.heroSequence[killedHeroType].sequence then
                self.heroSequence[killedHeroType].currentIndex = nextIndex
                -- 部署新的英雄
                self:DeployWaterFallHero(killedHeroType, false)
            else
                print(string.format("[Arena] 警告：队伍 %d 已无可用英雄", killedHeroType))
            end
            
            -- 在更新完被击杀者状态后，再处理击杀者数据和胜利检查
            if realKiller and killerType and killerData and killerTeamData then
                --self:KamiBlessing(realKiller)
                local newHealth = realKiller:GetHealth() + realKiller:GetMaxHealth() / 3
                if newHealth > realKiller:GetMaxHealth() then
                    newHealth = realKiller:GetMaxHealth()
                end
                
                local newMana = realKiller:GetMana() + realKiller:GetMaxMana()  / 3
                if newMana > realKiller:GetMaxMana() then
                    newMana = realKiller:GetMaxMana()
                end
                
                realKiller:SetHealth(newHealth)
                realKiller:SetMana(newMana)
                

                local particle = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf", PATTACH_ABSORIGIN_FOLLOW, realKiller)
                ParticleManager:SetParticleControl(particle, 0, realKiller:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(particle)
                --重置所有技能冷却和充能
                -- for i = 0, realKiller:GetAbilityCount() - 1 do
                --     local ability = realKiller:GetAbilityByIndex(i)
                --     if ability then
                --         -- 降低技能总冷却的一半时间
                --         local currentCooldown = ability:GetCooldownTimeRemaining()
                --         if currentCooldown > 0 then
                --             local totalCooldown = ability:GetCooldown(ability:GetLevel())
                --             ability:EndCooldown()
                --             -- 当前剩余冷却时间减去总冷却的一半
                --             local newCooldown = math.max(0, currentCooldown - totalCooldown * 0.3)
                --             ability:StartCooldown(newCooldown)
                --         end
                        
                --         -- 充能点数回复一半
                --         local maxCharges = ability:GetMaxAbilityCharges(ability:GetLevel())
                --         if maxCharges > 0 then
                --             local currentCharges = ability:GetCurrentAbilityCharges()
                --             local chargesToRestore = math.floor((maxCharges - currentCharges) * 0.5)
                --             ability:SetCurrentAbilityCharges(currentCharges + chargesToRestore)
                --         end
                --     end
                -- end


                killerData.kills = (killerData.kills or 0) + 1
                
                if not killerTeamData.teamStats then
                    killerTeamData.teamStats = {}
                end
                killerTeamData.teamStats.kills = (killerTeamData.teamStats.kills or 0) + 1
                
                self:UpdateWaterFallTeamPanelData()
                self:SendKillFeedToClient(realKiller, heroToProcess)
                
                if self:CheckForVictory(killerType) then
                    self:PlayVictoryEffects(realKiller)
                    hero_duel.EndDuel = true
                end
            end
                        -- 清理附近掉落的物品
            local nearby_items = Entities:FindAllByClassnameWithin("dota_item_drop", killedUnit:GetAbsOrigin(), 300)
            for _, item in pairs(nearby_items) do
                if not item:IsNull() then
                    UTIL_Remove(item)
                end
            end
            -- 使用正确的索引进行清理

            self:CleanupWaterFallHeroAndSummons(killedHeroType, indexToClean, function()
                self:PreCreateWaterFallHeroes(killedHeroType)
            end)
            
        else
            print("[Arena] 警告：无法找到被击杀英雄的队伍数据")
        end
    -- end)
end
-- 在初始化时
function Main:UpdateWaterFallTeamPanelData()
    if not self.showTeamPanel then return end

    for type, teamData in pairs(self.teamTypes) do  -- type就是1,2这样的数字
        local heroSequence = self.heroSequence[type]  -- 直接使用type
        if heroSequence then
            -- 获取当前英雄
            local currentData = heroSequence.sequence[heroSequence.currentIndex]
            local currentHero = currentData and currentData.entity and currentData.entity:GetUnitName()
            
            -- 获取下一个英雄
            local nextHeroIndex = heroSequence.currentIndex + 1
            local nextHeroData = heroSequence.sequence[nextHeroIndex]
            local nextHero = nextHeroData and nextHeroData.entity and nextHeroData.entity:GetUnitName()

            -- 使用teamStats中的deaths来获取已死亡英雄数量
            local deadHeroes = heroSequence.teamStats.deaths or 0

            -- 构建数据
            local data = {
                type = teamData.type,  -- 直接使用type
                currentHero = currentHero,
                nextHero = nextHero,
                remainingHeroes = #heroSequence.sequence - deadHeroes,
                totalHeroes = #heroSequence.sequence,
                kills = heroSequence.teamStats.kills or 0,
                deadHeroes = deadHeroes
            }
            
            -- 添加中文打印信息
            print("==== 队伍状态更新 ====")
            print(string.format("队伍类型: %s (%s)", teamData.type, teamData.name))
            print(string.format("当前英雄: %s", currentHero or "无"))
            print(string.format("下一个英雄: %s", nextHero or "无"))
            print(string.format("总英雄数: %d", #heroSequence.sequence))
            print(string.format("已死亡英雄: %d", deadHeroes))
            print(string.format("剩余英雄: %d", #heroSequence.sequence - deadHeroes))
            print(string.format("队伍击杀数: %d", heroSequence.teamStats.kills or 0))
            print("========================")
            
            CustomGameEventManager:Send_ServerToAllClients("update_team_data", data)
        end
    end
end







function Main:InitializeWaterfallHeroSequence()
    local heroesGroup1 = {

    "npc_dota_hero_chaos_knight",
    "npc_dota_hero_omniknight", 
    "npc_dota_hero_doom_bringer", 

    "npc_dota_hero_spirit_breaker", 
    "npc_dota_hero_slardar", 
    "npc_dota_hero_dawnbreaker",
    "npc_dota_hero_dark_seer",
    "npc_dota_hero_obsidian_destroyer", 
    "npc_dota_hero_jakiro", 
    "npc_dota_hero_muerta",

    "npc_dota_hero_tidehunter",
    "npc_dota_hero_skeleton_king",
    "npc_dota_hero_ogre_magi",
    "npc_dota_hero_axe",
    "npc_dota_hero_legion_commander", 
    "npc_dota_hero_tusk",

    "npc_dota_hero_kunkka"



    }
    
    local heroesGroup2 = {
    "npc_dota_hero_sniper", 

    "npc_dota_hero_gyrocopter", 

    "npc_dota_hero_juggernaut", 
    "npc_dota_hero_weaver", 

    "npc_dota_hero_shadow_shaman", 
    "npc_dota_hero_faceless_void", 
    "npc_dota_hero_drow_ranger", 
    "npc_dota_hero_razor",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_naga_siren", 
    "npc_dota_hero_broodmother", 
    "npc_dota_hero_kez",
    "npc_dota_hero_monkey_king",
    "npc_dota_hero_phantom_lancer", 
    "npc_dota_hero_hoodwink",
    "npc_dota_hero_pangolier", 
    "npc_dota_hero_brewmaster", 


    }
    
    -- 创建一个查找表来确定英雄类型

        -- Group3: 筛选英雄池。当Group1和Group2都不启用时，
    -- 使用原始type分类方式，但只使用这个组里列出的英雄
    -- local heroesGroup3 = {
    --     "npc_dota_hero_earthshaker",
    --     "npc_dota_hero_kunkka",
    --     "npc_dota_hero_tiny",
    --     "npc_dota_hero_abyssal_underlord",
    --     "npc_dota_hero_elder_titan",
    --     "npc_dota_hero_axe",
    --     "npc_dota_hero_tidehunter",
    --     "npc_dota_hero_sven",
    --     "npc_dota_hero_weaver",
    --     "npc_dota_hero_troll_warlord",
    --     "npc_dota_hero_razor",
    --     "npc_dota_hero_drow_ranger",
    --     "npc_dota_hero_morphling",
    --     "npc_dota_hero_slark",
    --     "npc_dota_hero_bloodseeker",
    --     "npc_dota_hero_meepo",
    --     "npc_dota_hero_juggernaut",
    --     "npc_dota_hero_phantom_assassin",
    --     "npc_dota_hero_lich",
    --     "npc_dota_hero_necrolyte",
    --     "npc_dota_hero_crystal_maiden",
    --     "npc_dota_hero_disruptor",
    --     "npc_dota_hero_warlock",
    --     "npc_dota_hero_leshrac",
    --     "npc_dota_hero_jakiro",
    --     "npc_dota_hero_pugna",
    --     "npc_dota_hero_lina",
    --     "npc_dota_hero_abaddon",
    --     "npc_dota_hero_rattletrap",
    --     "npc_dota_hero_winter_wyvern",
    --     "npc_dota_hero_sand_king",
    --     "npc_dota_hero_invoker",
    --     "npc_dota_hero_dazzle",
    --     "npc_dota_hero_enigma"
    -- }
    local useOriginalType = not heroesGroup1 and not heroesGroup2
    local useGroup3Filter = heroesGroup3 ~= nil
    local heroTypeMap = {}
    local group3Set = {}
    
    if useGroup3Filter then
        -- 将 group3 的英雄加入集合中用于快速查找
        for _, heroName in ipairs(heroesGroup3) do
            group3Set[heroName] = true
        end
    end
    
    -- if not useOriginalType then
    --     if heroesGroup1 then
    --         for _, heroName in ipairs(heroesGroup1) do
    --             heroTypeMap[heroName] = 1
    --         end
    --     end
    --     if heroesGroup2 then
    --         for _, heroName in ipairs(heroesGroup2) do
    --             heroTypeMap[heroName] = 2
    --         end
    --     end
    -- end

    -- 只遍历 self.teamTypes 中定义的类型
    for heroType, typeInfo in pairs(self.teamTypes) do
        local heroPool = {}
        local typeNum = tonumber(typeInfo.type)

        -- 直接使用原始列表
        if typeNum == 1 and heroesGroup1 then
            -- 处理第一组英雄
            for _, heroName in ipairs(heroesGroup1) do
                for _, hero in ipairs(heroes_precache) do
                    if hero.name == heroName then
                        table.insert(heroPool, {
                            name = hero.name,
                            chinese = hero.chinese,
                            entity = nil,
                            kills = 0,
                            damage = 0
                        })
                        break  -- 找到对应的英雄信息后就跳出内层循环
                    end
                end
            end
        elseif typeNum == 2 and heroesGroup2 then
            -- 处理第二组英雄
            for _, heroName in ipairs(heroesGroup2) do
                for _, hero in ipairs(heroes_precache) do
                    if hero.name == heroName then
                        table.insert(heroPool, {
                            name = hero.name,
                            chinese = hero.chinese,
                            entity = nil,
                            kills = 0,
                            damage = 0
                        })
                        break  -- 找到对应的英雄信息后就跳出内层循环
                    end
                end
            end
        else
            -- 如果没有指定组，使用原始type分类
            local heroCount = 0
            for _, hero in ipairs(heroes_precache) do
                if hero.type == typeNum then
                    table.insert(heroPool, {
                        name = hero.name,
                        chinese = hero.chinese,
                        entity = nil,
                        kills = 0,
                        damage = 0
                    })
                    heroCount = heroCount + 1
                    if heroCount >= 100 then 
                        break
                    end
                end
            end
        end
        
        -- 如果是测试模式，处理测试英雄
        if self.isTestMode and self.testModeHeroes[heroType] then
            local sequence = {}
            -- 首先添加测试英雄
            for i, testHero in ipairs(self.testModeHeroes[heroType]) do
                table.insert(sequence, {
                    name = testHero.name,
                    chinese = testHero.chinese,
                    entity = nil,
                    kills = 0,
                    damage = 0
                })
            end
            
            -- 随机打乱剩余英雄池并添加到序列中
            local remainingPool = table.shuffle(heroPool)
            for _, hero in ipairs(remainingPool) do
                -- 检查是否已经在测试英雄中
                local isDuplicate = false
                for _, testHero in ipairs(sequence) do
                    if testHero.name == hero.name then
                        isDuplicate = true
                        break
                    end
                end
                if not isDuplicate then
                    table.insert(sequence, hero)
                end
            end
            self.heroSequence[heroType].sequence = sequence
        else
            -- 非测试模式，直接随机打乱所有英雄
            self.heroSequence[heroType].sequence = table.shuffle(heroPool)
            --self.heroSequence[heroType].sequence = heroPool
        end
        
        -- 设置总数和初始索引
        self.heroSequence[heroType].totalCount = #self.heroSequence[heroType].sequence
        self.heroSequence[heroType].currentIndex = 1
        
        -- 输出日志以便调试
        print(string.format("[Arena] 类型 %d 的英雄池大小: %d", heroType, #self.heroSequence[heroType].sequence))
        for i = 1, math.min(5, #self.heroSequence[heroType].sequence) do
            print(string.format("%d: %s (%s)", 
                i, 
                self.heroSequence[heroType].sequence[i].name,
                self.heroSequence[heroType].sequence[i].chinese))
        end
    end
end

function Main:OnAttack_waterfall_hero_chaos(keys)
    local attacker = EntIndexToHScript(keys.entindex_attacker)
    local victim = EntIndexToHScript(keys.entindex_killed)
    local damage = keys.damage

    -- 如果目标无效或者是友军，直接返回
    if not victim or attacker:GetTeamNumber() == victim:GetTeamNumber() then
        return
    end

    -- 获取实际应该记录伤害的英雄实体
    local damageOwner = attacker:GetRealOwner()

    -- 如果没找到有效的伤害归属者，直接返回
    if not damageOwner then
        return
    end

    -- 获取攻击者的团队和英雄名称
    local attackerTeam = damageOwner:GetTeamNumber()
    local attackerHeroName = damageOwner:GetUnitName()

    -- 遍历所有英雄类型
    for heroType, data in pairs(self.heroSequence) do
        if data and data.sequence then
            -- 搜索整个序列
            for i = 1, #data.sequence do
                if data.sequence[i] and data.sequence[i].entity then
                    local heroData = data.sequence[i]
                    -- 判定逻辑：团队相同且单位名称相同
                    if heroData.entity:GetTeamNumber() == attackerTeam and 
                       heroData.entity:GetUnitName() == attackerHeroName then
                        
                        -- 更新英雄个人伤害
                        heroData.damage = (heroData.damage or 0) + math.ceil(damage)
                        
                        -- 更新团队总伤害
                        if not data.teamStats then
                            data.teamStats = { damage = 0, kills = 0 }
                        end
                        data.teamStats.damage = (data.teamStats.damage or 0) + math.ceil(damage)
                        
                        
                        break  
                    end
                end
            end
        end
    end
end



function Main:PreCreateWaterFallHeroes(heroType)
    local data = self.heroSequence[heroType]
    if not data then
        print(string.format("[Arena] 错误：无效的英雄属性类型: %d", heroType))
        return false
    end

    for i = data.currentIndex, data.totalCount do
        local heroData = data.sequence[i]
        
        if not heroData.entity then
            local heroName = heroData.name
            
            print(string.format("[Arena] 准备创建英雄: %s (序号: %d)", 
                heroData.chinese, i))
            
            local parentHeroes = self.parentHeroes[heroType]
            if not parentHeroes then
                print(string.format("[Arena] 错误：未找到阵营 %d 的母体", heroType))
                return
            end 

            local facet = self.heroFacets[heroName] or 1
            print(string.format("[Arena] 命石: %d", facet))

            -- 获取对应命石的母体英雄
            local parentHero = parentHeroes[facet]
            if not parentHero then
                print(string.format("[Arena] 错误：未找到阵营 %d 命石 %d 的母体", heroType, facet))
                return
            end

            CreateHeroHeroChaos(
                0,
                heroName,
                facet, 
                self.SPAWN_POINT_FAR,
                data.team,
                false,
                parentHero,
                function(createdHero)
                    if not createdHero then
                        print(string.format("[Arena] 错误：创建英雄失败: %s", heroData.chinese))
                        return
                    end
                    
                    if heroName == "npc_dota_hero_weaver" then
                        print("[Arena] 检测到编织者，立即升至最高等级")
                        HeroMaxLevel(createdHero)
                    end
                    
                    heroData.entity = createdHero
                    self:SetupInitialBuffs(createdHero)
                    
                    print(string.format("[Arena] 成功创建英雄: %s", heroData.chinese))
                end
            )
            return true

        else
            print(string.format("[Arena] 英雄已存在，继续查找下一个: %s", heroData.chinese))
        end
    end

    print(string.format("[Arena] 提示：属性 %d 的英雄已全部创建完成", heroType))
    return false
end



function Main:DeployWaterFallHero(heroType, isInitialSpawn)
    local data = self.heroSequence[heroType]
    if not data then return end
    
    -- 检查索引是否有效
    if data.currentIndex > #data.sequence then
        print(string.format("[Arena] 错误：当前索引 %d 超出英雄序列长度 %d", 
            data.currentIndex, #data.sequence))
        return
    end
    local deployIndex = data.currentIndex
    
    -- 初始化等待计数器
    local waitCount = 0
    local MAX_WAIT_TIME = 15 -- 最多等待10秒

    -- 检查当前位置是否有可用的英雄，如果没有则等待
    local function waitForHero()
        waitCount = waitCount + 1
        
        -- 超过最大等待时间
        if waitCount > MAX_WAIT_TIME then
            print(string.format("[Arena] 错误：等待属性 %d 当前位置 %d 的英雄超时", heroType, deployIndex))
            return nil
        end

        local heroData = data.sequence[deployIndex]  -- 使用保存的索引
        if not heroData or not heroData.entity then
            print(string.format("[Arena] 等待属性 %d 当前位置 %d 的英雄就绪...（%d/%d）", 
                heroType, deployIndex, waitCount, MAX_WAIT_TIME))
            return 1 -- 1秒后重试
        end

        -- 找到可用英雄，开始部署流程
        local hero = heroData.entity
        local spawnPoint = self:GetSpawnPointForType(heroType, isInitialSpawn,hero)
        
        -- 计算朝向
        local direction = (self.ARENA_CENTER - spawnPoint):Normalized()
        -- 转换为角度
        local angle = VectorToAngles(direction)
        -- 设置英雄朝向
        hero:SetAngles(angle.x, angle.y, angle.z)
        
        -- 根据英雄类型选择特效
        local particleName = ""
        if heroType == 1 then -- 力量英雄，红色
            particleName = "particles/red/teleport_start_ti6_lvl2.vpcf"
        elseif heroType == 2 then -- 敏捷英雄，绿色
            particleName = "particles/green/teleport_start_ti8_lvl2.vpcf"
        elseif heroType == 4 then -- 智力英雄，蓝色
            particleName = "particles/blue/teleport_start_ti7_lvl3.vpcf"
        elseif heroType == 8 then -- 全才英雄，紫色
            particleName = "particles/purple/teleport_start_ti9_lvl2.vpcf"
        end
        
        -- 播放传送特效
        local particle = ParticleManager:CreateParticle(particleName, PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particle, 0, spawnPoint)
        
        local delay = isInitialSpawn and 10.0 or 1
        print(string.format("[Arena] 英雄 %s 将在 %.1f 秒后移除无敌状态", hero:GetUnitName(), delay))

        -- 4秒后开始传送
        Timers:CreateTimer(delay, function()
            -- 移除隐身相关的buff
            if hero:HasModifier("modifier_wearable") then
                hero:RemoveModifierByName("modifier_wearable")
            end
            FindClearSpaceForUnit(hero, spawnPoint, true)

            -- 根据是否是初始生成决定延迟时间

            -- 移除无敌状态
            if hero:HasModifier("modifier_invulnerable") then
                hero:RemoveModifierByName("modifier_invulnerable")
                hero:Purge(false, true, false, false, false)
            end
            
            -- 清理传送特效
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
            
            -- 创建AI并设置战斗状态
            CreateAIForHero(hero,{"攻击无敌单位"})
            self:SetupWaterFallCombatBuffs(hero)
            
            -- 执行英雄特殊效果
            local heroStrategy = hero.ai and hero.ai.heroStrategy or nil
            self:HeroBenefits(hero:GetUnitName(), hero, heroStrategy)
            self:StartAbilitiesMonitor(hero,false)

        end)

        return nil -- 不再继续等待
    end

    -- 开始等待循环
    Timers:CreateTimer(waitForHero)
end

function Main:Initialize_waterfall_hero_chaos_UI()
    print("[Arena] Starting UI initialization...")
    
    -- 分数面板始终显示
    CustomGameEventManager:Send_ServerToAllClients("show_hero_chaos_score", {})
    
    -- 只有在showTeamPanel为true时才显示队伍面板
    if self.showTeamPanel then
        print("[Arena] Sending show_waterfall_hero_chaos_container event")
        CustomGameEventManager:Send_ServerToAllClients("show_hero_chaos_container", {})
        
        -- 设置需要的面板
        local activeTypes = {}
        for type, typeInfo in pairs(self.teamTypes) do
            table.insert(activeTypes, typeInfo.type)
        end
        
        print("[Arena] Sending setup_waterfall_hero_chaos_panels event with types:", table.concat(activeTypes, ", "))
        CustomGameEventManager:Send_ServerToAllClients("setup_hero_chaos_panels", {
            types = activeTypes
        })
    end

    print("[Arena] UI initialization completed")
end



function Main:InitialPreWaterFallCreateHeroes()
    -- 先创建母体，再创建英雄
    local PARENT_SPAWN_POINT = Vector(9999, 9999, 128)
    self.parentHeroes = {}

    -- 团队到DOTA_TEAM的映射
    local teamMapping = {
        [1] = DOTA_TEAM_BADGUYS,    -- 红队
        [2] = DOTA_TEAM_GOODGUYS,   -- 绿队
        [4] = DOTA_TEAM_CUSTOM_1,   -- 蓝队
        [8] = DOTA_TEAM_CUSTOM_2    -- 紫队
    }

    -- 根据配置类型确定需要创建的阵营
    local teamsToCreate = {}
    if self.teamConfig == "ATTRIBUTE" then
        teamsToCreate = {1, 2, 4, 8}  -- 力量、敏捷、智力、全才
    elseif self.teamConfig == "TOURNAMENT" then
        teamsToCreate = {1, 2}  -- 只创建力量和敏捷阵营
    else
        -- 如果有其他配置类型，可以在这里添加
        print(string.format("[Arena] 警告：未知的队伍配置类型: %s，默认使用所有阵营", self.teamConfig))
        teamsToCreate = {1, 2, 4, 8}
    end
    
    -- 打印调试信息
    print(string.format("[Arena] 当前配置: %s，将创建以下阵营的母体:", self.teamConfig))
    for _, teamType in ipairs(teamsToCreate) do
        local teamName = ""
        if teamType == 1 then teamName = "力量"
        elseif teamType == 2 then teamName = "敏捷"
        elseif teamType == 4 then teamName = "智力"
        elseif teamType == 8 then teamName = "全才"
        end
        print(string.format("  - 阵营 %d (%s)", teamType, teamName))
    end

    -- 创建英雄的函数
    local function CreateHeroes()
        local heroTypes = {}
        -- 从teamTypes中获取所有type
        for type, _ in pairs(self.teamTypes) do
            table.insert(heroTypes, type)
        end
        
        -- 确定每种属性预创建的英雄数量
        local heroesPerType = math.max(self.preCreatePerTeam, self.heroesPerTeam)
        local totalTime = 10
        local interval = totalTime / (#heroTypes * heroesPerType)
        
        local currentIndex = 0
        for _, heroType in ipairs(heroTypes) do
            for i = 1, heroesPerType do
                Timers:CreateTimer(interval * currentIndex, function()
                    self:PreCreateWaterFallHeroes(heroType)
                end)
                currentIndex = currentIndex + 1
            end
        end
    end

    -- 查找heroFacets中的最大命石值
    local maxFacet = 1
    for _, facetValue in pairs(self.heroFacets) do
        if facetValue > maxFacet then
            maxFacet = facetValue
        end
    end
    print(string.format("[Arena] 检测到最大命石值: %d", maxFacet))

    -- 使用新的方式创建母体，只创建需要的阵营
    CreateParentHeroesWithFacets(function(allHeroes)
        -- 将创建的英雄按照阵营分配到self.parentHeroes中，只分配需要的阵营
        for _, teamType in ipairs(teamsToCreate) do
            if teamType == 1 then
                self.parentHeroes[1] = allHeroes.bad        -- 红队
            elseif teamType == 2 then
                self.parentHeroes[2] = allHeroes.good       -- 绿队
            elseif teamType == 4 then
                self.parentHeroes[4] = allHeroes.custom1    -- 蓝队
            elseif teamType == 8 then
                self.parentHeroes[8] = allHeroes.custom2    -- 紫队
            end
        end

        -- 打印日志确认创建成功
        for heroType, heroes in pairs(self.parentHeroes) do
            print(string.format("[Arena] 阵营 %d 母体创建情况:", heroType))
            local facetCount = 0
            for facetId, hero in pairs(heroes) do
                facetCount = facetCount + 1
                print(string.format("  - 命石 %d: %s", facetId, hero:GetUnitName()))
            end
            
            -- 检查是否有足够的母体英雄
            if facetCount < maxFacet then
                print(string.format("[Arena] 警告：阵营 %d 的母体数量(%d)小于最大命石值(%d)，可能导致命石不匹配", 
                    heroType, facetCount, maxFacet))
            end
        end

        -- 创建其他英雄
        CreateHeroes()
    end, teamsToCreate, maxFacet)  -- 传递需要创建的阵营和最大命石值
end




function Main:Start_waterfall_hero_chaos_ScoreBoardMonitor()
    if self.scoreMonitorTimer then
        Timers:RemoveTimer(self.scoreMonitorTimer)
    end

    self.scoreMonitorTimer = Timers:CreateTimer(0.1, function()
        if hero_duel.EndDuel == true then
            return nil
        end

        -- 收集团队数据
        local teamData = {}

        -- 收集团队数据
        for heroType, typeInfo in pairs(self.teamTypes) do
            if self.heroSequence[heroType] then
                table.insert(teamData, {
                    type = typeInfo.type,
                    name = typeInfo.name,
                    kills = self.heroSequence[heroType].teamStats.kills or 0,
                    damage = self.heroSequence[heroType].teamStats.damage or 0
                })
            end
        end

        -- 按击杀数排序，如果击杀数相同则按伤害排序
        table.sort(teamData, function(a, b)
            if a.kills == b.kills then
                return a.damage > b.damage
            end
            return a.kills > b.kills
        end)


        -- 收集当前场上英雄数据
        local currentHeroes = {}
        for heroType, data in pairs(self.heroSequence) do
            local currentHero = data.sequence[data.currentIndex]
            if currentHero then
                table.insert(currentHeroes, {
                    type = self.teamTypes[heroType].type,
                    name = currentHero.chinese,
                    kills = currentHero.kills or 0,
                    damage = currentHero.damage or 0
                })
            end
        end

        -- 对当前场上英雄进行排序
        table.sort(currentHeroes, function(a, b)
            if a.kills == b.kills then
                return a.damage > b.damage
            end
            return a.kills > b.kills
        end)


        -- 收集个人数据
        local heroData = {}
        for heroType, data in pairs(self.heroSequence) do
            for i = 1, data.currentIndex do
                local hero = data.sequence[i]
                if hero then
                    table.insert(heroData, {
                        type = self.teamTypes[heroType].type,
                        name = hero.chinese,
                        kills = hero.kills or 0,
                        damage = hero.damage or 0
                    })
                end
            end
        end

        -- 按击杀数排序，如果击杀数相同则按伤害排序
        table.sort(heroData, function(a, b)
            if a.kills == b.kills then
                return a.damage > b.damage
            end
            return a.kills > b.kills
        end)

        -- 发送数据到前端
        CustomGameEventManager:Send_ServerToAllClients("update_hero_chaos_score", {
            teamTypes = self.teamTypes,  -- Add team types to the event data
            teams = teamData,
            currentHeroes = currentHeroes,
            heroes = heroData
        })

        return 0.1
    end)
end

function Main:OnAbilityUsed_waterfall_hero_chaos(event)
    print("技能释放事件")
    local caster = EntIndexToHScript(event.caster_entindex)
    local target = caster:GetCursorCastTarget()
    --如果英雄释放的技能是chaos_knight_reality_rift，让英雄对目标施加持续三秒的缴械、沉默和破坏效果
    if event.abilityname == "chaos_knight_reality_rift" then
        target:AddNewModifier(caster, nil, "modifier_break", {duration = 3})
        target:AddNewModifier(caster, nil, "modifier_silence", {duration = 3})
        target:AddNewModifier(caster, nil, "modifier_disarmed", {duration = 3})
    end
    

end






function Main:OnNPCSpawned_waterfall_hero_chaos(spawnedUnit, event)
    spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_kv_editor", {})
    local minX = -7023.13
    local maxX = -4999.12
    local minY = -876.53
    local maxY = 1157.39
    
    Timers:CreateTimer(2.0, function()
        if not spawnedUnit or spawnedUnit:IsNull() then
            return
        end

        if spawnedUnit:IsIllusion() and spawnedUnit:HasModifier("modifier_spectre_haunt") then
            local origin = spawnedUnit:GetAbsOrigin()
            if origin.x < minX or origin.x > maxX or origin.y < minY or origin.y > maxY then
                spawnedUnit:Kill(nil, nil)
            end
        end
    end)
end