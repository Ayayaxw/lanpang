function Main:Cleanup_Work_Work()

end

function Main:Init_Work_Work(event, playerID)
    hero_duel.EndDuel = false  
    PrintManager.luosiKillCount = 0
    PrintManager.alchemistKillCount = 0
    print("Counters reset: luosi =", self.luosiKillCount, "alchemist =", self.alchemistKillCount)
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
--[[     local ability_modifiers = {
        npc_dota_hero_ringmaster = {
            ringmaster_tame_the_beasts = {
                -- AbilityCooldown = 0,
                -- AbilityChannelTime = 1,       
                -- AbilityCastRange = 99999,        
                -- AbilityManaCost = 0, 
                
            }
        },
    }

    self:UpdateAbilityModifiers(ability_modifiers) ]]
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    -- 设置英雄配置
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})
                hero:AddNewModifier(hero, nil, "modifier_rooted", {duration = 5})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
                HeroMaxLevel(hero)
                
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
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation", {})
            end,
        }
    }

    -- 从 event 中获取新的数据
    local selfHeroId = event.selfHeroId or -1
    local selfFacetId = event.selfFacetId or -1
    local opponentHeroId = event.opponentHeroId or -1
    local opponentFacetId = event.opponentFacetId or -1
    local selfAIEnabled = (event.selfAIEnabled == 1)
    local opponentAIEnabled = (event.opponentAIEnabled == 1)
    local selfEquipment = event.selfEquipment or {}
    local opponentEquipment = event.opponentEquipment or {}
    local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)
    local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)
    local opponentOverallStrategy = self:getDefaultIfEmpty(event.opponentOverallStrategies)
    local opponentHeroStrategy = self:getDefaultIfEmpty(event.opponentHeroStrategies)


    -- 获取玩家和对手的英雄名称及中文名称
    local heroName, heroChineseName = self:GetHeroNames(selfHeroId)
    local opponentHeroName, opponentChineseName = self:GetHeroNames(opponentHeroId)
    SendToServerConsole("host_timescale 1")          --游戏速度

    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer
    self.PlayerChineseName = heroChineseName

    PlayerResource:SetGold(playerID, 0, false)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 60        -- 限定时间为准备时间结束后的一分钟
    hero_duel.EndDuel = false  -- 标记战斗是否结束

    SendCameraPositionToJS(Main.Work_Work_Camera, 2)

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
    SendInitializationMessage(data, order)
    CreateHero(0, heroName, selfFacetId, Main.Work_Work, DOTA_TEAM_GOODGUYS, false, function(playerHero)
        playerHero:SetForwardVector(Vector(0,-1, 0))
        playerHero:AddItemByName("item_ultimate_scepter_2")
        playerHero:AddItemByName("item_aghanims_shard")
        playerHero:AddItemByName("item_broom_handle")
        playerHero:AddNewModifier(playerHero, nil, "modifier_kv_editor", {})
        playerHero:AddNewModifier(playerHero, nil, "attribute_stack_modifier", {})
        playerHero:AddNewModifier(playerHero, nil, "modifier_rooted", { duration = 5 })
        HeroMaxLevel(playerHero)
        if playerHero:GetUnitName() == "npc_dota_hero_ogre_magi" then
            local extraGold = 2024
            playerHero:ModifyGold(extraGold, true, DOTA_ModifyGold_Unspecified)
            print("食人魔魔法师获得额外金钱：", extraGold)
        end


        -- 新增：购买小树枝的逻辑
        local heroGold = playerHero:GetGold()
        local multiplier = math.floor(heroGold / 50)
        if multiplier > 0 then
            local goldToSpend = multiplier * 50
            playerHero:SpendGold(goldToSpend, DOTA_ModifyGold_Unspecified)
            for i = 1, multiplier do
                playerHero:AddItemByName("item_iron_branch_custom")
            end
        end
        
        self.leftTeamHero1 = playerHero
        local player = PlayerResource:GetPlayer(0)
        playerHero:SetControllableByPlayer(0, true)
        player:SetAssignedHeroEntity(playerHero)
        Main.currentArenaHeroes[1] = playerHero
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



    Timers:CreateTimer(5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_disarmed", { duration = self.duration-5 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_silence", { duration = self.duration-5 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = self.duration-5 })
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_break", { duration = self.duration-5 })

        end
    end)


    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = {self.leftTeamHero1}
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
        end
    end)
    --英雄小礼物

    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    Timers:CreateTimer(self.duration - 0.5, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)
    end)

    -- 比赛即将开始
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        CreateUnits(self,timerId)
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
    end)
end


function Main:OnUnitKilled_Work_Work(killedUnit, args)
    -- 获取被杀死的单位
    print("Counters reset: luosi =", PrintManager.luosiKillCount, "alchemist =", PrintManager.alchemistKillCount)
    local killedUnit = EntIndexToHScript(args.entindex_killed)
    
    -- 获取击杀者（可能为 nil）
    local killerEntity = args.entindex_attacker and EntIndexToHScript(args.entindex_attacker) or nil

    if killedUnit then
        -- 检查被击杀的单位是否为 luosi
        if killedUnit:GetUnitName() == "luosi" then

            PrintManager.luosiKillCount = PrintManager.luosiKillCount + 1

            -- 如果有击杀者，处理击杀奖励
            if killerEntity then
                local heroEntity = killerEntity
                if not killerEntity:IsRealHero() or killerEntity:IsClone() then
                    if killerEntity:IsClone() then
                        heroEntity = killerEntity:GetCloneSource()
                    elseif killerEntity.GetPlayerOwnerID then
                        heroEntity = self.leftTeamHero1
                    end
                end

                if heroEntity and heroEntity:IsRealHero() then
                    -- 给予英雄一个自定义树枝物品
                    heroEntity:AddItemByName("item_iron_branch_custom")

                    -- 检查英雄是否是炼金术师
                    if heroEntity:GetUnitName() == "npc_dota_hero_alchemist" then
                        -- 初始化炼金术师的击杀计数

                        PrintManager.alchemistKillCount = PrintManager.alchemistKillCount + 1
                        
                        -- 计算额外金钱奖励
                        local extraGold = math.min(2 * PrintManager.alchemistKillCount, 18)
                        print("炼金击杀数,金钱奖励",PrintManager.alchemistKillCount,extraGold)
                        heroEntity:ModifyGold(extraGold, true, DOTA_ModifyGold_Unspecified)
                        print("炼金术师获得额外金钱：", extraGold)
                    end

                    

                    -- 检查英雄的金钱是否是50的倍数
                    local heroGold = heroEntity:GetGold()
                    print("有金钱：",heroGold)
                    local multiplier = math.floor(heroGold / 50)
                    if multiplier > 0 then
                        -- 扣除相应的金钱
                        local goldToSpend = multiplier * 50
                        heroEntity:SpendGold(goldToSpend, DOTA_ModifyGold_Unspecified)
                        -- 给予相应数量的额外自定义树枝物品
                        for i = 1, multiplier do
                            heroEntity:AddItemByName("item_iron_branch_custom")
                        end
                    end

                    local particle = ParticleManager:CreateParticle("particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf", PATTACH_ABSORIGIN, killedUnit)
                    ParticleManager:SetParticleControl(particle, 1, killedUnit:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(particle)

                    local particle2 = ParticleManager:CreateParticle("particles/econ/events/spring_2021/hero_levelup_spring_2021_godray.vpcf", PATTACH_ABSORIGIN, self.leftTeamHero1)
                    ParticleManager:SetParticleControl(particle2, 0, self.leftTeamHero1:GetAbsOrigin())
                    ParticleManager:ReleaseParticleIndex(particle2)

                    EmitSoundOn("General.Coins", heroEntity)
                end
            end
        end
    end
end

function CreateUnits(self, timerId)
    -- 创建左边的发条技师
    local leftClockwerk = CreateUnitByName("npc_dota_hero_rattletrap", Vector(-1550.94, -7496.29, 128.00), true, nil, nil, DOTA_TEAM_GOODGUYS)
    SetupClockwerk(leftClockwerk, 0)
    leftClockwerk:SetForwardVector(Vector(1, 0, 0))  -- 朝向右边

    -- 创建右边的发条技师
    self.rightClockwerk = CreateUnitByName("npc_dota_hero_rattletrap", Vector(1332.87, -7476.62, 128.00), true, nil, nil, DOTA_TEAM_GOODGUYS)
    SetupClockwerk(self.rightClockwerk, 1)
    self.rightClockwerk:SetForwardVector(Vector(-1, 0, 0))  -- 朝向左边

    -- 设置创建 luosi 的位置
    local spawnPosition = Vector(-1300.04, -7500.42, 128.00)

    -- 初始间隔时间
    local spawnInterval = 2.0
    local startTime = GameRules:GetGameTime()
    local minInterval = 0.01 -- 最小间隔时间
    local luosiCount = 0 -- 计数器，记录已生成的 luosi 数量
    local isProducing = true -- 标记是否仍在生产
    local lastLuosisEntIndices = {} -- 用于存储停止生产前最后10个生成的螺丝的EntIndex


    local function checkLastLuosis()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        if self.lastLuosisEntIndices and #self.lastLuosisEntIndices > 0 then
            local allLuosisDead = true
            for _, entIndex in ipairs(self.lastLuosisEntIndices) do
                local luosi = EntIndexToHScript(entIndex)
                if luosi and luosi:IsAlive() then
                    allLuosisDead = false
                    break
                end
            end

            if allLuosisDead then
                print("All last luosis are dead, triggering end sequence")
                self:TriggerEndSequence()
                return nil -- 停止定时器
            end
        end
        return 0.5 -- 每0.5秒检查一次
    end


    -- 创建一个计时器，每隔一定时间创建一个 luosi
    Timers:CreateTimer(function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel or not isProducing then return end

        local luosi = CreateLuosiWithSkin(spawnPosition)
        luosiCount = luosiCount + 1
        
        -- 标记最后10个螺丝的EntIndex
        if #lastLuosisEntIndices < 20 then
            table.insert(lastLuosisEntIndices, luosi:entindex())
        else
            table.remove(lastLuosisEntIndices, 1)
            table.insert(lastLuosisEntIndices, luosi:entindex())
        end
        
        -- 让发条技师做攻击动作
        leftClockwerk:StartGesture(ACT_DOTA_ATTACK)

        
        local currentTime = GameRules:GetGameTime()
        
        -- 每生成10个 luosi 后调整频率
        if luosiCount % 10 == 0 and currentTime - startTime > 20 then
            spawnInterval = math.max(minInterval, spawnInterval * 0.7)
        end

        -- 如果间隔时间已经达到最小值，停止生成
        if spawnInterval <= minInterval then
            print("luosi 生成已达到最大速度，停止生产")
            isProducing = false
            self.lastLuosisEntIndices = lastLuosisEntIndices -- 保存最后10个螺丝的EntIndex到self中
            print("Set self.lastLuosisEntIndices with " .. #self.lastLuosisEntIndices .. " entries")
            
            -- 开始监测最后10个螺丝的状态
            Timers:CreateTimer(checkLastLuosis)
            
            return nil -- 返回 nil 以停止计时器
        end

        return spawnInterval -- 下一次执行的间隔
    end)
end

function Main:TriggerEndSequence()
    -- 触发结束序列
    self.leftTeamHero1:Stop()
    Timers:CreateTimer(0.03, function()
        self.leftTeamHero1:SetForwardVector(Vector(0, -1, 0))
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_damage_reduction_100", { duration = self.endduration })
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_rooted", { duration = self.endduration })
        self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_disable_healing", { duration = self.endduration })
        self.leftTeamHero1:StartGesture(ACT_DOTA_VICTORY)
    end)

    local heroName = self.leftTeamHero1:GetUnitName()

    self:gradual_slow_down(Vector(0, 0, 0), self.leftTeamHero1:GetOrigin())

    local particle1 = ParticleManager:CreateParticle("particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", PATTACH_ABSORIGIN, self.leftTeamHero1)
    ParticleManager:SetParticleControl(particle1, 0, self.leftTeamHero1:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle1)



    -- 获取 attribute_stack_modifier 的层数作为得分
    local score = 0
    local attributeStackModifier = self.leftTeamHero1:FindModifierByName("attribute_stack_modifier")
    if attributeStackModifier then
        score = attributeStackModifier:GetStackCount()
    end

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[玩家得分]",
        tostring(score)
    )

    -- 清空 lastLuosisEntIndices，防止重复触发
    self.lastLuosisEntIndices = nil
end
-- 设置发条技师的函数
function SetupClockwerk(unit, playerID)
    unit:AddNewModifier(unit, nil, "modifier_disarmed", {})
    unit:AddItemByName("item_ultimate_scepter_2")
    unit:AddItemByName("item_aghanims_shard")
    unit:AddNewModifier(unit, nil, "modifier_kv_editor", {})

    HeroMaxLevel(unit)

end

function CreateLuosiWithSkin(position)
    -- 创建 luosi 单位
    local luosi = CreateUnitByName("luosi", position, true, nil, nil, DOTA_TEAM_BADGUYS)
    luosi:AddNewModifier(luosi, nil, "modifier_luosi_damage_limiter", {})
    luosi:AddNewModifier(luosi, nil, "modifier_magic_immune", {})
    luosi:AddNewModifier(luosi, nil, "modifier_phased", {})
    

    -- 创建 luosipi 作为可穿戴假人
    local luosipiDummy = CreateUnitByName("luosipi", luosi:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)

    if luosipiDummy then
        -- 设置 luosipi 假人的属性
        luosipiDummy:FollowEntity(luosi, true)
    
        luosipiDummy:AddNewModifier(luosipiDummy, nil, "modifier_wearable", {})

        -- 将假人关联到 luosi
        luosi.wearableDummy = luosipiDummy
        

    else
        print("螺丝出问题啦")
    end
    return luosi
end


function Main:OnNPCSpawned_Work_Work(spawnedUnit, event)
    -- 如果不是被排除的单位，则应用战场效果
    if not self:isExcludedUnit(spawnedUnit) then
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")
    end
end