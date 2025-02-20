-- 清理函数
function Main:Cleanup_MillGrinding()

end

-- 初始化函数
function Main:Init_MillGrinding(event, playerID)
    -- 基础参数初始化
    self.currentMatchID = self:GenerateUniqueID()    
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1 
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 60        -- 比赛时间
    hero_duel.EndDuel = false  -- 标记战斗是否结束

    -- 设置摄像机位置
    self:SendCameraPositionToJS(Main.largeSpawnCenter + Vector(0, -200, 0), 1)

    -- 计数初始化
    hero_duel.totalRotation = 0
    hero_duel.laps = 0
    hero_duel.lastAngle = nil

    -- 单人模式数据获取
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)

    -- 获取英雄名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)

    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    -- 设置英雄配置
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})
                HeroMaxLevel(hero)
                --hero:AddNewModifier(hero, nil, "modifier_maximum_attack", {})
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
                hero:AddNewModifier(hero, nil, "modifier_auto_bullwhip", {})

            end,
        }
    }

    -- 裁判控制台播报
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
    hero_duel.finalScore = 0
    -- 修改前端观众播报，添加得分显示
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["已转圈数"] = "0",
        ["剩余时间"] = self.limitTime,
        ["当前得分"] = "0",
    }
    local order = {"挑战英雄", "已转圈数", "剩余时间", "当前得分"}
    SendInitializationMessage(data, order)

    -- 创建玩家英雄
    CreateHero(playerID, heroName, selfFacetId, Main.largeSpawnCenter + Vector(0, -700, 0), DOTA_TEAM_GOODGUYS, false, function(playerHero)
        self:ConfigureHero(playerHero, true, playerID)
        self:EquipHeroItems(playerHero, selfEquipment)
        self.leftTeamHero1 = playerHero
        self.currentArenaHeroes[1] = playerHero
        local mofang = CreateUnitByName("mofang", Main.largeSpawnCenter, true, nil, nil, DOTA_TEAM_GOODGUYS)
        mofang:AddNewModifier(mofang, nil, "modifier_rooted", {})
        mofang:AddNewModifier(mofang, nil, "modifier_wearable", {})

                -- 创建魔方单位
        local kongbai = CreateUnitByName("kongbai", Main.largeSpawnCenter, true, nil, nil, DOTA_TEAM_GOODGUYS)
        kongbai:SetHullRadius(450)
        kongbai:AddNewModifier(kongbai, nil, "modifier_custom_out_of_game", {})


        if selfAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1")
                return nil
            end)
        end


        -- 创建NPC人马
        CreateHero(playerID, "npc_dota_hero_centaur", 1, Main.largeSpawnCenter + Vector(0, -500, 0), DOTA_TEAM_BADGUYS, false, function(centaur)
            centaur:RemoveAbility("centaur_rawhide")
            centaur:RemoveAbility("special_bonus_movement_speed_20")
            self.rightTeamHero1 = centaur
            self.currentArenaHeroes[2] = centaur
            centaur:AddNewModifier(centaur, nil, "modifier_auto_elevation_large", {})
            HeroMaxLevel(centaur)
            -- 添加初始状态
            centaur:AddNewModifier(centaur, nil, "modifier_rooted", {})
            centaur:AddNewModifier(centaur, nil, "modifier_invulnerable", {})
    
            -- 添加运动限制
            centaur:AddNewModifier(centaur, nil, "modifier_custom_rolling", {
                x = Main.largeSpawnCenter.x,
                y = Main.largeSpawnCenter.y,
                z = Main.largeSpawnCenter.z,
                radius = 500
            })
            
            centaur:AddNewModifier(centaur, nil, "modifier_custom_coil", {
                x = Main.largeSpawnCenter.x,
                y = Main.largeSpawnCenter.y,
                z = Main.largeSpawnCenter.z,
                radius = 500
            })

            -- 设置魔方朝向和圈数计算
            mofang:SetContextThink("MofangFaceThink", function()
                if IsValidEntity(centaur) and IsValidEntity(mofang) then
                    local heroPos = centaur:GetAbsOrigin()
                    local mofangPos = mofang:GetAbsOrigin()
                    local direction = (heroPos - mofangPos):Normalized()
                    --mofang:SetForwardVector(direction)
                    
                    local currentAngle = math.atan2(heroPos.y - Main.largeSpawnCenter.y, 
                                                  heroPos.x - Main.largeSpawnCenter.x)
                    
                    if hero_duel.lastAngle then
                        local angleDiff = currentAngle - hero_duel.lastAngle
                        if angleDiff > math.pi then
                            angleDiff = angleDiff - 2 * math.pi
                        elseif angleDiff < -math.pi then
                            angleDiff = angleDiff + 2 * math.pi
                        end
                        
                        hero_duel.totalRotation = hero_duel.totalRotation + angleDiff
                        local newLaps = math.floor(math.abs(hero_duel.totalRotation) / (2 * math.pi))
                        
                        if newLaps > hero_duel.laps then
                            hero_duel.laps = newLaps
                            
                            -- 更新圈数和得分
                            if newLaps < 10 then
                                hero_duel.finalScore = newLaps
                            else
                                local timeSpent = GameRules:GetGameTime() - hero_duel.startTime
                                local remainingTime = self.limitTime - timeSpent
                                hero_duel.finalScore = 10 + math.floor(remainingTime)
                            end
            
                            -- 更新前端显示
                            CustomGameEventManager:Send_ServerToAllClients("update_score", {
                                ["已转圈数"] = tostring(newLaps),
                                ["当前得分"] = tostring(hero_duel.finalScore)
                            })
                            
                        
                            local mango = CreateItem("item_famango", nil, nil)
                            local container = CreateItemOnPositionSync(mofang:GetAbsOrigin(), mango)
                            EmitSoundOn("ui.ready_check.yes", mofang)
                            
                            local startPos = mofang:GetAbsOrigin()
                            local duration = 1.2
                            local startTime = GameRules:GetGameTime()
                            
                            Timers:CreateTimer(function()
                                if not IsValidEntity(container) or not IsValidEntity(self.leftTeamHero1) then
                                    if IsValidEntity(container) then
                                        UTIL_Remove(container)
                                    end
                                    return nil
                                end
                        
                                local currentTime = GameRules:GetGameTime()
                                local elapsed = currentTime - startTime
                                local progress = elapsed / duration
                                
                                if progress >= 1.0 then
                                    UTIL_Remove(container)
                                    local new_mango = CreateItem("item_famango", self.leftTeamHero1, self.leftTeamHero1)
                                    self.leftTeamHero1:AddItem(new_mango)
                                    return nil
                                else
                                    local currentEndPos = self.leftTeamHero1:GetAbsOrigin()
                                    local newPos = startPos + (currentEndPos - startPos) * progress
                                    newPos.z = startPos.z + math.sin(progress * math.pi) * 400
                                    container:SetAbsOrigin(newPos)
                                    return 0.03
                                end
                            end)

                            -- 判断胜利条件
                            if newLaps >= 10 and not hero_duel.EndDuel then
                                hero_duel.EndDuel = true
                                
                                -- 给人马添加禁锢
                                if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
                                    self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_rooted", {})
                                    self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_invulnerable", {})
                                end
                                
                                -- 计算剩余时间和最终得分
                                local timeSpent = GameRules:GetGameTime() - hero_duel.startTime
                                local remainingTime = math.max(0, self.limitTime - timeSpent)
                                local formattedTime = string.format("%02d:%02d.%02d", 
                                    math.floor(remainingTime / 60),
                                    math.floor(remainingTime % 60),
                                    math.floor((remainingTime * 100) % 100))
                                
                                hero_duel.finalScore = 10 + math.floor(remainingTime)
                                
                                -- 更新前端显示
                                CustomGameEventManager:Send_ServerToAllClients("update_score", {
                                    ["剩余时间"] = formattedTime,
                                    ["当前得分"] = tostring(hero_duel.finalScore)
                                })
                                
                                self:PlayVictoryEffects(self.leftTeamHero1)
                                
                                -- 发送胜利消息
                                self:createLocalizedMessage(
                                    "[LanPang_RECORD][",
                                    self.currentMatchID,
                                    "]",
                                    "[挑战成功],最终得分:" .. hero_duel.finalScore
                                )
                            end
                        end
                    end
                    
                    hero_duel.lastAngle = currentAngle
                    return 0.03
                end
                return nil
            end, 0)
        end)
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
        FindClearSpaceForUnit(self.leftTeamHero1, Main.largeSpawnCenter + Vector(0, -700, 0), true)
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

    -- 开始计时
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.startTime = GameRules:GetGameTime()
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
    
        -- 移除人马的限制
        if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
            self.rightTeamHero1:RemoveModifierByName("modifier_rooted")
            self.rightTeamHero1:RemoveModifierByName("modifier_invulnerable")
        end
    
        -- 给英雄添加鞭子并保存引用
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            local bullwhip = self.leftTeamHero1:AddItemByName("item_bullwhip")
        end
    
        -- 启动移动速度监控
        if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
            -- 初始化显示



            self:StartTextMonitor(
                self.rightTeamHero1,
                "当前移速: " .. math.floor(self.rightTeamHero1:GetBaseMoveSpeed()),
                16,
                "#00FF00"
            )
            
            -- 创建移动速度监控定时器
            Timers:CreateTimer(function()
                if hero_duel.EndDuel then 
                    return 
                end
                
                if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
                    local currentSpeed = math.floor(self.rightTeamHero1:GetBaseMoveSpeed())
                    
                    -- 根据速度设置颜色和大小
                    local color = "#00FF00"  -- 默认绿色
                    local fontSize = 16      -- 默认大小
                    
                    if currentSpeed > 2000 then
                        color = "#FF0000"    -- 红色
                        fontSize = 24        -- 更大字体
                    elseif currentSpeed > 500 then
                        color = "#FFD700"    -- 黄色
                        fontSize = 20        -- 稍大字体
                    end
                    
                    -- 更新显示的文本
                    self:UpdateText(
                        self.rightTeamHero1,
                        "当前移速: " .. currentSpeed,
                        fontSize,
                        color
                    )
                end
                
                return 0.03  -- 约30帧每秒的更新频率
            end)
        end
    
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    -- 时间到结束处理
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true

        -- 给人马添加禁锢
        if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
            self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_rooted", {})
        end
        
        -- 最终得分就是圈数（如果没有达到10圈）
        if hero_duel.laps < 10 then
            hero_duel.finalScore = hero_duel.laps
        end

        self:PlayDefeatAnimation(self.leftTeamHero1)

        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败],最终得分:" .. hero_duel.finalScore
        )
        self:gradual_slow_down(self.leftTeamHero1:GetOrigin(), self.leftTeamHero1:GetOrigin())
        
        CustomGameEventManager:Send_ServerToAllClients("update_score", {
            ["剩余时间"] = "0",
            ["当前得分"] = tostring(hero_duel.finalScore)
        })
    end)
end


function Main:OnUnitKilled_MillGrinding(killedUnit, args)

    local killedUnit = EntIndexToHScript(args.entindex_killed)
    local killer = EntIndexToHScript(args.entindex_attacker)
    
    if not killedUnit or killedUnit:IsNull() then return end


    -- 判断是否是玩家英雄死亡
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
        -- 计算最终得分 (使用当前累积的分数，取整)
        local finalScore = math.floor(hero_duel.finalScore)
        
        -- 发送记录消息
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[挑战失败],最终得分:" .. finalScore
        )
        -- 发送最终结果给前端
        self:PlayDefeatAnimation(self.leftTeamHero1)

        self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_invulnerable", {})
        self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_rooted", {})
        
        -- 计算并格式化剩余时间
        local endTime = GameRules:GetGameTime()
        local timeSpent = endTime - hero_duel.startTime
        local remainingTime = self.limitTime - timeSpent
        local formattedTime = string.format("%02d:%02d.%02d", 
            math.floor(remainingTime / 60),
            math.floor(remainingTime % 60),
            math.floor((remainingTime * 100) % 100))
        CustomGameEventManager:Send_ServerToAllClients("update_score", {["剩余时间"] = formattedTime})
        hero_duel.EndDuel = true
        return
    end
    
end
function Main:OnNPCSpawned_MillGrinding(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end