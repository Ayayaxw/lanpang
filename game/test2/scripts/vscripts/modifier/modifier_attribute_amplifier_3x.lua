modifier_attribute_amplifier_3x = class({})

function modifier_attribute_amplifier_3x:IsHidden() return false end
function modifier_attribute_amplifier_3x:IsDebuff() return false end
function modifier_attribute_amplifier_3x:IsPurgable() return false end
function modifier_attribute_amplifier_3x:RemoveOnDeath() return false end
function modifier_attribute_amplifier_3x:IsPermanent() return true end

function modifier_attribute_amplifier_3x:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
end

function modifier_attribute_amplifier_3x:OnCreated()
    if not IsServer() then return end
    local hero = self:GetParent()
    
    if hero:IsIllusion() then
        -- 幻象记录原始属性
        self.original_str = hero:GetBaseStrength()
        self.original_agi = hero:GetBaseAgility()
        self.original_int = hero:GetBaseIntellect()
        return
    end
    
    -- 以下是本体的处理
    self.original_total_str = hero:GetStrength()
    self.original_total_agi = hero:GetAgility()
    self.original_total_int = hero:GetIntellect(false)
    
    self.original_base_str = hero:GetBaseStrength()
    self.original_base_agi = hero:GetBaseAgility()
    self.original_base_int = hero:GetBaseIntellect()
    
    local target_total_str = self.original_total_str * 3
    local target_total_agi = self.original_total_agi * 3
    local target_total_int = self.original_total_int * 3
    
    local str_diff = target_total_str - self.original_total_str
    local agi_diff = target_total_agi - self.original_total_agi
    local int_diff = target_total_int - self.original_total_int
    
    local new_base_str = self.original_base_str + str_diff
    local new_base_agi = self.original_base_agi + agi_diff
    local new_base_int = self.original_base_int + int_diff
    
    hero:SetBaseStrength(new_base_str)
    hero:SetBaseAgility(new_base_agi)
    hero:SetBaseIntellect(new_base_int)
    
    if IsServer() then
        self:PrintAttributeChanges()
    end
end

function modifier_attribute_amplifier_3x:GetModifierBonusStats_Strength()
    local hero = self:GetParent()
    if not hero:IsIllusion() then return 0 end
    return self.original_str * 2  -- 使用记录的原始属性计算
end

function modifier_attribute_amplifier_3x:GetModifierBonusStats_Agility()
    local hero = self:GetParent()
    if not hero:IsIllusion() then return 0 end
    return self.original_agi * 2
end

function modifier_attribute_amplifier_3x:GetModifierBonusStats_Intellect()
    local hero = self:GetParent()
    if not hero:IsIllusion() then return 0 end
    return self.original_int * 2
end

function modifier_attribute_amplifier_3x:PrintAttributeChanges()
    local hero = self:GetParent()
    print("Attribute Amplifier (5x) for " .. hero:GetName())
    print(string.format("Original Total Attributes: Str %d, Agi %d, Int %d", 
        self.original_total_str,
        self.original_total_agi,
        self.original_total_int))
    print(string.format("New Total Attributes: Str %d, Agi %d, Int %d", 
        hero:GetStrength(),
        hero:GetAgility(),
        hero:GetIntellect(false)))
    print(string.format("Original Base Attributes: Str %d, Agi %d, Int %d", 
        self.original_base_str,
        self.original_base_agi,
        self.original_base_int))
    print(string.format("New Base Attributes: Str %d, Agi %d, Int %d", 
        hero:GetBaseStrength(),
        hero:GetBaseAgility(),
        hero:GetBaseIntellect()))
end