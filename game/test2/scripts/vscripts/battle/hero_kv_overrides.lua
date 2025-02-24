
Main.heroListKV = LoadKeyValues('scripts/npc/npc_heroes.txt')
Main.unitListKV = LoadKeyValues('scripts/npc/npc_units.txt')

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

function Main:UpdateAbilityModifiers(ability_modifiers)
    for hero_name, hero_abilities in pairs(ability_modifiers) do
        for ability_name, ability_data in pairs(hero_abilities) do
            local key = hero_name .. "_" .. ability_name
            -- 如果这个键还没有记录过原始值
            if not self.original_values[key] then
                local original_data = self:GetOriginalAbilityValue(hero_name, ability_name)
                if original_data then
                    self.original_values[key] = original_data
                end
            end
        end
    end

    local function PrintEditKvContents()
        local found_data = false
        
        for hero_name, hero_abilities in pairs(ability_modifiers) do
            for ability_name, _ in pairs(hero_abilities) do
                local key = hero_name .. "_" .. ability_name
                local data = CustomNetTables:GetTableValue("edit_kv", key)
                if data then
                    found_data = true

                end
            end
        end
        
        if not found_data then
            print("edit_kv 表是空的或没有找到任何数据")
        end
    end

    -- 设置新数据
    for hero_name, hero_abilities in pairs(ability_modifiers) do
        for ability_name, ability_data in pairs(hero_abilities) do
            local ability_index = hero_name .. "_" .. ability_name
            
            -- 新建一个平坦的表，用于存储特殊值
            local flat_data = {}
            
            local function flattenAbilityData(data)
                -- Ensure 'data' is a table
                if type(data) ~= 'table' then
                    return
                end
                
                -- 处理 AbilityValues
                if data['AbilityValues'] and type(data['AbilityValues']) == 'table' then
                    for special_name, special_data in pairs(data['AbilityValues']) do
                        if type(special_data) == 'table' then
                            if special_data['value'] then
                                flat_data[special_name] = special_data['value']
                            end
                            -- If there are nested tables inside special_data, recursively process them
                            flattenAbilityData(special_data)
                        else
                            -- Handle the case where special_data is not a table
                            -- Uncomment for debugging
                            -- print("Warning: Expected 'special_data' to be a table, got " .. type(special_data))
                        end
                    end
                end
                
                -- 处理直接在 data 下的数值和数值字符串
                for k, v in pairs(data) do
                    if k ~= 'AbilityValues' then
                        if type(v) == 'number' then
                            flat_data[k] = v
                        elseif type(v) == 'string' then
                            if v:match("^%d+%.?%d*[%s%d%.]*$") then  -- 如果是数值字符串
                                flat_data[k] = v
                            end
                        elseif type(v) == 'table' then
                            -- 递归处理嵌套表
                            flattenAbilityData(v)
                        else
                            -- Handle unexpected types
                            -- Uncomment for debugging
                            -- print("Warning: Unexpected type for key '" .. k .. "': " .. type(v))
                        end
                    end
                end
            end
            
            flattenAbilityData(ability_data)
            
            -- 只有在有数据时才设置
            if next(flat_data) then
                CustomNetTables:SetTableValue("edit_kv", ability_index, flat_data)
            else
                -- Uncomment for debugging
                -- print("Warning: No valid data for " .. ability_index)
            end
        end
    end
    
    -- 打印更新后的内容
    PrintEditKvContents()
end

function Main:AmplifyAbilityAOE(multiplier)

    multiplier = multiplier or 10  -- 默认10倍

    local function processAbilityValues(ability_data)
        if not ability_data or type(ability_data) ~= 'table' then 

            return 
        end
        
        -- 创建一个新的扁平结构来存储修改后的值
        local modified_values = {
            AbilityValues = {}
        }

        -- 处理AbilityValues中的AOE值
        if ability_data.AbilityValues then
            for k, v in pairs(ability_data.AbilityValues) do
                if type(v) == 'table' and v.affected_by_aoe_increase then
                    if v.affected_by_aoe_increase == 1 or v.affected_by_aoe_increase == "1" then
                        print(string.format("\n找到 AOE 标记字段: %s", k))
                        
                        -- 复制原始数据结构
                        modified_values.AbilityValues[k] = table.deepcopy(v)
                        
                        -- 修改value值
                        if v.value then
                            local old_value = v.value
                            if type(old_value) == 'string' then
                                local numbers = {}
                                for num in old_value:gmatch("%d+") do
                                    table.insert(numbers, tonumber(num) * multiplier)
                                end
                                if #numbers > 0 then
                                    modified_values.AbilityValues[k].value = table.concat(numbers, " ")
                                    print(string.format("数值修改：%s[value] %s -> %s", 
                                        k, old_value, modified_values.AbilityValues[k].value))
                                end
                            elseif type(old_value) == 'number' then
                                modified_values.AbilityValues[k].value = old_value * multiplier
                                print(string.format("数值修改：%s[value] %s -> %s", 
                                    k, old_value, modified_values.AbilityValues[k].value))
                            end
                        end
                    end
                end
            end
        end

        return modified_values
    end

    for hero_name, hero_abilities in pairs(Main.heroAbilities) do
        print(string.format("\n====================="))
        print(string.format("正在处理英雄：%s", hero_name))
        print(string.format("====================="))
        
        local updates = {}
        updates[hero_name] = {}
        
        for ability_name, ability_data in pairs(hero_abilities) do
            if type(ability_data) == 'table' then
                print(string.format("\n处理技能：%s", ability_name))
                
                local modified_values = processAbilityValues(ability_data)
                if modified_values and next(modified_values.AbilityValues) then
                    updates[hero_name][ability_name] = modified_values
                end
            end
        end
        
        -- 只有当有修改时才调用UpdateAbilityModifiers
        if next(updates[hero_name]) then
            self:UpdateAbilityModifiers(updates)
        end
    end
    
    print("\nAmplifyAbilityAOE 函数执行完成")
end