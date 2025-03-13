-- 打印npc_abilities表的完整内容
if not Main then
    Main = {}
end

-- 从npc_abilities.txt加载技能数据
if not Main.npc_abilities then
    Main.npc_abilities = LoadKeyValues('scripts/npc/npc_abilities.txt')
end

-- 深度打印函数，可以打印嵌套表
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

-- 打印完整的技能表
PrintAbilitiesTable(Main.npc_abilities) 