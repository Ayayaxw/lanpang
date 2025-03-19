ability_extra_health = class({})

function ability_extra_health:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
    -- 获取技能特殊值
    local bonus_health = self:GetSpecialValueFor("bonus_health")
    local duration = self:GetSpecialValueFor("duration")
    
    -- 如果目标有Linken的效果，则不应用
    if target:TriggerSpellAbsorb(self) then
        return
    end
    
    -- 应用modifier给目标
    target:AddNewModifier(
        caster,         -- 来源
        self,           -- 技能
        "modifier_extra_health_bonus", -- modifier名称
        {
            duration = duration,
            bonus_health = bonus_health
        }
    )
    
    -- 播放音效
    EmitSoundOn("DOTA_Item.Bloodstone.Cast", target)
    
    -- 播放粒子效果
    local particle = ParticleManager:CreateParticle(
        "particles/items2_fx/mekanism_recipient.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        target
    )
    ParticleManager:ReleaseParticleIndex(particle)
end

function ability_extra_health:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function ability_extra_health:OnUpgrade()
    -- 可选的升级逻辑
end 