-- 定义一个修饰器
modifier_full_restore = class({})

-- 修饰器的属性，这里设为隐藏
function modifier_full_restore:IsHidden()
    return true
end

-- 修饰器不会被驱散
function modifier_full_restore:IsPurgable()
    return false
end

-- 当修饰器创建时执行的函数
function modifier_full_restore:OnCreated(kv)
    if IsServer() then
        self:StartIntervalThink(0.1) -- 每0.1秒检查一次
    end
end

function modifier_full_restore:OnIntervalThink()
    if IsServer() then
        local parent = self:GetParent()

        -- 检查单位是否是 Phoenix
        if parent:GetUnitName() == "npc_dota_hero_phoenix" then
            -- 检查生命值是否低于5%
            if parent:GetHealthPercent() < 5 then
                if not parent.bonus_armor_applied then
                    parent:SetPhysicalArmorBaseValue(parent:GetPhysicalArmorBaseValue() + 1000)
                    parent.bonus_armor_applied = true
                end
            else
                if parent.bonus_armor_applied then
                    parent:SetPhysicalArmorBaseValue(parent:GetPhysicalArmorBaseValue() - 1000)
                    parent.bonus_armor_applied = false
                end
            end
        else
            -- 检查生命值和法力值是否低于30%
            if parent:GetHealthPercent() < 30 or parent:GetManaPercent() < 30 then
                parent:SetHealth(parent:GetMaxHealth()) -- 回满生命值
                parent:SetMana(parent:GetMaxMana())     -- 回满法力值
            end
        end
    end
end
