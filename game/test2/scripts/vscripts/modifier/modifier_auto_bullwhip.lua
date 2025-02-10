modifier_auto_bullwhip = class({})

function modifier_auto_bullwhip:IsHidden()
    return true
end

function modifier_auto_bullwhip:OnCreated()
    if not IsServer() then return end
    
    self:StartIntervalThink(5.0)
end

function modifier_auto_bullwhip:OnIntervalThink()
    if not IsServer() then return end
    
    local parent = self:GetParent()
    if not parent or parent:IsNull() then 
        print("未找到parent或parent无效")
        return 
    end
    
    -- 检查单位是否死亡或隐身
    if not parent:IsAlive() or parent:IsInvisible() then
        print("单位已死亡或处于隐身状态，停止检查")
        return
    end
    
    -- 检查是否有鞭子
    local bullwhip = nil
    for i = 16, 0, -1 do
        local item = parent:GetItemInSlot(i)
        if item and item:GetName() == "item_bullwhip" then
            bullwhip = item
            print("找到鞭子在槽位:", i)
            break
        end
    end
    
    if not bullwhip then 
        print("未找到鞭子")
        return 
    end

    local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
    DOTA_UNIT_TARGET_FLAG_INVULNERABLE + 
    DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD +
    DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS

    print("开始搜索范围内单位，搜索者队伍:", parent:GetTeamNumber())
    
    local enemies = FindUnitsInRadius(
        parent:GetTeamNumber(),
        parent:GetAbsOrigin(),
        nil,
        2000,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_ALL,
        flags,
        FIND_ANY_ORDER,
        false
    )
    
    print("找到的单位数量:", #enemies)
    
    for _, enemy in pairs(enemies) do
        -- 检查目标单位是否存活且不在隐身状态
        if enemy and not enemy:IsNull() and enemy:IsAlive() and not enemy:IsInvisible() then
            print("检查单位:", enemy:GetUnitName())
            if enemy:GetUnitName() == "npc_dota_hero_centaur" then
                print("找到半人马，准备施放鞭子")
                parent:SetCursorCastTarget(enemy)
                bullwhip:OnSpellStart()
                print("鞋子释放完毕")
                break
            end
        end
    end
end