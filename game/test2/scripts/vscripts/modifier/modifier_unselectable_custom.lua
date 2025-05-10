-- 创建和注册自定义修饰器

-- 自定义不可选中修饰器
modifier_unselectable_custom = class({})

function modifier_unselectable_custom:CheckState()
    local state = {
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_UNTARGETABLE] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_FISSURE] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_OBSTRUCTIONS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_BASE_BLOCKER] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    }
    return state
end

function modifier_unselectable_custom:IsHidden() return true end
function modifier_unselectable_custom:IsPurgable() return false end
function modifier_unselectable_custom:RemoveOnDeath() return true end
