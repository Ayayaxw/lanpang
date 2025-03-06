
-- 发送沙盒功能数据到前端
function Main:SendSandboxFunctionsData()
    local sandboxFunctions = {}
    
    for _, func in ipairs(Main.SandboxFunctions) do
        local funcData = {
            id = func.id,
            name = func.name,
            category = func.category,
            requiresSelection = func.requiresSelection or false,
            selectionType = func.selectionType
        }
        
        table.insert(sandboxFunctions, funcData)
    end
    
    CustomGameEventManager:Send_ServerToAllClients("initialize_sandbox_functions", sandboxFunctions)
end



-- 处理请求沙盒数据的事件
function Main:RequestSandboxData(data)
    -- 直接调用发送沙盒功能数据的函数
    print("请求沙盒数据")   
    Main:SendSandboxFunctionsData()
end

-- 处理沙盒功能事件
function Main:HandleSandboxEvent(data)
    local playerId = data.PlayerID
    
    -- 检查是否是请求沙盒数据
    if data.RequestSandboxData then
        Main:SendSandboxFunctionsData()
        return
    end
    
    -- 处理功能调用
    local functionId = data.functionId
    
    -- 查找对应的功能
    local targetFunction = nil
    for _, func in ipairs(Main.SandboxFunctions) do
        if func.id == functionId then
            targetFunction = func
            break
        end
    end
    
    if targetFunction then
        -- 调用对应的功能函数
        local functionName = targetFunction.functionName
        if Main[functionName] then
            -- 根据功能是否需要额外参数调用不同的方法
            if targetFunction.requiresSelection and targetFunction.selectionType == "hero" then
                -- 对于需要选择英雄的功能，从data中提取英雄ID和facetID
                local heroId = data.heroId
                local facetId = data.facetId
                Main[functionName](Main, playerId, heroId, facetId)
            else
                -- 对于普通功能，直接调用
                Main[functionName](Main, playerId)
            end
        else
            print("Function not found: " .. functionName)
        end
    else
        print("Sandbox function not found: " .. functionId)
    end
end

-- 注册事件监听器


-- 以下是各个沙盒功能的实现

-- 在Main表中添加沙盒模式功能定义
Main.SandboxFunctions = {
    -- 英雄操作类
    {
        id = "create_hero",
        name = "创建英雄",
        functionName = "CreateHero_Sandbox",
        category = "hero",
        requiresSelection = true,
        selectionType = "hero"  -- 表示需要选择英雄
    },
    {
        id = "delete_hero",
        name = "删除英雄",
        functionName = "DeleteHero",
        category = "hero"
    },
    {
        id = "level_up_hero",
        name = "升级英雄",
        functionName = "LevelUpHero",
        category = "hero"
    },
    {
        id = "get_all_skills",
        name = "获得全部技能",
        functionName = "GetAllSkills",
        category = "hero"
    },
    
    -- 游戏资源类
    {
        id = "infinite_gold",
        name = "无限金钱",
        functionName = "SetInfiniteGold",
        category = "resource"
    },
    {
        id = "infinite_mana",
        name = "无限魔法",
        functionName = "SetInfiniteMana",
        category = "resource"
    },
    {
        id = "reset_cooldowns",
        name = "清除冷却",
        functionName = "ResetCooldowns",
        category = "resource"
    },
    {
        id = "get_items",
        name = "获取装备",
        functionName = "GetItems",
        category = "resource"
    },
    
    -- 小兵控制类
    {
        id = "spawn_friendly_creeps",
        name = "友方小兵",
        functionName = "SpawnFriendlyCreeps",
        category = "creep"
    },
    {
        id = "spawn_enemy_creeps",
        name = "敌方小兵",
        functionName = "SpawnEnemyCreeps",
        category = "creep"
    },
    {
        id = "clear_creeps",
        name = "清除小兵",
        functionName = "ClearCreeps",
        category = "creep"
    },
    {
        id = "super_creeps",
        name = "超级兵",
        functionName = "SpawnSuperCreeps",
        category = "creep"
    },
    
    -- 环境设置类
    {
        id = "toggle_day_night",
        name = "切换昼夜",
        functionName = "ToggleDayNight",
        category = "environment"
    },
    {
        id = "weather_effects",
        name = "天气效果",
        functionName = "ToggleWeatherEffects",
        category = "environment"
    },
    {
        id = "clear_fog",
        name = "清除迷雾",
        functionName = "ClearFog",
        category = "environment"
    },
    {
        id = "reset_map",
        name = "重置地图",
        functionName = "ResetMap",
        category = "environment"
    }
}


-- 英雄操作类功能
function Main:CreateHero_Sandbox(playerId, heroId, facetId)
    print("Creating hero for player " .. playerId .. ", heroId: " .. (heroId or "none"))
    
    if heroId then
        -- 设置默认参数
        local spawnPosition = Vector(0, 0, 0)
        local team = DOTA_TEAM_GOODGUYS
        local isControllableByPlayer = true
        
        -- 从heroId获取英雄名称
        local heroName = DOTAGameManager:GetHeroUnitNameByID(heroId)
        
        if heroName then
            -- 调用新的CreateHero函数
            CreateHero(
                playerId,
                heroName,
                facetId or 0, -- 如果facetId为nil则使用0
                spawnPosition,
                team,
                isControllableByPlayer,
                function(hero)
                    -- 可以在这里添加额外的英雄设置
                end
            )
        else
            print("Error: Invalid heroId")
        end
    else
        -- 如果没有指定英雄ID，可以设置一个默认英雄
        print("Warning: No hero specified")
    end
end

function Main:DeleteHero(playerId)
    print("Deleting hero for player " .. playerId)
    -- 实现删除英雄的代码
end

function Main:LevelUpHero(playerId)
    print("Leveling up hero for player " .. playerId)
    -- 实现升级英雄的代码
    -- 例如：local hero = PlayerResource:GetSelectedHeroEntity(playerId)
    -- if hero then hero:HeroLevelUp(true) end
end

function Main:GetAllSkills(playerId)
    print("Getting all skills for player " .. playerId)
    -- 实现获取全部技能的代码
end

-- 游戏资源类功能
function Main:SetInfiniteGold(playerId)
    print("Setting infinite gold for player " .. playerId)
    -- 实现无限金钱的代码
end

function Main:SetInfiniteMana(playerId)
    print("Setting infinite mana for player " .. playerId)
    -- 实现无限魔法的代码
end

function Main:ResetCooldowns(playerId)
    print("Resetting cooldowns for player " .. playerId)
    -- 实现清除冷却的代码
end

function Main:GetItems(playerId)
    print("Getting items for player " .. playerId)
    -- 实现获取装备的代码
end

-- 小兵控制类功能
function Main:SpawnFriendlyCreeps(playerId)
    print("Spawning friendly creeps for player " .. playerId)
    -- 实现生成友方小兵的代码
end

function Main:SpawnEnemyCreeps(playerId)
    print("Spawning enemy creeps for player " .. playerId)
    -- 实现生成敌方小兵的代码
end

function Main:ClearCreeps(playerId)
    print("Clearing creeps for player " .. playerId)
    -- 实现清除小兵的代码
end

function Main:SpawnSuperCreeps(playerId)
    print("Spawning super creeps for player " .. playerId)
    -- 实现生成超级兵的代码
end

-- 环境设置类功能
function Main:ToggleDayNight(playerId)
    print("Toggling day/night for player " .. playerId)
    -- 实现切换昼夜的代码
end

function Main:ToggleWeatherEffects(playerId)
    print("Toggling weather effects for player " .. playerId)
    -- 实现切换天气效果的代码
end

function Main:ClearFog(playerId)
    print("Clearing fog for player " .. playerId)
    -- 实现清除迷雾的代码
end

function Main:ResetMap(playerId)
    print("Resetting map for player " .. playerId)
    -- 实现重置地图的代码
end