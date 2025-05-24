-- 自动海象神拳修饰器
modifier_auto_walrus_punch_custom = class({})

function modifier_auto_walrus_punch_custom:IsHidden() return false end
function modifier_auto_walrus_punch_custom:IsDebuff() return false end
function modifier_auto_walrus_punch_custom:IsPurgable() return false end

function modifier_auto_walrus_punch_custom:OnCreated(kv)
    if not IsServer() then return end
    
    print("[Auto Walrus Punch] OnCreated 开始")
    

    
    local parent = self:GetParent()
    -- 检查单位是否有海象神拳技能
    local ability_name = "tusk_walrus_punch"
    local walrus_punch_ability = parent:FindAbilityByName(ability_name)
    
    if not walrus_punch_ability then
        -- 如果没有此技能，添加技能
        print("[Auto Walrus Punch] 单位没有海象神拳技能，添加技能")
        walrus_punch_ability = parent:AddAbility(ability_name)
        
        -- 将技能升级到最高级（3级）
        walrus_punch_ability:SetLevel(3)
        walrus_punch_ability:ToggleAutoCast() -- 切换为自动施放
        print("[Auto Walrus Punch] 海象神拳技能已添加并升至3级")
        walrus_punch_ability:SetHidden(true)
    else
        -- 如果已有技能但未满级，则升级
        if walrus_punch_ability:GetLevel() < 3 then
            walrus_punch_ability:SetLevel(3)
            print("[Auto Walrus Punch] 已有海象神拳技能升至3级")
        else
            print("[Auto Walrus Punch] 单位已有3级海象神拳技能")
        end
        
        -- 确保自动施放开启
        if not walrus_punch_ability:GetAutoCastState() then
            walrus_punch_ability:ToggleAutoCast()
        end
    end
    
    -- 保存技能引用以便后续使用
    self.walrus_punch_ability = walrus_punch_ability
    
    -- 获取技能实体索引并修改KV数据
    Timers:CreateTimer(0.2, function()
        local ability_name = "tusk_walrus_punch"
        local walrus_punch_ability = parent:FindAbilityByName(ability_name)
        local ability_index = walrus_punch_ability:GetEntityIndex()
        
        -- 创建需要修改的KV数据
        local kv_data = {
            AbilityCooldown = 0,
            AbilityManaCost = 0
        }
        
        -- 更新网络表
        CustomNetTables:SetTableValue("edit_kv", tostring(ability_index), kv_data)
        
        -- 确保英雄已应用modifier_kv_editor_specific_ability
        if not parent:HasModifier("modifier_kv_editor_specific_ability") then
            parent:AddNewModifier(parent, nil, "modifier_kv_editor_specific_ability", {})
        end
    end)
    
    print("[Auto Walrus Punch] OnCreated 完成")
end

function modifier_auto_walrus_punch_custom:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end


-- 添加伤害事件处理
function modifier_auto_walrus_punch_custom:OnTakeDamage(event)
    if not IsServer() then return end
    
    local parent = self:GetParent()
    local attacker = event.attacker
    local target = event.unit
    local inflictor = event.inflictor
    
    if not attacker or not target then
        return
    end
    
    -- 获取攻击者的真正主人
    local realOwner = attacker:GetRealOwner()
    
    -- 检查是不是modifier拥有者或其主人
    local isOwnerOrUnit = (attacker == parent) or (realOwner == parent)
    
    if isOwnerOrUnit and target ~= attacker and (inflictor or attacker ~= realOwner) and target:GetTeamNumber() ~= parent:GetTeamNumber() and target:IsAlive() then
        -- 检查该目标在当前帧是否已被攻击过
        local target_entindex = target:GetEntityIndex()

        local damageAmount = parent:GetAverageTrueAttackDamage(nil) * 3
        
        local damageTable = {
            victim = target,
            attacker = parent,
            damage = damageAmount,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
        }
        
        ApplyDamage(damageTable)
        target:AddNewModifier(parent, nil, "modifier_stunned", {duration = 1})
        target:AddNewModifier(parent, nil, "modifier_air_spin_controller", {rotation_speed = 0.82, height = 500, distance = 0})
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, damageAmount, nil)
        
        -- 添加海象神拳的音效
        EmitSoundOn("Hero_Tusk.WalrusPunch.Target", parent)
        -- 添加海象神拳的特效
        -- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        -- ParticleManager:SetParticleControl(particle, 0, parent:GetAbsOrigin())
        -- ParticleManager:ReleaseParticleIndex(particle)
        
        local particle_impact = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_tgt_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(particle_impact, 0, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_impact, 1, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_impact)
        
        print("[Auto Walrus Punch] 施加伤害完成: " .. damageAmount)
    end
end

function modifier_auto_walrus_punch_custom:OnDestroy()
    if not IsServer() then return end
    
    print("[Auto Walrus Punch] OnDestroy")
    -- 可以选择在这里移除技能或保留
    -- 如果要移除技能，取消下面的注释
    -- local parent = self:GetParent()
    -- if parent and not parent:IsNull() then
    --     if self.walrus_punch_ability and not self.walrus_punch_ability:IsNull() then
    --         parent:RemoveAbility(self.walrus_punch_ability:GetAbilityName())
    --         print("[Auto Walrus Punch] 移除海象神拳技能")
    --     end
    -- end
end 