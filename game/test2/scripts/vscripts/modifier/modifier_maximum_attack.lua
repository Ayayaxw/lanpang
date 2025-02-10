modifier_maximum_attack = class({})

function modifier_maximum_attack:IsHidden()
    return false
end

function modifier_maximum_attack:IsDebuff()
    return false
end

function modifier_maximum_attack:IsPurgable()
    return false
end

function modifier_maximum_attack:AllowIllusionDuplicate()
    return true
end

function modifier_maximum_attack:RemoveOnDeath()
    return false
end

function modifier_maximum_attack:OnCreated()
    if IsServer() then
        local parent = self:GetParent()
        parent:SetBaseAttackTime(0.00000001)
        
        -- 监听单位创建事件
        ListenToGameEvent("npc_spawned", function(event)
            local spawnedUnit = EntIndexToHScript(event.entindex)
            
            -- 检查是否是同一个玩家的单位且不是double_on_death_mega
            if spawnedUnit:GetPlayerOwnerID() == parent:GetPlayerOwnerID() and 
               spawnedUnit:GetUnitName() ~= "double_on_death_mega" then
                if spawnedUnit:IsIllusion() then
                    -- 如果是幻象，需要检查是否和英雄是同一个单位
                    if spawnedUnit:GetUnitName() == parent:GetUnitName() then
                        spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_maximum_attack", {})
                    end
                else
                    -- 如果不是幻象，直接添加modifier
                    spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_maximum_attack", {})
                end
            end
        end, nil)
    end
end

function modifier_maximum_attack:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT  -- 添加魔法恢复属性
    }
    return funcs
end

function modifier_maximum_attack:GetModifierBaseAttackTimeConstant()
    return 0.00000000
end

function modifier_maximum_attack:GetModifierAttackSpeedBonus_Constant()
    return 100000000
end

function modifier_maximum_attack:GetModifierAttackSpeed_Limit()
    return 1
end

function modifier_maximum_attack:GetModifierConstantManaRegen()
    return 999
end