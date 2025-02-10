
function Main:Init_CD0_1skill_online(newHero0,newHero1,firstHeroChineseName,secondHeroChineseName)
    -- 清空场上所有名字非“caipan”的实体单位

    
    self.newHero0 = newHero0  -- 保存 newHero 以便在 OnUnitKilled 中使用
    self.newHero1 = newHero1
    self.duration = 11 -- 保存 duration 以便在 OnUnitKilled 中使用
    self.endduration = 6  -- 保存 duration 以便在 OnUnitKilled 中使用
    local limitTime = self.duration + 60  -- 限定时间为准备时间结束后的一分钟

    -- 设置当前计时器标志
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer

    -- 设置金币和经验
    PlayerResource:SetGold(0, 0, false)
    PlayerResource:SetGold(1, 0, false)
    HeroMaxLevel(newHero0)
    HeroMaxLevel(newHero1)
    
    -- 移动英雄到 (0, 0, 0) 位置
    newHero0:SetAbsOrigin(Vector(-800, -3000, 0))
    newHero1:SetAbsOrigin(Vector(1000, -3000, 0))
    
    FindClearSpaceForUnit(newHero0, Vector(-800, -3000, 0), true)
    FindClearSpaceForUnit(newHero1, Vector(1000, -3000, 0), true)
    -- 输出控制台信息: 更换英雄
    local currentTime = Time()
    local formattedTime = string.format("%.2f", currentTime)
    print("[DOTA_RECORD] " .. firstHeroChineseName .. ": 更换英雄")
    self:ListenHeroHealth(newHero1)
    -- 添加必要的物品
    newHero0:AddItemByName("item_ultimate_scepter_2")
    newHero0:AddItemByName("item_aghanims_shard")

    newHero0:AddNewModifier(newHero0, nil, "modifier_disarmed", { duration = self.duration })
    newHero0:AddNewModifier(newHero0, nil, "modifier_silence", { duration = self.duration })
    newHero0:AddNewModifier(newHero0, nil, "modifier_rooted", { duration = self.duration })
    newHero0:AddNewModifier(newHero0, nil, "modifier_break", { duration = self.duration })
    newHero0:AddNewModifier(newHero0, nil, "modifier_no_cooldown_FirstSkill", {})

    -- 添加必要的物品
    newHero1:AddItemByName("item_ultimate_scepter_2")
    newHero1:AddItemByName("item_aghanims_shard")

    newHero1:AddNewModifier(newHero1, nil, "modifier_disarmed", { duration = self.duration })
    newHero1:AddNewModifier(newHero1, nil, "modifier_silence", { duration = self.duration })
    newHero1:AddNewModifier(newHero1, nil, "modifier_rooted", { duration = self.duration })
    newHero1:AddNewModifier(newHero1, nil, "modifier_break", { duration = self.duration })
    newHero1:AddNewModifier(newHero1, nil, "modifier_no_cooldown_FirstSkill", {})

    

    local dummy = CreateUnitByName("npc_dota_observer_wards", Vector(100, -3000, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    PlayerResource:SetCameraTarget(0, dummy)

    Timers:CreateTimer(2, function()
        PlayerResource:SetCameraTarget(0, nil)
        dummy:RemoveSelf()
    end)


    hero_duel.EndDuel = false  -- 新增的标志
    Main.AIheroName = newHero1:GetUnitName()

    local challengedHeroChineseName = self:GetHeroChineseName(Main.AIheroName);

    CustomGameEventManager:Send_ServerToAllClients("reset_timer", {remaining = limitTime - self.duration, heroChineseName = firstHeroChineseName ,challengedHeroChineseName=challengedHeroChineseName})


    -- 如果英雄是影魔，则召唤15个小狗头人
    if firstHeroChineseName == "影魔" then
        local necromasteryAbility = newHero0:FindAbilityByName("nevermore_necromastery")
        if necromasteryAbility and necromasteryAbility:GetLevel() > 0 then
            local maxSouls = 25
            newHero0:SetModifierStackCount("modifier_nevermore_necromastery", newHero0, maxSouls)
        else
            print("错误：未能找到影魔的灵魂积累技能或技能未升级！")
        end
    end

    if secondHeroChineseName == "影魔" then
        local necromasteryAbility = newHero1:FindAbilityByName("nevermore_necromastery")
        if necromasteryAbility and necromasteryAbility:GetLevel() > 0 then
            local maxSouls = 25
            newHero1:SetModifierStackCount("modifier_nevermore_necromastery", newHero1, maxSouls)
        else
            print("错误：未能找到影魔的灵魂积累技能或技能未升级！")
        end
    end

    if firstHeroChineseName == "艾欧" then
        print("创建了")
        local gnoll = CreateUnitByName("npc_dota_roshan", newHero0:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)), true, nil, nil, DOTA_TEAM_GOODGUYS)
        if gnoll then
            gnoll:SetOwner(newHero0)
            gnoll:SetControllableByPlayer(newHero0:GetPlayerID(), true)
        end
    end

    if secondHeroChineseName == "艾欧" then
        print("创建了")
        local gnoll = CreateUnitByName("npc_dota_roshan", newHero1:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)), true, nil, nil, DOTA_TEAM_BADGUYS)
        if gnoll then
            gnoll:SetOwner(newHero1)
            gnoll:SetControllableByPlayer(newHero1:GetPlayerID(), true)
        end
    end

    if firstHeroChineseName == "末日使者" then
        print("创建了")
        local gnoll = CreateUnitByName("npc_dota_neutral_enraged_wildkin", newHero0:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)), true, nil, nil, DOTA_TEAM_BADGUYS)
        if gnoll then
            gnoll:SetOwner(newHero0)
            gnoll:SetControllableByPlayer(newHero0:GetPlayerID(), true)
        end
    end

    if secondHeroChineseName == "末日使者" then
        print("创建了")
        local gnoll = CreateUnitByName("npc_dota_neutral_enraged_wildkin", newHero1:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)), true, nil, nil, DOTA_TEAM_GOODGUYS)
        if gnoll then
            gnoll:SetOwner(newHero1)
            gnoll:SetControllableByPlayer(newHero1:GetPlayerID(), true)
        end
    end

    if firstHeroChineseName == "魅惑魔女" then
        print("创建了")
        local gnoll = CreateUnitByName("npc_dota_neutral_enraged_wildkin", newHero0:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)), true, nil, nil, DOTA_TEAM_BADGUYS)
        if gnoll then
            gnoll:SetOwner(newHero0)
            gnoll:SetControllableByPlayer(newHero0:GetPlayerID(), true)
        end
    end

    if secondHeroChineseName == "魅惑魔女" then
        print("创建了")
        local gnoll = CreateUnitByName("npc_dota_neutral_enraged_wildkin", newHero1:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)), true, nil, nil, DOTA_TEAM_GOODGUYS)
        if gnoll then
            gnoll:SetOwner(newHero1)
            gnoll:SetControllableByPlayer(newHero1:GetPlayerID(), true)
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
        --CreateAIForHero(dianhun)
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {startTime = GameRules:GetGameTime(),limitTime = limitTime - self.duration})
        local currentTime = Time()
        local formattedTime = string.format("%.2f", currentTime)
        print("[DOTA_RECORD] " .. firstHeroChineseName .. ": 开始战斗")
    end)

    -- 限定时间结束后执行的操作
    Timers:CreateTimer(limitTime, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        -- 停止计时并精确设置前端计时器的时间
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {time = 0})
        


        -- 对英雄再次施加缠绕、缴械、禁锢和破坏效果
        hero_duel.EndDuel = true
        newHero0:AddNewModifier(newHero0, nil, "modifier_disarmed", { duration = self.endduration })
        newHero0:AddNewModifier(newHero0, nil, "modifier_silence", { duration = self.endduration })
        newHero0:AddNewModifier(newHero0, nil, "modifier_rooted", { duration = self.endduration })
        newHero0:AddNewModifier(newHero0, nil, "modifier_break", { duration = self.endduration })

        newHero1:AddNewModifier(newHero1, nil, "modifier_disarmed", { duration = self.endduration })
        newHero1:AddNewModifier(newHero1, nil, "modifier_silence", { duration = self.endduration })
        newHero1:AddNewModifier(newHero1, nil, "modifier_rooted", { duration = self.endduration })
        newHero1:AddNewModifier(newHero1, nil, "modifier_break", { duration = self.endduration })
    end)
end

