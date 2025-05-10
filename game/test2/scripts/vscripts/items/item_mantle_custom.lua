LinkLuaModifier("modifier_item_mantle_stats", "items/item_mantle_custom.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_parabola_throw", "items/item_mantle_custom.lua", LUA_MODIFIER_MOTION_NONE)

item_mantle_custom = class({})

function item_mantle_custom:GetIntrinsicModifierName()
    return "modifier_item_mantle_stats"
end

modifier_item_mantle_stats = class({})

function modifier_item_mantle_stats:IsHidden() return true end
function modifier_item_mantle_stats:IsDebuff() return false end
function modifier_item_mantle_stats:IsPurgable() return false end
function modifier_item_mantle_stats:RemoveOnDeath() return false end

function modifier_item_mantle_stats:OnCreated()
    if IsServer() then
        -- 为持有物品的单位添加modifier_parabola_throw
        self:GetParent():SetBaseAttackTime(0.01)
        if not self:GetParent():HasModifier("modifier_parabola_throw") then
            self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_parabola_throw", {})
        end
    end
end

function modifier_item_mantle_stats:OnDestroy()
    if IsServer() then
        -- 检查玩家是否还有其他此物品，如果没有则移除modifier_parabola_throw
        local parent = self:GetParent()
        local has_another_mantle = false
        
        for i = 0, 8 do
            local item = parent:GetItemInSlot(i)
            if item and item:GetName() == "item_mantle_custom" and item ~= self:GetAbility() then
                has_another_mantle = true
                break
            end
        end
        
        if not has_another_mantle and parent:HasModifier("modifier_parabola_throw") then
            parent:RemoveModifierByName("modifier_parabola_throw")
        end
    end
end

function modifier_item_mantle_stats:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT
    }
end

function modifier_item_mantle_stats:GetModifierBaseAttackTimeConstant()
    return 0.01
end

function modifier_item_mantle_stats:GetModifierAttackSpeed_Limit()
    return 1
end

local function GetTotalCharges(unit)
    local slots = 5
    if unit:HasAbility("techies_spoons_stash") then
        slots = 8
    end
    
    local total_charges = 0
    for i = 0, slots do
        local item = unit:GetItemInSlot(i)
        if item and item:GetName() == "item_mantle_custom" then
            -- 获取物品的堆叠数量（充能数）
            local charges = item:GetCurrentCharges()
            if charges <= 0 then
                charges = 1  -- 如果没有充能，则至少算1个
            end
            total_charges = total_charges + charges
        end
    end
    return total_charges
end

function modifier_item_mantle_stats:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect") * GetTotalCharges(self:GetParent())
end

-- 添加抛物线投掷功能的修饰器
modifier_parabola_throw = class({})

function modifier_parabola_throw:IsHidden() return false end
function modifier_parabola_throw:IsDebuff() return false end
function modifier_parabola_throw:IsPurgable() return false end

function modifier_parabola_throw:OnCreated()
    if IsServer() then

        self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
    end
end
    
function modifier_parabola_throw:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
    }
end

function modifier_parabola_throw:GetModifierAttackRangeBonus()
    return 2000 - self:GetParent():GetBaseAttackRange()
end

function modifier_parabola_throw:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then return end
    if params.target == nil then return end
    if params.attacker:IsIllusion() then return end

    if not params.target:IsHero() then
        return
    end
    
    local attacker = params.attacker
    local target = params.target
    
    -- 检查攻击者是否拥有item_mantle_custom物品，如果有则减少堆叠数量
    local has_mantle = false
    local mantle_item = nil
    
    -- 检查物品栏中的每个物品
    for i = 0, 8 do
        local item = attacker:GetItemInSlot(i)
        if item and item:GetName() == "item_mantle_custom" then
            mantle_item = item
            has_mantle = true
            break
        end
    end
    
    -- 如果找到物品，减少堆叠数量
    if has_mantle and mantle_item then
        local current_charges = mantle_item:GetCurrentCharges()
        if current_charges > 1 then
            mantle_item:SetCurrentCharges(current_charges - 1)
        else
            -- 如果只有一个堆叠，移除物品
            attacker:RemoveItem(mantle_item)
        end
    else
        return
    end
    
    -- 创建一个可见的单位作为投射物 (使用小兵单位替代thinker，这样可以显示血条)
    local projectile_unit = CreateUnitByName("mantle_unit", attacker:GetAbsOrigin(), true, attacker, attacker, attacker:GetTeamNumber())
    

    projectile_unit:AddNewModifier(projectile_unit, nil, "modifier_extra_health_bonus", {bonus_health = 10000})
    projectile_unit:AddNewModifier(projectile_unit, nil, "modifier_disarmed", {})
    projectile_unit:AddNewModifier(projectile_unit, nil, "modifier_phased", {})
    -- 设置单位不可被选中
    projectile_unit:AddNewModifier(projectile_unit, nil, "modifier_unselectable_custom", {})
    projectile_unit:AddNoDraw()
    
    -- 附加物品图像到投射物单位上
    -- 使用正确的图标格式，这是item_mantle的贴图路径
    --百分之一的概率变成item_urn_of_shadows
    local random_number = RandomInt(1, 100)
    if random_number == 1 then
        item_icon_path = "item_urn_of_shadows"
    else
        item_icon_path = "item_mantle"
    end
    
    -- 使用更小的图标尺寸（原来是64，现在使用32来获得50%的效果）
    local icon_size = 40
    
    
    CustomGameEventManager:Send_ServerToAllClients("update_floating_text", {
        entityId = projectile_unit:GetEntityIndex(),
        teamId = projectile_unit:GetTeamNumber(),
        imageSource = item_icon_path,
        imageWidth = icon_size,
        imageHeight = 30
    })
    
    -- 记录单位的初始位置，用于检测强制位移
    local last_position = projectile_unit:GetAbsOrigin()
    local is_trajectory_active = true -- 标记抛物线运动是否激活
    
    -- 添加一个修饰器来监测位移
    local modifier = projectile_unit:AddNewModifier(attacker, nil, "modifier_phased", {})
    
    -- 初始位置和目标位置
    local start_pos = projectile_unit:GetAbsOrigin()
    local target_pos = target:GetAbsOrigin()
    
    -- 根据单位名字计算唯一的高度系数
    local height_factor = 0.5 -- 默认高度系数
    local attacker_name = attacker:GetName()
    
    -- 计算名字的特征值来确定高度系数
    local name_value = 0
    for i = 1, string.len(attacker_name) do
        name_value = name_value + string.byte(attacker_name, i)
    end
    
    -- 将名字的特征值转换为0.3到0.9之间的高度系数
    height_factor = 0.3 + (name_value % 7) * 0.1
    
    -- 计算水平距离和高度
    local distance = (target_pos - start_pos):Length2D()
    local height = math.max(250, distance * height_factor) -- 提高基础高度和系数效果
    
    -- 设置投射物速度和固定重力加速度
    local base_speed = 400 -- 基础水平速度
    local time_to_target = distance / base_speed
    
    -- 固定重力加速度
    local gravity_acc = 400 -- 固定的重力加速度值
    
    -- 根据固定重力加速度计算所需的初始垂直速度
    local initial_vertical_speed = gravity_acc * time_to_target / 2
    
    -- 创建定时器进行抛物线移动
    local time_elapsed = 0
    
    Timers:CreateTimer(function()
        if not projectile_unit or not IsValidEntity(projectile_unit) or 
           not target or not IsValidEntity(target) or
           not is_trajectory_active then
            
            if projectile_unit and IsValidEntity(projectile_unit) and not is_trajectory_active then
                -- 不强制杀死单位，让它继续存在
                return nil
            end
            
            if projectile_unit and IsValidEntity(projectile_unit) then
                projectile_unit:ForceKill(false)
                
                -- 清除浮动图标 
                if Main then
                    Main:ClearFloatingText(projectile_unit)
                end
            end
            return nil
        end
        
        -- 检测单位是否被强制位移
        local current_position = projectile_unit:GetAbsOrigin()
        local expected_position = last_position
        
        -- 如果当前位置与上次位置相差太远（超过预期移动距离），则认为受到了强制位移
        if time_elapsed > 0.1 then -- 给一点初始时间避免误判
            -- 计算当前垂直速度
            local current_vertical_speed = math.abs(initial_vertical_speed - gravity_acc * time_elapsed)
            
            -- 计算当前时刻的总速度（水平分量+垂直分量）
            local current_speed = math.sqrt(base_speed * base_speed + current_vertical_speed * current_vertical_speed)
            
            local expected_move_distance = current_speed * FrameTime() * 1.2 -- 允许一定误差
            
            -- 计算完整的三维距离，包括高度差异
            local actual_distance = (current_position - expected_position):Length()
            
            if actual_distance > expected_move_distance or 
               (projectile_unit and IsValidEntity(projectile_unit) and 
                (projectile_unit:IsLeashed() or projectile_unit:IsRooted())) and not projectile_unit:HasModifier("modifier_faceless_void_chronosphere_freeze") then
                -- 仅停止位移轨迹，但不立即杀死单位
                is_trajectory_active = false
                if modifier and IsValidEntity(modifier) then
                    modifier:Destroy()
                end
                
                -- 记录单位当前位置
                local base_pos = projectile_unit:GetAbsOrigin()
                
                -- 添加向下的重力效果
                Timers:CreateTimer(function()
                    if not projectile_unit or not IsValidEntity(projectile_unit) then
                        return nil
                    end
                    
                    -- 获取当前位置
                    local pos = projectile_unit:GetAbsOrigin()
                    
                    -- 加上重力
                    local fall_speed = 800 -- 下落速度
                    local new_z = math.max(GetGroundHeight(Vector(pos.x, pos.y, 0), nil), pos.z - fall_speed * FrameTime())
                    
                    -- 更新位置
                    projectile_unit:SetAbsOrigin(Vector(pos.x, pos.y, new_z))
                    
                    -- 检查是否已经到达地面
                    if new_z <= GetGroundHeight(Vector(pos.x, pos.y, 0), nil) + 5 then
                        -- 清除浮动图标
                        if Main then
                            Main:ClearFloatingText(projectile_unit)
                        end
                        
                        -- 杀掉单位
                        projectile_unit:ForceKill(false)
                        
                        -- 在单位位置创建物品掉落，添加随机偏移
                        local offset_x = RandomFloat(-150, 150)
                        local offset_y = RandomFloat(-150, 150)
                        
                        -- 计算掉落位置
                        local drop_pos = Vector(
                            pos.x + offset_x,
                            pos.y + offset_y,
                            GetGroundHeight(Vector(pos.x + offset_x, pos.y + offset_y, 0), nil)
                        )
                        
                        -- 创建物品
                        local drop_item = CreateItem("item_mantle_custom", nil, nil)
                        if drop_item then
                            CreateItemOnPositionSync(drop_pos, drop_item)
                        end
                        
                        return nil
                    end
                    
                    return FrameTime()
                end)
                
                return nil
            elseif projectile_unit and IsValidEntity(projectile_unit) and projectile_unit:HasModifier("modifier_faceless_void_chronosphere_freeze") then
                -- 检测到时间凝滞效果，立即停止投射物并添加我们的保护修饰器
                is_trajectory_active = false
                if modifier and IsValidEntity(modifier) then
                    modifier:Destroy()
                end
                
                -- 存储轨迹数据，以便恢复
                projectile_unit.trajectory_data = {
                    start_pos = start_pos,
                    target_pos = target_pos,
                    time_elapsed = time_elapsed,
                    time_to_target = time_to_target,
                    initial_vertical_speed = initial_vertical_speed,
                    gravity_acc = gravity_acc,
                    target = target,
                    last_position = last_position
                }
                
                -- 添加我们的修饰器来冻结单位，直到时间凝滞结束
                projectile_unit:AddNewModifier(projectile_unit, nil, "modifier_chronosphere_pause", {})
                
                -- 设置一个定时器，监测时间凝滞效果的消失
                Timers:CreateTimer(function()
                    if not projectile_unit or not IsValidEntity(projectile_unit) then
                        return nil
                    end
                    
                    -- 如果时间凝滞效果消失，移除我们的保护修饰器
                    if not projectile_unit:HasModifier("modifier_faceless_void_chronosphere_freeze") then
                        if projectile_unit:HasModifier("modifier_chronosphere_pause") then
                            projectile_unit:RemoveModifierByName("modifier_chronosphere_pause")
                        end
                        return nil
                    end
                    
                    return 0.1
                end)
                
                return nil
            end
        end
        
        -- 更新目标位置（如果目标在移动）
        target_pos = target:GetAbsOrigin()
        
        -- 更新时间
        time_elapsed = time_elapsed + FrameTime()
        local t = math.min(time_elapsed / time_to_target, 1.0)
        
        -- 计算水平位置（匀速）
        local horizontal_pos_x = start_pos.x + t * (target_pos.x - start_pos.x)
        local horizontal_pos_y = start_pos.y + t * (target_pos.y - start_pos.y)
        
        -- 计算垂直位置（抛物线：h = v0*t - 0.5*g*t^2）
        local vertical_pos = start_pos.z + (initial_vertical_speed * time_elapsed - 0.5 * gravity_acc * time_elapsed * time_elapsed)
        
        -- 设置单位位置
        local current_pos = Vector(horizontal_pos_x, horizontal_pos_y, vertical_pos)
        projectile_unit:SetAbsOrigin(current_pos)
        
        -- 更新上次位置为当前设置的位置
        last_position = current_pos
        
        -- 如果到达目标位置
        if t >= 1.0 then
            -- 清除浮动图标
            if Main then
                Main:ClearFloatingText(projectile_unit)
            end
            
            if target and IsValidEntity(target) then
                -- 检查目标是否可选择
                if not target:HasModifier("modifier_unselectable_custom") and not target:HasModifier("modifier_slark_depth_shroud") then
                    -- 目标是可选择的，发起攻击
                    projectile_unit:AddNewModifier(projectile_unit, nil, "modifier_parabola_attack_landed", {})

                    -- 设置一个标记，用于跟踪是否攻击已经命中
                    projectile_unit.attack_landed = false
                    
                    -- 使用PerformAttack立即发起攻击
                    projectile_unit:PerformAttack(
                        target,        -- 攻击目标
                        false,          -- 使用攻击法球效果
                        true,          -- 处理攻击过程
                        false,         -- 不跳过冷却
                        false,         -- 不忽略隐身
                        true,          -- 使用投射物
                        false,         -- 不是假攻击
                        true           -- 必定命中
                    )
                    
                    -- 设置定时器在短暂延迟后移除单位（无论是否命中）
                    Timers:CreateTimer(0.1, function()
                        if projectile_unit and IsValidEntity(projectile_unit) then
                            -- 检查攻击是否已命中，如果未命中则在地上生成物品
                            if not projectile_unit.attack_landed then
                                -- 在单位位置创建物品掉落，添加随机偏移
                                local base_pos = projectile_unit:GetAbsOrigin()
                                
                                -- 生成随机偏移量，范围为-150到150
                                local offset_x = RandomFloat(-150, 150)
                                local offset_y = RandomFloat(-150, 150)
                                
                                -- 计算掉落位置
                                local drop_pos = Vector(
                                    base_pos.x + offset_x,
                                    base_pos.y + offset_y,
                                    GetGroundHeight(Vector(base_pos.x + offset_x, base_pos.y + offset_y, 0), nil)
                                )
                                
                                -- 创建物品
                                local drop_item = CreateItem("item_mantle_custom", nil, nil)
                                if drop_item then
                                    CreateItemOnPositionSync(drop_pos, drop_item)
                                end
                            end
                            projectile_unit:ForceKill(false)
                        end
                        return nil
                    end)
                else
                    -- 不可选择的目标，直接给物品
                    local item = CreateItem("item_mantle_custom", nil, nil)
                    if item then
                        target:AddItem(item)
                    end
                    
                    -- 移除投射物单位
                    projectile_unit:ForceKill(false)
                end
            else
                -- 移除投射物单位
                projectile_unit:ForceKill(false)
            end
            return nil
        end
        
        return FrameTime()
    end)
    

end

-- 处理攻击命中的修饰器
LinkLuaModifier("modifier_parabola_attack_landed", "items/item_mantle_custom.lua", LUA_MODIFIER_MOTION_NONE)
modifier_parabola_attack_landed = class({})

function modifier_parabola_attack_landed:IsHidden() return true end
function modifier_parabola_attack_landed:IsDebuff() return false end
function modifier_parabola_attack_landed:IsPurgable() return false end

function modifier_parabola_attack_landed:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_parabola_attack_landed:OnAttackLanded(params)
    if not IsServer() then return end

    local attacker = params.attacker
    local target = params.target

    -- 检查是否是我们的投射物发起的攻击
    if attacker ~= self:GetParent() then
        return
    end

    -- 标记攻击已命中
    attacker.attack_landed = true
    
    target:AddItemByName("item_mantle_custom")
    
    -- 显示"智力+3"蓝色文本
    if Main then
        -- 发送临时文本更新给前端
        CustomGameEventManager:Send_ServerToAllClients("show_temp_floating_text", {
            entityId = target:GetEntityIndex(),
            teamId = target:GetTeamNumber(),
            text = "智力+3",
            fontSize = 14,
            color = "#00bfff", -- 蓝色
            textStyle = "minion_intelligence"
        })
    end
end

-- 创建一个新的修饰器，用于防止单位在时间凝滞状态下受到任何移动影响
LinkLuaModifier("modifier_chronosphere_pause", "items/item_mantle_custom.lua", LUA_MODIFIER_MOTION_NONE)

modifier_chronosphere_pause = class({})

function modifier_chronosphere_pause:IsHidden() return false end
function modifier_chronosphere_pause:IsDebuff() return false end
function modifier_chronosphere_pause:IsPurgable() return false end
function modifier_chronosphere_pause:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_chronosphere_pause:CheckState()
    return {
        [MODIFIER_STATE_FROZEN] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end

function modifier_chronosphere_pause:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
    }
end

function modifier_chronosphere_pause:GetAbsoluteNoDamageMagical() return 1 end
function modifier_chronosphere_pause:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_chronosphere_pause:GetAbsoluteNoDamagePure() return 1 end

function modifier_chronosphere_pause:OnDestroy()
    if IsServer() then
        local unit = self:GetParent()
        if unit and IsValidEntity(unit) then
            -- 恢复轨迹运动而不是应用重力
            unit.resume_trajectory = true
            
            -- 获取存储的轨迹信息
            local data = unit.trajectory_data
            if data then
                -- 创建定时器恢复轨迹运动
                Timers:CreateTimer(function()
                    if not unit or not IsValidEntity(unit) then
                        return nil
                    end
                    
                    -- 如果不再需要恢复轨迹，退出
                    if not unit.resume_trajectory then
                        return nil
                    end
                    
                    -- 更新时间
                    data.time_elapsed = data.time_elapsed + FrameTime()
                    local t = math.min(data.time_elapsed / data.time_to_target, 1.0)
                    
                    -- 计算水平位置（匀速）
                    local horizontal_pos_x = data.start_pos.x + t * (data.target_pos.x - data.start_pos.x)
                    local horizontal_pos_y = data.start_pos.y + t * (data.target_pos.y - data.start_pos.y)
                    
                    -- 计算垂直位置（抛物线：h = v0*t - 0.5*g*t^2）
                    local vertical_pos = data.start_pos.z + (data.initial_vertical_speed * data.time_elapsed - 0.5 * data.gravity_acc * data.time_elapsed * data.time_elapsed)
                    
                    -- 设置单位位置
                    local current_pos = Vector(horizontal_pos_x, horizontal_pos_y, vertical_pos)
                    unit:SetAbsOrigin(current_pos)
                    
                    -- 更新上次位置
                    unit.last_position = current_pos
                    
                    -- 如果到达目标位置
                    if t >= 1.0 then
                        -- 清除浮动图标
                        if Main then
                            Main:ClearFloatingText(unit)
                        end
                        
                        if data.target and IsValidEntity(data.target) then
                            -- 检查目标是否可选择
                            if not data.target:HasModifier("modifier_unselectable_custom") then
                                -- 目标是可选择的，发起攻击
                                unit:AddNewModifier(unit, nil, "modifier_parabola_attack_landed", {})

                                -- 设置标记，用于跟踪是否攻击已经命中
                                unit.attack_landed = false
                                
                                -- 使用PerformAttack立即发起攻击
                                unit:PerformAttack(
                                    data.target,  -- 攻击目标
                                    false,        -- 使用攻击法球效果
                                    true,         -- 处理攻击过程
                                    false,        -- 不跳过冷却
                                    false,        -- 不忽略隐身
                                    true,         -- 使用投射物
                                    false,        -- 不是假攻击
                                    false         -- 必定命中
                                )
                                
                                -- 设置定时器在短暂延迟后移除单位（无论是否命中）
                                Timers:CreateTimer(0.1, function()
                                    if unit and IsValidEntity(unit) then
                                        -- 检查攻击是否已命中，如果未命中则在地上生成物品
                                        if not unit.attack_landed then
                                            -- 在单位位置创建物品掉落，添加随机偏移
                                            local base_pos = unit:GetAbsOrigin()
                                            
                                            -- 生成随机偏移量
                                            local offset_x = RandomFloat(-150, 150)
                                            local offset_y = RandomFloat(-150, 150)
                                            
                                            -- 计算掉落位置
                                            local drop_pos = Vector(
                                                base_pos.x + offset_x,
                                                base_pos.y + offset_y,
                                                GetGroundHeight(Vector(base_pos.x + offset_x, base_pos.y + offset_y, 0), nil)
                                            )
                                            
                                            -- 创建物品
                                            local drop_item = CreateItem("item_mantle_custom", nil, nil)
                                            if drop_item then
                                                CreateItemOnPositionSync(drop_pos, drop_item)
                                            end
                                        end
                                        unit:ForceKill(false)
                                    end
                                    return nil
                                end)
                            else
                                -- 不可选择的目标，直接给物品
                                local item = CreateItem("item_mantle_custom", nil, nil)
                                if item then
                                    data.target:AddItem(item)
                                end
                                
                                -- 移除投射物单位
                                unit:ForceKill(false)
                            end
                        else
                            -- 移除投射物单位
                            unit:ForceKill(false)
                        end
                        return nil
                    end
                    
                    return FrameTime()
                end)
            else
                -- 如果没有轨迹数据（异常情况），应用默认的重力逻辑
                unit.can_apply_gravity = true
            
                -- 添加向下的重力效果
                Timers:CreateTimer(function()
                    if not unit or not IsValidEntity(unit) then
                        return nil
                    end
                    
                    -- 检查是否仍可应用重力
                    if not unit.can_apply_gravity then
                        return nil
                    end
                    
                    -- 获取当前位置
                    local pos = unit:GetAbsOrigin()
                    
                    -- 加上重力
                    local fall_speed = 800 -- 下落速度
                    local new_z = math.max(GetGroundHeight(Vector(pos.x, pos.y, 0), nil), pos.z - fall_speed * FrameTime())
                    
                    -- 更新位置
                    unit:SetAbsOrigin(Vector(pos.x, pos.y, new_z))
                    
                    -- 检查是否已经到达地面
                    if new_z <= GetGroundHeight(Vector(pos.x, pos.y, 0), nil) + 5 then
                        -- 清除浮动图标
                        if Main then
                            Main:ClearFloatingText(unit)
                        end
                        
                        -- 杀掉单位
                        unit:ForceKill(false)
                        
                        -- 在单位位置创建物品掉落，添加随机偏移
                        local offset_x = RandomFloat(-150, 150)
                        local offset_y = RandomFloat(-150, 150)
                        
                        -- 计算掉落位置
                        local drop_pos = Vector(
                            pos.x + offset_x,
                            pos.y + offset_y,
                            GetGroundHeight(Vector(pos.x + offset_x, pos.y + offset_y, 0), nil)
                        )
                        
                        -- 创建物品
                        local drop_item = CreateItem("item_mantle_custom", nil, nil)
                        if drop_item then
                            CreateItemOnPositionSync(drop_pos, drop_item)
                        end
                        
                        return nil
                    end
                    
                    return FrameTime()
                end)
            end
        end
    end
end 