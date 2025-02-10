
function CommonAI:Ini_SkillAoeRadius()
    self.specificRadius = {
        razor_plasma_field = 1800,
        meepo_megameepo = 0,
        shredder_reactive_armor = 9999,
        ursa_enrage = 1200,
        razor_eye_of_the_storm = 9999,
        furion_sprout = 9999,
        pugna_nether_ward = 1400,
        witch_doctor_voodoo_switcheroo = 650,

        leshrac_diabolic_edict = 2000,
        death_prophet_exorcism = 2000,
        leshrac_greater_lightning_storm = 9999,
        leshrac_pulse_nova = 9999,
        void_spirit_aether_remnant = 600,
        --void_spirit_dissimilate = 800,
        void_spirit_dissimilate = 300,
        dark_seer_wall_of_replica = 650,
        void_spirit_astral_step = 170,
        batrider_firefly = 2000,
        dark_willow_shadow_realm = 800,
        magnataur_skewer = 145,
        batrider_flaming_lasso = 0,
        nyx_assassin_jolt = 0,
        nyx_assassin_spiked_carapace = 900,
        huskar_inner_fire = 500,
        arc_warden_tempest_double = 9999,
        clinkz_burning_barrage = 50,
        arc_warden_magnetic_field = 625,
        shadow_shaman_mass_serpent_ward = 810,
        skywrath_mage_concussive_shot = 9999,
        templar_assassin_self_trap = 400,
        hoodwink_scurry = 1000,
        undying_soul_rip = 0,
        doom_bringer_scorched_earth = 9999,
        phoenix_fire_spirits = 0,
        pangolier_gyroshell = 2500,
        pangolier_rollup = 50,
        snapfire_firesnap_cookie = 725,
        visage_soul_assumption = 0,
        enigma_demonic_conversion = 2000,
        visage_stone_form_self_cast = 2000,
        nyx_assassin_burrow = 1250,
        invoker_forge_spirit = 2000,
        rattletrap_jetpack = 800,
        ursa_overpower = 2000,
        silencer_global_silence = 9999,
        muerta_dead_shot = 1500,
        ember_spirit_immolation = 2000,
        phantom_lancer_juxtapose = 1000,
        pangolier_rollup = 2000,
        weaver_shukuchi = 1000,
        enchantress_natures_attendants = 0,
        dark_willow_bedlam = 200,
        invoker_ice_wall = 750,
        primal_beast_pulverize = 0,
        centaur_stampede = 99999,
        bristleback_warpath = 9999,
        troll_warlord_whirling_axes_melee = 600,
        antimage_counterspell = 600,
        monkey_king_wukongs_command = 800,
        meepo_petrify = 99999,
        drow_ranger_multishot = 1700,
        naga_siren_mirror_image = 2000,
        naga_siren_song_of_the_siren = 2000,
    }
    self.itemRadius = {
        item_mjollnir = 2000,
        item_disperser = 2000,
        item_satanic = 2000,
    }
end

function CommonAI:GetItemAoeRadius(ability)
    local abilityName = ability:GetAbilityName()
    -- 如果是电锤且策略包含"贴脸放电锤",直接返回500
    if abilityName == "item_mjollnir" and self:containsStrategy(self.global_strategy, "贴脸放电锤") then
        return 500
    end
    -- 其他物品按原来的逻辑处理
    if self.itemRadius[abilityName] then
        return self.itemRadius[abilityName]
    end
    return ability:GetAOERadius()
end

function CommonAI:GetSkillAoeRadius(ability)
    local kv = ability:GetAbilityKeyValues()
    local caster = ability:GetCaster()
    local abilityName = ability:GetAbilityName()
    local aoeRadius = ability:GetAOERadius()

    if Main.currentChallenge == Main.Challenges.CD0_1skill then
        self.specificRadius.batrider_flamebreak = 0
        self.specificRadius.rattletrap_battery_assault = 0
        self.specificRadius.ursa_earthshock = 9999
    end

    if self:containsStrategy(self.global_strategy, "防守策略") then
        self.specificRadius.hoodwink_acorn_shot = 2500
        --self.specificRadius.hoodwink_bushwhack = 2500
        self.specificRadius.hoodwink_scurry = 0
        self.specificRadius.treant_leech_seed = 2000
        self.specificRadius.mars_arena_of_blood = 800
        self.specificRadius.lina_light_strike_array = 800
    end

    if self:containsStrategy(self.hero_strategy, "省蓝") then
        self.specificRadius.leshrac_pulse_nova = 1300
    end

    if self:containsStrategy(self.hero_strategy, "贴脸才相位转移") then
        self.specificRadius.puck_phase_shift = 500
    end
    
    if self:containsStrategy(self.hero_strategy, "主动进攻") then
        self.specificRadius.zuus_heavenly_jump = 2500
    end
    if self:containsStrategy(self.hero_strategy, "贴脸才放大") then
        self.specificRadius.faceless_void_time_zone = 300
    end
    if self:containsStrategy(self.hero_strategy, "出门开转") then
        self.specificRadius.juggernaut_blade_fury = 2000
    end
    if self:containsStrategy(self.hero_strategy, "出门直接跳") then
        self.specificRadius.slark_pounce = 2500
    end
    if self:containsStrategy(self.hero_strategy, "出门开壳") or self:containsStrategy(self.hero_strategy, "掉血开壳") then
        self.specificRadius.nyx_assassin_spiked_carapace = 2500
    end
    if self:containsStrategy(self.hero_strategy, "远距离飞斧") then
        self.specificRadius.troll_warlord_whirling_axes_melee = 2500
    end
    if self:containsStrategy(self.hero_strategy, "优先跳") then
        self.specificRadius.mirana_leap = 4000
    end
    if self:containsStrategy(self.hero_strategy, "远距离针刺") then
        self.specificRadius.bristleback_quill_spray = 2500
    end
    if self:containsStrategy(self.hero_strategy, "原地山崩") then
        self.specificRadius.tiny_avalanche = 200
    end
    if self:containsStrategy(self.hero_strategy, "半路大") then
        self.specificRadius.doom_bringer_doom = 1300
    end
    if self:containsStrategy(self.hero_strategy, "提前摇大") then
        self.specificRadius.sandking_epicenter = 2000
    end
    if self:containsStrategy(self.hero_strategy, "异化赶路") then
        self.specificRadius.void_spirit_dissimilate = 2000
    end
    if self:containsStrategy(self.hero_strategy, "出门埋地") then
        self.specificRadius.nyx_assassin_burrow = 2000
    end
    if self:containsStrategy(self.hero_strategy, "靠近就魔晶") then
        self.specificRadius.pangolier_rollup = 1600
    end
    if self:containsStrategy(self.hero_strategy, "出门不放魔晶") then
        self.specificRadius.pangolier_rollup = 300
    end
    if self:containsStrategy(self.hero_strategy, "出门放齿轮") then
        self.specificRadius.rattletrap_power_cogs = 3000
    end
    if self:containsStrategy(self.hero_strategy, "用跳赶路") then
        self.specificRadius.ursa_earthshock = 2000
    end
    if self:containsStrategy(self.hero_strategy, "提前开C") then
        self.specificRadius.slark_dark_pact = 1000
    end
    if self:containsStrategy(self.hero_strategy, "走两步波") then
        self.specificRadius.morphling_waveform = 800
    end
    if self:containsStrategy(self.hero_strategy, "远距离冲刺") then
        self.specificRadius.kez_falcon_rush = 1450
    end
    if self:containsStrategy(self.hero_strategy, "大招弹射") then
        self.specificRadius.skywrath_mage_mystic_flare = 850
    end

    if self.entity:HasModifier("modifier_rattletrap_jetpack") then
        self.specificRadius.rattletrap_power_cogs = 1500
    else
        self.specificRadius.rattletrap_power_cogs = nil
    end

    if self.needToDodge == true then
        self.specificRadius.zuus_heavenly_jump = 2500
    end

    -- 如果在特定技能表中找到，则使用固定值
    if self.specificRadius[abilityName] then
        return self.specificRadius[abilityName]
    end
    
    local specialValueKeys = {
        crystal_maiden_crystal_clone = "frostbite_radius",
        elder_titan_earth_splitter = "crack_width",
        lion_impale = "width",
        earthshaker_fissure = "fissure_radius",
        kunkka_tidal_wave = "radius",
        treant_natures_guise = "radius",
        tidehunter_gush = "aoe_scepter",
        primal_beast_onslaught = "knockback_radius",
        dawnbreaker_celestial_hammer = "flare_radius",
        clinkz_burning_barrage = "projectile_width",
        morphling_waveform = "width",
        monkey_king_boundless_strike = "strike_radius",
        tinker_march_of_the_machines = "radius",
        grimstroke_dark_artistry = { "start_radius", "end_radius" },
        puck_illusory_orb = "radius",
        death_prophet_carrion_swarm = { "start_radius", "end_radius" },
        --muerta_dead_shot = "radius",
        lina_dragon_slave = "dragon_slave_width_initial",
        magnataur_horn_toss = "radius",
        nevermore_requiem = "requiem_radius",
        nevermore_shadowraze3 = "shadowraze_radius",
        nevermore_shadowraze2 = "shadowraze_radius",
        nevermore_shadowraze1 = "shadowraze_radius",
        monkey_king_wukongs_command = "radius",
        clinkz_burning_army = "range",
        pangolier_swashbuckle = "range",
        drow_ranger_wave_of_silence = "wave_width",
        templar_assassin_psionic_trap = "trap_radius",
        brewmaster_void_astral_pull = "pull_distance",
        kez_ravens_veil = "blast_radius",
        kez_falcon_rush = "rush_range",
        dark_willow_bedlam = "attack_radius",
        mars_spear = "spear_width",
        sniper_concussive_grenade = "radius",
    }


    -- 特殊处理 templar_assassin_meld
    if abilityName == "templar_assassin_meld" or abilityName == "sniper_take_aim" then
        if caster then
            local attackRange = caster:Script_GetAttackRange()
            aoeRadius = attackRange
        end
    elseif abilityName == "windrunner_windrun" then
        if caster then
            local attackRange = caster:Script_GetAttackRange()
            aoeRadius = attackRange
        end
    elseif abilityName == "marci_unleash" and self:containsStrategy(self.hero_strategy, "出门开大") then
        if caster then
            local attackRange = caster:Script_GetAttackRange()
            aoeRadius = attackRange
        end
    elseif abilityName == "enchantress_bunny_hop" then
        if caster then
            local attackRange = caster:Script_GetAttackRange()
            aoeRadius = attackRange
        end
    elseif abilityName == "muerta_pierce_the_veil" then
        if caster then
            local attackRange = caster:Script_GetAttackRange() + 300
            aoeRadius = attackRange
        end

    elseif abilityName == "slardar_slithereen_crush" then
        if self:containsStrategy(self.hero_strategy, "踩水洼") then
            if not caster:HasModifier("modifier_slardar_seaborn_sentinel_river") then
                aoeRadius = 1000
            end
        end

    elseif abilityName == "ember_spirit_searing_chains" then
        local remnants = FindUnitsInRadius(
            caster:GetTeamNumber(),
            self.target:GetAbsOrigin(),
            nil,
            400,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
            FIND_ANY_ORDER,
            false
        )

        for _, remnant in pairs(remnants) do
            if remnant:GetUnitName() == "npc_dota_ember_spirit_remnant" then
                self:log("有残焰在附近，可以远程捆")
                aoeRadius = 2000
            end
        end
    elseif abilityName == "elder_titan_echo_stomp" then
        local spirits = FindUnitsInRadius(
            caster:GetTeamNumber(),
            self.target:GetAbsOrigin(),
            nil,
            500,
            DOTA_UNIT_TARGET_TEAM_BOTH,
            DOTA_UNIT_TARGET_ALL,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
            DOTA_UNIT_TARGET_FLAG_INVULNERABLE + 
            DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD +
            DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
            FIND_ANY_ORDER,
            false
        )
    
        for _, unit in pairs(spirits) do
            if unit:GetUnitName() == "npc_dota_elder_titan_ancestral_spirit" then
                self:log("先祖之灵在敌人500范围内，可以远程踩")
                aoeRadius = 2000
            end
        end

    -- 特殊处理 magnataur_reverse_polarity
    elseif abilityName == "magnataur_reverse_polarity" then
        local caster = ability:GetCaster()
        if caster and caster:HasAbility("special_bonus_facet_magnataur_reverse_reverse_polarity") then
            local talent = caster:FindAbilityByName("special_bonus_facet_magnataur_reverse_reverse_polarity")
            if talent and talent:GetLevel() > 0 then
                aoeRadius =  700
            end
        end
        aoeRadius = 430


    elseif abilityName == "earthshaker_fissure" then
        if self:containsStrategy(self.hero_strategy, "沟壑连招") then
            return 0
        end


    elseif abilityName == "earthshaker_echo_slam" then
        if not self:containsStrategy(self.hero_strategy, "远程余震") then

            local totemAbility = self.entity:FindAbilityByName("earthshaker_enchant_totem")
            if totemAbility then
                print("用图腾的范围代替")
                aoeRadius = self:GetSkillAoeRadius(totemAbility)
            end
        else
            aoeRadius = 500
        end
    end

    if specialValueKeys[abilityName] then
        local kv = ability:GetAbilityKeyValues()
        if kv.AbilityValues then
            local specialValueKey = specialValueKeys[abilityName]
            if type(specialValueKey) == "table" then
                -- 处理有两个半径值的情况
                local value1 = tonumber(kv.AbilityValues[specialValueKey[1]] or 0)
                local value2 = tonumber(kv.AbilityValues[specialValueKey[2]] or 0)
                return math.max(value1 or 0, value2 or 0)
            else
                -- 处理单个半径值的情况
                local specialValue = kv.AbilityValues[specialValueKey]
                if type(specialValue) == "table" and specialValue.value then
                    return tonumber(specialValue.value) or 0
                elseif type(specialValue) == "string" then
                    -- 处理多等级技能
                    local radii = {}
                    for value in string.gmatch(specialValue, "%d+") do
                        table.insert(radii, tonumber(value))
                    end
                    local currentLevel = ability:GetLevel()
                    return radii[currentLevel] or radii[#radii] or 0
                else
                    return tonumber(specialValue) or 0
                end
            end
        end
    end


    -- 如果默认AOE半径为0，则尝试从技能的特殊值中获取AOE半径
    if aoeRadius == 0 then
        local radius = 0
        local additionalRadius = 0
        -- 检查AbilityValues中的radius或特殊值
        if kv.AbilityValues then
            if kv.AbilityValues.radius then
                if type(kv.AbilityValues.radius) == "table" then
                    radius = kv.AbilityValues.radius.value or 0
                else
                    -- 处理多级技能的情况
                    if type(kv.AbilityValues.radius) == "string" then
                        local radii = {}
                        for value in string.gmatch(kv.AbilityValues.radius, "%d+") do
                            table.insert(radii, tonumber(value))
                        end
                        local currentLevel = ability:GetLevel()
                        radius = radii[currentLevel] or radii[#radii]
                        self:log(string.format("Debug: Processing multi-level radius: level %d, selected radius %d", 
                            currentLevel, radius))
                    else
                        radius = tonumber(kv.AbilityValues.radius) or 0
                    end
                end
            elseif specialValueKey then
                if type(specialValueKey) == "table" then
                    local value1 = tonumber(kv.AbilityValues[specialValueKey[1]] or 0)
                    local value2 = tonumber(kv.AbilityValues[specialValueKey[2]] or 0)
                    
                    -- 添加日志输出
                    self:log(string.format("Debug: specialValueKey[1] = %s, value = %s", tostring(specialValueKey[1]), tostring(value1)))
                    self:log(string.format("Debug: specialValueKey[2] = %s, value = %s", tostring(specialValueKey[2]), tostring(value2)))
                    
                    if value1 and value2 then
                        radius = math.max(value1, value2)
                    else
                        self:log("Warning: Invalid values for math.max in GetSkillAoeRadius")
                        radius = value1 or value2 or 0
                    end
                else
                    local specialValue = kv.AbilityValues[specialValueKey]
                    if type(specialValue) == "table" and specialValue.value then
                        radius = tonumber(specialValue.value) or 0
                    else
                        -- 处理多级技能的情况
                        if type(specialValue) == "string" then
                            local radii = {}
                            for value in string.gmatch(specialValue, "%d+") do
                                table.insert(radii, tonumber(value))
                            end
                            local currentLevel = ability:GetLevel()
                            radius = radii[currentLevel] or radii[#radii]
                            self:log(string.format("Debug: Processing multi-level special radius: level %d, selected radius %d", 
                                currentLevel, radius))
                        else
                            radius = tonumber(specialValue) or 0
                        end
                    end
                end
            end
        end

        -- 添加最终的radius日志输出
        self:log(string.format("Debug: Final radius value = %s", tostring(radius)))

        -- 如果没有找到radius，检查顶层的AbilityRadius
        if (not radius or radius == 0) and kv.AbilityRadius then
            radius = type(kv.AbilityRadius) == "table" and kv.AbilityRadius.value or kv.AbilityRadius
        end

        -- 确保radius是一个数字
        if type(radius) == "table" then
            radius = radius.value or 0
        elseif type(radius) ~= "number" then
            radius = tonumber(radius) or 0
        end

        -- 处理多级技能的情况
        if type(radius) == "string" then
            local radii = {}
            for value in string.gmatch(radius, "%d+") do
                table.insert(radii, tonumber(value))
            end
            local currentLevel = ability:GetLevel()
            radius = radii[currentLevel] or radii[#radii] or 0
        end

        -- 检查是否有碎片升级
        local caster = ability:GetCaster()
        if caster and caster:HasModifier("modifier_item_aghanims_shard") then
            local shardBonus = 0
            if kv.AbilityValues and kv.AbilityValues.radius and type(kv.AbilityValues.radius) == "table" then
                shardBonus = tonumber(string.match(kv.AbilityValues.radius.special_bonus_shard or "0", "[%+%-]?%d+")) or 0
            end
            if shardBonus == 0 then
                shardBonus = tonumber(string.match(kv.AbilityRadius and kv.AbilityRadius.special_bonus_shard or "0", "[%+%-]?%d+")) or 50  -- 默认假设碎片提供50的额外半径
            end
            radius = radius + shardBonus
        end

        -- 动态检查特殊天赋
        local talentSource = kv.AbilityValues and kv.AbilityValues.radius or kv.AbilityRadius
        if type(talentSource) == "table" then
            for key, value in pairs(talentSource) do
                if string.find(key, "special_bonus_unique_") then
                    local talentName = key
                    if caster and caster:HasAbility(talentName) then
                        local talent = caster:FindAbilityByName(talentName)
                        if talent and talent:GetLevel() > 0 then
                            local bonusRadius = tonumber(string.match(value, "[%+%-]?%d+"))
                            if bonusRadius then
                                radius = radius + bonusRadius
                            end
                        end
                    end
                end
            end
        end

        if abilityName == "pangolier_shield_crash" then
            local jumpDistance = 0
            if kv.AbilityValues and kv.AbilityValues.jump_horizontal_distance then
                local jumpValue = kv.AbilityValues.jump_horizontal_distance
                if type(jumpValue) == "table" then
                    jumpDistance = tonumber(jumpValue.value) or 0
                else
                    jumpDistance = tonumber(jumpValue) or 0
                end
            end
            radius = radius + jumpDistance
        end


        aoeRadius = radius + additionalRadius
    end

    if abilityName == "earthshaker_enchant_totem" then
        if self:containsStrategy(self.hero_strategy, "远程余震") then
            print("[Debug] 正在检测远程余震策略")
            if self.target then
                print("[Debug] 目标存在，开始搜索范围内单位")
    
                local location = self.target:GetAbsOrigin()
                local radius = 500
                local thinkers = Entities:FindAllByClassnameWithin("npc_dota_thinker", location, radius)
                
                print("[Debug] 搜索到thinker数量:", #thinkers)
                for _, thinker in pairs(thinkers) do
                    print("[Debug] 发现thinker单位")
                    local owner = thinker:GetOwner()
                    if owner then
                        print("[Debug] thinker所有者:", owner:GetUnitName())
                        if owner:FindAbilityByName("earthshaker_aftershock") then
                            print("[Debug] 检测到余震thinker，设置AOE为9999")
                            aoeRadius = 9999
                            break
                        else
                            print("[Debug] 所有者没有余震技能")
                        end
                    else
                        print("[Debug] thinker没有所有者")
                    end
                end
            else
                print("[Debug] 目标不存在，跳过余震检测")
            end
        else
            print("[Debug] 未启用远程余震策略")
        end
    end
    return aoeRadius
end