hero_duel = {}

-- 清除并生成小兵的函数
function hero_duel:spawn_creatures(self, initialCreepCount, creepName, team)
    -- 初始化击杀计数器
    self.killedCount = 0
    self.creepCount = initialCreepCount

    -- 查找所有单位
    local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE,
                                    DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    
    -- 删除特定的小兵
    for _, unit in pairs(units) do
        if unit:GetUnitName() == creepName then
            unit:RemoveSelf()
        end
    end

    -- 在 (0, 0, 0) 位置生成指定数量的小兵
    for i = 1, initialCreepCount do
        local spawnPos = Vector(100, -500, 0)
        CreateUnitByName(creepName, spawnPos, true, nil, nil, team)
    end
end

function hero_duel:UpdateShadowShamanHealth(newHero,healthPercentage,duration)
    -- 减少暗影萨满的血量统计，考虑实际受到的伤害量
    if healthPercentage ~= 0 then

        -- 发送当前生命值的百分比到所有客户端
        CustomGameEventManager:Send_ServerToAllClients("update_shadow_shaman_health", {health = healthPercentage})
        
    else 
        self.EndDuel = true  -- 设置标志，表示小兵已全部击杀
        CustomGameEventManager:Send_ServerToAllClients("update_shadow_shaman_health", {health = 0})
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})

        -- 播放某种胜利效果或动画
        -- 对英雄再次施加缠绕、缴械、禁锢和破坏效果
        newHero:AddNewModifier(newHero, nil, "modifier_disarmed", { duration = 10 })
        --newHero:AddNewModifier(newHero, nil, "modifier_silence", { duration = duration })
        newHero:AddNewModifier(newHero, nil, "modifier_rooted", { duration = 10 })
        newHero:AddNewModifier(newHero, nil, "modifier_break", { duration = 10 })
        newHero:AddNewModifier(newHero, nil, "modifier_invulnerable", { duration = 10 })
        newHero:StartGesture(ACT_DOTA_VICTORY)

                    -- 发送一个事件到所有客户端，通知它们调整相机距离
                    -- 锁定摄像机到玩家身上
        local playerID = newHero:GetPlayerOwnerID()
        if playerID then
            PlayerResource:SetCameraTarget(playerID, newHero)
            
            -- 在几秒后释放摄像机
            Timers:CreateTimer(2, function()
                PlayerResource:SetCameraTarget(playerID, nil)
            end)
        end

        -- 在英雄头上播放决斗胜利的动画和音效
        local particle = ParticleManager:CreateParticle("particles/econ/items/legion/legion_weapon_voth_domosh/legion_commander_duel_arcana.vpcf", PATTACH_OVERHEAD_FOLLOW, newHero)
        ParticleManager:SetParticleControl(particle, 0, newHero:GetAbsOrigin())

        ParticleManager:ReleaseParticleIndex(particle)

        -- 播放音效
        EmitSoundOn("Hero_LegionCommander.Duel.Victory", newHero)
    end
end

