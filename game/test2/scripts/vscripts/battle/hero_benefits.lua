function Main:HeroBenefits(heroName, hero, overallStrategy, heroStrategy)

    -- 检查是否为米波，如果是，为克隆体也创建AI
    if heroName == "npc_dota_hero_meepo" then
        if not AIs[hero] then
            print("主要米波英雄还没有AI,跳过克隆体AI创建")
            return
        end
        Timers:CreateTimer(0.1, function()
            local meepos = FindUnitsInRadius(
                hero:GetTeamNumber(),
                hero:GetAbsOrigin(),
                nil,
                FIND_UNITS_EVERYWHERE,
                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED,
                FIND_ANY_ORDER,
                false
            )
            for _, meepo in pairs(meepos) do
                if meepo:IsClone() and
                not AIs[meepo] then
                    print("创建克隆体AI")
                    -- 创建AI
                    CreateAIForHero(meepo, overallStrategy, heroStrategy, "meepo_clone")
                    
                    -- 同步朝向
                    meepo:SetForwardVector(hero:GetForwardVector())
                    
                    -- 同步控制状态
                    local controlModifiers = {

                        "modifier_rooted",
                        "modifier_silenced",

                    }
                    
                    for _, modName in pairs(controlModifiers) do
                        local mod = hero:FindModifierByName(modName)
                        if mod then
                            local duration = mod:GetRemainingTime()
                            if duration > 0 then
                                meepo:AddNewModifier(
                                    mod:GetCaster(), -- 原始施法者
                                    mod:GetAbility(), -- 原始技能
                                    modName,
                                    {duration = duration}
                                )
                            end
                        end
                    end
                else
                    print("没有找到克隆体，单位名：" .. meepo:GetUnitName())
                end
            end
        end)
    end

    if heroName == "npc_dota_hero_primal_beast" then
        local ability = hero:FindAbilityByName("primal_beast_uproar")
        if ability and ability:GetLevel() > 0 then
            local modifier = hero:AddNewModifier(hero, ability, "modifier_primal_beast_uproar", {duration = 20})
            if modifier then
                modifier:SetStackCount(5)
            end
        end
    end




    if heroName == "npc_dota_hero_tiny" or 
        heroName == "npc_dota_hero_furion" or 
        heroName == "npc_dota_hero_treant" or 
        heroName == "npc_dota_hero_muerta" or 
        heroName == "npc_dota_hero_hoodwink" or 
        heroName == "npc_dota_hero_shredder" or
        heroName == "npc_dota_hero_monkey_king" or
        heroName == "npc_dota_hero_windrunner"  then
        
        print("正在生成树木环绕阵型")
        
        -- 检查1000码范围内的树木数量
        local nearbyTrees = GridNav:GetAllTreesAroundPoint(hero:GetAbsOrigin(), 1000, true)
        if #nearbyTrees >= 20 then
            print("周围已有" .. #nearbyTrees .. "颗树木，不再生成新的树木")
            return
        end
        
        -- 获取英雄朝向角度（弧度）
        local heroForwardVector = hero:GetForwardVector()
        local heroAngle = math.atan2(heroForwardVector.y, heroForwardVector.x)
        
        -- 定义前方禁止区域（以英雄朝向为中心，往两边各60度）
        local forbiddenAngleStart = heroAngle - math.rad(30)
        local forbiddenAngleEnd = heroAngle + math.rad(30)
        
        -- 检查角度是否在禁止区域内
        local function isAngleAllowed(angle)
            -- 将angle标准化到 [-π, π]
            while angle > math.pi do angle = angle - 2 * math.pi end
            while angle < -math.pi do angle = angle + 2 * math.pi end
            
            -- 同样标准化forbiddenAngle
            local fStart = forbiddenAngleStart
            while fStart > math.pi do fStart = fStart - 2 * math.pi end
            while fStart < -math.pi do fStart = fStart + 2 * math.pi end
            
            local fEnd = forbiddenAngleEnd
            while fEnd > math.pi do fEnd = fEnd - 2 * math.pi end
            while fEnd < -math.pi do fEnd = fEnd + 2 * math.pi end
            
            -- 检查是否在禁止区域
            if fStart <= fEnd then
                return angle < fStart or angle > fEnd
            else
                return angle < fStart and angle > fEnd
            end
        end
        
        -- 内圈树木（5棵，300码半径）
        for i = 1, 5 do
            local angle = i * (360 / 5)
            local rad = math.rad(angle)
            
            -- 只在允许的角度生成树木
            if isAngleAllowed(rad) then
                local x = hero:GetAbsOrigin().x + 300 * math.cos(rad)
                local y = hero:GetAbsOrigin().y + 300 * math.sin(rad)
                local position = Vector(x, y, hero:GetAbsOrigin().z)
                
                -- 检查50码范围内是否有单位或树木
                local units = FindUnitsInRadius(hero:GetTeamNumber(),
                    position,
                    nil,
                    80,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
                    
                local trees = GridNav:GetAllTreesAroundPoint(position, 80, true)
                
                if #units == 0 and #trees == 0 then
                    if self.limitTime then
                        CreateTempTree(position, self.limitTime)
                    else
                        CreateTempTree(position, 30)
                    end
                end
            end
        end

        -- 外圈树木（10棵，600码半径）
        for i = 1, 10 do
            local angle = i * (360 / 10)
            local rad = math.rad(angle)
            
            -- 只在允许的角度生成树木
            if isAngleAllowed(rad) then
                local x = hero:GetAbsOrigin().x + 600 * math.cos(rad)
                local y = hero:GetAbsOrigin().y + 600 * math.sin(rad)
                local position = Vector(x, y, hero:GetAbsOrigin().z)
                
                -- 检查50码范围内是否有单位或树木
                local units = FindUnitsInRadius(hero:GetTeamNumber(),
                    position,
                    nil,
                    80,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
                    
                local trees = GridNav:GetAllTreesAroundPoint(position, 80, true)
                
                if #units == 0 and #trees == 0 then
                    CreateTempTree(position, 30)
                end
            end
        end
    end



    if heroName == "npc_dota_hero_wisp" then
        print("【小精灵连接】开始处理小精灵连接逻辑")
        
        -- 搜索全图所有小精灵，使用英雄所在的队伍
        local wisps = FindUnitsInRadius(
            hero:GetTeamNumber(),  -- 改为使用英雄的队伍编号
            Vector(0,0,0),
            nil,
            FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        -- 过滤出所有小精灵并按实体索引排序
        local sortedWisps = {}
        for _, w in pairs(wisps) do
            -- if w:GetUnitName() == "npc_dota_hero_wisp" then
            --     print(string.format("【小精灵连接】发现小精灵，实体索引: %d，所属队伍: %d", 
            --         w:GetEntityIndex(), w:GetTeamNumber()))
                table.insert(sortedWisps, w)
            -- end
        end
        table.sort(sortedWisps, function(a,b) return a:GetEntityIndex() < b:GetEntityIndex() end)

        print(string.format("【小精灵连接】找到 %d 个小精灵", #sortedWisps))
        for i, wisp in ipairs(sortedWisps) do
            print(string.format("【小精灵连接】第 %d 个小精灵，实体索引: %d", i, wisp:GetEntityIndex()))
        end

        -- 如果只有一个小精灵，创建肉山并连接
        if #sortedWisps == 1 then
            print("【小精灵连接】只有一个小精灵，准备创建并连接肉山")
            local roshan = CreateUnitByName("npc_dota_roshan", 
                hero:GetAbsOrigin() + RandomVector(200), 
                true, nil, nil, hero:GetTeamNumber())
            if roshan then
                roshan:SetOwner(hero)
                roshan:SetControllableByPlayer(hero:GetPlayerID(), true)
                hero:SetCursorCastTarget(roshan)
                print(string.format("【小精灵连接】小精灵(实体索引:%d)准备连接到肉山(实体索引:%d)", 
                    hero:GetEntityIndex(), roshan:GetEntityIndex()))
                hero:FindAbilityByName("wisp_tether"):OnSpellStart()
                print("【小精灵连接】连接肉山完成")
            else
                print("【小精灵连接】肉山创建失败")
            end
            return
        end

        -- 创建环形连接
        if #sortedWisps > 1 then
            print("【小精灵连接】开始创建环形连接")
            for i = 1, #sortedWisps do
                local current = sortedWisps[i]
                local nextWisp = sortedWisps[i % #sortedWisps + 1]
                
                -- 确保不会自己连接自己
                if current ~= nextWisp then
                    print(string.format("【小精灵连接】第 %d 个小精灵(实体索引:%d)准备连接到第 %d 个小精灵(实体索引:%d)", 
                        i, 
                        current:GetEntityIndex(),
                        (i % #sortedWisps + 1),
                        nextWisp:GetEntityIndex()))
                    
                    current:SetCursorCastTarget(nextWisp)
                    current:FindAbilityByName("wisp_tether"):OnSpellStart()
                    
                    print(string.format("【小精灵连接】第 %d 个小精灵连接完成", i))
                else
                    print(string.format("【小精灵连接】警告：第 %d 个小精灵试图连接自己，已跳过", i))
                end
            end
            print("【小精灵连接】环形连接创建完成")
        end
    end

    if heroName == "npc_dota_hero_doom_bringer" then
        
        local ability = hero:FindAbilityByName("doom_bringer_devour")
        if ability == nil or ability:GetLevel() < 1 then return end
    
        local function createUnitAndCastSpell(unitName)
            local unit = CreateUnitByName(unitName, hero:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)), true, nil, nil, DOTA_TEAM_NEUTRALS)
            if unit and ability then
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                hero:SetCursorCastTarget(unit)
                ability:OnSpellStart()
            
                local caster = hero
                local target = unit
                
                -- 获取末日英雄的技能3和技能4（索引为2和3）
                local ability3 = caster:GetAbilityByIndex(2)
                local ability4 = caster:GetAbilityByIndex(3)
            
                -- 获取目标的前两个技能
                local targetAbility1 = target:GetAbilityByIndex(0)
                local targetAbility2 = target:GetAbilityByIndex(1)
                
                -- 获取吞噬技能的等级
                local devourAbility = caster:FindAbilityByName("doom_bringer_devour")
                local skillLevel = devourAbility and devourAbility:GetLevel() or 1

                -- 复制第一个技能（如果不是creep_piercing）
                if targetAbility1 then
                    local ability1Name = targetAbility1:GetAbilityName()
                    if ability1Name ~= "creep_piercing" and ability1Name ~= "neutral_upgrade" then
                        caster:RemoveAbility("doom_bringer_empty1")
                        local newAbility1 = caster:AddAbility(ability1Name)
                        if newAbility1 then
                            newAbility1:SetLevel(skillLevel)
                        end
                    end
                    -- 如果是creep_piercing，不做任何操作，保持技能槽为空
                end
                
                -- 复制第二个技能（如果不是creep_piercing）
                if targetAbility2 then
                    local ability2Name = targetAbility2:GetAbilityName()
                    if ability2Name ~= "creep_piercing" and ability2Name ~= "neutral_upgrade" then
                        caster:RemoveAbility("doom_bringer_empty2")
                        local newAbility2 = caster:AddAbility(ability2Name)
                        if newAbility2 then
                            newAbility2:SetLevel(skillLevel)
                        end
                    end
                    -- 如果是creep_piercing，不做任何操作，保持技能槽为空
                end
            end
        end
    
        if CommonAI:containsStrategy(heroStrategy, "给予枭兽") then
            createUnitAndCastSpell("npc_dota_neutral_wildkin")
        elseif CommonAI:containsStrategy(heroStrategy, "给予枭兽撕裂者") then
            createUnitAndCastSpell("npc_dota_neutral_enraged_wildkin")
        elseif CommonAI:containsStrategy(heroStrategy, "给予半人马猎手") then
            createUnitAndCastSpell("npc_dota_neutral_centaur_outrunner")
        elseif CommonAI:containsStrategy(heroStrategy, "给予半人马撕裂者") then
            createUnitAndCastSpell("npc_dota_neutral_centaur_khan")
        elseif CommonAI:containsStrategy(heroStrategy, "给予食人魔拳手") then
            createUnitAndCastSpell("npc_dota_neutral_ogre_mauler")
        elseif CommonAI:containsStrategy(heroStrategy, "给予食人魔冰霜法师") then
            createUnitAndCastSpell("npc_dota_neutral_ogre_magi")
        elseif CommonAI:containsStrategy(heroStrategy, "给予萨特放逐者") then
            createUnitAndCastSpell("npc_dota_neutral_satyr_trickster")
        elseif CommonAI:containsStrategy(heroStrategy, "给予萨特窃神者") then
            createUnitAndCastSpell("npc_dota_neutral_satyr_soulstealer")
        elseif CommonAI:containsStrategy(heroStrategy, "给予萨特苦难使者") then
            createUnitAndCastSpell("npc_dota_neutral_satyr_hellcaller")
        elseif CommonAI:containsStrategy(heroStrategy, "给予丘陵巨魔") then
            createUnitAndCastSpell("npc_dota_neutral_dark_troll")
        elseif CommonAI:containsStrategy(heroStrategy, "给予丘陵巨魔狂战士") then
            createUnitAndCastSpell("npc_dota_neutral_forest_troll_berserker")
        elseif CommonAI:containsStrategy(heroStrategy, "给予丘陵巨魔牧师") then
            createUnitAndCastSpell("npc_dota_neutral_forest_troll_high_priest")
        elseif CommonAI:containsStrategy(heroStrategy, "给予黑暗巨魔召唤法师") then
            createUnitAndCastSpell("npc_dota_neutral_dark_troll_warlord")
        elseif CommonAI:containsStrategy(heroStrategy, "给予地狱熊怪") then
            createUnitAndCastSpell("npc_dota_neutral_polar_furbolg_champion")
        elseif CommonAI:containsStrategy(heroStrategy, "给予地狱熊怪粉碎者") then
            createUnitAndCastSpell("npc_dota_neutral_polar_furbolg_ursa_warrior")
        elseif CommonAI:containsStrategy(heroStrategy, "给予巨狼") then
            createUnitAndCastSpell("npc_dota_neutral_giant_wolf")
        elseif CommonAI:containsStrategy(heroStrategy, "给予头狼") then
            createUnitAndCastSpell("npc_dota_neutral_alpha_wolf")
        elseif CommonAI:containsStrategy(heroStrategy, "给予鹰身女妖侦察者") then
            createUnitAndCastSpell("npc_dota_neutral_harpy_scout")
        elseif CommonAI:containsStrategy(heroStrategy, "给予鹰身女妖风暴巫师") then
            createUnitAndCastSpell("npc_dota_neutral_harpy_storm")
        elseif CommonAI:containsStrategy(heroStrategy, "给予狗头人") then
            createUnitAndCastSpell("npc_dota_neutral_kobold")
        elseif CommonAI:containsStrategy(heroStrategy, "给予狗头人士兵") then
            createUnitAndCastSpell("npc_dota_neutral_kobold_tunneler")
        elseif CommonAI:containsStrategy(heroStrategy, "给予狗头人长官") then
            createUnitAndCastSpell("npc_dota_neutral_kobold_taskmaster")
        elseif CommonAI:containsStrategy(heroStrategy, "给予泥土傀儡") then
            createUnitAndCastSpell("npc_dota_neutral_mud_golem")
        elseif CommonAI:containsStrategy(heroStrategy, "给予魔能之魂") then
            createUnitAndCastSpell("npc_dota_neutral_fel_beast")
        elseif CommonAI:containsStrategy(heroStrategy, "给予鬼魂") then
            createUnitAndCastSpell("npc_dota_neutral_ghost")
        elseif CommonAI:containsStrategy(heroStrategy, "给予豺狼人刺客") then
            createUnitAndCastSpell("npc_dota_neutral_gnoll_assassin")
        elseif CommonAI:containsStrategy(heroStrategy, "给予斗松掠夺者") then
            createUnitAndCastSpell("npc_dota_neutral_warpine_raider")
        -- 远古野怪
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古黑蜉蝣") then
            createUnitAndCastSpell("npc_dota_neutral_black_drake")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古黑龙") then
            createUnitAndCastSpell("npc_dota_neutral_black_dragon")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古花岗岩傀儡") then
            createUnitAndCastSpell("npc_dota_neutral_granite_golem")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古岩石傀儡") then
            createUnitAndCastSpell("npc_dota_neutral_rock_golem")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古寒冰萨满") then
            createUnitAndCastSpell("npc_dota_neutral_ice_shaman")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古霜害傀儡") then
            createUnitAndCastSpell("npc_dota_neutral_frostbitten_golem")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古潜行者长老") then
            createUnitAndCastSpell("npc_dota_neutral_elder_jungle_stalker")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古潜行者") then
            createUnitAndCastSpell("npc_dota_neutral_jungle_stalker")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古侍僧潜行者") then
            createUnitAndCastSpell("npc_dota_neutral_prowler_acolyte")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古萨满潜行者") then
            createUnitAndCastSpell("npc_dota_neutral_prowler_shaman")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古岚肤兽") then
            createUnitAndCastSpell("npc_dota_neutral_small_thunder_lizard")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古雷肤兽") then
            createUnitAndCastSpell("npc_dota_neutral_big_thunder_lizard")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古青蛙战士") then
            createUnitAndCastSpell("npc_dota_neutral_ancient_frog")
        else
            createUnitAndCastSpell("npc_dota_neutral_centaur_khan")
        end
    end
    if heroName == "npc_dota_hero_nevermore" then
        local necromasteryAbility = hero:FindAbilityByName("nevermore_necromastery")
        if necromasteryAbility and necromasteryAbility:GetLevel() > 0 then
            local maxSouls = 20
            -- 检查是否有阿哈利姆神杖效果
            if hero:HasScepter() then
                maxSouls = 25
            end
            hero:SetModifierStackCount("modifier_nevermore_necromastery", hero, maxSouls)
        else
            print("错误：未能找到影魔的灵魂积累技能或技能未升级！")
        end
    end

    if heroName == "npc_dota_hero_skeleton_king" then
        local necromasteryAbility = hero:FindAbilityByName("skeleton_king_bone_guard")
        if necromasteryAbility and necromasteryAbility:GetLevel() > 0 then
            local abilityLevel = necromasteryAbility:GetLevel()
            local maxSouls = 2 + (math.max(abilityLevel - 1, 0) * 2)
            
            hero:SetModifierStackCount("modifier_skeleton_king_bone_guard", hero, maxSouls)
            print("找到骷髅王技能了, 当前技能等级" .. abilityLevel .. "层数" .. maxSouls)
        else
            print("错误：未能找到骷髅王白骨护卫或技能未升级！")
        end
    end

    if heroName == "npc_dota_hero_chen" then
        local ability = hero:FindAbilityByName("chen_holy_persuasion")
        if ability then
            print("找到了神圣劝化技能")
            
            -- 定义两种单位列表
            local basic_neutrals = {
                "npc_dota_neutral_centaur_khan",
                "npc_dota_neutral_alpha_wolf",
                "npc_dota_neutral_dark_troll_warlord"
            }
            
            local shard_neutrals = {
                "npc_dota_neutral_big_thunder_lizard",
                "npc_dota_neutral_granite_golem",
                "npc_dota_neutral_black_dragon"
            }
    
            -- 获取技能等级和神杖状态
            local persuasion_level = ability:GetLevel()
            local hand_of_god = hero:FindAbilityByName("chen_hand_of_god")
            local hand_of_god_level = hand_of_god and hand_of_god:GetLevel() or 0
            local has_shard = hero:HasModifier("modifier_item_aghanims_shard")
            
            -- 确定要创建的单位列表
            local units_to_create = {}
            if has_shard then
                -- 根据手of god等级替换单位
                for i = 1, math.min(persuasion_level, 3) do
                    if i <= hand_of_god_level then
                        units_to_create[i] = shard_neutrals[i]
                    else
                        units_to_create[i] = basic_neutrals[i]
                    end
                end
            else
                -- 没有神杖，根据劝化等级决定创建基础单位
                for i = 1, math.min(persuasion_level, 3) do
                    units_to_create[i] = basic_neutrals[i]
                end
            end
    
            -- 创建单位
            for _, unitName in ipairs(units_to_create) do
                local unit = CreateUnitByName(unitName, 
                    hero:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)), 
                    true, nil, nil, DOTA_TEAM_BADGUYS)
                if unit then
                    unit:SetOwner(hero)
                    unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                    -- 直接释放技能
                    hero:SetCursorCastTarget(unit)
                    ability:OnSpellStart()
                end
            end
    
            -- 如果劝化等级为4，执行转换
            if persuasion_level == 4 then
                local convertAbility = hero:FindAbilityByName("chen_summon_convert")
                if convertAbility then
                    convertAbility:OnSpellStart()
                end
            end
    
        else
            print("错误：未能找到陈的神圣劝化技能")
        end
    end

    if heroName == "npc_dota_hero_enchantress" then
        print("创建了")
        local ability = hero:FindAbilityByName("enchantress_enchant")
    
        local function createUnitAndCastSpell(unitName)
            local unit = CreateUnitByName(unitName, 
                hero:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)), 
                true, nil, nil, hero:GetTeamNumber())  -- 修改这里，使用英雄的队伍编号
            if unit and ability then
                unit:SetOwner(hero)
                unit:SetControllableByPlayer(hero:GetPlayerID(), true)
                hero:SetCursorCastTarget(unit)
                ability:OnSpellStart()
            end
        end
    
        local unitName = nil
        
        if heroStrategy then
            if CommonAI:containsStrategy(heroStrategy, "给予枭兽") then
                unitName = "npc_dota_neutral_enraged_wildkin"
            elseif CommonAI:containsStrategy(heroStrategy, "给予人马") then
                unitName = "npc_dota_neutral_centaur_khan"
            elseif CommonAI:containsStrategy(heroStrategy, "给予头狼") then
                unitName = "npc_dota_neutral_alpha_wolf"
            elseif CommonAI:containsStrategy(heroStrategy, "给予食人魔") then
                unitName = "npc_dota_neutral_ogre_magi"
            elseif CommonAI:containsStrategy(heroStrategy, "给予萨特") then
                unitName = "npc_dota_neutral_satyr_hellcaller"
            elseif CommonAI:containsStrategy(heroStrategy, "给予巨魔") then
                unitName = "npc_dota_neutral_dark_troll_warlord"
            elseif CommonAI:containsStrategy(heroStrategy, "给予熊怪") then
                unitName = "npc_dota_neutral_polar_furbolg_ursa_warrior"
            end
        end
    
        -- 如果没有选择任何单位，默认给人马
        if not unitName then
            unitName = "npc_dota_neutral_centaur_khan"
        end
    
        -- 创建两只相同的单位
        createUnitAndCastSpell(unitName)
        createUnitAndCastSpell(unitName)
    end

    if heroName == "npc_dota_hero_centaur" then
        local ability = hero:FindAbilityByName("centaur_rawhide")
        if ability then
            hero:RemoveAbility("centaur_rawhide")
            local level = hero:GetLevel()
            -- 给予等级*30的生命值加成
            local bonus_health = level * 30
            --恢复满血
            hero:SetHealth(hero:GetMaxHealth())
            hero:AddNewModifier(hero, nil, "modifier_extra_health_bonus", {bonus_health = bonus_health})
        end
    end


    if heroName == "npc_dota_hero_visage" then
        local ability = hero:FindAbilityByName("visage_summon_familiars")
        if ability then
            ability:OnSpellStart()
        end
    end

    if heroName == "npc_dota_hero_venomancer" then
        local ability = hero:FindAbilityByName("venomancer_plague_ward")
        if ability and hero:GetHeroFacetID() == 2 then
            hero:SetCursorCastTarget(hero)
            ability:OnSpellStart()
            ability:OnSpellStart()
            ability:OnSpellStart()
        end
    end

    if heroName == "npc_dota_hero_lone_druid" then
        local ability = hero:FindAbilityByName("lone_druid_spirit_bear")
        if ability then
            print("找到德鲁伊的召唤熊技能")
            ability:OnSpellStart()
            
            -- 等待一小段时间确保熊已经召唤出来
            Timers:CreateTimer(0.1, function()
                print("开始寻找熊...")
                -- 寻找300范围内的熊
                local units = FindUnitsInRadius(
                    hero:GetTeamNumber(),
                    hero:GetAbsOrigin(),
                    nil,
                    300,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                
                print("范围内找到单位数量: " .. #units)
                
                -- 遍历找到的单位
                for _, unit in pairs(units) do
                    print("检查单位: " .. unit:GetUnitName())
                    if string.match(unit:GetUnitName(), "npc_dota_lone_druid_bear") then
                        print("找到了熊!")
                        -- 先清空熊的所有装备
                        for itemSlot = 0, 16 do
                            local bearItem = unit:GetItemInSlot(itemSlot)
                            if bearItem then
                                unit:RemoveItem(bearItem)
                            end
                        end
                        
                        -- 复制英雄的装备给熊
                        for itemSlot = 0, 16 do
                            local item = hero:GetItemInSlot(itemSlot)
                            if item then
                                local itemName = item:GetName()
                                print("复制装备: " .. itemName)
                                unit:AddItemByName(itemName)
                            end
                        end
                        break -- 找到熊后就退出循环
                    end
                end
                print("搜索结束")
            end)
        else
            print("未找到德鲁伊的召唤熊技能")
        end
    end

    if heroName == "npc_dota_hero_axe" then
        -- 获取斧王等级
        local heroLevel = hero:GetLevel()
        -- 找到技能
        local ability = hero:FindAbilityByName("axe_battle_hunger")
        if ability and ability:GetLevel() > 0 then
            -- 给予相当于英雄等级的层数
            hero:SetModifierStackCount("modifier_axe_coat_of_blood", hero, heroLevel)
        else
            print("错误：未能找到斧王的战争饥渴技能或技能未升级！")
        end
    end



    if heroName == "npc_dota_hero_broodmother" then
        -- 找到技能
        local spiderlingAbility = hero:FindAbilityByName("broodmother_spawn_spiderlings")
        local webAbility = hero:FindAbilityByName("broodmother_spin_web")
        
        if webAbility and webAbility:GetLevel() > 0 then
            -- 先在脚底下释放蛛网
            hero:SetCursorPosition(hero:GetAbsOrigin())
            webAbility:OnSpellStart()
        end

        local challengeCode = self.currentChallenge
        print("challengeCode",challengeCode)

        local challengeName = self:GetChallengeIDByCode(challengeCode)
        print("challengeName",challengeName)
        if challengeName == "Intelligence_Cloak_Battle" then
        else
            if spiderlingAbility and spiderlingAbility:GetLevel() > 0 then
                -- 创建5个狗头人
                for i = 1, 3 do
                    local unit = CreateUnitByName("npc_dota_neutral_kobold", hero:GetAbsOrigin() + RandomVector(100), true, nil, nil, DOTA_TEAM_NEUTRALS)
                    if unit then
                        -- 对每个狗头人释放技能
                        hero:SetCursorCastTarget(unit)
                        spiderlingAbility:OnSpellStart()
                    end
                end
    
            end
        end

    end

    if heroName == "npc_dota_hero_necrolyte" then
        -- 获取英雄等级
        local heroLevel = hero:GetLevel()
        -- 计算应给予的层数(等级除以3)
        local stacks = math.floor(heroLevel / 3)
        -- 找到技能
        local ability = hero:FindAbilityByName("necrolyte_reapers_scythe")
        if ability and ability:GetLevel() > 0 then
            -- 获取当前技能等级
            local abilityLevel = ability:GetLevel()
            -- 根据技能等级获取每层提供的生命和魔法恢复
            local hpPerKill = {2, 4, 6}  -- 每级技能的生命恢复值
            local manaPerKill = {1, 2, 3}  -- 每级技能的魔法恢复值
            
            -- 计算总的生命和魔法恢复加成
            local totalHPRegen = hpPerKill[abilityLevel] * stacks
            local totalManaRegen = manaPerKill[abilityLevel] * stacks
            
            -- 设置英雄的生命和魔法恢复
            hero:SetBaseHealthRegen(hero:GetBaseHealthRegen() + totalHPRegen)
            hero:SetBaseManaRegen(hero:GetBaseManaRegen() + totalManaRegen)
            
            -- 为了显示效果，仍然设置modifier的层数
            hero:AddNewModifier(hero, ability, "modifier_necrolyte_reapers_scythe_respawn_time", {})
            hero:SetModifierStackCount("modifier_necrolyte_reapers_scythe_respawn_time", hero, stacks)
            
            print(string.format("死亡收割者获得额外生命恢复: %.1f, 魔法恢复: %.1f", totalHPRegen, totalManaRegen))
        end
    end

    if heroName == "npc_dota_hero_abyssal_underlord" then
        -- 找到技能
        local ability = hero:FindAbilityByName("abyssal_underlord_atrophy_aura")
        if ability and ability:GetLevel() > 0 then
            local duration = 60.0
            
            -- 给予10层小兵buff
            for i = 1, 10 do
                hero:AddNewModifier(hero, ability, "modifier_abyssal_underlord_atrophy_aura_creep_buff", {duration = duration})
            end
            
            -- 给予88层计数器和攻击力buff
            hero:AddNewModifier(hero, ability, "modifier_abyssal_underlord_atrophy_aura_dmg_buff_counter", {duration = duration})
            hero:SetModifierStackCount("modifier_abyssal_underlord_atrophy_aura_dmg_buff_counter", hero, 2 * ability:GetLevel() * 10)
        else
            print("错误：未能找到孽主的衰败光环技能或技能未升级！")
        end
    end

    if heroName == "npc_dota_hero_slark" then
        -- 获取英雄等级
        local heroLevel = hero:GetLevel()
        -- 计算层数
        local stacks = math.floor(heroLevel / 3)
        
        local ability = hero:FindAbilityByName("slark_essence_shift")
        if ability and ability:GetLevel() > 0 then
            -- 给予永久精华层数
            hero:AddNewModifier(hero, ability, "modifier_slark_essence_shift_permanent_buff", {})
            hero:SetModifierStackCount("modifier_slark_essence_shift_permanent_buff", hero, stacks)
            -- 打印给予的层数
            print("斯拉克获得永久精华层数: " .. stacks)
        else
            print("错误：未能找到斯拉克的精华转移技能或技能未升级！")
        end
    end
    if heroName == "npc_dota_hero_lion" then
        local heroLevel = hero:GetLevel()
        local stacks = math.floor(heroLevel / 3)
        local ability = hero:FindAbilityByName("lion_finger_of_death") 
        if ability and ability:GetLevel() > 0 then
            hero:SetModifierStackCount("modifier_lion_finger_of_death_kill_counter", hero, stacks)
        end
    end

    if heroName == "npc_dota_hero_marci" then
        --给他创建一个信使并且给信使狂战斧
        local challengeCode = self.currentChallenge
        print("challengeCode",challengeCode)

        local challengeName = self:GetChallengeIDByCode(challengeCode)
        print("challengeName",challengeName)


        local heroTeam = hero:GetTeamNumber()
        local courier = CreateUnitByName("npc_dota_courier", hero:GetAbsOrigin() + Vector(9999, 9999, 0), true, nil, nil, heroTeam)
        --允许玩家0控制
        courier:SetControllableByPlayer(0, true)
        --狂战斧
        if challengeName == "Fishing_Master" then
            courier:AddItemByName("item_gem")
        elseif challengeName == "Attack_Trigger_1skill"then
            courier:AddItemByName("item_satanic")
        elseif challengeName == "Intelligence_Cloak_Battle" then
            courier:AddItemByName("item_moon_shard")
        else
            courier:AddItemByName("item_bfury")
        end



        


    end

    if heroName == "npc_dota_hero_pudge" then
        local heroLevel = hero:GetLevel()
        local stacks = math.floor(heroLevel / 3)
        local ability = hero:FindAbilityByName("pudge_flesh_heap") 
        if ability and ability:GetLevel() > 0 then
            hero:SetModifierStackCount("modifier_pudge_innate_graft_flesh", hero, stacks)
            print(string.format("屠夫获得腐肉层数: %d", stacks))
        end
    end
    if heroName == "npc_dota_hero_silencer" then
        local heroLevel = hero:GetLevel()
        local stacks = math.floor(heroLevel)
        -- 设置智力窃取层数
        hero:SetModifierStackCount("modifier_silencer_brain_drain", hero, stacks)
        print(string.format("沉默术士获得智力窃取层数: %d", stacks))
        -- 增加30点智力
        hero:ModifyIntellect(30)
        print("沉默术士获得30点智力")

    end

    if heroName == "npc_dota_hero_legion_commander" then
        local heroLevel = hero:GetLevel()
        local stacks = math.floor(heroLevel / 3) * 28
        local ability = hero:FindAbilityByName("legion_commander_duel")
        if ability and ability:GetLevel() > 0 then
            hero:AddNewModifier(hero, ability, "modifier_legion_commander_duel_damage_boost", {})
            hero:SetModifierStackCount("modifier_legion_commander_duel_damage_boost", hero, stacks)
            print(string.format("军团获得决斗加成伤害: %d", stacks))
        end
    end

    if heroName == "npc_dota_hero_primal_beast" then
        local ability = hero:FindAbilityByName("primal_beast_uproar")
        if ability and ability:GetLevel() > 0 then
            local modifier = hero:AddNewModifier(hero, ability, "modifier_primal_beast_uproar", {duration = 20})
            if modifier then
                modifier:SetStackCount(5)
            end
        end
    end



end
function Main:HeroBenefits_10000(heroName, hero, overallStrategy, heroStrategy)

    local stacks = 1000
    if heroName == "npc_dota_hero_necrolyte" then

        hero:SetModifierStackCount("modifier_silencer_brain_drain", hero, stacks)
        print(string.format("沉默术士获得智力窃取层数: %d", stacks))
    end

    if heroName == "npc_dota_hero_silencer" then

        hero:SetModifierStackCount("modifier_silencer_brain_drain", hero, stacks * 3)

        hero:ModifyIntellect(stacks*3)

    end

    if heroName == "npc_dota_hero_rattletrap" then
        local ability = hero:FindAbilityByName("rattletrap_armor_power")
        print("找到了",ability)
        if ability and ability:GetLevel() > 0 then
            print("",ability:GetLevel())
            hero:AddNewModifier(hero, ability, "modifier_rattletrap_junk_mail", {})
            hero:SetModifierStackCount("modifier_rattletrap_junk_mail", hero, stacks)
        end
    end



    if heroName == "npc_dota_hero_necrolyte" then
        -- 设置英雄的生命和魔法恢复
                -- 为了显示效果，仍然设置modifier的层数
    local ability = hero:FindAbilityByName("necrolyte_reapers_scythe")
        hero:AddNewModifier(hero, ability, "modifier_health_regen_custom", {regen_amount = stacks * 6})
        hero:AddNewModifier(hero, ability, "modifier_mana_regen_custom", {regen_amount = stacks * 3})
        

        hero:AddNewModifier(hero, ability, "modifier_necrolyte_reapers_scythe_respawn_time", {})
        hero:SetModifierStackCount("modifier_necrolyte_reapers_scythe_respawn_time", hero, stacks)
    end

    if heroName == "npc_dota_hero_slark" then
        local ability = hero:FindAbilityByName("slark_essence_shift")
        hero:AddNewModifier(hero, ability, "modifier_slark_essence_shift_permanent_buff", {})
        hero:SetModifierStackCount("modifier_slark_essence_shift_permanent_buff", hero, stacks)
    end

    if heroName == "npc_dota_hero_pudge" then
        local ability = hero:FindAbilityByName("pudge_flesh_heap") 
        hero:SetModifierStackCount("modifier_pudge_innate_graft_flesh", hero, stacks)
    end

    if heroName == "npc_dota_hero_legion_commander" then
        local ability = hero:FindAbilityByName("legion_commander_duel")
        hero:AddNewModifier(hero, ability, "modifier_legion_commander_duel_damage_boost", {})
        hero:SetModifierStackCount("modifier_legion_commander_duel_damage_boost", hero, stacks * 35)
    end

    if heroName == "npc_dota_hero_lion" then
        local ability = hero:FindAbilityByName("lion_finger_of_death") 
        hero:SetModifierStackCount("modifier_lion_finger_of_death_kill_counter", hero, stacks)

    end
    if heroName == "npc_dota_hero_axe" then
        local ability = hero:FindAbilityByName("axe_battle_hunger")
        hero:SetModifierStackCount("modifier_axe_coat_of_blood", hero, stacks * 3)
    end
    if heroName == "npc_dota_hero_centaur" then
        local ability = hero:FindAbilityByName("centaur_rawhide")
        if ability then
            hero:RemoveAbility("centaur_rawhide")
            local bonus_health = stacks * 30
            --恢复满血
            hero:SetHealth(hero:GetMaxHealth())
            hero:AddNewModifier(hero, nil, "modifier_extra_health_bonus", {bonus_health = bonus_health})
        end
    end
    if heroName == "npc_dota_hero_life_stealer" then
        local ability = hero:FindAbilityByName("life_stealer_feast")
        if ability then
            if not hero:HasModifier("modifier_life_stealer_feast") then
                hero:AddNewModifier(hero, ability, "modifier_life_stealer_feast", {})
            end
            hero:SetModifierStackCount("modifier_life_stealer_feast", hero, stacks * 30)
            hero:AddNewModifier(hero, nil, "modifier_extra_health_bonus", {bonus_health = stacks * 30})
        end
    end


    if heroName == "npc_dota_hero_muerta" then
        local ability = hero:FindAbilityByName("muerta_pierce_the_veil")
        if ability then
            if not hero:HasModifier("modifier_muerta_pierce_the_veil_spell_amp_boost") then
                hero:AddNewModifier(hero, ability, "modifier_muerta_pierce_the_veil_spell_amp_boost", {})
            end
            hero:SetModifierStackCount("modifier_muerta_pierce_the_veil_spell_amp_boost", hero, stacks * 2)
        end
    end

    if heroName == "npc_dota_hero_nevermore" then
        hero:SetModifierStackCount("modifier_nevermore_necromastery", hero, stacks)
    end

    if heroName == "npc_dota_hero_storm_spirit" then
        hero:SetModifierStackCount("modifier_storm_spirit_galvanized", hero, stacks + 9)
        -- 同时提供魔法恢复速度加成，根据stacks数值
        hero:SetBaseManaRegen(hero:GetBaseManaRegen() + stacks * 0.1)
    end


    if heroName == "npc_dota_hero_tidehunter" then
        local ability = hero:FindAbilityByName("tidehunter_kraken_shell")
        if not hero:HasModifier("modifier_tidehunter_kraken_shell") then
            hero:AddNewModifier(hero, ability, "modifier_tidehunter_kraken_shell", {})
        end
        hero:SetModifierStackCount("modifier_tidehunter_kraken_shell", hero, stacks*4)
    end

    if heroName == "npc_dota_hero_arc_warden" then
        local ability = hero:FindAbilityByName("arc_warden_runic_infusion")
        if ability then
            hero:SetModifierStackCount("modifier_arc_warden_runic_infusion", hero, stacks)
        end
    end

    if heroName == "npc_dota_hero_alchemist" then
        local ability = hero:FindAbilityByName("alchemist_goblins_greed")
        if not hero:HasModifier("modifier_alchemist_scepter_bonus_damage") then
            hero:AddNewModifier(hero, ability, "modifier_alchemist_scepter_bonus_damage", {})
        end

        Timers:CreateTimer(0.01, function()
            -- 设置原有的技能层数
            hero:SetModifierStackCount("modifier_alchemist_scepter_bonus_damage", hero, stacks)

            return 0.01
        end)
        
    end




    if heroName == "npc_dota_hero_pugna" then
        local ability = hero:FindAbilityByName("pugna_oblivion_savant")
        if ability then

            hero:AddNewModifier(hero, ability, "modifier_special_bonus_spell_amplify", {
                bonus_value = stacks * 1.25
            })
            Timers:CreateTimer(0.01, function()
                -- 设置原有的技能层数
                hero:SetModifierStackCount("modifier_pugna_oblivion_savant", hero, stacks)
                

                
                return 0.01
            end)
        end
    end



end


function Main:HeroPreparation(heroName, hero, overallStrategy, heroStrategy)
    if heroName == "npc_dota_hero_doom_bringer" then
        local ability = hero:FindAbilityByName("doom_bringer_devour")
        if ability == nil or ability:GetLevel() < 1 then return end
        
        local function createUnit(unitName)
            --local unit = CreateUnitByName(unitName, hero:GetAbsOrigin() + RandomVector(RandomFloat(100, 200)), true, nil, nil, DOTA_TEAM_NEUTRALS)  
        end

        if CommonAI:containsStrategy(heroStrategy, "给予枭兽") then
            createUnit("npc_dota_neutral_wildkin")
        elseif CommonAI:containsStrategy(heroStrategy, "给予枭兽撕裂者") then
            createUnit("npc_dota_neutral_enraged_wildkin")
        elseif CommonAI:containsStrategy(heroStrategy, "给予半人马猎手") then
            createUnit("npc_dota_neutral_centaur_outrunner")
        elseif CommonAI:containsStrategy(heroStrategy, "给予半人马撕裂者") then
            createUnit("npc_dota_neutral_centaur_khan")
        elseif CommonAI:containsStrategy(heroStrategy, "给予食人魔拳手") then
            createUnit("npc_dota_neutral_ogre_mauler")
        elseif CommonAI:containsStrategy(heroStrategy, "给予食人魔冰霜法师") then
            createUnit("npc_dota_neutral_ogre_magi")
        elseif CommonAI:containsStrategy(heroStrategy, "给予萨特放逐者") then
            createUnit("npc_dota_neutral_satyr_trickster")
        elseif CommonAI:containsStrategy(heroStrategy, "给予萨特窃神者") then
            createUnit("npc_dota_neutral_satyr_soulstealer")
        elseif CommonAI:containsStrategy(heroStrategy, "给予萨特苦难使者") then
            createUnit("npc_dota_neutral_satyr_hellcaller")
        elseif CommonAI:containsStrategy(heroStrategy, "给予丘陵巨魔") then
            createUnit("npc_dota_neutral_dark_troll")
        elseif CommonAI:containsStrategy(heroStrategy, "给予丘陵巨魔狂战士") then
            createUnit("npc_dota_neutral_forest_troll_berserker")
        elseif CommonAI:containsStrategy(heroStrategy, "给予丘陵巨魔牧师") then
            createUnit("npc_dota_neutral_forest_troll_high_priest")
        elseif CommonAI:containsStrategy(heroStrategy, "给予黑暗巨魔召唤法师") then
            createUnit("npc_dota_neutral_dark_troll_warlord")
        elseif CommonAI:containsStrategy(heroStrategy, "给予地狱熊怪") then
            createUnit("npc_dota_neutral_polar_furbolg_champion")
        elseif CommonAI:containsStrategy(heroStrategy, "给予地狱熊怪粉碎者") then
            createUnit("npc_dota_neutral_polar_furbolg_ursa_warrior")
        elseif CommonAI:containsStrategy(heroStrategy, "给予巨狼") then
            createUnit("npc_dota_neutral_giant_wolf")
        elseif CommonAI:containsStrategy(heroStrategy, "给予头狼") then
            createUnit("npc_dota_neutral_alpha_wolf")
        elseif CommonAI:containsStrategy(heroStrategy, "给予鹰身女妖侦察者") then
            createUnit("npc_dota_neutral_harpy_scout")
        elseif CommonAI:containsStrategy(heroStrategy, "给予鹰身女妖风暴巫师") then
            createUnit("npc_dota_neutral_harpy_storm")
        elseif CommonAI:containsStrategy(heroStrategy, "给予狗头人") then
            createUnit("npc_dota_neutral_kobold")
        elseif CommonAI:containsStrategy(heroStrategy, "给予狗头人士兵") then
            createUnit("npc_dota_neutral_kobold_tunneler")
        elseif CommonAI:containsStrategy(heroStrategy, "给予狗头人长官") then
            createUnit("npc_dota_neutral_kobold_taskmaster")
        elseif CommonAI:containsStrategy(heroStrategy, "给予泥土傀儡") then
            createUnit("npc_dota_neutral_mud_golem")
        elseif CommonAI:containsStrategy(heroStrategy, "给予魔能之魂") then
            createUnit("npc_dota_neutral_fel_beast")
        elseif CommonAI:containsStrategy(heroStrategy, "给予鬼魂") then
            createUnit("npc_dota_neutral_ghost")
        elseif CommonAI:containsStrategy(heroStrategy, "给予豺狼人刺客") then
            createUnit("npc_dota_neutral_gnoll_assassin")
        elseif CommonAI:containsStrategy(heroStrategy, "给予斗松掠夺者") then
            createUnit("npc_dota_neutral_warpine_raider")
        -- 远古野怪
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古黑蜉蝣") then
            createUnit("npc_dota_neutral_black_drake")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古黑龙") then
            createUnit("npc_dota_neutral_black_dragon")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古花岗岩傀儡") then
            createUnit("npc_dota_neutral_granite_golem")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古岩石傀儡") then
            createUnit("npc_dota_neutral_rock_golem")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古寒冰萨满") then
            createUnit("npc_dota_neutral_ice_shaman")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古霜害傀儡") then
            createUnit("npc_dota_neutral_frostbitten_golem")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古潜行者长老") then
            createUnit("npc_dota_neutral_elder_jungle_stalker")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古潜行者") then
            createUnit("npc_dota_neutral_jungle_stalker")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古侍僧潜行者") then
            createUnit("npc_dota_neutral_prowler_acolyte")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古萨满潜行者") then
            createUnit("npc_dota_neutral_prowler_shaman")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古岚肤兽") then
            createUnit("npc_dota_neutral_small_thunder_lizard")
        elseif CommonAI:containsStrategy(heroStrategy, "给予远古雷肤兽") then
            createUnit("npc_dota_neutral_big_thunder_lizard")
        else
            createUnit("npc_dota_neutral_centaur_khan")
        end
    end

    if heroName == "npc_dota_hero_morphling" and not self.currentChallenge == 3021  then
        local ability_modifiers = {
            npc_dota_hero_morphling = {
                morphling_replicate = {
                    AbilityValues = {
                        duration = 1    
                    },
                },
                morphling_morph_agi = {
                    AbilityValues = {
                        points_per_tick = 1,
                        morph_cooldown = 0.001    
                    },
                },
                morphling_morph_str = {
                    AbilityValues = {
                        points_per_tick = 1,
                        morph_cooldown = 0.001    
                    },
                },
            },
        }
        self:UpdateAbilityModifiers(ability_modifiers)
        print("更新了morphling_replicate")
        local heroTeam = hero:GetTeamNumber()
        local enemyTeam = heroTeam == DOTA_TEAM_GOODGUYS and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS
    
        -- 创建食人魔魔法师
        local ogre = CreateUnitByName(
            "npc_dota_hero_ogre_magi",
            hero:GetAbsOrigin() + Vector(100, 0, 0),
            true,
            nil,
            nil,
            enemyTeam
        )
    
        if ogre then
            -- 添加无敌状态
            ogre:AddNewModifier(ogre, nil, "modifier_damage_reduction_100", {})
            
            -- 添加缴械modifier
            ogre:AddNewModifier(ogre, nil, "modifier_disarmed", {})
    
            -- 2秒后清理
            Timers:CreateTimer(2.0, function()
                if ogre and not ogre:IsNull() then
                    UTIL_Remove(ogre)
                end
                self:RestoreOriginalValues()
                return nil
            end)
        end
    end


    if heroName == "npc_dota_hero_ringmaster" then
        local gold = hero:GetGold()
        local tempHero = CreateUnitByName("npc_dota_hero_axe", hero:GetAbsOrigin() + RandomVector(100), true, nil, nil, DOTA_TEAM_BADGUYS)
        tempHero:AddNoDraw()
        Timers:CreateTimer(0.5, function()
            tempHero:Kill(nil,hero)
            hero:SetGold(gold, false)
        end)
    end


    if heroName == "npc_dota_hero_rubick" and self.currentChallenge == 3020 then
        local ability_modifiers = {
            npc_dota_hero_morphling = {
                morphling_replicate = {
                    AbilityValues = {
                        duration = 1    
                    },
                },
                morphling_morph_agi = {
                    AbilityValues = {
                        points_per_tick = 1,
                        morph_cooldown = 0.001    
                    },
                },
                morphling_morph_str = {
                    AbilityValues = {
                        points_per_tick = 1,
                        morph_cooldown = 0.001    
                    },
                },
            },
        }
        self:UpdateAbilityModifiers(ability_modifiers)
        print("更新了morphling_replicate")
        local heroTeam = hero:GetTeamNumber()
        local enemyTeam = heroTeam == DOTA_TEAM_GOODGUYS and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS
    
        -- 创建娜迦
        local naga = CreateUnitByName(
            "npc_dota_hero_naga_siren",
            hero:GetAbsOrigin() + Vector(100, 0, 0),
            true,
            nil,
            nil,
            enemyTeam
        )
    
        if naga then
            -- 添加无敌状态
            --
            HeroMaxLevel(naga)
            naga:AddNewModifier(naga, nil, "modifier_item_aghanims_shard", {})
            naga:AddNewModifier(naga, nil, "modifier_item_ultimate_scepter_consumed", {})
            naga:SetControllableByPlayer(0, true)
            naga:AddNewModifier(naga, nil, "modifier_damage_reduction_100", {})

            
            -- 添加缴械modifier
            naga:AddNewModifier(ogre, nil, "modifier_disarmed", {})
    
            Timers:CreateTimer(0.5, function()  
                naga:CastAbilityNoTarget(naga:FindAbilityByName("naga_siren_song_of_the_siren"), 0)
            end)
            -- 2秒后清理
            Timers:CreateTimer(3.0, function()
                if naga and not naga:IsNull() then

                    hero:SetCursorCastTarget(naga)
                    hero:FindAbilityByName("rubick_spell_steal"):OnSpellStart()
                    naga:SetAbsOrigin(Main.SPAWN_POINT_FAR)
                end
                self:RestoreOriginalValues()
                return nil
            end)
        end
    end


















    if heroName == "npc_dota_hero_sven" then
        local heroTeam = hero:GetTeamNumber()
        local enemyTeam = heroTeam == DOTA_TEAM_GOODGUYS and DOTA_TEAM_BADGUYS or DOTA_TEAM_GOODGUYS
    
        -- 创建食人魔魔法师
        local ogre = CreateUnitByName(
            "npc_dota_hero_ogre_magi",
            hero:GetAbsOrigin() + Vector(100, 0, 0),
            true,
            nil,
            nil,
            enemyTeam
        )
    
        if ogre then
            -- 添加无敌状态
            ogre:AddNewModifier(ogre, nil, "modifier_damage_reduction_100", {})
            
            -- 添加缴械modifier
            ogre:AddNewModifier(ogre, nil, "modifier_disarmed", {})
    
            -- 2秒后清理
            Timers:CreateTimer(2.0, function()
                if ogre and not ogre:IsNull() then
                    UTIL_Remove(ogre)
                end
                return nil
            end)
        end
    end
    
    if heroName == "npc_dota_hero_silencer" then
        print("创建沉默术士的可穿戴假人")

        -- 移除英雄本身的穿戴装备
        local wearable = hero:FirstMoveChild()
        while wearable ~= nil do
            if wearable:GetClassname() == "dota_item_wearable" then
                local nextWearable = wearable:NextMovePeer()
                UTIL_Remove(wearable)
                wearable = nextWearable
            else
                wearable = wearable:NextMovePeer()
            end
        end
        
        local dummyName = "npc_dota_hero_silencer_wearable_dummy"
        local dummy = CreateUnitByName(dummyName, hero:GetAbsOrigin(), false, hero, hero, hero:GetTeamNumber())
        
        if dummy then
            dummy:FollowEntity(hero, true)
            dummy:AddNewModifier(dummy, nil, "modifier_wearable", {})

            hero.wearableDummy = dummy
            print("成功创建并附加可穿戴假人到沉默术士")
        else
            print("无法为沉默术士创建可穿戴假人")
        end
    end

    if heroName == "npc_dota_hero_puck" then
        print("创建帕克的可穿戴假人")
    
        -- 移除英雄本身的穿戴装备
        local wearable = hero:FirstMoveChild()
        while wearable ~= nil do
            if wearable:GetClassname() == "dota_item_wearable" then
                local nextWearable = wearable:NextMovePeer()
                UTIL_Remove(wearable)
                wearable = nextWearable
            else
                wearable = wearable:NextMovePeer()
            end
        end
    
        local dummyName = "npc_dota_hero_puck_wearable_dummy"
        local dummy = CreateUnitByName(dummyName, hero:GetAbsOrigin(), false, hero, hero, hero:GetTeamNumber())
        
        if dummy then
            dummy:FollowEntity(hero, true)
            dummy:AddNewModifier(dummy, nil, "modifier_wearable", {})
    
            hero.wearableDummy = dummy
            print("成功创建并附加可穿戴假人到帕克")
        else
            print("无法为帕克创建可穿戴假人")
        end
    end

    
    if heroName == "npc_dota_hero_invoker" then
        local wex = hero:FindAbilityByName("invoker_wex")
        local quas = hero:FindAbilityByName("invoker_quas")
        local exort = hero:FindAbilityByName("invoker_exort")
        local invoke = hero:FindAbilityByName("invoker_invoke")
        local facet = hero:GetHeroFacetID()
        
        if wex and quas and exort and invoke then
            -- 预先检查所有技能等级，避免重复获取
            local wexLevel = wex:GetLevel()
            local quasLevel = quas:GetLevel()
            local exortLevel = exort:GetLevel()
            local invokeLevel = invoke:GetLevel()
            
            -- 定义一个辅助函数，仅当技能等级>1时才释放技能
            local function castIfHigherLevel(ability, level)
                if level >= 1 then 
                    ability:OnSpellStart() 
                end
            end
            
            if facet == 4 then
                -- 原有的facet 4逻辑
                print("释放3次wex和1次invoke")
                castIfHigherLevel(wex, wexLevel)
                castIfHigherLevel(wex, wexLevel)
                castIfHigherLevel(wex, wexLevel)
                castIfHigherLevel(invoke, invokeLevel)

                print("释放2次wex,1次quas和1次invoke")
                castIfHigherLevel(wex, wexLevel)
                castIfHigherLevel(wex, wexLevel)
                castIfHigherLevel(quas, quasLevel)
                castIfHigherLevel(invoke, invokeLevel)
                
            elseif facet == 5 then
                -- 新增的facet 5逻辑
                print("释放3次exort和1次invoke")
                castIfHigherLevel(exort, exortLevel)
                castIfHigherLevel(exort, exortLevel)
                castIfHigherLevel(exort, exortLevel)
                castIfHigherLevel(invoke, invokeLevel)
                
                print("释放2次exort,1次quas和1次invoke")
                castIfHigherLevel(exort, exortLevel)
                castIfHigherLevel(exort, exortLevel)
                castIfHigherLevel(wex, wexLevel)
                castIfHigherLevel(invoke, invokeLevel)
            end
        end
    end
    if heroName == "npc_dota_hero_kez" then
        print("给与凯兹小礼物")
        if CommonAI:containsStrategy(heroStrategy, "双钗出战") then
            print("双钗出战")
            local ability = hero:FindAbilityByName("kez_switch_weapons")
            if ability then
                ability:OnSpellStart()
            end
        end
    end

end