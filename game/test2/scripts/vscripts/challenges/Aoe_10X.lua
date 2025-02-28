function Main:Init_Aoe_10X(event, playerID)
    -- 技能修改器
    self.courierPool = {}
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    hero_duel.killCount = 0    -- 初始化击杀计数器
    print("[DEBUG] Kill count reset to:", hero_duel.killCount) -- 添加调试打印
    local ability_modifiers = {
    }
    -- 设置英雄配置
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    Main:AmplifyAbilityAOE(10)
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                local heroName = hero:GetUnitName()
                if heroName ~= "npc_dota_hero_invoker" then
                    hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                end
                
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_full_restore", {}) -- 给英雄添加修饰器
                local item = hero:AddItemByName("item_gungir")
                if not item then return end

                hero:RemoveItem(item)
            end,
        },
        FRIENDLY = {
            function(hero)
                hero:SetForwardVector(Vector(1, 0, 0))
                -- 可以在这里添加更多友方英雄特定的操作
            end,
        },
        ENEMY = {
            function(hero)
                hero:SetForwardVector(Vector(-1, 0, 0))
                -- 可以在这里添加敌方英雄特定的操作
            end,
        },
        BATTLEFIELD = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})

            end,
        }
    }

    -- 从 event 中获取新的数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)


    -- 获取玩家和对手的英雄名称及中文名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)


    self:UpdateAbilityModifiers(ability_modifiers)

    -- 设置游戏速度
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer
    self.PlayerChineseName = heroChineseName

    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 99999, true)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 60        
    hero_duel.EndDuel = false  -- 标记战斗是否结束

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[新挑战]"
    )

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择绿方]",
        {localize = true, text = heroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(heroName, selfFacetId)}
    )

    -- 发送初始化消息给前端
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["剩余时间"] = self.limitTime,
        ["击杀数量"] = "0",
        ["当前总分"] = "0"  -- 添加当前总分
    }
    local order = {"挑战英雄", "剩余时间", "击杀数量", "当前总分"}
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, self.largeSpawnCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        -- 如果启用了AI，为玩家英雄创建AI
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1")

                return nil
            end)
        else
            -- 处理非 AI 情况
        end
    end)


    -- 给英雄添加小礼物
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroPreparation(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
        self:HeroBenefits(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)


        -- 直接设置到 CustomNetTables，保持完整的数据结构

        
        --Main:UpdateAbilityModifiers(ability_modifiers)


        -- CustomNetTables:SetTableValue("edit_kv", "npc_dota_hero_dragon_knight_dragon_tail", {
        --     dragon_aoe = {
        --         value = "0",
        --         special_bonus_unique_dragon_knight_8 = "+1600",
        --         affected_by_aoe_increase = "1"
        --     }
        -- })
        
        
    end)

    -- 赛前限制
    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        -- 给双方英雄添加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.duration - 5 })
            end
            if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
                self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, modifier, { duration = self.duration - 5 })
            end
        end
    end)

    -- 发送摄像机位置给前端
    self:SendCameraPositionToJS(Main.largeSpawnCenter, 1)

    -- 比赛即将开始
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 比赛开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeamHero1:CalculateStatBonus(true)
        self.startTime = GameRules:GetGameTime() -- 记录开始时间
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:PreSpawnSniper()
    end)


    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        self:SendLeftHeroData(heroName, selfFacetId)
        Timers:CreateTimer(2, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 0.5")
        end)
        Timers:CreateTimer(3, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 1")
        end)
    end)

    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true
    
        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})
    
        -- 计算最终得分
        local finalScore = hero_duel.killCount * 10  -- 基础击杀得分

        -- 对英雄再次施加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.endduration })
            end
        end
    
        -- 记录结果
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战完成]击杀数:" .. hero_duel.killCount .. ",最终得分:" .. finalScore
        )
        local data = {
            ["击杀数量"] = hero_duel.killCount,
            ["剩余时间"] = "0",
            ["当前总分"] = finalScore
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)
        -- 结束决斗并更新UI，显示胜利和得分
        CustomGameEventManager:Send_ServerToAllClients("update_final_score", {
            result = "victory",
            survivalTime = "01:00.00",  -- 满时间
            killCount = hero_duel.killCount,
            finalScore = finalScore
        })
    
        -- 播放胜利效果
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self:PlayVictoryEffects(self.leftTeamHero1)
        end
    end)
end

function Main:PreSpawnSniper()
    -- 获取矩形四个角的坐标
    local left = self.largeSpawnArea_northWest.x
    local right = self.largeSpawnArea_northEast.x
    local top = self.largeSpawnArea_northWest.y
    local bottom = self.largeSpawnArea_southWest.y
    local sniperPool = {}

    -- 计算区域宽度和高度
    local width = right - left
    local height = top - bottom
    
    -- 要生成的总单位数
    local totalSnipers = 100
    
    -- 计算理想的行列数
    local aspectRatio = width / height
    
    -- 尝试不同的行列组合，找到最均匀的分布
    local bestRows, bestCols = 1, totalSnipers
    local bestRemainder = totalSnipers
    
    for r = 1, totalSnipers do
        local c = math.ceil(totalSnipers / r)
        local remainder = (r * c) - totalSnipers
        
        -- 优先选择填满或接近填满的组合
        if remainder >= 0 and remainder <= bestRemainder then
            -- 检查这个组合的宽高比是否接近矩形的宽高比
            local gridRatio = c / r
            if math.abs(gridRatio - aspectRatio) < math.abs(bestCols / bestRows - aspectRatio) or bestRemainder > remainder then
                bestRows = r
                bestCols = c
                bestRemainder = remainder
            end
        end
    end
    
    local rows = bestRows
    local cols = bestCols
    
    print("使用网格: " .. rows .. " 行 x " .. cols .. " 列 (总共: " .. rows*cols .. " 个位置，需要放置: " .. totalSnipers .. " 个单位)")
    
    -- 计算精确步长，确保覆盖整个区域
    local xStep = width / (cols - 1)
    local yStep = height / (rows - 1)
    
    -- 特殊情况处理
    if cols == 1 then xStep = 0 end
    if rows == 1 then yStep = 0 end
    
    -- 创建所有单位
    local count = 0
    for i = 0, rows - 1 do
        for j = 0, cols - 1 do
            -- 确保不超过所需的单位数量
            if count >= totalSnipers then
                break
            end
            
            -- 计算均匀分布的位置
            local xPercent = (cols == 1) and 0.5 or (j / (cols - 1))
            local yPercent = (rows == 1) and 0.5 or (i / (rows - 1))
            
            local spawnX = left + (width * xPercent)
            local spawnY = bottom + (height * yPercent)
            local spawnPos = Vector(spawnX, spawnY, self.largeSpawnArea_northWest.z)
            
            -- 创建狙击手单位
            local sniper = CreateUnitByName(
                "sniper",
                spawnPos,
                true,
                nil,
                nil,
                DOTA_TEAM_BADGUYS
            )
            
            if sniper then
                -- 删除所有技能
                for i = 0, 3 do
                    local ability = sniper:GetAbilityByIndex(i)
                    if ability then
                        sniper:RemoveAbility(ability:GetAbilityName())
                    end
                end

                sniper:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", {})
                sniper:AddNewModifier(self.leftTeamHero1, nil, "modifier_disarmed", {})
                sniper:AddNewModifier(sniper, nil, "modifier_invulnerable", {duration = 8.0})



                HeroMaxLevel(sniper)
                -- 面向中心点
                local centerPoint = Vector((left + right) / 2, (top + bottom) / 2, self.largeSpawnArea_northWest.z)
                local direction = (centerPoint - spawnPos):Normalized()
                sniper:SetForwardVector(direction)
                
                table.insert(sniperPool, sniper)
                count = count + 1
            end
        end
    end
    
    print("实际生成单位数量: " .. count)
    self.sniperPool = sniperPool
end

function Main:OnUnitKilled_Aoe_10X(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)

    if hero_duel.EndDuel then return end

    -- 先检查是否是玩家英雄死亡
    if killedUnit == self.leftTeamHero1 then
        self:ProcessHeroDeath_Aoe_10X(killedUnit, killer)
        return -- 英雄死亡后直接返回，不再处理其他逻辑
    end

    -- 如果不是英雄死亡，检查是否是马格纳斯死亡
    if killedUnit:GetUnitName() == "sniper" then
        self:ProcessHeroDeath_Aoe_10X(killedUnit, killer)
    end
end
function Main:ProcessHeroDeath_Aoe_10X(killedUnit, killer)
    local function CalculateCurrentScore()
        return hero_duel.killCount * 10
    end

    -- print("ProcessHeroDeath_Aoe_10X called for unit: ", killedUnit:GetUnitName())
    
    if killedUnit:GetUnitName() == "sniper" then
        -- 播放击杀特效
        if killer then
            local particle = ParticleManager:CreateParticle(
                "particles/generic_gameplay/lasthit_coins_local.vpcf", 
                PATTACH_ABSORIGIN, 
                killedUnit
            )
            ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)
            EmitSoundOn("General.Coins", killer)
        end

        -- 更新击杀数和得分
        hero_duel.killCount = hero_duel.killCount + 1
        local currentScore = CalculateCurrentScore() -- 只计算击杀得分
        local data = {
            ["击杀数量"] = hero_duel.killCount,
            ["当前总分"] = currentScore
        }
        CustomGameEventManager:Send_ServerToAllClients("update_score", data)

        -- 保存死亡位置
        local spawnPosition = killedUnit:GetAbsOrigin()

        -- 一秒后重生英雄
        Timers:CreateTimer(1.0, function()
            if not killedUnit:IsNull() then
                killedUnit:RespawnHero(false, false)
                FindClearSpaceForUnit(killedUnit, spawnPosition, true)
                
                -- 设置为玩家0控制
                killedUnit:SetControllableByPlayer(0, true)
                killedUnit:RemoveModifierByName("modifier_fountain_invulnerability")
                -- 添加禁锢和缴械效果
                killedUnit:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", {})
                killedUnit:AddNewModifier(self.leftTeamHero1, nil, "modifier_disarmed", {})
            end
        end)
    end
end

function Main:OnNPCSpawned_Aoe_10X(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end