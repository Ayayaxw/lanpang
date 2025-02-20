modifier_custom_unicycle = class({})

function modifier_custom_unicycle:IsHidden() return true end
function modifier_custom_unicycle:IsPurgable() return false end
function modifier_custom_unicycle:RemoveOnDeath() return true end

function modifier_custom_unicycle:OnCreated(kv)
    if IsServer() then
        local parent = self:GetParent()
        self.height = 100  -- 设置想要的高度
        self.base_z = parent:GetAbsOrigin().z + self.height  -- 记录初始高度
        
        -- 创建独轮车模型
        self.unicycle_prop = SpawnEntityFromTableSynchronous("prop_dynamic", {
            model = "models/heroes/ringmaster/ringmaster_unicycle.vmdl",
            DefaultAnim = "idle",
            targetname = DoUniqueString("unicycle_prop")
        })
        
        -- 设置独轮车位置和旋转
        self.unicycle_prop:SetParent(parent, "")
        self.unicycle_prop:SetLocalAngles(0, 90, 0)
        
        -- 初始化旋转值
        self.currentRotation = 0
        
        -- 开启位置更新
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_custom_unicycle:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        if not parent or parent:IsNull() then return end

        -- 维持固定高度
        local current_pos = parent:GetAbsOrigin()
        parent:SetAbsOrigin(Vector(
            current_pos.x,
            current_pos.y,
            self.base_z
        ))

        -- 更新轮子旋转
        if parent:IsMoving() then
            local moveSpeed = parent:GetIdealSpeed()
            local rotationRate = moveSpeed / 300
            self.currentRotation = self.currentRotation + rotationRate
            if self.currentRotation >= 360 then
                self.currentRotation = self.currentRotation - 360
            end
            self.unicycle_prop:SetLocalAngles(self.currentRotation, 90, 0)
        end
    end
end

function modifier_custom_unicycle:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        if parent and not parent:IsNull() then
            -- 恢复到初始高度
            local current_pos = parent:GetAbsOrigin()
            parent:SetAbsOrigin(Vector(
                current_pos.x,
                current_pos.y,
                current_pos.z - self.height
            ))
        end
        
        if self.unicycle_prop and not self.unicycle_prop:IsNull() then
            self.unicycle_prop:RemoveSelf()
        end
    end
end