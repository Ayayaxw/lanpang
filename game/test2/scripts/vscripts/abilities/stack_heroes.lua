stack_heroes = class({})

function stack_heroes:OnSpellStart()
    local caster = self:GetCaster()
    local radius = 1000
    local caster_pos = caster:GetAbsOrigin()
    local vertical_offset = 128
    
    local units = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster_pos,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false
    )
    
    -- 计算所有英雄的属性总和，添加false参数
    local total_str = 0
    local total_agi = 0
    local total_int = 0
    
    for _, unit in ipairs(units) do
        total_str = total_str + unit:GetStrength()/10
        total_agi = total_agi + unit:GetAgility()/10
        total_int = total_int + unit:GetIntellect(false)/10
    end
    
    -- 从单位列表中移除施法者
    for i = #units, 1, -1 do
        if units[i] == caster then
            table.remove(units, i)
            break
        end
    end
    
    -- 给施法者添加属性modifier
    caster:AddNewModifier(
        caster,
        self,
        "modifier_stack_heroes_stats",
        {
            str = total_str,
            agi = total_agi,
            int = total_int
        }
    )
    
    for i, unit in ipairs(units) do
        local height = vertical_offset * i
        local new_pos = Vector(
            caster_pos.x,
            caster_pos.y,
            caster_pos.z + height
        )
        
        FindClearSpaceForUnit(unit, new_pos, true)
        unit:SetAbsOrigin(new_pos)
        
        unit:AddNewModifier(unit, nil, "modifier_invulnerable", {})
        unit:AddNewModifier(unit, nil, "modifier_phased", {})
        
        unit:AddNewModifier(
            caster,
            self,
            "modifier_stack_heroes",
            {
                duration = -1,
                height = height,
                parent_unit = caster:entindex()
            }
        )
    end
    
    caster:AddNewModifier(caster, nil, "modifier_phased", {})
end

LinkLuaModifier("modifier_stack_heroes_stats", "abilities/stack_heroes", LUA_MODIFIER_MOTION_NONE)

modifier_stack_heroes_stats = class({})

function modifier_stack_heroes_stats:IsHidden() return false end
function modifier_stack_heroes_stats:IsDebuff() return false end
function modifier_stack_heroes_stats:IsPurgable() return false end

function modifier_stack_heroes_stats:OnCreated(kv)
    if IsServer() then
        self.bonus_str = kv.str
        self.bonus_agi = kv.agi
        self.bonus_int = kv.int
    end
end

function modifier_stack_heroes_stats:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
end

function modifier_stack_heroes_stats:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_stack_heroes_stats:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_stack_heroes_stats:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

LinkLuaModifier("modifier_stack_heroes", "abilities/stack_heroes", LUA_MODIFIER_MOTION_NONE)

modifier_stack_heroes = class({})

function modifier_stack_heroes:IsHidden() return false end
function modifier_stack_heroes:IsDebuff() return false end
function modifier_stack_heroes:IsPurgable() return false end

function modifier_stack_heroes:OnCreated(kv)
    if IsServer() then
        self.height = kv.height
        self.parent_unit = EntIndexToHScript(kv.parent_unit)
        
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_stack_heroes:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        local parent_pos = self.parent_unit:GetAbsOrigin()
        
        if not self.parent_unit:IsAlive() then
            parent:RemoveModifierByName("modifier_invulnerable")
            parent:RemoveModifierByName("modifier_phased")
            parent:ForceKill(false)
            self:Destroy()
            return
        end
        
        local new_pos = Vector(
            parent_pos.x,
            parent_pos.y,
            parent_pos.z + self.height
        )
        parent:SetAbsOrigin(new_pos)
    end
end

function modifier_stack_heroes:CheckState()
    return {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_INVULNERABLE] = true
    }
end

function modifier_stack_heroes:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_stack_heroes:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_stack_heroes:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        if parent then
            if parent:HasModifier("modifier_invulnerable") then
                parent:RemoveModifierByName("modifier_invulnerable")
            end
            if parent:HasModifier("modifier_phased") then
                parent:RemoveModifierByName("modifier_phased")
            end
        end
    end
end