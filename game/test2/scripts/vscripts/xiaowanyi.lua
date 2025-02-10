xiaowanyi = {}

function xiaowanyi:OnThink()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        -- 获取所有 lich 以及 icespire 单位
        local liches = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, 
            DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        local icespires = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, 
            DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        
        for _, lich in pairs(liches) do
            if lich:GetUnitName() == "npc_dota_hero_lich" then
                for _, icespire in pairs(icespires) do
                    if icespire:GetUnitName() == "npc_dota_lich_ice_spire" then
                        if lich:IsAlive() then
                            -- 设置 icespire 的位置为 lich 的位置
                            icespire:SetAbsOrigin(lich:GetAbsOrigin())
                            -- 检查是否已经具有相位移动修饰符，如果没有则添加
                            if not icespire:HasModifier("modifier_phased") then
                                icespire:AddNewModifier(icespire, nil, "modifier_phased", {})
                            end
                        else
                            -- 如果 lich 死亡，移除 icespire
                            icespire:RemoveSelf()
                        end
                    end
                end
            end
        end
    elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    return 0.03  -- 每帧更新一次位置
end




function xiaowanyi:SetHeroModel(hero, modelIndex)
    local modelPaths = {
        [1] = "models/heroes/juggernaut/jugg_healing_ward.vmdl",
        [2] = "models/heroes/lich/ice_spire.vmdl",
        [3] = "models/heroes/witchdoctor/witchdoctor_ward.vmdl",
        [4] = "models/heroes/shadowshaman/shadowshaman_totem.vmdl",
        [5] = "models/heroes/venomancer/venomancer_ward.vmdl",
        [6] = "models/heroes/pugna/pugna_ward.vmdl"
    }

    local particlePaths = {
        [1] = "particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf",
        [2] = "particles/units/heroes/hero_lich/lich_ice_spire.vpcf",
        [3] = "particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull.vpcf",
        --[4] = "particles/units/heroes/hero_shadowshaman/shadow_shaman_ward_base_attack_launch_b.vpcf",
        --[5] = "particles/units/heroes/hero_venomancer/venomancer_ward.vpcf",
        [6] = "particles/units/heroes/hero_pugna/pugna_ward_ambient.vpcf"
    }

    local selectedModel = modelPaths[modelIndex]
    local selectedParticle = particlePaths[modelIndex]

    if selectedModel then
        hero:SetModel(selectedModel)
        hero:SetOriginalModel(selectedModel)

        -- 如果是第4个模型，将其放大3倍
        if modelIndex == 4 then
            hero:SetModelScale(3.5)
        elseif modelIndex == 5 then
            hero:SetModelScale(2)
        else
            hero:SetModelScale(1.0)  -- 恢复默认缩放比例
        end

        -- 移除所有的饰品
        local children = hero:GetChildren()
        for _, child in ipairs(children) do
            if child:GetClassname() == "dota_item_wearable" then
                child:RemoveSelf()
            end
        end
        -- 通知模型更改
        hero:NotifyWearablesOfModelChange(true)

        -- 添加粒子效果
        if selectedParticle then
            local particle = ParticleManager:CreateParticle(selectedParticle, PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    else
        print("Invalid model index provided.")
    end
end


function xiaowanyi:CreateAndSetupHero(heroName, position, playerID, modelIndex,teamID)
    local hero = CreateUnitByName(heroName, position, true, nil, nil, teamID or DOTA_TEAM_GOODGUYS )

    hero:SetForwardVector(Vector(-1,0, 0))
    --hero:SetControllableByPlayer(playerID, true)
    hero:AddItemByName("item_ultimate_scepter_2")
    hero:AddItemByName("item_aghanims_shard")
    HeroMaxLevel(hero)

    if modelIndex == 5 then
        hero:AddNewModifier(hero, nil, "modifier_judu", {})
    end
    if modelIndex == 1 then
        hero:AddNewModifier(hero, nil, "modifier_naibangren", {})
    end
    if modelIndex == 4 then
       hero:AddNewModifier(hero, nil, "modifier_shadow_shaman_serpent_ward", {})
        
    end

    -- Timers:CreateTimer(1, function()
    --     xiaowanyi:SetHeroModel(hero, modelIndex)
    --     --hero:SetControllableByPlayer(playerID, true)
    --     hero:AddNewModifier(hero, nil, "modifier_shebangren", {})
        
    --     hero:CalculateStatBonus(true)
    --     hero:AddItemByName("item_vitality_booster")
        
    --     --hero:Heal(hero:GetMaxHealth(), nil)  -- 回复英雄的血量

    -- end)
    return hero
end
return xiaowanyi
