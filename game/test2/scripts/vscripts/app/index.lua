if Main == nil then
	Main = class({})
    Main.challengeActive = false
    Main.currentChallenge = nil
	Main.initializedHeroes = {}  
    Main.shouldSpawnCreeps = false
    Main.spawnCount = 0
    Main.AIheroName = "npc_dota_hero_razor"
    Main.currentArenaHeroes = {}
    Main.lastPrint = {}
    Main.totalKills = 0
    Main.printCooldown = 5 -- dotarecord的打印冷却时间，以秒为单位
    Main.sequence_number = 0
end

function Main:GetNextSequenceNumber()
    self.sequence_number = self.sequence_number + 1
    return self.sequence_number
end
AIs = {}


Main.heroesUsedAbility = {} --给拉比克判断敌方是否施法过的

require("app/require")



function SendInitializationMessage(data, order)
    -- 准备要发送的数据

    -- 将数据和顺序一起发送
    local message = {
        data = data,
        order = order
    }

    -- 使用 CustomGameEventManager 发送消息到前端
    CustomGameEventManager:Send_ServerToAllClients("ini_scoreboard", message)
end

function Main:SendCameraPositionToJS(position, duration)
    -- 创建一个包含位置和持续时间的表
    local cameraData = {
        x = position.x,
        y = position.y,
        z = position.z,
        duration = duration
    }
    -- 使用 CustomGameEventManager 发送消息到前端
    CustomGameEventManager:Send_ServerToAllClients("move_camera_position", cameraData)
    print("相机位置数据已发送到前端")
end


function Main:InitGameMode()

    -- Timers:CreateTimer(1, function()
    --     print("正在设置Execute Order Filter")
    --     GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(Main, "ExecuteOrderFilter"), Main)
    -- end)

    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 15)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 15)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 15)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 15)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_3, 15)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_4, 15)
    -- 设置队伍血条颜色
    SetTeamCustomHealthbarColor(DOTA_TEAM_GOODGUYS, 27, 192, 91)      -- 鲜艳的绿色（敏捷）
    SetTeamCustomHealthbarColor(DOTA_TEAM_BADGUYS, 243, 48, 48)       -- 鲜艳的红色（力量）
    SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_1, 61, 141, 255)     -- 亮天蓝色（智力）
    SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_2, 191, 71, 255)     -- 亮紫色（全才）
    SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_3, 255, 146, 0)      -- 明亮的橙色
    SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_4, 65, 255, 255)     -- 青色
    GameRules:LockCustomGameSetupTeamAssignment(true)

    Convars:SetFloat("dota_roshan_upgrade_rate", 10000000)

	-- GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
	GameRules:GetGameModeEntity():SetFixedRespawnTime(99999)
	--GameRules:GetGameModeEntity():SetCameraDistanceOverride(2200)
	GameRules:GetGameModeEntity():SetDaynightCycleDisabled(false)
	GameRules:GetGameModeEntity():SetKillingSpreeAnnouncerDisabled(true)
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
    GameRules:SetTimeOfDay(0.5) -- 0.5代表正午

	

    GameSetup:init()



    -- 加载所有英雄、技能、单位和物品的KV文件

    
	--SpawnCreeps()
    --SpawnAllHeroes("5")
    --Banjiang("npc_dota_hero_bloodseeker","npc_dota_hero_meepo","npc_dota_hero_phantom_assassin")
    --SpawnSelectedHeroes()
	--ListenToGameEvent("npc_spawned", Dynamic_Wrap(self, "OnUnitSpawned"), self)


-------------------------------打印英雄ID-----------------------------------------------------
    -- for i = 1, 150 do
    --     local heroName = DOTAGameManager:GetHeroNameByID(i)
    --     if heroName then
    --         print(string.format('%d: "npc_dota_hero_%s"', i, heroName))
    --     else
    --         print(string.format('%d: "unknown"', i))
    --     end
    -- end



	ListenToGameEvent("entity_killed", Dynamic_Wrap(self, "OnUnitKilled"), self)
    ListenToGameEvent("player_chat", Dynamic_Wrap(self, "OnPlayerChat"), self)
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(self, "OnNPCSpawned"), self)
    ListenToGameEvent("entity_hurt", Dynamic_Wrap(self, "OnAttack"), self)


    CustomGameEventManager:RegisterListener("ChangeHeroRequest", Dynamic_Wrap(self, "HandleCustomGameEvents"))
    CustomGameEventManager:RegisterListener("fc_custom_event", Dynamic_Wrap(self, "SendGameModesData"))
    CustomGameEventManager:RegisterListener("fc_custom_event", Dynamic_Wrap(self, "RequestItemData"))
    CustomGameEventManager:RegisterListener("fc_custom_event", Dynamic_Wrap(self, "RequestStrategyData"))
    CustomGameEventManager:RegisterListener("SetTimescale", Dynamic_Wrap(self, "OnKeyPressed"))
    CustomGameEventManager:RegisterListener("request_unit_info", Dynamic_Wrap(self, "PrintEverythingAboutUnit"))
    CustomGameEventManager:RegisterListener("request_nearby_units_info", Dynamic_Wrap(self, "OnRequestNearbyUnitsInfo"))
    CustomGameEventManager:RegisterListener("SetFogOverride", Dynamic_Wrap(self, "OnFogToggled"))
    CustomGameEventManager:RegisterListener("sandbox_custom_event", Dynamic_Wrap(self, "HandleSandboxEvent"))
    CustomGameEventManager:RegisterListener("sandbox_request", Dynamic_Wrap(self, "RequestSandboxData"))
    --CustomGameEventManager:RegisterListener("set_challenge_type", Dynamic_Wrap(self, "OnSetChallengeType"))

    --ListenToGameEvent( "set_challenge_type", Dynamic_Wrap( self, 'OnSetChallengeType' ), self )


    -- local heroName = "npc_dota_hero_ringmaster"
    -- local heroID = DOTAGameManager:GetHeroIDFromName(heroName)

    -- if heroID ~= -1 then
    --     print("英雄 " .. heroName .. " 的ID是: " .. heroID)
    -- else
    --     print("未找到英雄: " .. heroName)
    -- end

    ListenToGameEvent("dota_non_player_used_ability", Dynamic_Wrap(self, "OnAbilityUsed"),self)
    ListenToGameEvent("dota_ability_channel_finished", Dynamic_Wrap(self, "OnAbilityUsed"),self)
    ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(self, "OnAbilityUsed"),self)
    --ListenToGameEvent("entity_hurt", Dynamic_Wrap(self, "OnEntityHurt"), self)
	--CreateUnitByName("npc_dota_hero_legion_commander", Vector(0,0,500), true, nil, nil, DOTA_TEAM_BADGUYS)


    -- 在服务器端（Lua）
    CustomNetTables:SetTableValue("edit_kv", "test_key", { value = "test_value" })


    Timers:CreateTimer(5, function()
        CustomGameEventManager:Send_ServerToAllClients("Init_ToolsMode", { isToolsMode = IsInToolsMode() })
    end)

    self.caipan = self:CreateReferee(Main.largeSpawnArea_Caipan)
    self.caipan:AddNewModifier(self.caipan, nil, "modifier_global_ability_listener", {})
    
    self.caipan_waterfall = self:CreateReferee(Main.waterFall_Caipan)

    self.currentHeroName = nil  -- 初始化时没有英雄被选中
    if not IsInToolsMode() then
        local message = "游戏的菜单在左上角，把鼠标移过去就可以看见！有任何BUG欢迎加群反馈！Q群：934026049"
        local firstInterval = 5  -- 第一次打印的延迟（秒）
        local regularInterval = 120  -- 常规打印间隔（秒）
        Timers:CreateTimer(firstInterval, function()

            GameRules:SendCustomMessage(message, 0, 0)
            
            Timers:CreateTimer(regularInterval, function()
                GameRules:SendCustomMessage(message, 0, 0)
                return regularInterval
            end)
        end)
    end

end

function Main:CreateReferee(position)
    local referee = CreateUnitByName("caipan", position, true, nil, nil, DOTA_TEAM_BADGUYS)

    referee:AddNewModifier(referee, nil, "modifier_caipan", {})
    referee:AddNewModifier(referee, nil, "modifier_wearable", {})
    referee:AddNewModifier(referee, nil, "modifier_phased", {})
    referee:AddNewModifier(referee, nil, "modifier_disarmed", {})
    referee:SetForwardVector(Vector(0, -1, 0))
    

    StartAnimation(referee, {
        duration = 99999999999999,
        activity = ACT_DOTA_VICTORY,
        rate = 1.0,
        translate = "happy_dance"  -- 使用快乐舞蹈修饰符
    })

    FindClearSpaceForUnit(referee, position, true)
    return referee
end
----------------------------------
function Main:KamiBlessing(targetUnit)
    if not targetUnit or not targetUnit:IsAlive() then return end
    
    -- 在目标单位附近创建Kami
    local spawnPos = targetUnit:GetAbsOrigin() + Vector(100, 0, 0)
    local kami = CreateUnitByName("kami", spawnPos, true, nil, nil, targetUnit:GetTeamNumber())
    
    if not kami  then
        print("kami不见了")
        return end
    
    -- 升级技能
    local ability1 = kami:FindAbilityByName("keeper_of_the_light_chakra_magic")
    if ability1 then
        ability1:SetLevel(4)
    end
    
    -- 添加无敌效果和物品
    kami:AddNewModifier(kami, nil, "modifier_wearable", {})
    local item = kami:AddItemByName("item_cheese")
    
    -- 设置目标并释放技能
    kami:SetCursorCastTarget(targetUnit)
    
    if ability1 then
        ability1:OnSpellStart()
    end
    
    if item then
        item:OnSpellStart()
    end
    
    UTIL_Remove(kami)
end



function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

 function Main:getDefaultIfEmpty(strategies)
    if not strategies or type(strategies) ~= "table" then
        return {"默认策略"}
    end
    
    local validStrategies = {}
    for _, v in pairs(strategies) do
        if type(v) == "string" then
            table.insert(validStrategies, v)
        end
    end
    
    return #validStrategies > 0 and validStrategies or {"默认策略"}
end



function Main:getFacetTooltip(heroName, facetNumber)
    if not heroesFacets[heroName] then
        return nil
    end
    
    local facet = heroesFacets[heroName]["Facets"][facetNumber]
    if not facet then
        return nil
    end

    -- 返回包含两个可能的本地化key的表
    return {
        facetName = facet["name"],
        abilityName = facet["AbilityName"]
    }
end

function Main:createLocalizedMessage(...)
    local parts = {}
    for i, v in ipairs({...}) do
        if type(v) == "table" and v.localize then
            local part = {
                index = i,
                localize = true
            }
            if v.facetInfo then
                part.facetInfo = {
                    facetName = v.facetInfo.facetName,
                    abilityName = v.facetInfo.abilityName
                }
            else
                part.text = v.text
            end
            table.insert(parts, part)
        else
            table.insert(parts, {
                index = i,
                text = tostring(v),
                localize = false
            })
        end
    end

    CustomGameEventManager:Send_ServerToAllClients("localized_message", {
        message_parts = parts
    })

    return true
end



function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%d:%02d", minutes, remainingSeconds)
end

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
-- 辅助函数：检查技能是否在表中
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end



function Main:CreateTrueSightWards(teams)
    local position = Vector(144, 1611.78, 256.00)
    
    for _, team in pairs(teams) do
        local ward = CreateUnitByName(
            "ward",
            position,
            true,
            nil,
            nil,
            team
        )
        
        if ward then
            ward:AddNewModifier(ward, nil, "modifier_invulnerable", {})
            ward:AddNewModifier(ward, nil, "modifier_invisible", {})
            ward:AddNewModifier(ward, nil, "modifier_global_truesight", {})
            ward:AddNewModifier(ward, nil, "modifier_wearable", {})
            ward:AddNoDraw()
        end
    end
end


function Main:GenerateUniqueID()
    self.matchCounter = (self.matchCounter or 0) + 1
    
    local timeStr = "000000"
    local success, result = pcall(function()
        return LocalTime()
    end)
    if success and type(result) == "table" then
        print("LocalTime() result:")
        for k, v in pairs(result) do
            print(k, v)
        end
        
        if result.Hours and result.Minutes and result.Seconds then
            timeStr = string.format("%02d%02d%02d", result.Hours, result.Minutes, result.Seconds)
            print("Time string created:", timeStr)
        else
            print("Expected time fields not found in LocalTime() result")
        end
    else
        print("Error getting time or unexpected result type:", type(result))
    end

    local uniqueID = string.format("%s-%03x", timeStr, self.matchCounter)
    print("Generated ID:", uniqueID)
    
    return uniqueID
end



function Main:PrintKV(name, kvTable, kvType)
    if kvTable and kvTable[name] then
        print(kvType .. " KV for: " .. name)
        for k, v in pairs(kvTable[name]) do
            print(k .. ": " .. tostring(v))
        end
    else
        print(kvType .. " KV not found for: " .. name)
    end
end

function Main:OnRequestNearbyUnitsInfo(event)
    local playerID = event.PlayerID
    local position = Vector(event.position_x, event.position_y, event.position_z)
    local searchRadius = 500
    local units = {}

    print("========== 开始扫描区域实体 ==========")
    print(string.format("搜索中心点: X=%.2f, Y=%.2f, Z=%.2f", position.x, position.y, position.z))
    print("搜索范围: " .. searchRadius .. " 单位")

    local entities = Entities:FindAllInSphere(position, searchRadius)
    print("找到实体数量: " .. #entities)
    print("\n开始处理每个实体的详细信息...")

    for entIndex, entity in pairs(entities) do
        if IsValidEntity(entity) then
            print("\n----- 实体 #" .. entIndex .. " -----")
            print("实体名称: " .. entity:GetName())
            print("类名: " .. entity:GetClassname())
            
            -- 打印模型信息
            if entity.GetModelName then
                print("模型路径: " .. entity:GetModelName())
            else
                print("该实体没有模型信息方法")
            end
            
            local entityInfo = {
                unit_name = entity:GetName(),
                class_name = entity:GetClassname(),
                model_name = entity.GetModelName and entity:GetModelName() or nil,  -- 添加模型信息到发送数据中
                team_number = entity:GetTeamNumber(),
                owner_player_id = -1,
                entity_index = entity:GetEntityIndex(),
                position = {
                    x = entity:GetAbsOrigin().x,
                    y = entity:GetAbsOrigin().y,
                    z = entity:GetAbsOrigin().z
                }
            }

            print(string.format("位置: X=%.2f, Y=%.2f, Z=%.2f", 
                entity:GetAbsOrigin().x, 
                entity:GetAbsOrigin().y, 
                entity:GetAbsOrigin().z))
            print("队伍编号: " .. entity:GetTeamNumber())

            -- 检查单位名称
            if entity.GetUnitName then
                entityInfo.unit_name = entity:GetUnitName()
                print("单位名称: " .. entity:GetUnitName())
            else
                print("该实体没有单位名称方法")
            end

            -- 检查所属玩家
            if entity.GetPlayerOwnerID then
                entityInfo.owner_player_id = entity:GetPlayerOwnerID()
                print("所属玩家ID: " .. entity:GetPlayerOwnerID())
            else
                print("该实体没有所属玩家")
            end

            -- 检查是否是物品
            if entity.IsItem and entity:IsItem() then
                print("类型: 物品")
                entityInfo.is_item = true
                entityInfo.item_name = entity:GetName()
                print("物品名称: " .. entity:GetName())
                
                if entity.GetPurchaser then
                    local purchaser = entity:GetPurchaser()
                    if purchaser then
                        entityInfo.purchaser = purchaser:GetPlayerOwnerID()
                        print("购买者ID: " .. purchaser:GetPlayerOwnerID())
                    else
                        print("物品没有购买者")
                    end
                end
            end

            -- 检查是否是建筑
            if entity.IsBaseNPC and entity:IsBaseNPC() then
                if entity.IsTower and entity:IsTower() then
                    print("类型: 防御塔")
                    entityInfo.is_building = true
                    entityInfo.building_type = "tower"
                elseif entity.IsBarracks and entity:IsBarracks() then
                    print("类型: 兵营")
                    entityInfo.is_building = true
                    entityInfo.building_type = "barracks"
                elseif entity.IsFort and entity:IsFort() then
                    print("类型: 古跡")
                    entityInfo.is_building = true
                    entityInfo.building_type = "ancient"
                end
            end

            -- 检查生命值
            if entity.GetHealth and entity.GetMaxHealth then
                entityInfo.health = entity:GetHealth()
                entityInfo.max_health = entity:GetMaxHealth()
                print(string.format("生命值: %.1f/%.1f", entity:GetHealth(), entity:GetMaxHealth()))
            end

            -- 检查魔法值
            if entity.GetMana and entity.GetMaxMana then
                entityInfo.mana = entity:GetMana()
                entityInfo.max_mana = entity:GetMaxMana()
                print(string.format("魔法值: %.1f/%.1f", entity:GetMana(), entity:GetMaxMana()))
            end

            -- 检查是否是英雄
            if entity.IsHero and entity:IsHero() then
                print("类型: 英雄单位")
                entityInfo.is_hero = true
                
                if entity.GetHeroFacetID then
                    entityInfo.facet_id = entity:GetHeroFacetID()
                    print("FacetID: " .. tostring(entity:GetHeroFacetID()))
                end
                
                entityInfo.level = entity:GetLevel()
                print("英雄等级: " .. entity:GetLevel())

                -- 获取modifier信息
                print("检查状态效果:")
                entityInfo.modifiers = {}
                if entity.FindAllModifiers then
                    local modifiers = entity:FindAllModifiers()
                    print("状态效果总数: " .. #modifiers)
                    
                    for i, modifier in pairs(modifiers) do
                        local modifierName = modifier:GetName()
                        local remainingTime = modifier:GetRemainingTime()
                        local duration = modifier:GetDuration()
                        local stackCount = modifier:GetStackCount()
                        
                        print(string.format("  状态效果 #%d:", i))
                        print("    名称: " .. modifierName)
                        print(string.format("    持续时间: %.2f", duration))
                        print(string.format("    剩余时间: %.2f", remainingTime))
                        print("    层数: " .. stackCount)
                        
                        table.insert(entityInfo.modifiers, {
                            name = modifierName,
                            remaining_time = remainingTime,
                            duration = duration,
                            stack_count = stackCount
                        })
                    end
                else
                    print("该单位没有状态效果系统")
                end
            end

            -- 将实体信息添加到结果列表中
            table.insert(units, entityInfo)
        else
            print("\n实体 #" .. entIndex .. " 无效")
        end
    end

    print("\n========== 扫描完成 ==========")
    print("有效实体总数: " .. #units)

    -- 发送结果给请求的玩家
    CustomGameEventManager:Send_ServerToPlayer(
        PlayerResource:GetPlayer(playerID),
        "response_nearby_units_info",
        {
            units = units,
            total_count = #units,
            search_radius = searchRadius,
            center_position = {
                x = position.x,
                y = position.y,
                z = position.z
            }
        }
    )
    print("数据已发送给玩家 " .. playerID)
    print("================================")
end

function Main:ExecuteSpellCast(spell_data)
    local parent = spell_data.parent
    local ability = spell_data.ability
    local target = spell_data.target
    local behavior = spell_data.behavior
    local targetTeam = spell_data.targetTeam
    local abilityName = spell_data.abilityName
    
    -- 检查实体是否有效
    if not parent or parent:IsNull() or not ability or ability:IsNull() then
        return
    end
    
    -- 检查技能是否是持续施法
    local isChanneled = ability:GetChannelTime() > 0
    
    -- 如果是持续施法技能，使用幻想施法方法
    if isChanneled and abilityName ~= "windrunner_powershot" then
        if spell_data.is_self_cast then
            Main:CreateIllusionAndCast(parent, abilityName, "target", parent)
            return
        end
        
        if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
            Main:CreateIllusionAndCast(parent, abilityName, "no_target", nil)
        elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
            local position
            if targetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
                position = parent:GetAbsOrigin()
            else
                position = (target and not target:IsNull()) and target:GetAbsOrigin() or spell_data.lastPosition
            end
            Main:CreateIllusionAndCast(parent, abilityName, "point", position)
        elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
            local castTarget
            if targetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
                castTarget = parent
            else
                if not target or target:IsNull() then
                    return
                end
                castTarget = target
            end
            Main:CreateIllusionAndCast(parent, abilityName, "target", castTarget)
        else
            if not target or target:IsNull() then
                return
            end
            Main:CreateIllusionAndCast(parent, abilityName, "target", target)
        end
        return
    end
    
    -- 如果不是持续施法技能，使用原来的方式
    if spell_data.is_self_cast then
        parent:SetCursorCastTarget(parent)
        ability:OnSpellStart()
        return
    end
    
    if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) ~= 0 then
        ability:OnSpellStart()
    elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
        if targetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
            parent:SetCursorPosition(parent:GetAbsOrigin())
        else
            -- 使用目标位置或保存的死亡位置
            local position = (target and not target:IsNull()) and target:GetAbsOrigin() or spell_data.lastPosition
            parent:SetCursorPosition(position)
        end
        ability:OnSpellStart()
    elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 then
        if targetTeam == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
            parent:SetCursorCastTarget(parent)
        else
            -- 检查目标有效性
            if not target or target:IsNull() then
                return
            end
            parent:SetCursorCastTarget(target)
        end
        ability:OnSpellStart()
    else
        -- 检查目标有效性
        if not target or target:IsNull() then
            return
        end
        parent:SetCursorCastTarget(target)
        ability:OnSpellStart()
    end
end






function Main:CreateIllusionAndCast(unit, abilityName, castType, castTarget)
    local modifierKeys = {
        outgoing_damage = 1.0,          -- 造成100%伤害
        incoming_damage = 1.0,          -- 承受100%伤害
        bounty_base = 0,                -- 无赏金
        bounty_growth = 0,              -- 无赏金成长
        outgoing_damage_structure = 1.0, -- 对建筑造成100%伤害
        outgoing_damage_roshan = 1.0     -- 对肉山造成100%伤害
    }
    
    local illusions = CreateIllusions(unit, unit, modifierKeys, 1, 0, false, false)


    if abilityName ~= "crystal_maiden_freezing_field" then
        illusions[1]:AddNewModifier(unit, nil, "modifier_wearable", {})
    else
        illusions[1]:AddNewModifier(unit, nil, "modifier_phased", {})
        illusions[1]:AddNewModifier(unit, nil, "modifier_invulnerable", {})
        illusions[1]:AddNewModifier(unit, nil, "modifier_attack_immune", {})
        illusions[1]:AddNewModifier(unit, nil, "modifier_disarmed", {})
    end

    if abilityName ~= "kez_raptor_dance" then
        illusions[1]:AddNoDraw()
    end
    if #illusions > 0 then
        local illusion = illusions[1]
        -- 通过技能名称在幻象身上查找对应技能
        local ability = illusion:FindAbilityByName(abilityName)
        
        
        -- 让幻象释放指定技能
        if ability and not ability:IsNull() then
            -- 根据施法类型设置不同的施法方式
            if castType == "target" then
                illusion:SetCursorCastTarget(castTarget or illusion) -- 如果没有指定目标，则以自身为目标
                ability:OnSpellStart()
            elseif castType == "point" then
                print("施法点",castTarget)
                illusion:SetCursorPosition(castTarget) -- castTarget应为Vector类型坐标
                ability:OnSpellStart()
            elseif castType == "no_target" then
                ability:OnSpellStart()
            end
            
            -- 检查是否是持续施法技能
            local channelTime = ability:GetChannelTime()
            if channelTime > 0 then
                -- 对于持续施法技能，等待持续时间结束后再结束施法
                print("开始持续施法时间",channelTime)
                Timers:CreateTimer(channelTime, function()
                    if illusion and not illusion:IsNull() and ability and not ability:IsNull() then
                        ability:OnChannelFinish(false)
                        print(string.format("【幻象】%s 结束持续施法", illusion:GetUnitName()))
                        
                        -- 为kez_raptor_dance技能特殊处理，延迟3秒后杀死幻象
                        if abilityName == "kez_raptor_dance" then
                            print(string.format("【幻象】%s 使用kez_raptor_dance技能，将在3秒后被杀死", illusion:GetUnitName()))
                            Timers:CreateTimer(1.5, function()
                                if illusion and not illusion:IsNull() then
                                    illusion:ForceKill(false)
                                    print(string.format("【幻象】%s 在延迟3秒后被杀死", illusion:GetUnitName()))
                                end
                            end)
                        else
                            -- 其它技能的幻象在持续施法结束后立即杀死
                            illusion:ForceKill(false)
                            print(string.format("【幻象】%s 在持续施法结束后被杀死", illusion:GetUnitName()))
                        end
                    end
                end)
                print(string.format("【幻象】%s 开始持续施法，持续时间: %.1f秒", illusion:GetUnitName(), channelTime))
            else
                print(string.format("【幻象】%s 已创建并释放了技能", illusion:GetUnitName()))
                

                -- 其它技能的幻象在施法结束后立即杀死
                illusion:ForceKill(false)
                print(string.format("【幻象】%s 在施法结束后被杀死", illusion:GetUnitName()))

            end

            return illusion
        else
            print(string.format("【幻象】%s 无法找到技能: %s", illusion:GetUnitName(), abilityName))
            Timers:CreateTimer(0.1, function()
                -- 无法释放技能时也杀死幻象
                illusion:ForceKill(false)
                print(string.format("【幻象】%s 因无法释放技能被杀死", illusion:GetUnitName()))
                return nil
            end)
        end
    end
    return nil
end




function Main:OnKeyPressed(keys)
    local timescale = keys.timescale
    SendToServerConsole("host_timescale " .. timescale)
end


function Main:OnFogToggled(keys)
    local enable = keys.enable
    if enable == 1 then
        SendToServerConsole("fog_enable 1")
    else
        -- 关闭迷雾
        SendToServerConsole("fog_enable 0")
        SendToServerConsole("r_farz 10000")
    end

end

function Main:UpgradeNeutralCreep(unit, stack_count)
    if not unit or not IsValidEntity(unit) then
        return
    end

    -- 移除原有的Neutral Upgrade技能
    if unit:HasAbility("neutral_upgrade") then
        unit:RemoveAbility("neutral_upgrade")
    end

    -- 添加自定义升级修饰符
    unit:AddNewModifier(unit, nil, "modifier_custom_neutral_upgrade", {stack_count = stack_count})

    -- 计算应该提升的技能等级
    local ability_level_increase = 0
    if stack_count >= 4 then
        ability_level_increase = 2      -- 升至3级
    elseif stack_count >= 2 then
        ability_level_increase = 1      -- 升至2级
    end

    -- 如果需要提升等级
    if ability_level_increase > 0 then
        -- 遍历单位的所有技能
        for i = 0, unit:GetAbilityCount() - 1 do
            local ability = unit:GetAbilityByIndex(i)
            if ability and not ability:IsHidden() then
                -- 获取当前等级
                local current_level = ability:GetLevel()
                -- 设置新等级（最高3级）
                local new_level = math.min(current_level + ability_level_increase, 3)
                ability:SetLevel(new_level)
            end
        end
    end
end

function Main:ExecuteOrderFilter(filterTable)
    print("\n========== 指令执行开始 ==========")
    print("指令类型: " .. self:GetOrderTypeName(filterTable.order_type))
    
    print("完整的 filterTable 内容:")
    DeepPrintTable(filterTable)
    
    print("========== 指令执行结束 ==========\n")
    
    return true
end

function Main:GetOrderTypeName(orderType)
    local orderTypes = {
        [DOTA_UNIT_ORDER_NONE] = "无",
        [DOTA_UNIT_ORDER_MOVE_TO_POSITION] = "移动到位置",
        [DOTA_UNIT_ORDER_MOVE_TO_TARGET] = "移动到目标",
        [DOTA_UNIT_ORDER_ATTACK_MOVE] = "攻击移动",
        [DOTA_UNIT_ORDER_ATTACK_TARGET] = "攻击目标",
        [DOTA_UNIT_ORDER_CAST_POSITION] = "对位置释放技能",
        [DOTA_UNIT_ORDER_CAST_TARGET] = "对目标释放技能",
        [DOTA_UNIT_ORDER_CAST_TARGET_TREE] = "对树释放技能",
        [DOTA_UNIT_ORDER_CAST_NO_TARGET] = "无目标释放技能",
        [DOTA_UNIT_ORDER_CAST_TOGGLE] = "切换技能",
        [DOTA_UNIT_ORDER_HOLD_POSITION] = "保持位置",
        [DOTA_UNIT_ORDER_STOP] = "停止",
        [DOTA_UNIT_ORDER_VECTOR_TARGET_POSITION] = "矢量目标位置",
        -- 可以根据需要添加更多的指令类型
    }
    return orderTypes[orderType] or "未知指令类型"
end


function Main:ShouldPrintMessage(message)
    local currentTime = GameRules:GetGameTime()
    if not self.lastPrint[message] or currentTime - self.lastPrint[message] > self.printCooldown then
        return true
    end
    return false
end



function setCameraPosition(position)
    -- 创建一个假单位作为相机目标
    local dummy = CreateUnitByName("npc_dota_observer_wards", position, true, nil, nil, DOTA_TEAM_GOODGUYS)
    -- 设置相机目标
    PlayerResource:SetCameraTarget(0, dummy)
    -- 创建一个计时器，2秒后移除相机目标并删除假单位
    Timers:CreateTimer(2, function()
        PlayerResource:SetCameraTarget(0, nil)
        if dummy and not dummy:IsNull() then
            dummy:RemoveSelf()
        end
    end)
end


-- 定义一个函数，用于获取英雄的中文名称
function Main:GetHeroChineseName(heroName)
    for _, hero in ipairs(heroes_precache) do
        if hero.name == heroName then
            return hero.chinese
        end
    end
    return "未知英雄"
end



function table.shuffle(tbl)
    local size = #tbl
    local shuffled = {}
    for i, v in ipairs(tbl) do
        shuffled[i] = v
    end
    -- 加入一个随机偏移，避免在同一帧内的调用产生相似结果
    local offset = RandomInt(1, 100)
    for i = size, 2, -1 do
        local j = RandomInt(1, i)
        -- 使用偏移量来影响随机选择
        if offset % 2 == 0 then
            j = (j % i) + 1
        end
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    return shuffled
end
