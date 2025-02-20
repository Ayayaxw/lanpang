function CommonAI:Ini_SkillCastRange()
    self.skillCastRanges = {
        drow_ranger_glacier = 800,
        spirit_breaker_charge_of_darkness = 9999,
        spectre_reality = 9999,
        spectre_haunt_single = 9999,

        storm_spirit_ball_lightning = 9999,
        --riki_tricks_of_the_trade = 9999,
        monkey_king_tree_dance = 9999,
        monkey_king_primal_spring = 9999,
        ancient_apparition_ice_blast = 9999,

        zuus_cloud = 9999,
        primal_beast_onslaught_release = 0,
        dawnbreaker_fire_wreath = 500,
        keeper_of_the_light_spirit_form = 0,--灵魂形态不设置施法距离
        death_prophet_spirit_siphon = 500,
        shadow_demon_shadow_poison = 1500,
        void_spirit_astral_step = 800,
        mirana_leap = 1000,
        ember_spirit_searing_chains = 0,
        bristleback_bristleback = 700,
        clinkz_strafe = 0,
        templar_assassin_trap_teleport = 9999,
        troll_warlord_battle_trance = 0,
        hoodwink_scurry = 0,
        mars_gods_rebuke = 0,
        dawnbreaker_converge = 0,
        earth_spirit_rolling_boulder = 950,
        earth_spirit_boulder_smash = 800,
        elder_titan_move_spirit = 9999,
        phoenix_icarus_dive = 100,
        kez_echo_slash = 0,
        kez_shodo_sai = 500,
        muerta_dead_shot = 2000,
        invoker_sun_strike = 9999,
        dawnbreaker_solar_guardian = 9999,
        furion_wrath_of_nature = 9999,
        drow_ranger_multishot = 25,
        wisp_relocate = 9999,
        huskar_inner_fire = 0,
        dark_willow_bedlam = 0,
        treant_living_armor = 9999,
        rattletrap_rocket_flare = 9999,
        ogre_bruiser_ogre_smash = 100,

    }
end

function CommonAI:GetSkillCastRange(entity, ability)
    if not self.skillCastRanges then
        self:Ini_SkillCastRange()  -- 如果 skillCastRanges 不存在，初始化它
    end

    local abilityName = ability:GetAbilityName()
    local castRange = ability:GetCastRange(entity:GetOrigin(), nil)

    
    if Main.currentChallenge == Main.Challenges.CD0_1skill then
        self.skillCastRanges.dark_willow_terrorize = 100
    end
    local kv = ability:GetAbilityKeyValues()
    -- 如果默认施法距离为0，则尝试从技能的特殊值中获取施法距离


    if castRange == 0 then
        
        local range = 0
        local additionalLength = 0
        
        -- 定义技能特殊施法距离映射表
        local specialValueKeys = {
            mars_spear = "spear_range",
            primal_beast_onslaught = "max_distance",
        }
        
        local specialValueKey = specialValueKeys[abilityName]
        
        -- 添加日志：打印技能名称和specialValueKey
        self:log(string.format("Debug: Checking castrange for ability: %s, specialValueKey: %s", 
            tostring(abilityName), tostring(specialValueKey)))
        
        -- 首先检查是否有特殊值需要读取
        if kv.AbilityValues and specialValueKey then
            -- 添加日志：确认进入特殊值检查
            self:log("Debug: Found AbilityValues and specialValueKey")
            
            if type(specialValueKey) == "table" then
                local value1 = tonumber(kv.AbilityValues[specialValueKey[1]] or 0)
                local value2 = tonumber(kv.AbilityValues[specialValueKey[2]] or 0)
                
                -- 添加日志：打印表中的值
                self:log(string.format("Debug: specialValueKey[1] = %s, value = %s", 
                    tostring(specialValueKey[1]), tostring(value1)))
                self:log(string.format("Debug: specialValueKey[2] = %s, value = %s", 
                    tostring(specialValueKey[2]), tostring(value2)))
                
                if value1 and value2 then
                    range = math.max(value1, value2)
                else
                    self:log("Warning: Invalid values for math.max in GetSkillCastRange")
                    range = value1 or value2 or 0
                end
            else
                local specialValue = kv.AbilityValues[specialValueKey]
                -- 添加日志：打印获取到的特殊值
                self:log(string.format("Debug: Found special value: %s", 
                    type(specialValue) == "table" and tostring(specialValue.value) or tostring(specialValue)))
                
                if type(specialValue) == "table" and specialValue.value then
                    range = tonumber(specialValue.value) or 0
                else
                    -- 处理多级技能的情况
                    if type(specialValue) == "string" then
                        local ranges = {}
                        for value in string.gmatch(specialValue, "%d+") do
                            table.insert(ranges, tonumber(value))
                        end
                        local currentLevel = ability:GetLevel()
                        range = ranges[currentLevel] or ranges[#ranges]
                        -- 添加日志：打印多级技能的处理结果
                        self:log(string.format("Debug: Processing multi-level range: level %d, selected range %d", 
                            currentLevel, range))
                    else
                        range = tonumber(specialValue) or 0
                    end
                end
            end
            
            -- 添加日志：打印最终计算的range值
            self:log(string.format("Debug: Final calculated range = %s", tostring(range)))
        end
    
        -- 如果特殊值没有找到，则按原有逻辑查找
        if range == 0 then
            -- 检查AbilityValues中的range
            if kv.AbilityValues and kv.AbilityValues.range then
                if type(kv.AbilityValues.range) == "table" then
                    if kv.AbilityValues.range.value then
                        range = kv.AbilityValues.range.value
                    end
                else
                    range = kv.AbilityValues.range
                end
            -- 如果没有找到range，检查AbilityCastRange
            elseif kv.AbilityValues and kv.AbilityValues.AbilityCastRange then
                if type(kv.AbilityValues.AbilityCastRange) == "table" then
                    range = kv.AbilityValues.AbilityCastRange.value or 0
                else
                    range = kv.AbilityValues.AbilityCastRange or 0
                end
            -- 最后检查顶层的AbilityCastRange
            elseif kv.AbilityCastRange then
                if type(kv.AbilityCastRange) == "table" then
                    range = kv.AbilityCastRange.value or 0
                else
                    range = kv.AbilityCastRange or 0
                end
            end
        end
    
        -- 处理多级技能的情况
        if type(range) == "string" then
            local ranges = {}
            for value in string.gmatch(range, "%d+") do
                table.insert(ranges, tonumber(value))
            end
            local currentLevel = ability:GetLevel()
            range = ranges[currentLevel] or ranges[#ranges]
        end
    
        -- 检查是否有 length_buffer
        if kv.length_buffer then
            additionalLength = tonumber(kv.length_buffer) or 0
        end
    
        -- 检查是否有碎片升级
        local caster = ability:GetCaster()
        if caster:HasModifier("modifier_item_aghanims_shard") then
            local shardBonus = 0
            if kv.AbilityValues and kv.AbilityValues.range and type(kv.AbilityValues.range) == "table" then
                shardBonus = tonumber(string.match(kv.AbilityValues.range.special_bonus_shard or "0", "[%+%-]?%d+")) or 0
            end
            if shardBonus == 0 then
                shardBonus = tonumber(string.match(kv.AbilityValues and kv.AbilityValues.AbilityCastRange and kv.AbilityValues.AbilityCastRange.special_bonus_shard or "0", "[%+%-]?%d+")) or
                             tonumber(string.match(kv.AbilityCastRange and kv.AbilityCastRange.special_bonus_shard or "0", "[%+%-]?%d+")) or
                             150
            end
            range = range + shardBonus
        end
    
        -- 动态检查特殊天赋
        local talentSource = (kv.AbilityValues and kv.AbilityValues.range) or
                             (kv.AbilityValues and kv.AbilityValues.AbilityCastRange) or
                             kv.AbilityCastRange
        if type(talentSource) == "table" then
            for key, value in pairs(talentSource) do
                if string.find(key, "special_bonus_unique_") then
                    local talentName = key
                    if caster:HasAbility(talentName) then
                        local talent = caster:FindAbilityByName(talentName)
                        if talent and talent:GetLevel() > 0 then
                            local bonusRange = tonumber(string.match(value, "[%+%-]?%d+"))
                            if bonusRange then
                                range = range + bonusRange
                            end
                        end
                    end
                end
            end
        end
    
        castRange = range + additionalLength
    end
    -- 检查特定技能的固定范围
    if self.skillCastRanges[abilityName] then
        castRange = self.skillCastRanges[abilityName]
    end

    -- 获取额外的施法距离加成
    local bonusRange = entity:GetCastRangeBonus()

    -- 某些特殊技能可能不应该受到施法距离加成的影响
    local ignoreBonus = {
        spirit_breaker_charge_of_darkness = true,
        spectre_reality = true,
        spectre_haunt_single = true,
        storm_spirit_ball_lightning = true,
        monkey_king_tree_dance = true,
        ancient_apparition_ice_blast = true,
        -- 可以根据需要添加更多不受影响的技能
    }

    -- 如果技能不在忽略列表中，则加上额外的施法距离
    if not ignoreBonus[abilityName] then
        castRange = castRange + bonusRange
    end

    -- 特殊处理 lich_chain_frost 技能
    if abilityName == "lich_chain_frost" then
        local enemiesInRange = FindUnitsInRadius(
            entity:GetTeamNumber(),
            entity:GetOrigin(),
            nil,
            castRange,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
            FIND_ANY_ORDER,
            false
        )

        if #enemiesInRange == 0 then
            local iceSpires = FindUnitsInRadius(
                entity:GetTeamNumber(),
                entity:GetOrigin(),
                nil,
                castRange,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                FIND_ANY_ORDER,
                false
            )

            for _, spire in pairs(iceSpires) do
                if spire:GetUnitName() == "npc_dota_lich_ice_spire" and spire:IsMagicImmune() then
                    local enemiesNearSpire = FindUnitsInRadius(
                        entity:GetTeamNumber(),
                        spire:GetOrigin(),
                        nil,
                        600,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
                        FIND_ANY_ORDER,
                        false
                    )

                    if #enemiesNearSpire > 0 then
                        return 9999
                    end
                end
            end
        end
    elseif abilityName == "storm_spirit_electric_vortex" then
        -- 特殊处理 storm_spirit_electric_vortex
        if entity:HasModifier("modifier_storm_spirit_ball_lightning") then
            castRange = castRange + 400
            self:log("storm_spirit_electric_vortex 的施法距离增加400，现在为：" .. castRange)
        end

    elseif abilityName == "monkey_king_boundless_strike" then
        
        if self:containsStrategy(self.hero_strategy, "先开大") then
            castRange = 675
        end
    elseif abilityName == "luna_eclipse" then
        
        if self:containsStrategy(self.hero_strategy, "大招确保罩到自己") then
            castRange = 675
        end
    elseif abilityName == "drow_ranger_glacier" then
        
        if self:containsStrategy(self.hero_strategy, "出门放冰川") then
            castRange = 2000
        end
    elseif abilityName == "drow_ranger_wave_of_silence" then
        
        if self:containsStrategy(self.global_strategy, "防守策略") then
            castRange = 500
        end
    elseif abilityName == "tiny_avalanche" then
        
        if self:containsStrategy(self.hero_strategy, "原地山崩") then
            castRange = 100
        end
    elseif abilityName == "arc_warden_tempest_double" then
        
        if self:containsStrategy(self.hero_strategy, "分身放身边") then
            castRange = 100
        end

    elseif abilityName == "bristleback_bristleback" then
        
        if self:containsStrategy(self.hero_strategy, "提前转身") then
            castRange = 1000
        end
    elseif abilityName == "kez_shodo_sai" then
        
        if self:containsStrategy(self.hero_strategy, "优先盾反") then
            castRange = 1500
        end
    elseif abilityName == "mars_spear" then 
            -- 获取大招技能
        local arena = entity:FindAbilityByName("mars_arena_of_blood")
        -- 检查大招是否可用
        if arena and self:IsSkillReady(arena) then
            -- 施法距离减少100
            castRange = castRange - 300
        end
        
        if self:containsStrategy(self.hero_strategy, "先大后矛") then
            self.specificRadius.mars_spear = 620
        end

    elseif abilityName == "earthshaker_fissure" and self:containsStrategy(self.hero_strategy, "沟壑连招") then
        -- 获取跳跃技能
        local totemAbility = entity:FindAbilityByName("earthshaker_enchant_totem")
        if totemAbility then
            local totemCastRange = self:GetSkillCastRange(entity, totemAbility)
            local totemAoeRadius = self:GetSkillAoeRadius(totemAbility)
            castRange = totemCastRange + totemAoeRadius + 1
        end



    elseif abilityName == "earth_spirit_rolling_boulder" then
        local stoneCallerAbility = entity:FindAbilityByName("earth_spirit_stone_caller")
        local stone_charger = 0
    
        if stoneCallerAbility then
            if entity:GetHeroFacetID() ~= 2 then
                stone_charger = stoneCallerAbility:GetCurrentAbilityCharges()
            else
                if stoneCallerAbility:IsFullyCastable() then
                    stone_charger = 1
                else 
                    stone_charger = 0
                end
            end
    
            if stone_charger > 0 then
                castRange = 1900
            else
                local entityPos = entity:GetAbsOrigin()
                local targetPos = self.target:GetAbsOrigin()
                local direction = (targetPos - entityPos):Normalized()
                local endPoint = entityPos + direction * 950
                local width = 180
            
                local unitsInLine = FindUnitsInLine(
                    entity:GetTeamNumber(),
                    entityPos,
                    endPoint,
                    nil,
                    width,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE
                )
            
                local validStoneFound = false
                for _, unit in pairs(unitsInLine) do
                    if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                        validStoneFound = true
                        break
                    end
                end
            
                if validStoneFound then
                    castRange = 1900
                end
            end
        end

    elseif abilityName == "earth_spirit_boulder_smash" then
        local stoneCallerAbility = entity:FindAbilityByName("earth_spirit_stone_caller")
        local stone_charger = 0
    
        if stoneCallerAbility then
            if entity:GetHeroFacetID() ~= 2 then
                stone_charger = stoneCallerAbility:GetCurrentAbilityCharges()
            else
                if stoneCallerAbility:IsFullyCastable() then
                    stone_charger = 1
                else 
                    stone_charger = 0
                end
            end
    
            if stone_charger > 0 then
                castRange = 2000
            else
                local searchRadius = 200
                
                local unitsAround = FindUnitsInRadius(
                    entity:GetTeamNumber(),
                    entity:GetAbsOrigin(),
                    nil,
                    searchRadius,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                    FIND_ANY_ORDER,
                    false
                )
            
                local validStoneFound = false
                for _, unit in pairs(unitsAround) do
                    if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                        validStoneFound = true
                        break
                    end
                end
            
                if validStoneFound then
                    castRange = 2000
                    self:log("找到有效的石头或被石化单位，施法距离设置为2000")
                else
                    self:log("未找到有效的石头或被石化单位，施法距离保持不变")
                end
            end
        end
    elseif abilityName == "earth_spirit_geomagnetic_grip" then
        local stoneCallerAbility = entity:FindAbilityByName("earth_spirit_stone_caller")
        local stone_charger = 0
    
        if stoneCallerAbility then
            if entity:GetHeroFacetID() ~= 2 then
                stone_charger = stoneCallerAbility:GetCurrentAbilityCharges()
            else
                if stoneCallerAbility:IsFullyCastable() then
                    stone_charger = 1
                else 
                    stone_charger = 0
                end
            end
    
            local enemyPos = self.target:GetAbsOrigin()
            local heroPos = entity:GetAbsOrigin()
            local direction = (enemyPos - heroPos):Normalized()
    
            -- 检查敌人周围150码是否有石头
            local enemyNearbyStone = FindUnitsInRadius(
                entity:GetTeamNumber(),
                enemyPos,
                nil,
                150,
                DOTA_UNIT_TARGET_TEAM_BOTH,
                DOTA_UNIT_TARGET_ALL,
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                FIND_ANY_ORDER,
                false
            )
            
            local stoneNearEnemy = false
            for _, unit in pairs(enemyNearbyStone) do
                if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                    stoneNearEnemy = true
                    break
                end
            end
    
            -- 如果敌人周围没有石头，检查直线区域
            if not stoneNearEnemy then
                local lineStart = enemyPos
                local lineEnd = enemyPos + direction * (castRange - (enemyPos - heroPos):Length2D())
                local lineWidth = 200
                
                local unitsInLine = FindUnitsInLine(
                    entity:GetTeamNumber(),
                    lineStart,
                    lineEnd,
                    nil,
                    lineWidth,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE
                )
                
                local stoneInLine = false
                for _, unit in pairs(unitsInLine) do
                    if unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                        stoneInLine = true
                        break
                    end
                end
    
                -- 如果直线区域内也没有石头，并且有可用的石头召唤次数，设置castRange为石头召唤技能的施法距离
                if not stoneInLine and stone_charger > 0 then
                    castRange = self:GetSkillCastRange(entity, stoneCallerAbility)
                    self:log("未找到有效的石头或被石化单位，施法距离设置为石头召唤技能的施法距离")
                else
                    self:log("找到有效的石头或被石化单位，或没有可用的石头召唤次数，施法距离保持不变")
                end
            else
                self:log("敌人周围找到有效的石头或被石化单位，施法距离保持不变")
            end
        else
            self:log("未找到石头召唨技能，施法距离保持不变")
        end




    elseif abilityName == "puck_waning_rift" then
        if kv.AbilityValues and kv.AbilityValues.max_distance then
            if type(kv.AbilityValues.max_distance) == "table" then
                castRange = tonumber(kv.AbilityValues.max_distance.value) or 0
                -- 检查是否有特殊天赋
                local talentBonus = tonumber(string.match(kv.AbilityValues.max_distance.special_bonus_unique_puck_rift_radius or "0", "[%+%-]?%d+")) or 0
                if talentBonus ~= 0 then
                    local talentName = "special_bonus_unique_puck_rift_radius"
                    if entity:HasAbility(talentName) then
                        local talent = entity:FindAbilityByName(talentName)
                        if talent and talent:GetLevel() > 0 then
                            castRange = castRange + talentBonus
                        end
                    end
                end
            else
                castRange = tonumber(kv.AbilityValues.max_distance) or 0
            end
        end
    end
    return castRange
end