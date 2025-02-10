
-- 定义一个函数，用于处理技能释放事件
function Main:Init_HeroChallenge_ShadowShaman(newHero, playerID, heroChineseName)
    -- 清空场上所有名字非“caipan”的实体单位
    local allUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE,
                                       DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, true)
    print("allUnits",allUnits)
    for _, unit in ipairs(allUnits) do
        print("Unit Index: ", i, "Unit Name: ", unit:GetUnitName(), "Unit ID: ", unit:GetEntityIndex())
        if unit:GetUnitName() ~= "caipan" and not (playerID == 0 and unit == PlayerResource:GetSelectedHeroEntity(0)) then
            unit:RemoveSelf()
        end
    end
    
    self.newHero = newHero  -- 保存 newHero 以便在 OnUnitKilled 中使用
    self.duration = 11 -- 保存 duration 以便在 OnUnitKilled 中使用
    self.endduration = 6  -- 保存 duration 以便在 OnUnitKilled 中使用
    local limitTime = self.duration + 60  -- 限定时间为准备时间结束后的一分钟

    -- 设置当前计时器标志
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer

    -- 设置金币和经验
    PlayerResource:SetGold(playerID, 0, false)
    HeroMaxLevel(newHero)
    
    -- 移动英雄到 (0, 0, 0) 位置
    newHero:SetAbsOrigin(Vector(-800, -3000, 0))
    FindClearSpaceForUnit(newHero, Vector(-800, -3000, 0), true)
    -- 输出控制台信息: 更换英雄
    local currentTime = Time()
    local formattedTime = string.format("%.2f", currentTime)
    print("[DOTA_RECORD] " .. heroChineseName .. ": 更换英雄")

    -- 添加必要的物品
    newHero:AddItemByName("item_skadi")
    newHero:AddItemByName("item_assault")
    newHero:AddItemByName("item_ultimate_scepter_2")
    newHero:AddItemByName("item_aghanims_shard")
    --newHero:AddNewModifier(newHero, nil, "modifier_invisible", {duration = -1})
    newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = self.duration })
    newHero:AddNewModifier(newHero, nil, "modifier_silence", { duration = self.duration })
    newHero:AddNewModifier(newHero, nil, "modifier_rooted", { duration = self.duration })
    newHero:AddNewModifier(newHero, nil, "modifier_break", { duration = self.duration })

    -- 创建并设置暗影萨满 AI
    local saman = xiaowanyi:CreateAndSetupHero("npc_dota_hero_shadow_shaman", Vector(1000, -3000, 0), playerID, 4, DOTA_TEAM_BADGUYS)
    --saman:CalculateStatBonus(true)

    local dummy = CreateUnitByName("npc_dota_observer_wards", Vector(100, -3000, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)

    dummy:AddNewModifier(unit, nil, "modifier_invisible", {duration = 9999})
    PlayerResource:SetCameraTarget(playerID, dummy)

    hero_duel.shadowShamanHealthTotal = 45
    hero_duel.EndDuel = false  -- 新增的标志
    local challengedHeroChineseName = self:GetHeroChineseName(Main.AIheroName);
    CustomGameEventManager:Send_ServerToAllClients("reset_timer", {remaining = limitTime - self.duration, heroChineseName = heroChineseName ,challengedHeroChineseName=challengedHeroChineseName})
    CustomGameEventManager:Send_ServerToAllClients("update_shaman_health", {health = hero_duel.shadowShamanHealthTotal})
    Timers:CreateTimer(2, function()
        PlayerResource:SetCameraTarget(playerID, nil)
        dummy:RemoveSelf()
    end)

    -- 如果英雄是影魔，则召唤15个小狗头人
    if heroChineseName == "影魔" then
        local necromasteryAbility = newHero:FindAbilityByName("nevermore_necromastery")
        if necromasteryAbility and necromasteryAbility:GetLevel() > 0 then
            local maxSouls = 25
            newHero:SetModifierStackCount("modifier_nevermore_necromastery", newHero, maxSouls)
        else
            -- 如果没有找到技能或技能未升级，可以在这里处理错误或者记录日志
            print("错误：未能找到影魔的灵魂积累技能或技能未升级！")
        end
    end

    if heroChineseName == "艾欧" then
        print("创建了")
        local gnoll = CreateUnitByName("npc_dota_neutral_polar_furbolg_champion", newHero:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)),true, nil, nil, DOTA_TEAM_GOODGUYS)
        if gnoll then
            gnoll:SetOwner(newHero)
            gnoll:SetControllableByPlayer(newHero:GetPlayerID(), true)
        end

    end


    -- 倒计时3秒，在最后一秒喊话“开始”
    Timers:CreateTimer(self.duration - 3, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        GameRules:SendCustomMessage("3", 0, 0)
    end)
    Timers:CreateTimer(self.duration - 2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        GameRules:SendCustomMessage("2", 0, 0)
    end)
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        GameRules:SendCustomMessage("1", 0, 0)
    end)
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        GameRules:SendCustomMessage("开始！", 0, 0)
        saman:SetContextThink("AIThink", function() return HeroAI:Think(saman) end, 0.1)
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {startTime = GameRules:GetGameTime(),limitTime = limitTime - self.duration})
        local currentTime = Time()
        local formattedTime = string.format("%.2f", currentTime)
        print("[DOTA_RECORD] " .. heroChineseName .. ": 开始战斗")
    end)

    -- 限定时间结束后执行的操作

    Timers:CreateTimer(limitTime, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        -- 停止计时并精确设置前端计时器的时间
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {time = 0})
        local allUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE,
                                        DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, true)
        print("allUnits",allUnits)
        for _, unit in ipairs(allUnits) do
            print("Unit Index: ", i, "Unit Name: ", unit:GetUnitName(), "Unit ID: ", unit:GetEntityIndex())
            if unit:GetUnitName() ~= "caipan" and not (playerID == 0 and unit == PlayerResource:GetSelectedHeroEntity(0)) then
                unit:RemoveSelf()
            end
        end

        -- 对英雄再次施加缠绕、缴械、禁锢和破坏效果
        hero_duel.EndDuel = true
        newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = self.endduration })
        newHero:AddNewModifier(newHero, nil, "modifier_silence", { duration = self.endduration })
        newHero:AddNewModifier(newHero, nil, "modifier_rooted", { duration = self.endduration })
        newHero:AddNewModifier(newHero, nil, "modifier_break", { duration = self.endduration })
        
    end)
end

