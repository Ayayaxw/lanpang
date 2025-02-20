function Main:Cleanup_Upside_Down()

end




-- 修改 ReverseAllAbilityValues 函数
function Main:ReverseAllAbilityValues()

    
    local function TrimTrailingZeros(str)
        return str:gsub('%.?0+$', '')
    end

    function ReverseNumber(num)
        if num < 0 then
            return -ReverseNumber(-num)  -- 处理负数
        elseif num == 0 then
            return 0 
        else
            -- 保留两位小数
            num = tonumber(string.format("%.2f", num))
            local str = tostring(num)
            -- 去掉末尾的零和可能的末尾小数点
            str = TrimTrailingZeros(str)
            
            -- 分离整数部分和小数部分
            local integer_part, fractional_part = str:match("^(%d*)%.?(%d*)$")
            local fractional_length = fractional_part and #fractional_part or 0
            
            -- 将整数部分和小数部分合并，然后反转
            local combined = integer_part .. (fractional_part or "")
            local reversed = combined:reverse()
            
            -- 如果有小数部分，则在反转后的字符串中重新插入小数点
            if fractional_length > 0 then
                reversed = reversed:sub(1, fractional_length) .. "." .. reversed:sub(fractional_length + 1)
            end
            
            -- 去掉可能的前导零和末尾的小数点
            reversed = reversed:gsub("^0+", "")
            reversed = reversed:gsub("%.$", "")
            
            return tonumber(reversed) or 0
        end
    end
    
    

    local function ReverseNumberString(str)
        local numbers = {}
        for number in str:gmatch("%d+%.?%d*") do
            table.insert(numbers, tonumber(number))
        end
        
        local reversed = {}
        for _, num in ipairs(numbers) do
            table.insert(reversed, ReverseNumber(num))
        end
        
        return table.concat(reversed, " ")
    end

    local function PrintTable(t, indent)
        indent = indent or ""
        for k, v in pairs(t) do
            if type(v) == "table" then
                print(indent .. k .. " = {")
                PrintTable(v, indent .. "  ")
                print(indent .. "}")
            else
                print(indent .. k .. " = " .. tostring(v))
            end
        end
    end
    
    local function ReverseAbilityValues(ability_data, ability_name, should_print)
        local reversed = {}
        local is_phantom_assassin = ability_name:lower():find("幻影刺客") or ability_name:lower():find("phantom_assassin")
        should_print = should_print or false
        if should_print and is_phantom_assassin then
            print("处理幻影刺客技能:", ability_name)
            print("修改前的数值:")
            PrintTable(ability_data)
        end
        
        for k, v in pairs(ability_data) do
            if k == "AbilityCastPoint" then
                reversed[k] = v  
                if should_print and is_phantom_assassin then
                    print("保持不变: " .. k .. " = " .. tostring(v))
                end
            elseif k == "AbilityCastRange" or k:lower():find("radius") then
                if type(v) == "number" then
                    if v > 150 then
                        reversed[k] = math.max(150, ReverseNumber(v))
                    else
                        reversed[k] = ReverseNumber(v)
                    end
                elseif type(v) == "string" then
                    local numbers = {}
                    for number in v:gmatch("%d+%.?%d*") do
                        table.insert(numbers, tonumber(number))
                    end
                    local reversed_numbers = {}
                    for _, num in ipairs(numbers) do
                        if num > 150 then
                            local reversed_num = ReverseNumber(num)
                            table.insert(reversed_numbers, math.max(150, reversed_num))
                        else
                            table.insert(reversed_numbers, ReverseNumber(num))
                        end
                    end
                    reversed[k] = table.concat(reversed_numbers, " ")
                else
                    reversed[k] = v  -- 如果不是数字或字符串，保持原样
                end
                if should_print and is_phantom_assassin then
                    print("修改: " .. k .. " = " .. tostring(reversed[k]) .. " (原值: " .. tostring(v) .. ")")
                end
            elseif type(v) == "number" then
                reversed[k] = ReverseNumber(v)
                if should_print and is_phantom_assassin then
                    print("修改: " .. k .. " = " .. tostring(reversed[k]) .. " (原值: " .. tostring(v) .. ")")
                end
            elseif type(v) == "string" then
                if v:match("^%d+%.?%d*[%s%d%.]*$") then
                    reversed[k] = ReverseNumberString(v)
                    if should_print and is_phantom_assassin then
                        print("修改: " .. k .. " = " .. tostring(reversed[k]) .. " (原值: " .. tostring(v) .. ")")
                    end
                else
                    reversed[k] = v  -- 非数值字符串保持不变
                    if should_print and is_phantom_assassin then
                        print("保持不变: " .. k .. " = " .. tostring(v))
                    end
                end
            elseif type(v) == "table" then
                -- 递归处理嵌套表
                reversed[k] = ReverseAbilityValues(v, ability_name .. "." .. k, should_print)
            else
                reversed[k] = v  -- 其他类型保持不变
                if should_print and is_phantom_assassin then
                    print("保持不变: " .. k .. " = " .. tostring(v))
                end
            end
        end
    
        if should_print and is_phantom_assassin then
            print("修改后的数值:")
            PrintTable(reversed)
            print("------------------------")  -- 分隔线，使输出更清晰
        end
    
        return reversed
    end

    function DeepCopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
            end
            setmetatable(copy, DeepCopy(getmetatable(orig)))
        else
            copy = orig
        end
        return copy
    end
    
    

    local function PrintModifiedAbilities(original, modified, heroName)
        print(heroName .. " 技能修改:")
        for ability_name, ability_data in pairs(original) do
            print("  " .. ability_name .. ":")
            if type(ability_data) == "table" then
                local function printValue(indent, name, orig, mod)
                    local indentStr = string.rep("  ", indent)
                    if name == "AbilityCastPoint" then
                        print(string.format("%s%s: %s (未修改 - 原因: AbilityCastPoint)", indentStr, name, tostring(orig)))
                    elseif name == "AbilityCastRange" then
                        if mod and orig ~= mod then
                            print(string.format("%s%s: %s -> %s (最小值设为150)", indentStr, name, tostring(orig), tostring(mod)))
                        else
                            print(string.format("%s%s: %s (未修改)", indentStr, name, tostring(orig)))
                        end
                    elseif type(orig) == "number" then
                        if mod and orig ~= mod then
                            print(string.format("%s%s: %s -> %s", indentStr, name, tostring(orig), tostring(mod)))
                        else
                            print(string.format("%s%s: %s (未修改)", indentStr, name, tostring(orig)))
                        end
                    elseif type(orig) == "string" then
                        if orig:match("^%d+%.?%d*[%s%d%.]*$") then
                            if mod and orig ~= mod then
                                print(string.format("%s%s: %s -> %s", indentStr, name, orig, mod))
                            else
                                print(string.format("%s%s: %s (未修改)", indentStr, name, orig))
                            end
                        else
                            --print(string.format("%s%s: %s (未修改 - 原因: 非数值字符串)", indentStr, name, orig))
                        end
                    elseif type(orig) == "table" then
                        print(string.format("%s%s:", indentStr, name))
                        for subkey, subvalue in pairs(orig) do
                            local submod = mod and mod[subkey]
                            printValue(indent + 1, subkey, subvalue, submod)
                        end
                    else
                        print(string.format("%s%s: %s (未修改 - 原因: 未知类型)", indentStr, name, tostring(orig)))
                    end
                end
                
                for key, original_value in pairs(ability_data) do
                    local modified_value = modified and modified[ability_name] and modified[ability_name][key]
                    printValue(2, key, original_value, modified_value)
                end
            else
                print("    警告: 技能数据不是一个表")
            end
        end
    end
    if not self.abilitiesReversed then
        -- 第一次运行时，保存原始数据
        self.originalHeroAbilities = DeepCopy(self.heroAbilities)
    end
    -- 修改：为所有英雄反转技能
    local all_reversed_abilities = {}
    for heroName, abilities in pairs(self.heroAbilities) do
        local original_abilities = DeepCopy(abilities)
        local reversed_abilities = {}
        for ability_name, ability_data in pairs(original_abilities) do
            if type(ability_data) == "table" then
                reversed_abilities[ability_name] = ReverseAbilityValues(ability_data, ability_name)

            else
                -- print("警告: " .. heroName .. " 的 " .. ability_name .. " 技能数据不是一个表。")
            end
        end

        -- 保存反转后的能力
        all_reversed_abilities[heroName] = reversed_abilities

        -- 更新 self.heroAbilities
        self.heroAbilities[heroName] = reversed_abilities
    end

    -- 更新 CustomNetTables
    self:UpdateAbilityModifiers(all_reversed_abilities)
    self.abilitiesReversed = true
end

function Main:PrintHeroAbilities(heroName, isOriginal)
    local original = self.originalHeroAbilities[heroName]
    local modified = self.heroAbilities[heroName]
    if not original then
        print("未找到英雄 " .. heroName .. " 的能力数据")
        return
    end

    print(heroName .. (isOriginal and " 原始" or " 当前") .. "技能数据:")

    local function printValue(indent, name, orig, mod)
        local indentStr = string.rep("  ", indent)
        if name == "AbilityCastPoint" then
            print(string.format("%s%s: %s (未修改 - 原因: AbilityCastPoint)", indentStr, name, tostring(orig)))
        elseif name == "AbilityCastRange" then
            if not isOriginal and mod and orig ~= mod then
                print(string.format("%s%s: %s -> %s (最小值设为150)", indentStr, name, tostring(orig), tostring(mod)))
            else
                print(string.format("%s%s: %s%s", indentStr, name, tostring(orig), isOriginal and "" or " (未修改)"))
            end
        elseif type(orig) == "number" then
            if not isOriginal and mod and orig ~= mod then
                print(string.format("%s%s: %s -> %s", indentStr, name, tostring(orig), tostring(mod)))
            else
                print(string.format("%s%s: %s%s", indentStr, name, tostring(orig), isOriginal and "" or " (未修改)"))
            end
        elseif type(orig) == "string" then
            if orig:match("^%d+%.?%d*[%s%d%.]*$") then
                if not isOriginal and mod and orig ~= mod then
                    print(string.format("%s%s: %s -> %s", indentStr, name, orig, mod))
                else
                    print(string.format("%s%s: %s%s", indentStr, name, orig, isOriginal and "" or " (未修改)"))
                end
            else
                -- 非数值字符串，不打印
            end
        elseif type(orig) == "table" then
            print(string.format("%s%s:", indentStr, name))
            for subkey, subvalue in pairs(orig) do
                local submod = not isOriginal and mod and mod[subkey]
                printValue(indent + 1, subkey, subvalue, submod)
            end
        else
            print(string.format("%s%s: %s (未修改 - 原因: 未知类型)", indentStr, name, tostring(orig)))
        end
    end

    for ability_name, ability_data in pairs(original) do
        print("  " .. ability_name .. ":")
        if type(ability_data) == "table" then
            for key, original_value in pairs(ability_data) do
                local modified_value = not isOriginal and modified and modified[ability_name] and modified[ability_name][key]
                printValue(2, key, original_value, modified_value)
            end
        else
            print("    警告: 技能数据不是一个表")
        end
    end
end

function Main:Init_Upside_Down(event, playerID)


    if not self.abilitiesReversed then
        self:ReverseAllAbilityValues()
        self.abilitiesReversed = true
    end

    -- 技能修改器
    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    -- 设置英雄配置
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍
    self:CreateTrueSightWards(teams)
    self.HERO_CONFIG = {
        ALL = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_rooted", {duration = 5})
                hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})
                hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})
            end,
        },
        FRIENDLY = {
            function(hero)
                -- 保存原始比例
                hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})

                local currentScale = hero:GetModelScale()
                hero:SetModelScale(-currentScale)

                local heroPosition = hero:GetAbsOrigin()

                hero:AddNewModifier(hero, nil, "modifier_constant_height_adjustment", {height_adjustment = 200})
                hero:AddNewModifier(hero, nil, "modifier_attribute_reversal", {}) 

                HeroMaxLevel(hero)
                -- 可以在这里添加更多友方英雄特定的操作
            end,
        },
        ENEMY = {
            function(hero)
                HeroMaxLevel(hero)
                hero:SetForwardVector(Vector(-1, 0, 0))
                -- 可以在这里添加敌方英雄特定的操作
            end,
        },
        BATTLEFIELD = {
            function(hero)
                hero:AddNewModifier(hero, nil, "modifier_auto_elevation_small", {})
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

    -- 设置AI英雄信息
    self.AIheroName = opponentHeroName
    self.FacetId = opponentFacetId
--[[     -- 打印当前英雄的原始数据
    print("自己的英雄 (" .. heroChineseName .. ") 原始数据:")
    self:PrintHeroAbilities(heroName, true)
    
    print("\n对手的英雄 (" .. opponentChineseName .. ") 原始数据:")
    self:PrintHeroAbilities(opponentHeroName, true)

    if not self.abilitiesReversed then
        self:ReverseAllAbilityValues()
    end

    -- 打印当前英雄的修改后数据
    print("\n自己的英雄 (" .. heroChineseName .. ") 修改后的数据:")
    self:PrintHeroAbilities(heroName, false)
    
    print("\n对手的英雄 (" .. opponentChineseName .. ") 修改后的数据:")
    self:PrintHeroAbilities(opponentHeroName, false) ]]

    -- 设置游戏速度
    SendToServerConsole("host_timescale 1")
    self.currentTimer = (self.currentTimer or 0) + 1
    local timerId = self.currentTimer
    self.PlayerChineseName = heroChineseName

    -- 设置初始金钱
    PlayerResource:SetGold(playerID, 0, false)

    -- 定义时间参数
    self.duration = 10         -- 赛前准备时间
    self.endduration = 10      -- 赛后庆祝时间
    self.limitTime = 60        -- 限定时间为准备时间结束后的一分钟
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

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择红方]",
        {localize = true, text = opponentHeroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(opponentHeroName, opponentFacetId)}
    )


    -- 发送初始化消息给前端
    local data = {
        ["挑战英雄"] = heroChineseName,
        ["对手英雄"] = opponentChineseName,
        ["剩余时间"] = self.limitTime,
    }
    local order = {"挑战英雄", "对手英雄", "剩余时间"}
    SendInitializationMessage(data, order)

    CreateHero(playerID, heroName, selfFacetId, self.smallDuelAreaLeft, DOTA_TEAM_GOODGUYS, false, function(playerHero)
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

    -- 创建对手英雄
    CreateHero(playerID, opponentHeroName, opponentFacetId, self.smallDuelAreaRight, DOTA_TEAM_BADGUYS, false, function(opponentHero)
        self:ConfigureHero(opponentHero, false, playerID)
        self:EquipHeroItems(opponentHero, opponentEquipment)
        self.rightTeamHero1 = opponentHero
        self:ListenHeroHealth(self.rightTeamHero1)
        self.currentArenaHeroes[2] = self.rightTeamHero1
        -- 如果启用了AI，为对手英雄创建AI
        if opponentAIEnabled then
            Timers:CreateTimer(self.duration - 0.7, function()
                if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                CreateAIForHero(self.rightTeamHero1, opponentOverallStrategy, opponentHeroStrategy,"rightTeamHero1")
                
                -- 检查是否为米波，如果是，为克隆体也创建AI
                if opponentHeroName == "npc_dota_hero_meepo" then
                    Timers:CreateTimer(0.3, function()
                        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
                        local meepos = FindUnitsInRadius(
                            DOTA_TEAM_BADGUYS,
                            opponentHero:GetAbsOrigin(),
                            nil,
                            FIND_UNITS_EVERYWHERE,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_HERO,
                            DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
                            FIND_ANY_ORDER,
                            false
                        )
                        for _, meepo in pairs(meepos) do
                            if meepo:HasModifier("modifier_meepo_divided_we_stand") and meepo:IsRealHero() and meepo ~= opponentHero then
                                CreateAIForHero(meepo, opponentOverallStrategy, opponentHeroStrategy, "rightTeamHero1_clone")
                            end
                        end
                    end)
                end
                
                return nil
            end)
        else
            -- 处理非 AI 情况
        end
    end)
        
    -- 赛前准备
    Timers:CreateTimer(2, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.leftTeam = {self.leftTeamHero1}
        self.rightTeam = {self.rightTeamHero1}
        if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
            self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })
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
    self:SendCameraPositionToJS(Main.smallDuelArea, 1)

    -- 重置计时器并发送信息
    CustomGameEventManager:Send_ServerToAllClients("reset_timer", {remaining = self.limitTime - self.duration, heroChineseName = heroChineseName, challengedHeroChineseName = opponentChineseName})

    -- 监视战斗状态并开始计时
    Timers:CreateTimer(self.duration - 6, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end

        Timers:CreateTimer(0.1, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            self:MonitorUnitsStatus()
            return 0.01
        end)

        self:SendHeroAndFacetData(heroName, opponentHeroName, selfFacetId, opponentFacetId, self.limitTime)
        Timers:CreateTimer(2, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 0.5")
        end)
        Timers:CreateTimer(3, function()
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
            SendToServerConsole("host_timescale 1")
        end)
    end)

    -- 比赛即将开始
    Timers:CreateTimer(self.duration - 1, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})
    end)

    -- 比赛开始
    Timers:CreateTimer(self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        self.startTime = GameRules:GetGameTime() -- 记录开始时间
        CustomGameEventManager:Send_ServerToAllClients("start_timer", {})
        self:MonitorUnitsStatus()
        self:createLocalizedMessage(
            "[LanPang_RECORD][",
            self.currentMatchID,
            "]",
            "[正式开始]"
        )
    end)

    -- 限定时间结束后的操作
    Timers:CreateTimer(self.limitTime + self.duration, function()
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end
        hero_duel.EndDuel = true

        -- 停止计时
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})

        -- 对英雄再次施加禁用效果
        local modifiers = {"modifier_disarmed", "modifier_silence", "modifier_rooted", "modifier_break"}
        for _, modifier in ipairs(modifiers) do
            if self.leftTeamHero1 and not self.leftTeamHero1:IsNull() then
                self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, modifier, { duration = self.endduration })
            end
            if self.rightTeamHero1 and not self.rightTeamHero1:IsNull() then
                self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, modifier, { duration = self.endduration })
            end
        end
    end)
end


function Main:OnUnitKilled_Upside_Down(killedUnit, args)
    local killedUnit = EntIndexToHScript(args.entindex_killed)

    if hero_duel.EndDuel or not killedUnit:IsRealHero() then
        print("Unit killed: " .. killedUnit:GetUnitName() .. " (not processed)")
        return
    end

    self:ProcessHeroDeath(killedUnit)
end


function Main:OnNPCSpawned_Upside_Down(spawnedUnit, event)
    if spawnedUnit:IsRealHero() and spawnedUnit:HasModifier("modifier_arc_warden_tempest_double") then
        -- 检查英雄是否属于好人队（Radiant）
        if spawnedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
            local currentScale = spawnedUnit:GetModelScale()
            spawnedUnit:SetModelScale(-currentScale)

            local heroPosition = spawnedUnit:GetAbsOrigin()

            spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_constant_height_adjustment", {height_adjustment = 200})
            spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_attribute_reversal", {}) 
        end
    end
end