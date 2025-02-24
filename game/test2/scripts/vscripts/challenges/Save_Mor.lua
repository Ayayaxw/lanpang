function Main:Cleanup_Save_Mor()

end

function Main:Init_Save_Mor(heroName, heroFacet,playerID, heroChineseName)

    self.currentMatchID = self:GenerateUniqueID()    --比赛ID
    SendToServerConsole("host_timescale 1")          --游戏速度
    self.currentTimer = (self.currentTimer or 0) + 1 --计时器
    local timerId = self.currentTimer
    PlayerResource:SetGold(playerID, 0, false)

    --赛前准备时间
    self.duration = 10
    --赛后庆祝时间
    self.endduration = 10
    -- 限定时间为准备时间结束后的一分钟
    self.limitTime = 60 
    hero_duel.EndDuel = false  

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[新挑战]"
    )

    self:createLocalizedMessage(
        "[LanPang_RECORD][",
        self.currentMatchID,
        "]",
        "[选择绿方]",
        {localize = true, text = heroName},
        ",",
        {localize = true, text = "facet", facetInfo = self:getFacetTooltip(heroName, heroFacet)}
    )
    
    CreateHero(0, heroName, heroFacet, Main.Save_Mor, DOTA_TEAM_GOODGUYS, false, function(playerHero)

        playerHero:AddItemByName("item_ultimate_scepter_2")
        playerHero:AddItemByName("item_aghanims_shard")
        playerHero:AddNewModifier(playerHero, nil, "modifier_kv_editor", {})
        playerHero:AddNewModifier(playerHero, nil, "modifier_rooted", { duration = 5 })
        HeroMaxLevel(playerHero)
        self.leftTeamHero1 = playerHero
        local player = PlayerResource:GetPlayer(0)
        playerHero:SetControllableByPlayer(0, true)
        player:SetAssignedHeroEntity(playerHero)
        Main.currentArenaHeroes[1] = playerHero

    end)



    self:SendCameraPositionToJS(Main.Save_Mor, 1)








    local function CreateHero(heroName, position, level, team)
        local hero = CreateUnitByName(heroName, position, true, nil, nil, team)
        for i = 1, level - 1 do
            hero:HeroLevelUp(false)
        end
        return hero
    end
    
    -- 给英雄添加物品的函数
    local function AddItemsToHero(hero, itemNames)
        for _, itemName in ipairs(itemNames) do
            local item = CreateItem(itemName, hero, hero)
            hero:AddItem(item)
        end
    end
    
    local function MaxOutAbilities(hero)
        print("升级 " .. hero:GetUnitName() .. " 的技能:")
        for i = 0, hero:GetAbilityCount() - 1 do
            local ability = hero:GetAbilityByIndex(i)
            if ability then
                local abilityName = ability:GetAbilityName()
                if abilityName == "special_bonus_attributes" then
                    -- 只将附加属性升到5级
                    while ability:GetLevel() < 5 do
                        ability:UpgradeAbility(true)
                        print("  升级附加属性到 " .. ability:GetLevel() .. " 级")
                    end
                else
                    -- 其他技能升到最高级
                    if ability:CanAbilityBeUpgraded() then
                        print("  正在升级: " .. abilityName)
                        while ability:CanAbilityBeUpgraded() and ability:GetLevel() < ability:GetMaxLevel() do
                            ability:UpgradeAbility(true)
                        end
                        print("    最终等级: " .. ability:GetLevel())
                    end
                end
            end
        end
        print("技能升级完成")
    end
    
    -- 创建敌方英雄
    local enemy_team = DOTA_TEAM_BADGUYS
    local heroes = {
        CreateHero("npc_dota_hero_invoker", Vector(3250.09, 5341.96, 256.00), 22, enemy_team),
        CreateHero("npc_dota_hero_phantom_lancer", Vector(3357.52, 5357.55, 256.00), 23, enemy_team),
        CreateHero("npc_dota_hero_wisp", Vector(3397.35, 5629.69, 256.00), 21, enemy_team),
        CreateHero("npc_dota_hero_chen", Vector(4458.18, 5467.81, 256.00), 14, enemy_team),
        CreateHero("npc_dota_hero_axe", Vector(5181.61, 5703.44, 256.00), 22, enemy_team)
    }
    
    -- 创建友方英雄
    local friendly_team = DOTA_TEAM_GOODGUYS
    local morphling = CreateHero("npc_dota_hero_morphling", Vector(2600.87, 5473.30, 128.00), 23, friendly_team)
    table.insert(heroes, morphling)
    
    -- 给所有单位添加disarm modifier
    for _, hero in ipairs(heroes) do
        hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = -1})
    end
    
    -- 给英雄添加装备
    AddItemsToHero(heroes[2], {"item_power_treads", "item_diffusal_blade", "item_manta", "item_eagle", "item_dragon_lance"}) -- 幻影长矛手
    AddItemsToHero(morphling, {"item_diffusal_blade", "item_manta", "item_power_treads", "item_ring_of_aquila", "item_skadi", "item_lifesteal"}) -- 变体精灵
    AddItemsToHero(heroes[5], {"item_blink", "item_invis_sword", "item_ogre_axe", "item_blade_mail", "item_vanguard", "item_phase_boots"}) -- 斧王
    AddItemsToHero(heroes[4], {"item_vladmir", "item_tranquil_boots", "item_magic_wand", "item_medallion_of_courage"}) -- 陈
    AddItemsToHero(heroes[1], {"item_eagle", "item_sphere", "item_blink", "item_ultimate_scepter", "item_travel_boots", "item_hand_of_midas"}) -- 卡尔
    AddItemsToHero(heroes[3], {"item_mekansm", "item_vitality_booster", "item_urn_of_shadows", "item_bottle", "item_soul_ring", "item_magic_stick"}) -- 小精灵
    
    -- 让水人学习所有技能到最高等级
    MaxOutAbilities(morphling)
    
    -- 搜索并摧毁防御塔的函数
    local function FindAndDestroyTowers(position, radius)
        local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                                        position,
                                        nil,
                                        radius,
                                        DOTA_UNIT_TARGET_TEAM_BOTH,
                                        DOTA_UNIT_TARGET_BUILDING,
                                        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                                        FIND_ANY_ORDER,
                                        false)
        
        for _, unit in pairs(units) do
            if unit:GetClassname() == "npc_dota_tower" then
                unit:RemoveModifierByName("modifier_invulnerable")
                unit:ForceKill(false)
                print("摧毁了位于 " .. tostring(unit:GetAbsOrigin()) .. " 的防御塔")
            end
        end
    end
    
    -- 搜索并摧毁指定位置附近的防御塔
    FindAndDestroyTowers(Vector(-4655.20, 6010.10, 128.00), 300)
    FindAndDestroyTowers(Vector(-119.53, 6001.71, 128.00), 300)
    FindAndDestroyTowers(Vector(3547.77, 5770.11, 256.00), 300)
    


end


