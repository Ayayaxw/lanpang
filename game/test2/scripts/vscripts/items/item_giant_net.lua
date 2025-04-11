item_giant_net = class({})

LinkLuaModifier("modifier_giant_net_root", "items/item_giant_net", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_giant_net_thinker", "items/item_giant_net", LUA_MODIFIER_MOTION_NONE)

function item_giant_net:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    
    -- 尝试不同的方式访问特殊值
    print("[Giant Net] 调试 - 尝试不同方式获取特殊值:")
    print("[Giant Net] self:GetSpecialValueFor(\"01\"): " .. (self:GetSpecialValueFor("01") or "nil"))
    print("[Giant Net] self:GetSpecialValueFor(\"radius\"): " .. (self:GetSpecialValueFor("radius") or "nil"))
    print("[Giant Net] self:GetSpecialValueFor(\"1\"): " .. (self:GetSpecialValueFor("1") or "nil"))
    
    -- 使用硬编码的值
    local radius = 1000  -- 直接使用配置文件中的值
    local duration = 30  -- 一个合理的持续时间
    
    print("[Giant Net] 施放巨网，坐标: " .. point.x .. "," .. point.y .. "," .. point.z)
    print("[Giant Net] 使用硬编码值 - 半径: " .. radius .. ", 持续时间: " .. duration)
    
    -- 调试：显示施法范围
    --DebugDrawCircle(point, Vector(255,0,0), 100, radius, true, 5)
    
    CreateModifierThinker(
        caster,
        self,
        "modifier_giant_net_thinker",
        {
            duration = duration,
            radius = radius
        },
        point,
        caster:GetTeamNumber(),
        false
    )
    
    caster:EmitSound("Hero_Meepo.Earthbind.Cast")
end

function item_giant_net:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function item_giant_net:GetCastRange(location, target)
    return self:GetSpecialValueFor("cast_range")
end

--------------------------------------------------------------------
modifier_giant_net_thinker = class({})

function modifier_giant_net_thinker:OnCreated(kv)
    if IsServer() then
        -- 解析参数，默认值以防参数无效
        self.radius = tonumber(kv.radius) or 1000
        if self.radius <= 0 then self.radius = 1000 end
        
        print("[Giant Net] 创建网修饰器，半径: " .. self.radius)
        self.caster = self:GetCaster()
        self.ability = self:GetAbility()
        self.netID = DoUniqueString("net")
        self.capturedUnits = {}

        -- 特效必须绑定到思考者
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_meepo/meepo_earthbind.vpcf",
            PATTACH_WORLDORIGIN,
            self:GetParent()
        )
        ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius, self.radius, 0))

        -- 显示持续的调试圆
        local duration = self:GetRemainingTime()
        if duration <= 0 then duration = 30 end
        
        print("[Giant Net] 思考者持续时间: " .. duration)
        --DebugDrawCircle(self:GetParent():GetAbsOrigin(), Vector(255,0,0), 128, self.radius, true, duration)
        
        -- 立即执行首次检测
        self:OnIntervalThink()
        self:StartIntervalThink(0.2)
    end
end

function modifier_giant_net_thinker:OnIntervalThink()
    -- 第一次运行时移除地面网特效
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        self.particle = nil
        print("[Giant Net] 已移除地面网特效")
    end

    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        self:GetParent():GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    print("[Giant Net] 搜索单位: 找到" .. #enemies .. "个单位在范围内")

    -- 强制更新所有单位状态
    local currentEnemies = {}
    for _, enemy in ipairs(enemies) do
        currentEnemies[enemy] = true
        if not self.capturedUnits[enemy] then
            print("[Giant Net] 尝试捕获单位: " .. enemy:GetUnitName())
            self:ApplyRoot(enemy)
        end
    end

    -- 清理离开的单位
    for unit,_ in pairs(self.capturedUnits) do
        if not currentEnemies[unit] then
            self:RemoveRoot(unit)
            self.capturedUnits[unit] = nil
        end
    end
end

function modifier_giant_net_thinker:ApplyRoot(target)
    if not IsValidEntity(target) then 
        print("[Giant Net] 无效的目标实体")
        return 
    end
    
    -- 确保单位只能被同一张网束缚一次
    if not target:HasModifier("modifier_giant_net_root") then
        print("[Giant Net] 对单位" .. target:GetUnitName() .. "应用束缚效果")
        
        -- 移除特定的修饰器
        target:RemoveModifierByName("modifier_slark_shadow_dance_persistent")
        target:RemoveModifierByName("modifier_slark_fade_transition")
        
        local duration = self:GetRemainingTime()
        target:AddNewModifier(
            self.caster,
            self.ability,
            "modifier_giant_net_root",
            { duration = duration, netID = self.netID }
        )
        self.capturedUnits[target] = true
        print("[Giant Net] 束缚效果已应用，持续时间: " .. duration)
    else
        print("[Giant Net] 单位已有束缚效果: " .. target:GetUnitName())
    end
end

function modifier_giant_net_thinker:RemoveRoot(target)
    if target:HasModifier("modifier_giant_net_root") then
        local mod = target:FindModifierByName("modifier_giant_net_root")
        if mod and mod.netID == self.netID then
            target:RemoveModifierByName("modifier_giant_net_root")
        end
    end
end

function modifier_giant_net_thinker:OnDestroy()
    if IsServer() then
        -- 清理所有关联单位
        for unit,_ in pairs(self.capturedUnits) do
            self:RemoveRoot(unit)
        end
        
        -- 如果特效还存在，则销毁
        if self.particle then
            ParticleManager:DestroyParticle(self.particle, false)
            self.particle = nil
        end
        
        UTIL_Remove(self:GetParent())
    end
end

--------------------------------------------------------------------
modifier_giant_net_root = class({})

function modifier_giant_net_root:IsHidden() return false end
function modifier_giant_net_root:IsDebuff() return true end
function modifier_giant_net_root:IsPurgable() return false end

function modifier_giant_net_root:OnCreated(kv)
    if IsServer() then
        self.netID = kv.netID
        -- 添加可见的束缚特效到目标单位
        self.particle = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_meepo/meepo_earthbind_model_catch.vpcf",
            PATTACH_ABSORIGIN_FOLLOW,
            self:GetParent()
        )
        self:AddParticle(self.particle, false, false, -1, false, false)
        EmitSoundOn("Hero_Meepo.Earthbind.Target", self:GetParent())
    end
end

function modifier_giant_net_root:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true, -- 禁止移动
        [MODIFIER_STATE_DISARMED] = true, -- 禁止攻击
        [MODIFIER_STATE_INVISIBLE] = false, -- 禁止攻击
    }
end