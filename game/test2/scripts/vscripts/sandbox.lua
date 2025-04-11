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
            -- 新增参数处理
            local teamId = data.teamId or DOTA_TEAM_GOODGUYS
            local position = Vector(tonumber(data.positionX) or 0, 
                                   tonumber(data.positionY) or 0, 
                                   tonumber(data.positionZ) or 0)
            local selectedEntityId = data.selectedEntityId -- 获取前端传递的选中单位ID
            
            -- 根据功能类型传递参数
            if targetFunction.requiresSelection and targetFunction.selectionType == "hero" then
                local heroId = data.heroId
                local facetId = data.facetId
                Main[functionName](Main, playerId, heroId, facetId, teamId, position)  -- 新增参数
            else
                Main[functionName](Main, playerId, teamId, position, selectedEntityId)  -- 新增选中单位ID参数
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
    {
        id = "add_ai",
        name = "添加AI",
        functionName = "AddAIToHero",
        category = "hero"
    },
    {
        id = "max_level",
        name = "升至满级",
        functionName = "MaxLevelHero",
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
function Main:CreateHero_Sandbox(playerId, heroId, facetId, teamId, position)
    print(string.format("Creating hero for player %d, heroId: %s, team: %d",
                      playerId, tostring(heroId), teamId))
    
    if heroId then
        -- 根据队伍决定生成位置
        local spawnPosition
        if teamId == DOTA_TEAM_GOODGUYS then
            spawnPosition = Vector(-5600, -1720, 128.00)  -- 天辉（Good）基地
        elseif teamId == DOTA_TEAM_BADGUYS then
            spawnPosition = Vector(5600, -1720, 128.00)    -- 夜魇（Bad）基地
        else
            spawnPosition = Vector(0, 0, 128.00)           -- 默认位置（中立）
            print("Warning: Unknown teamId, spawning at default position")
        end
        
        local isControllableByPlayer = true
        local heroName = DOTAGameManager:GetHeroUnitNameByID(heroId)
        
        if heroName then
            CreateHero(
                playerId,
                heroName,
                facetId or 0,
                spawnPosition,
                teamId,
                isControllableByPlayer,
                function(hero)
                    -- 可以在这里添加额外的英雄设置

                end
            )
        else
            print("Error: Invalid heroId")
        end
    else
        print("Warning: No hero specified")
    end
end

-- 英雄删除函数修改
function Main:DeleteHero(playerId, teamId, position, selectedEntityId)
    print("尝试删除玩家 " .. playerId .. " 选中的英雄，选中单位ID: " .. (selectedEntityId or "无"))
    
    -- 使用前端传递的选中单位ID
    local selectedHero = nil
    if selectedEntityId and selectedEntityId ~= -1 then
        selectedHero = EntIndexToHScript(selectedEntityId)
    else
        -- 兼容旧方式，如果没有传递选中单位ID
        selectedHero = PlayerResource:GetSelectedHeroEntity(playerId)
    end
    
    if selectedHero then
        -- 获取英雄位置以显示特效
        local heroPos = selectedHero:GetAbsOrigin()
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, heroPos)
        ParticleManager:SetParticleControl(particleID, 1, Vector(100, 0, 0))
        ParticleManager:ReleaseParticleIndex(particleID)
        
        -- 播放音效
        EmitSoundOnLocationWithCaster(heroPos, "Hero_Invoker.SunStrike.Ignite", selectedHero)
        
        -- 获取英雄所属玩家ID
        local heroOwner = selectedHero:GetPlayerOwnerID()
        
        print("删除英雄: " .. selectedHero:GetUnitName())
        
        -- 检查英雄是否有关联的玩家
        if heroOwner ~= -1 and heroOwner ~= 0 and PlayerResource:IsValidPlayerID(heroOwner) then
            -- 有关联玩家，断开玩家连接
            print("英雄有关联玩家 " .. heroOwner .. "，断开玩家连接")
            DisconnectClient(heroOwner, true)
        else
            -- 没有关联玩家，直接删除英雄
            print("英雄没有关联玩家，直接删除")
            UTIL_Remove(selectedHero)
        end
    else
        print("未选中英雄单位")
    end
end

-- 英雄升级函数修复
function Main:LevelUpHero(playerId, teamId, position, selectedEntityId)
    print("尝试升级玩家 " .. playerId .. " 选中的英雄，选中单位ID: " .. (selectedEntityId or "无"))
    
    -- 使用前端传递的选中单位ID
    local selectedHero = nil
    if selectedEntityId and selectedEntityId ~= -1 then
        selectedHero = EntIndexToHScript(selectedEntityId)
    else
        -- 兼容旧方式，如果没有传递选中单位ID
        selectedHero = PlayerResource:GetSelectedHeroEntity(playerId)
    end
    
    if selectedHero then
        print("升级英雄: " .. selectedHero:GetUnitName())
        
       selectedHero:HeroLevelUp(true)

    else
        print("未选中英雄单位")
    end
end

function Main:PrintAllPlayersAndHeroes()
    print("打印所有玩家及其选中英雄信息：")
    print("----------------------------------------------")
    
    -- Dota 2默认最多支持10个玩家ID (0-9)
    local maxPlayers = 10
    local foundPlayers = false
    
    for playerId = 0, maxPlayers - 1 do
        if PlayerResource:IsValidPlayerID(playerId) then
            foundPlayers = true
            
            -- 获取玩家名称
            local playerName = PlayerResource:GetPlayerName(playerId)
            
            -- 获取玩家队伍
            local teamId = PlayerResource:GetTeam(playerId)
            local teamName = "未知"
            if teamId == DOTA_TEAM_GOODGUYS then
                teamName = "天辉"
            elseif teamId == DOTA_TEAM_BADGUYS then
                teamName = "夜魇"
            elseif teamId == DOTA_TEAM_CUSTOM_1 then
                teamName = "自定义1"
            elseif teamId == DOTA_TEAM_CUSTOM_2 then
                teamName = "自定义2"
            elseif teamId == DOTA_TEAM_CUSTOM_3 then
                teamName = "自定义3"
            elseif teamId == DOTA_TEAM_CUSTOM_4 then
                teamName = "自定义4"
            elseif teamId == DOTA_TEAM_CUSTOM_5 then
                teamName = "自定义5"
            elseif teamId == DOTA_TEAM_CUSTOM_6 then
                teamName = "自定义6"
            elseif teamId == DOTA_TEAM_CUSTOM_7 then
                teamName = "自定义7"
            elseif teamId == DOTA_TEAM_CUSTOM_8 then
                teamName = "自定义8"
            elseif teamId == DOTA_TEAM_NEUTRALS then
                teamName = "中立"
            end
            
            -- 检查是否为AI玩家
            local isAI = PlayerResource:IsFakeClient(playerId)
            local playerType = isAI and "AI" or "玩家"
            
            print("玩家ID: " .. playerId .. " | 名称: " .. playerName .. " | 类型: " .. playerType .. " | 队伍: " .. teamName)
            
            -- 获取玩家选择的英雄
            local selectedHero = PlayerResource:GetSelectedHeroEntity(playerId)
            
            if selectedHero then
                local heroName = selectedHero:GetUnitName()
                local heroLevel = selectedHero:GetLevel()
                local heroHealth = selectedHero:GetHealth() .. "/" .. selectedHero:GetMaxHealth()
                local heroMana = selectedHero:GetMana() .. "/" .. selectedHero:GetMaxMana()
                
                print("  选中英雄: " .. heroName .. " | 等级: " .. heroLevel .. " | 生命值: " .. heroHealth .. " | 魔法值: " .. heroMana)
                
                -- 获取英雄所属玩家ID
                local heroOwner = selectedHero:GetPlayerOwnerID()
                if heroOwner ~= playerId then
                    print("  警告：此英雄实际归属于玩家ID: " .. heroOwner)
                end
            else
                print("  未选中英雄")
            end
            
            print("----------------------------------------------")
        end
    end
    
    if not foundPlayers then
        print("没有找到任何有效玩家")
    end
end

function Main:GetAllSkills(playerId, teamId, position, selectedEntityId)
    print("为玩家 " .. playerId .. " 选中的英雄获取全部技能，选中单位ID: " .. (selectedEntityId or "无"))
    
    -- 使用前端传递的选中单位ID
    local selectedHero = nil
    if selectedEntityId and selectedEntityId ~= -1 then
        selectedHero = EntIndexToHScript(selectedEntityId)
    else
        -- 兼容旧方式，如果没有传递选中单位ID
        selectedHero = PlayerResource:GetSelectedHeroEntity(playerId)
    end
    
    if selectedHero then
        print("为英雄获取全部技能: " .. selectedHero:GetUnitName())
        -- 这里实现获取全部技能的逻辑
    else
        print("未选中英雄单位")
    end
end

-- 游戏资源类功能
function Main:SetInfiniteGold(playerId)
    print("Setting infinite gold for player " .. playerId)
    -- 实现无限金钱的代码
end

function Main:SetInfiniteMana(playerId, teamId, position, selectedEntityId)
    print("为玩家 " .. playerId .. " 选中的英雄设置无限魔法，选中单位ID: " .. (selectedEntityId or "无"))
    
    -- 使用前端传递的选中单位ID
    local selectedHero = nil
    if selectedEntityId and selectedEntityId ~= -1 then
        selectedHero = EntIndexToHScript(selectedEntityId)
    else
        -- 兼容旧方式，如果没有传递选中单位ID
        selectedHero = PlayerResource:GetSelectedHeroEntity(playerId)
    end
    
    if selectedHero then
        print("为英雄设置无限魔法: " .. selectedHero:GetUnitName())
        
        -- 创建一个循环定时器，不断恢复魔法值
        local infiniteManaTimerName = "infinite_mana_" .. selectedHero:GetEntityIndex()
        
        -- 先取消可能已存在的定时器
        if Timers.timers[infiniteManaTimerName] then
            Timers:RemoveTimer(infiniteManaTimerName)
            print("已移除英雄的无限魔法效果")
            
            -- 显示特效，表示取消效果
            local heroPos = selectedHero:GetAbsOrigin()
            local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf", PATTACH_CUSTOMORIGIN, nil)
            ParticleManager:SetParticleControl(particleID, 0, heroPos)
            ParticleManager:ReleaseParticleIndex(particleID)
            
            EmitSoundOnLocationWithCaster(heroPos, "Hero_KeeperOfTheLight.ChakraMagic.Target", selectedHero)
            
            -- 显示消息给玩家
            local notification = {
                message = "无限魔法状态已关闭",
                duration = 3.0,
                style = { color = "red" }
            }
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "game_notification", notification)
            
            return
        end
        
        -- 设置无限魔法
        Timers:CreateTimer(infiniteManaTimerName, {
            endTime = 0.1,
            callback = function()
                if IsValidEntity(selectedHero) and selectedHero:IsAlive() then
                    selectedHero:SetMana(selectedHero:GetMaxMana())
                    
                    -- 是否需要显示特效
                    if GameRules:GetGameTime() % 5 < 0.1 then
                        local heroPos = selectedHero:GetAbsOrigin()
                        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf", PATTACH_CUSTOMORIGIN, nil)
                        ParticleManager:SetParticleControl(particleID, 0, heroPos)
                        ParticleManager:ReleaseParticleIndex(particleID)
                    end
                    
                    return 0.1
                else
                    return nil -- 如果英雄无效或已死亡，停止定时器
                end
            end
        })
        
        -- 显示特效
        local heroPos = selectedHero:GetAbsOrigin()
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, heroPos)
        ParticleManager:ReleaseParticleIndex(particleID)
        
        EmitSoundOnLocationWithCaster(heroPos, "Hero_KeeperOfTheLight.ChakraMagic.Target", selectedHero)
        
        -- 显示消息给玩家
        local notification = {
            message = "无限魔法状态已启动",
            duration = 3.0,
            style = { color = "blue" }
        }
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "game_notification", notification)
        
        print("已为英雄 " .. selectedHero:GetUnitName() .. " 设置无限魔法")
    else
        print("未选中英雄单位")
    end
end

function Main:ResetCooldowns(playerId, teamId, position, selectedEntityId)
    print("为玩家 " .. playerId .. " 选中的英雄重置技能冷却，选中单位ID: " .. (selectedEntityId or "无"))
    
    -- 使用前端传递的选中单位ID
    local selectedHero = nil
    if selectedEntityId and selectedEntityId ~= -1 then
        selectedHero = EntIndexToHScript(selectedEntityId)
    else
        -- 兼容旧方式，如果没有传递选中单位ID
        selectedHero = PlayerResource:GetSelectedHeroEntity(playerId)
    end
    
    if selectedHero then
        print("为英雄重置技能冷却: " .. selectedHero:GetUnitName())
        
        -- 重置所有技能冷却
        for i = 0, selectedHero:GetAbilityCount() - 1 do
            local ability = selectedHero:GetAbilityByIndex(i)
            if ability and not ability:IsNull() then
                ability:EndCooldown()
            end
        end
        
        -- 重置所有物品冷却
        for i = 0, 8 do
            local item = selectedHero:GetItemInSlot(i)
            if item and not item:IsNull() then
                item:EndCooldown()
            end
        end
        
        -- 显示特效
        local heroPos = selectedHero:GetAbsOrigin()
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, heroPos)
        ParticleManager:ReleaseParticleIndex(particleID)
        
        -- 播放音效
        EmitSoundOnLocationWithCaster(heroPos, "Hero_KeeperOfTheLight.ChakraMagic.Target", selectedHero)
        
        print("已重置英雄 " .. selectedHero:GetUnitName() .. " 的所有技能和物品冷却")
    else
        print("未选中英雄单位")
    end
end

function Main:GetItems(playerId, teamId, position, selectedEntityId)
    print("为玩家 " .. playerId .. " 选中的英雄获取装备，选中单位ID: " .. (selectedEntityId or "无"))
    
    -- 使用前端传递的选中单位ID
    local selectedHero = nil
    if selectedEntityId and selectedEntityId ~= -1 then
        selectedHero = EntIndexToHScript(selectedEntityId)
    else
        -- 兼容旧方式，如果没有传递选中单位ID
        selectedHero = PlayerResource:GetSelectedHeroEntity(playerId)
    end
    
    if selectedHero then
        print("为英雄获取装备: " .. selectedHero:GetUnitName())
        
        -- 示例装备列表
        local itemList = {
            "item_blink",
            "item_black_king_bar",
            "item_assault",
            "item_heart",
            "item_satanic",
            "item_refresher"
        }
        
        -- 先清空英雄的物品栏
        for i = 0, 8 do
            local item = selectedHero:GetItemInSlot(i)
            if item then
                selectedHero:RemoveItem(item)
            end
        end
        
        -- 添加示例装备
        for _, itemName in ipairs(itemList) do
            local item = CreateItem(itemName, selectedHero, selectedHero)
            selectedHero:AddItem(item)
        end
        
        -- 显示特效
        local heroPos = selectedHero:GetAbsOrigin()
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, heroPos)
        ParticleManager:SetParticleControl(particleID, 1, Vector(100, 0, 0))
        ParticleManager:ReleaseParticleIndex(particleID)
        
        -- 播放音效
        EmitSoundOnLocationWithCaster(heroPos, "General.CoinsBig", selectedHero)
        
        print("已为英雄 " .. selectedHero:GetUnitName() .. " 添加标准装备")
    else
        print("未选中英雄单位")
    end
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

-- 添加AI到英雄
function Main:AddAIToHero(playerId, teamId, position, selectedEntityId)
    print("为玩家 " .. playerId .. " 选中的英雄添加AI，选中单位ID: " .. (selectedEntityId or "无"))
    
    -- 使用前端传递的选中单位ID
    local selectedHero = nil
    if selectedEntityId and selectedEntityId ~= -1 then
        selectedHero = EntIndexToHScript(selectedEntityId)
    else
        -- 兼容旧方式，如果没有传递选中单位ID
        selectedHero = PlayerResource:GetSelectedHeroEntity(playerId)
    end
    
    if selectedHero then
        print("为英雄添加AI: " .. selectedHero:GetUnitName())
        
        -- 添加AI控制
        CreateAIForHero(selectedHero, {"不允许对非英雄释放控制","避免重复施法"}, nil, "", 0.1, nil)
        
        -- 显示特效
        local heroPos = selectedHero:GetAbsOrigin()
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_guardian_ambient.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, heroPos)
        ParticleManager:ReleaseParticleIndex(particleID)
        
        -- 播放音效
        EmitSoundOnLocationWithCaster(heroPos, "Hero_Wisp.Spirits.Create", selectedHero)
        
        -- 显示消息给玩家
        local notification = {
            message = "已为英雄添加AI控制",
            duration = 3.0,
            style = { color = "green" }
        }
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "game_notification", notification)
        
        print("已为英雄 " .. selectedHero:GetUnitName() .. " 添加AI控制")
    else
        print("未选中英雄单位")
    end
end

-- 将英雄升至满级
function Main:MaxLevelHero(playerId, teamId, position, selectedEntityId)
    print("为玩家 " .. playerId .. " 选中的英雄升至满级，选中单位ID: " .. (selectedEntityId or "无"))
    
    -- 使用前端传递的选中单位ID
    local selectedHero = nil
    if selectedEntityId and selectedEntityId ~= -1 then
        selectedHero = EntIndexToHScript(selectedEntityId)
    else
        -- 兼容旧方式，如果没有传递选中单位ID
        selectedHero = PlayerResource:GetSelectedHeroEntity(playerId)
    end
    
    if selectedHero then
        print("将英雄升至满级: " .. selectedHero:GetUnitName())
        
        -- 保存升级前的等级
        local oldLevel = selectedHero:GetLevel()
        
        -- 将英雄升至满级
        HeroMaxLevel(selectedHero)
        
        -- 获取升级后的等级
        local newLevel = selectedHero:GetLevel()
        
        -- 显示特效
        local heroPos = selectedHero:GetAbsOrigin()
        local particleID = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(particleID, 0, heroPos)
        ParticleManager:SetParticleControl(particleID, 1, Vector(4, 0, 0))  -- 使用4级多重施法的效果
        ParticleManager:ReleaseParticleIndex(particleID)
        
        -- 播放音效
        EmitSoundOnLocationWithCaster(heroPos, "Hero_OgreMagi.Fireblast.x3", selectedHero)
        
        -- 显示消息给玩家
        local notification = {
            message = "英雄从 " .. oldLevel .. " 级升至 " .. newLevel .. " 级",
            duration = 3.0,
            style = { color = "yellow" }
        }
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "game_notification", notification)
        
        print("已将英雄 " .. selectedHero:GetUnitName() .. " 从 " .. oldLevel .. " 级升至 " .. newLevel .. " 级")
    else
        print("未选中英雄单位")
    end
end