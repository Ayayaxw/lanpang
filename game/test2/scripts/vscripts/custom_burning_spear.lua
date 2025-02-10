-- custom_burning_spear.lua

function BurningSpear(keys)
    local caster = keys.caster
    local ability = keys.ability
    local damage = ability:GetSpecialValueFor("damage") -- 设置伤害值
    local radius = 2000

    -- 获取范围内的敌方单位
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

    -- 对范围内的每个敌人造成纯粹伤害
    for _, enemy in ipairs(enemies) do
        ApplyDamage({
            victim = enemy,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_PURE,
            ability = ability
        })

        -- 播放技能特效
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_burning_spear.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
        ParticleManager:ReleaseParticleIndex(particle)

        -- 播放技能音效
        enemy:EmitSound("Hero_Huskar.Burning_Spear")
    end
end
