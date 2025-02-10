item_iron_branch_custom = class({})

function item_iron_branch_custom:GetIntrinsicModifierName()
    return "modifier_iron_branch_detector"
end

LinkLuaModifier("modifier_iron_branch_detector", "items/item_iron_branch_custom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_iron_branch_stats", "items/item_iron_branch_custom", LUA_MODIFIER_MOTION_NONE)

-- Detector modifier
modifier_iron_branch_detector = class({})

function modifier_iron_branch_detector:IsHidden()
    return true
end

function modifier_iron_branch_detector:IsDebuff()
    return false
end

function modifier_iron_branch_detector:IsPurgable()
    return false
end

function modifier_iron_branch_detector:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_iron_branch_detector:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_iron_branch_detector:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()
        local itemCount = 0

        for i = 0, 8 do
            local item = parent:GetItemInSlot(i)
            if item and item:GetName() == "item_iron_branch_custom" then
                itemCount = itemCount + item:GetCurrentCharges()
            end
        end

        local modifier = parent:FindModifierByName("modifier_iron_branch_stats")
        if itemCount > 0 then
            if not modifier then
                modifier = parent:AddNewModifier(parent, nil, "modifier_iron_branch_stats", {})
            end
            modifier:SetStackCount(itemCount)
        else
            if modifier then
                modifier:Destroy()
            end
        end
    end
end

-- Stats modifier
modifier_iron_branch_stats = class({})

function modifier_iron_branch_stats:IsHidden()
    return false
end

function modifier_iron_branch_stats:IsDebuff()
    return false
end

function modifier_iron_branch_stats:IsPurgable()
    return false
end

function modifier_iron_branch_stats:GetTexture()
    return "item_branches"
end

function modifier_iron_branch_stats:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
    return funcs
end

function modifier_iron_branch_stats:GetModifierBonusStats_Strength()
    return self:GetStackCount()
end

function modifier_iron_branch_stats:GetModifierBonusStats_Agility()
    return self:GetStackCount()
end

function modifier_iron_branch_stats:GetModifierBonusStats_Intellect()
    return self:GetStackCount()
end