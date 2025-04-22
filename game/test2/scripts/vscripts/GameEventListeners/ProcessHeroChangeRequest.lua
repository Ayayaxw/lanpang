function Main:ProcessHeroChangeRequest(event)

    local mapCenter = Vector(0, 0, 0)
    local mapRadius = 99999  -- 地图半径，确保覆盖整个地图

    GridNav:DestroyTreesAroundPoint(mapCenter, mapRadius, false)
    GridNav:RegrowAllTrees()
    CameraControl:Stop()

    local playerID = 0  -- 假设是玩家0，如果需要可以修改
    local player = PlayerResource:GetPlayer(playerID)

    if not player then
        print("未找到玩家")
        return
    end

    self:RestoreOriginalValues() --恢复修改过的技能KV

    self.currentChallenge = event.challengeType

    self:ExecuteCleanupFunction(self.currentChallenge)
    print("更新当前挑战为:", self.currentChallenge)

    self:SetupNewHero(event, playerID)

    print("英雄更改请求处理完成")


    -- 递归打印表格内容的函数
    local function DeepPrint(t, indent, visited)
        indent = indent or 0
        visited = visited or {}
        
        -- 防止循环引用导致的无限递归
        if visited[t] then
            print(string.rep("  ", indent) .. "已引用过的表: " .. tostring(t))
            return
        end
        
        visited[t] = true
        
        for k, v in pairs(t) do
            local prefix = string.rep("  ", indent)
            if type(v) == "table" then
                print(prefix .. tostring(k) .. " = {")
                DeepPrint(v, indent + 1, visited)
                print(prefix .. "}")
            else
                print(prefix .. tostring(k) .. " = " .. tostring(v))
            end
        end
    end

    -- 详细打印event所有内容
    print("\n========= 事件详细内容 =========")
    DeepPrint(event)
    print("================================\n")

end


-- 执行挑战模式的收尾函数
function Main:ExecuteCleanupFunction(challengeId)
    hero_duel.EndDuel = true
    local challengeName = self:GetChallengeNameById(challengeId)

    if challengeName then
        self.DeleteCurrentArenaHeroes()
        Timers:CreateTimer(0.5, function()
        self.ClearAllUnitsExcept()
        AIs = {}
        end)

        local cleanupFunctionName = "Cleanup_" .. challengeName
        if self[cleanupFunctionName] then
            self[cleanupFunctionName](self)
        end
    end
end

-- 获取挑战模式名称
function Main:GetChallengeNameById(challengeId)
    for name, id in pairs(Main.Challenges) do
        if id == challengeId then
            return name
        end
    end
    return nil
end

function Main:GetChallengeIDByCode(challengeCode)
    for name, code in pairs(Main.Challenges) do
        if code == challengeCode then
            return name
        end
    end
    return nil
end



-- 设置新英雄
function Main:SetupNewHero(event, playerID)
    -- 根据配置的挑战类型执行相应的初始化
    Timers:CreateTimer(2, function()
        -- 获取当前的挑战模式ID
        local challengeId = self.currentChallenge
        print("当前挑战模式ID: " .. challengeId)
        local challengeName = self:GetChallengeNameById(challengeId)

        
        SendToServerConsole("host_timescale 1")
        self.currentTimer = (self.currentTimer or 0) + 1
        self.currentMatchID = self:GenerateUniqueID()    --比赛ID
        hero_duel.EndDuel = false  -- 标记战斗是否结束
        hero_duel.abilityDamageTracker = {}
        hero_duel.damagePanelEnabled = false -- 默认禁用
        hero_duel.currentHighestAbility = nil
        hero_duel.damagePanelTimerStarted = false
        hero_duel.start_time = GameRules:GetGameTime()

        if challengeName then
            -- 构建初始化函数的名称
            local initFunctionName = "Init_" .. challengeName
            if self[initFunctionName] then
                -- 调用对应的初始化函数，传入 event 和 playerID
                self[initFunctionName](self, event, playerID)
            else
                print("没有找到对应挑战模式的初始化函数: " .. challengeName)
            end
        else
            print("未知的挑战模式ID: " .. tostring(challengeId))
        end
    end)
end


function Main:DeleteCurrentArenaHeroes()
    -- 遍历并清除当前竞技场中的英雄
    Main:ClearAbilitiesPanel()
    Main:ClearAllFloatingText()
    Timers:CreateTimer(1, function()
        Main:ClearAbilitiesPanel()
    end)
    for index, hero in ipairs(Main.currentArenaHeroes) do
        if hero and not hero:IsNull() and hero.GetPlayerID then
            local playerID = hero:GetPlayerID()
            print("Clearing hero for Player ID:", playerID)

            -- 如果英雄已死亡，先复活
            if not hero:IsAlive() then
                hero:RespawnHero(false, false)
            end
            
            -- 如果是美杜莎，先将其传送到远处
            if hero:GetUnitName() == "npc_dota_hero_medusa" or hero:GetUnitName() == "npc_dota_hero_tinker" then
                hero:SetAbsOrigin(Vector(10000, 10000, 128))
            end
            Timers:CreateTimer(0.1, function()
                if hero:IsHero() and not hero:IsClone() and hero:GetPlayerOwner() then
                    
                    DisconnectClient(playerID, true)
                else
                    UTIL_Remove(hero)
                end
            end)
        else
            print("Error: Invalid hero entity at index " .. index)
        end
    end

    -- 清空表格
    Main.currentArenaHeroes = {}
end


function FindChineseNameByHeroCode(heroCode)
    for _, heroInfo in pairs(heroes_precache) do
        if heroInfo.name == heroCode then
            return heroInfo.chinese
        end
    end
    return "未知英雄"  -- 如果没有找到匹配的英雄，返回这个
end

function Main:HandleCustomGameEvents(event)
    local eventName = event.event
    if eventName == "ChangeHeroRequest" then
        Main:ProcessHeroChangeRequest(event)
    end
    -- 可以在这里添加其他事件的处理
end


-- 获取英雄名称和中文名称
function Main:GetHeroNames(heroId)
    if heroId ~= -1 then
        local heroCode = DOTAGameManager:GetHeroNameByID(heroId)
        local heroName = "npc_dota_hero_" .. heroCode
        local heroChineseName = FindChineseNameByHeroCode(heroName)
        return heroName, heroChineseName
    else
        return "npc_dota_hero_target_dummy", "伪人"
    end
end

function Main:ConfigureHero(hero, isFriendly, playerID)
    self:ApplyConfig(hero, "ALL")
    self:ApplyConfig(hero, isFriendly and "FRIENDLY" or "ENEMY")
    Timers:CreateTimer(0.2, function()
        self:ApplyConfig(hero, "BATTLEFIELD")  -- 对英雄应用战场效果
    end)
    
    if isFriendly then
        local player = PlayerResource:GetPlayer(playerID)
        hero:SetControllableByPlayer(playerID, true)
        player:SetAssignedHeroEntity(hero)
    end
    
    self:HandleSpecialHero(hero, isFriendly and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS)
end

function Main:ApplyConfig(hero, configType)
    -- 添加防御性检查
    if not self.HERO_CONFIG then
        print("Warning: HERO_CONFIG is not initialized")
        return
    end

    if not self.HERO_CONFIG[configType] then
        print("Warning: Invalid config type: " .. tostring(configType))
        return
    end

    for _, operation in ipairs(self.HERO_CONFIG[configType]) do
        operation(hero)
    end
end

function Main:HandleSpecialHero(hero, team)
    local heroName = hero:GetUnitName()
    if heroName == "npc_dota_hero_meepo" then
        Timers:CreateTimer(2.0, function()
            if self.currentTimer ~= self.timerId or hero_duel.EndDuel then return end
            local meepos = FindUnitsInRadius(
                team,
                hero:GetAbsOrigin(),
                nil,
                FIND_UNITS_EVERYWHERE,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
                FIND_ANY_ORDER,
                false
            )
            for _, meepo in pairs(meepos) do
                if meepo:HasModifier("modifier_meepo_divided_we_stand") and meepo:IsRealHero() then
                    self:ApplyConfig(meepo, "FRIENDLY")
                end
            end
        end)
    end
    -- 可以在这里添加其他特殊英雄的处理
end

-- 为英雄装备物品
function Main:EquipHeroItems(hero, equipment)
    if equipment and type(equipment) == "table" then
        for _, item in pairs(equipment) do
            if type(item) == "table" and item.name and item.count then
                local itemCount = tonumber(item.count) or 0
                for i = 1, itemCount do
                    local newItem = hero:AddItemByName(item.name)
                    if not newItem then
                        print("警告: 无法添加物品 " .. item.name .. " 到英雄")
                    end
                end
            else
                print("警告: 无效的装备数据格式")
            end
        end
    else
        print("警告: 无效的装备列表")
    end
end



function Main:ClearAllUnitsExcept()
    local exceptModifier = "modifier_caipan"
    print("开始清理全图所有单位和物品，除了拥有 '" .. exceptModifier .. "' 修饰器的单位")

    local allFlags = DOTA_UNIT_TARGET_FLAG_NONE + 
                     DOTA_UNIT_TARGET_FLAG_DEAD +
                     DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
                     DOTA_UNIT_TARGET_FLAG_INVULNERABLE +
                     DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD

    local removedCount = 0
    local removedItemCount = 0

    -- 清理地上的物品
    local items = Entities:FindAllByClassname("dota_item_drop")
    for _, item in pairs(items) do
        if item and IsValidEntity(item) then
            UTIL_Remove(item)
            removedItemCount = removedItemCount + 1
        end
    end

    -- 查找所有单位，包括无敌和特殊状态的单位
    local allUnits = FindUnitsInRadius(
        DOTA_TEAM_NOTEAM,
        Vector(0, 0, 0),
        nil,
        FIND_UNITS_EVERYWHERE,
        DOTA_UNIT_TARGET_TEAM_BOTH,
        DOTA_UNIT_TARGET_ALL,
        allFlags,
        FIND_ANY_ORDER,
        false
    )

    for _, unit in pairs(allUnits) do
        if unit and IsValidEntity(unit) and not unit:HasModifier(exceptModifier) then
            print("正在移除单位: " .. unit:GetUnitName())
            
            if unit:IsHero() then
                -- 如果是英雄且已死亡，先复活
                if not unit:IsAlive() then
                    unit:RespawnHero(false, false)
                end

                -- 移除所有修饰器
                unit:RemoveAllModifiers(0, true, true, true)  -- 移除所有(0)修饰器，立即移除，永久移除，不是死亡导致的移除
                if unit:GetUnitName() == "npc_dota_hero_medusa" then
                    unit:SetAbsOrigin(Vector(10000, 10000, 128))
                    if unit:HasModifier("modifier_invulnerable") then
                        unit:RemoveModifierByName("modifier_invulnerable")
                    end
                    Timers:CreateTimer(0.1, function()
                        if IsValidEntity(unit) then  -- 添加有效性检查
                            local playerID = unit:GetPlayerID()
                            UTIL_Remove(unit)
                            DisconnectClient(playerID, true)
                        end
                    end)
                else
                    -- 移除无敌状态
                    unit:RemoveModifierByName("modifier_invulnerable")
                    local playerID = unit:GetPlayerID()
                    UTIL_Remove(unit)
                    DisconnectClient(playerID, true)
                end
            else
                -- 非英雄单位处理逻辑优化
                if IsValidEntity(unit) then
                    -- 先强制杀死单位
                    unit:ForceKill(false)
                    
                    -- 再次检查有效性后处理修饰器
                    if IsValidEntity(unit) then
                        unit:RemoveAllModifiers(0, true, true, true)
                        if unit:HasModifier("modifier_invulnerable") then
                            unit:RemoveModifierByName("modifier_invulnerable")
                        end
                        UTIL_Remove(unit)
                    end
                end
            end

            removedCount = removedCount + 1
        end
    end

    print("清理完成，共移除 " .. removedCount .. " 个单位，" .. removedItemCount .. " 个物品")
end