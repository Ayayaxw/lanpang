if modifier_constant_height_adjustment == nil then
    modifier_constant_height_adjustment = class({})
end

function modifier_constant_height_adjustment:IsHidden() return true end
function modifier_constant_height_adjustment:IsPurgable() return false end
function modifier_constant_height_adjustment:RemoveOnDeath() return false end

-- 允许这个修改器被分身继承
function modifier_constant_height_adjustment:AllowIllusionDuplicate() return true end

function modifier_constant_height_adjustment:OnCreated(kv)
    if IsServer() then
        self.heightAdjustment = kv.height_adjustment or 200
        self:StartIntervalThink(0.03)
    end
end

function modifier_constant_height_adjustment:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        self:AdjustUnitHeight(parent)
    end
end

function modifier_constant_height_adjustment:AdjustUnitHeight(unit)
    -- 获取单位当前位置
    local position = unit:GetAbsOrigin()
    
    -- 获取地面高度
    local groundHeight = GetGroundHeight(position, unit)
    
    -- 调整高度，使单位悬浮在地面上方
    unit:SetAbsOrigin(Vector(position.x, position.y, groundHeight + self.heightAdjustment))
end