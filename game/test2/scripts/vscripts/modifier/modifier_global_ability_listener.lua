-- modifier_global_ability_listener.lua
if modifier_global_ability_listener == nil then
    modifier_global_ability_listener = class({})
end

function modifier_global_ability_listener:IsHidden()
    return true
end

function modifier_global_ability_listener:IsPurgable()
    return false
end

function modifier_global_ability_listener:RemoveOnDeath()
    return false
end

function modifier_global_ability_listener:DeclareFunctions()
    return { 
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_EVENT_ON_DEATH_COMPLETED,
        MODIFIER_EVENT_ON_ATTACK_FINISHED
    }
end

function modifier_global_ability_listener:GetHeroChineseName(heroName)
    for _, hero in ipairs(heroes_precache) do
        if hero.name == heroName then
            return hero.chinese
        end
    end
    return "未知英雄"
end

function modifier_global_ability_listener:OnAbilityExecuted(params)
    if IsServer() then
        print("[ABILITY_LISTENER] 有单位在放技能")
        DeepPrintTable(params)
        
        -- 尝试获取更多施法信息
        local ability = params.ability
        local caster = params.unit
        
        if ability and caster then
            print("[ABILITY_LISTENER] 施法单位: " .. caster:GetUnitName())
            print("[ABILITY_LISTENER] 施法技能: " .. ability:GetAbilityName())
            
            -- 尝试获取施法位置
            local cursor_position = ability:GetCursorPosition()
            if cursor_position then
                print("[ABILITY_LISTENER] 施法目标位置: ", cursor_position.x, cursor_position.y, cursor_position.z)
            end
            
            -- 获取施法单位当前位置
            local caster_position = caster:GetAbsOrigin()
            print("[ABILITY_LISTENER] 施法单位位置: ", caster_position.x, caster_position.y, caster_position.z)
            
            -- 尝试获取目标单位
            local cursor_target = ability:GetCursorTarget()

        end

        if ability and caster and not ability:IsItem() then
            print("[ABILITY_LISTENER] 技能名称: " .. ability:GetAbilityName())
            print("[ABILITY_LISTENER] 施法者名称: " .. caster:GetUnitName())
            
            -- 如果施法者是英雄(包括幻象)
            if caster:IsHero() then
                print("[ABILITY_LISTENER] 施法者是英雄: " .. caster:GetUnitName())
                local message = PrintManager:FormatAbilityMessage(caster, ability)
                PrintManager:PrintMessage(message)
                
                -- 记录使用过技能的英雄
                Main.heroesUsedAbility[caster:GetEntityIndex()] = true
                print("[ABILITY_LISTENER] 已记录英雄使用技能: " .. caster:GetEntityIndex())
                
                -- 初始化英雄技能记录表
                if not Main.heroLastCastAbility then
                    Main.heroLastCastAbility = {}
                    print("[ABILITY_LISTENER] 初始化英雄技能记录表")
                end
                
                local heroIndex = caster:GetEntityIndex()
                -- 初始化该英雄的技能记录表
                if not Main.heroLastCastAbility[heroIndex] then
                    Main.heroLastCastAbility[heroIndex] = {}
                    print("[ABILITY_LISTENER] 初始化英雄 " .. caster:GetUnitName() .. " 的技能记录表")
                end

                local abilityName = ability:GetAbilityName()
                print("[ABILITY_LISTENER] 记录技能 " .. abilityName .. " 的释放时间")
                
                -- 获取目标位置和目标单位
                local cursor_position = ability:GetCursorPosition()
                local cursor_target = ability:GetCursorTarget()
                local target_unit_name = cursor_target and cursor_target.GetUnitName and cursor_target:GetUnitName() or nil
                local target_unit_index = cursor_target and cursor_target:GetEntityIndex() or nil
                
                -- 记录该英雄每个技能最近一次释放的信息
                Main.heroLastCastAbility[heroIndex][abilityName] = {
                    time = GameRules:GetGameTime(),  -- 技能释放时间
                    cursor_position = cursor_position,  -- 技能释放位置
                    target_unit_index = target_unit_index,  -- 技能释放目标单位索引
                    caster_position = caster:GetAbsOrigin()  -- 技能释放者位置
                }
                print("[ABILITY_LISTENER] 当前游戏时间: " .. GameRules:GetGameTime())
                
                -- 打印记录的信息
                if cursor_position then
                    print("[ABILITY_LISTENER] 已记录施法目标位置: ", cursor_position.x, cursor_position.y, cursor_position.z)
                end
                if target_unit_name then
                    print("[ABILITY_LISTENER] 已记录施法目标单位: " .. target_unit_name)
                end
                
                -- 新增：记录对特定单位释放的技能（用于AI查询）
                self:RecordAbilityTargetedAtUnit(caster, ability, cursor_target, cursor_position, false)
            else
                print("[ABILITY_LISTENER] 施法者不是英雄: " .. caster:GetUnitName())
            end
        else
            if not ability then
                print("[ABILITY_LISTENER] 无效的技能对象")
            end
            if not caster then
                print("[ABILITY_LISTENER] 无效的施法者对象")
            end
            if ability and ability:IsItem() then
                print("[ABILITY_LISTENER] 这是一个物品技能: " .. ability:GetAbilityName())
            end
        end


    end
end

-- 新增函数：记录对特定单位释放的技能
function modifier_global_ability_listener:RecordAbilityTargetedAtUnit(caster, ability, target_unit, target_position, is_ability_start)
    if not IsServer() then return end
    
    -- 初始化全局表
    if not Main.abilitiesTargetedAtUnits then
        Main.abilitiesTargetedAtUnits = {}
        print("[ABILITY_LISTENER] 初始化技能目标记录表")
    end
    
    local current_time = GameRules:GetGameTime()
    local ability_name = ability:GetAbilityName()
    local caster_index = caster:GetEntityIndex()
    local caster_position = caster:GetAbsOrigin()
    local cast_point = ability:GetCastPoint()
    
    -- 特殊处理 muerta_dead_shot 技能
    if ability_name == "muerta_dead_shot" then
        -- 查找距离施法者最近的敌方英雄
        local nearest_enemy = FindUnitsInRadius(
            caster:GetTeamNumber(),
            caster_position,
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_CLOSEST,
            false
        )[1]
        
        if nearest_enemy and nearest_enemy:IsHero() then
            target_unit = nearest_enemy
            print("[ABILITY_LISTENER] muerta_dead_shot 特殊处理: 目标设为最近敌方英雄 " .. target_unit:GetUnitName())
        end
    end
    
    -- 处理单体目标技能
    if target_unit and target_unit:IsHero() then
        local target_index = target_unit:GetEntityIndex()
        
        -- 初始化目标单位的记录表
        if not Main.abilitiesTargetedAtUnits[target_index] then
            Main.abilitiesTargetedAtUnits[target_index] = {}
        end
        
        -- 记录技能信息
        local record = {
            ability_name = ability_name,
            caster_index = caster_index,
            caster_name = caster:GetUnitName(),
            cast_time = current_time,
            cast_position = caster_position,
            target_type = "unit_target",
            cast_point = cast_point
        }
        
        -- 如果是技能开始施法，记录前摇开始时间
        if is_ability_start then
            record.start_time = current_time
            print("[ABILITY_LISTENER] 记录技能开始施法: " .. ability_name .. " -> " .. target_unit:GetUnitName())
        else
            print("[ABILITY_LISTENER] 记录技能释放完成: " .. ability_name .. " -> " .. target_unit:GetUnitName())
        end
        
        table.insert(Main.abilitiesTargetedAtUnits[target_index], record)
        
    -- 处理点目标技能（可能影响范围内的英雄）
    elseif target_position then
        local aoe_radius = CommonAI:GetSkillAoeRadius(ability)
        if aoe_radius > 0 then
            -- 查找范围内的所有英雄
            local heroes_in_range = FindUnitsInRadius(
                caster:GetTeamNumber(),
                target_position,
                nil,
                aoe_radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false
            )
            
            for _, hero in pairs(heroes_in_range) do
                if hero:IsHero() then
                    local hero_index = hero:GetEntityIndex()
                    
                    -- 初始化目标单位的记录表
                    if not Main.abilitiesTargetedAtUnits[hero_index] then
                        Main.abilitiesTargetedAtUnits[hero_index] = {}
                    end
                    
                    -- 记录技能信息
                    local record = {
                        ability_name = ability_name,
                        caster_index = caster_index,
                        caster_name = caster:GetUnitName(),
                        cast_time = current_time,
                        cast_position = caster_position,
                        target_position = target_position,
                        target_type = "aoe_target",
                        aoe_radius = aoe_radius,
                        cast_point = cast_point
                    }
                    
                    -- 如果是技能开始施法，记录前摇开始时间
                    if is_ability_start then
                        record.start_time = current_time
                        print("[ABILITY_LISTENER] 记录AOE技能开始施法: " .. ability_name .. " -> " .. hero:GetUnitName() .. " (范围内)")
                    else
                        print("[ABILITY_LISTENER] 记录AOE技能释放完成: " .. ability_name .. " -> " .. hero:GetUnitName() .. " (范围内)")
                    end
                    
                    table.insert(Main.abilitiesTargetedAtUnits[hero_index], record)
                end
            end
        else
            -- 无AOE的点目标技能，记录到最近的敌方英雄
            local nearest_hero = FindUnitsInRadius(
                caster:GetTeamNumber(),
                target_position,
                nil,
                300, -- 300范围内查找最近的英雄
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_CLOSEST,
                false
            )[1]
            
            if nearest_hero and nearest_hero:IsHero() then
                local hero_index = nearest_hero:GetEntityIndex()
                
                -- 初始化目标单位的记录表
                if not Main.abilitiesTargetedAtUnits[hero_index] then
                    Main.abilitiesTargetedAtUnits[hero_index] = {}
                end
                
                -- 记录技能信息
                local record = {
                    ability_name = ability_name,
                    caster_index = caster_index,
                    caster_name = caster:GetUnitName(),
                    cast_time = current_time,
                    cast_position = caster_position,
                    target_position = target_position,
                    target_type = "point_target",
                    cast_point = cast_point
                }
                
                -- 如果是技能开始施法，记录前摇开始时间
                if is_ability_start then
                    record.start_time = current_time
                    print("[ABILITY_LISTENER] 记录点目标技能开始施法: " .. ability_name .. " -> " .. nearest_hero:GetUnitName() .. " (最近目标)")
                else
                    print("[ABILITY_LISTENER] 记录点目标技能释放完成: " .. ability_name .. " -> " .. nearest_hero:GetUnitName() .. " (最近目标)")
                end
                
                table.insert(Main.abilitiesTargetedAtUnits[hero_index], record)
            end
        end
    end
    
    -- 清理过期记录（保留最近30秒的记录）
    self:CleanupOldAbilityRecords(30)
end

-- 新增函数：清理过期的技能记录
function modifier_global_ability_listener:CleanupOldAbilityRecords(max_age_seconds)
    if not Main.abilitiesTargetedAtUnits then return end
    
    local current_time = GameRules:GetGameTime()
    local cleaned_count = 0
    
    for unit_index, ability_list in pairs(Main.abilitiesTargetedAtUnits) do
        local new_list = {}
        for _, ability_record in pairs(ability_list) do
            if current_time - ability_record.cast_time <= max_age_seconds then
                table.insert(new_list, ability_record)
            else
                cleaned_count = cleaned_count + 1
            end
        end
        Main.abilitiesTargetedAtUnits[unit_index] = new_list
    end
    
    if cleaned_count > 0 then
        print("[ABILITY_LISTENER] 清理了 " .. cleaned_count .. " 条过期技能记录")
    end
end

function modifier_global_ability_listener:OnAttackFinished(params)
    if IsServer() then
        print("[ABILITY_LISTENER] 有单位完成攻击动作，弹道已发射")
        local attacker = params.attacker
        local target = params.target
        
        if attacker and target then
            print("[ABILITY_LISTENER] 攻击者名称: " .. attacker:GetUnitName())
            print("[ABILITY_LISTENER] 目标名称: " .. target:GetUnitName())
            
            -- 如果攻击者是英雄(包括幻象)
            if attacker:IsHero() then
                print("[ABILITY_LISTENER] 攻击者是英雄: " .. attacker:GetUnitName())
                -- 这里可以添加类似技能记录的逻辑
                
                -- 记录发起攻击的英雄
                if not Main.heroesAttacked then
                    Main.heroesAttacked = {}
                end
                Main.heroesAttacked[attacker:GetEntityIndex()] = true
                print("[ABILITY_LISTENER] 已记录英雄发起攻击: " .. attacker:GetEntityIndex())
                
                -- 如果需要记录攻击时间等信息，可以参照技能记录的方式
                if not Main.heroLastAttack then
                    Main.heroLastAttack = {}
                end
                
                local heroIndex = attacker:GetEntityIndex()
                if not Main.heroLastAttack[heroIndex] then
                    Main.heroLastAttack[heroIndex] = {}
                end
                
                Main.heroLastAttack[heroIndex] = {
                    target = target:GetUnitName(),
                    time = GameRules:GetGameTime(),
                    damage = params.damage,
                    ranged_attack = params.ranged_attack
                }
                print("[ABILITY_LISTENER] 当前游戏时间: " .. GameRules:GetGameTime())
            else
                print("[ABILITY_LISTENER] 攻击者不是英雄: " .. attacker:GetUnitName())
            end
        else
            if not attacker then
                print("[ABILITY_LISTENER] 无效的攻击者对象")
            end
            if not target then
                print("[ABILITY_LISTENER] 无效的目标对象")
            end
        end
    end
end

-- AI查询接口：获取对指定单位释放的所有技能
function modifier_global_ability_listener:GetAbilitiesTargetedAtUnit(unit, time_window)
    if not Main.abilitiesTargetedAtUnits then return {} end
    
    local unit_index = unit:GetEntityIndex()
    local ability_list = Main.abilitiesTargetedAtUnits[unit_index] or {}
    
    -- 如果指定了时间窗口，只返回该时间内的技能
    if time_window then
        local current_time = GameRules:GetGameTime()
        local filtered_list = {}
        
        for _, ability_record in pairs(ability_list) do
            if current_time - ability_record.cast_time <= time_window then
                table.insert(filtered_list, ability_record)
            end
        end
        
        return filtered_list
    end
    
    return ability_list
end

-- AI查询接口：检查指定时间内是否有特定技能对单位释放
function modifier_global_ability_listener:HasAbilityBeenCastAtUnit(unit, ability_name, time_window) 
    local abilities = self:GetAbilitiesTargetedAtUnit(unit, time_window)
    
    for _, ability_record in pairs(abilities) do
        if ability_record.ability_name == ability_name then
            return true, ability_record
        end
    end
    
    return false, nil
end

-- AI查询接口：获取最近对单位释放的技能
function modifier_global_ability_listener:GetMostRecentAbilityAtUnit(unit, time_window)
    local abilities = self:GetAbilitiesTargetedAtUnit(unit, time_window)
    
    if #abilities == 0 then return nil end
    
    -- 按时间排序，获取最新的
    table.sort(abilities, function(a, b) return a.cast_time > b.cast_time end)
    
    return abilities[1]
end

-- AI查询接口：获取指定施法者对单位释放的技能
function modifier_global_ability_listener:GetAbilitiesFromCasterAtUnit(unit, caster_index, time_window)
    local abilities = self:GetAbilitiesTargetedAtUnit(unit, time_window)
    local filtered_abilities = {}
    
    for _, ability_record in pairs(abilities) do
        if ability_record.caster_index == caster_index then
            table.insert(filtered_abilities, ability_record)
        end
    end
    
    return filtered_abilities
end

-- AI查询接口：统计对单位释放的技能数量
function modifier_global_ability_listener:CountAbilitiesAtUnit(unit, time_window, ability_name_filter)
    local abilities = self:GetAbilitiesTargetedAtUnit(unit, time_window)
    local count = 0
    
    for _, ability_record in pairs(abilities) do
        if not ability_name_filter or ability_record.ability_name == ability_name_filter then
            count = count + 1
        end
    end
    
    return count
end

function modifier_global_ability_listener:OnAbilityStart(params)
    if IsServer() then
        local ability = params.ability
        local caster = params.unit
        
        if ability and caster and not ability:IsItem() then
            local abilityName = ability:GetAbilityName()
            
            -- 检查是否是需要记录开始时间的技能
            local trackableSkills = {
                ["pudge_meat_hook"] = true,
                -- 可以添加更多需要精确时机控制的技能
            }
            
            if trackableSkills[abilityName] then
                print("[ABILITY_LISTENER] 检测到技能开始施法: " .. abilityName)
                
                -- 使用现有的记录系统记录技能开始施法
                self:RecordAbilityTargetedAtUnit(caster, ability, ability:GetCursorTarget(), ability:GetCursorPosition(), true)
                
                print("[ABILITY_LISTENER] 记录技能开始时间: " .. GameRules:GetGameTime())
                print("[ABILITY_LISTENER] 技能前摇时间: " .. ability:GetCastPoint())
            end
        end
    end
end

-- 检查特定技能是否对单位开始施法
function modifier_global_ability_listener:HasAbilityStartBeenCastAtUnit(unit, ability_name, time_window)
    local abilities = self:GetAbilitiesTargetedAtUnit(unit, time_window)
    
    for _, ability_record in pairs(abilities) do
        if ability_record.ability_name == ability_name and ability_record.start_time then
            return true, ability_record
        end
    end
    
    return false, nil
end