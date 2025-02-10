-- custom_inner_fire.lua

function CustomInnerFire(keys)
    local caster = keys.caster
    local ability = keys.ability
    local radius = ability:GetSpecialValueFor("radius")
    local damage = ability:GetSpecialValueFor("damage")
    local knockback_duration = ability:GetSpecialValueFor("knockback_duration")
    local knockback_distance = ability:GetSpecialValueFor("knockback_distance")

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        FIND_ANY_ORDER,
        false
    )

    for _, enemy in ipairs(enemies) do
        ApplyDamage({
            victim = enemy,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_PURE,
            ability = ability,
            damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION 
        })

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
        ParticleManager:ReleaseParticleIndex(particle)

        local knockback = {
            should_stun = true,
            knockback_duration = knockback_duration,
            duration = knockback_duration,
            knockback_distance = knockback_distance,
            knockback_height = 0,
            center_x = caster:GetAbsOrigin().x,
            center_y = caster:GetAbsOrigin().y,
            center_z = caster:GetAbsOrigin().z
        }

        enemy:AddNewModifier(caster, ability, "modifier_knockback", knockback)

        -- 在被命中的单位身上发出音效
        EmitSoundOn("Hero_Huskar.Inner_Fire.Cast", enemy)
    end
end
