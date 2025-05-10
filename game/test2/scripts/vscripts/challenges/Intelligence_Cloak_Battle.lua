function Main:Init_Intelligence_Cloak_Battle(event, playerID)
    -- 基础参数初始化

    self.currentMatchID = self:GenerateUniqueID()    
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1 
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    -- 定义时间参数
    self.duration = 10         
    self.endduration = 10      
    self.limitTime = 60       
    hero_duel.EndDuel = false  

    hero_duel.killCount = 0    
    
    -- 设置摄像机位置
    self:SendCameraPositionToJS(Main.smallDuelCenter, 1)
    -- CameraControl:Initialize()
    -- local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    -- self:CreateTrueSightWards(teams)
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_small", {})
                hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = 8})
                hero:AddNewModifier(hero, nil, "modifier_outgoing_damage_reduction", {damage_reduction = 100})
                -- hero:AddNewModifier(hero, nil, "modifier_reduced_ability_cost", {})
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
                if hero:GetUnitName() ~= "ward" then
                    Timers:CreateTimer(0.1, function()
                        hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                    end)
                end
            end,
        }
    }

    -- 获取玩家数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)
    local selfSkillThresholds = self:getDefaultIfEmpty(event.selfSkillThresholds)
    local otherSettings = {skillThresholds = selfSkillThresholds}
    -- 获取英雄名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)

    local ability_modifiers = {
    }
    self:UpdateAbilityModifiers(ability_modifiers)
    -- 播报初始化
    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[智力斗篷挑战]"
    )

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择英雄]",
        {localize = true, text = heroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(heroName, selfFacetId)}
    )

    -- 前端显示初始化
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["神谕者智力斗篷"] = "1000",
        ["力丸智力斗篷"] = "1000",
        ["最终得分"] = "0",
        ["剩余时间"] = self.limitTime,
    }
    local order = {"挑战英雄", "神谕者智力斗篷", "力丸智力斗篷", "最终得分", "剩余时间"}
    hero_duel.oracleItemCount = 1000
    hero_duel.rikimaru_itemCount = 1000
    hero_duel.cloakDifference = 0
    hero_duel.survivalTime = 0
    SendInitializationMessage(data, order)

    -- 创建神谕者和力丸英雄
    self:CreateOracleAndRiki_Intelligence_Cloak_Battle(timerId)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, Main.smallDuelCenter, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

                
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1",0.01, otherSettings)
                return nil
            end)
        end
        -- 移除90%减CD的modifier
        -- playerHero:AddNewModifier(playerHero, nil, "modifier_cooldown_reduction_90", {})

    end)

    -- 赛前准备时间
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = {self.leftTeamHero1}
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
    end)


    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)
    

    Timers:CreateTimer(self.duration-5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        FindClearSpaceForUnit(self.leftTeamHero1, Main.smallDuelCenter, true)
        self:DisableHeroWithModifiers(self.leftTeamHero1, 5)
        self:ResetUnit(self.leftTeamHero1)
    end)


    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
    
        self:SendLeftHeroData(heroName, selfFacetId)
        
        -- 慢动作效果
        Timers:CreateTimer(2, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 0.5")
        end)
        Timers:CreateTimer(3, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 1")
        end)
    end)


    -- 开始信号
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 正式开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.startTime = GameRules:GetGameTime()
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})

        -- 激活AI，开始战斗
        self:StartCombat_Intelligence_Cloak_Battle(timerId)

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    -- 时间结束判定
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true
        
        self.oracle:AddNewModifier(self.oracle, nil, "modifier_disarmed", {})
        self.riki:AddNewModifier(self.riki, nil, "modifier_disarmed", {})

        if hero_duel.cloakDifference > 0 then
            self:PlayVictoryEffects(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功]",
                "最终得分:" .. hero_duel.cloakDifference
            )
        else
            self:PlayDefeatAnimation(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战失败]",
                "最终得分:" .. hero_duel.cloakDifference
            )
        end
    end)
end

-- 创建神谕者和力丸英雄
function Main:CreateOracleAndRiki_Intelligence_Cloak_Battle(timerId)
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
    
    -- 创建神谕者(GOODGUYS)
    local oracleSpawnPos = Vector(
        Main.smallDuelCenter.x - 600,
        Main.smallDuelCenter.y,
        Main.smallDuelCenter.z
    )
    
    self.oracle = CreateUnitByName(
        "npc_dota_hero_oracle", 
        oracleSpawnPos, 
        true, 
        nil, 
        nil, 
        DOTA_TEAM_GOODGUYS
    )

    --self.oracle:AddNewModifier(self.oracle, nil, "modifier_attack_speed_custom", {base_attack_time = 0.00000000, ignore_attack_speed_limit = 1})
    self.oracle:AddNewModifier(self.oracle, nil, "modifier_disarmed", {})
    
    -- 创建力丸(BADGUYS)
    local rikiSpawnPos = Vector(
        Main.smallDuelCenter.x + 600,
        Main.smallDuelCenter.y,
        Main.smallDuelCenter.z
    )
    
    self.riki = CreateUnitByName(
        "npc_dota_hero_riki", 
        rikiSpawnPos, 
        true, 
        nil, 
        nil, 
        DOTA_TEAM_BADGUYS
    )

    --self.riki:AddNewModifier(self.riki, nil, "modifier_attack_speed_custom", {base_attack_time = 0.00000000, ignore_attack_speed_limit = 1})
    self.riki:AddNewModifier(self.riki, nil, "modifier_disarmed", {})
    --朝向南方
    self.riki:SetForwardVector(Vector(-1, 0, 0))
    
    -- 配置两个英雄
    self:ConfigureSpecialHero_Intelligence_Cloak_Battle(self.oracle, "item_mantle_custom", hero_duel.oracleItemCount)
    self:ConfigureSpecialHero_Intelligence_Cloak_Battle(self.riki, "item_mantle_custom", hero_duel.rikimaru_itemCount)
    
    -- 更新UI
    self:UpdateHeroItemCountDisplay_Intelligence_Cloak_Battle()
end

-- 启动战斗
function Main:StartCombat_Intelligence_Cloak_Battle(timerId)
    -- 开始AI
    self:StartHeroAI_Intelligence_Cloak_Battle(self.oracle, self.riki, timerId)
    self:StartHeroAI_Intelligence_Cloak_Battle(self.riki, self.oracle, timerId)
    -- 每0.1秒更新一次英雄头顶的计数
    Timers:CreateTimer(0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        -- 确保实体有效后再更新
        if self.oracle and not self.oracle:IsNull() and self.riki and not self.riki:IsNull() then
            -- 计算当前装备数量
            local oracleItemCount = self:CountHeroItems_Intelligence_Cloak_Battle(self.oracle, "item_mantle_custom")
            local rikiItemCount = self:CountHeroItems_Intelligence_Cloak_Battle(self.riki, "item_mantle_custom")
            
            -- 计算力丸与神谕者的最终得分
            local cloakDifference = rikiItemCount - oracleItemCount
            
            -- 更新全局变量
            hero_duel.oracleItemCount = oracleItemCount
            hero_duel.rikimaru_itemCount = rikiItemCount
            hero_duel.cloakDifference = cloakDifference
            
            -- 更新头顶显示
            self:StartTextMonitor(self.oracle, "智力斗篷数量: " .. oracleItemCount, 20, "hero_score")
            self:StartTextMonitor(self.riki, "智力斗篷数量: " .. rikiItemCount, 20, "hero_score")
            
            -- 更新前端显示
            CustomGameEventManager:Send_ServerToAllClients("update_score", {
                ["神谕者智力斗篷"] = tostring(oracleItemCount),
                ["力丸智力斗篷"] = tostring(rikiItemCount),
                ["最终得分"] = tostring(cloakDifference)
            })
        end
        
        return 0.1
    end)
end

-- 配置特殊英雄
function Main:ConfigureSpecialHero_Intelligence_Cloak_Battle(hero, itemName, itemCount)
    -- 添加英雄等级
    HeroMaxLevel(hero)
    


    

    
    -- 添加装备
    for i = 1, itemCount do
        local item = CreateItem(itemName, hero, hero)
        hero:AddItem(item)
    end
    
    -- 添加头顶显示
    local heroName = hero:GetUnitName() == "npc_dota_hero_oracle" and "神谕者" or "力丸"
    
    -- 确保头顶显示立即生效
    Timers:CreateTimer(0.1, function()
        self:StartTextMonitor(hero,  "智力斗篷数量: " .. itemCount, 20, "hero_score")
    end)
end

-- 英雄AI函数
function Main:StartHeroAI_Intelligence_Cloak_Battle(hero, target, timerId)
    -- 移除缴械效果
    Timers:CreateTimer(0.1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero:RemoveModifierByName("modifier_disarmed")
    end)
    
    -- 开始AI循环
    Timers:CreateTimer(0.1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        
        -- 检查是否能攻击
        if CommonAI:IsUnableToAttack(hero, target) then
            return 0.1
        end
        
        -- 检查当前攻击目标
        local currentTarget = hero:GetAttackTarget()
        if currentTarget == target then
            return 0.1
        end
        
        -- 发出攻击指令
        ExecuteOrderFromTable({
            UnitIndex = hero:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = target:entindex(),
            Queue = false
        })
        
        return 0.1
    end)
end

-- 更新英雄装备数量显示
function Main:UpdateHeroItemCountDisplay_Intelligence_Cloak_Battle()
    -- 检查实体是否存在且有效
    if not self.oracle or self.oracle:IsNull() or not self.riki or self.riki:IsNull() then
        return
    end
    
    -- 计算当前装备数量
    local oracleItemCount = self:CountHeroItems_Intelligence_Cloak_Battle(self.oracle, "item_mantle_custom")
    local rikiItemCount = self:CountHeroItems_Intelligence_Cloak_Battle(self.riki, "item_mantle_custom")
    
    -- 计算力丸与神谕者的最终得分
    local cloakDifference = rikiItemCount - oracleItemCount
    
    -- 更新全局变量
    hero_duel.oracleItemCount = oracleItemCount
    hero_duel.rikimaru_itemCount = rikiItemCount
    hero_duel.cloakDifference = cloakDifference
    
    -- 更新头顶显示
    local oracleHeroName = "神谕者"
    local rikiHeroName = "力丸"
    
    -- 清除并重新设置头顶显示，确保每次更新都能被正确显示
    self:StartTextMonitor(self.oracle, "智力斗篷数量: " .. oracleItemCount, 20, "hero_score")
    self:StartTextMonitor(self.riki, "智力斗篷数量: " .. rikiItemCount, 20, "hero_score")
    
    -- 更新前端显示
    CustomGameEventManager:Send_ServerToAllClients("update_score", {
        ["智力斗篷数量"] = tostring(oracleItemCount),
        ["智力斗篷数量"] = tostring(rikiItemCount),
        ["最终得分"] = tostring(cloakDifference)
    })
end

-- 计算英雄特定物品数量
function Main:CountHeroItems_Intelligence_Cloak_Battle(hero, itemName)
    local count = 0
    for i = 0, 8 do
        local item = hero:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            -- 获取物品堆叠数量而不是物品数量
            count = count + item:GetCurrentCharges()
        end
    end
    return count
end

-- 单位死亡判定
function Main:OnUnitKilled_Intelligence_Cloak_Battle(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    if not killedUnit or killedUnit:IsNull() or hero_duel.EndDuel then return end

    -- 玩家死亡判定
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS and killedUnit == self.leftTeamHero1 then
        hero_duel.EndDuel = true  -- 在发送消息前先设置结束标志
        
        if hero_duel.cloakDifference > 0 then
            self:PlayVictoryEffects(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战成功]",
                "最终得分:" .. hero_duel.cloakDifference
            )
        else
            self:PlayDefeatAnimation(self.leftTeamHero1)
            self:createLocalizedMessage(
                "[LanPang_RECORD][",
                self.currentMatchID,
                "]",
                "[挑战失败]",
                "最终得分:" .. hero_duel.cloakDifference
            )
        end
        
        return
    end

    -- 神谕者或力丸死亡判定
    if killedUnit:IsRealHero() and (killedUnit == self.oracle or killedUnit == self.riki) then
        -- 再次检查游戏是否已结束（以防在处理过程中游戏结束）
        if hero_duel.EndDuel then return end

        -- 直接结束游戏
        hero_duel.EndDuel = true
        
        -- 判断哪个英雄死亡，并基于当前最终得分确定输赢
        local resultMessage
        if killedUnit == self.oracle then
            -- 神谕者死亡，玩家胜利
            self:PlayVictoryEffects(self.leftTeamHero1)
            resultMessage = "[挑战成功] 神谕者已阵亡!"
        else
            -- 力丸死亡，玩家失败
            self:PlayDefeatAnimation(self.leftTeamHero1)
            resultMessage = "[挑战失败] 力丸已阵亡!"
        end
        
        -- 添加最终得分信息
        resultMessage = resultMessage .. " 最终得分:" .. hero_duel.cloakDifference
        
        -- 发送结束消息
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            resultMessage
        )
    end
end


function Main:OnNPCSpawned_Intelligence_Cloak_Battle(spawnedUnit, event)
    spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_outgoing_damage_reduction", {damage_reduction = 100})
    spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_damage_reduction", {damage_reduction = 100})
end