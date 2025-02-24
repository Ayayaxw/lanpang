function CDOTA_Buff:IsFearDebuff()
    local tables = {}
    self:CheckStateToTable(tables)
    
    for state_name, mod_table in pairs(tables) do
        if tostring(state_name) == tostring(MODIFIER_STATE_FEARED) then
             return true
        end
    end
    return false
end

function CDOTA_Buff:IsTauntDebuff()
    local tables = {}
    self:CheckStateToTable(tables)
    
    for state_name, mod_table in pairs(tables) do
        if tostring(state_name) == tostring(MODIFIER_STATE_TAUNTED) then
             return true
        end
    end
    return false
end

function CDOTA_BaseNPC:IsLeashed()
    if not IsServer() then return end
    
    for _, mod in pairs(self:FindAllModifiers()) do
        local tables = {}
        mod:CheckStateToTable(tables)
        local bkb_allowed = true
    
        if mod:GetAbility() then 
            local behavior = mod:GetAbility():GetAbilityTargetFlags()
    
            if bit.band(behavior, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) == 0 and self:IsDebuffImmune() then 
                bkb_allowed = false
            end 
        end 
    
        if bkb_allowed == true then 
            for state_name, mod_table in pairs(tables) do
                if tostring(state_name) == tostring(MODIFIER_STATE_TETHERED) then
                     return true
                end
            end
        end
    end
    return false
end