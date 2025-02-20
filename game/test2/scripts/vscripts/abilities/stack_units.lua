modifier_stack_units_fall = class({})

function modifier_stack_units_fall:IsHidden() return true end
function modifier_stack_units_fall:IsDebuff() return false end
function modifier_stack_units_fall:IsPurgable() return false end
function modifier_stack_units_fall:RemoveOnDeath() return true end

function modifier_stack_units_fall:OnCreated(kv)
    if IsServer() then
        self.start_pos = self:GetParent():GetAbsOrigin()
        self.start_height = kv.start_height or self.start_pos.z
        
        -- 随机选择落点
        local angle = RandomFloat(0, 360)
        local distance = RandomFloat(300, 600)
        local target_x = self.start_pos.x + distance * math.cos(angle * math.pi / 180)
        local target_y = self.start_pos.y + distance * math.sin(angle * math.pi / 180)
        
        self.ground_height = GetGroundHeight(Vector(target_x, target_y, 0), self:GetParent())
        self.target_pos = Vector(target_x, target_y, self.ground_height)
        
        -- 计算高度差
        self.height_offset = self.start_height - self.ground_height
        
        -- 使用固定的重力加速度
        self.gravity = 1200  -- 固定重力加速度
        
        -- 根据高度差计算所需时间
        -- 使用自由落体公式：t = sqrt(2h/g)
        self.duration = math.sqrt((2 * self.height_offset) / self.gravity)
        -- 确保最小时间
        self.duration = math.max(self.duration, 0.5)
        
        self.time_elapsed = 0
        
        -- 设置初始位置
        local initial_pos = Vector(self.start_pos.x, self.start_pos.y, self.start_height)
        self:GetParent():SetAbsOrigin(initial_pos)
        
        self:StartIntervalThink(0.01)
    end
end

function modifier_stack_units_fall:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        self.time_elapsed = self.time_elapsed + 0.01
        
        if self.time_elapsed >= self.duration then
            FindClearSpaceForUnit(parent, self.target_pos, true)
            self:Destroy()
            return
        end
        
        local progress = self.time_elapsed / self.duration
        
        -- 水平运动（线性）
        local current_x = Lerp(progress, self.start_pos.x, self.target_pos.x)
        local current_y = Lerp(progress, self.start_pos.y, self.target_pos.y)
        
        -- 垂直运动（使用平方函数实现加速下落）
        local fall_progress = progress * progress  -- 使用二次函数使下落加速
        local current_z = Lerp(fall_progress, self.start_height, self.ground_height)
        
        -- 确保不低于地面
        current_z = math.max(current_z, self.ground_height)
        
        local new_pos = Vector(current_x, current_y, current_z)
        parent:SetAbsOrigin(new_pos)
    end
end


function modifier_stack_units_fall:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }
end

function modifier_stack_units_fall:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_stack_units_fall:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end
function modifier_stack_units_fall:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        if parent and parent:IsAlive() then
            parent:RemoveModifierByName("modifier_invulnerable")
            parent:RemoveModifierByName("modifier_phased")
            
            -- 播放落地音效
            EmitSoundOn("BodyImpact_Common.Heavy", parent)
            
            -- 直接使用 PATTACH_ABSORIGIN 就会在单位脚底生成特效
            local particle = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_slardar/slardar_crush_entity_splash.vpcf", 
                PATTACH_ABSORIGIN, -- 使用 ABSORIGIN，特效会在单位脚底生成
                parent
            )
            ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end
end

-- 辅助函数：线性插值
function Lerp(t, a, b)
    return a + (b - a) * t
end

modifier_stack_bonus = class({})

function modifier_stack_bonus:IsHidden() return false end
function modifier_stack_bonus:IsDebuff() return false end
function modifier_stack_bonus:IsPurgable() return false end

function modifier_stack_bonus:OnCreated(kv)
    if IsServer() then
        self.total_health = kv.total_health
        self.total_damage = kv.total_damage
        self.total_mana = kv.total_mana
        self.unit_count = kv.unit_count
        self.health_per_unit = self.total_health / 10 / self.unit_count
        self.stacked_units = {} 
        self.last_health_percent = 100
        
        local parent = self:GetParent()
        
        -- 强制重新计算属性以应用修饰符的加成
        parent:CalculateStatBonus(true)
        
        -- 确保当前魔法值设置为新的最大值
        parent:SetMana(parent:GetMaxMana())
        
        self.damage_accumulator = 0
        self:StartIntervalThink(0.1)
    end
end

function modifier_stack_bonus:GetModifierManaBonus()
    return self.total_mana / 5
end

function modifier_stack_bonus:GetModifierBaseAttack_BonusDamage()
    return self.total_damage / 5
end

function modifier_stack_bonus:GetModifierExtraHealthBonus()
    return self.total_health / 5
end

function modifier_stack_bonus:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        if not parent:IsAlive() then
            self:ReleaseAllUnits()
            return
        end

        local current_health = parent:GetHealth()
        local max_health = parent:GetMaxHealth()
        
        -- 使用更精确的伤害计算方式
        local health_lost = (self.last_health_percent - (current_health / max_health * 100))
        self.damage_accumulator = self.damage_accumulator + health_lost
        
        -- 计算每个单位对应的生命百分比（使用浮点数计算）
        local percent_per_unit = 100 / self.unit_count
        local units_to_release = math.floor(self.damage_accumulator / percent_per_unit)
        
        if units_to_release > 0 then
            -- 保留未达到整数的剩余伤害
            self.damage_accumulator = self.damage_accumulator - (units_to_release * percent_per_unit)
            self:ReleaseUnits(units_to_release)
        end
        
        -- 更新最后记录的生命值（使用当前实际值）
        self.last_health_percent = (current_health / max_health) * 100
        
        -- 当生命值低于5%时强制释放剩余单位
        if self.last_health_percent <= 5 and #self.stacked_units > 0 then
            self:ReleaseUnits(#self.stacked_units)
        end
    end
end

function modifier_stack_bonus:ReleaseUnits(count)
    for i = 1, count do
        if #self.stacked_units > 0 then
            local unit = self.stacked_units[#self.stacked_units]
            local modifier = unit:FindModifierByName("modifier_stack_units")
            if modifier then
                modifier:Destroy()
            end
            table.remove(self.stacked_units)
        end
    end
end

function modifier_stack_bonus:ReleaseAllUnits()
    if IsServer() then
        -- 使用反向遍历避免索引错位
        for i = #self.stacked_units, 1, -1 do
            local unit = self.stacked_units[i]
            if unit and not unit:IsNull() then
                -- 强制解除堆叠状态
                local modifier = unit:FindModifierByName("modifier_stack_units")
                if modifier then
                    modifier:Destroy()
                end
                -- 立即移除保护状态
                unit:RemoveModifierByName("modifier_invulnerable")
                unit:RemoveModifierByName("modifier_phased")
            end
        end
        self.stacked_units = {}
    end
end

function modifier_stack_bonus:OnDestroy()
    if IsServer() then
        -- 无论因何原因被移除都会触发释放
        self:ReleaseAllUnits()
        
        -- 同时移除主单位的相位状态
        local parent = self:GetParent()
        if parent and not parent:IsNull() then
            parent:RemoveModifierByName("modifier_phased")
        end
    end
end

function modifier_stack_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    }
end



function modifier_stack_bonus:AddStackedUnit(unit)
    table.insert(self.stacked_units, unit)
end


modifier_stack_units = class({})

function modifier_stack_units:IsHidden() return false end
function modifier_stack_units:IsDebuff() return false end
function modifier_stack_units:IsPurgable() return false end

function modifier_stack_units:OnCreated(kv)
    if IsServer() then
        self.height = kv.height
        self.parent_unit = EntIndexToHScript(kv.parent_unit)
        
        self.ground_z = GetGroundHeight(self:GetParent():GetAbsOrigin(), self:GetParent())
        
        -- Immediately set initial facing angle
        local parent = self:GetParent()
        parent:SetForwardVector(self.parent_unit:GetForwardVector())
        
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_stack_units:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        local parent_pos = self.parent_unit:GetAbsOrigin()
        
        -- Update position
        local new_pos = Vector(
            parent_pos.x,
            parent_pos.y,
            self.ground_z + self.height
        )
        parent:SetAbsOrigin(new_pos)
        
        -- Update facing direction
        parent:SetForwardVector(self.parent_unit:GetForwardVector())
        
        -- Optional: If you want to match the exact rotation angles
        local angles = self.parent_unit:GetAnglesAsVector()
        parent:SetAngles(angles.x, angles.y, angles.z)
    end
end

function modifier_stack_units:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_STUNNED] = true,
    }
end

function modifier_stack_units:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end



function modifier_stack_units:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        if parent and parent:IsAlive() then
            -- 改为使用保存的高度而不是当前高度
            local fall_height = self.height  -- 这里使用 modifier 创建时保存的高度值
            
            -- 添加下落 modifier 时强制设置正确的高度
            parent:AddNewModifier(parent, nil, "modifier_stack_units_fall", {
                start_height = fall_height + GetGroundHeight(parent:GetAbsOrigin(), parent)  -- 使用原始堆叠高度
            })
            
            -- 强制设置一次高空位置确保同步
            local current_ground_pos = GetGroundHeight(parent:GetAbsOrigin(), parent)
            parent:SetAbsOrigin(Vector(parent:GetAbsOrigin().x, parent:GetAbsOrigin().y, fall_height + current_ground_pos))
        end
    end
end
-- 2. 然后是LinkLuaModifier
LinkLuaModifier("modifier_stack_units_fall", "abilities/stack_units", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stack_units", "abilities/stack_units", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stack_bonus", "abilities/stack_units", LUA_MODIFIER_MOTION_NONE)

-- 3. 最后是主技能
stack_units = class({})

function stack_units:OnSpellStart()
    local caster = self:GetCaster()
    local radius = 1000
    local caster_pos = caster:GetAbsOrigin()
    local max_vertical_offset = 128
    local min_vertical_offset = 50
    
    local units = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster_pos,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    
    for i = #units, 1, -1 do
        if units[i] == caster then
            table.remove(units, i)
            break
        end
    end
    
    table.sort(units, function(a, b)
        local health_a = a:GetBaseMaxHealth()
        local health_b = b:GetBaseMaxHealth()
        
        if health_a == health_b then
            local damage_a = (a:GetBaseDamageMin() + a:GetBaseDamageMax()) / 2
            local damage_b = (b:GetBaseDamageMin() + b:GetBaseDamageMax()) / 2
            
            if damage_a == damage_b then
                -- 如果血量和攻击力都相同，使用实体索引确保唯一排序
                return a:entindex() > b:entindex()
            end
            
            return damage_a > damage_b
        end
        
        return health_a > health_b
    end)
    
    local total_health = 0
    local total_damage = 0
    local total_mana = 0  -- 新增魔法值统计
    local unit_count = #units
    local max_health = units[1] and units[1]:GetBaseMaxHealth() or 0
    
    for _, unit in ipairs(units) do
        total_health = total_health + unit:GetBaseMaxHealth()
        total_damage = total_damage + (unit:GetBaseDamageMin() + unit:GetBaseDamageMax()) / 2
        total_mana = total_mana + unit:GetMaxMana()  -- 累加魔法值
    end
    
    local stack_bonus = caster:AddNewModifier(
        caster,
        self,
        "modifier_stack_bonus",
        {
            total_health = total_health,
            total_damage = total_damage,
            total_mana = total_mana,  -- 传递魔法值参数
            unit_count = unit_count
        }
    )
    local min_gap = 5 -- 最小间隔保证
    local accumulated_height = 0
    for i, unit in ipairs(units) do
        -- 根据单位血量计算高度偏移
        local health_ratio = unit:GetBaseMaxHealth() / max_health
        local vertical_offset = min_vertical_offset + (max_vertical_offset - min_vertical_offset) * health_ratio
        
        -- 确保每个单位至少有最小间隔
        if i > 1 then
            accumulated_height = accumulated_height + math.max(vertical_offset, min_gap)
        else
            accumulated_height = vertical_offset
        end
        
        local new_pos = Vector(
            caster_pos.x,
            caster_pos.y,
            caster_pos.z + accumulated_height
        )
        
        FindClearSpaceForUnit(unit, new_pos, true)
        unit:SetAbsOrigin(new_pos)
        
        unit:AddNewModifier(unit, nil, "modifier_invulnerable", {})
        unit:AddNewModifier(unit, nil, "modifier_phased", {})
        
        -- 在创建 modifier_stack_units 时传递绝对高度差
        unit:AddNewModifier(
            caster,
            self,
            "modifier_stack_units",
            {
                duration = -1,
                height = accumulated_height,  -- 这里应该是相对于地面的绝对高度差
                parent_unit = caster:entindex()
            }
        )
        
        stack_bonus:AddStackedUnit(unit)
    end
    
    caster:AddNewModifier(caster, nil, "modifier_phased", {})
end