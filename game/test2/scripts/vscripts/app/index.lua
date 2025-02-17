
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

Main.northWest = Vector(-1850, 1450, 128)
Main.northEast = Vector(1850, 1450, 128)
Main.southWest = Vector(-1850, -750, 128)
Main.southEast = Vector(1850, -750, 128)
Main.SnipeCenter = Vector(8575, -10270, 128)
Main.largeSpawnCenter = Vector(150, 150, 128)
Main.largeSpawnArea = Vector(100, 500, 128)
Main.smallDuelArea = Vector(150, -2800, 128)
Main.smallDuelCenter = Vector(150, -3000, 128)
Main.smallDuelAreaLeft = Vector(-800, -3000, 128)
Main.smallDuelAreaRight = Vector(1000, -3000, 128)
Main.Save_Mor = Vector(2403, 5441, 128)
Main.Work_Work = Vector(-134, -7500, 128)
Main.Work_Work_Camera = Vector(-130, -7500, 128)
Main.heroesUsedAbility = {} --给拉比克判断敌方是否施法过的

Main.heroListKV = LoadKeyValues('scripts/npc/npc_heroes.txt')
Main.unitListKV = LoadKeyValues('scripts/npc/npc_units.txt')

Main.abilityListKV = {}
Main.originAbility = {}
Main.original_values = {}

-- 初始化必要的表
Main.heroAbilities = Main.heroAbilities or {}
Main.originAbility = Main.originAbility or {}
-- 加载通用技能
local npc_abilities = LoadKeyValues('scripts/npc/npc_abilities.txt')
if npc_abilities then
    Main.genericAbilities = npc_abilities
end

-- 加载英雄特定技能
if Main.heroListKV then
    for hero_name, hero_data in pairs(Main.heroListKV) do
        -- 检查 hero_name 是否真的是一个英雄名
        if type(hero_data) == "table" and hero_name:sub(1, 14) == "npc_dota_hero_" and hero_name ~= "npc_dota_hero_base" then
            Main.heroAbilities[hero_name] = {}
            Main.originAbility[hero_name] = {}
            local hero_abilities_path = 'scripts/npc/heroes/' .. hero_name .. '.txt'
            local hero_abilities = LoadKeyValues(hero_abilities_path)
            if hero_abilities then
                for k, v in pairs(hero_abilities) do
                    Main.heroAbilities[hero_name][k] = v
                    Main.originAbility[hero_name][k] = true
                end
                -- print("Successfully loaded abilities for hero: " .. hero_name)
            else
                print("Warning: Unable to load abilities for hero: " .. hero_name)
                print("Attempted to load from: " .. hero_abilities_path)
            end
        else
            print("Skipping non-hero entry: " .. hero_name)
        end
    end
else
    print("Warning: Main.heroListKV is not initialized")
end

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

function SendCameraPositionToJS(position, duration)
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
	print( "Template addon is loaded." )
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



	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
	GameRules:GetGameModeEntity():SetFixedRespawnTime(99999)
	--GameRules:GetGameModeEntity():SetCameraDistanceOverride(2200)
	GameRules:GetGameModeEntity():SetDaynightCycleDisabled(false)
	GameRules:GetGameModeEntity():SetKillingSpreeAnnouncerDisabled(true)
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
    GameRules:SetTimeOfDay(0) -- 0.5代表正午

	

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
    CustomGameEventManager:RegisterListener("request_unit_info", Dynamic_Wrap(self, "OnRequestUnitInfo"))
    CustomGameEventManager:RegisterListener("request_nearby_units_info", Dynamic_Wrap(self, "OnRequestNearbyUnitsInfo"))
    CustomGameEventManager:RegisterListener("SetFogOverride", Dynamic_Wrap(self, "OnFogToggled"))
    --CustomGameEventManager:RegisterListener("set_challenge_type", Dynamic_Wrap(self, "OnSetChallengeType"))

    --ListenToGameEvent( "set_challenge_type", Dynamic_Wrap( self, 'OnSetChallengeType' ), self )



    -- local heroName = "npc_dota_hero_ringmaster"
    -- local heroID = DOTAGameManager:GetHeroIDFromName(heroName)

    -- if heroID ~= -1 then
    --     print("英雄 " .. heroName .. " 的ID是: " .. heroID)
    -- else
    --     print("未找到英雄: " .. heroName)
    -- end

    --ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(self, "OnAbilityUsed"), self)

    --ListenToGameEvent("entity_hurt", Dynamic_Wrap(self, "OnEntityHurt"), self)
	--CreateUnitByName("npc_dota_hero_legion_commander", Vector(0,0,500), true, nil, nil, DOTA_TEAM_BADGUYS)
	self.caipan = CreateUnitByName("caipan", Vector(144.5, 1600, 0), true, nil, nil, DOTA_TEAM_BADGUYS)

    -- 在服务器端（Lua）
    CustomNetTables:SetTableValue("edit_kv", "test_key", { value = "test_value" })



    Timers:CreateTimer(2, function()
        self.caipan:SetControllableByPlayer(0, true)
    end)

    Timers:CreateTimer(5, function()
        CustomGameEventManager:Send_ServerToAllClients("Init_ToolsMode", { isToolsMode = IsInToolsMode() })
    end)


    self.caipan:AddNewModifier(self.caipan, nil, "modifier_global_ability_listener", {})
    self.caipan:AddNewModifier(self.caipan, nil, "modifier_caipan", {})
    self.caipan:AddNewModifier(self.caipan, nil, "modifier_wearable", {})
    self.caipan:AddNewModifier(self.caipan, nil, "modifier_phased", {})
    

	-- Setting the forward direction to face towards a specific point, e.g., facing downwards on the map
	self.caipan:SetForwardVector(Vector(0, -1, 0))
	-- self.caipan:AddItemByName("item_gem")
    -- --unit:AddItemByName("item_roshans_banner")
    -- self.caipan:AddItemByName("item_sphere")






    -- local unit = CreateUnitByName("caipan", Vector(-4000, 5000, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)



	-- -- --unit:AddNewModifier(unit, nil, "modifier_invulnerable", {})
	-- -- -- Setting the forward direction to face towards a specific point, e.g., facing downwards on the map
	-- -- unit:SetForwardVector(Vector(0, -1, 0))
	-- unit:AddItemByName("item_gem")
    -- --unit:AddItemByName("item_roshans_banner")
    -- unit:AddItemByName("item_sphere")
    -- unit:AddNewModifier(unit, nil, "modifier_invulnerable", {})
    -- Timers:CreateTimer(10, function()
    --     item = unit:GetItemInSlot(0)
    --     caipanitem = self.caipan:GetItemInSlot(0)
    --     if item then
    --         unit:CastAbilityOnPosition(unit:GetOrigin(), item,unit:GetPlayerOwnerID())
    --         self.caipan:CastAbilityOnPosition(self.caipan:GetOrigin(),caipanitem, self.caipan:GetPlayerOwnerID())
    --     end

    -- end)
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

----------------------------------

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



function Main:SendHeroAndFacetData(leftHeroName, rightHeroName, LeftFacetID, RightFacetID,limitTime)
    -- 将单个 facet 数据转换为可序列化的格式
    local function convertSingleFacetToSerializable(heroName, facetID)
        local heroData = heroesFacets[heroName]
        if heroData and heroData["Facets"] then
            local facet = heroData["Facets"][facetID]  -- 使用整数索引访问 facet

            if facet then
                -- 准备序列化的 Facet 数据
                return {
                    [tostring(facetID)] = {
                        name = facet["name"],
                        color = facet["Color"],
                        gradientId = facet["GradientID"],
                        icon = facet["Icon"],
                        abilityName = facet["AbilityName"] or ""
                    }
                }
            else
                print("未找到 ID 对应的 Facet: ", facetID)
            end
        else
            print("未找到英雄或 Facets 数据：", heroName)
        end
        return {}
    end
    
    local serializedLeftFacet = convertSingleFacetToSerializable(leftHeroName, LeftFacetID)
    local serializedRightFacet = convertSingleFacetToSerializable(rightHeroName, RightFacetID)

    -- 打印即将发送的 Facet 数据
    print("即将发送的左侧英雄 Facet 数据：", serializedLeftFacet)
    print("即将发送的右侧英雄 Facet 数据：", serializedRightFacet)

    -- 发送事件，包含指定的 facet 数据和 AbilityName
    CustomGameEventManager:Send_ServerToAllClients("show_hero", {
        selfFacets = serializedLeftFacet,
        opponentFacets = serializedRightFacet,
        Time = limitTime,
    })
end

function Main:SendLeftHeroData(leftHeroName, LeftFacetID)
    -- 将单个 facet 数据转换为可序列化的格式
    local function convertSingleFacetToSerializable(heroName, facetID)
        local heroData = heroesFacets[heroName]
        if heroData and heroData["Facets"] then
            local facet = heroData["Facets"][facetID]  -- 使用整数索引访问 facet

            if facet then
                -- 准备序列化的 Facet 数据
                return {
                    [tostring(facetID)] = {
                        name = facet["name"],
                        color = facet["Color"],
                        gradientId = facet["GradientID"],
                        icon = facet["Icon"],
                        abilityName = facet["AbilityName"] or ""
                    }
                }
            else
                print("未找到 ID 对应的 Facet: ", facetID)
            end
        else
            print("未找到英雄或 Facets 数据：", heroName)
        end
        return {}
    end

    -- 使用 DOTA 2 API 根据英雄名称获取 hero ID
    local heroID = DOTAGameManager:GetHeroIDByName(leftHeroName)
    
    if not heroID then
        print("无法找到英雄 ID：", leftHeroName)
        return
    end

    local serializedLeftFacet = convertSingleFacetToSerializable(leftHeroName, LeftFacetID)

    -- 打印即将发送的数据
    print("即将发送的左侧英雄数据：", "Hero ID:", heroID, "Facet 数据:", serializedLeftFacet)

    -- 发送事件，包含左侧英雄的 hero ID 和 facet 数据
    CustomGameEventManager:Send_ServerToAllClients("show_left_hero", {
        heroID = heroID,
        facets = serializedLeftFacet
    })
end

-- 辅助函数：根据英雄名称获取 hero ID
function GetHeroID(heroName)
    local heroEntity = CreateHeroForPlayer(heroName, nil)
    if heroEntity then
        local heroID = heroEntity:GetHeroID()
        UTIL_Remove(heroEntity)  -- 移除临时创建的英雄实体
        return heroID
    else
        print("无法创建英雄实体：", heroName)
        return nil
    end
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

    -- 调试输出
    -- print("Sending data to client:")
    -- DeepPrintTable(parts)

    CustomGameEventManager:Send_ServerToAllClients("localized_message", {
        message_parts = parts
    })

    return true
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



function Main:GetOriginalAbilityValue(hero_name, ability_name)
    -- 先检查英雄特定技能
    local ability = self.heroAbilities[hero_name] and self.heroAbilities[hero_name][ability_name]
    -- 如果在英雄特定技能中找不到，则检查通用技能
    if not ability then
        ability = self.genericAbilities[ability_name]
    end
    
    if ability then
        local flat_data = {}
        -- 提取特殊值
        if ability.AbilitySpecial then
            for _, special in pairs(ability.AbilitySpecial) do
                for k, v in pairs(special) do
                    if k ~= "var_type" then
                        flat_data[k] = v
                    end
                end
            end
        end
        -- 提取其他数值属性
        for k, v in pairs(ability) do
            if type(v) == 'number' or (type(v) == 'string' and v:match("^%d+%.?%d*[%s%d%.]*$")) then
                flat_data[k] = v
            end
        end
        return flat_data
    end
    return nil
end

function Main:RestoreOriginalValues()
    -- 恢复所有记录过的原始值
    for key, original_data in pairs(self.original_values) do
        CustomNetTables:SetTableValue("edit_kv", key, original_data)
    end
    
    -- 打印恢复后的状态
    print("已恢复以下键值的原始数据：")
    for key, _ in pairs(self.original_values) do
        print(key)
        local current_data = CustomNetTables:GetTableValue("edit_kv", key)
        if current_data then
            DeepPrintTable(current_data)
        end
    end
end

function Main:UpdateAbilityModifiers(ability_modifiers)
    for hero_name, hero_abilities in pairs(ability_modifiers) do
        for ability_name, ability_data in pairs(hero_abilities) do
            local key = hero_name .. "_" .. ability_name
            -- 如果这个键还没有记录过原始值
            if not self.original_values[key] then
                local original_data = self:GetOriginalAbilityValue(hero_name, ability_name)
                if original_data then
                    self.original_values[key] = original_data
                end
            end
        end
    end

    local function PrintEditKvContents()
        local found_data = false
        
        for hero_name, hero_abilities in pairs(ability_modifiers) do
            for ability_name, _ in pairs(hero_abilities) do
                local key = hero_name .. "_" .. ability_name
                local data = CustomNetTables:GetTableValue("edit_kv", key)
                if data then
                    found_data = true
                    -- Uncomment the following lines for debugging
                    -- print("Key: " .. key)
                    -- DeepPrintTable(data)
                end
            end
        end
        
        if not found_data then
            print("edit_kv 表是空的或没有找到任何数据")
        end
    end

    -- 设置新数据
    for hero_name, hero_abilities in pairs(ability_modifiers) do
        for ability_name, ability_data in pairs(hero_abilities) do
            local ability_index = hero_name .. "_" .. ability_name
            
            -- 新建一个平坦的表，用于存储特殊值
            local flat_data = {}
            
            local function flattenAbilityData(data)
                -- Ensure 'data' is a table
                if type(data) ~= 'table' then
                    return
                end
                
                -- 处理 AbilityValues
                if data['AbilityValues'] and type(data['AbilityValues']) == 'table' then
                    for special_name, special_data in pairs(data['AbilityValues']) do
                        if type(special_data) == 'table' then
                            if special_data['value'] then
                                flat_data[special_name] = special_data['value']
                            end
                            -- If there are nested tables inside special_data, recursively process them
                            flattenAbilityData(special_data)
                        else
                            -- Handle the case where special_data is not a table
                            -- Uncomment for debugging
                            -- print("Warning: Expected 'special_data' to be a table, got " .. type(special_data))
                        end
                    end
                end
                
                -- 处理直接在 data 下的数值和数值字符串
                for k, v in pairs(data) do
                    if k ~= 'AbilityValues' then
                        if type(v) == 'number' then
                            flat_data[k] = v
                        elseif type(v) == 'string' then
                            if v:match("^%d+%.?%d*[%s%d%.]*$") then  -- 如果是数值字符串
                                flat_data[k] = v
                            end
                        elseif type(v) == 'table' then
                            -- 递归处理嵌套表
                            flattenAbilityData(v)
                        else
                            -- Handle unexpected types
                            -- Uncomment for debugging
                            -- print("Warning: Unexpected type for key '" .. k .. "': " .. type(v))
                        end
                    end
                end
            end
            
            flattenAbilityData(ability_data)
            
            -- 只有在有数据时才设置
            if next(flat_data) then
                CustomNetTables:SetTableValue("edit_kv", ability_index, flat_data)
            else
                -- Uncomment for debugging
                -- print("Warning: No valid data for " .. ability_index)
            end
        end
    end
    
    -- 打印更新后的内容
    PrintEditKvContents()
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
        end
    end
end

function Main:ClearAllUnitsExcept()
    local exceptName = "caipan"
    print("开始清理全图所有单位和物品，除了名字为 '" .. exceptName .. "' 的单位")

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
        if unit and IsValidEntity(unit) and unit:GetUnitName() ~= exceptName then
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
                    unit:RemoveModifierByName("modifier_invulnerable")
                    Timers:CreateTimer(0.1, function()
                        local playerID = unit:GetPlayerID()
                        UTIL_Remove(unit)
                        DisconnectClient(playerID, true)
                    end)
                else
                    -- 移除无敌状态
                    unit:RemoveModifierByName("modifier_invulnerable")
                    local playerID = unit:GetPlayerID()
                    UTIL_Remove(unit)
                    DisconnectClient(playerID, true)
                end
            else
                -- 非英雄单位的处理
                unit:RemoveAllModifiers(0, true, true, true)  -- 移除所有(0)修饰器，立即移除，永久移除，不是死亡导致的移除

                -- 移除无敌状态
                unit:RemoveModifierByName("modifier_invulnerable")

                -- 强制杀死单位
                unit:ForceKill(false)

                -- 如果单位还存在，尝试直接移除
                if IsValidEntity(unit) then
                    UTIL_Remove(unit)
                end
            end

            removedCount = removedCount + 1
        end
    end

    print("清理完成，共移除 " .. removedCount .. " 个单位，" .. removedItemCount .. " 个物品")
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

function Main:MonitorUnitsStatus()
    -- 计算队伍基础状态的函数
    local function calculateTeamStats(team)
        local totalHealth = 0
        local totalMaxHealth = 0
        local totalMana = 0
        local totalMaxMana = 0
        local totalAverageDamage = 0
        local totalArmor = 0
        local totalAttackSpeed = 0
        local totalMagicResistance = 0
        local totalMoveSpeed = 0
        local totalStrength = 0
        local totalAgility = 0
        local totalIntellect = 0
        local heroCount = #team
    
        for i, hero in ipairs(team) do
            if hero and not hero:IsNull() then
                totalHealth = totalHealth + (hero:IsAlive() and hero:GetHealth() or 0)
                totalMaxHealth = totalMaxHealth + hero:GetMaxHealth()
                totalMana = totalMana + hero:GetMana()
                totalMaxMana = totalMaxMana + hero:GetMaxMana()
                totalAverageDamage = totalAverageDamage + hero:GetAverageTrueAttackDamage(nil)
                totalArmor = totalArmor + hero:GetPhysicalArmorValue(false)
                totalAttackSpeed = totalAttackSpeed + hero:GetAttackSpeed(false)
                totalMagicResistance = totalMagicResistance + hero:Script_GetMagicalArmorValue(false, nil)
                
                local baseSpeed = hero:GetBaseMoveSpeed()
                local moveSpeedModifier = hero:GetMoveSpeedModifier(baseSpeed, false)
                totalMoveSpeed = totalMoveSpeed + moveSpeedModifier
                
                totalStrength = totalStrength + hero:GetStrength()
                totalAgility = totalAgility + hero:GetAgility()
                totalIntellect = totalIntellect + hero:GetIntellect(false)
            end
        end
    
        local stats = {
            currentHealth = totalHealth,
            maxHealth = totalMaxHealth,
            currentMana = totalMana,
            maxMana = totalMaxMana,
            averageDamage = math.floor(totalAverageDamage / heroCount + 0.5),
            armor = math.floor(totalArmor / heroCount + 0.5),
            attackSpeed = math.floor((totalAttackSpeed / heroCount) * 100),
            magicResistance = string.format("%.2f%%", (totalMagicResistance / heroCount) * 100),
            moveSpeed = math.floor(totalMoveSpeed / heroCount + 0.5),
            strength = math.floor(totalStrength / heroCount + 0.5),
            agility = math.floor(totalAgility / heroCount + 0.5),
            intellect = math.floor(totalIntellect / heroCount + 0.5)
        }
    
        return stats
    end

    -- 收集基础状态数据
    local statsData = {
        Left = calculateTeamStats(self.leftTeam),
        Right = calculateTeamStats(self.rightTeam)
    }

    -- 发送基础状态数据到前端
    CustomGameEventManager:Send_ServerToAllClients("update_unit_status", statsData)
    
    -- 调用技能状态监控函数
    --self:MonitorAbilitiesStatus()
end


function Main:ClearAbilitiesPanel()
    -- 发送清理信号到前端
    CustomGameEventManager:Send_ServerToAllClients("clear_abilities_panels", {})
    CustomGameEventManager:Send_ServerToAllClients("hide_hero_chaos_container", {})
    CustomGameEventManager:Send_ServerToAllClients("hide_hero_chaos_score", {})

end

function Main:MonitorAbilitiesStatus(hero,enableOverlapDetection)
    if not hero or hero:IsNull() then 
        --print("[技能监控] 英雄对象为空或无效")
        return 
    end
    
    --print("[技能监控] 开始监控英雄:", hero:GetUnitName())
    
    local function getHeroType(heroName)
        --print("[英雄类型] 正在查找英雄类型:", heroName)
        for _, heroData in pairs(heroes_precache) do
            if heroData.name == heroName then
                --print("[英雄类型] 找到英雄类型:", heroData.type)
                return heroData.type
            end
        end
        --print("[英雄类型] 未找到类型，使用默认值(1)")
        return 1
    end
    
    local function calculateAbilitiesStatus(hero)
        --print("[技能状态] 开始计算英雄技能状态:", hero:GetUnitName())
        local heroAbilities = {}
        local sortedAbilities = {}
        local abilityCount = 0
        
        for abilitySlot = 0, 23 do
            local ability = hero:GetAbilityByIndex(abilitySlot)
            if ability and not ability:IsNull() and not ability:IsHidden() then
                --print(string.format("[技能信息] 槽位 %d: %s", abilitySlot, ability:GetAbilityName()))
                
                local isPassiveAndNotLearnable = 
                    bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_PASSIVE) ~= 0 and 
                    bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) ~= 0
                
                if not string.find(ability:GetAbilityName(), "special_bonus") and 
                   not (ability:IsPassive() and ability:GetMaxLevel() == 1) and
                   bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_INNATE_UI) == 0 and
                   not isPassiveAndNotLearnable then
                    
                    abilityCount = abilityCount + 1
                    -- print(string.format("[技能详情] %s: 等级=%d, 冷却时间=%.1f, 魔法消耗=%d", 
                    --     ability:GetAbilityName(),
                    --     ability:GetLevel(),
                    --     ability:GetCooldownTimeRemaining(),
                    --     ability:GetManaCost(-1)
                    -- ))

                    local abilityData = {
                        slot = abilitySlot,
                        data = {
                            id = ability:GetAbilityName(),
                            cooldown = math.floor(ability:GetCooldownTimeRemaining() * 10) / 10,
                            manaCost = ability:GetManaCost(-1),
                            level = ability:GetLevel(),
                            isPassive = ability:IsPassive(),
                            isActivated = ability:IsActivated(),
                            charges = ability:GetCurrentAbilityCharges(),
                            maxCharges = ability:GetMaxAbilityCharges(ability:GetLevel()),
                            chargeRestoreTime = ability:GetAbilityChargeRestoreTime(ability:GetLevel()),
                            hasEnoughMana = hero:GetMana() >= ability:GetManaCost(-1),
                            slot = abilitySlot
                        }
                    }
                    table.insert(sortedAbilities, abilityData)
                    --print(string.format("[技能数据] 已添加技能数据: %s", ability:GetAbilityName()))
                else
                    --print(string.format("[技能过滤] 技能被过滤掉: %s", ability:GetAbilityName()))
                end
            end
        end
        
        --print(string.format("[技能统计] 总共找到 %d 个有效技能", abilityCount))
        
        table.sort(sortedAbilities, function(a, b)
            return a.slot < b.slot
        end)
        --print("[技能排序] 技能已按槽位排序")
        
        for index, abilityData in ipairs(sortedAbilities) do
            heroAbilities[index] = abilityData.data
            --print(string.format("[技能索引] 索引 %d: %s", index, abilityData.data.id))
        end
        
        return heroAbilities
    end

    local heroName = hero:GetUnitName()
    --print("[英雄信息] 正在处理英雄:", heroName)
    local heroType = getHeroType(heroName)
    --print("[英雄信息] 获取到英雄类型:", heroType)

    local abilitiesData = {
        abilities = calculateAbilitiesStatus(hero),
        entityId = hero:GetEntityIndex(),
        teamId = hero:GetTeamNumber(),
        enableOverlapDetection = enableOverlapDetection
    }

    CustomGameEventManager:Send_ServerToAllClients("update_abilities_status", abilitiesData)
    --print("[发送数据] 数据已发送到前端")
end


function Main:StartTextMonitor(entity, text, fontSize, color)
    if not entity or entity:IsNull() then return end
    if not text or not fontSize or not color then return end

    -- 直接发送更新
    self:SendTextUpdate(entity, text, fontSize, color)
end

-- 更新文本内容
function Main:UpdateText(entity, text, fontSize, color)
    if not entity or entity:IsNull() then return end
    if not text or not fontSize or not color then return end
    
    -- 直接发送更新
    self:SendTextUpdate(entity, text, fontSize, color)
end

-- 发送文本更新到前端
function Main:SendTextUpdate(entity, text, fontSize, color)
    if not entity or entity:IsNull() then return end
    if not text or not fontSize or not color then return end
    
    local entityId = entity:GetEntityIndex()
    
    CustomGameEventManager:Send_ServerToAllClients("update_floating_text", {
        entityId = entityId,
        teamId = entity:GetTeamNumber(),
        text = text,
        fontSize = fontSize,
        color = color
    })
end

-- 清理指定实体的文本
function Main:ClearFloatingText(entity)
    if not entity or entity:IsNull() then return end

    CustomGameEventManager:Send_ServerToAllClients("clear_floating_text", {
        entityId = entity:GetEntityIndex()
    })
end

-- 清理所有文本
function Main:ClearAllFloatingText()
    CustomGameEventManager:Send_ServerToAllClients("clear_all_floating_text", {})
end



-- 在你的游戏逻辑中定时调用这个函数
function Main:StartAbilitiesMonitor(hero,enableOverlapDetection)
    if not hero or hero:IsNull() then return end
    
    local entityId = hero:GetEntityIndex()
    local timerName = "AbilitiesMonitor_" .. entityId
    
    -- 如果已经在监控中，先停止
    if Timers.timers[timerName] then
        Timers:RemoveTimer(timerName)
    end
    
    -- 创建新的监控定时器
    Timers:CreateTimer(timerName, {
        useGameTime = true,
        endTime = 0.1,
        callback = function()
            if not hero or hero:IsNull() then return nil end
            self:MonitorAbilitiesStatus(hero,false)
            return 0.1
        end
    })
end


function Main:GetRealOwner(unit)
    local function FindOwner(checkUnit, level)
        if not checkUnit or not IsValidEntity(checkUnit) then return nil end

        -- 特殊处理德鲁伊熊
        local unitName = checkUnit:GetUnitName()
        if unitName and unitName:find("npc_dota_lone_druid_bear") then
            local playerID = checkUnit:GetPlayerOwnerID()
            if playerID and playerID >= 0 then
                local druid = PlayerResource:GetSelectedHeroEntity(playerID)
                if druid then
                    return druid
                end
            end
        end

        -- 如果是幻象，通过playerID获取原始单位
        if checkUnit.IsIllusion and checkUnit:IsIllusion() then
            local playerID = checkUnit:GetPlayerOwnerID()
            if playerID and playerID >= 0 then
                local originalHero = PlayerResource:GetSelectedHeroEntity(playerID)
                if originalHero then
                    return originalHero
                end
            end
        end

        -- 如果是真实英雄（非幻象），直接返回
        if checkUnit.IsRealHero and checkUnit:IsRealHero() and not checkUnit:IsIllusion() and not checkUnit:IsClone() then
            return checkUnit
        end

        -- 如果是技能召唤物（比如雷云、地狱火等）
        if checkUnit.IsRealHero and not checkUnit:IsRealHero() then
            local owner = checkUnit:GetOwnerEntity()
            if owner then
                if owner.IsRealHero and owner:IsRealHero() then
                    return owner
                end
                -- 如果owner是技能，尝试获取施法者
                if type(owner.GetCaster) == "function" then
                    local caster = owner:GetCaster()
                    if caster then
                        return caster
                    end
                end
            end
        end
        
        -- 处理米波克隆体情况
        if unitName == "npc_dota_hero_meepo" then
            local playerID = checkUnit:GetPlayerOwnerID()
            if playerID and playerID >= 0 then
                local mainMeepo = PlayerResource:GetSelectedHeroEntity(playerID)
                if mainMeepo then
                    return mainMeepo
                end
            end
        end

        -- 检查召唤物属性
        local ownerEntity = checkUnit:GetOwnerEntity()
        if ownerEntity and ownerEntity ~= checkUnit and type(ownerEntity.IsValidEntity) == "function" and ownerEntity:IsValidEntity() then
            if ownerEntity.IsRealHero and ownerEntity:IsRealHero() then
                return ownerEntity
            end
            return FindOwner(ownerEntity, level + 1)
        end
        
        -- 检查直接所有者
        local owner = checkUnit:GetOwner()
        if not owner then 
            -- 尝试通过playerID查找
            local playerID = checkUnit:GetPlayerOwnerID()
            if playerID and playerID >= 0 then
                local heroOwner = PlayerResource:GetSelectedHeroEntity(playerID)
                if heroOwner then
                    return heroOwner
                end
            end
            return nil 
        end
        
        if owner and owner ~= checkUnit and type(owner.IsValidEntity) == "function" and owner:IsValidEntity() then
            return FindOwner(owner, level + 1)
        end
        
        return nil
    end

    if not unit or not IsValidEntity(unit) then return nil end
    return FindOwner(unit, 1)
end

function Main:StopAbilitiesMonitor(hero)
    print("[StopAbilitiesMonitor] Starting...")
    
    -- 增加entityId参数支持
    if type(hero) == "number" then
        print("[StopAbilitiesMonitor] Received entityId:", hero)
        hero = EntIndexToHScript(hero)
    end
    
    if not hero then
        print("[StopAbilitiesMonitor] Error: hero is nil")
        -- 尝试从追踪列表中获取entityId
        local entityId = hero
        if entityId then
            print("[StopAbilitiesMonitor] Attempting to remove panel using entityId:", entityId)
            -- 停止定时器
            local timerName = "AbilitiesMonitor_" .. entityId
            if Timers.timers[timerName] then
                print("[StopAbilitiesMonitor] Removing timer:", timerName)
                Timers:RemoveTimer(timerName)
            end
            
            -- 发送移除信号到前端
            CustomGameEventManager:Send_ServerToAllClients("remove_hero_abilities_panel", {
                entityId = entityId
            })
        end
        return
    end
    
    if hero:IsNull() then
        print("[StopAbilitiesMonitor] Error: hero is null")
        return
    end
    
    local entityId = hero:GetEntityIndex()
    print("[StopAbilitiesMonitor] Stopping monitor for hero entity:", entityId)
    
    -- 停止定时器
    local timerName = "AbilitiesMonitor_" .. entityId
    if Timers.timers[timerName] then
        print("[StopAbilitiesMonitor] Removing timer:", timerName)
        Timers:RemoveTimer(timerName)
    end
    
    -- 发送移除信号到前端
    print("[StopAbilitiesMonitor] Sending remove panel event for entity:", entityId)
    CustomGameEventManager:Send_ServerToAllClients("remove_hero_abilities_panel", {
        entityId = entityId
    })
    
    print("[StopAbilitiesMonitor] Completed for hero entity:", entityId)
end


                -- 只为第一个英雄获取可见的modifier
--[[                 if i == 1 then
                    local modifiers = hero:FindAllModifiers()
                    for _, modifier in ipairs(modifiers) do
                        if modifier and not modifier:IsNull() and isModifierVisible(modifier) then
                            local modifierName = modifier:GetName()
                            local ability = modifier:GetAbility()
                            local textureName = modifier:GetTexture() or "unknown"
                            
                            if ability and ability:HasFunction("GetAbilityTextureName") then
                                textureName = ability:GetAbilityTextureName() or textureName
                            end
                            
                            local remainingTime = modifier:GetRemainingTime()
                            local duration = modifier:GetDuration()
                            local timePercentage = nil
                            if duration > 0 then
                                timePercentage = (remainingTime / duration) * 100
                            end
                            
                            local stackCount = modifier:GetStackCount()
                            
                            local modifierInfo = {
                                name = modifierName,
                                texture = textureName,
                                timePercentage = timePercentage,
                                stackCount = stackCount > 0 and stackCount or nil
                            }
                            
                            tabl    e.insert(visibleModifiers, modifierInfo)
                            
                            -- 打印modifier信息
                            print(string.format("Modifier: %s, 纹理: %s, 剩余时间百分比: %s, 层数: %s", 
                                modifierName, 
                                textureName, 
                                timePercentage and string.format("%.2f%%", timePercentage) or "N/A", 
                                stackCount > 0 and stackCount or "N/A"))
                        end
                    end
                end ]]
    -- -- 打印获得的modifier信息
    -- print("Left team modifiers:")
    -- for _, modifier in ipairs(data.Left.visibleModifiers) do
    --     print(string.format("Name: %s, Texture: %s, Time Percentage: %s, Stack Count: %s", 
    --         modifier.name, 
    --         modifier.texture, 
    --         modifier.timePercentage and string.format("%.2f%%", modifier.timePercentage) or "N/A", 
    --         modifier.stackCount or "N/A"))
    -- end

    -- print("Right team modifiers:")
    -- for _, modifier in ipairs(data.Right.visibleModifiers) do
    --     print(string.format("Name: %s, Texture: %s, Time Percentage: %s, Stack Count: %s", 
    --         modifier.name, 
    --         modifier.texture, 
    --         modifier.timePercentage and string.format("%.2f%%", modifier.timePercentage) or "N/A", 
    --         modifier.stackCount or "N/A"))
    -- end


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


function CDOTA_Buff:IsFearDebuff()
    local tables = {}
    self:CheckStateToTable(tables)
    
    for state_name, mod_table in pairs(tables) do
        if tostring(state_name) == tostring(MODIFIER_STATE_FEARED) then
             return true
        end
    end
    return false
end

function CDOTA_Buff:IsTauntDebuff()
    local tables = {}
    self:CheckStateToTable(tables)
    
    for state_name, mod_table in pairs(tables) do
        if tostring(state_name) == tostring(MODIFIER_STATE_TAUNTED) then
             return true
        end
    end
    return false
end

function CDOTA_BaseNPC:IsLeashed()
    if not IsServer() then return end
    
    for _, mod in pairs(self:FindAllModifiers()) do
        local tables = {}
        mod:CheckStateToTable(tables)
        local bkb_allowed = true
    
        if mod:GetAbility() then 
            local behavior = mod:GetAbility():GetAbilityTargetFlags()
    
            if bit.band(behavior, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) == 0 and self:IsDebuffImmune() then 
                bkb_allowed = false
            end 
        end 
    
        if bkb_allowed == true then 
            for state_name, mod_table in pairs(tables) do
                if tostring(state_name) == tostring(MODIFIER_STATE_TETHERED) then
                     return true
                end
            end
        end
    end
    return false
end
    
function Main:OnRequestUnitInfo(event)
    local playerID = event.PlayerID
    local unitEntIndex = event.unit_ent_index
    local unit = EntIndexToHScript(unitEntIndex)
    if unit and IsValidEntity(unit) then
        -- 打印束缚状态
        if unit:IsLeashed() then
            print(string.format("【单位状态】%s 处于束缚状态", unit:GetUnitName()))
        else
            print(string.format("【单位状态】%s 未处于束缚状态", unit:GetUnitName()))
        end

        -- 打印激活的技能
        print(string.format("【单位技能】%s 当前激活的技能：", unit:GetUnitName()))
        for i = 0, unit:GetAbilityCount() - 1 do
            local ability = unit:GetAbilityByIndex(i)
            if ability and ability:GetToggleState() then
                print(string.format("    - %s", ability:GetAbilityName()))
            end
        end

        -- 查找最近的单位
        local nearbyUnits = FindUnitsInRadius(
            unit:GetTeamNumber(),
            unit:GetAbsOrigin(),
            nil,
            99999, -- 搜索范围设为最大以找到最近的单位
            DOTA_UNIT_TARGET_TEAM_BOTH,  -- 搜索所有队伍
            DOTA_UNIT_TARGET_ALL,        -- 搜索所有类型单位
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,                -- 按距离排序
            false
        )

        -- 找到最近的非自身单位
        local closestUnit = nil
        local closestDistance = 99999
        for _, nearbyUnit in pairs(nearbyUnits) do
            if nearbyUnit ~= unit then
                local distance = (nearbyUnit:GetAbsOrigin() - unit:GetAbsOrigin()):Length2D()
                closestUnit = nearbyUnit
                closestDistance = distance
                break  -- 因为已经按距离排序，第一个非自身单位就是最近的
            end
        end

        if closestUnit then
            print(string.format("【最近单位】%s 最近的单位是 %s，距离 %.0f", 
                unit:GetUnitName(),
                closestUnit:GetUnitName(),
                closestDistance
            ))
        else
            print(string.format("【最近单位】%s 附近没有其他单位", unit:GetUnitName()))
        end

    

        local unitName = unit:GetUnitName()
        local modifiers = {}
        local unitModifiers = unit:FindAllModifiers()
        for _, modifier in pairs(unitModifiers) do
            local modifierName = modifier:GetName()
            local remainingTime = modifier:GetRemainingTime()
            local duration = modifier:GetDuration()
            local stackCount = modifier:GetStackCount()
            table.insert(modifiers, {
                name = modifierName,
                remaining_time = remainingTime,
                duration = duration,
                stack_count = stackCount
            })
        end
        local ownerPlayerID = unit:GetPlayerOwnerID()
        local teamNumber = unit:GetTeamNumber()
        
        local facetID = nil
        if unit.GetHeroFacetID then
            facetID = unit:GetHeroFacetID()
        end

        -- Add new unit information
        local isHero = unit:IsHero()
        local IsRealHero = unit:IsRealHero()
        local isIllusion = unit:IsIllusion()
        local isSummoned = unit:IsSummoned()

        -- Get child units
        local childUnits = {}
        local children = unit:GetChildren()
        for _, child in pairs(children) do
            -- 检查是否是单位（通过尝试调用IsUnit方法）
            if IsValidEntity(child) and child.IsUnit and child:IsUnit() then
                table.insert(childUnits, {
                    name = child:GetUnitName(),
                    ent_index = child:GetEntityIndex(),
                    is_summoned = child:IsSummoned()
                })
            end
        end

        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "response_unit_info", {
            unit_name = unitName,
            modifiers = modifiers,
            owner_player_id = ownerPlayerID,
            team_number = teamNumber,
            facet_id = facetID,
            is_hero = isHero,
            is_true_hero = IsRealHero,
            is_illusion = isIllusion,
            is_summoned = isSummoned,
            child_units = childUnits
        })
    end
end
function Main:OnKeyPressed(keys)
    local timescale = keys.timescale
    SendToServerConsole("host_timescale " .. timescale)
end


function Main:OnFogToggled(keys)
    local enable = keys.enable
    if enable == 1 then
        -- 开启迷雾
        SendToServerConsole("fog_override_enable 0")
    else
        -- 关闭迷雾
        SendToServerConsole("fog_override_enable 1")
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

function CreateAIForHero(heroEntity, overallStrategy, heroStrategy, aiName, thinkInterval)
    -- print("为英雄创建AI: " .. heroEntity:GetUnitName())
    -- print("整体策略: " .. (type(overallStrategy) == "table" and table.concat(overallStrategy, ", ") or tostring(overallStrategy or "默认策略")))
    -- print("英雄策略: " .. (type(heroStrategy) == "table" and table.concat(heroStrategy, ", ") or tostring(heroStrategy or "默认策略")))
    
    local heroAI = HeroAI.CreateAIForHero(heroEntity, overallStrategy or {"默认策略"}, heroStrategy or {"默认策略"}, thinkInterval)
    
    if heroAI then
        --print("成功创建AI实例: " .. heroEntity:GetUnitName())
        
        AIs[heroEntity] = {
            ai = heroAI,
            name = aiName or heroEntity:GetUnitName()
        }

        heroEntity:SetContextThink("AIThink", function() 
            if AIs[heroEntity] then
                return AIs[heroEntity].ai:Think(heroEntity) 
            else
                --print("AI实例为空: " .. heroEntity:GetUnitName())
                return 1.0  -- 1秒后重试
            end
        end, 0)
    else
        --print("创建AI实例失败: " .. heroEntity:GetUnitName())
        return
    end
end



-- Evaluate the state of the game
function Main:OnThink()
    --return xiaowanyi:OnThink()
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

function Main:ClearAllUnitByName(unitName)
    -- 获取场上所有的单位，包括无敌单位
    local units = FindUnitsInRadius(
        DOTA_TEAM_GOODGUYS, -- 搜索范围的队伍
        Vector(0, 0, 0), -- 搜索范围的中心点
        nil, -- 搜索范围的缓存句柄
        FIND_UNITS_EVERYWHERE, -- 搜索范围
        DOTA_UNIT_TARGET_TEAM_BOTH, -- 搜索的队伍类别
        DOTA_UNIT_TARGET_ALL, -- 搜索的单位类别
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, -- 搜索的标志，包括魔法免疫和无敌单位
        FIND_ANY_ORDER, -- 搜索的排序方式
        false -- 是否可以搜索死亡单位
    )

    -- 遍历所有单位，移除指定名称的单位
    for _, unit in ipairs(units) do
        if unit:GetUnitName() == unitName then
            unit:RemoveSelf()
        end
    end
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


function Main:gradual_slow_down(loserPos, winnerPos)
    SendToServerConsole("host_timescale 0.1")
    
    Timers:CreateTimer(0.1,function()
    CustomGameEventManager:Send_ServerToAllClients("stop_timer", {winnerPos})
    end)

    Timers:CreateTimer(0.2,function()
        SendToServerConsole("host_timescale 1")
    end)

end

