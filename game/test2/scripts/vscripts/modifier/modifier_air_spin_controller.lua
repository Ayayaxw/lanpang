--[[
旋转飞行效果修饰器 (modifier_air_spin_controller)
该修饰器使单位被击飞到空中并眩晕，同时可以控制飞行方向和距离。

参数说明:
- height: 数值，单位被击飞的高度，单位为游戏单位。默认值为600。
  高度也决定了修饰器的持续时间，使用公式: duration = sqrt(height/150)
  例如: height=600时，持续时间为2秒

- distance: 数值，单位飞行的水平距离，单位为游戏单位。默认值为500。
  如果设置为0，单位将只进行垂直运动，不会有水平位移。

- direction: 方向向量或字符串，指定单位飞行的方向。
  可以是以下字符串之一: "north", "south", "east", "west", 
  "northeast", "northwest", "southeast", "southwest"
  也可以是一个包含x和y属性的Vector表: {x=1, y=0}
  默认值为"south"（向南方向）。

- rotation_speed: 数值，单位在空中旋转的速度，单位为圈/秒。默认值为0.5。
  例如: rotation_speed=1时，单位每秒旋转一整圈(360度)
  如果设置为0，单位将不会旋转。
  如果设置为负数，单位将反向旋转。

- gravity_factor: 数值，控制重力加速度系数，默认值为1.5。
  值越大，持续时间越短，下落越快。
  例如：gravity_factor=2.0时，整体持续时间会减少为正常情况的一半。

使用示例:
1. 基础用法（默认参数）:
   target:AddNewModifier(caster, ability, "modifier_air_spin_controller", {})

2. 向东飞行1000单位:
   target:AddNewModifier(caster, ability, "modifier_air_spin_controller", {
     distance = 1000,
     direction = "east"
   })

3. 高高度，自定义方向和快速旋转:
   target:AddNewModifier(caster, ability, "modifier_air_spin_controller", {
     height = 1200,
     distance = 800,
     direction = {x=0.5, y=0.5},  -- 向东南方向
     rotation_speed = 2.0,  -- 每秒2圈
     gravity_factor = 1.5   -- 重力加速度提高50%
   })
]]

modifier_air_spin_controller = class({})

-- 添加修饰器类型声明，指定为HORIZONTAL和VERTICAL运动控制器
function modifier_air_spin_controller:GetAttributes()
    return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_air_spin_controller:IsHidden() return false end
function modifier_air_spin_controller:IsDebuff() return true end
function modifier_air_spin_controller:IsPurgable() return false end
function modifier_air_spin_controller:IsStunDebuff() return true end
function modifier_air_spin_controller:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_air_spin_controller:RemoveOnDeath() return false end

-- 声明这是一个运动控制器修饰器
function modifier_air_spin_controller:GetMotionControllerPriority()
    return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM
end

-- 声明这是一个水平和垂直运动控制器
function modifier_air_spin_controller:GetMotionControllerType()
    return DOTA_MOTION_CONTROLLER_BOTH
end

function modifier_air_spin_controller:OnCreated(kv)
    if IsServer() then

        -- 从参数中获取高度增量，如果没有则使用默认值600
        local height_increment = kv.height or 600
        
        -- 获取重力系数，控制下落速度，如果没有则使用默认值1.5
        self.gravity_factor = kv.gravity_factor or 1.5
        
        -- 使用二次函数计算持续时间 (基于sqrt(height/150)的公式)
        -- 这样当height=600时，持续时间为2秒
        -- 遵循自由落体运动的物理规律，高度与时间平方成正比
        -- 应用重力系数来减少持续时间
        self.duration = math.sqrt(height_increment / 150) / self.gravity_factor

        -- 获取单位当前位置
        local parent = self:GetParent()
        local origin = parent:GetAbsOrigin()
        self.angle = parent:GetAngles()
        self.start_position = origin

        -- 计算最高点高度（原始高度 + 高度增量）
        self.ground_z = GetGroundHeight(origin, parent)
        self.hero_height = parent:GetAbsOrigin().z
        self.max_height = self.hero_height + height_increment

        -- 初始化旋转角度
        self.rotation_x = 0
        
        -- 设置旋转速度（从参数获取，默认为每秒5圈）
        local rotations_per_second = kv.rotation_speed or 5
        -- 每秒旋转的角度 = 每秒旋转圈数 * 360度/圈
        self.rotation_speed = rotations_per_second * 360

        -- 计算上升和下降的时间（各占总时间的一半）
        self.rise_time = self.duration * 0.5
        
        -- 获取单位当前的实际高度
        local current_z = parent:GetAbsOrigin().z
        -- 计算离地高度
        local height_above_ground = current_z - self.ground_z
        -- 判断单位是否在空中
        local is_on_ground = height_above_ground < 10 -- 如果离地小于10单位，视为在地面上
        
        if is_on_ground then
            -- 如果单位在地面上，下落时间和上升时间相同
            self.fall_time = self.rise_time

        else
            -- 单位已经在空中，计算从当前高度到最高点的时间
            local rise_ratio = (self.max_height - current_z) / (self.max_height - self.hero_height)
            -- 确保比例值在合理范围内
            rise_ratio = math.max(0.1, math.min(1.0, rise_ratio))
            -- 根据比例计算实际上升时间
            self.rise_time = self.rise_time * rise_ratio

            
            -- 计算下落时间：假设从最高点到地面的下落时间与高度的平方根成正比
            local full_fall_height = self.max_height - self.ground_z
            self.fall_time = self.duration * 0.5 * math.sqrt(full_fall_height / height_increment)

        end
        
        
        -- 计算总运动时间
        self.total_motion_time = self.rise_time + self.fall_time

        
        -- 记录开始时间
        self.start_time = GameRules:GetGameTime()
       -- 播放翻腾动画
        parent:StartGesture(ACT_DOTA_FLAIL)

        
        -- 设置移动距离，如果没有则使用默认值0（不移动）
        self.move_distance = kv.distance or 500
        
        -- 设置移动方向
        -- 默认为向南 (0,-1,0)
        self.move_direction = Vector(0, -1, 0)
        
        -- 处理direction参数
        if kv.direction then
            -- 检查是否是字符串类型的方向
            if type(kv.direction) == "table" then
                -- 尝试从表格创建Vector
                if kv.direction.x ~= nil and kv.direction.y ~= nil then
                    -- 创建二维方向向量（忽略z轴，因为这是水平移动）
                    self.move_direction = Vector(kv.direction.x, kv.direction.y, 0)

                else

                end
            else

            end
        else

        end
        
        -- 归一化方向向量，确保这是一个单位向量
        if self.move_direction:Length() > 0 then
            self.move_direction = self.move_direction:Normalized()
        end
        
        -- 计算水平速度（单位/秒）
        self.horizontal_speed = self.move_distance / self.total_motion_time

        -- 应用运动控制器
        if not self:ApplyHorizontalMotionController() then
            self:Destroy()
            return
        end
        
        if not self:ApplyVerticalMotionController() then
            self:Destroy()
            return
        end

        
        -- 初始化帧计数器
        self.frameCount = 0
        
        -- 设置标志表示运动控制器成功应用
        self.motion_applied = true
        
        -- 标记上升阶段
        self.rising_phase = true
        -- 标记已达到最高点
        self.reached_peak = false
        -- 标记已落地
        self.has_landed = false
        
        -- 设置思考间隔
        self:StartIntervalThink(0.03)
    end
end

function modifier_air_spin_controller:OnIntervalThink()
    if IsServer() then
        -- 如果运动被中断，直接退出
        if self.motion_interrupted then
            return
        end
        
        local current_time = GameRules:GetGameTime()
        local elapsed_time = current_time - self.start_time
        local parent = self:GetParent()
        
        -- 计算当前应该处于的阶段
        if elapsed_time >= self.rise_time and self.rising_phase then
            -- 从上升阶段转为下降阶段
            self.rising_phase = false
            self.reached_peak = true

        end
        
        -- 检查是否完成了整个运动过程
        if elapsed_time >= self.total_motion_time and not self.has_landed then
            -- 标记已落地
            self.has_landed = true
            
            -- 确保单位位置正确设置为地面高度
            local current_pos = parent:GetAbsOrigin()
            parent:SetAbsOrigin(Vector(current_pos.x, current_pos.y, self.ground_z))
            
            -- 重置角度到正常朝向
            parent:SetAngles(0, self.angle.y, self.angle.z)
            
            -- 移除修饰器
            self:Destroy()
            return
        end
        
        -- 检查单位是否已经到达或接近地面（这是一个备用检查，UpdateVerticalMotion中已有类似逻辑）
        if self.has_landed then
            -- 如果已标记为落地，且不是被中断状态，则销毁修饰器
            if not self.motion_interrupted then
                self:Destroy()
            end
            return
        end
    end
end

function modifier_air_spin_controller:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        -- 检查是否被新的同类modifier打断
        if self.motion_interrupted then
            self:Destroy()
            return
        end
        
        -- 如果没有设置移动距离，则不进行水平移动
        if self.move_distance <= 0 then
            return
        end
        
        local current_time = GameRules:GetGameTime()
        local elapsed_time = current_time - self.start_time
        
        -- 计算此帧应移动的距离
        local distance_this_frame = self.horizontal_speed * dt
        
        -- 获取当前位置
        local current_pos = me:GetAbsOrigin()
        
        -- 计算新位置（按照设定方向移动）
        local new_pos = Vector(
            current_pos.x + self.move_direction.x * distance_this_frame,
            current_pos.y + self.move_direction.y * distance_this_frame,
            current_pos.z
        )
        
        -- 更新位置（z坐标由垂直运动控制）
        me:SetAbsOrigin(new_pos)
        

    end
end

function modifier_air_spin_controller:UpdateVerticalMotion(me, dt)
    if IsServer() then
        -- 检查是否被新的同类modifier打断
        if self.motion_interrupted then
            self:Destroy()
            return
        end
        
        local current_time = GameRules:GetGameTime()
        local elapsed_time = current_time - self.start_time
        
        -- 更新帧计数器
        self.frameCount = self.frameCount + 1
        
        -- 每10帧打印一次详细信息

        
        -- 计算当前高度
        local current_height
        if elapsed_time <= self.rise_time then
            -- 上升阶段：使用二次函数实现平滑上升
            local progress = math.min(elapsed_time / self.rise_time, 1.0)
            current_height = self.hero_height + (self.max_height - self.hero_height) * (-(progress - 1) * (progress - 1) + 1)
            

        else
            -- 下降阶段：使用二次函数实现平滑下降到地面
            local fall_progress = math.min((elapsed_time - self.rise_time) / self.fall_time, 1.0)
            -- 从最高点下降到地面，而不是起始高度
            current_height = self.max_height - (self.max_height - self.ground_z) * (fall_progress * fall_progress)
            

            
            -- 检查是否接近地面
            if current_height <= self.ground_z + 5 and not self.has_landed then
                -- 确保不会低于地面
                current_height = self.ground_z
                
                -- 标记已落地
                self.has_landed = true

                -- 重置单位角度到正常朝向，并在下一帧销毁此modifier
                me:SetAngles(0, self.angle.y, self.angle.z)
                self:SetDuration(0.03, true)
            end
        end
        

        -- 更新旋转角度（前空翻，绕X轴旋转）
        self.rotation_x = self.rotation_x + (self.rotation_speed * dt)
        self.rotation_x = self.rotation_x % 360  -- 确保不超过360度
        

        -- 更新单位高度，使用当前的水平位置
        me:SetAbsAngles(self.rotation_x, self.angle.y, self.angle.z)
        me:SetAbsOrigin(Vector(me:GetAbsOrigin().x, me:GetAbsOrigin().y, current_height))
    end
end

function modifier_air_spin_controller:OnHorizontalMotionInterrupted()
    if IsServer() then
        if self.motion_applied then
            -- 设置标志表明运动被中断，不是正常结束
            self.motion_interrupted = true
            
            -- 释放控制器，但不执行落地逻辑
            local parent = self:GetParent()
            if parent and not parent:IsNull() then
                parent:RemoveHorizontalMotionController(self)

            end
        end
        -- 不直接销毁，允许新的modifier接管
    end
end

function modifier_air_spin_controller:OnVerticalMotionInterrupted()
    if IsServer() then

        if self.motion_applied then
            -- 设置标志表明运动被中断，不是正常结束
            self.motion_interrupted = true
            
            -- 释放控制器，但不执行落地逻辑
            local parent = self:GetParent()
            if parent and not parent:IsNull() then
                parent:RemoveVerticalMotionController(self)

            end
        end
        -- 不直接销毁，允许新的modifier接管
    end
end

function modifier_air_spin_controller:OnDestroy()
    if IsServer() then

        
        local parent = self:GetParent()
        if parent and not parent:IsNull() then
            -- 如果motion_applied是true，则需要移除运动控制器
            if self.motion_applied then
                -- 移除运动控制器

                parent:RemoveHorizontalMotionController(self)
                

                parent:RemoveVerticalMotionController(self)
            end
            
            -- 重置单位角度到初始值（正面朝向）
            parent:SetAngles(0, self.angle.y, self.angle.z)

            
            parent:FadeGesture(ACT_DOTA_FLAIL)
            
            -- 查找并移除所有同名modifier
            local all_modifiers = parent:FindAllModifiersByName("modifier_air_spin_controller")
            for _, modifier in pairs(all_modifiers) do
                -- 跳过当前正在销毁的modifier
                if modifier ~= self then

                    modifier:Destroy()
                end
            end
        else

        end
        

    end
end

function modifier_air_spin_controller:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,

    }
end

function modifier_air_spin_controller:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
end

function modifier_air_spin_controller:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end 