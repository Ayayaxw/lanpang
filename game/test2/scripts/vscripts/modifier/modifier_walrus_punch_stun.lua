modifier_walrus_punch_stun = class({})

function modifier_walrus_punch_stun:IsHidden() return false end
function modifier_walrus_punch_stun:IsDebuff() return true end
function modifier_walrus_punch_stun:IsPurgable() return false end
function modifier_walrus_punch_stun:IsStunDebuff() return true end
function modifier_walrus_punch_stun:GetEffectName() return "particles/generic_gameplay/generic_stunned.vpcf" end
function modifier_walrus_punch_stun:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

function modifier_walrus_punch_stun:OnCreated(kv)
    if IsServer() then
        -- 默认持续时间为2秒，如果传入了持续时间则使用传入的值
        self.duration = kv.duration or 2.0
        
        -- 获取单位当前位置
        local parent = self:GetParent()
        local origin = parent:GetAbsOrigin()
        self.start_position = origin
        
        -- 计算最高点高度（原始高度 + 600单位，比原来高3倍）
        self.ground_height = GetGroundHeight(origin, parent)
        self.max_height = self.ground_height + 600
        
        -- 初始化旋转角度和方向（前空翻，绕X轴旋转）
        self.rotation_x = 0
        self.rotation_speed = 360 / self.duration -- 总共旋转360度
        
        -- 计算上升和下降的时间
        self.rise_time = self.duration * 0.5
        self.fall_time = self.duration * 0.5
        
        -- 记录开始时间
        self.start_time = GameRules:GetGameTime()
        
        -- 添加眩晕效果
        parent:AddNewModifier(parent, nil, "modifier_stunned", {duration = self.duration})
        
        -- 播放翻腾动画
        parent:StartGesture(ACT_DOTA_FLAIL)
        
        -- 开始帧更新
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_walrus_punch_stun:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        if not parent or parent:IsNull() then return end
        
        local current_time = GameRules:GetGameTime()
        local elapsed_time = current_time - self.start_time
        
        -- 如果已经超过持续时间，结束效果
        if elapsed_time >= self.duration then
            parent:SetAbsOrigin(Vector(
                self.start_position.x,
                self.start_position.y,
                self.ground_height
            ))
            parent:FadeGesture(ACT_DOTA_FLAIL)
            self:Destroy()
            return
        end
        
        -- 计算当前高度
        local current_height
        if elapsed_time <= self.rise_time then
            -- 上升阶段：使用二次函数实现平滑上升
            local progress = elapsed_time / self.rise_time
            current_height = self.ground_height + (self.max_height - self.ground_height) * (-(progress - 1) * (progress - 1) + 1)
        else
            -- 下降阶段：使用二次函数实现平滑下降
            local fall_progress = (elapsed_time - self.rise_time) / self.fall_time
            current_height = self.max_height - (self.max_height - self.ground_height) * (fall_progress * fall_progress)
        end
        
        -- 更新旋转角度（前空翻，绕X轴旋转）
        self.rotation_x = self.rotation_x + (self.rotation_speed * FrameTime())
        
        -- 应用旋转效果（通过设置模型的角度）
        -- 第一个参数是X轴旋转（前空翻），第二个是Y轴旋转（左右摇摆），第三个是Z轴旋转（水平旋转）
        parent:SetAngles(self.rotation_x, 0, 0)
        
        -- 更新单位位置
        parent:SetAbsOrigin(Vector(
            self.start_position.x,
            self.start_position.y,
            current_height
        ))
    end
end

function modifier_walrus_punch_stun:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        if parent and not parent:IsNull() then
            -- 确保单位回到地面
            parent:SetAbsOrigin(Vector(
                self.start_position.x,
                self.start_position.y,
                self.ground_height
            ))
            
            -- 停止翻腾动画
            parent:FadeGesture(ACT_DOTA_FLAIL)
            
            -- 重置旋转
            parent:SetAngles(0, 0, 0)
        end
    end
end

function modifier_walrus_punch_stun:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
end

function modifier_walrus_punch_stun:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
end

function modifier_walrus_punch_stun:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end 