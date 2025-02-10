_G.totalKills = _G.totalKills or 0

modifier_illusion_death_listener = class({})

function modifier_illusion_death_listener:IsHidden()
    return true
end

function modifier_illusion_death_listener:IsPurgable()
    return false
end

function modifier_illusion_death_listener:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH
    }
end

function modifier_illusion_death_listener:OnDeath(params)
    if not _G.endduel then 
        if params.unit == self:GetParent() then
            local unit = params.unit
            local position = unit:GetAbsOrigin()
            local team = unit:GetTeamNumber()

            -- 查找玩家0的英雄
            local playerHero = PlayerResource:GetSelectedHeroEntity(0)
            if playerHero then
                -- 重新生成玩家0的英雄的幻象
                local newIllusions = CreateIllusions(unit, playerHero, {
                    duration = 999.0,
                    outgoing_damage = 100,
                    incoming_damage = 100,
                    team = team
                }, 1, 64, true, true)

                if #newIllusions > 0 then
                    local newIllusion = newIllusions[1]
                    Main.illusion = newIllusion
                    newIllusion:SetTeam(team)
                    newIllusion:SetOwner(nil)
                    newIllusion:SetControllableByPlayer(-1, false)
                    newIllusion:AddNewModifier(newIllusion, nil, "modifier_illusion_death_listener", {})  -- 添加监听幻象死亡的修饰符

                else
                    print("Failed to create illusions.")
                end
            end


            -- 增加全局计数器
            _G.totalKills = _G.totalKills + 1

            -- 发送分数更新事件
            local data = {
                ["击杀数量"] = _G.totalKills
            }
            CustomGameEventManager:Send_ServerToAllClients("update_score", data)

        end
    end
end
