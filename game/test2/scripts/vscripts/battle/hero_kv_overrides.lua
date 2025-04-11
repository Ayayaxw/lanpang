Main.heroListKV = LoadKeyValues('scripts/npc/npc_heroes.txt')
Main.unitListKV = LoadKeyValues('scripts/npc/npc_units.txt')
Main.npc_abilities = LoadKeyValues('scripts/npc/npc_abilities.txt')

-- 打印npc_abilities表的完整内容
function DeepPrintTable(t, indent, done)
    -- 避免无限递归
    done = done or {}
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    
    if type(t) ~= "table" then
        print(prefix .. tostring(t))
        return
    end
    
    if done[t] then
        print(prefix .. "已打印过的表")
        return
    end
    done[t] = true
    
    -- 获取所有键并排序，使输出更有组织性
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        if type(a) == "number" and type(b) == "number" then
            return a < b
        else
            return tostring(a) < tostring(b)
        end
    end)
    
    print(prefix .. "{")
    for _, k in ipairs(keys) do
        local v = t[k]
        if type(v) == "table" then
            print(prefix .. "  " .. tostring(k) .. " = ")
            DeepPrintTable(v, indent + 2, done)
        else
            print(prefix .. "  " .. tostring(k) .. " = " .. tostring(v))
        end
    end
    print(prefix .. "}")
end

-- 创建一个打印技能表的函数，让控制台输出更清晰
function PrintAbilitiesTable(abilities_table)
    print("========= 打印完整的npc_abilities表 ==========")
    print("总技能数量: " .. GetTableLength(abilities_table))
    print("=============================================")
    
    -- 按字母顺序打印每个技能
    local ability_names = {}
    for ability_name in pairs(abilities_table) do
        table.insert(ability_names, ability_name)
    end
    table.sort(ability_names)
    
    for _, ability_name in ipairs(ability_names) do
        local ability_data = abilities_table[ability_name]
        print("\n技能: " .. ability_name)
        print("------------------------------------")
        DeepPrintTable(ability_data, 1)
        print("------------------------------------")
    end
    
    print("\n========= npc_abilities表打印完成 ==========")
end

-- 计算表中元素数量的辅助函数
function GetTableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- 打印npc_abilities表
-- print("开始打印npc_abilities表...")
-- PrintAbilitiesTable(Main.npc_abilities)
-- print("npc_abilities表打印完成")

Main.abilityListKV = {}
Main.originAbility = {}
Main.original_values = {}

-- 初始化必要的表
Main.heroAbilities = Main.heroAbilities or {}
Main.originAbility = Main.originAbility or {}
-- 加载通用技能
Main.genericAbilities = {}

-- 直接从英雄文件夹加载英雄及其技能
if Main.heroListKV then
    for hero_name, hero_data in pairs(Main.heroListKV) do
        -- 检查 hero_name 是否真的是一个英雄名
        if type(hero_data) == "table" and hero_name:sub(1, 14) == "npc_dota_hero_" and hero_name ~= "npc_dota_hero_base" then
            Main.heroAbilities[hero_name] = {}
            Main.originAbility[hero_name] = {}
            -- 从英雄文件夹加载
            local hero_file_path = 'scripts/npc/heroes/' .. hero_name .. '.txt'

            
            local hero_data = LoadKeyValues(hero_file_path)
            
            if hero_data then

                local ability_count = 0
                
                for ability_name, ability_data in pairs(hero_data) do
                    if type(ability_data) == "table" then
                        Main.heroAbilities[hero_name][ability_name] = ability_data
                        Main.originAbility[hero_name][ability_name] = true
                        ability_count = ability_count + 1

                    end
                end

            else

            end
        else

        end
    end

    local total_heroes = 0
    local total_abilities = 0
    
    for hero_name, abilities in pairs(Main.heroAbilities) do
        total_heroes = total_heroes + 1
        local hero_ability_count = 0
        

        for ability_name, _ in pairs(abilities) do
            hero_ability_count = hero_ability_count + 1
            total_abilities = total_abilities + 1

        end

    end
    
else

end

-- print("开始打印npc_abilities表...")
-- PrintAbilitiesTable(Main.heroAbilities)
-- print("npc_abilities表打印完成")


function Main:GetOriginalAbilityValue(hero_name, ability_name)
    -- 先检查英雄特定技能
    local ability = self.heroAbilities[hero_name] and self.heroAbilities[hero_name][ability_name]
    -- 如果在英雄特定技能中找不到，则检查通用技能
    if not ability then
        ability = self.genericAbilities[ability_name]
    end
    
    if ability then
        local flat_data = {}
        -- 提取特殊值
        if ability.AbilitySpecial then
            for _, special in pairs(ability.AbilitySpecial) do
                for k, v in pairs(special) do
                    if k ~= "var_type" then
                        flat_data[k] = v
                    end
                end
            end
        end
        -- 提取其他数值属性
        for k, v in pairs(ability) do
            if type(v) == 'number' or (type(v) == 'string' and v:match("^%d+%.?%d*[%s%d%.]*$")) then
                flat_data[k] = v
            end
        end
        return flat_data
    end
    return nil
end


    

function Main:RestoreOriginalValues()
    -- 恢复所有记录过的原始值
    for key, original_data in pairs(self.original_values) do
        CustomNetTables:SetTableValue("edit_kv", key, original_data)
    end
    
    -- 打印恢复后的状态
    print("已恢复以下键值的原始数据：")
    for key, _ in pairs(self.original_values) do
        print(key)
        local current_data = CustomNetTables:GetTableValue("edit_kv", key)
        if current_data then
            DeepPrintTable(current_data)
        end
    end
end

function Main:UpdateAbilityModifiers(ability_modifiers, debug_print)
    debug_print = debug_print or false

    -- 处理每个外层键
    for key, data in pairs(ability_modifiers) do
        -- 判断是否为英雄键（格式为npc_dota_hero_xxx）
        if string.match(key, "^npc_dota_hero_") then
            -- 处理指定英雄的技能
            local hero_name = key
            for ability_name, ability_data in pairs(data) do
                local ability_key = hero_name .. "_" .. ability_name
                -- 保存原始数据
                if not self.original_values[ability_key] then
                    local original_data = self:GetOriginalAbilityValue(hero_name, ability_name)
                    if original_data then
                        self.original_values[ability_key] = original_data
                    end
                end
                -- 设置新的技能数据
                if ability_data.AbilityValues then
                    if debug_print then
                        print(string.format("更新英雄技能: %s", ability_key))
                        DeepPrintTable(ability_data.AbilityValues)
                    end
                    CustomNetTables:SetTableValue("edit_kv", ability_key, { AbilityValues = ability_data.AbilityValues })
                end
            end
        else
            -- 处理全局技能（应用到所有英雄）
            local ability_name = key
            local global_key = "*_" .. ability_name
            -- 保存全局技能的原始数据（需确保GetOriginalAbilityValue支持全局查询）
            if not self.original_values[global_key] then
                local original_data = self:GetOriginalAbilityValue(nil, ability_name) -- 假设支持全局查询
                if original_data then
                    self.original_values[global_key] = original_data
                end
            end
            -- 设置全局技能数据
            if data.AbilityValues then
                if debug_print then
                    print(string.format("设置全局技能: %s", global_key))
                    DeepPrintTable(data.AbilityValues)
                end
                CustomNetTables:SetTableValue("edit_kv", global_key, { AbilityValues = data.AbilityValues })
            end
        end
    end

    -- 打印NetTable内容（调试用）
    local function PrintEditKvContents()
        local found_data = false
        for key, _ in pairs(ability_modifiers) do
            if string.match(key, "^npc_dota_hero_") then
                for ability_name, _ in pairs(ability_modifiers[key]) do
                    local specific_key = key .. "_" .. ability_name
                    local data = CustomNetTables:GetTableValue("edit_kv", specific_key)
                    if data then
                        found_data = true
                        if debug_print then
                            print("英雄技能数据 "..specific_key..":")
                            DeepPrintTable(data)
                        end
                    end
                end
            else
                local global_key = "*_" .. key
                local data = CustomNetTables:GetTableValue("edit_kv", global_key)
                if data then
                    found_data = true
                    if debug_print then
                        print("全局技能数据 "..global_key..":")
                        DeepPrintTable(data)
                    end
                end
            end
        end
        if not found_data and debug_print then
            print("edit_kv 表中未找到数据")
        end
    end
    PrintEditKvContents()
end

function Main:AmplifyAbilityAOE(multiplier)
    multiplier = multiplier or 10  -- 默认10倍
    local all_updates = {} -- 收集所有更新

    local function processAbilityValues(ability_name, ability_data)
        if not ability_data or type(ability_data) ~= 'table' then 
            return 
        end
        
        local modified_values = {
            AbilityValues = {}
        }
    
        -- 打印dragon_tail所有原始数据
        if ability_name == "queenofpain_shadow_strike" then
            print("\n=== queenofpain_shadow_strike修改前的所有数据 ===")
            for field, value in pairs(ability_data.AbilityValues) do
                print(string.format("\n字段: %s", field))
                if type(value) == "table" then
                    DeepPrintTable(value)
                else
                    print(tostring(value))
                end
            end
            print("================================")
        end

        if ability_data.AbilityValues then
            for k, v in pairs(ability_data.AbilityValues) do
                if type(v) == 'table' and v.affected_by_aoe_increase then
                    if v.affected_by_aoe_increase == 1 or v.affected_by_aoe_increase == "1" then
                        print(string.format("\n处理AOE字段: %s", k))
                        
                        modified_values.AbilityValues[k] = table.deepcopy(v)
                        
                        for field, field_value in pairs(v) do
                            if field ~= "affected_by_aoe_increase" then
                                print(string.format("正在处理: %s = %s (%s)", 
                                    field, tostring(field_value), type(field_value)))
                                
                                if type(field_value) == "string" then
                                    if field_value:sub(1,1) == "=" then
                                        local num = tonumber(field_value:sub(2))
                                        if num then
                                            modified_values.AbilityValues[k][field] = "=" .. (num * multiplier)
                                            print(string.format("修改后: %s", modified_values.AbilityValues[k][field]))
                                        end
                                    elseif field_value:find("%s") then
                                        local numbers = {}
                                        for num in field_value:gmatch("-?%d+") do
                                            table.insert(numbers, tonumber(num) * multiplier)
                                        end
                                        if #numbers > 0 then
                                            modified_values.AbilityValues[k][field] = table.concat(numbers, " ")
                                            print(string.format("修改后: %s", modified_values.AbilityValues[k][field]))
                                        end
                                    else
                                        local num = tonumber(field_value)
                                        if num then
                                            modified_values.AbilityValues[k][field] = num * multiplier
                                            print(string.format("修改后: %s", tostring(modified_values.AbilityValues[k][field])))
                                        end
                                    end
                                elseif type(field_value) == "number" then
                                    modified_values.AbilityValues[k][field] = field_value * multiplier
                                    print(string.format("修改后: %s", tostring(modified_values.AbilityValues[k][field])))
                                end
                            end
                        end
                    end
                end
            end
        end

        -- 打印dragon_tail最终修改后的所有数据
        if ability_name == "queenofpain_shadow_strike" then
            print("\n=== queenofpain_shadow_strike修改后的所有数据 ===")
            if modified_values and modified_values.AbilityValues then
                for field, value in pairs(modified_values.AbilityValues) do
                    print(string.format("\n字段: %s", field))
                    if type(value) == "table" then
                        DeepPrintTable(value)
                    else
                        print(tostring(value))
                    end
                end
            else
                print("没有生成修改后的数据")
            end
            print("================================")
        end
    
        return modified_values
    end

    for hero_name, hero_abilities in pairs(Main.heroAbilities) do
        all_updates[hero_name] = {}
        
        for ability_name, ability_data in pairs(hero_abilities) do
            if type(ability_data) == 'table' then
                local modified_values = processAbilityValues(ability_name, ability_data)
                if modified_values and next(modified_values.AbilityValues) then
                    all_updates[hero_name][ability_name] = modified_values
                end
            end
        end
    end
    
    if next(all_updates) then
        self:UpdateAbilityModifiers(all_updates)
    end
end

function Main:StandardizeAbilityPercentages()
    local all_updates = {} -- 收集所有更新
    
    -- 特殊字段表，包含那些名称中没有百分比特征但实际是百分比的字段
    local special_percentage_fields = {
        ["obsidian_destroyer_astral_imprisonment"] = {"mana_capacity_steal"},
        ["phantom_assassin_immaterial"] = {"evasion_base"},
        ["phantom_assassin_coup_de_grace"] = {"crit_chance","dagger_crit_chance"},

        ["antimage_mana_break"] = {"mana_per_hit_pct"}, 
        ["omniknight_hammer_of_purity"] = {"base_damage"},
        -- ["omniknight_degen_aura"] = {"bonus_damage_per_stack","speed_bonus"},
        ["omniknight_guardian_angel"] = {"special_bonus_scepter"},
        ["juggernaut_blade_dance"] = {"blade_dance_lifesteal"},
        ["juggernaut_healing_ward"] = {"healing_ward_heal_amount"},
        ["skywrath_mage_ancient_seal"] = {"resist_debuff"},
        ["skywrath_mage_arcane_bolt"] = {"int_multiplier"},
        ["abaddon_death_coil"] = {"self_damage"},
        ["phoenix_blinding_sun"] = {"blind_per_second"},
        ["kez_echo_slash"] = {"katana_echo_damage"},
        ["kez_falcon_rush"] = {"attack_speed_factor"},
        ["kez_switch_weapons"] = {"katana_bonus_damage","katana_swap_bonus_damage"},
        ["pugna_life_drain"] = {"spell_amp_drain_max","spell_amp_drain_rate"},
        ["dazzle_nothl_projection"] = {"shadow_wave_cdr"},
        ["ogre_magi_unrefined_fireblast"] = {"scepter_mana_cost"},
        ["special_bonus_unique_ogre_magi_3"] = {"value"},
        ["nevermore_requiem"] = {"requiem_reduction_mres","requiem_reduction_ms"},
        ["invoker_sun_strike"] = {"cataclysm_damage_pct"},
        ["faceless_void_time_zone"] = {"bonus_move_speed","bonus_cast_speed","bonus_turn_speed","bonus_projectile_speed","cooldown_acceleration"},
        ["medusa_mana_shield"] = {"absorption_pct"},
        ["medusa_mystic_snake"] = {"snake_scale"},
        ["pangolier_swashbuckle"] = {"attack_damage"},
        ["obsidian_destroyer_equilibrium"] = {"mana_restore","mana_increase", "scepter_barrier_threshold","scepter_max_mana_barrier_pct"},
        ["obsidian_destroyer_ominous_discernment"] = {"bonus_max_mana_per_int"},
        ["ursa_enrage"] = {"damage_increase"},
        ["ember_spirit_searing_chains"] = {"non_damage_per_second"},
        ["sven_great_cleave"] = {"great_cleave_damage"},
        ["rubick_fade_bolt"] = {"attack_damage_reduction"},
        ["primal_beast_trample"] = {"attack_damage"},
        ["abyssal_underlord_firestorm"] = {"burn_damage","shard_wave_interval_reduction"},
        ["necrolyte_ghost_shroud"] = {"movement_speed","heal_bonus","bonus_damage"},
        ["life_stealer_ghoul_frenzy"] = {"movement_speed_bonus"},
        ["phantom_lancer_juxtapose"] = {"tooltip_illusion_damage"},
        ["phantom_lancer_spirit_lance"] = {"scepter_bonus_illusion_damage", "illusion_lance_damage_pct" , "tooltip_illusion_damage"},
        ["shredder_chakram"] = {"slow"},

        ["venomancer_venomous_gale"] = {"movement_slow"},
        ["venomancer_poison_sting"] = {"movement_speed"},
        ["special_bonus_unique_witch_doctor_2"] = {"value"},
        ["witch_doctor_maledict"] = {"bonus_damage"},
        ["huskar_berserkers_blood"] = {"hp_threshold_max"},
        ["huskar_burning_spear"] = {"health_cost","max_health_cost","burn_damage_max_pct"},
        ["sven_warcry"] = {"movespeed"},
        ["kunkka_tidebringer"] = {"cleave_damage"},
        ["kunkka_admirals_rum"] = {"damage_threshold","ghostship_absorb"},
        ["kunkka_ghostship"] = {"ghostship_absorb","movespeed_bonus"},
        ["dragon_knight_elder_dragon_form"] = {"wyrms_wrath_bonus_tooltip"},
        ["tiny_grow"] = {"attack_speed_reduction"},
        ["drow_ranger_frost_arrows"] = {"frost_arrows_movement_speed"},
        ["kez_shadowhawk_passive"] = {"mark_trigger_cd_reduction"},
        ["phantom_assassin_stifling_dagger"] = {"dagger_secondary_reduce","attack_factor","attack_factor_tooltip","move_slow"},


        ["elder_titan_momentum"] = {"attack_speed_from_movespeed"},

        
        
        -- 可以在这里添加更多特殊情况
    }   

    -- 不做任何修改的字段表，即使它们看起来像百分比字段
    local exclude_from_modification_fields = {
        ["ember_spirit_searing_chains"] = {"damage_per_second"},
        ["zuus_static_field"] = {"damage_health_pct", "damage_health_pct_max_close", "damage_health_pct_min_close","distance_threshold_min","distance_threshold_max"},
        ["special_bonus_unique_ursa_4"] = {"value"},
        ["phantom_lancer_juxtapose"] = {"illusion_damage_in_pct", "tooltip_total_illusion_damage_in_pct"},
        ["sven_wrath_of_god"] = {"bonus_damage_per_str"},
        ["nevermore_requiem"] = {"requiem_damage_pct_scepter"},
        ["sandking_epicenter"] = {"epicenter_pulses","epicenter_damage","epicenter_radius_base","epicenter_radius_increment","scepter_explosion_radius_pct"},
        
        -- 可以在这里添加更多不需要修改的字段
    }

    -- 完全跳过处理的技能列表
    local skip_abilities = {
        "zuus_static_field",


        -- 可以在这里添加更多需要跳过的技能
    }

    local function isPercentageField(field_name)
        return field_name:find("pct") or field_name:find("percent") or 
               field_name:find("chance") or field_name:find("perc") or
                field_name:find("resistance") or field_name:find("magic_resist") or 
                field_name:find("damage_increase") or field_name:find("crit_mult") or 
                 field_name:find("bonus_movement_speed") or field_name:find("strength_damage") or
                 field_name:find("health_damage") or field_name:find("mana_damage") or
                 field_name:find("bonus_ms") or field_name:find("movement_bonus") or
                 field_name:find("illusion_outgoing") or field_name:find("illusion_incoming") or
                 field_name:find("strength_mult") or field_name:find("agility_mult") or
                 field_name:find("intellect_mult") or field_name:find("times") or
                 field_name:find("_amp") or field_name:find("per_mana") or
                 field_name:find("damage_reduction") or field_name:find("per_str") or
                 field_name:find("cleave_damage") or field_name:find("movespeed_bonus")
                 
    end 

    -- 辅助函数：标准化单个百分比值
    local function standardizePercentValue(value, prefix)
        prefix = prefix or ""
        
        -- 如果值为0，忽略不处理
        if value == 0 or value == "0" or value == "=0" or value == "+0" then
            print(string.format("忽略特殊值: %s", tostring(value)))
            return value
        end
        
        local num = value
        local is_string = false
        local is_negative = false
        local original_value = value
        
        -- 处理字符串类型的值
        if type(value) == "string" then
            is_string = true
            if value:sub(1,1) == "=" then
                num = tonumber(value:sub(2))
                prefix = "="
                if num and num < 0 then
                    is_negative = true
                    num = math.abs(num)
                end
            elseif value:sub(1,1) == "+" then
                num = tonumber(value:sub(2))
                prefix = "+"
            elseif value:sub(1,1) == "-" then
                num = tonumber(value:sub(1))
                if num and num < 0 then
                    is_negative = true
                    num = math.abs(num)
                end
            else
                num = tonumber(value)
                if num and num < 0 then
                    is_negative = true
                    num = math.abs(num)
                end
            end
        elseif type(value) == "number" then
            if value < 0 then
                is_negative = true
                num = math.abs(value)
            end
        end
        
        -- 如果无法转换为数字，则返回原值
        if not num then return value end
        
        -- 根据数值范围标准化
        local result
        if num >= 100 then
            -- 大于等于100的值保持原样
            if is_string then
                -- 对于字符串，保留原始前缀和数值
                result = original_value
            else
                -- 对于数字，直接返回原始值
                return original_value
            end
        elseif num < 1 then
            result = is_string and (prefix .. "1") or 1
        else
            result = is_string and (prefix .. "100") or 100
        end
        
        -- 如果原值是负数，确保结果也是负数
        if is_negative and num < 100 then  -- 只对小于100的值进行负号处理
            if is_string then
                -- 对于字符串，需要处理前缀
                if prefix == "=" then
                    return "=-" .. result:sub(2)
                else
                    return "-" .. result
                end
            else
                -- 对于数字，直接添加负号
                return -result
            end
        end
        
        return result
    end
    
    -- 辅助函数：处理空格分隔的多值字符串
    local function standardizeMultiValues(value_str)
        local result = {}
        
        -- 处理带前缀的数值序列（如"=5 =6 =7 =8"或"+2.5 +3.0 +3.5"）
        if value_str:find("=") or value_str:find("%+") then
            -- 匹配带前缀的数值
            for prefix, num_str in value_str:gmatch("([=+%-])(%-?%d+%.?%d*)") do
                local num = tonumber(num_str)
                if num then
                    local is_negative = num < 0
                    num = math.abs(num)
                    
                    local standardized_value
                    if num >= 100 then
                        -- 大于等于100的值保持原样
                        standardized_value = num_str
                        table.insert(result, prefix .. standardized_value)
                        goto continue
                    elseif num < 1 then
                        standardized_value = "1"
                    else
                        standardized_value = "100"
                    end
                    
                    -- 如果原值是负数，添加负号到标准化值
                    if is_negative then
                        standardized_value = "-" .. standardized_value
                    end
                    
                    -- 添加原始前缀
                    table.insert(result, prefix .. standardized_value)
                    
                    ::continue::
                end
            end
            
            if #result > 0 then
                return table.concat(result, " ")
            end
        else
            -- 处理普通数值序列（没有前缀的情况）
            for num_str in value_str:gmatch("(%-?%d+%.?%d*)") do
                local num = tonumber(num_str)
                if num then
                    local is_negative = num < 0
                    num = math.abs(num)
                    
                    local standardized_value
                    if num >= 100 then
                        -- 大于等于100的值保持原样
                        standardized_value = num_str
                        table.insert(result, standardized_value)
                        goto continue
                    elseif num < 1 then
                        standardized_value = "1"
                    else
                        standardized_value = "100"
                    end
                    
                    -- 如果原值是负数，添加负号
                    if is_negative then
                        standardized_value = "-" .. standardized_value
                    end
                    
                    table.insert(result, standardized_value)
                    
                    ::continue::
                end
            end
            
            if #result > 0 then
                return table.concat(result, " ")
            end
        end
        
        return value_str
    end

    local function processAbilityValues(ability_name, ability_data)
        if not ability_data or type(ability_data) ~= 'table' then 
            return 
        end
        
        -- 检查技能是否在跳过列表中
        for _, skip_ability in ipairs(skip_abilities) do
            if ability_name == skip_ability then
                print(string.format("\n完全跳过处理技能: %s", ability_name))
                return nil
            end
        end
        
        local modified_values = {
            AbilityValues = {}
        }
    
        -- 打印技能修改前的数据
        if ability_name == "obsidian_destroyer_arcane_orb" then
            print("\n=== " .. ability_name .. "修改前的所有数据 ===")
            if ability_data.AbilityValues then
                for field, value in pairs(ability_data.AbilityValues) do
                    print(string.format("\n字段: %s", field))
                    if type(value) == "table" then
                        DeepPrintTable(value)
                    else
                        print(tostring(value))
                    end
                end
            end
            print("================================")
        end

        if ability_data.AbilityValues then
            for k, v in pairs(ability_data.AbilityValues) do
                -- 检查字段名是否包含百分比特征或在特殊列表中
                local is_special_field = false
                local is_excluded_field = false
                
                if special_percentage_fields[ability_name] then
                    for _, special_field in ipairs(special_percentage_fields[ability_name]) do
                        if k == special_field then
                            is_special_field = true
                            break
                        end
                    end
                end
                
                -- 检查该字段是否在排除修改的列表中
                if exclude_from_modification_fields[ability_name] then
                    for _, excluded_field in ipairs(exclude_from_modification_fields[ability_name]) do
                        if k == excluded_field then
                            is_excluded_field = true
                            break
                        end
                    end
                end
                
                -- 如果字段在排除列表中，跳过处理
                if is_excluded_field then
                    print(string.format("\n跳过处理字段: %s (在排除列表中)", k))
                    -- 保留原始值，不做修改
                    if type(v) == 'table' then
                        modified_values.AbilityValues[k] = table.deepcopy(v)
                    else
                        modified_values.AbilityValues[k] = v
                    end
                elseif isPercentageField(k) or is_special_field then
                    print(string.format("\n处理百分比字段: %s", k))
                    
                    if type(v) == 'table' then
                        modified_values.AbilityValues[k] = table.deepcopy(v)
                        
                        for field, field_value in pairs(v) do
                            print(string.format("正在处理: %s = %s (%s)", 
                                field, tostring(field_value), type(field_value)))
                            
                            if type(field_value) == "string" then
                                if field_value:find("%s") then
                                    -- 处理空格分隔的多值
                                    modified_values.AbilityValues[k][field] = standardizeMultiValues(field_value)
                                    print(string.format("修改后: %s", modified_values.AbilityValues[k][field]))
                                else
                                    -- 处理单值
                                    modified_values.AbilityValues[k][field] = standardizePercentValue(field_value)
                                    print(string.format("修改后: %s", tostring(modified_values.AbilityValues[k][field])))
                                end
                            elseif type(field_value) == "number" then
                                modified_values.AbilityValues[k][field] = standardizePercentValue(field_value)
                                print(string.format("修改后: %s", tostring(modified_values.AbilityValues[k][field])))
                            end
                        end
                    else
                        -- 处理不是表的情况
                        print(string.format("正在处理非表值: %s = %s (%s)", 
                            k, tostring(v), type(v)))
                        
                        if type(v) == "string" then
                            if v:find("%s") then
                                modified_values.AbilityValues[k] = standardizeMultiValues(v)
                                print(string.format("修改后: %s", modified_values.AbilityValues[k]))
                            else
                                modified_values.AbilityValues[k] = standardizePercentValue(v)
                                print(string.format("修改后: %s", tostring(modified_values.AbilityValues[k])))
                            end
                        elseif type(v) == "number" then
                            modified_values.AbilityValues[k] = standardizePercentValue(v)
                            print(string.format("修改后: %s", tostring(modified_values.AbilityValues[k])))
                        end
                    end
                end
            end
        end

        -- 打印技能修改后的数据
        if ability_name == "obsidian_destroyer_arcane_orb" then
            print("\n=== " .. ability_name .. "修改后的所有数据 ===")
            if modified_values and modified_values.AbilityValues then
                for field, value in pairs(modified_values.AbilityValues) do
                    print(string.format("\n字段: %s", field))
                    if type(value) == "table" then
                        DeepPrintTable(value)
                    else
                        print(tostring(value))
                    end
                end
            else
                print("没有生成修改后的数据")
            end
            print("================================")
        end
    
        return modified_values
    end

    for hero_name, hero_abilities in pairs(Main.heroAbilities) do
        all_updates[hero_name] = {}
        
        for ability_name, ability_data in pairs(hero_abilities) do
            if type(ability_data) == 'table' then
                local modified_values = processAbilityValues(ability_name, ability_data)
                if modified_values and next(modified_values.AbilityValues) then
                    all_updates[hero_name][ability_name] = modified_values
                end
            end
        end
    end
    
    if next(all_updates) then
        self:UpdateAbilityModifiers(all_updates)
    end
end