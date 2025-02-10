
function Main:Init_CreepChallenge_500MegaCreeps(newHero, playerID, heroChineseName)
    self.newHero = newHero  -- 保存 newHero 以便在 OnUnitKilled 中使用
    self.duration = 11 -- 保存 duration 以便在 OnUnitKilled 中使用
    self.endduration = 6  -- 保存 duration 以便在 OnUnitKilled 中使用
    local limitTime = self.duration + 30  -- 限定时间为准备时间结束后的一分钟

    -- 定义初始小兵数量、生物名称和队伍
    local initialCreepCount = 500
    local creepName = "npc_dota_creep_goodguys_melee_upgraded_mega"
    local team = DOTA_TEAM_BADGUYS

    -- 设置当前计时器标志
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer

    -- 设置金币和经验
    PlayerResource:SetGold(playerID, 0, false)
    HeroMaxLevel(newHero)

    -- 移动英雄到 (0, 0, 0) 位置
    newHero:SetAbsOrigin(Vector(0, 0, 0))
    FindClearSpaceForUnit(newHero, Vector(100, -500, 0), true)
        -- 输出控制台信息: 更换英雄
    local currentTime = Time()
    local formattedTime = string.format("%.2f", currentTime)
    print("[DOTA_RECORD] " .. heroChineseName .. ": 更换英雄")

    -- 添加必要的物品
    newHero:AddItemByName("item_ultimate_scepter_2")
    newHero:AddItemByName("item_aghanims_shard")
    --newHero:AddNewModifier(newHero, nil, "modifier_invisible", {duration = -1})
    newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = self.duration })
    newHero:AddNewModifier(newHero, nil, "modifier_silence", { duration = self.duration })
    newHero:AddNewModifier(newHero, nil, "modifier_rooted", { duration = self.duration })
    newHero:AddNewModifier(newHero, nil, "modifier_break", { duration = self.duration })



    spawn_manager.spawn_creatures(spawn_manager, initialCreepCount, creepName, team)

    -- 初始化击杀数量和标志
    spawn_manager.killedCount = 0
    spawn_manager.creepCount = initialCreepCount
    spawn_manager.allCreepsKilled = false  -- 新增的标志
    local challengedHeroChineseName = self:GetHeroChineseName(Main.AIheroName);
    CustomGameEventManager:Send_ServerToAllClients("reset_timer", {remaining = limitTime - self.duration, heroChineseName = heroChineseName ,challengedHeroChineseName=challengedHeroChineseName})
    CustomGameEventManager:Send_ServerToAllClients("update_creep_count", {count = spawn_manager.killedCount})

    -- 倒计时3秒，在最后一秒喊话“开始”
    Timers:CreateTimer(self.duration - 3, function()
        if self.currentTimer ~= timerId or spawn_manager.allCreepsKilled then return end
        GameRules:SendCustomMessage("3", 0, 0)
    end)
    Timers:CreateTimer(self.duration - 2, function()
        if self.currentTimer ~= timerId or spawn_manager.allCreepsKilled then return end
        GameRules:SendCustomMessage("2", 0, 0)
    end)
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or spawn_manager.allCreepsKilled then return end
        GameRules:SendCustomMessage("1", 0, 0)
    end)
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or spawn_manager.allCreepsKilled then return end
        GameRules:SendCustomMessage("开始！", 0, 0)
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {startTime = GameRules:GetGameTime(), limitTime = limitTime - self.duration})
        local currentTime = Time()
        local formattedTime = string.format("%.2f", currentTime)
        print("[DOTA_RECORD] " .. heroChineseName .. ": 开始战斗")
    end)

    -- 限定时间结束后执行的操作
    Timers:CreateTimer(limitTime, function()
        if self.currentTimer ~= timerId or spawn_manager.allCreepsKilled then return end
        
        -- 停止计时并精确设置前端计时器的时间
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {time = 0})
        
        -- 清理所有小兵
        local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE,
                                        DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _, unit in pairs(units) do
            if unit:GetUnitName() == "npc_dota_creep_goodguys_melee_upgraded_mega" or unit:GetUnitName() == "npc_dota_creep_badguys_melee" then
                unit:RemoveSelf()
            end
        end

        -- 对英雄再次施加缠绕、缴械、禁锢和破坏效果
        spawn_manager.allCreepsKilled = true
        newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = self.endduration })
        newHero:AddNewModifier(newHero, nil, "modifier_silence", { duration = self.endduration })
        newHero:AddNewModifier(newHero, nil, "modifier_rooted", { duration = self.endduration })
        newHero:AddNewModifier(newHero, nil, "modifier_break", { duration = self.endduration })
        
    end)
end