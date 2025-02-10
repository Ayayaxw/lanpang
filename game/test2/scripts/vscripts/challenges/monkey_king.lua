function Main:Init_MonkeyKing(heroName, heroFacet,playerID, heroChineseName)
    local currentTime = Time()
    local formattedTime = string.format("%.2f", currentTime)
    print("[DOTA_RECORD] " .. heroChineseName .. ": 更换英雄：".. heroFacet )
    enemyChineseName=self:GetHeroChineseName(Main.AIheroName)
    print("[DOTA_RECORD] " .. enemyChineseName .. ": 创建对手：".. tostring(FacetsNum))

    PlayerResource:SetGold(playerID, 0, false)
    self.duration = 10 -- 保存 duration 以便在 OnUnitKilled 中使用
    self.endduration = 6  -- 保存 duration 以便在 OnUnitKilled 中使用
    local limitTime = self.duration + 60  -- 限定时间为准备时间结束后的一分钟
    -- 设置当前计时器标志
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer

    CreateHero(0, heroName, heroFacet, Vector(-0, -3000, 0), DOTA_TEAM_GOODGUYS, false, function(playerHero)
        playerHero:SetForwardVector(Vector(1,0, 0))
        playerHero:AddItemByName("item_ultimate_scepter_2")
        playerHero:AddItemByName("item_aghanims_shard")
        Timers:CreateTimer(0.5, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            playerHero:AddItemByName("item_black_king_bar")
            --playerHero:AddItemByName("item_blink")
            playerHero:AddItemByName("item_heart")
            

            return nil  -- 确保定时器在执行后不再重复
        end)
        -- playerHero:AddItemByName("item_heart")
        HeroMaxLevel(playerHero)
        -- playerHero:AddNewModifier(playerHero, nil, "modifier_no_cooldown_FirstSkill", {}
        self.newHero = playerHero
        local player = PlayerResource:GetPlayer(0)
        playerHero:SetControllableByPlayer(0, true)
        player:SetAssignedHeroEntity(playerHero)
        Main.currentArenaHeroes[1] = playerHero
    end)
    -- 设置金币和经验
    Timers:CreateTimer(2, function()
        if self.newHero and not self.newHero:IsNull() then
            self.newHero:AddNewModifier(self.newHero, nil, "modifier_no_cooldown_all", { duration = 3 })
        end
    end)

    Main.AIheroName_monkey = "npc_dota_hero_monkey_king"
    FacetsNum_monkey = 1
    Timers:CreateTimer(3, function()
        CreateHero(0, Main.AIheroName_monkey, FacetsNum_monkey, Vector(200, -3000, 0), DOTA_TEAM_GOODGUYS, false, function(enemyBot)
            enemyBot:SetForwardVector(Vector(-1,0, 0))
            enemyBot:AddItemByName("item_ultimate_scepter_2")
            enemyBot:AddItemByName("item_aghanims_shard")
            Timers:CreateTimer(0.5, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                enemyBot:AddItemByName("item_trident")
                enemyBot:AddItemByName("item_heart")
                enemyBot:AddItemByName("item_monkey_king_bar")
                enemyBot:AddItemByName("item_butterfly")
                enemyBot:AddItemByName("item_assault")
                enemyBot:AddItemByName("item_greater_crit")
                enemyBot:AddItemByName("item_moon_shard")
                --enemyBot:SetModelScale(2)

                return nil  -- 确保定时器在执行后不再重复
            end)

            HeroMaxLevel(enemyBot)
            --enemyBot:AddNewModifier(enemyBot, nil, "modifier_no_cooldown_FirstSkill", {})
            --self:ListenHeroHealth(enemyBot)
            Timers:CreateTimer(self.duration-1, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(enemyBot)
                return nil  -- 确保定时器在执行后不再重复
            end)
            -- 根据循环的索引调整存储英雄的数组位置
            Main.currentArenaHeroes[7] = enemyBot
        end)
    end)


    Main.AIheroName = "npc_dota_hero_marci"
    FacetsNum = 2
    -- 定义五边形每个顶点的角度和半径
    local numHeroes = 5
    local radius = 300


    local firstItems = {
        "item_heavens_halberd",  -- 天堂之戟
        "item_sheepstick",       -- 魔杖（羊刀）
        "item_rod_of_atos",      -- 影刃
        "item_bloodthorn",       -- 血棘
        "item_abyssal_blade"     -- 深渊之刃
    }
    local heroes = {}  -- 用于存储创建的英雄对象
    for i = 1, numHeroes do
        -- 计算五边形顶点坐标
        local angle = (2 * math.pi / numHeroes) * (i - 1)
        local x = 200 + radius * math.cos(angle)
        local y = -3000 + radius * math.sin(angle)
    
        CreateHero(0, Main.AIheroName, FacetsNum, Vector(x, y, 0), DOTA_TEAM_BADGUYS, false, function(enemyBot)
            enemyBot:SetForwardVector(Vector(-1, 0, 0))
            enemyBot:AddItemByName("item_ultimate_scepter_2")
            enemyBot:AddItemByName("item_aghanims_shard")
            --enemyBot:AddNewModifier(enemyBot, nil, "modifier_invisible", { duration = 5 })
    
            Timers:CreateTimer(0.5, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return nil end
                
                enemyBot:AddItemByName(firstItems[i])
                enemyBot:AddItemByName("item_heart")
                enemyBot:AddItemByName("item_sange_and_yasha")
                enemyBot:AddItemByName("item_mantle")
                enemyBot:AddItemByName("item_mantle")
                
                enemyBot:AddItemByName("item_mantle")
                return nil  -- 确保定时器在执行后不再重复
            end)
    
            HeroMaxLevel(enemyBot)
            heroes[i] = enemyBot  -- 存储英雄对象到数组
    
            Timers:CreateTimer(self.duration-1, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return nil end
                CreateAIForHero(enemyBot)
                return nil  -- 确保定时器在执行后不再重复
            end)
    
            Main.currentArenaHeroes[i + 1] = enemyBot
    
            -- 在循环的最后一次迭代时调用
            if i == numHeroes then
                Timers:CreateTimer(5, function()
                    if self.currentTimer ~= timerId or hero_duel.EndDuel then return nil end
                    self:ListenHeroHealth(heroes)  -- 用新的方法调用，传入所有英雄的数组
                    return nil
                end)
            end
        end)
    end
    

    Timers:CreateTimer(5, function()
        local heroes = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _, hero in ipairs(heroes) do
            if hero:GetUnitName() == Main.AIheroName  then
                if hero and not hero:IsNull() then
                    hero:AddNewModifier(hero, nil, "modifier_disarmed", { duration = self.duration-5 })
                    hero:AddNewModifier(hero, nil, "modifier_silence", { duration = self.duration-5 })
                    hero:AddNewModifier(hero, nil, "modifier_rooted", { duration = self.duration-5 })
                    hero:AddNewModifier(hero, nil, "modifier_break", { duration = self.duration-5 })
                    hero:AddNewModifier(hero, nil, "modifier_muted", { duration = self.duration-5 })
                    hero:AddNewModifier(hero, nil, "modifier_invisible", { duration = self.duration-5 })
                    hero:AddNewModifier(hero, nil, "modifier_invulnerable", { duration = self.duration-5 })
                    --hero:AddNewModifier(hero, nil, "modifier_damage_attribute_transfer", {})
                    print("添加修饰成功")
                end
            end
        end
    end)

    Timers:CreateTimer(5, function()
        local heroes = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _, hero in ipairs(heroes) do
    
            if hero and not hero:IsNull() then
                local duration = (hero:GetUnitName() == "npc_dota_hero_monkey_king") and (self.duration-5) or (self.duration - 5.5)
                hero:AddNewModifier(hero, nil, "modifier_disarmed", { duration = duration })
                hero:AddNewModifier(hero, nil, "modifier_silence", { duration = duration })
                hero:AddNewModifier(hero, nil, "modifier_rooted", { duration = duration })
                hero:AddNewModifier(hero, nil, "modifier_muted", { duration = duration })
                hero:AddNewModifier(hero, nil, "modifier_break", { duration = duration })
                --hero:AddNewModifier(hero, nil, "modifier_damage_attribute_transfer", {})
                print("添加修饰成功")
            end
    
        end
    end)
    


    local dummy = CreateUnitByName("npc_dota_observer_wards", Vector(100, -3000, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)

    PlayerResource:SetCameraTarget(playerID, dummy)


    hero_duel.EndDuel = false  -- 新增的标志
    local challengedHeroChineseName = self:GetHeroChineseName(Main.AIheroName);
    CustomGameEventManager:Send_ServerToAllClients("reset_timer", {remaining = limitTime - self.duration, heroChineseName = heroChineseName ,challengedHeroChineseName=challengedHeroChineseName})

    Timers:CreateTimer(2, function()
        PlayerResource:SetCameraTarget(playerID, nil)
        if dummy and not dummy:IsNull() then
            dummy:RemoveSelf()
        end
    end)


    Timers:CreateTimer(2, function()
        self:HeroBenefits(heroName,self.newHero)
    end)




    -- 倒计时3秒，在最后一秒喊话“开始”
    Timers:CreateTimer(self.duration - 3, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        --GameRules:SendCustomMessage("3", 0, 0)
    end)
    Timers:CreateTimer(self.duration - 2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        --GameRules:SendCustomMessage("2", 0, 0)
    end)
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        --GameRules:SendCustomMessage("1", 0, 0)
    end)
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        --GameRules:SendCustomMessage("开始！", 0, 0)
        --CreateAIForHero(dianhun)
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
        
        -- 对英雄再次施加缠绕、缴械、禁锢和破坏效果
        hero_duel.EndDuel = true
        newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = self.endduration })
        newHero:AddNewModifier(newHero, nil, "modifier_silence", { duration = self.endduration })
        newHero:AddNewModifier(newHero, nil, "modifier_rooted", { duration = self.endduration })
        newHero:AddNewModifier(newHero, nil, "modifier_break", { duration = self.endduration })
        hero:AddNewModifier(hero, nil, "modifier_disarmed", { duration = self.endduration })
        hero:AddNewModifier(hero, nil, "modifier_silence", { duration = self.endduration })
        hero:AddNewModifier(hero, nil, "modifier_rooted", { duration = self.endduration })
        hero:AddNewModifier(hero, nil, "modifier_break", { duration = self.endduration })
    end)
end


function Main:OnUnitKilled_MonkeyKing(killedUnit, args)

    local killedUnit = EntIndexToHScript(args.entindex_killed)

    if not hero_duel.EndDuel then
        if killedUnit:GetUnitName() == Main.AIheroName then
            -- 调用 hero_duel:UpdateShadowShamanHealth 方法，将暗影萨满的健康值设为 0
            self.deadAIHeroCount = (self.deadAIHeroCount or 0) + 1

            -- 检查是否所有五个英雄都已死亡
            if self.deadAIHeroCount == 5 then
                hero_duel:UpdateShadowShamanHealth(self.newHero, 0)
                hero_duel.EndDuel = true
                print("All five " .. Main.AIheroName .. " have died. Shadow Shaman's health set to 0.")
            end

        -- 检查是否有实体被杀死，且该实体是一个英雄
        elseif killedUnit:IsRealHero() then
            if killedUnit:GetUnitName() == "npc_dota_hero_skeleton_king" then
                local ability = killedUnit:FindAbilityByName("skeleton_king_reincarnation")
                if ability then
                    local cooldownTime = ability:GetCooldownTimeRemaining()
                    local fullCooldown = ability:GetCooldown(ability:GetLevel() - 1)

                    -- 检查重生技能的冷却时间是否在1秒内，这意味着技能刚刚被触发
                    if fullCooldown - cooldownTime < 1 then
                        print("Skeleton King has used Reincarnation and will resurrect.")
                    else
                        -- 如果重生技能冷却时间不在这个范围内，那么认为英雄已彻底死亡
                        hero_duel.EndDuel = true
                        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
                        print("Skeleton King has died permanently. Timer stopped.")
                    end
                end
            elseif killedUnit:GetUnitName() == "npc_dota_hero_monkey_king" then
                -- 其他英雄死亡逻辑
                hero_duel.EndDuel = true
                CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
                print("A player-controlled hero has died. Timer stopped.")
            end
        
        end
    end
end


function Main:OnHeroHealth_MonkeyKing(heroes)
    print("当前挑战：MonkeyKing")
    if not heroes then
        print("英雄列表为空，终止执行")
        return
    end

    -- 移除之前的监听
    if self.heroHealthTimer then
        print("移除已存在的定时器")
        Timers:RemoveTimer(self.heroHealthTimer)
    end

    -- 监听英雄组当前生命值占最大生命值的总百分比
    self.heroHealthTimer = Timers:CreateTimer(0.1, function()
        local totalCurrentHealth = 0
        local totalMaxHealth = 0

        for _, hero in pairs(heroes) do
            -- 检查每个英雄是否仍然存在且有效
            if not hero or hero:IsNull() then
                print("检测到无效英雄，终止此轮计算")
                return nil
            elseif hero_duel.EndDuel then
                print("对决已结束，终止定时器")
                return nil
            end

            -- 累计生命值和最大生命值
            totalCurrentHealth = totalCurrentHealth + hero:GetHealth()
            totalMaxHealth = totalMaxHealth + hero:GetMaxHealth()
        end

        -- 计算总生命值百分比
        local totalHealthPercentage = (totalCurrentHealth / totalMaxHealth) * 100
        totalHealthPercentage = math.ceil(totalHealthPercentage)
        print("总生命值百分比计算结果：", totalHealthPercentage)

        if totalHealthPercentage > 100 then
            totalHealthPercentage = 100
            print("生命百分比超过500，调整为500")
        end

        -- 更新Shadow Shaman的血量百分比，假设需要更新
        hero_duel:UpdateShadowShamanHealth(newHero,totalHealthPercentage)

        -- 继续监听
        return 0.1
    end)
end