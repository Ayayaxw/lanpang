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