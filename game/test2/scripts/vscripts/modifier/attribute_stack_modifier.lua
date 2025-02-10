attribute_stack_modifier = class({})

function attribute_stack_modifier:IsHidden()
    return true
end

function attribute_stack_modifier:IsDebuff()
    return false
end

function attribute_stack_modifier:IsPurgable()
    return false
end

function attribute_stack_modifier:GetTexture()
    return "item_branches"
end

function attribute_stack_modifier:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
        self:LoadHeroKVData()
    end
end

function attribute_stack_modifier:LoadHeroKVData()
    if not self.heroListKV then
        self.heroListKV = LoadKeyValues('scripts/npc/npc_heroes.txt')
    end
    local heroName = self:GetParent():GetUnitName()
    self.heroKV = self.heroListKV[heroName]
    if not self.heroKV then
        print("Warning: No KV data found for hero " .. heroName)
    end
end

function attribute_stack_modifier:OnIntervalThink()
    if IsServer() then
        self:UpdateBonusStats()
    end
end

function attribute_stack_modifier:UpdateBonusStats()
    local parent = self:GetParent()
    local branchCount = 0

    for i = 0, 8 do
        local item = parent:GetItemInSlot(i)
        if item and item:GetName() == "item_iron_branch_custom" then
            branchCount = branchCount + item:GetCurrentCharges()
        end
    end

    if self:GetStackCount() ~= branchCount then
        self:SetStackCount(branchCount)
        parent:CalculateStatBonus(true)
        self:PrintBonusStats()
    end
end

function attribute_stack_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
    return funcs
end

function attribute_stack_modifier:GetModifierBonusStats_Strength()
    if self.heroKV then
        return self:GetStackCount() * (self.heroKV.AttributeStrengthGain or 0)
    end
    return 0
end

function attribute_stack_modifier:GetModifierBonusStats_Agility()
    if self.heroKV then
        return self:GetStackCount() * (self.heroKV.AttributeAgilityGain or 0)
    end
    return 0
end

function attribute_stack_modifier:GetModifierBonusStats_Intellect()
    if self.heroKV then
        return self:GetStackCount() * (self.heroKV.AttributeIntelligenceGain or 0)
    end
    return 0
end

function attribute_stack_modifier:PrintBonusStats()
    local str = self:GetModifierBonusStats_Strength()
    local agi = self:GetModifierBonusStats_Agility()
    local int = self:GetModifierBonusStats_Intellect()
    print(string.format("Hero %s bonus stats - Str: %.2f, Agi: %.2f, Int: %.2f", 
        self:GetParent():GetUnitName(), str, agi, int))
end