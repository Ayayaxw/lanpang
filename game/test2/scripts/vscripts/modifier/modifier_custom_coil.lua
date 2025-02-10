modifier_custom_coil = class({})

function modifier_custom_coil:IsHidden() return false end
function modifier_custom_coil:IsDebuff() return false end
function modifier_custom_coil:IsPurgable() return false end

function modifier_custom_coil:OnCreated(kv)
    if IsServer() then
        self.center_point = Vector(kv.x, kv.y, kv.z)
        self.radius = kv.radius or 500
        
        -- 创建连接线特效，注意这里改用了PATTACH_CUSTOMORIGIN
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_puck/puck_dreamcoil_tether.vpcf",
            PATTACH_CUSTOMORIGIN,
            self:GetParent()
        )
        
        -- 设置特效起点（英雄）
        ParticleManager:SetParticleControlEnt(
            self.particle,
            0,
            self:GetParent(),
            PATTACH_POINT_FOLLOW,
            "attach_hitloc",
            self:GetParent():GetAbsOrigin(),
            true
        )
        
        -- 设置特效终点（中心点）
        ParticleManager:SetParticleControl(
            self.particle,
            1,
            self.center_point
        )
    end
end

function modifier_custom_coil:OnDestroy()
    if IsServer() then
        if self.particle then
            ParticleManager:DestroyParticle(self.particle, false)
            ParticleManager:ReleaseParticleIndex(self.particle)
        end
    end
end