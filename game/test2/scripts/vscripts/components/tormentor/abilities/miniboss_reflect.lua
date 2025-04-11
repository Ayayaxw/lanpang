LinkLuaModifier("modifier_miniboss_reflect_custom", "components/tormentor/abilities/miniboss_reflect.lua", LUA_MODIFIER_MOTION_NONE)

miniboss_reflect_custom = miniboss_reflect_custom or class({})

function miniboss_reflect_custom:Spawn()
	if IsServer() then
		self:SetLevel(1)
	end
end

function miniboss_reflect_custom:GetIntrinsicModifierName()
	return "modifier_miniboss_reflect_custom"
end

---------------------------------------------------------------------------------------------------

modifier_miniboss_reflect_custom = modifier_miniboss_reflect_custom or class({})

function modifier_miniboss_reflect_custom:IsHidden()
	return true
end

function modifier_miniboss_reflect_custom:IsDebuff()
	return false
end

function modifier_miniboss_reflect_custom:IsPurgable()
	return false
end

function modifier_miniboss_reflect_custom:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_miniboss_reflect_custom:OnCreated()
    if not IsServer() then return end

    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    -- 强制设置为天灾阵营
    self.tormentorTeam = DOTA_TEAM_GOODGUYS  -- 直接赋值替代原有逻辑

    self.radius = self.ability:GetSpecialValueFor("radius")
    self.illusion_damage_pct = self.ability:GetSpecialValueFor("illusion_damage_pct")

    self.pfx_name = {
        [DOTA_TEAM_GOODGUYS] = { -- 注意拼写正确，原代码中的DOTA_TEAM_GOODGUYS可能有拼写错误
            shield = "particles/neutral_fx/miniboss_shield.vpcf",
            reflect = "particles/neutral_fx/miniboss_damage_reflect.vpcf",
            impact = "particles/neutral_fx/miniboss_damage_impact.vpcf",
            death = "particles/neutral_fx/miniboss_death.vpcf",
        },
        [DOTA_TEAM_BADGUYS] = {
            shield = "particles/neutral_fx/miniboss_shield_dire.vpcf",
            reflect = "particles/neutral_fx/miniboss_damage_reflect_dire.vpcf",
            impact = "particles/neutral_fx/miniboss_dire_damage_impact.vpcf",
            death = "particles/neutral_fx/miniboss_death_dire.vpcf",
        }
    }

    -- 使用已设置的阵营值
    local deaths = Tormentors:GetDeaths(self.tormentorTeam)
    self.bonusReflectionPerDeath = self.ability:GetSpecialValueFor("passive_reflection_bonus_per_death") * deaths
    self.reflection = self.ability:GetSpecialValueFor("passive_reflection_pct") + self.bonusReflectionPerDeath

    if self.pfx_name[self.tormentorTeam] and self.pfx_name[self.tormentorTeam].shield then
        -- 创建粒子时使用自定义原点
        self.shield_pfx = ParticleManager:CreateParticle(
            self.pfx_name[self.tormentorTeam].shield,
            PATTACH_CUSTOMORIGIN,  -- 自定义原点模式
            self.parent
        )
        
        -- 定义更新位置的函数
        local function UpdateShieldPosition()
            if not IsValidEntity(self.parent) or not self.parent:IsAlive() then
                ParticleManager:DestroyParticle(self.shield_pfx, false)
                return nil
            end
            
            -- 计算单位中心高度
            local origin = self.parent:GetAbsOrigin()
            local mins, maxs = self.parent:GetBoundingMins(), self.parent:GetBoundingMaxs()
            local centerZ = origin.z + (mins.z + maxs.z) / 2 + 200
            
            -- 设置粒子位置到中心
            ParticleManager:SetParticleControl(
                self.shield_pfx,
                0,  -- 控制点索引（通常0为主控制点）
                Vector(origin.x, origin.y, centerZ)
            )
            return 0.03  -- 每帧更新（约30次/秒）
        end
        
        -- 启动定时更新
        GameRules:GetGameModeEntity():SetThink(UpdateShieldPosition, "UpdateShield", 0)
    end

    self:SetHasCustomTransmitterData(true)
end

function modifier_miniboss_reflect_custom:AddCustomTransmitterData()
	return {
		reflection = self.reflection,
	}
end

function modifier_miniboss_reflect_custom:HandleCustomTransmitterData(data)
	self.reflection = data.reflection
end

function modifier_miniboss_reflect_custom:OnTakeDamage(keys)
    if not IsServer() then return end

    local damage = keys.original_damage
    local damageType = keys.damage_type
    local damageFlags = keys.damage_flags
    local attacker = keys.attacker

    if keys.unit ~= self.parent then return end
    
    -- 忽略带有反射标记的伤害
    if bit.band(damageFlags, DOTA_DAMAGE_FLAG_REFLECTION) > 0 then
        return
    end

    -- -- 忽略无法法术吸血的伤害
    -- if bit.band(damageFlags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) > 0 then
    --     print("忽略无法法术吸血的伤害")
    --     return
    -- end

    -- 忽略无法法术增幅的伤害
    -- if bit.band(damageFlags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION) > 0 then
    --     print("忽略无法法术增幅的伤害")
    --     return
    -- end

    -- 检查攻击者是否为普通单位
    local isAttackerBasicUnit = attacker and not attacker:IsHero() and not attacker:IsBuilding() and not attacker:IsAncient() and not attacker:IsCourier() and not attacker:IsZombie() and not attacker:IsOther()
    
    -- 查找范围内的敌方英雄
    local enemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(),
        self.parent:GetAbsOrigin(),
        nil,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )
    self.parent:RemoveGesture(ACT_DOTA_FLINCH)
    self.parent:StartGesture(ACT_DOTA_FLINCH)

    -- 通用伤害参数
    local damageTable = {
        attacker = self.parent,
        damage_type = damageType,
        ability = self.ability,
        damage_flags = bit.bor(DOTA_DAMAGE_FLAG_REFLECTION, DOTA_DAMAGE_FLAG_ATTACK_MODIFIER),
    }

    -- 创建有效目标列表
    local valid_targets = {}
    
    -- 筛选有效英雄目标
    for _, enemy in pairs(enemies) do
        if enemy and not enemy:IsNull() and IsValidEntity(enemy) and enemy:IsAlive() and 
           not enemy:IsIllusion() and 
           not enemy:IsOther() and not enemy:IsZombie() then
            print("添加有效目标",enemy:GetUnitName())
            table.insert(valid_targets, enemy)
        else
            print("无效目标")
        end
    end
    
    -- 添加符合条件的普通单位攻击者
    local attackerAdded = false
    if isAttackerBasicUnit and attacker and not attacker:IsNull() and not attacker:IsZombie() and not attacker:IsOther() and IsValidEntity(attacker) and 
       attacker:IsAlive() then
        print("攻击者不是zombie")
        table.insert(valid_targets, attacker)
        attackerAdded = true
    end

    -- 没有有效目标时的处理
    if #valid_targets == 0 then
        --
        print("没有有效目标")
        if attacker and not attacker:IsNull() and IsValidEntity(attacker) and attacker:IsAlive() and not attacker:IsDebuffImmune() then
            -- 如果攻击者是非英雄单位，直接击杀
            if not attacker:IsHero() then
                attacker:Kill(self.ability, self.parent)
                
                -- 播放特效和音效
                local pfx = ParticleManager:CreateParticle(self.pfx_name[self.tormentorTeam].reflect, PATTACH_ABSORIGIN_FOLLOW, self.parent)
                ParticleManager:SetParticleControl(pfx, 0, self.parent:GetAbsOrigin())
                ParticleManager:SetParticleControlEnt(pfx, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(pfx)
                attacker:EmitSound("Miniboss.Tormenter.Reflect")
            else
                -- 对英雄单位正常反弹伤害
                damageTable.victim = attacker
                damageTable.damage = damage * self.reflection / 100

                if attacker:IsIllusion() then
                    damageTable.damage = damageTable.damage * self.illusion_damage_pct / 100
                end

                ApplyDamage(damageTable)

                local pfx = ParticleManager:CreateParticle(self.pfx_name[self.tormentorTeam].reflect, PATTACH_ABSORIGIN_FOLLOW, self.parent)
                ParticleManager:SetParticleControl(pfx, 0, self.parent:GetAbsOrigin())
                ParticleManager:SetParticleControlEnt(pfx, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(pfx)
                attacker:EmitSound("Miniboss.Tormenter.Reflect")
            end
        end
        return
    end
    
    -- 计算分摊伤害
    local reflectedDamage = (damage * self.reflection / 100) / #valid_targets
    
    -- 对每个目标造成伤害
    for _, target in pairs(valid_targets) do
        -- 跳过减益免疫的单位
        if target:IsDebuffImmune() then
            -- 只播放特效和音效，不造成伤害
            local pfx = ParticleManager:CreateParticle(self.pfx_name[self.tormentorTeam].reflect, PATTACH_ABSORIGIN_FOLLOW, self.parent)
            ParticleManager:SetParticleControl(pfx, 0, self.parent:GetAbsOrigin())
            ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(pfx)
            target:EmitSound("Miniboss.Tormenter.Reflect")
        else
            damageTable.victim = target
            damageTable.damage = reflectedDamage
            
            if target:IsIllusion() then
                damageTable.damage = reflectedDamage * self.illusion_damage_pct / 100
            end
            
            ApplyDamage(damageTable)
            
            local pfx = ParticleManager:CreateParticle(self.pfx_name[self.tormentorTeam].reflect, PATTACH_ABSORIGIN_FOLLOW, self.parent)
            ParticleManager:SetParticleControl(pfx, 0, self.parent:GetAbsOrigin())
            ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(pfx)
            target:EmitSound("Miniboss.Tormenter.Reflect")
        end
    end
    
    -- 处理未加入列表的攻击者
    if attacker and not attacker:IsNull() and IsValidEntity(attacker) and attacker:IsAlive() 
    and not attacker:IsOther() and not attacker:IsZombie() 
    and not attackerAdded and not table.contains(valid_targets, attacker) then 
        if attacker:IsDebuffImmune() then
            -- 只播放特效和音效，不造成伤害
            local pfx = ParticleManager:CreateParticle(self.pfx_name[self.tormentorTeam].reflect, PATTACH_ABSORIGIN_FOLLOW, self.parent)
            ParticleManager:SetParticleControl(pfx, 0, self.parent:GetAbsOrigin())
            ParticleManager:SetParticleControlEnt(pfx, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(pfx)
            attacker:EmitSound("Miniboss.Tormenter.Reflect")
        else
            damageTable.victim = attacker
            damageTable.damage = reflectedDamage
            
            if attacker:IsIllusion() then
                damageTable.damage = reflectedDamage * self.illusion_damage_pct / 100
            end
            
            ApplyDamage(damageTable)
            
            local pfx = ParticleManager:CreateParticle(self.pfx_name[self.tormentorTeam].reflect, PATTACH_ABSORIGIN_FOLLOW, self.parent)
            ParticleManager:SetParticleControl(pfx, 0, self.parent:GetAbsOrigin())
            ParticleManager:SetParticleControlEnt(pfx, 1, attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", attacker:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(pfx)
            attacker:EmitSound("Miniboss.Tormenter.Reflect")
        end
    end
end

function modifier_miniboss_reflect_custom:OnTooltip()
	return self.reflection
end

function modifier_miniboss_reflect_custom:OnDeath(keys)
    if not IsServer() then return end

    if keys.unit ~= self.parent then return end

    -- 使用保存的tormentorTeam而非parent的属性
    local team = self.tormentorTeam
    if self.pfx_name[team] and self.pfx_name[team].death then
        local pfx = ParticleManager:CreateParticle(self.pfx_name[team].death, PATTACH_ABSORIGIN_FOLLOW, self.parent)
        ParticleManager:SetParticleControl(pfx, 0, self.parent:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(pfx)
    end

    if self.shield_pfx then
        ParticleManager:DestroyParticle(self.shield_pfx, true)
        ParticleManager:ReleaseParticleIndex(self.shield_pfx)
    end
end