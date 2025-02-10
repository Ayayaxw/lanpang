modifier_custom_rolling = class({})

function modifier_custom_rolling:IsHidden() return false end
function modifier_custom_rolling:IsDebuff() return false end
function modifier_custom_rolling:IsPurgable() return false end

function modifier_custom_rolling:OnCreated(kv)
    if IsServer() then
        self.base_speed = 100
        self:GetParent():SetBaseMoveSpeed(self.base_speed)
        
        self.radius = kv.radius or 500
        self.center = Vector(
            kv.x or self:GetParent():GetAbsOrigin().x,
            kv.y or self:GetParent():GetAbsOrigin().y,
            kv.z or self:GetParent():GetAbsOrigin().z
        )
        self.clockwise = true
        
        local start_pos = Vector(
            self.center.x,
            self.center.y - self.radius,
            self.center.z
        )
        self:GetParent():SetAbsOrigin(start_pos)
        
        -- 初始化层数表
        self.stacks = {}
        -- 使用FrameTime()进行帧检查
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_custom_rolling:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end

function modifier_custom_rolling:GetModifierIgnoreMovespeedLimit()
    return 1
end

function modifier_custom_rolling:CalculateSpeed()
    local total_multiplier = 1
    local current_time = GameRules:GetGameTime()
    
    -- 移除过期的层数
    for i = #self.stacks, 1, -1 do
        if current_time > self.stacks[i].expire_time then
            table.remove(self.stacks, i)
        end
    end
    
    -- 计算所有有效层数的乘法叠加
    for _, stack in ipairs(self.stacks) do
        total_multiplier = total_multiplier * (1 + stack.bonus)
    end
    
    return self.base_speed * total_multiplier
end

function modifier_custom_rolling:GetModifierMoveSpeedBase_Override()
    if IsServer() then
        return self:CalculateSpeed()
    end
    return self.base_speed
end

function modifier_custom_rolling:GetModifierIncomingDamage_Percentage()
    return -200
end

function modifier_custom_rolling:OnTakeDamage(keys)
    if IsServer() then
        if keys.unit == self:GetParent() then
            local bonus = math.max(0.005, keys.original_damage / 1000) -- 1% minimum
            local current_time = GameRules:GetGameTime()
            
            -- 添加新层数
            table.insert(self.stacks, {
                bonus = bonus,
                expire_time = current_time + 5 -- 5秒持续时间
            })
        end
    end
end

function modifier_custom_rolling:OnIntervalThink()
    if IsServer() then
        -- 更新移动速度和位置
        self:GetParent():SetBaseMoveSpeed(self:CalculateSpeed())
        
        local parent = self:GetParent()
        local current_pos = parent:GetAbsOrigin()
        
        local to_center = self.center - current_pos
        
        local tangent
        if self.clockwise then
            tangent = Vector(-to_center.y, to_center.x, 0):Normalized()
        else
            tangent = Vector(to_center.y, -to_center.x, 0):Normalized()
        end
        
        local speed = parent:GetIdealSpeed()
        
        local target_pos = current_pos + tangent * speed * FrameTime() * 2
        
        local to_target = target_pos - self.center
        target_pos = self.center + to_target:Normalized() * self.radius
        
        parent:MoveToPosition(target_pos)
    end
end

function modifier_custom_rolling:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_FISSURE] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_OBSTRUCTIONS] = true,
        [MODIFIER_STATE_STUNNED] = false,          -- 免疫眩晕
        [MODIFIER_STATE_UNSLOWABLE] = true,        -- 免疫减速
        [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = false,  -- 可以被击飞
        --[MODIFIER_STATE_ROOTED] = false,           -- 免疫缠绕
        [MODIFIER_STATE_FEARED] = false,           -- 免疫恐惧
        [MODIFIER_STATE_NIGHTMARED] = false,       -- 免疫睡眠
        [MODIFIER_STATE_TETHERED] = false,         -- 免疫束缚
        [MODIFIER_STATE_HEXED] = false             -- 免疫变羊
    }
end

function modifier_custom_rolling:OnDestroy()
    if IsServer() then
        self:GetParent():Stop()
    end
end

function modifier_custom_rolling:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end