-- 技能数据打印工具
-- 用法:
-- 1. 打印所有技能: _G.print_all_abilities()
-- 2. 打印单个技能: _G.print_ability("技能名称")
-- 3. 列出所有技能: _G.list_abilities()

if not Main then
    Main = {}
end

-- 加载技能数据
if not Main.npc_abilities then
    print("正在加载npc_abilities.txt...")
    Main.npc_abilities = LoadKeyValues('scripts/npc/npc_abilities.txt')
    
    if not Main.npc_abilities then
        print("错误：无法加载npc_abilities.txt文件!")
        return
    else
        print("技能数据加载完成！")
    end
end

-- 打印函数
local function DeepPrintTable(t, indent, done)
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

-- 计算表中元素数量的辅助函数
local function GetTableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- 打印技能表的主函数
local function PrintAbilitiesTable(abilities_table)
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

-- 打印单个技能的详细信息
local function PrintSingleAbility(ability_name)
    if not ability_name or ability_name == "" then
        print("错误：请指定技能名称")
        return false
    end
    
    local ability_data = Main.npc_abilities[ability_name]
    if ability_data then
        print("\n========= 打印技能: " .. ability_name .. " ==========")
        DeepPrintTable(ability_data, 1)
        print("========= 技能打印完成 ==========")
        return true
    else
        print("错误：找不到技能 '" .. ability_name .. "'")
        -- 打印可能匹配的技能
        print("可能匹配的技能:")
        local found = false
        for name in pairs(Main.npc_abilities) do
            if string.find(name:lower(), ability_name:lower()) then
                print("  - " .. name)
                found = true
            end
        end
        if not found then
            print("没有找到匹配项")
        end
        return false
    end
end

-- 列出所有技能名称
local function ListAllAbilities()
    print("\n========= 所有技能名称列表 ==========")
    local ability_names = {}
    for ability_name in pairs(Main.npc_abilities) do
        table.insert(ability_names, ability_name)
    end
    table.sort(ability_names)
    
    for _, ability_name in ipairs(ability_names) do
        print(ability_name)
    end
    print("总计: " .. #ability_names .. " 个技能")
    print("========= 技能列表结束 ==========")
end

-- 全局函数，方便调用
function _G.print_all_abilities()
    PrintAbilitiesTable(Main.npc_abilities)
end

function _G.print_ability(ability_name)
    return PrintSingleAbility(ability_name)
end

function _G.list_abilities()
    ListAllAbilities()
end

-- 打印使用指南
print("技能数据打印工具已加载！")
print("使用方法:")
print("1. 打印所有技能: _G.print_all_abilities()")
print("2. 打印单个技能: _G.print_ability(\"技能名称\")")
print("3. 列出所有技能: _G.list_abilities()") 