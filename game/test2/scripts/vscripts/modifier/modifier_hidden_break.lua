-- 定义隐藏的break修饰器
modifier_hidden_break = class({})

function modifier_hidden_break:IsHidden()
    return true -- 使修饰器在UI中不可见
end

function modifier_hidden_break:IsPurgable()
    return false -- 不可被净化
end

function modifier_hidden_break:IsDebuff()
    return true -- 这是一个负面效果
end

function modifier_hidden_break:DeclareFunctions()
    local funcs = {
        -- 如果需要可以在这里添加更多函数
    }
    return funcs
end

function modifier_hidden_break:CheckState()
    local state = {
        [MODIFIER_STATE_PASSIVES_DISABLED] = true -- 这是实现break效果的关键
    }
    return state
end
