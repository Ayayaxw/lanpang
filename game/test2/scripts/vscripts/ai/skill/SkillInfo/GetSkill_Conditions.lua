local firstTimeCalled = true
-- 定义英雄特定的技能释放条件

-- 通用的条件函数
HeroSkillConditions = {
    ["npc_dota_hero_spectre"] = {
        ["spectre_reality"] = {
            function(self, caster, log)
                return GetRealEnemyHeroesWithinDistance(caster, 300, log) == 0 and HasHauntIllusions(caster, log)
            end
        },
        ["spectre_dispersion"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "禁用折射主动") then
                    return false
                else
                    return true
                end
            end
        },

    },
    ["npc_dota_hero_bloodseeker"] = {
        ["bloodseeker_blood_mist"] = {
            function(self, caster, log)
                return GetRealEnemyHeroesWithinDistance(caster, 350, log) > 0 
            end
        },
        ["bloodseeker_rupture"] = {
            function(self, caster, log)


                local ability = caster:FindAbilityByName("bloodseeker_rupture")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_bloodseeker_rupture"},
                    0.5,
                    "distance" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return self.target ~= nil
            end
        },
    },
    ["npc_dota_hero_broodmother"] = {
        ["broodmother_spin_web"] = {
            function(self, caster, log)
                -- local forbiddenModifiers = {
                --     "modifier_broodmother_spin_web",
                -- }
                -- return self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
                return false
            end
        },
        ["broodmother_sticky_snare"] = {
            function(self, caster, log)
                -- 初始化上次返回true的时间
                if not self.lastStickySnareTime then
                    self.lastStickySnareTime = 0
                end

                local currentTime = GameRules:GetGameTime()
                
                -- 检查是否在3秒冷却时间内
                if currentTime - self.lastStickySnareTime < 3 then
                    return false
                end
                
                -- 更新上次返回true的时间
                self.lastStickySnareTime = currentTime
                return true
            end
        },
    },
    ["npc_dota_hero_antimage"] = {
        ["antimage_blink"] = {
            function(self, caster, log)
                return GetRealEnemyHeroesWithinDistance(caster, 300, log) == 0 
            end
        },
        ["antimage_counterspell_ally"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("antimage_counterspell_ally")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {""},
                    0,
                    "distance" ,
                    true,
                    false
                )
                
                return self.Ally ~= nil
            end
        },
        
        ["antimage_mana_void"] = {
            function(self, caster, log)
                -- 获取虚空技能
                local ability = caster:FindAbilityByName("antimage_mana_void")
                if not ability then return false end
        
                if self:containsStrategy(self.hero_strategy, "满血直接炸") then
                    return true
                else
                    -- 寻找魔法值百分比最低的目标
                    local potentialTarget = self:FindBestEnemyHeroTarget(
                        caster,
                        ability,
                        {},
                        0,
                        "mana_percent",
                        true
                    )
                    
                    -- 只有在找到的目标不为nil时才赋值
                    if potentialTarget then
                        self.target = potentialTarget
                    end
                    
                    -- 敌法师生命值低于30%且找到目标时返回true
                    if caster:GetHealthPercent() < 30 and self.target then
                        return true
                    end
                    
                    -- 找到目标且目标魔法值低于10%时返回true
                    if self.target and self.target:GetManaPercent() < 10 then
                        return true
                    end
                    
                    return false
                end
            end
        },
        
    },
    ["npc_dota_hero_weaver"] = {
        ["weaver_time_lapse"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("weaver_time_lapse")
                if not ability then return false end
        
                if caster:GetHealthPercent() < 50 then
                    self.Ally = caster
                    return true
                end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "health_percent"  -- 按血量百分比排序
                )
                if self:containsStrategy(self.hero_strategy, "满血开大") then
                    self:log("该满血开大了")
                    return self.Ally
                else
                    return self.Ally and self.Ally:GetHealthPercent() < 50
                end
            end
        }
    },
    ["npc_dota_hero_bane"] = {
        ["bane_fiends_grip"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("bane_fiends_grip")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return self.target ~= nil
            end
        },
        -- ["bane_brain_sap"] = {
        --     function(self, caster, log)
        --         local ability = caster:FindAbilityByName("bane_brain_sap")
        --         if not ability then return false end
                
        --         self.target = self:FindBestEnemyHeroTarget(
        --             caster,
        --             ability,
        --             {"modifier_bane_nightmare"},
        --             0.5,
        --             "distance",
        --             false      -- 只允许英雄单位
        --         )
                
        --         return self.target ~= nil
        --     end
        -- },
        ["bane_nightmare"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("bane_nightmare")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
    },
    ["npc_dota_hero_ringmaster"] = {
        ["ringmaster_the_box"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("ringmaster_the_box")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "health_percent"
                )
                
                return self.Ally and self.Ally:GetHealthPercent() < 50
            end
        },
        ["ringmaster_strongman_tonic"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("ringmaster_strongman_tonic")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "health_percent"
                )
                
                return self.Ally 
            end
        }

    },
    ["npc_dota_hero_snapfire"] = {
        ["snapfire_mortimer_kisses"] = {
            function(self, caster, log)
                if self.target then
                    local distance = (caster:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D()
                    if distance <= 400 then
                        return false
                    end
                end
                return true
            end
        },
        ["snapfire_firesnap_cookie"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("snapfire_firesnap_cookie")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
    },
    ["npc_dota_hero_winter_wyvern"] = {
        ["winter_wyvern_cold_embrace"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("winter_wyvern_cold_embrace")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,  -- 没有需要检查的buff/debuff
                    nil,  -- 不需要检查持续时间
                    "health_percent"
                )
        
                if self.Ally and self.Ally:GetHealthPercent() < 50 then
                    return true
                end
                
                return false
            end
        },
        ["winter_wyvern_winters_curse"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("winter_wyvern_winters_curse")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
        ["winter_wyvern_splinter_blast"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("winter_wyvern_winters_curse")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
    },
    ["npc_dota_hero_chen"] = {
        ["chen_hand_of_god"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("chen_hand_of_god")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster, 
                    ability,
                    nil,
                    nil,
                    "health_percent"
                )
        
                return self.Ally ~= nil and self.Ally:GetHealthPercent() < 50
            end
        },
    },

    ["npc_dota_hero_arc_warden"] = {
        ["arc_warden_magnetic_field"] = {
            function(self, caster, log)


                local ability = caster:FindAbilityByName("arc_warden_magnetic_field")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster, 
                    ability,
                    {"modifier_arc_warden_magnetic_field_evasion"},
                    0,
                    "nearest_to_enemy",
                    true,
                    true,
                    false
                )
        
                -- 检查是否找到了盟友
                return self.Ally ~= nil
            end
        },


        ["arc_warden_flux"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("arc_warden_flux")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_arc_warden_flux"},
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },

        
    },

    ["npc_dota_hero_axe"] = {
        ["axe_culling_blade"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("axe_culling_blade")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "health_percent",  
                    true      -- 只允许英雄单位
                )
                
                -- 更新目标
                if potentialTarget then self.target = potentialTarget end
                if not self.target then return false end
                
                -- 目标生命值低于斩杀线
                if self.target:GetHealth() <= 575 then return true end
                
                -- 自身生命值过低且未限制使用策略时使用
                if caster:GetHealthPercent() <= 20 and not self:containsStrategy(self.hero_strategy, "必须留斩杀") then
                    return true
                end
                
                return false
            end
        },
        ["axe_berserkers_call"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("axe_berserkers_call")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
    },


    ["npc_dota_hero_skeleton_king"] = {
        ["skeleton_king_bone_guard"] = {
            function(self, caster, log)
                -- 查找英雄身上的 modifier_skeleton_king_bone_guard
                local modifier = caster:FindModifierByName("modifier_skeleton_king_bone_guard")
                
                -- 如果 modifier 存在，检查其层数
                if modifier then
                    local stackCount = modifier:GetStackCount()
                    -- 如果层数超过两层，返回 true
                    if stackCount >= 2 then
                        return true
                    end
                end
                return false
            end
        },
        ["skeleton_king_hellfire_blast"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("skeleton_king_hellfire_blast")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
        ["skeleton_king_reincarnation"] = {
            function(self, caster, log)
                return false
            end
        },
    },



    ["npc_dota_hero_nevermore"] = {
        ["nevermore_shadowraze1"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("nevermore_shadowraze1")
                local radius = ability and self:GetSkillAoeRadius(ability) or 250
                local castRange = 200
                
                -- 获取SF朝向的单位向量
                local forward = caster:GetForwardVector():Normalized()
                -- 计算影压圆心位置
                local razeCenter = caster:GetAbsOrigin() + forward * castRange
                
                -- 查找范围内的敌方单位
                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),    -- 队伍编号
                    razeCenter,                -- 圆心位置
                    nil,                       -- 过滤器
                    radius,                    -- 搜索半径
                    DOTA_UNIT_TARGET_TEAM_ENEMY,    -- 目标队伍
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,  -- 目标类型
                    DOTA_UNIT_TARGET_FLAG_NONE,     -- 目标标志
                    FIND_ANY_ORDER,                 -- 查找顺序
                    false                           -- 是否可见要求
                )
                
                -- 如果找到至少一个敌人，返回true
                return #enemies > 0
            end
        },
        ["nevermore_shadowraze2"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("nevermore_shadowraze2")
                local radius = ability and self:GetSkillAoeRadius(ability) or 250
                local castRange = 450
                
                local forward = caster:GetForwardVector():Normalized()
                local razeCenter = caster:GetAbsOrigin() + forward * castRange
                
                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    razeCenter,
                    nil,
                    radius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                
                return #enemies > 0
            end
        },
        ["nevermore_shadowraze3"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("nevermore_shadowraze3")
                local radius = ability and self:GetSkillAoeRadius(ability) or 250
                local castRange = 700
                
                local forward = caster:GetForwardVector():Normalized()
                local razeCenter = caster:GetAbsOrigin() + forward * castRange
                
                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    razeCenter,
                    nil,
                    radius,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                
                return #enemies > 0
            end
        },
        ["nevermore_frenzy"] = {
            function(self, caster, log)
                local needsRefresh = self:NeedsModifierRefresh(caster, {"modifier_nevermore_frenzy"}, 0.5)
                return needsRefresh
            end
        },
        ["nevermore_requiem"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "满血开大") then
                    return true
                end
                return caster:GetHealthPercent()<80
            end
        },
    },
    ["npc_dota_hero_disruptor"] = {
        ["disruptor_static_storm"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("disruptor_static_storm")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_disruptor_static_storm"},
                    0,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
    },


    ["npc_dota_hero_lich"] = {
        ["lich_frost_shield"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("lich_frost_shield")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster, 
                    ability,
                    {"modifier_lich_frost_shield"},
                    0.5,
                    "health_percent"
                )
        
                return self.Ally ~= nil
            end
        },
        ["lich_sinister_gaze"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("lich_sinister_gaze")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
    },

    ["npc_dota_hero_grimstroke"] = {
        ["grimstroke_spirit_walk"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("grimstroke_spirit_walk")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,  -- 不需要检查buff
                    nil,  -- 不需要检查剩余时间
                    "nearest_to_enemy",  -- 优先给离敌人最近的友军释放
                    true,
                    true,
                    true
                )
                
                return self.Ally ~= nil
            end
        }
    },

    ["npc_dota_hero_warlock"] = {
        ["warlock_shadow_word"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("warlock_shadow_word")
                if not ability then return false end
        
                if self:containsStrategy(self.hero_strategy, "先给自己奶") then
                    self.skillTargetTeam["warlock_shadow_word"] = DOTA_UNIT_TARGET_TEAM.FRIENDLY
                    self.Ally = caster
                    return true
                end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,  -- 不需要检查buff
                    nil,  -- 不需要检查剩余时间
                    "health",  -- 优先给离敌人最近的友军释放
                    true,
                    true
                )
                
                if self.Ally then
                    self.skillTargetTeam["warlock_shadow_word"] = DOTA_UNIT_TARGET_TEAM.FRIENDLY
                else
                    if self.skillTargetTeam["warlock_shadow_word"] then
                        self.skillTargetTeam["warlock_shadow_word"] = nil
                    end
                end
        
                return self.Ally ~= nil
            end
        },
    },

    ["npc_dota_hero_shadow_shaman"] = {
        ["shadow_shaman_voodoo"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("shadow_shaman_voodoo")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
        ["shadow_shaman_shackles"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("shadow_shaman_shackles")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        }
    },

    ["npc_dota_hero_ogre_magi"] = {
        ["ogre_magi_ignite"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("ogre_magi_ignite")
                local aoeRadius = self:GetSkillAoeRadius(ability)
                local castRange = self:GetSkillCastRange(caster, ability)
                local totalRange = aoeRadius + castRange

                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    totalRange,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )

                for _, enemy in pairs(enemies) do
                    if self:NeedsModifierRefresh(enemy, {"modifier_ogre_magi_ignite"}, 0.5) then
                        return true
                    end
                end

                return false
            end
        },
        ["ogre_magi_fireblast"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("ogre_magi_fireblast")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
        
        ["ogre_magi_unrefined_fireblast"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("ogre_magi_unrefined_fireblast")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
        ["ogre_magi_bloodlust"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("ogre_magi_bloodlust")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_ogre_magi_bloodlust"},
                    0.5,
                    "attack",
                    false,  -- forceHero设为false,允许选择非英雄单位
                    true
                )
        
                return self.Ally ~= nil
            end
        },
        ["ogre_magi_smash"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("ogre_magi_smash") 
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_ogre_magi_smash_buff"},
                    0.5,
                    "health_percent",
                    true, 
                    true
                )
                return self.Ally ~= nil
            end
        }
    },


    ["npc_dota_hero_abyssal_underlord"] = {
        ["abyssal_underlord_pit_of_malice"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("abyssal_underlord_pit_of_malice")
                local aoeRadius = self:GetSkillAoeRadius(ability)
                local castRange = self:GetSkillCastRange(caster, ability)
                local totalRange = aoeRadius + castRange

                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    totalRange,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )

                for _, enemy in pairs(enemies) do

                    local forbiddenModifiers = {
                        "modifier_abyssal_underlord_pit_of_malice_slow",
                    }
                    if self:IsNotUnderModifiers(enemy, forbiddenModifiers, log) then
                        return true
                    end

                end

                return false
            end
        },
        ["abyssal_underlord_dark_portal"] = {
            function(self, caster, log)
                return false
            end
        },
    },





    ["npc_dota_hero_lion"] = {
        ["lion_voodoo"] = {
            function(self, caster, log)

                local ability = caster:FindAbilityByName("lion_voodoo")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
        ["lion_impale"] = {
            function(self, caster, log)

                local ability = caster:FindAbilityByName("lion_impale")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
        ["lion_mana_drain"] = {
            function(self, caster, log)
                -- 获取英雄当前蓝量百分比
                local manaPercent = caster:GetManaPercent()
                
                -- 如果蓝量超过30%返回false
                if manaPercent > 30 then
                    return false
                end
                
                -- 蓝量低于或等于30%返回true
                return true
            end
        },
    },




    ["npc_dota_hero_rubick"] = {
        ["rubick_spell_steal"] = {
            function(self, caster, log)
                -- 获取所有敌方英雄
                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    1500, -- 搜索范围，可以根据需要调整
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_CLOSEST,
                    false
                )
                
                -- 遍历所有找到的英雄
                for _, enemy in pairs(enemies) do
                    local unitName = enemy:GetUnitName()
                    if enemy:IsRealHero() and 
                       not string.find(unitName, "npc_dota_lone_druid_bear") and 
                       Main.heroesUsedAbility[enemy:GetEntityIndex()] then
                        -- 找到符合条件的最近英雄，更新target并返回true
                        self.target = enemy
                        self:log("找到使用过技能的最近敌方英雄: " .. unitName)
                        return true
                    end
                end
                
                self:log("未找到使用过技能的敌方英雄")
                return false
            end
        },
        ["rubick_telekinesis"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("rubick_telekinesis")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    1,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil
            end
        },
    },

    ["npc_dota_hero_riki"] = {
        ["riki_smoke_screen"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("riki_smoke_screen")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil and self:NeedsModifierRefresh(caster,{"modifier_riki_tricks_of_the_trade_phase"}, 0.2)
            end
        },
        ["riki_tricks_of_the_trade"] = {
            function(self, caster, log)
                return true
            end
        },
        ["riki_blink_strike"] = {
            function(self, caster, log)
                return self:NeedsModifierRefresh(caster,{"modifier_riki_tricks_of_the_trade_phase"}, 0)
            end
        },
    },
    ["npc_dota_hero_sven"] = {
        ["sven_gods_strength"] = {
            function(self, caster, log)
                local forbiddenModifiers = {
                    "modifier_sven_gods_strength",
                }
                return self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
            end
        },
        ["sven_storm_bolt"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("sven_storm_bolt")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },
    



    ["npc_dota_hero_templar_assassin"] = {
        ["templar_assassin_meld"] = {
            function(self, caster, log)
                local forbiddenModifiers = {
                    "modifier_templar_assassin_meld",
                }
                return self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
            end
        },
        ["templar_assassin_trap_teleport"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "允许传送") then
                    local modifierName = "modifier_templar_assassin_psionic_trap_counter"
                    local modifier = caster:FindModifierByName(modifierName)
                    
                    if modifier and modifier:GetStackCount() >= 1 then
                        if log then
                            self:log("圣堂刺客有足够的陷阱层数，可以使用传送")
                        end
                        return true
                    else
                        if log then
                            self:log("圣堂刺客没有足够的陷阱层数，不能使用传送")
                        end
                        return false
                    end
                else
                    return false
                end
            end
        }
    },


    ["npc_dota_hero_faceless_void"] = {
        ["faceless_void_time_dilation"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("faceless_void_time_dilation")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "cooldown_abilities" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["faceless_void_time_walk_reverse"] = {
            function(self, caster, log)
                -- 计算与目标的距离
                local distance = (caster:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D()
                local isTargetClose = distance <= 200
                
                if caster:HasModifier("modifier_faceless_void_time_walk_shardbuff") and 
                   self:NeedsModifierRefresh(caster,{"modifier_faceless_void_time_walk_shardbuff"}, 0.8) and 
                   self:NeedsModifierRefresh(self.target,{"modifier_faceless_void_timelock_freeze"}, 0) and
                   isTargetClose then
                    return true
                else
                    return false
                end
            end
        },
        ["faceless_void_time_walk"] = {
            function(self, caster, log)      
                if self:containsStrategy(self.hero_strategy, "满血跳") then
                    return true
                else
                    -- 当血量低于30%时直接返回true(紧急情况)
                    local current_health = caster:GetHealthPercent()
                    if current_health < 25 then
                        if log then
                            self:log("血量低于30%，立即释放时间漫步，当前血量: " .. current_health .. "%")
                        end
                        return true
                    end
                    
                    -- 初始化需要的变量
                    if not self.void_time_walk_data then
                        self.void_time_walk_data = {
                            last_health_percent = caster:GetHealthPercent(),
                            damage_detected = false,
                            damage_time = 0,
                            original_health = 0,
                            skill_triggered = false
                        }
                        return false
                    end
                    
                    local current_time = GameRules:GetGameTime()
                    
                    -- 如果技能已触发，需要等待一段时间再重新检测
                    if self.void_time_walk_data.skill_triggered then
                        if current_time - self.void_time_walk_data.damage_time > 3 then
                            -- 重置状态，准备下一次检测
                            self.void_time_walk_data = {
                                last_health_percent = current_health,
                                damage_detected = false,
                                damage_time = 0,
                                original_health = 0,
                                skill_triggered = false
                            }
                        end
                        return false
                    end
                    
                    -- 检测到掉血
                    if current_health < self.void_time_walk_data.last_health_percent and not self.void_time_walk_data.damage_detected then
                        self.void_time_walk_data.damage_detected = true
                        self.void_time_walk_data.damage_time = current_time
                        self.void_time_walk_data.original_health = self.void_time_walk_data.last_health_percent
                        if log then
                            self:log("检测到掉血，原始血量: " .. self.void_time_walk_data.original_health .. "，现在血量: " .. current_health)
                        end
                    end
                    
                    -- 更新上次血量记录
                    self.void_time_walk_data.last_health_percent = current_health
                    
                    -- 如果已检测到掉血，且已经过了2秒，则触发技能
                    if self.void_time_walk_data.damage_detected and current_time - self.void_time_walk_data.damage_time >= 1.5 then
                        local health_drop = self.void_time_walk_data.original_health - current_health
                        if health_drop > 5 then  -- 掉血超过5%才触发
                            self.void_time_walk_data.skill_triggered = true
                            if log then
                                self:log("准备释放时间漫步，掉血量: " .. health_drop .. "%，经过时间: " .. (current_time - self.void_time_walk_data.damage_time))
                            end
                            return true
                        else
                            -- 掉血不足以触发技能，重置检测
                            self.void_time_walk_data.damage_detected = false
                        end
                    end
                    
                    return false
                end
            end
        },
        ["faceless_void_chronosphere"] = {
            function(self, caster, log)

                if self:containsStrategy(self.global_strategy, "卡时间") then
                    if (hero_duel.start_time + Main.limitTime + Main.duration) - GameRules:GetGameTime()  > 5 then
                        return false
                    end
                end


                local ability = caster:FindAbilityByName("faceless_void_chronosphere")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },

    ["npc_dota_hero_luna"] = {
        ["luna_lunar_orbit"] = {
            function(self, caster, log)                
                return self:NeedsModifierRefresh(caster,{"modifier_luna_moon_glaive_shield"}, 0.5)
            end
        }
    },

    ["npc_dota_hero_phantom_assassin"] = {
        ["phantom_assassin_phantom_strike"] = {
            function(self, caster, log)
                -- 检查是否有"模糊好了才放技能"策略
                if self:containsStrategy(self.hero_strategy, "模糊好了才放技能") then
                    -- 检查模糊技能是否冷却好
                    local blurAbility = caster:FindAbilityByName("phantom_assassin_blur")
                    if not (blurAbility and blurAbility:IsFullyCastable()) then
                        return false
                    end
                end
                
                -- 检查目标是否需要刷新扇形刀刃modifier
                local needsTargetModifierRefresh = self.target:HasModifier("modifier_phantom_assassin_fan_of_knives")
                
                -- 检查施法者是否需要刷新幻影突袭modifier
                local needsCasterModifierRefresh = self:NeedsModifierRefresh(caster, {"modifier_phantom_assassin_phantom_strike"}, 0.2)
                
                -- 计算与目标的距离
                local distance = (caster:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D()
                local isTooFar = distance > 150
                
                -- 根据策略决定返回结果
                if self:containsStrategy(self.hero_strategy, "先破被动再行动") then
                    -- 检查英雄是否拥有扇形刀刃技能并且不在冷却中
                    local hasReadyFanOfKnives = false
                    local fanOfKnivesAbility = caster:FindAbilityByName("phantom_assassin_fan_of_knives")
                    if fanOfKnivesAbility and fanOfKnivesAbility:IsFullyCastable() then
                        hasReadyFanOfKnives = true
                    end
                    
                    return (needsTargetModifierRefresh or hasReadyFanOfKnives) and (isTooFar or needsCasterModifierRefresh)
                else
                    return isTooFar or needsCasterModifierRefresh
                end
            end
        },
        ["phantom_assassin_stifling_dagger"] = {
            function(self, caster, log)

                
                -- 检查是否有"远距离才放镖"策略
                if self:containsStrategy(self.hero_strategy, "远距离才放镖") then
                    -- 计算与目标的距离
                    local distance = (caster:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D()
                    if distance <= 200 then
                        -- 距离太近，不释放匕首
                        return false
                    end
                end

                -- "先破被动再行动"策略的原有判断
                if self:containsStrategy(self.hero_strategy, "先破被动再行动") then
                    -- 检查目标是否有扇形刀刃modifier
                    if self.target:HasModifier("modifier_phantom_assassin_fan_of_knives") then
                        return true
                    else
                        -- 检查英雄是否拥有扇形刀刃技能并且不在冷却中
                        local fanOfKnivesAbility = caster:FindAbilityByName("phantom_assassin_fan_of_knives")
                        if fanOfKnivesAbility and fanOfKnivesAbility:IsFullyCastable() then
                            return true
                        else
                            return false
                        end
                    end
                else
                    return true
                end
            end
        },
        ["phantom_assassin_fan_of_knives"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "模糊好了才放技能") then
                    -- 检查模糊技能是否冷却好
                    local blurAbility = caster:FindAbilityByName("phantom_assassin_blur")
                    if blurAbility and blurAbility:IsFullyCastable() then
                        return true
                    else
                        return false
                    end
                else
                    return true
                end
            end
        },




        ["phantom_assassin_blur"] = {
            function(self, caster, log)    
                if caster:HasScepter() and caster:GetPurgableDebuffsCount() > 0 then
                    return true
                elseif caster:GetHealthPercent() < 50 then
                    return true
                end 
                return false
            end
        },

    },

    ["npc_dota_hero_omniknight"] = {
        ["omniknight_guardian_angel"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("omniknight_guardian_angel")
                if not ability then return false end
                
                if self:containsStrategy(self.hero_strategy, "满血开大") then
                    self.Ally = caster
                    return true
                end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {},
                    0,
                    "health_percent"
                )
        
                return self.Ally and self.Ally:GetHealthPercent() < 50
            end
        },
        
        ["omniknight_martyr"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("omniknight_martyr")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_omniknight_martyr"},
                    0.5,
                    "health_percent"
                )
        
                return self.Ally ~= nil
            end
        },
        
        ["omniknight_purification"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("omniknight_purification")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {},
                    0,
                    "health"
                )
                
                return self.Ally and (self.Ally:GetMaxHealth() - self.Ally:GetHealth() > 500)
            end
        }
    },

    ["npc_dota_hero_centaur"] = {
        ["centaur_mount"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("centaur_mount")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "health_percent",  -- 按血量百分比排序
                    true,             -- 只允许英雄单位
                    false             -- 不允许选择自己
                )
        
                return self.Ally and self.Ally:GetHealthPercent() < 30
            end
        },
        ["centaur_work_horse"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("centaur_work_horse")
                if not ability then return false end
        
                -- 检查自身是否有 modifier_centaur_stampede
                local has_stampede = caster:HasModifier("modifier_centaur_stampede")
                
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "health_percent",  -- 按血量百分比排序
                    true,             -- 只允许英雄单位
                    false             -- 不允许选择自己
                )
        
                -- 如果找到合适的队友，或者自己没有 stampede modifier，则返回 true
                return (self.Ally and self.Ally:GetHealthPercent() < 30) or (not has_stampede)
            end
        },
        ["centaur_stampede"] = {
            function(self, caster, log)
                -- 检查自身是否有 modifier_centaur_stampede
                local has_stampede = caster:HasModifier("modifier_centaur_stampede")
                
                -- 如果自己没有 stampede modifier，则返回 true
                return not has_stampede
            end
        },


        ["centaur_hoof_stomp"] = {
            function(self, caster, log)
                if caster:HasModifier("modifier_centaur_hoof_stomp_windup") then
                    return false
                end
        
                local ability = caster:FindAbilityByName("centaur_hoof_stomp")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 

                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },






    ["npc_dota_hero_doom_bringer"] = {
        ["doom_bringer_scorched_earth"] = {
            function(self, caster, log)                
                return self:NeedsModifierRefresh(caster,{"modifier_doom_bringer_scorched_earth_effect"}, 0.5)
            end
        },
        ["doom_bringer_doom"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("doom_bringer_doom")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_doom_bringer_doom_aura_enemy"},
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["doom_bringer_infernal_blade"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("doom_bringer_infernal_blade")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                local isToggled = ability:GetAutoCastState()
                if potentialTarget and not isToggled then
                    return true
                elseif not potentialTarget and isToggled then
                    return true
                end
                return false
            end
        },

        ["centaur_khan_war_stomp"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("centaur_khan_war_stomp")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["ogre_magi_frost_armor"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("ogre_magi_frost_armor")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_ogre_magi_frost_armor"},  -- 不需要检查buff
                    0.5,  -- 不需要检查剩余时间
                    "nearest_to_enemy",  -- 优先给离敌人最近的友军释放
                    false,
                    true
                )
                
                return self.Ally ~= nil
            end
        },
        ["satyr_trickster_purge"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("satyr_trickster_purge")
                if not ability then return false end

                -- 先查找友方单位
                local potentialAlly = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "dispellable_debuffs",  -- 优先给有可驱散debuff最多的友军释放
                    false,
                    true
                )
                
                -- 检查友方目标是否存在，并且身上有可驱散的debuff
                if potentialAlly and potentialAlly:GetPurgableDebuffsCount() > 0 then
                    self.Ally = potentialAlly
                    self.skillTargetTeam["satyr_trickster_purge"] = DOTA_UNIT_TARGET_TEAM.FRIENDLY  
                    return true
                end
                
                -- 如果没有合适的友方单位，则查找敌方单位
                local potentialEnemy = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "dispellable_buffs",  -- 优先选择有可驱散buff最多的敌人
                    false
                )
                
                -- 检查敌方目标是否存在，并且身上有可驱散的buff
                if potentialEnemy and potentialEnemy:GetPurgableBuffsCount() > 0 then
                    self.target = potentialEnemy
                    self.skillTargetTeam["satyr_trickster_purge"] = DOTA_UNIT_TARGET_TEAM.ENEMY  
                    return true
                end
                
                -- 没有找到合适的目标，返回false
                return false
            end
        },
    },
    ["npc_dota_neutral_centaur_khan"] = {
        ["centaur_khan_war_stomp"] = {
            function(self, caster, log)                
                return self:NeedsModifierRefresh(self.target,{"modifier_stunned"}, 0.5)
            end
        },
    },
    ["npc_dota_hero_dragon_knight"] = {
        ["dragon_knight_dragon_tail"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("dragon_knight_dragon_tail")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },


    ["npc_dota_hero_spirit_breaker"] = {
        ["spirit_breaker_bulldoze"] = {
            function(self, caster, log)                
                return self:NeedsModifierRefresh(caster,{"modifier_spirit_breaker_bulldoze"}, 0.5)
            end
        },
        ["spirit_breaker_charge_of_darkness"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("spirit_breaker_charge_of_darkness")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        
        ["spirit_breaker_nether_strike"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("spirit_breaker_nether_strike")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },

    },
    ["npc_dota_hero_primal_beast"] = {
        ["primal_beast_trample"] = {
            function(self, caster, log)                
                return self:NeedsModifierRefresh(caster,{"modifier_primal_beast_trample"}, 0.5)
            end
        },
        ["primal_beast_uproar"] = {
            function(self, caster, log)
                local uproarBuff = caster:FindModifierByName("modifier_primal_beast_uproar")
                if uproarBuff then
                    if uproarBuff:GetStackCount() >= 5 or caster:GetHealthPercent()<50 then
                        return true
                    end
                end
                return false
            end
        },
        ["primal_beast_onslaught"] = {
            function(self, caster, log)
                -- 只记录蓄力开始时间
                local ability = caster:FindAbilityByName("primal_beast_onslaught")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                self.charge_start_time = GameRules:GetGameTime()
                return potentialTarget ~= nil

            end
        },
        ["primal_beast_pulverize"] = {
            function(self, caster, log)
                -- 检查是否在践踏状态且血量高于30%
                if caster:HasModifier("modifier_primal_beast_trample") and caster:GetHealthPercent() > 30 then
                    return false
                end

                local ability = caster:FindAbilityByName("primal_beast_pulverize")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["primal_beast_onslaught_release"] = {
            function(self, caster, log)
                -- 获取当前时间和位置
                local current_time = GameRules:GetGameTime()
                local current_position = caster:GetAbsOrigin()
                local target_position = self.target:GetAbsOrigin()
                
                -- 计算与目标的距离
                local distance = (target_position - current_position):Length2D()
                
                -- 以1200速度计算所需时间（秒）
                local required_time = distance / 1200
                
                -- 计算已蓄力时间
                local charge_time = current_time - self.charge_start_time
                
                -- 如果蓄力时间已经达到或略微超过所需时间，允许释放
                if charge_time >= required_time and charge_time <= required_time + 3 then
                    return true
                end
                
                return false
            end
        },

    },

    ["npc_dota_hero_ursa"] = {
        ["ursa_overpower"] = {
            function(self, caster, log)
                local forbiddenModifiers = {
                    "modifier_ursa_overpower",
                }
                return self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
            end
        },
        ["ursa_enrage"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "秒解控") then
                    if caster:IsStunned() then
                        self:log("处于眩晕状态，触发'秒解控'策略")
                        return true
                    end
                end

                return caster:GetHealthPercent()<50
            end
        },
    },

    ["npc_dota_hero_lycan"] = {
        ["lycan_wolf_bite"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("lycan_wolf_bite")
                if not ability then return false end
    
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "attack",  -- 按攻击力排序
                    true,    
                    false     -- 不允许选择自己
                )
    
                return self.Ally ~= nil
            end
        }
    },



    
    ["npc_dota_hero_meepo"] = {
        ["meepo_megameepo"] = {
            function(self, caster, log)
                -- 查找周围1000范围内的所有单位
                if self:containsStrategy(self.hero_strategy, "满血合体") then
                    return true
                end
                local nearbyUnits = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetOrigin(),
                    nil,
                    1000,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
    
                -- 遍历所有附近单位
                for _, unit in pairs(nearbyUnits) do
                    -- 检查单位是否是Meepo
                    if unit:GetUnitName() == "npc_dota_hero_meepo" then
                        -- 计算当前生命值百分比
                        local healthPercentage = unit:GetHealth() / unit:GetMaxHealth() * 100
    
                        -- 如果有任何Meepo单位生命值低于10%，返回true
                        if healthPercentage < 30 then
                            if log then 
                                self:log("Meepo unit found with health below 10%")
                            end
                            return true
                        end
                    end
                end
    
                -- 如果没有找到生命值低于10%的Meepo单位，返回false
                if log then 
                    self:log("No Meepo unit found with health below 10%")
                end
                return false
            end
        },
        ["meepo_petrify"] = {
            function(self, caster, log)
                return caster:GetHealthPercent()<50
            end
        },
    },
    ["npc_dota_hero_troll_warlord"] = {
        ["troll_warlord_battle_trance"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "秒解控") then
                    if caster:IsStunned() then

                        self:log("巨魔处于眩晕状态，触发'秒解控'策略")

                        return true
                    end
                elseif self:containsStrategy(self.hero_strategy, "出门开大") then
                    return true
                end

                return caster:GetHealthPercent()<20
            end
        },
    },

    ["npc_dota_hero_zuus"] = {
        ["zuus_heavenly_jump"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "对琼英碧灵专用") then
                    local heavenly_jump = caster:FindAbilityByName("zuus_heavenly_jump")
                    if heavenly_jump and self:IsSkillReady(heavenly_jump) then
                        return false
                    end
                end
                if self:containsStrategy(self.hero_strategy, "主动进攻") then
                    return true
                end
                
                if self.target then
                    local distance = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
                    local healthPercent = caster:GetHealthPercent()
                    
                    if distance < 200 or healthPercent < 20 then
                        return true
                    end
                end
                
                return false
            end
        },
    },

    ["npc_dota_hero_tidehunter"] = {
        ["tidehunter_ravage"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("tidehunter_ravage")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["tidehunter_dead_in_the_water"] = {
            function(self, caster, log)
                local challengeId = Main.currentChallenge
                print("当前挑战模式ID: " .. challengeId)
                local challengeName = Main:GetChallengeNameById(challengeId)
                if challengeName == "waterfall_hero_chaos" then
                    return false
                end




                local ability = caster:FindAbilityByName("tidehunter_dead_in_the_water")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil

            end
        },
    },

    
    ["npc_dota_hero_lina"] = {
        ["lina_laguna_blade"] = {
            function(self, caster, log)
                local isHealthLow = caster:GetHealthPercent()<80
                if isHealthLow then
                    self.highPrioritySkills.npc_dota_hero_lina = {"lina_laguna_blade"}
                else
                    self.highPrioritySkills.npc_dota_hero_lina = {}
                end
                return true
            end
        },
        ["lina_flame_cloak"] = {
            function(self, caster, log)
                local requiredModifiers = {"modifier_lina_flame_cloak"}
                return self:NeedsModifierRefresh(caster, requiredModifiers, 0.5)
            end
        },
        ["lina_light_strike_array"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("lina_light_strike_array")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },

    ["npc_dota_hero_chaos_knight"] = {
        ["chaos_knight_phantasm"] = {
            function(self, caster, log)
                -- 检查生命值是否低于20%
                if caster:GetHealthPercent()<20 then
                    return true
                end
    
                local chaos_bolt_ability = caster:FindAbilityByName("chaos_knight_chaos_bolt")
                
                if self:containsStrategy(self.hero_strategy, "先晕再大") then
                    if chaos_bolt_ability and chaos_bolt_ability:IsFullyCastable() then
                        return false
                    end
                end
    
                return true
            end
        },
        ["chaos_knight_reality_rift"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "刷沉默") then
                    local requiredModifiers = {"modifier_silence"}
                    return self:NeedsModifierRefresh(self.target, requiredModifiers, 0.5)
                else
                    return true
                end
            end
        },
        ["chaos_knight_chaos_bolt"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("chaos_knight_chaos_bolt")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },
    ["npc_dota_hero_bounty_hunter"] = {
        ["bounty_hunter_wind_walk_ally"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("bounty_hunter_wind_walk_ally")
                local castRange = self:GetSkillCastRange(caster, ability)
    
                local nearbyUnits = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetOrigin(),
                    nil,
                    castRange,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                    FIND_ANY_ORDER,
                    false
                )
    
                -- 遍历所有附近单位
                for _, unit in pairs(nearbyUnits) do
                    if unit ~= caster and unit:IsRealHero() then
                        if log then 
                            self:log("发现合适的友方英雄目标: " .. unit:GetUnitName())
                        end
                        return true
                    end
                end
    
                -- 如果没有找到合适的目标，返回false
                if log then 
                    self:log("施法范围内没有友方英雄")
                end
                return false
            end
        },
        ["bounty_hunter_wind_walk"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("bounty_hunter_wind_walk")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },

        ["bounty_hunter_track"] = {
            function(self, caster, log)

                local ability = caster:FindAbilityByName("bounty_hunter_track")
                if not ability then return false end

                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_bounty_hunter_track"},
                    0.5,
                    "distance",
                    true
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },

    },



    ["npc_dota_hero_shredder"] = {
        ["shredder_timber_chain"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("shredder_timber_chain")
                if not ability then
                    log("找不到伐木机的钩锁技能")
                    return false
                end
            
                local aoeRadius = self:GetSkillAoeRadius(ability)
                local castRange = self:GetSkillCastRange(caster, ability)
                local totalRange = aoeRadius + castRange
            
                local trees = GridNav:GetAllTreesAroundPoint(caster:GetAbsOrigin(), totalRange, true)
                local validTrees = {}
            
                for _, tree in pairs(trees) do
                    local treePos = tree:GetAbsOrigin()
                    local direction = (treePos - caster:GetAbsOrigin()):Normalized()
                    local endPos = caster:GetAbsOrigin() + direction * (treePos - caster:GetAbsOrigin()):Length2D()
            
                    local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
                    local targetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
                    local targetFlags = DOTA_UNIT_TARGET_FLAG_NONE
                    local enemies = FindUnitsInLine(
                        caster:GetTeamNumber(),
                        caster:GetAbsOrigin(),
                        endPos,
                        nil,
                        225,  -- 宽度225的矩形范围
                        targetTeam,
                        targetType,
                        targetFlags
                    )
            
                    if self.target and not self.target:IsDebuffImmune() then
                        local targetPos = self.target:GetAbsOrigin()
                        -- 使用向量计算来代替 IsPositionInLine 函数
                        local toTarget = targetPos - caster:GetAbsOrigin()
                        local projectionLength = toTarget:Dot(direction)
                        local projectionPoint = caster:GetAbsOrigin() + direction * projectionLength
                        local distanceFromLine = (targetPos - projectionPoint):Length2D()
                        
                        if projectionLength >= 0 and projectionLength <= (endPos - caster:GetAbsOrigin()):Length2D() and distanceFromLine <= 225/2 then
                            table.insert(validTrees, {tree = tree, distance = (treePos - caster:GetAbsOrigin()):Length2D()})
                        end
                    end
                end
            
                if #validTrees > 0 then
                    table.sort(validTrees, function(a, b) return a.distance < b.distance end)
                    log("已经为伐木机找到了最近的有效树木目标")
                    return true
                else
                    log("伐木机周围没有找到符合条件的树木")
                    return false
                end
            end
        },
        ["shredder_chakram"] = {
            function(self, caster, log)
                -- 记录圆锯释放时间
                self.chakram_start_time = GameRules:GetGameTime()
                return true
            end
        },
        ["shredder_return_chakram"] = {
            function(self, caster, log)
                -- 获取当前时间
                local current_time = GameRules:GetGameTime()
                
                -- 计算圆锯已飞行的时间
                local chakram_time = current_time - self.chakram_start_time
                
                -- 如果已经过了3秒，允许收回圆锯
                if chakram_time >= 3 then
                    return true
                end
                
                return false
            end
        },
    },



    ["npc_dota_hero_tiny"] = {
        ["tiny_toss"] = {
            function(self, caster, log)
                local searchRadius = 300
                local targetTeam = DOTA_UNIT_TARGET_TEAM_BOTH
                local targetType = DOTA_UNIT_TARGET_ALL
                local targetFlags = DOTA_UNIT_TARGET_FLAG_NONE
                local findOrder = FIND_ANY_ORDER
        
                log("小小投掷技能检查，搜索范围: " .. searchRadius)
        
                local units = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    searchRadius,
                    targetTeam,
                    targetType,
                    targetFlags,
                    findOrder,
                    false
                )
        
                local availableUnits = {}
                for _, unit in ipairs(units) do
                    if unit ~= caster and 
                       not unit:HasModifier("modifier_tiny_toss") and 
                       not unit:IsDebuffImmune() then
                        table.insert(availableUnits, unit)
                    end
                end
        
                if #availableUnits > 0 then
                    log("小小周围" .. searchRadius .. "码内发现可投掷单位，可以使用投掷")
                    return true
                else
                    if #units > 0 then
                        log("小小周围" .. searchRadius .. "码内的单位都不可投掷（可能已被投掷或处于debuff免疫状态），无法使用投掷")
                    else
                        log("小小周围" .. searchRadius .. "码内没有发现可投掷单位，无法使用投掷")
                    end
                    return false
                end
            end
        },
        ["tiny_toss_tree"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("tiny_toss_tree")
                if not ability then
                    log("找不到小小的投掷树木技能")
                    return false
                end
        
                local aoeRadius = self:GetSkillAoeRadius(ability)
                local castRange = self:GetSkillCastRange(caster, ability)
                local totalRange = aoeRadius + castRange
        
                local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
                local targetType = DOTA_UNIT_TARGET_HERO
                local targetFlags = DOTA_UNIT_TARGET_FLAG_NONE
                local findOrder = FIND_ANY_ORDER
        
                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    totalRange,
                    targetTeam,
                    targetType,
                    targetFlags,
                    findOrder,
                    false
                )
        
                for _, enemy in pairs(enemies) do
                    if enemy:IsRealHero() and enemy:IsAlive() then
                        local tinyAverageDamage = caster:GetAverageTrueAttackDamage(enemy) + 100
                        local enemyHealth = enemy:GetHealth()
                        if enemyHealth < tinyAverageDamage then
                            log(string.format("发现可击杀目标 %s，当前生命值 %d，小小对其的平均攻击力 %d", enemy:GetUnitName(), enemyHealth, tinyAverageDamage))
                            return true
                        end
                    end
                end
        
                log("未找到生命值低于小小平均攻击力的目标")
                return false
            end
        },

        ["tiny_tree_channel"] = {
            function(self, caster, log)
                local searchRadius = 700
                local trees = GridNav:GetAllTreesAroundPoint(caster:GetAbsOrigin(), searchRadius, true)
                
                if #trees > 0 then
                    log(string.format("小小周围 %d 码范围内发现树木，可以使用树木连掷", searchRadius))
                    return true
                else
                    log(string.format("小小周围 %d 码范围内没有发现树木，无法使用树木连掷", searchRadius))
                    return false
                end
            end
        },
        
        ["tiny_tree_grab"] = {
            function(self, caster, log)
                local searchRadius = 400
                local trees = GridNav:GetAllTreesAroundPoint(caster:GetAbsOrigin(), searchRadius, true)
                
                if #trees > 0 then
                    log(string.format("小小周围 %d 码范围内发现树木，可以使用树木抓取", searchRadius))
                    return true
                else
                    log(string.format("小小周围 %d 码范围内没有发现树木，无法使用树木抓取", searchRadius))
                    return false
                end
            end
        },
        ["tiny_avalanche"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("tiny_avalanche")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },
    ["npc_dota_hero_dark_willow"] = {
        ["dark_willow_pixie_dust"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "主动靠近作祟") then
                    return true
                else
                    local ability = caster:FindAbilityByName("dark_willow_pixie_dust")
                    local aoeRadius = self:GetSkillAoeRadius(ability)
                    
                    -- 搜索范围内的敌方单位
                    local enemies = FindUnitsInRadius(
                        caster:GetTeamNumber(),
                        caster:GetAbsOrigin(),
                        nil,
                        aoeRadius,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false
                    )
                    
                    -- 检查是否有非魔法免疫的敌方单位
                    for _, enemy in pairs(enemies) do
                        if not enemy:IsMagicImmune() then
                            log("范围内发现非魔法免疫的敌方单位，可以使用妖精之尘")
                            return true
                        end
                    end
                    
                    log("范围内没有可用目标，不使用妖精之尘")
                    return false
                end
            end
        },
    },

    
    ["npc_dota_templar_assassin_psionic_trap"] = {
        ["templar_assassin_self_trap"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "陷阱不自动引爆") then
                    return false
                else
                    return true
                end
            end
        },
    },

    ["npc_dota_hero_furion"] = {
        ["furion_force_of_nature"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("furion_force_of_nature")
                local searchRadius = math.max(400, self:GetSkillCastRange(caster, ability))
                local trees = GridNav:GetAllTreesAroundPoint(caster:GetAbsOrigin(), searchRadius, true)
                
                if #trees > 0 then
                    log(string.format("先知周围 %d 码范围内发现树木，可以使用召唤树人", searchRadius))
                    return true
                else
                    log(string.format("先知周围 %d 码范围内没有发现树木，无法使用召唤树人", searchRadius))
                    return false
                end
            end
        },
        ["furion_wrath_of_nature"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("furion_wrath_of_nature")
                if not ability then return false end

                -- 寻找血量百分比最低的目标
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "distance"
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                    return true
                end
                return false
            end
        },
    },

    ["npc_dota_hero_wisp"] = {
        ["wisp_tether"] = {
            function(self, caster, log)
                local forbiddenModifiers = {
                    "modifier_wisp_tether",
                }
                if not self:IsNotUnderModifiers(caster, forbiddenModifiers, log) then
                    return false
                end


                local ability = caster:FindAbilityByName("wisp_tether")
                if not ability then return false end
    
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,  -- 不需要检查buff
                    nil,  -- 不需要检查剩余时间
                    "health_percent"  -- 优先给血量百分比最低的友军
                )
                
                return self.Ally ~= nil
            end
        },
        ["wisp_spirits"] = {
            function(self, caster, log)
                -- 检查是否有神杖
                if caster:HasScepter() then
                    -- 计算生命值百分比
                    local healthPercent = caster:GetHealthPercent()
                    if healthPercent < 30 then
                        log("有神杖且生命值低于20%(" .. healthPercent .. "%)，开启小精灵")
                        return true
                    else
                        log("有神杖但生命值高于20%(" .. healthPercent .. "%)，不开启小精灵")
                        return false
                    end
                else
                    log("没有神杖，直接开启小精灵")
                    return true
                end
            end
        },
        ["wisp_tether_break"] = {
            function(self, caster, log)
                return false
            end
        },
        ["wisp_spirits_in"] = {
            function(self, caster, log)
                if not self.target then
                    return false
                end

                local distance = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
                local ability = caster:FindAbilityByName("wisp_spirits_in")
                local currentState = ability:GetToggleState()
                
                -- 如果距离小于330，需要保持in开启
                if distance < 520 then
                    if not currentState then
                        log("目标距离" .. distance .. "小于330，需要开启in")
                        return true
                    end
                -- 如果距离在330-550之间，需要交替切换
                elseif distance <= 460 then
                    -- 初始化上次切换时间
                    self.lastSpiritToggleTime = self.lastSpiritToggleTime or GameRules:GetGameTime()
                    
                    -- 检查是否已经过了1秒
                    if GameRules:GetGameTime() - self.lastSpiritToggleTime >= 1.0 then
                        -- 如果out是开启状态，我们就开启in
                        local outAbility = caster:FindAbilityByName("wisp_spirits_out")
                        if outAbility:GetToggleState() then
                            log("目标在中间距离" .. distance .. "，切换到in")
                            self.lastSpiritToggleTime = GameRules:GetGameTime()
                            return true
                        end
                    end
                end
                
                return false
            end
        },
        ["wisp_spirits_out"] = {
            function(self, caster, log)
                if not self.target then
                    return false
                end

                local distance = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
                local ability = caster:FindAbilityByName("wisp_spirits_out")
                local currentState = ability:GetToggleState()
                
                -- 如果距离大于550，需要保持out开启
                if distance > 520 then
                    if not currentState then
                        log("目标距离" .. distance .. "大于550，需要开启out")
                        return true
                    end
                -- 如果距离在330-550之间，需要交替切换
                elseif distance >= 330 then
                    -- 初始化上次切换时间
                    self.lastSpiritToggleTime = self.lastSpiritToggleTime or GameRules:GetGameTime()
                    
                    -- 检查是否已经过了1秒
                    if GameRules:GetGameTime() - self.lastSpiritToggleTime >= 1.0 then
                        -- 如果in是开启状态，我们就开启out
                        local inAbility = caster:FindAbilityByName("wisp_spirits_in")
                        if inAbility:GetToggleState() then
                            log("目标在中间距离" .. distance .. "，切换到out")
                            self.lastSpiritToggleTime = GameRules:GetGameTime()
                            return true
                        end
                    end
                end
                
                return false
            end
        },
    },

    ["npc_dota_hero_necrolyte"] = {
        ["necrolyte_ghost_shroud"] = {
            function(self, caster, log)
                local requiredModifiers = {"modifier_necrolyte_ghost_shroud_active"}
                local healthRegen = caster:GetHealthRegen()
                return self:NeedsModifierRefresh(caster, requiredModifiers, 0.5) and 
                       (caster:GetHealthPercent()<50 or healthRegen >= 50)
            end
        },
        ["necrolyte_reapers_scythe"] = {
            function(self, caster, log)
                -- 先获取死神镰刀技能
                local ability = caster:FindAbilityByName("necrolyte_reapers_scythe")
                if not ability then return false end

                -- 寻找血量百分比最低的目标
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {},
                    0,
                    "health_percent",
                    true
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                if self:containsStrategy(self.hero_strategy, "满血直接斩") then
                    return potentialTarget ~= nil
                else
                    if caster:GetHealthPercent() >= 50 and (not self.target or self.target:GetHealthPercent() >= 50) then
                        return false
                    else
                        return potentialTarget ~= nil
                    end
                end
            end
        },
    },


    ["npc_dota_hero_drow_ranger"] = {
        ["drow_ranger_wave_of_silence"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("drow_ranger_wave_of_silence")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_drowranger_wave_of_silence"},
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },

    ["npc_dota_hero_hoodwink"] = {
        ["hoodwink_bushwhack"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("hoodwink_bushwhack")
                if not ability then
                    return false
                end
            
                local castRange =  self:GetSkillCastRange(caster, ability)
                local aoeRadius =  self:GetSkillAoeRadius(ability)
                local searchRange = castRange
            
                if bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
                    searchRange = castRange + aoeRadius
                    log("技能为点目标类型，搜索范围: " .. searchRange)
                else
                    log("技能非点目标类型，搜索范围: " .. searchRange)
                end
            
                if self:containsStrategy(self.global_strategy, "防守策略") then
                    searchRange = 3000
                end
        
                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetOrigin(),
                    nil,
                    searchRange,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    0,
                    FIND_ANY_ORDER,
                    false
                )
                
                for _, enemy in pairs(enemies) do
                    if enemy:IsHero() and not enemy:IsSummoned() and self:NeedsModifierRefresh(enemy,{"modifier_hoodwink_bushwhack_trap"}, 1.2) then
                        -- 检查敌人265范围内是否有树木
                        local nearbyTrees = GridNav:GetAllTreesAroundPoint(enemy:GetAbsOrigin(), 265, false)
                        if #nearbyTrees > 0 then
                            log("找到合适的英雄目标且附近有树木: " .. enemy:GetUnitName())
                            return true
                        end
                    end
                end
            
                log("没有找到合适的英雄目标")
                return false
            end
        },
        ["hoodwink_scurry"] = {
            function(self, caster, log)
                local requiredModifiers = {"modifier_hoodwink_scurry_active"}
                return self:NeedsModifierRefresh(caster, requiredModifiers, 0.5)
            end
        },
        ["hoodwink_sharpshooter_release"] = {
            function(self, caster, log)
                local requiredModifiers = {"modifier_hoodwink_sharpshooter_windup"}
                return self:NeedsModifierRefresh(caster, requiredModifiers, 2.75)
            end
        },


        ["hoodwink_acorn_shot"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "必须弹射栗子") then
                    local ability = caster:FindAbilityByName("hoodwink_acorn_shot")
                    if ability and ability:GetCurrentAbilityCharges() == 1 then
                        local enemies = FindUnitsInRadius(
                            caster:GetTeamNumber(),
                            self.target:GetAbsOrigin(),
                            nil,
                            550,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_ANY_ORDER,
                            false
                        )
                        
                        -- 如果目标周围550范围内只有目标一个敌人,返回false
                        if #enemies <= 0 then
                            log("敌人数量小于1")
                            return false
                        end
                    end
                end
                
                -- 其他所有情况返回true
                return true
            end
        },
    },

    ["npc_dota_hero_abaddon"] = {
        ["abaddon_aphotic_shield"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("abaddon_aphotic_shield")
                if not ability then return false end
        
                if self:containsStrategy(self.hero_strategy, "无限续盾") then
                    self.Ally = self:FindBestAllyHeroTarget(
                        caster,
                        ability,
                        {},
                        0,
                        "health_percent"
                    )
                    return self.Ally ~= nil
                else
                    self.Ally = self:FindBestAllyHeroTarget(
                        caster,
                        ability, 
                        {"modifier_abaddon_aphotic_shield"},
                        0.5,
                        "health_percent"
                    )
                    return self.Ally ~= nil
                end
            end
        },
        ["abaddon_borrowed_time"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "手动开大") then
                    local requiredModifiers = {"modifier_abaddon_borrowed_time"}
                    return self:NeedsModifierRefresh(caster, requiredModifiers, 0.5)
                else
                    return false
                end
            end
        },


    },
    -- ["npc_dota_hero_undying"] = {
    --     ["undying_tombstone"] = {
    --         function(self, caster, log)
    --             local ability = caster:FindAbilityByName("undying_tombstone")
    --             if not ability then return false end
    
    --             self.Ally = self:FindBestAllyHeroTarget(
    --                 caster,
    --                 ability,
    --                 nil,
    --                 nil,
    --                 "health_percent" -- 优先给血量百分比最低的友军
    --             )
                
    --             return self.Ally and self.Ally:GetHealthPercent() < 50 -- 血量低于50%才施放
    --         end
    --     },
    
    --     ["undying_soul_rip"] = {
    --         function(self, caster, log)
    --             local ability = caster:FindAbilityByName("undying_soul_rip")
    --             if not ability then return false end
    
    --             self.Ally = self:FindBestAllyHeroTarget(
    --                 caster,
    --                 ability,
    --                 nil,
    --                 nil,
    --                 "health_percent" -- 优先给血量百分比最低的友军
    --             )
                
    --             return self.Ally and self.Ally:GetHealthPercent() < 50 -- 血量低于50%才施放
    --         end
    --     },
    -- },

    ["npc_dota_hero_slark"] = {
        ["slark_shadow_dance"] = {
            function(self, caster, log)
                local requiredModifiers = {"modifier_slark_shadow_dance","modifier_slark_depth_shroud"}
                if self:containsStrategy(self.hero_strategy, "出门直接放大") then
                    return self:NeedsModifierRefresh(caster, requiredModifiers, 0.2)
                else 
                    return self:NeedsModifierRefresh(caster, requiredModifiers, 0.2) and caster:GetHealthPercent() < 50 
                end
            end
        },
        ["slark_depth_shroud"] = {
            function(self, caster, log)
                local requiredModifiers = {"modifier_slark_shadow_dance","modifier_slark_depth_shroud"}
                local ability = caster:FindAbilityByName("slark_depth_shroud")
                if not ability then return false end
                
                -- 检查是否有魔晶只给自己策略
                if self:containsStrategy(self.hero_strategy, "魔晶只给自己") then
                    -- 检查自身生命值
                    if caster:GetHealthPercent() < 50 then
                        self.Ally = caster
                        return self:NeedsModifierRefresh(caster, requiredModifiers, 0.2)
                    end
                    return false
                end
                
                -- 检查是否有出门直接放大策略
                if self:containsStrategy(self.hero_strategy, "出门直接放大") then
                    self.Ally = self:FindBestAllyHeroTarget(
                        caster,
                        ability,
                        {"modifier_slark_shadow_dance","modifier_slark_depth_shroud"},
                        0.2,
                        "health_percent"
                    )
                    return self.Ally ~= nil
                else
                    -- 默认策略:血量低于50%且需要刷新buff时施放
                    self.Ally = self:FindBestAllyHeroTarget(
                        caster,
                        ability,
                        {"modifier_slark_shadow_dance","modifier_slark_depth_shroud"},
                        0.2,
                        "health_percent"
                    )
                    return self.Ally and self.Ally:GetHealthPercent() < 50
                end
            end
        },
        ["slark_pounce"] = {
            function(self, caster, log)

                local essenceShiftCount = self:CountModifiers(caster, "modifier_slark_essence_shift_buff")
                    
                -- 检查周围300码内的敌人数量
                local nearbyEnemies = GetRealEnemyHeroesWithinDistance(caster, 300, log)

                if self:containsStrategy(self.hero_strategy, "100层后不用跳") then
                    if essenceShiftCount > 100 and nearbyEnemies > 0 then
                        return false
                    else
                        return true
                    end

                elseif self:containsStrategy(self.hero_strategy, "200层后不用跳") then
                    if essenceShiftCount > 200 and nearbyEnemies > 0 then
                        return false
                    else
                        return true
                    end
                else
                    return true
                end
            end
        },
    },


    ["npc_dota_hero_phantom_lancer"] = {
        ["phantom_lancer_doppelwalk"] = {
            function(self, caster, log)
                -- 检查1000码范围内的单位
                local units = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    1000,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                
                local illusion_count = 0
                for _, unit in pairs(units) do
                    -- 检查单位是否是幻象且与施法者同名
                    if unit:IsIllusion() and unit:GetName() == caster:GetName() then
                        illusion_count = illusion_count + 1
                    end
                end
                
                log("幻影长矛手幻象数量: " .. illusion_count)
                
                -- 如果幻象数量超过20个，返回false，否则返回true
                if illusion_count > 100 then
                    log("幻象数量超过20，不使用幻影突袭")
                    return false
                else
                    log("幻象数量不超过20，可以使用幻影突袭")
                    return true
                end
            end
        },
        ["phantom_lancer_juxtapose"] = {
            function(self, caster, log)
                -- 检查1000码范围内的单位
                local units = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    1000,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                
                local illusion_count = 0
                for _, unit in pairs(units) do
                    -- 检查单位是否是幻象且与施法者同名
                    if unit:IsIllusion() and unit:GetName() == caster:GetName() then
                        illusion_count = illusion_count + 1
                    end
                end
                
                log("幻影长矛手幻象数量: " .. illusion_count)
                
                -- 如果幻象数量超过20个，返回false，否则返回true
                if illusion_count > 100 then
                    log("幻象数量超过20，不使用幻影突袭")
                    return false
                else
                    log("幻象数量不超过20，可以使用幻影突袭")
                    return true
                end
            end
        },


    },
    ["npc_dota_hero_enigma"] = {
        ["enigma_demonic_conversion"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "小谜团上限") then
                    -- 检查1000码范围内的单位
                    local units = FindUnitsInRadius(
                        caster:GetTeamNumber(),
                        caster:GetAbsOrigin(),
                        nil,
                        1000,
                        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                        DOTA_UNIT_TARGET_ALL,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false
                    )
                    
                    local eidolon_count = 0
                    for _, unit in pairs(units) do
                        -- 检查单位名字是否包含eidolon
                        if string.find(unit:GetUnitName(), "eidolon") then
                            eidolon_count = eidolon_count + 1
                        end
                    end
                    
                    log("谜团小兵数量: " .. eidolon_count)
                    
                    -- 如果谜团小兵数量超过30个，返回false，否则返回true
                    if eidolon_count > 30 then
                        log("谜团小兵数量超过30，不使用转化")
                        return false
                    else
                        log("谜团小兵数量不超过30，可以使用转化")
                        return true
                    end
                elseif self:containsStrategy(self.hero_strategy, "招到80%血") then
                    if not caster:GetHealthPercent()<80 then
                        return true
                    else
                        return false
                    end
                end
                return true
            end
        },
        ["enigma_malefice"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("enigma_malefice")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["enigma_black_hole"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("enigma_black_hole")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_enigma_black_hole_pull"},
                    0,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        
    },

    ["npc_dota_hero_invoker"] = {
        ["invoker_alacrity"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("invoker_alacrity")
                if not ability then return false end
                
                if self:containsStrategy(self.hero_strategy, "灵动迅捷优先给队友") then
                    -- 先尝试找队友单位
                    self.Ally = self:FindBestAllyHeroTarget(
                        caster,
                        ability,
                        {"modifier_invoker_alacrity"},
                        0.5,
                        "attack", 
                        false,
                        false
                    )
                    
                    -- 如果找到了队友单位就直接返回
                    if self.Ally then
                        return true
                    end
                end
        
                -- 如果策略判断不通过或者没找到队友单位,按原来的逻辑执行
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_invoker_alacrity"},
                    0.5,
                    "attack",
                    false,
                    true
                )
                
                return self.Ally ~= nil
            end
        },
        ["invoker_sun_strike"] = {
            function(self, caster, log)
                -- 默认行为（非英雄目标）
                if not self.target:IsHero() then
                    self.skillBehavior["invoker_sun_strike"] = DOTA_ABILITY_BEHAVIOR.POINT
                    self.skillTargetTeam["invoker_sun_strike"] = DOTA_UNIT_TARGET_TEAM.ENEMY
                -- 英雄目标且拥有神杖
                elseif self.target:IsHero() and caster:HasScepter() then
                    self.skillBehavior["invoker_sun_strike"] = DOTA_ABILITY_BEHAVIOR.UNIT_TARGET
                    self.skillTargetTeam["invoker_sun_strike"] = DOTA_UNIT_TARGET_TEAM.FRIENDLY
                end
                
                -- 原有的 modifier 刷新检查
                return self:NeedsModifierRefresh(self.target, {"modifier_invoker_deafening_blast_knockback"}, 1.2) 
                       and self:NeedsModifierRefresh(self.target, {"modifier_invoker_tornado"}, 1.5)
            end
        },

        ["invoker_emp"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("invoker_emp")
                if not ability then return false end
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "distance",
                    true
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },


        
        ["invoker_tornado"] = {
            function(self, caster, log)
                -- 检查是否在过去2秒内释放过以下技能
                local checkTime = 2.0  -- 检查的时间范围(秒)
                local forbiddenAbilities = {
                    "invoker_chaos_meteor",
                    "invoker_sun_strike",
                    "invoker_deafening_blast"
                }
                
                -- 获取英雄的EntityIndex
                local heroIndex = caster:GetEntityIndex()
                
                -- 检查全局变量是否存在
                if Main and Main.heroLastCastAbility and Main.heroLastCastAbility[heroIndex] then
                    local currentTime = GameRules:GetGameTime()
                    
                    -- 检查是否在过去指定时间内释放过禁止的技能
                    for _, abilityName in pairs(forbiddenAbilities) do
                        local abilityData = Main.heroLastCastAbility[heroIndex][abilityName]
                        if abilityData and (currentTime - abilityData.time) <= checkTime then
                            if log then
                                log(string.format("2秒内释放过技能 %s，禁止释放龙卷风", abilityName))
                            end
                            return false
                        end
                    end
                end
                
                return true
            end
        },

        ["invoker_chaos_meteor"] = {
            function(self, caster, log)
                -- 检查是否在过去1秒内释放过龙卷风
                local heroIndex = caster:GetEntityIndex()
                if Main and Main.heroLastCastAbility and Main.heroLastCastAbility[heroIndex] then
                    local currentTime = GameRules:GetGameTime()
                    local tornadoData = Main.heroLastCastAbility[heroIndex]["invoker_tornado"]
                    if tornadoData and (currentTime - tornadoData.time) <= 1.0 then
                        if log then
                            log("1秒内释放过龙卷风，禁止释放")
                        end
                        return false
                    end
                end
                
                return self:NeedsModifierRefresh(self.target, {"modifier_invoker_tornado"}, 0.5)
            end
        },
        ["invoker_deafening_blast"] = {
            function(self, caster, log)
                -- 检查是否在过去1秒内释放过龙卷风
                local heroIndex = caster:GetEntityIndex()
                if Main and Main.heroLastCastAbility and Main.heroLastCastAbility[heroIndex] then
                    local currentTime = GameRules:GetGameTime()
                    local tornadoData = Main.heroLastCastAbility[heroIndex]["invoker_tornado"]
                    if tornadoData and (currentTime - tornadoData.time) <= 1.0 then
                        if log then
                            log("1秒内释放过龙卷风，禁止释放")
                        end
                        return false
                    end
                end
                
                return self:NeedsModifierRefresh(self.target, {"modifier_invoker_tornado"}, 0)
            end
        },
    },
    ["npc_dota_hero_slardar"] = {
        ["slardar_amplify_damage"] = {
            function(self, caster, log)

                local ability = caster:FindAbilityByName("slardar_slithereen_crush")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_slardar_amplify_damage"},
                    0.5,
                    "distance",  
                    false      -- 只允许英雄单位
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
                
                return potentialTarget ~= nil

            end
        },
        ["slardar_slithereen_crush"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("slardar_slithereen_crush")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },

    ["npc_dota_hero_magnataur"] = {
        ["magnataur_empower"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("magnataur_empower")
                if not ability then return false end
        
                if caster:GetHeroFacetID() == 3 then
                    self.Ally = self:FindBestAllyHeroTarget(
                        caster,
                        ability,
                        {"modifier_magnataur_empower"},
                        0.5,
                        "attack",
                        true,
                        false
                    )
                else
                    self.Ally = self:FindBestAllyHeroTarget(
                        caster,
                        ability,
                        {"modifier_magnataur_empower"},
                        0.5,
                        "attack"
                    )
                end
                
                return self.Ally ~= nil
            end
        },
        ["magnataur_reverse_polarity"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("magnataur_reverse_polarity")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },

    ["npc_dota_hero_legion_commander"] = {
        ["legion_commander_duel"] = {
            function(self, caster, log)
                local forbiddenModifiers = {
                    "modifier_legion_commander_duel",
                }
                return self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
            end
        },
        ["legion_commander_press_the_attack"] = {
            function(self, caster, log)
                local forbiddenModifiers = {
                    "modifier_legion_commander_duel",
                }
                if not self:IsNotUnderModifiers(caster, forbiddenModifiers, log) then 
                    return false
                end
        
                local ability = caster:FindAbilityByName("legion_commander_press_the_attack")
                if not ability then return false end
        
                if self:containsStrategy(self.hero_strategy, "续魔免") then
                    self.Ally = self:FindBestAllyHeroTarget(
                        caster,
                        ability,
                        {"modifier_legion_commander_press_the_attack_immunity"},
                        0.3,
                        "health"
                    )
                    if self.Ally then
                        if self:containsStrategy(self.hero_strategy, "满血强攻") then
                            return true
                        elseif self.Ally:GetHealthPercent() < 95 then
                            return true
                        end
                    end
                else
                    self.Ally = self:FindBestAllyHeroTarget(
                        caster,
                        ability,
                        {"modifier_legion_commander_press_the_attack"},
                        0.5,
                        "health"
                    )
                    if self.Ally then
                        if self:containsStrategy(self.hero_strategy, "满血强攻") then
                            return true
                        elseif self.Ally:GetHealthPercent() < 95 then
                            return true
                        end
                    end
                end
        
                return false
            end
        },
    },
    ["npc_dota_hero_clinkz"] = {
        ["clinkz_death_pact"] = {
            function(self, caster, log)
                local buffName = "modifier_clinkz_death_pact"
                local hasBuff = caster:HasModifier(buffName)
                
                -- 获取死亡契约技能
                local ability = caster:FindAbilityByName("clinkz_death_pact")
                if not ability then
                    if log then
                        log("找不到死亡契约技能")
                    end
                    return false
                end
                
                local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
                DOTA_UNIT_TARGET_FLAG_INVULNERABLE + 
                DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD +
                DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
                
                -- 获取施法范围
                local radius = self:GetSkillCastRange(caster, ability) + 200
                local team = caster:GetTeam()
                local position = caster:GetAbsOrigin()
                local units = FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, flags, FIND_CLOSEST, false)
                
                -- 获取施法者的玩家ID
                local casterPlayerId = caster:GetPlayerOwnerID()
                
                -- 查找属于同一玩家的骨弓兵
                local found = false
                for _, unit in pairs(units) do
                    if unit:GetUnitName() == "npc_dota_clinkz_skeleton_archer" and unit:GetPlayerOwnerID() == casterPlayerId then
                        self.Ally = unit
                        found = true
                        break
                    end
                end
                
                if not found then
                    if log then
                        log("范围内没有找到自己的骨弓兵")
                    end
                    return false
                end
                
                -- 后续判断逻辑
                if not hasBuff then
                    if log then
                        log("骨弓没有死亡契约buff，可以使用技能")
                    end
                    return true
                else
                    if caster:GetHealthPercent() < 50 then
                        if log then
                            log("骨弓有死亡契约buff，但生命值低于20%，可以使用技能")
                        end
                        return true
                    else
                        if log then
                            log("骨弓有死亡契约buff，且生命值不低于20%，不使用技能")
                        end
                        return false
                    end
                end
            end
        },
        ["clinkz_tar_bomb"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "禁用焦油") then
                    return false
                end

                local ability = caster:FindAbilityByName("clinkz_tar_bomb")
                if not ability then
                    return false
                end
            
                local castRange =  self:GetSkillCastRange(caster, ability)
                local aoeRadius =  self:GetSkillAoeRadius(ability)
                local searchRange = castRange
            
                if bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 then
                    searchRange = castRange + aoeRadius
                    log("技能为点目标类型，搜索范围: " .. searchRange)
                else
                    log("技能非点目标类型，搜索范围: " .. searchRange)
                end
            
                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetOrigin(),
                    nil,
                    searchRange,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    0,
                    FIND_ANY_ORDER,
                    false
                )
                
                for _, enemy in pairs(enemies) do
                    if enemy:IsHero() and not enemy:IsSummoned() and self:NeedsModifierRefresh(enemy,{"modifier_clinkz_tar_bomb_slow"}, 0) then
                        log("找到合适的英雄目标: " .. enemy:GetUnitName())
                        return true
                    end
                end
            
                log("没有找到合适的英雄目标")
                return false


            end
        },
        
    },

    ["npc_dota_hero_terrorblade"] = {
        ["terrorblade_sunder"] = {
            function(self, caster, log)
                return caster:GetHealthPercent()<30
            end
        },
        ["terrorblade_terror_wave"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "满血开恐惧") then
                    return true
                end
                local ability = caster:FindAbilityByName("terrorblade_terror_wave")
                if not ability then
                    return false
                end
                -- 如果target没有大招modifier，按原逻辑执行
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_terrorblade_fear"},
                    0.5,
                    "control" 
                )

                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil and caster:GetHealthPercent()<50

            end
        }
    },
    ["npc_dota_hero_puck"] = {
        ["puck_phase_shift"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "相位转移打伤害") then
                    return true
                end

                return caster:GetHealthPercent()<80
            end
        },
        ["puck_illusory_orb"] = {
            function(self, caster, log)
                -- 记录魔法球释放时间
                self.orb_start_time = GameRules:GetGameTime()
                return true
            end
        },
        ["puck_ethereal_jaunt"] = {
            function(self, caster, log)
                -- 首先判断技能是否可用
                local ability = caster:FindAbilityByName("puck_ethereal_jaunt")
                if not ability or not ability:IsActivated() then
                    return false
                end
        
                -- 获取当前时间
                local current_time = GameRules:GetGameTime()
                
                -- 计算魔法球已飞行的时间
                local orb_time = current_time - self.orb_start_time
                
                -- 如果在2-3.5秒之间，允许跳跃
                if orb_time >= 2 and orb_time <= 3.5 then
                    return true
                end
                
                return false
            end
        },
    },
    ["npc_dota_hero_dawnbreaker"] = {
        ["dawnbreaker_solar_guardian"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "满血开大") then
                    self.Ally = caster
                    return true
                end


                local ability = caster:FindAbilityByName("dawnbreaker_solar_guardian")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "health_percent"
                )
        
                return self.Ally and self.Ally:GetHealthPercent() < 50
            end
        },
        ["dawnbreaker_land"] = {
            function(self, caster, log)
                return false
            end
        },
    },
    ["npc_dota_hero_witch_doctor"] = {
        ["witch_doctor_voodoo_switcheroo"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "满血开魔晶") then
                    return true
                end
                return caster:GetHealthPercent() < 50
            end
        }
    },

    ["npc_dota_hero_sniper"] = {
        ["sniper_shrapnel"] = {
            function(self, caster, log)
                -- 获取当前时间
                local current_time = GameRules:GetGameTime()
                local heroIndex = caster:GetEntityIndex()
                
                -- 获取上次释放时间
                local last_cast_info = Main.heroLastCastAbility 
                    and Main.heroLastCastAbility[heroIndex] 
                    and Main.heroLastCastAbility[heroIndex]["sniper_shrapnel"]
                local last_time = last_cast_info and last_cast_info.time or 0
                
                -- 如果是首次释放或者距离上次释放超过1秒
                if not last_cast_info or (current_time - last_time) > 1 then
                    return true
                end
                
                return false
            end
        }
    },

    ["npc_dota_hero_kez"] = {
        ["kez_falcon_rush"] = {
            function(self, caster, log)
                return self:NeedsModifierRefresh(caster, {"modifier_kez_falcon_rush"}, 0.5)
            end
        },


        ["kez_echo_slash"] = {
            function(self, caster, log)
                -- 获取施法者到目标的方向向量
                if self:containsStrategy(self.hero_strategy, "禁用回音重斩") then 
                    return false
                end


                local dirToTarget = (self.target:GetOrigin() - caster:GetOrigin()):Normalized()
                -- 获取施法者的朝向向量
                local forward = caster:GetForwardVector()
                -- 计算两个向量的点积
                local dotProduct = forward.x * dirToTarget.x + forward.y * dirToTarget.y
                -- 如果点积大于0，说明目标在前方
                return dotProduct > 0
            end
        },
        ["kez_shodo_sai_parry_cancel"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "招架秒取消") then
                    return true
                end
                return not self:IsNotUnderModifiers(self.target,{"modifier_bashed"}, log)
            end
        },
        ["kez_switch_weapons"] = {
            function(self, caster, log)
                local abilities = {
                    "kez_echo_slash",
                    "kez_grappling_claw", 
                    "kez_kazurai_katana",
                    "kez_raptor_dance",
                    "kez_falcon_rush",
                    "kez_talon_toss",
                    "kez_shodo_sai",
                    "kez_ravens_veil"
                }

                if self:containsStrategy(self.hero_strategy, "禁用单刀三技能") then
                    table.remove(abilities, 3)
                end



                
                local allDisabled = true
                for _, abilityName in ipairs(abilities) do
                    local ability = caster:FindAbilityByName(abilityName)
                    if ability and ability:IsHidden() then
                        if ability:IsCooldownReady() and ability:GetManaCost(ability:GetLevel()) <= caster:GetMana() then
                            allDisabled = false
                            break
                        end
                    end
                end
                
                if allDisabled then
                    -- 检查是否满足"无技能时保持双钗"策略
                    if self:containsStrategy(self.hero_strategy, "无技能时保持双钗") then
                        -- 检查kez_falcon_rush是否处于隐藏状态
                        local falcon_rush = caster:FindAbilityByName("kez_falcon_rush")
                        if falcon_rush and falcon_rush:IsHidden() then
                            return true
                        end
                    end
                    return false
                end

                if self:containsStrategy(self.hero_strategy, "冲刺后不切形态") then
                    local dance_ability = caster:FindAbilityByName("kez_raptor_dance")
                    
                    -- 检查dance技能的条件
                    if dance_ability and not dance_ability:IsCooldownReady() then
                        -- 如果dance技能存在但在冷却中，使用原来的逻辑
                        return self:IsNotUnderModifiers(caster,{"modifier_kez_falcon_rush"}, log)
                    end
            
                    -- 检查血量条件
                    local healthThreshold = self:containsStrategy(self.hero_strategy, "半血开大") and 50 or 100
                    local isDanceConditionMet = caster:GetHealthPercent()<healthThreshold
            
                    if isDanceConditionMet and dance_ability and dance_ability:IsCooldownReady() then
                        -- 如果满足dance条件且技能存在且不在冷却，返回true
                        return true
                    else
                        -- 其他情况检查rush技能和modifier
                        local rush_ability = caster:FindAbilityByName("kez_falcon_rush")
                        return self:IsNotUnderModifiers(caster,{"modifier_kez_falcon_rush"}, log) or 
                            (rush_ability and rush_ability:IsHidden())

                    end
                elseif self:containsStrategy(self.hero_strategy, "拖延") then
                    local raptorDance = caster:FindAbilityByName("kez_raptor_dance")
                    -- 如果猛禽之舞在冷却中，直接返回true
                    if raptorDance and not raptorDance:IsCooldownReady() then
                        return true
                    end

                    local talonToss = caster:FindAbilityByName("kez_talon_toss")

                    if self.target:HasModifier("modifier_ursa_enrage") then
                        if talonToss and not talonToss:IsHidden() then
                            return false
                        end
                    else
                        if talonToss and 
                           not talonToss:IsHidden() and 
                           talonToss:IsCooldownReady() then
                            return false
                        end
                    end
                    
                    return true

                else
                    return true
                end
            end
        },
        ["kez_raptor_dance"] = {
            function(self, caster, log)
                -- 设置血量阈值



                local healthThreshold
                if self:containsStrategy(self.hero_strategy, "半血开大") then
                    healthThreshold = 50
                elseif self:containsStrategy(self.hero_strategy, "丝血开大") then
                    healthThreshold = 30
                else
                    healthThreshold = 100
                end
        
                -- 判断血量条件
                if caster:GetHealthPercent() >= healthThreshold then
                    return false
                end
        
                -- 判断沉默接大的条件
                if self:containsStrategy(self.hero_strategy, "沉默接大") then
                    -- 检查目标是否没有被沉默且不在狂暴下
                    if not self.target:IsSilenced() or self.target:HasModifier("modifier_ursa_enrage") then
                        return false
                    end
                end
                return true
            end
        },
        ["kez_talon_toss"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "禁用沉默") then
                    return false
                end
                if self:containsStrategy(self.hero_strategy, "沉默接大") then
                    local raptorDance = caster:FindAbilityByName("kez_raptor_dance")
                
                    -- 如果猛禽之舞在冷却中，直接返回true
                    if raptorDance and not raptorDance:IsCooldownReady() then
                        return true
                    end
                    -- 检查目标是否没有被沉默且不在狂暴下
                    if self.target:HasModifier("modifier_ursa_enrage") then
                        return false
                    else
                        return true
                    end
                end
                return true
            end
        },
        ["kez_kazurai_katana"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "标记暴击") then
                    -- 检查目标是否没有被沉默且不在狂暴下
                    if self.target:HasModifier("modifier_kez_shodo_sai_mark")then
                        return true
                    else
                        return false
                    end
                end
                if self:containsStrategy(self.hero_strategy, "禁用单刀三技能") then
                    return false
                end
                return true
            end
        },
        ["kez_ravens_veil"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "禁用隐身大招") then
                    return false
                end



                if self:containsStrategy(self.hero_strategy, "驱散禁锢") then
                    -- 检查目标是否被禁锢
                    if caster:IsRooted() then
                        return true
                    else
                        return false
                    end
                end
                return true
            end
        }
    },

    ["npc_dota_hero_naga_siren"] = {
        ["naga_siren_song_of_the_siren"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("naga_siren_song_of_the_siren")
                if not ability then return false end
            
                -- 如果有歌唱治疗buff，直接返回false
                if caster:HasModifier("modifier_naga_siren_song_of_the_siren_healing") then
                    return false
                end
            
                local healthThreshold
                if self:containsStrategy(self.hero_strategy, "残血唱歌") then
                    healthThreshold = 30
                elseif self:containsStrategy(self.hero_strategy, "满血唱歌") then
                    healthThreshold = 100
                else
                    healthThreshold = 50
                end
            
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_naga_siren_song_of_the_siren_healing"},
                    0,
                    "health_percent",  -- 按血量百分比排序
                    true,    -- 只允许英雄单位
                    true     -- 包括自己
                )
            
                return self.Ally and self.Ally:GetHealthPercent() <= healthThreshold
            end
        },
        ["naga_siren_ensnare"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("naga_siren_ensnare")
                if not ability then
                    log("娜迦海妖技能检查: 未找到 naga_siren_ensnare 技能")
                    return false
                end
            
                -- 如果self.target已存在且有娜迦大招modifier
                if self.target and self.target:HasModifier("modifier_naga_siren_song_of_the_siren") then
                    -- 检查自己是否需要刷新大招aura
                    return self:NeedsModifierRefresh(caster, {"modifier_naga_siren_song_of_the_siren_aura"}, 0.5)
                end
                
                -- 如果target没有大招modifier，按原逻辑执行
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_naga_siren_ensnare"},
                    0.2,
                    "control" 
                )

                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["naga_siren_song_of_the_siren_cancel"] = {
            function(self, caster, log)
                return false
            end
        },
        ["naga_siren_reel_in"] = {
            function(self, caster, log)
                return false
            end
        },
        
    },
    ["npc_dota_hero_medusa"] = {
        ["medusa_split_shot"] = {
            function(self, caster, log)
                log("检查 medusa_split_shot 条件")
                
                -- 获取攻击范围内的敌人
                local attack_range = caster:Script_GetAttackRange() + 300
                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetOrigin(),
                    nil,
                    attack_range,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                
                -- 获取敌人数量
                local enemy_count = #enemies
                log("攻击范围内敌人数量: " .. enemy_count)
                
                -- 检查是否开启了分裂箭
                local has_split_shot = not self:IsNotUnderModifiers(caster, {"modifier_medusa_split_shot"}, log)
                log("是否开启分裂箭: " .. tostring(has_split_shot))
                
                -- 敌人数量小于等于1的情况
                if enemy_count <= 1 then
                    if has_split_shot then
                        log("敌人数量<=1且开启分裂箭，返回true以关闭技能")
                        return true
                    else
                        log("敌人数量<=1且未开启分裂箭，返回false")
                        return false
                    end
                end
                
                -- 敌人数量大于等于2的情况
                if enemy_count >= 2 then
                    if not has_split_shot then
                        log("敌人数量>=2且未开启分裂箭，返回true以开启技能")
                        return true
                    else
                        log("敌人数量>=2且已开启分裂箭，返回false")
                        return false
                    end
                end
                
                log("默认情况返回false")
                return false
            end
        },
    },

    ["npc_dota_hero_morphling"] = {
        ["morphling_adaptive_strike_str"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("morphling_adaptive_strike_str")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    0.2,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },

        ["morphling_morph_agi"] = {
            function(self, caster, log)
                log("检查 morphling_morph_agi 条件")
                log("当前英雄策略: " .. tostring(self.hero_strategy))
        
                -- 获取血量阈值
                local threshold
                if self:containsStrategy(self.hero_strategy, "500开始转血") then
                    threshold = 1000
                elseif self:containsStrategy(self.hero_strategy, "1000开始转血") then
                    threshold = 1500
                elseif self:containsStrategy(self.hero_strategy, "2000开始转血") then
                    threshold = 2500
                else
                    threshold = 2000
                end
        
                local hasAgiModifier = not self:IsNotUnderModifiers(caster, {"modifier_morphling_morph_agi"}, log)
                local isHighHealth = not IsHealthBelowValue(caster, threshold, log)
        
                -- 血量高且没有正在转敏捷 -> 开启转换
                if isHighHealth and not hasAgiModifier then
                    log("morphling_morph_agi 条件检查结果: true (血量高，需要开始转敏捷)")
                    return true
                end
        
                -- 血量低且正在转敏捷 -> 停止转换
                if not isHighHealth and hasAgiModifier then
                    log("morphling_morph_agi 条件检查结果: true (血量已降低，需要停止转敏捷)")
                    return true
                end
        
                log("morphling_morph_agi 条件检查结果: false")
                return false
            end
        },
        
        ["morphling_morph_str"] = {
            function(self, caster, log)
                log("检查 morphling_morph_str 条件")
                log("当前英雄策略: " .. tostring(self.hero_strategy))
        
                -- 获取血量阈值
                local threshold
                if self:containsStrategy(self.hero_strategy, "500开始转血") then
                    threshold = 500
                elseif self:containsStrategy(self.hero_strategy, "1000开始转血") then
                    threshold = 1000
                elseif self:containsStrategy(self.hero_strategy, "2000开始转血") then
                    threshold = 2000
                else
                    threshold = 1500
                end
        
                local hasStrModifier = not self:IsNotUnderModifiers(caster, {"modifier_morphling_morph_str"}, log)
                local isLowHealth = IsHealthBelowValue(caster, threshold, log)
        
                -- 血量低且没有正在转力量 -> 开启转换
                if isLowHealth and not hasStrModifier then
                    log("morphling_morph_str 条件检查结果: true (血量低，需要开始转力量)")
                    return true
                end
        
                -- 血量高且正在转力量 -> 停止转换
                if not isLowHealth and hasStrModifier then
                    log("morphling_morph_str 条件检查结果: true (血量已恢复，需要停止转力量)")
                    return true
                end
        
                log("morphling_morph_str 条件检查结果: false")
                return false
            end
        },
        ["morphling_morph_replicate"] = {
            function(self, caster, log)
                -- 检查自身是否有复制modifier
                local hasReplicateModifier = caster:HasModifier("modifier_morphling_replicate")
                
                -- 检查是否有"不变回去"策略，如果有且已经在变形状态，直接返回false
                if self:containsStrategy(self.hero_strategy, "不变回去") and hasReplicateModifier then
                    return false
                end
                
                -- 检查周围2000范围内是否有带有复制幻象modifier的友方单位
                
                local allies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    2000,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, -- 添加无敌单位标志
                    FIND_ANY_ORDER,
                    false
                )
                
                local hasReplicateIllusion = false
                for _, ally in pairs(allies) do
                    -- 添加playerID检查
                    if ally:HasModifier("modifier_morphling_replicate_illusion") and 
                       ally:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
                        hasReplicateIllusion = true
                        break
                    end
                end
                if hasReplicateIllusion then
                    return false
                end
        
                local hasReplicateModifier = caster:HasModifier("modifier_morphling_replicate")
        
                local currentTime = GameRules:GetGameTime()
        
                -- 检查是否在变身冷却期
                if not hasReplicateModifier and currentTime < self.morphling_next_morph_time then
                    self:log("处于变身冷却期，不允许变身")
                    return false
                end
        
                local healthThreshold
                if self:containsStrategy(self.hero_strategy, "500开始转血") then
                    healthThreshold = 500
                elseif self:containsStrategy(self.hero_strategy, "1000开始转血") then
                    healthThreshold = 1000
                elseif self:containsStrategy(self.hero_strategy, "2000开始转血") then
                    healthThreshold = 2000
                else
                    healthThreshold = 1500
                end
                self:log("生命值阈值:", healthThreshold)
        
                local isHealthBelow = IsHealthBelowValue(caster, healthThreshold, log)
                self:log("生命值是否低于阈值:", isHealthBelow)
        
                if isHealthBelow and not hasReplicateModifier then
                    -- 检查基础敏捷值
                    local baseAgi = caster:GetBaseAgility()
                    self:log("当前基础敏捷:", baseAgi)
                    if baseAgi < 10 then
                        self:log("基础敏捷小于10，返回 true")
                        return true
                    end
                    self:log("生命值低于阈值且没有复制modifier，返回 false")
                    return false
                end
        
                if isHealthBelow then
                    self:log("生命值低于阈值且有复制modifier，返回 true")
                    return true
                end
        
                self:log("生命值高于阈值，继续检查其他条件")
        
                if hasReplicateModifier then
                    if caster:GetMana() < 100 then
                        return true
                    end
        
                    -- 检查变身状态下是否有可用技能
                    local result = self:checkAbilities(caster, {
                        ["morphling_morph_replicate"] = true
                    })
                    
                    -- 如果没有可用技能，记录最短冷却时间
                    if result then
                        local minCooldown = self:getMinCooldownOfValidSkills(caster, {
                            ["morphling_morph_replicate"] = true
                        })
                        -- 设置下次允许变身的时间
                        self.morphling_next_morph_time = GameRules:GetGameTime() + minCooldown
                        self:log("设置下次变身允许时间:", self.morphling_next_morph_time, "最短冷却:", minCooldown)
                    end
                    
                    return result
                else
                    self:log("无复制modifier，检查除复制和变身外的技能")
        
                    if caster:GetMana() < 100 then
                        return false
                    end
                    local result = self:checkAbilities(caster, {
                        ["morphling_morph_replicate"] = true,
                        ["morphling_morph_str"] = true,
                        ["morphling_morph_agi"] = true
                    })
                    self:log("checkAbilities 结果:", result)
                    return result
                end
            end
        },
        ["morphling_waveform"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "反复横跳波") then
                local forbiddenModifiers = {
                    "modifier_morphling_waveform",
                }
                    return self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
                else
                    return true
                end
            end
        },

    },

    ["npc_dota_hero_juggernaut"] = {

        ["juggernaut_blade_fury"] = {
            function(self, caster, log)
                local forbiddenModifiers = {
                    "modifier_juggernaut_omnislash",
                    "modifier_juggernaut_blade_fury"
                }
                return self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
            end
        },



        ["juggernaut_healing_ward"] = {
            function(self, caster, log)

                local forbiddenModifiers = {
                    "modifier_juggernaut_healing_ward_heal"
                }
                if not self:IsNotUnderModifiers(caster, forbiddenModifiers, log) then
                    return false
                end

                if self:containsStrategy(self.hero_strategy, "80%血放奶棒") then
                    return caster:GetHealthPercent()<80
                else
                    return true
                end

            end
        },

        ["juggernaut_omni_slash"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "无限斩") then
                    return true
                end
                local forbiddenModifiers = {
                    "modifier_juggernaut_blade_fury"
                }
                local requiredModifiers = {"modifier_juggernaut_omnislash"}
                
                local healthCheck = true
                if self:containsStrategy(self.hero_strategy, "半血无敌斩") then
                    healthCheck = caster:GetHealthPercent()<50
                end
                
                return self:IsNotUnderModifiers(caster, forbiddenModifiers, log) 
                    and healthCheck
                    and self:NeedsModifierRefresh(caster, requiredModifiers, 0.4)
            end
        },

        ["juggernaut_swift_slash"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "无限斩") then
                    return true
                end
                local forbiddenModifiers = {
                    "modifier_juggernaut_blade_fury"
                }
                local requiredModifiers = {"modifier_juggernaut_omnislash"}
                
                local healthCheck = true
                if self:containsStrategy(self.hero_strategy, "半血无敌斩") then
                    healthCheck = caster:GetHealthPercent()<50
                end
                
                return self:IsNotUnderModifiers(caster, forbiddenModifiers, log) 
                    and healthCheck
                    and self:NeedsModifierRefresh(caster, requiredModifiers, 0.4)
            end
        },
    },
    ["npc_dota_hero_monkey_king"] = {
        ["monkey_king_boundless_strike"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "BUFF板") then
                    return not self:IsNotUnderModifiers(caster, {"modifier_monkey_king_quadruple_tap_bonuses"}, log) 
                else
                    return true
                end
            end
        },
        ["monkey_king_mischief"] = {
            function(self, caster, log)
                return caster:GetHealthPercent()<99
            end
        },
    },
    --     ["monkey_king_primal_spring"] = {
    --         function(self, caster, log)
    --             -- 检查caster是否拥有modifier_monkey_king_tree_dance_hidden2
    --             if caster:HasModifier("modifier_monkey_king_tree_dance_hidden") then
    --                 return true
    --             else
    --                 return false
    --             end
    --         end
    --     },
    -- },
    ["npc_dota_hero_marci"] = {
        ["marci_bodyguard"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("marci_bodyguard")
                if not ability then return false end
    
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "attack",  -- 按攻击力排序
                    true,     -- 只允许英雄单位 
                    false     -- 不允许选择自己
                )
    
                return self.Ally ~= nil
            end
        },
        ["marci_special_delivery"] = {
            function(self, caster, log)
                return false
            end
        },
    
        ["marci_guardian"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("marci_guardian")
                if not ability then return false end
    
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "attack",  -- 按攻击力排序
                    true,     -- 只允许英雄单位
                    false     -- 不允许选择自己
                )
    
                return self.Ally ~= nil
            end
        },
        ["marci_companion_run"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("marci_companion_run")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil

            end
        },

    },
    ["npc_dota_hero_crystal_maiden"] = {
        ["crystal_maiden_freezing_field_stop"] = {
            function(self, caster, log)
                return false
            end
        },
    },
    ["npc_dota_hero_pangolier"] = {
        ["pangolier_gyroshell_stop"] = {
            function(self, caster, log)
                return false
            end
        },
        ["pangolier_swashbuckle"] = {
            function(self, caster, log)
                local forbiddenModifiers = {
                    "modifier_pangolier_gyroshell",
                    "modifier_pangolier_rollup"
                }
                return self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
            end
        },
        ["pangolier_shield_crash"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "禁止连跳") then
                    local forbiddenModifiers = {
                        "modifier_pangolier_shield_crash_jump"
                    }
                    if not self:IsNotUnderModifiers(caster, forbiddenModifiers, log) then
                        return false
                    end
                end
        
                if not self.target then return false end
                
                local forward_vector = caster:GetForwardVector()
                local direction_to_target = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
                local dot_product = forward_vector:Dot(direction_to_target)
                
                local distance = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
                
                -- 使用0.5作为判定值，相当于60度角（前方120度扇形）
                return dot_product > 0.5 or distance <= 200
            end
        },
        ["pangolier_rollup_stop"] = {
            function(self, caster, log)

                    return false
                -- end
            end
        },
    },
    ["npc_dota_hero_nyx_assassin"] = {
        ["nyx_assassin_impale"] = {
            function(self, caster, log)
                local forbiddenModifiers = {
                    "modifier_nyx_assassin_vendetta"
                }
                if not self:IsNotUnderModifiers(caster, forbiddenModifiers, log) then
                    return false 
                end
                local ability = caster:FindAbilityByName("nyx_assassin_impale")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["nyx_assassin_jolt"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("nyx_assassin_jolt")
                if not ability then return false end


                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,    -- 施法者
                    ability,   -- 技能
                    nil,       -- 无需检查特定状态
                    0,         -- 无需检查状态剩余时间
                    "max_mana" -- 按最大魔法值排序
                )

                if potentialTarget and potentialTarget:GetMaxMana() > 0 then
                    self.target = potentialTarget
                end

                local forbiddenModifiers = {
                    "modifier_nyx_assassin_vendetta"
                }
                return potentialTarget and self:IsNotUnderModifiers(caster, forbiddenModifiers, log)

            end
        },
        ["nyx_assassin_unburrow"] = {
            function(self, caster, log)
                return false
            end
        },
        ["nyx_assassin_vendetta"] = {
            function(self, caster, log)
                local forbiddenModifiers = {
                    "modifier_nyx_assassin_burrow"
                }
                return self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
            end
        },
        ["nyx_assassin_spiked_carapace"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "掉血开壳") then
                    return caster:GetHealthPercent()<99
                else
                    local ability = caster:FindAbilityByName("nyx_assassin_spiked_carapace")
                    if not ability then return false end
                    
                    local potentialTarget = self:FindBestEnemyHeroTarget(
                        caster,
                        ability,
                        nil,
                        nil,
                        "control" ,
                        true
                    )
                    
                    if potentialTarget then
                        self.target = potentialTarget
                    end
    
                    return potentialTarget ~= nil
                end
            end
        },



    },



    ["npc_dota_hero_ancient_apparition"] = {
        ["ancient_apparition_ice_blast"] = {
            function(self, caster, log)
                -- 记录技能释放时间
                self.ice_blast_start_time = GameRules:GetGameTime()
                return true
            end
        },
        ["ancient_apparition_ice_blast_release"] = {
            function(self, caster, log)
                -- 获取当前时间
                local current_time = GameRules:GetGameTime()
                
                -- 计算冰球飞行时间
                local flight_time = current_time - self.ice_blast_start_time
                
                -- 计算冰球飞行距离
                local travel_distance = flight_time * 1500
                
                -- 计算作用范围
                local aoe_radius = math.min(275 + 50 * flight_time, 1000)
                
                -- 计算目标与施法者的距离
                local distance_to_target = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
                
                -- 如果目标在作用范围内或者球已经飞过目标位置,返回true
                if distance_to_target <= travel_distance + aoe_radius and
                   distance_to_target >= travel_distance - aoe_radius then
                    return true
                end
                
                return false
            end
        },
        ["ancient_apparition_cold_feet"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("ancient_apparition_cold_feet")
                if not ability then return false end
            
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_cold_feet"},
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil

            end
        }
    },

    ["npc_dota_hero_storm_spirit"] = {
        ["storm_spirit_ball_lightning"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "没蓝不滚") then
                    if caster:GetMana() <= 500 then
                        return false
                    end
                end




                if self:containsStrategy(self.hero_strategy, "折叠飞") then
                    self:log("[FOLDING_FLY] 进入折叠飞策略判断")
                    
                    -- 初始化折叠飞相关变量
                    if not self.foldingFlyCount then
                        self.foldingFlyCount = 0
                    end
                    if not self.foldingFlyRecords then
                        self.foldingFlyRecords = {}
                    end
                    if not self.lastBallLightningCastTime then
                        self.lastBallLightningCastTime = 0
                    end
                    
                    local currentTime = GameRules:GetGameTime()
                    local isFlying = caster:HasModifier("modifier_storm_spirit_ball_lightning")
                    
                    -- 如果没有在飞行，允许施法
                    if not isFlying then
                        self:log("[FOLDING_FLY] 风暴之灵没有 modifier_storm_spirit_ball_lightning，允许使用技能")
                        self.lastBallLightningCastTime = currentTime
                        return true
                    end
                    
                    -- 如果正在飞行，需要计算是否到了下一次施法的时机
                    if isFlying then
                        -- 获取上次施法位置和当前位置
                        local lastCastPos = self:GetLastCastPositionFromGlobal(caster, "storm_spirit_ball_lightning")
                        if not lastCastPos then
                            self:log("[FOLDING_FLY] 无法获取上次施法位置，允许施法（错过最佳时机也要施法）")
                            return true
                        end
                        
                        local currentPos = caster:GetOrigin()
                        local nextTargetPos = self.target and self.target:GetOrigin() or currentPos
                        
                        -- 获取球状闪电技能和速度
                        local ability = caster:FindAbilityByName("storm_spirit_ball_lightning")
                        local ballLightningSpeed = 1400  -- 默认速度
                        if ability then
                            local kv = ability:GetAbilityKeyValues()
                            local currentLevel = ability:GetLevel()
                            if kv and kv.AbilityValues and kv.AbilityValues.ball_lightning_move_speed then
                                local speedValue = kv.AbilityValues.ball_lightning_move_speed
                                if type(speedValue) == "string" then
                                    local speeds = {}
                                    for s in speedValue:gmatch("%S+") do
                                        table.insert(speeds, tonumber(s))
                                    end
                                    ballLightningSpeed = speeds[currentLevel] or speeds[#speeds] or 1400
                                elseif type(speedValue) == "table" then
                                    ballLightningSpeed = tonumber(speedValue[currentLevel] or speedValue[#speedValue]) or 1400
                                else
                                    ballLightningSpeed = tonumber(speedValue) or 1400
                                end
                            end
                        end
                        
                        -- 实时计算：基于当前位置计算剩余飞行距离和时间
                        local remainingDistance = (lastCastPos - currentPos):Length2D()
                        local remainingFlightTime = remainingDistance / ballLightningSpeed
                        
                        -- 记录用于日志的总距离（用于调试）
                        local totalDistance = remainingDistance  -- 当前就是剩余距离
                        
                        -- 获取真实的施法前摇时间
                        local expectedCastPoint = ability and ability:GetCastPoint() or 0.3
                        
                        -- 计算下一次施法的最佳时机：剩余飞行时间 - 准备时间
                        local totalPreparationTime = expectedCastPoint + 0.03   -- 加上一帧的网络延迟
                        
                        -- 边界处理：确保最小施法间隔
                        local minPreparationTime = 0.1  -- 最小准备时间
                        totalPreparationTime = math.max(totalPreparationTime, minPreparationTime)
                        
                        self:log(string.format("[FOLDING_FLY] 时间计算详情:"))
                        self:log(string.format("[FOLDING_FLY]  - 当前位置到目标位置剩余距离: %.2f", remainingDistance))
                        self:log(string.format("[FOLDING_FLY]  - 球状闪电速度: %.2f", ballLightningSpeed))
                        self:log(string.format("[FOLDING_FLY]  - 剩余飞行时间: %.3f", remainingFlightTime))
                        self:log(string.format("[FOLDING_FLY]  - 施法前摇: %.3f", expectedCastPoint))
                        self:log(string.format("[FOLDING_FLY]  - 总准备时间: %.3f", totalPreparationTime))
                        
                        -- 判断是否到了施法时机：剩余飞行时间 <= 总准备时间
                        if remainingFlightTime <= totalPreparationTime then
                            self:log(string.format("[FOLDING_FLY] 到达施法时机，允许施法 (剩余飞行: %.3f, 准备时间: %.3f)", remainingFlightTime, totalPreparationTime))
                            self.lastBallLightningCastTime = currentTime
                            self.foldingFlyCount = self.foldingFlyCount + 1
                            
                            -- 记录这次施法的详细信息
                            table.insert(self.foldingFlyRecords, {
                                castTime = currentTime,
                                lastCastPos = lastCastPos,
                                currentPos = currentPos,
                                remainingDistance = remainingDistance,
                                remainingFlightTime = remainingFlightTime,
                                totalPreparationTime = totalPreparationTime
                            })
                            
                            return true
                        else
                            local timeUntilOptimal = remainingFlightTime - totalPreparationTime
                            self:log(string.format("[FOLDING_FLY] 尚未到达施法时机 (还需等待: %.3f秒)", timeUntilOptimal))
                            return false
                        end
                    end
                    
                    self:log("[FOLDING_FLY] 未匹配任何条件，默认禁止使用技能")
                    return false
                else
                    local attackRange = caster:Script_GetAttackRange()
                    print("[风暴判断] 攻击范围:", attackRange)

                    local forbiddenModifiers = {
                        "modifier_storm_spirit_electric_rave",
                        "modifier_storm_spirit_overload",
                    }
                    
                    -- 获取当前蓝量
                    local currentMana = caster:GetMana()
                    print("[风暴判断] 当前蓝量:", currentMana)
                    
                    -- 检查前三个技能中是否有可用技能
                    local function isAnyFirstThreeAbilityReady()
                        for i = 0, 2 do  -- 检查前三个技能槽位
                            local ability = caster:GetAbilityByIndex(i)
                            if ability and ability:IsCooldownReady() then
                                print("[风暴判断] 技能", i, "冷却完毕，可用")
                                return true
                            end
                        end
                        print("[风暴判断] 前三个技能都在冷却中")
                        return false
                    end
                
                    -- 蓝量低于500且有技能可用时不使用闪电
                    if currentMana < 500 and isAnyFirstThreeAbilityReady() then
                        print("[风暴判断] 满足特殊条件：蓝量低于500且有技能可用，禁止使用闪电")
                        self:log("满足特殊条件：蓝量低于500，且至少有一个技能可用，禁止使用技能")
                        return false
                    end
                    
                    -- 检查风暴特有buff状态
                    local hasOverload = caster:HasModifier("modifier_storm_spirit_overload")
                    local hasElectricRave = caster:HasModifier("modifier_storm_spirit_electric_rave")
                    local hasBallLightning = caster:HasModifier("modifier_storm_spirit_ball_lightning")
                    print("[风暴判断] 是否有过载:", hasOverload)
                    print("[风暴判断] 是否有电子兵:", hasElectricRave)
                    print("[风暴判断] 是否有球状闪电:", hasBallLightning)
                    
                    -- 检查上次攻击和上次技能释放
                    local heroIndex = caster:GetEntityIndex()
                    local lastAttackTime = 0
                    local lastAbilityTime = 0
                    
                    -- 获取上次攻击时间
                    if Main and Main.heroLastAttack and Main.heroLastAttack[heroIndex] then
                        lastAttackTime = Main.heroLastAttack[heroIndex].time
                        print("[风暴判断] 上次攻击时间:", lastAttackTime)
                    else
                        print("[风暴判断] 未找到攻击记录")
                    end
                    
                    -- 获取上次技能释放时间
                    if Main and Main.heroLastCastAbility and Main.heroLastCastAbility[heroIndex] then
                        for abilityName, abilityData in pairs(Main.heroLastCastAbility[heroIndex]) do
                            if abilityData.time and abilityData.time > lastAbilityTime then
                                lastAbilityTime = abilityData.time
                            end
                        end
                        print("[风暴判断] 上次技能释放时间:", lastAbilityTime)
                    else
                        print("[风暴判断] 未找到技能释放记录")
                    end
                    
                    -- 如果有球状闪电且上次技能释放后还没有攻击过，不返回true

                    if self:containsStrategy(self.hero_strategy, "球状闪电保持距离") and hasBallLightning then
                        return false
                    end

                    if hasBallLightning and (lastAbilityTime > lastAttackTime) then
                        print("[风暴判断] 有球状闪电且上次技能释放后还没有攻击过，禁止使用技能")
                        self:log("有球状闪电且上次技能释放后还没有攻击过，禁止使用技能")
                        return false
                    end
                    
                    -- 新增条件1：英雄没有以下两个modifier中的任意一个
                    if not hasOverload and not hasElectricRave then
                        print("[风暴判断] 没有风暴特有buff，无条件允许使用技能")
                        self:log("没有风暴特有buff，无条件允许使用技能")
                        return true
                    end
                    
                    -- 新增条件2：检查英雄是否刚刚A出去且A出去后没有释放技能
                    print("[风暴判断] 继续检查是否刚刚A出去且A出去后没有释放技能")
                    
                    -- 详细检查electric_rave的层数
                    local electricRaveStacks = 0
                    if hasElectricRave then
                        electricRaveStacks = caster:GetModifierStackCount("modifier_storm_spirit_electric_rave", caster)
                        print("[风暴判断] 电子兵层数:", electricRaveStacks)
                    end
                    
                    -- 排除electric_rave层数大于1的情况
                    if hasElectricRave and electricRaveStacks > 1 and currentMana < 500 then
                        print("[风暴判断] 电子兵层数>1，禁止使用技能")
                        self:log("电子兵层数大于1，禁止使用技能")
                        return false
                    end
                    
                    -- 如果有overload或者electric_rave层数正好为1(预计会被平A消耗掉)
                    if hasOverload or (hasElectricRave and electricRaveStacks == 1) then
                        print("[风暴判断] 有overload或electric_rave层数为1，检查是否刚A出去")
                        
                        -- 检查是否刚刚A出去
                        if Main and Main.heroLastAttack and Main.heroLastAttack[heroIndex] then
                            local lastAttackTime = Main.heroLastAttack[heroIndex].time
                            local currentTime = GameRules:GetGameTime()
                            local timeSinceLastAttack = currentTime - lastAttackTime
                            
                            print("[风暴判断] 上次攻击时间:", lastAttackTime)
                            print("[风暴判断] 当前时间:", currentTime)
                            print("[风暴判断] 距离上次攻击经过:", timeSinceLastAttack, "秒")
                            
                            -- 检查最近一次攻击是否是在近期(5秒内)
                            if timeSinceLastAttack <= 5.0 then
                                print("[风暴判断] 攻击在5秒内，检查攻击后是否释放过技能")
                                
                                -- 检查攻击后是否没有释放技能
                                local hasUsedAbilityAfterAttack = false
                                
                                if Main.heroLastCastAbility and Main.heroLastCastAbility[heroIndex] then
                                    for abilityName, abilityData in pairs(Main.heroLastCastAbility[heroIndex]) do
                                        if abilityData.time > lastAttackTime then
                                            hasUsedAbilityAfterAttack = true
                                            print("[风暴判断] 攻击后释放了技能:", abilityName, "在时间:", abilityData.time)
                                            break
                                        end
                                    end
                                end
                                
                                if not hasUsedAbilityAfterAttack then
                                    print("[风暴判断] 满足特殊条件：有overload或一层electric_rave，且刚刚A出去后未释放技能，允许使用技能")
                                    self:log("满足特殊条件：有overload或一层electric_rave，且刚刚A出去后未释放技能，允许使用技能")
                                    return true
                                else
                                    print("[风暴判断] 攻击后已经释放过技能，不满足条件")
                                    self:log("攻击后已经释放过技能，不满足条件")
                                end
                            else
                                print("[风暴判断] 上次攻击时间超过5秒，不满足条件")
                                self:log("上次攻击时间超过5秒，不满足条件")
                            end
                        else
                            print("[风暴判断] 没有攻击记录或Main.heroLastAttack未初始化")
                            self:log("没有攻击记录或Main.heroLastAttack未初始化")
                        end
                    else
                        print("[风暴判断] 没有overload且electric_rave层数不为1")
                        self:log("没有overload且electric_rave层数不为1")
                    end
                    
                    if GetEnemiesWithinDistance(caster, attackRange, log) == 0 then
                        print("[风暴判断] 攻击范围内没有敌人，允许使用技能")
                        self:log("攻击范围内没有敌人，允许使用技能")
                        return true
                    end
                    
                    print("[风暴判断] 不满足任何条件，禁止使用技能")
                    self:log("不满足任何条件，禁止使用技能")
                    return false
                end
            end
        },
        ["storm_spirit_electric_vortex"] = {
            function(self, caster, log)
                -- 检查自身是否有禁止的 modifier
                if self:containsStrategy(self.hero_strategy, "没蓝才放拉") then
                    if caster:GetMana() <= 500 then
                        return true
                    else
                        return false
                    end
                end



                local forbiddenModifiers = {
                    "modifier_storm_spirit_overload",
                    "modifier_storm_spirit_electric_rave",
                }
                local isNotUnderOtherModifiers = self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
                
                if isNotUnderOtherModifiers then
                    return true
                end
        
                -- 寻找最佳目标
                local ability = caster:FindAbilityByName("storm_spirit_electric_vortex")
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_storm_spirit_electric_vortex_pull"},
                    0.8,
                    "distance",
                    true  -- 只允许英雄单位
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                    return true
                else
                    return false
                end
            end
        },
    },
    ["npc_dota_hero_keeper_of_the_light"] = {
        ["keeper_of_the_light_recall"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("keeper_of_the_light_recall")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {},
                    nil,
                    "distance",
                    true,
                    false
                )
        
                return self.Ally ~= nil

            end
        },
        ["keeper_of_the_light_chakra_magic"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "查克拉只给自己") then
                    local excludeAbilities = {
                        ["keeper_of_the_light_spirit_form"] = true
                    }
                    self.Ally = caster
                    return self:checkAbilities(caster, excludeAbilities)
                end




                local ability = caster:FindAbilityByName("keeper_of_the_light_chakra_magic")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {},
                    nil,
                    "mana_percent"
                )
        
                if self.Ally and self.Ally:GetManaPercent() < 95 then
                    return true
                end
                
                return false
            end
        }
    },
    ["npc_dota_hero_beastmaster"] = {
        ["beastmaster_primal_roar"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("beastmaster_primal_roar")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },

    ["npc_dota_hero_tusk"] = {
        ["tusk_launch_snowball"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "秒放雪球") then
                    return true
                else
                    return false
                end
            end
        },
        ["tusk_snowball"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("tusk_snowball")
                if not ability then return false end

                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        }
    },

    ["npc_dota_hero_enchantress"] = {
        ["enchantress_impetus"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("enchantress_impetus")
                local isToggled = ability:GetAutoCastState()
                local distance = (self.target:GetOrigin() - caster:GetOrigin()):Length2D()
                
                if distance > 200 and not isToggled then
                    -- 距离大于200且未激活，需要激活
                    return true
                elseif distance <= 200 and isToggled then
                    -- 距离小于等于200且已激活，需要关闭
                    return true
                end
                
                -- 其他情况保持当前状态
                return false
            end
        }
    },

    ["npc_dota_hero_treant"] = {
        ["treant_overgrowth"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("treant_overgrowth")
                if not ability then return false end
    
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_treant_overgrowth"},
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["treant_living_armor"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("treant_living_armor")
                if not ability then return false end
    
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_treant_living_armor"},
                    0.5,
                    "health_percent"
                )
    
                return self.Ally ~= nil
            end
        },

    },

    ["npc_dota_hero_viper"] = {
        ["viper_nethertoxin"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("viper_nethertoxin")
                if not ability then return false end
            
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_viper_nethertoxin"},
                    0,
                    "distance" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil


            end
        },



    },

    ["npc_dota_hero_death_prophet"] = {
        ["death_prophet_spirit_siphon"] = {
            function(self, caster, log)
                local castRange = 1200
                local isLowHealth = caster:GetHealth() / caster:GetMaxHealth() < 0.5
    
                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetOrigin(),
                    nil,
                    castRange,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    isLowHealth and (DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC) or DOTA_UNIT_TARGET_HERO,
                    0,
                    FIND_ANY_ORDER,
                    false
                )
    
                for _, enemy in pairs(enemies) do
                    if not enemy:HasModifier("modifier_death_prophet_spirit_siphon_slow") then
                        if isLowHealth or enemy:IsHero() then
                            if log then
                                log("找到合适的目标: " .. enemy:GetUnitName())
                            end
                            return true
                        end
                    end
                end
    
                if log then
                    log("没有找到合适的目标")
                end
                return false
            end
        },
        ["death_prophet_silence"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("death_prophet_silence")
                if not ability then return false end
            
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_death_prophet_silence"},
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil

            end
        }
    },
    ["npc_dota_hero_jakiro"] = {
        ["jakiro_ice_path"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("jakiro_ice_path")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["jakiro_ice_path_detonate"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("jakiro_ice_path_detonate")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },
    ["npc_dota_hero_leshrac"] = {
        ["leshrac_greater_lightning_storm"] = {
            function(self, caster, log)
                return true
            end
        },
        ["leshrac_diabolic_edict"] = {
            function(self, caster, log)
                -- 检查 400 范围内的敌方英雄数量
                local enemyCount = GetRealEnemyHeroesWithinDistance(caster, 400, log)
                
                -- 如果有敌方英雄在范围内（数量大于等于1），返回 true
                if enemyCount >= 1 then
                    return true
                end
                
                -- 如果没有敌方英雄在范围内，检查 modifier 数量
                local modifierName = "modifier_leshrac_diabolic_edict"
                local modifierCount = self:CountModifiers(caster, modifierName)
                
                -- 如果 modifier 数量小于 5，返回 true；否则返回 false
                if modifierCount < 5 then
                    return true
                else
                    return false
                end
            end
        },
        ["leshrac_split_earth"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("leshrac_split_earth")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    0.35,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },
    ["npc_dota_hero_shadow_demon"] = {
        ["shadow_demon_shadow_poison_release"] = {
            function(self, caster, log)
                local castRange = 1500
                local units = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    castRange,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
    
                for _, unit in pairs(units) do
                    local poisonStacks = unit:GetModifierStackCount("modifier_shadow_demon_shadow_poison", caster)
                    if poisonStacks >= 5 then
                        log("发现目标拥有5层或以上Shadow Poison，释放技能")
                        return true
                    end
                end
    
                local casterHealthPercent = caster:GetHealth() / caster:GetMaxHealth() * 100
                if casterHealthPercent < 10 then
                    log("施法者血量低于10%，释放技能")
                    return true
                end
    
                log("未满足释放条件")
                return false
            end
        },
        ["shadow_demon_demonic_purge"] = {
            function(self, caster, log)

                local ability = caster:FindAbilityByName("shadow_demon_demonic_purge")
                if not ability then return false end
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_shadow_demon_purge_slow"},
                    0.5,
                    "distance"
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
    
                return potentialTarget ~= nil
            end
        },
        ["shadow_demon_disseminate"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("shadow_demon_disseminate")
                if not ability then return false end
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_shadow_demon_disseminate"},
                    0.5,
                    "distance"
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
    
                return potentialTarget ~= nil
            end
        },
        ["shadow_demon_demonic_cleanse"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("shadow_demon_demonic_cleanse")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_shadow_demon_purge_slow"},
                    0.5,
                    "health_percent" ,
                    true
                )
        
                return self.Ally ~= nil
            end
        }
    },
    ["npc_dota_hero_tinker"] = {

        ["tinker_defense_matrix"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("tinker_defense_matrix")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_tinker_defense_matrix"},
                    0.5,
                    "health_percent"
                )
        
                return self.Ally ~= nil
            end
        },
        ["tinker_rearm"] = {
            function(self, caster, log)
                -- 首先检查魔法值
                if caster:GetMana() < 300 then
                    self:log("魔法值小于300，返回false")
                    return false
                end
        
                local abilities = {}
                local cooldown_count = 0
                
                -- 获取前4个技能槽位（0-3）的技能
                for i = 0, 3 do
                    local ability = caster:GetAbilityByIndex(i)
                    if ability then
                        table.insert(abilities, ability)
                    end
                end
                
                -- 检查是否有技能在CD中
                for _, ability in pairs(abilities) do
                    if ability:GetCooldownTimeRemaining() > 0 then
                        cooldown_count = cooldown_count + 1
                    end
                end
                
                self:log("当前有 " .. cooldown_count .. " 个技能在冷却中")
                
                -- 如果有两个或更多技能在CD中，返回true
                if cooldown_count >= 2 then
                    self:log("两个或更多技能在冷却中，返回true")
                    return true
                else
                    self:log("少于两个技能在冷却中，返回false")
                    return false
                end
            end
        },
    },
    ["npc_dota_hero_pugna"] = {
        ["pugna_life_drain"] = {
            function(self, caster, log)
                return not caster:IsChanneling()
            end
        },
        ["pugna_decrepify"] = {
            function(self, caster, log)

                if self:containsStrategy(self.hero_strategy, "只虚无自己") then
                    if self:NeedsModifierRefresh(caster, {"modifier_pugna_decrepify"}, 0.5) then
                        self.target = caster
                        return true
                    else
                        return false
                    end
                end
                local ability = caster:FindAbilityByName("pugna_decrepify")
                if not ability then return false end

                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_pugna_decrepify"},
                    0.5,
                    "distance"
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end
    
                return potentialTarget ~= nil

            end
        },

    },
    ["npc_dota_hero_obsidian_destroyer"] = {
        ["obsidian_destroyer_sanity_eclipse"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "满血开大") then
                    return true
                end
                -- 如果血量低于25%直接返回true
                if caster:GetHealthPercent()<25 then
                    self:log("血量低于25%，直接返回true")
                    return true
                end
                
                local ability = caster:FindAbilityByName("obsidian_destroyer_sanity_eclipse")
                if not ability then
                    self:log("找不到技能，返回false")
                    return false
                end
                
                -- 获取技能等级对应的基础伤害
                local base_damage = {200, 300, 400}
                local ability_level = ability:GetLevel()
                local current_base_damage = base_damage[ability_level]
                
                -- 计算双方的魔法值差距
                local mana_diff = caster:GetMana() - self.target:GetMana()
                
                -- 计算目标魔法抗性
                local magic_resistance = self.target:Script_GetMagicalArmorValue(false, nil)
                
                -- 计算总伤害
                local total_damage = (mana_diff * 0.6 + current_base_damage) * (1 - magic_resistance)
                
                -- 获取目标当前生命值
                local target_health = self.target:GetHealth()
                
                self:log(string.format("计算伤害: %.2f, 目标生命值: %.2f", total_damage, target_health))
                
                -- 比较伤害和生命值
                if total_damage > target_health then
                    self:log("伤害大于目标生命值，返回true")
                    return true
                else
                    self:log("伤害小于目标生命值，返回false")
                    return false
                end
            end
        },
    },
    ["npc_dota_hero_alchemist"] = {
        ["alchemist_chemical_rage"] = {
            function(self, caster, log)

                if not self:NeedsModifierRefresh(caster, {"modifier_alchemist_chemical_rage"}, 0.5) then
                    return false
                end

                if self:containsStrategy(self.hero_strategy, "半血开大") then
                    return caster:GetHealthPercent()<50
                elseif self:containsStrategy(self.hero_strategy, "残血开大") then
                    return caster:GetHealthPercent()<30
                else
                    return true
                end
            end
        },
        ["alchemist_unstable_concoction"] = {
            function(self, caster, log)
                -- 记录技能释放时间
                --对手不是英雄单位，直接false

                self.concoction_start_time = GameRules:GetGameTime()
                if not self.target:IsHero() then
                    return false
                end
                return true
            end
        },
        ["alchemist_unstable_concoction_throw"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "见面扔炸弹") then
                    return true
                end



                if caster:GetHealthPercent()<20 then
                    return true
                end
                -- 获取当前时间
                local current_time = GameRules:GetGameTime()
                
                
                -- 计算从释放化合物到投掷的时间
                local brew_time = current_time - self.concoction_start_time
                
                -- 如果已经过了5秒
                if brew_time >= 4 then
                    return true
                end
                
                return false
            end
        },
        ["alchemist_berserk_potion"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("alchemist_berserk_potion")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_alchemist_berserk_potion"},
                    0.5,
                    "health_percent"
                )
        
                return self.Ally ~= nil
            end
        }
    },
    ["npc_dota_hero_phoenix"] = {
        ["phoenix_supernova"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("phoenix_supernova")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "health_percent"
                )
        
                -- 根据不同策略判断施放条件
                if self:containsStrategy(self.hero_strategy, "满血开大") then
                    return self.Ally ~= nil
                elseif self:containsStrategy(self.hero_strategy, "半血开大") then
                    return self.Ally and self.Ally:GetHealthPercent() < 50
                else
                    return self.Ally and self.Ally:GetHealthPercent() < 30
                end
            end
        },
        ["phoenix_launch_fire_spirit"] = {
            function(self, caster, log)
                if not self.lastFireSpiritTrueTime then
                    self.lastFireSpiritTrueTime = 0
                end
                
                local currentTime = GameRules:GetGameTime()
                if currentTime < self.lastFireSpiritTrueTime + 0.5 then
                    return false
                end
                
                local shouldRefresh = self:NeedsModifierRefresh(self.target, {"modifier_phoenix_fire_spirit_burn"}, 0.5)
                if shouldRefresh then
                    self.lastFireSpiritTrueTime = currentTime
                end
                return shouldRefresh
            end
        },
    },

    ["npc_dota_hero_bristleback"] = {
        ["bristleback_warpath"] = {
            function(self, caster, log)
                local modifiers = caster:FindAllModifiersByName("modifier_bristleback_warpath_stack")
                return #modifiers >= 3
            end
        }
    },
    ["npc_dota_hero_oracle"] = {
        ["oracle_false_promise"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "满血开大") then
                    self.Ally = caster
                    return true
                end


                local ability = caster:FindAbilityByName("oracle_false_promise")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_oracle_false_promise_timer"},
                    0.5,
                    "health_percent"
                )
                
                if self.Ally and self.Ally:GetHealthPercent() < 50 then
                    return true
                end
                
                return false
            end
        }
    },
    ["npc_dota_hero_life_stealer"] = {
        ["life_stealer_infest"] = {
            function(self, caster, log)

                if self:containsStrategy(self.hero_strategy, "满血开大") then
                    return true
                end





                local ability = caster:FindAbilityByName("life_stealer_infest")
                if not ability then return false end
                
                -- 生命值低于30%时直接返回true
                if caster:GetHealthPercent() < 30 then
                    return true
                end
                
                -- 生命值30%-50%时，需要找到合适目标
                if caster:GetHealthPercent() < 50 then
                    local potentialTarget = self:FindBestEnemyHeroTarget(
                        caster,
                        ability,
                        {"modifier_life_stealer_infest_enemy_hero"},
                        0.5,
                        "distance"
                    )
                    
                    if potentialTarget then
                        self.target = potentialTarget
                    end
        
                    return potentialTarget ~= nil
                end
        
                return false
            end
        },
        ["life_stealer_consume"] = {
            function(self, caster, log)
                return false
            end
        },

        ["life_stealer_unfettered"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "秒解控") then
                    if caster:IsStunned() then
                        return true
                    end
                    return false
                end
                return true
            end
        },
        ["life_stealer_open_wounds"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("life_stealer_open_wounds")
                local aoeRadius = self:GetSkillAoeRadius(ability)
                local castRange = self:GetSkillCastRange(caster, ability)
                local totalRange = aoeRadius + castRange

                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    totalRange,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )

                for _, enemy in pairs(enemies) do
                    if self:NeedsModifierRefresh(enemy, {"modifier_life_stealer_open_wounds"}, 0.5) then
                        return true
                    end
                end

                return false
            end
        },
    },



    ["npc_dota_hero_mars"] = {
        ["mars_spear"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "先大后矛") then
                    if caster:IsRooted() then -- 如果英雄被缠绕(定身)
                        return false
                    else
                        return true
                            
                    end
                else
                    return true
                end
            end
        },
        ["mars_bulwark"] = {
            function(self, caster, log)
                local forward = caster:GetForwardVector()
                local startPos = caster:GetAbsOrigin()
                local width = 600
                local length = 800
        
                local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                    startPos,
                    nil,
                    length,
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false)
                
                -- 计算前方矩形区域内的敌人数量
                local enemiesInFront = 0
                for _, enemy in pairs(enemies) do
                    local toEnemy = (enemy:GetAbsOrigin() - startPos):Normalized()
                    local dotProduct = forward:Dot(toEnemy)
                    -- 增加一个余量，使判定更宽松
                    if dotProduct > -0.2 and math.abs((enemy:GetAbsOrigin() - startPos):Cross(forward).z) <= (width/2 + 50) then
                        enemiesInFront = enemiesInFront + 1
                    end
                end
        
                -- 统一判定逻辑，增加开关条件的差值
                if caster:HasModifier("modifier_mars_bulwark_active") then
                    -- 已激活状态下，只有当前方敌人数量少于1才关闭
                    return enemiesInFront <= 1
                else
                    -- 未激活状态下，当前方敌人数量大于等于3才开启
                    return enemiesInFront >= 2
                end
            end
        },
    },

    ["npc_dota_hero_mirana"] = {
        ["mirana_leap"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "有人贴脸就跳") then
                    if self.target and (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= 300 then
                        return true
                    end
                    return false
                else
                    if GetEnemiesWithinDistance(caster, 500, log) > 0 then
                        return false
                    else
                        return true 
                    end
                end
            end
        },
        ["mirana_starfall"] = {
            function(self, caster, log)
                if caster:GetHealthPercent()<50 then
                    return true
                else
                    return self.target:HasModifier("modifier_mirana_leap_slow")
                end
            end
        },

    },
    ["npc_dota_hero_kunkka"] = {
        ["kunkka_torrent"] = {
            function(self, caster, log)

                local ability = caster:FindAbilityByName("kunkka_torrent")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
                
            end
        },
        ["kunkka_x_marks_the_spot"] = {
            function(self, caster, log)

                local ability = caster:FindAbilityByName("kunkka_x_marks_the_spot")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
                
            end
        }
    },

    ["npc_dota_hero_huskar"] = {
        ["huskar_inner_fire"] = {
            function(self, caster, log)
                
                local ability = caster:FindAbilityByName("huskar_inner_fire")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_huskar_life_break_taunt"},
                    0.5,
                    "distance"
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil and self:IsNotUnderModifiers(caster, {"modifier_huskar_life_break_charge"}, log)
            end
        }
    },
    ["npc_dota_hero_dark_seer"] = {
        ["dark_seer_ion_shell"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("dark_seer_ion_shell")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_dark_seer_ion_shell"},
                    0.5,
                    "distance",
                    true,
                    true,
                    true
                )
                
                return self.Ally ~= nil
            end
        },
        ["dark_seer_surge"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("dark_seer_surge")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_dark_seer_surge"},
                    0.5,
                    "distance"
                )
                
                return self.Ally ~= nil
            end
        }
    },

    ["npc_dota_hero_dazzle"] = {
        ["dazzle_shallow_grave"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("dazzle_shallow_grave")
                if not ability then return false end
        
                local checkTime = 0.5
                if self:containsStrategy(self.hero_strategy, "剩1秒续薄葬") then
                    checkTime = 1
                elseif self:containsStrategy(self.hero_strategy, "剩2秒续薄葬") then
                    checkTime = 2
                elseif self:containsStrategy(self.hero_strategy, "剩3秒续薄葬") then
                    checkTime = 3
                elseif self:containsStrategy(self.hero_strategy, "剩4秒续薄葬") then
                    checkTime = 4
                elseif self:containsStrategy(self.hero_strategy, "无限薄葬") then
                    checkTime = 4.5
                end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_dazzle_shallow_grave"},
                    checkTime,
                    "health_percent"
                )
        
                -- 检查是否有死亡镰刀
                if self.Ally and self.Ally:HasModifier("modifier_necrolyte_reapers_scythe") then
                    return true
                end
        
                if self:containsStrategy(self.hero_strategy, "无限薄葬") or
                   self:containsStrategy(self.hero_strategy, "剩1秒续薄葬") or
                   self:containsStrategy(self.hero_strategy, "剩2秒续薄葬") or
                   self:containsStrategy(self.hero_strategy, "剩3秒续薄葬") or
                   self:containsStrategy(self.hero_strategy, "剩4秒续薄葬") then
                    return self.Ally ~= nil
                else
                    local healthThreshold = 30
                    if self:containsStrategy(self.hero_strategy, "20%血薄葬") then
                        healthThreshold = 20
                    elseif self:containsStrategy(self.hero_strategy, "10%血薄葬") then
                        healthThreshold = 10
                    elseif self:containsStrategy(self.hero_strategy, "半血薄葬") then
                        healthThreshold = 50
                    elseif self:containsStrategy(self.hero_strategy, "满血薄葬") then
                        healthThreshold = 100
                        self.Ally = caster
                    end
                    return self.Ally and self.Ally:GetHealthPercent() < healthThreshold
                end
            end
        },
        ["dazzle_bad_juju"] = {
            function(self, caster, log)
                local excludeAbilities = {
                    ["dazzle_bad_juju"] = true
                }
                return self:checkAbilities(caster, excludeAbilities)
            end
        },
        ["dazzle_nothl_projection_end"] = {
            function(self, caster, log)
                return false
            end
        },
        ["dazzle_shadow_wave"] = {
            function(self, caster, log)
                local healthThreshold = 80
                if self:containsStrategy(self.hero_strategy, "满血治疗波") then
                    healthThreshold = 100
                end


                if caster:HasScepter() then
                    return true
                else
                    local ability = caster:FindAbilityByName("dazzle_shadow_wave")
                    if not ability then return false end
                    self.Ally = self:FindBestAllyHeroTarget(
                        caster,
                        ability,
                        {"modifier_dazzle_shallow_grave"},
                        0.5,
                        "health_percent"
                    )
                    if self.Ally and self.Ally:GetHealthPercent() <= healthThreshold then
                        return true
                    end
                    return false
                end
            end
        },
        ["dazzle_poison_touch"] = {
            function(self, caster, log)
                if self:containsStrategy(self.global_strategy, "留控打断") and caster:HasModifier("modifier_dazzle_nothl_projection_soul_debuff")   then
                    local ability = caster:FindAbilityByName("dazzle_poison_touch")
                    if not ability then return false end
                    local potentialTarget = self:FindBestEnemyHeroTarget(
                        caster,
                        ability,
                        {},
                        0,
                        "channeling", 
                        true
                    )
                
                    -- 如果找到目标且正在持续施法
                    if potentialTarget and potentialTarget:IsChanneling() then
                        self.target = potentialTarget
                        log(string.format("[PANDA_TEST] 找到正在持续施法的目标: %s", self.target:GetUnitName()))
                        return true
                    else
                        return false
                    end
                    
                else
                    return true
                end
            end
        },
    },
    
    ["npc_dota_hero_earthshaker"] = {
        ["earthshaker_enchant_totem"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "远程余震") then
                    local requiredModifiers = {"modifier_stunned"}
                    return self:NeedsModifierRefresh(self.target, requiredModifiers, 0.53)
                else
                    local ability = caster:FindAbilityByName("earthshaker_enchant_totem")
                    if not ability then return false end
                    
                    if self.target and (caster:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D() > 250 then
                        return true
                    end
                    
                    local potentialTarget = self:FindBestEnemyHeroTarget(
                        caster,
                        ability,
                        nil,
                        nil,
                        "control" ,
                        true
                    )
                    
                    if potentialTarget then
                        self.target = potentialTarget
                    end
    
                    return potentialTarget ~= nil
                end
            end
        },
        ["earthshaker_fissure"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("earthshaker_fissure")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["earthshaker_echo_slam"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "自定义") then
                    if hero_duel.creepCount and hero_duel.creepCount>=250 then
                        return true

                    else
                        return false
                    end
                end
                local ability = caster:FindAbilityByName("earthshaker_echo_slam")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },


    ["npc_dota_hero_brewmaster"] = {
        ["brewmaster_primal_split"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "满血开大") then
                    return true
                elseif self:containsStrategy(self.hero_strategy, "残血开大") then
                    return caster:GetHealthPercent()<10
                else
                    return caster:GetHealthPercent()<50
                end
            end
        },
        ["brewmaster_cinder_brew"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "无限灌酒") then
                    return true
                else
                    local requiredModifiers = {"modifier_brewmaster_cinder_brew"}
                    return self:NeedsModifierRefresh(self.target, requiredModifiers, 0.5)
                end
            end
        },
        ["brewmaster_drunken_brawler"] = {
            function(self, caster, log)
                local modifierName = "modifier_brewmaster_drunken_brawler_passive"
                local modifier = caster:FindModifierByName(modifierName)
                if modifier then
                    print("modifier存在")  -- 直接打印文本
                    print("modifier name:", modifier:GetName())  -- 打印modifier的名称
                    -- 使用 pcall 来安全地调用 GetTexture
                    local success, texture = pcall(function() return modifier:GetTexture() end)
                    if success then
                        print("获取texture成功:", texture)
                    else
                        print("获取texture失败:", texture)  -- texture 此时包含错误信息
                    end
                    if success and texture then
                        return texture == "brewmaster_drunken_brawler_active"
                    end
                else
                    print("modifier不存在")
                end
                return false
            end
        }

    },
    ["npc_dota_hero_muerta"] = {
        ["muerta_dead_shot"] = {
            function(self, caster, log)

                if self:containsStrategy(self.hero_strategy, "断技能") then

                
                    -- 检查敌人是否是屠夫，且没有释放过钩子
                    if self.target and self.target:GetUnitName() == "npc_dota_hero_pudge" then
                        local targetIndex = self.target:GetEntityIndex()
                        -- 检查目标是否使用过钩子技能
                        if Main.heroLastCastAbility and 
                        Main.heroLastCastAbility[targetIndex] and 
                        Main.heroLastCastAbility[targetIndex]["pudge_meat_hook"] then
                            -- 目标屠夫已经使用过钩子，正常判断
                        else
                            -- 目标屠夫没有使用过钩子，不使用我们的技能
                            if self.target
                            and ((self:NeedsModifierRefresh(self.target, {"modifier_muerta_the_calling_silence"}, 0.5) and self.target:HasModifier("modifier_muerta_the_calling_silence") )
                            or (self:NeedsModifierRefresh(self.target, {"modifier_muerta_dead_shot_fear"}, 0.5) and self.target:HasModifier("modifier_muerta_dead_shot_fear")) )
                            then
                                return true
                            else
                                return false
                            end
                        end
                    end
                end
                print("正在检测技能: muerta_dead_shot")
                self:log("正在检测技能: muerta_dead_shot")
                local ability = caster:FindAbilityByName("muerta_dead_shot")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_muerta_dead_shot_fear"},
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                local current_time = GameRules:GetGameTime()
                local heroIndex = caster:GetEntityIndex()
                    
                -- 获取上次释放时间
                local last_cast_info = Main.heroLastCastAbility 
                    and Main.heroLastCastAbility[heroIndex] 
                    and Main.heroLastCastAbility[heroIndex]["muerta_dead_shot"]
                local last_time = last_cast_info and last_cast_info.time or 0
                self:log("当前时间: " .. current_time)
                self:log("上次释放时间: " .. last_time)
                -- 如果是首次释放或者距离上次释放超过0.5秒
                if (current_time - last_time) > 2 then
                    if self.target then
                        return true
                    else
                        return false
                    end
                end

                return false
            end
        },
    },


    ["npc_dota_hero_elder_titan"] = {
        ["elder_titan_return_spirit"] = {
            function(self, caster, log)
                -- 查找 Echo Stomp 技能
                local echoStompAbility = caster:FindAbilityByName("elder_titan_echo_stomp")
                
                -- 检查技能是否存在且在冷却中
                if echoStompAbility and echoStompAbility:GetCooldownTimeRemaining() > 0 then
                    log("Echo Stomp 在冷却中，返回 true")
                    return true
                else
                    if not echoStompAbility then
                        log("未找到 Echo Stomp 技能")
                    else
                        log("Echo Stomp 不在冷却中")
                    end
                    return false
                end
            end
        },
        ["elder_titan_ancestral_spirit"] = {
            function(self, caster, log)
                local requiredModifiers = {"modifier_elder_titan_echo_stomp_magic_immune"}
                return self:NeedsModifierRefresh(caster, requiredModifiers, 0.1)
            end
        },
        ["elder_titan_move_spirit"] = {
            function(self, caster, log)
                local enemy = self.target
                
                if not enemy then
                    log("没有有效的敌人目标")
                    return false
                end
                -- 检查施法者和目标之间的距离
                local distance = (caster:GetAbsOrigin() - enemy:GetAbsOrigin()):Length2D()
                if distance < 275 then
                    log("施法者与目标距离小于275，不需要移动")
                    return false
                end
        
                log("开始检查敌人 " .. enemy:GetUnitName() .. " 周围275范围内的单位")
        
                -- 在敌人周围275范围内搜索单位
                local units = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    enemy:GetAbsOrigin(),
                    nil,
                    275, 
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + 
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE + 
                    DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD +
                    DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
                    FIND_ANY_ORDER,
                    false
                )
        
                log("在275范围内找到 " .. #units .. " 个单位")
        
                -- 检查是否有先祖之灵在范围内
                local spiritFound = false
                for _, unit in pairs(units) do
                    log("检查单位: " .. unit:GetUnitName())
                    if unit:GetUnitName() == "npc_dota_elder_titan_ancestral_spirit" then
                        log("先祖之灵在敌人275范围内，不需要移动")
                        spiritFound = true
                        break
                    end
                end
        
                if spiritFound then
                    return false
                else
                    log("在275范围内没有找到先祖之灵")
                    log("先祖之灵不在敌人275范围内，需要移动")
                    return true
                end
            end
        },
        
    },

    ["npc_dota_hero_earth_spirit"] = {
        ["earth_spirit_boulder_smash"] = {
            function(self, caster, log)
                local stoneCallerAbility = caster:FindAbilityByName("earth_spirit_stone_caller")
                local stone_charger = 0
        
                if stoneCallerAbility then
                    if caster:GetHeroFacetID() ~= 2 then
                        stone_charger = stoneCallerAbility:GetCurrentAbilityCharges()
                    else
                        if stoneCallerAbility:IsFullyCastable() then
                            stone_charger = 1
                        else 
                            stone_charger = 0
                        end
                    end
        
                    if stone_charger > 0 then
                        log("石头召唤技能可用，返回true")
                        return true
                    end
                end
        
                local radius = 200
                
                -- 搜索所有类型的单位，包括普通单位和无敌单位
                local units = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    radius,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                    FIND_ANY_ORDER,
                    false
                )
        
                for _, unit in pairs(units) do
                    if unit ~= caster then
                        if unit:IsHero() or unit:IsCreep() then
                            log("找到有效的普通单位目标")
                            return true
                        elseif unit:GetName() == "npc_dota_earth_spirit_stone" or unit:HasModifier("modifier_earthspirit_petrify") then
                            log("找到有效的石头或被石化单位")
                            return true
                        end
                    end
                end
        
                log("未找到有效目标")
                return false
            end
        },
        ["earth_spirit_petrify"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("earth_spirit_petrify")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "health_percent"
                )
                
                return self.Ally and self.Ally:GetHealthPercent() < 50
            end
        },

        ["earth_spirit_geomagnetic_grip"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("earth_spirit_geomagnetic_grip")
                if not ability then
                    log("找不到地磁抓取技能")
                    return false
                end
        
                local stoneCallerAbility = caster:FindAbilityByName("earth_spirit_stone_caller")
                local stone_charger = 0
        
                if stoneCallerAbility then
                    if caster:GetHeroFacetID() ~= 2 then
                        stone_charger = stoneCallerAbility:GetCurrentAbilityCharges()
                    else
                        if stoneCallerAbility:IsFullyCastable() then
                            stone_charger = 1
                        else 
                            stone_charger = 0
                        end
                    end
        
                    if stone_charger > 0 then
                        log("石头召唤技能可用，返回true")
                        return true
                    end
                end
        
                local aoeRadius = self:GetSkillAoeRadius(ability)
                local castRange = self:GetSkillCastRange(caster, ability)
                local totalRange = aoeRadius + castRange
        
                -- 一次性查找友方单位和无敌单位
                local units = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    totalRange,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY + DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                    FIND_ANY_ORDER,
                    false
                )
        
                for _, unit in pairs(units) do
                    if unit ~= caster then  -- 排除自己
                        if unit:IsHero() then
                            log("找到有效的友方英雄目标")
                            return true
                        elseif unit:GetUnitName() == "npc_dota_earth_spirit_stone" then
                            log("找到有效的石头目标")
                            return true
                        end
                    end
                end
        
                log("在范围内没有找到有效的地磁抓取目标")
                return false
            end
        },
        ["earth_spirit_rolling_boulder"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("earth_spirit_rolling_boulder")
                if not ability then
                    log("找不到滚动岩石技能")
                    return false
                end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["earth_spirit_stone_caller"] = {
            function(self, caster, log)
                -- 在函数内部定义静态变量
                if not self.lastTrueReturnTime then
                    self.lastTrueReturnTime = 0
                end
                if not self.firstTrueReturnTime then
                    self.firstTrueReturnTime = 0
                end
                local shortCooldownTime = 0.1 -- 0.2秒短冷却时间
                local longCooldownTime = 1 -- 1秒长冷却时间
        
                            local currentTime = GameRules:GetGameTime()
                
                -- 检查是否在短冷却时间内（0.2秒）
                if currentTime - self.firstTrueReturnTime <= shortCooldownTime then
                    log("在0.2秒短冷却时间内，继续返回 true")
                    return true
                end
                
                -- 检查是否在0.2-1秒之间
                if currentTime - self.firstTrueReturnTime > shortCooldownTime and currentTime - self.firstTrueReturnTime <= longCooldownTime then
                    log("在0.2-1秒之间，强制返回 true")
                    return false
                end
                
                -- 检查是否超过1秒，如果是，重置firstTrueReturnTime
                if currentTime - self.firstTrueReturnTime > longCooldownTime then
                    self.firstTrueReturnTime = 0
                end
        
                -- 检查自身是否有 rolling_boulder_caster modifier
                if not caster:HasModifier("modifier_earth_spirit_rolling_boulder_caster") then
                    log("施法者没有 rolling_boulder_caster modifier")
                    return false
                end
        
                -- 获取朝向目标的方向
                local casterPos = caster:GetAbsOrigin()
                local targetPos = self.target:GetAbsOrigin()
                local direction = (targetPos - casterPos):Normalized()
                local distanceToTarget = (targetPos - casterPos):Length2D()
        
                -- 设置搜索范围
                local searchRadius = math.min(distanceToTarget, 950)
                local searchWidth = 200  -- 设置一个合理的宽度来模拟直线搜索
        
                -- 在直线区域内搜索单位
                local unitsInLine = FindUnitsInLine(
                    caster:GetTeamNumber(),
                    casterPos,
                    casterPos + direction * searchRadius,
                    nil,
                    searchWidth,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE
                )
        
                -- 检查石头
                local stoneCount = 0
                local invalidStoneFound = false
        
                for _, unit in pairs(unitsInLine) do
                    if unit:GetName() == "npc_dota_earth_spirit_stone" then
                        stoneCount = stoneCount + 1
                        if not unit:HasModifier("modifier_earth_spirit_boulder_smash") then
                            invalidStoneFound = true
                            log("发现一个没有 boulder_smash modifier 的石头")
                                            break
                                        end
                                    end
                                end
                                
                -- 判断结果
                local shouldReturnTrue = false
                if stoneCount > 0 and not invalidStoneFound then
                    log("找到 " .. stoneCount .. " 个符合条件的石头")
                    self.earthSpiritStonePosition = "脚底下"  -- 设置标志变量，表示石头可以用于滚动
                    shouldReturnTrue = true
                elseif stoneCount == 0 then
                    log("没有找到石头")
                    self.earthSpiritStonePosition = "脚底下"  -- 设置标志变量，表示石头应该放在脚底下
                    shouldReturnTrue = true
                else
                    log("找到不符合条件的石头")
                    return false
                end
        
                if shouldReturnTrue then
                    if self.firstTrueReturnTime == 0 then
                        self.firstTrueReturnTime = currentTime
                    end
                    self.lastTrueReturnTime = currentTime
                                    return true
                                end
        
                return false
            end
        },

    },

    ["npc_dota_hero_rattletrap"] = {

        ["rattletrap_battery_assault"] = {
            function(self, caster, log)
                local requiredModifiers = {"modifier_rattletrap_battery_assault"}
                return self:NeedsModifierRefresh(caster, requiredModifiers, 0.5)
            end
        },
        ["rattletrap_overclocking"] = {
            function(self, caster, log)
                local requiredModifiers = {"modifier_rattletrap_overclocking"}
                return self:NeedsModifierRefresh(caster, requiredModifiers, 0.5)
            end
        },
        ["rattletrap_hookshot"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("rattletrap_hookshot")
                if not ability then 
                    print("【阻挡检测】没有找到发条的钩子技能，返回false")
                    return false 
                end
            
                local potentialTarget = self:FindClosestUnblockedEnemyHero(caster, ability, true, 300)
            
                if potentialTarget then
                    local realHeroStr = potentialTarget:IsTempestDouble() and "(假)" or "(真)"
                    print("【阻挡检测】找到目标: " .. potentialTarget:GetUnitName() .. realHeroStr .. "，返回true")
                    self.target = potentialTarget
                        return true
                else
                    print("【阻挡检测】没有找到合适目标，返回false")
                    return false
                end
            end
        },
    },
    ["npc_dota_hero_vengefulspirit"] = {
        ["vengefulspirit_magic_missile"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("vengefulspirit_magic_missile")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },

    },


    ["npc_dota_hero_sand_king"] = {
        ["sandking_sand_storm"] = {
            function(self, caster, log)
                return self:NeedsModifierRefresh(caster, {"modifier_sandking_sand_storm"}, 0.5)
            end
        },
        ["sandking_burrowstrike"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("sandking_burrowstrike")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },
    ["npc_dota_hero_pudge"] = {
        ["pudge_dismember"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("pudge_dismember")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["pudge_meat_hook"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("pudge_meat_hook")
                if not ability then return false end


                local potentialTarget = self:FindClosestUnblockedEnemyHero(caster,ability, false)

                if potentialTarget then
                    self.target = potentialTarget
                    return true
                else
                    return false
                end

            end
        },

    },
    ["npc_dota_hero_batrider"] = {
        ["batrider_flaming_lasso"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("batrider_flaming_lasso")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },


    ["npc_dota_hero_void_spirit"] = {
        ["void_spirit_aether_remnant"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("void_spirit_aether_remnant")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        
        ["void_spirit_resonant_pulse"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "续沉默") then
                    return self:NeedsModifierRefresh(self.target, {"modifier_silence"}, 0.2)
                else
                    local forbiddenModifiers = {
                        "modifier_void_spirit_resonant_pulse_physical_buff",
                    }
                    return self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
                end
            end
        },
    },

    ["npc_dota_hero_ember_spirit"]= {
        ["ember_spirit_sleight_of_fist"] = {
            function(self, caster, log)
                if caster:HasModifier("modifier_ember_spirit_sleight_of_fist_caster_invulnerability") then
                    if log then self:log("检测到英雄处于Sleight of Fist状态，返回false") end
                    return false
                end
                
                local fireRemnantAbility = caster:FindAbilityByName("ember_spirit_fire_remnant")
                if self:containsStrategy(self.hero_strategy, "飞魂期间不放无影拳") and 
                   caster:HasModifier("modifier_ember_spirit_fire_remnant") and
                   fireRemnantAbility and 
                   fireRemnantAbility:GetCurrentAbilityCharges() > 0 then
                    if log then self:log("检测到英雄处于Fire Remnant状态且还有充能，返回false") end
                    return false
                end
        
                local forbiddenModifiers = {
                    "modifier_ember_spirit_fire_remnant",
                }
                
                -- 检查是否处于躲避模式
                if self:containsStrategy(self.hero_strategy, "躲避模式") or self:containsStrategy(self.hero_strategy, "躲避模式1000码") then
                    -- 在躲避模式下才检查forbiddenModifiers
                    if not self:IsNotUnderModifiers(caster, forbiddenModifiers, log) then
                        self:log("躲避模式：检测到禁用modifier，返回false")
                        return false
                    end
                end
                
                local requiredModifier = "modifier_ember_spirit_fire_remnant_timer"
                
                if fireRemnantAbility and fireRemnantAbility:GetCurrentAbilityCharges() == 0 then
                    local allModifiers = caster:FindAllModifiersByName(requiredModifier)
                    self:log(string.format("Fire Remnant: Found %d modifiers", #allModifiers))
                    
                    local allBelowThreshold = true
                    
                    for i, modifier in ipairs(allModifiers) do
                        local remainingTime = modifier:GetRemainingTime()
                        self:log(string.format("Remnant %d: Remaining time %.2f", i, remainingTime))
                        
                        if remainingTime > 43.9 then
                            allBelowThreshold = false
                            self:log(string.format("Fire Remnant: Remnant %d has remaining time > 43.9", i))
                            break
                        end
                    end
                    
                    if allBelowThreshold then
                        self:log("Fire Remnant: All remnants have remaining time <= 43.9, returning true")
                        return true
                    else
                        self:log("Fire Remnant: Not all remnants have remaining time <= 43.9, returning false")
                        return false
                    end
                else
                    return true
                end
            end
        },
        ["ember_spirit_activate_fire_remnant"] = {
            function(self, caster, log)
                -- 检查残焰状态
                if caster:HasModifier("modifier_ember_spirit_fire_remnant") then
                    if log then self:log("英雄处于残焰状态，返回false") end
                    return false
                end
        
                -- 检查是否有残焰计时器
                if not caster:HasModifier("modifier_ember_spirit_fire_remnant_timer") then
                    if log then self:log("没有残焰计时器，返回false") end
                    return false
                end
        
                local forbiddenModifiers = {
                    "modifier_ember_spirit_fire_remnant",
                }
                
                local baseCondition = self:IsNotUnderModifiers(caster, forbiddenModifiers, log)
                
                if self:containsStrategy(self.hero_strategy, "躲避模式") or self:containsStrategy(self.hero_strategy, "躲避模式1000码") then
                    if not self.target then
                        if log then self:log("躲避模式：没有目标，返回false") end
                        return false
                    end
        
                    -- 初始化上一次状态和位置（如果还没有）
                    if self.lastSleightOfFistState == nil then
                        self.lastSleightOfFistState = false
                        self.lastNonSleightPosition = caster:GetAbsOrigin()
                    end
        
                    -- 获取当前状态
                    local currentSleightOfFistState = caster:HasModifier("modifier_ember_spirit_sleight_of_fist_caster_invulnerability")
                    
                    -- 如果从非SoF状态进入SoF状态，记录位置
                    if not self.lastSleightOfFistState and currentSleightOfFistState then
                        if log then self:log("进入Sleight of Fist状态，记录当前位置") end
                        self.lastNonSleightPosition = self.lastNonSleightPosition or caster:GetAbsOrigin()
                    end
                    
                    -- 如果从SoF状态退出，更新记录的位置
                    if self.lastSleightOfFistState and not currentSleightOfFistState then
                        if log then self:log("退出Sleight of Fist状态，更新记录位置") end
                        self.lastNonSleightPosition = caster:GetAbsOrigin()
                    end
        
                    -- 更新状态记录
                    self.lastSleightOfFistState = currentSleightOfFistState
        
                    -- 确定用于距离计算的位置
                    local positionForCalculation = currentSleightOfFistState and self.lastNonSleightPosition or caster:GetAbsOrigin()
                    
                    if log and currentSleightOfFistState then
                        self:log("使用记录的非Sleight of Fist位置进行计算")
                    end
        
                    local distance = (positionForCalculation - self.target:GetAbsOrigin()):Length2D()
                    
                    -- 根据不同的躲避模式使用不同的距离判定
                    local distanceThreshold = self:containsStrategy(self.hero_strategy, "躲避模式1000码") and 1000 or 700
                    
                    if distance <= distanceThreshold then
                        if log then 
                            self:log(string.format("躲避模式：目标距离 %.2f，小于等于%d，%s在Sleight of Fist中，返回true", 
                                distance, distanceThreshold, currentSleightOfFistState and "处于" or "不"))
                        end
                        return true
                    else
                        if log then 
                            self:log(string.format("躲避模式：目标距离 %.2f，大于%d，返回false", distance, distanceThreshold))
                        end
                        return false
                    end
                else
                    if log then self:log("非躲避模式：返回基础条件") end
                    return baseCondition
                end
            end
        },

        
        ["ember_spirit_fire_remnant"] = {
            function(self, caster, log)
                -- 检查是否处于躲避模式
                if self:containsStrategy(self.hero_strategy, "躲避模式") or self:containsStrategy(self.hero_strategy, "躲避模式1000码")  then
                    if caster:HasModifier("modifier_ember_spirit_fire_remnant") or caster:HasModifier("modifier_ember_spirit_fire_remnant_timer") then
                        if log then self:log("躲避模式：检测到modifier_ember_spirit_fire_remnant，返回false") end
                        return false
                    end
                end
                local requiredModifier = "modifier_ember_spirit_fire_remnant_timer"
        
                if self:containsStrategy(self.hero_strategy, "禁止连飞") and caster:HasModifier(requiredModifier) then
                    return false
                end
                
                -- 搜索残焰
                local remnants = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    3000,
                    DOTA_UNIT_TARGET_TEAM_BOTH,
                    DOTA_UNIT_TARGET_ALL, 
                    DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
                    FIND_ANY_ORDER,
                    false
                )
        
                -- 计算残焰数量（通过owner来判断）
                local remnantCount = 0
                for _, remnant in pairs(remnants) do
                    if remnant:GetUnitName() == "npc_dota_ember_spirit_remnant" and remnant:GetOwner() == caster then
                        remnantCount = remnantCount + 1
                    end
                end
        
                -- 如果残焰数量大于等于2，返回false
                if remnantCount >= 2 then
                    if log then self:log("检测到英雄拥有的残焰数量>=2，返回false") end
                    return false
                end
                
                return true
            end
        },
        ["ember_spirit_searing_chains"] = {
            function(self, caster, log)

                local ability = caster:FindAbilityByName("ember_spirit_searing_chains")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {"modifier_ember_spirit_searing_chains"},
                    0.5,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
    },


    ["npc_dota_hero_windrunner"] = {
        ["windrunner_shackleshot"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("windrunner_shackleshot")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "control" 
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        },
        ["windrunner_powershot"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "贴脸不射箭") and GetRealEnemyHeroesWithinDistance(caster, 600, log) ~= 0 then
                    return false
                else
                    return true
                end
            end
        },
        ["windrunner_windrun"] = {
            function(self, caster, log)

                return caster:GetHealthPercent() < 50
            end
        },

    },
    ["npc_dota_brewmaster"] = {
        ["brewmaster_primal_split_cancel"] = {
            function(self, caster, log)
                local nearbyUnits = FindUnitsInRadius(
                    caster:GetTeamNumber(), 
                    caster:GetOrigin(), 
                    nil, 
                    1000, 
                    DOTA_UNIT_TARGET_TEAM_BOTH, 
                    DOTA_UNIT_TARGET_ALL, 
                    DOTA_UNIT_TARGET_FLAG_NONE, 
                    FIND_ANY_ORDER, 
                    false
                )
                
                local brewmasterUnitsCount = 0
                for _, unit in pairs(nearbyUnits) do
                    -- 检查是否是熊猫单位且属于同一个玩家
                    if isBrewmasterUnit(unit:GetUnitName()) and unit:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
                        brewmasterUnitsCount = brewmasterUnitsCount + 1
                    end
                end
                
                if brewmasterUnitsCount == 1 and caster:GetHealthPercent() < 10 then
                    if log then self:log("Brewmaster unit is alone and health is below 10%") end
                    return true
                else
                    if log then self:log("Condition not met for Brewmaster primal split cancel") end
                    return false
                end
            end
        },
        ["brewmaster_storm_cyclone"] = {
            function(self, caster, log)

                if self:containsStrategy(self.hero_strategy, "无脑吹风") then
                    return true
                end
                local ability = caster:FindAbilityByName("brewmaster_storm_cyclone")
                
                -- 先找正在持续施法的目标
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {},
                    0,
                    "channeling", 
                    true
                )
            
                -- 如果找到目标且正在持续施法
                if potentialTarget and potentialTarget:IsChanneling() then
                    self.target = potentialTarget
                    log(string.format("[PANDA_TEST] 找到正在持续施法的目标: %s", self.target:GetUnitName()))
                    return true
                end
                
                -- 如果没找到持续施法的目标，找增益BUFF最多的目标
                potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    {},
                    0,
                    "dispellable_buffs",
                    true
                )
            
                if potentialTarget then
                    -- 检查是否有撒旦状态
                    if potentialTarget:HasModifier("modifier_item_satanic_unholy") then
                        self.target = potentialTarget
                        log(string.format("[PANDA_TEST] 找到增益BUFF最多的目标: %s", self.target:GetUnitName()))
                        log("[PANDA_TEST] 目标有撒旦状态")
                        return true
                    end

                    if potentialTarget:HasModifier("modifier_doom_bringer_doom_aura_self") then
                        self.target = potentialTarget

                        return true
                    end
                end
            
                -- 如果周围有敌方英雄，选择最近的一个
                local enemies = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    ability:GetCastRange(Vector(0,0,0), nil),
                    DOTA_UNIT_TARGET_TEAM_ENEMY,
                    DOTA_UNIT_TARGET_HERO,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_CLOSEST,
                    false
                )
            
                if #enemies > 1 then
                    self.target = enemies[1]
                    log(string.format("[PANDA_TEST] 找到周围的敌方英雄: %s", self.target:GetUnitName()))
                    return true
                end
            
                log("[PANDA_TEST] 没有找到合适的目标")
                return false
            end
        },
        ["brewmaster_storm_dispel_magic"] = {
            function(self, caster, log)
                if self.target:HasModifier("modifier_kez_falcon_rush") then
                    return true
                else
                    return false
                end
            end
        },
        
    },
    ["npc_dota_neutral_ogre_magi"] = {
        ["ogre_magi_frost_armor"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("ogre_magi_frost_armor")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_ogre_magi_frost_armor"},  -- 不需要检查buff
                    0.5,  -- 不需要检查剩余时间
                    "nearest_to_enemy",  -- 优先给离敌人最近的友军释放
                    false,
                    true
                )
                
                return self.Ally ~= nil
            end
        }
    },
    ["npc_dota_neutral_big_thunder_lizard"] = {
        ["big_thunder_lizard_frenzy"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("big_thunder_lizard_frenzy")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_big_thunder_lizard_frenzy"},  -- 不需要检查buff
                    0.5,  -- 不需要检查剩余时间
                    "attack",  -- 优先给离敌人最近的友军释放
                    false,
                    true
                )
                
                return self.Ally ~= nil
            end
        }
    },
    ["npc_dota_neutral_forest_troll_high_priest"] = {
        ["forest_troll_high_priest_heal"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("forest_troll_high_priest_heal")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    nil,  -- 不需要检查buff
                    nil,  -- 不需要检查剩余时间
                    "health_percent",  -- 优先给离敌人最近的友军释放
                    false,
                    true
                )
                
                return self.Ally ~= nil
            end
        }
    },
    ["npc_dota_neutral_froglet_mage"] = {
        ["frogmen_water_bubble_small"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("frogmen_water_bubble_small")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_frogmen_water_bubble"},  -- 不需要检查buff
                    0.5,  -- 不需要检查剩余时间
                    "health_percent",  -- 优先给离敌人最近的友军释放
                    false,
                    true
                )
                
                return self.Ally ~= nil
            end
        }
    },
    ["npc_dota_neutral_froglet_mage"] = {
        ["frogmen_water_bubble_small"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("frogmen_water_bubble_small")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_frogmen_water_bubble"},  -- 不需要检查buff
                    0.5,  -- 不需要检查剩余时间
                    "health_percent",  -- 优先给离敌人最近的友军释放
                    false,
                    true
                )
                
                return self.Ally ~= nil
            end
        }
    },
    ["npc_dota_neutral_grown_frog_mage"] = {
        ["frogmen_water_bubble_medium"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("frogmen_water_bubble_medium")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_frogmen_water_bubble"},  -- 不需要检查buff
                    0.5,  -- 不需要检查剩余时间
                    "health_percent",  -- 优先给离敌人最近的友军释放
                    false,
                    true
                )
                
                return self.Ally ~= nil
            end
        }
    },
    ["npc_dota_neutral_ancient_frog_mage"] = {
        ["frogmen_water_bubble_large"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("frogmen_water_bubble_large")
                if not ability then return false end
        
                self.Ally = self:FindBestAllyHeroTarget(
                    caster,
                    ability,
                    {"modifier_frogmen_water_bubble"},  -- 不需要检查buff
                    0.5,  -- 不需要检查剩余时间
                    "health_percent",  -- 优先给离敌人最近的友军释放
                    false,
                    true
                )
                
                return self.Ally ~= nil
            end
        }
    },
    ["npc_dota_neutral_harpy_scout"] = {
        ["harpy_scout_take_off"] = {
            function(self, caster, log)
                return false
            end
        }
    },
    ["npc_dota_neutral_prowler_shaman"] = {
        ["spawnlord_master_freeze"] = {
            function(self, caster, log)
                local currentAbility = caster:GetCurrentActiveAbility()
                if currentAbility then  
                    self:log("当前技能:" .. currentAbility:GetAbilityName())
                else
                    self:log("没有当前技能")
                end

                return true
            end
        }
    },

    ["custom_roshan"] = {
        ["roshan_grab_and_throw"] = {
            function(self, caster, log)
                local ability = caster:FindAbilityByName("roshan_grab_and_throw")
                if not ability then return false end
                
                local potentialTarget = self:FindBestEnemyHeroTarget(
                    caster,
                    ability,
                    nil,
                    nil,
                    "distance",
                    true
                )
                
                if potentialTarget then
                    self.target = potentialTarget
                end

                return potentialTarget ~= nil
            end
        }
    },



    ["npc_dota_visage_familiar"] = {
        ["visage_summon_familiars_stone_form"] = {
            function(self, caster, log)
                local currentTime = GameRules:GetGameTime()
                
                self:log(string.format("检查石化条件 - 当前时间: %.2f, 上次施法时间: %.2f", 
                    currentTime, VisageFamiliarCoordinator.lastCastTime))

                if self:containsStrategy(self.hero_strategy, "残血坐鸟") and caster:GetHealthPercent()<30 then
                    self:log("死灵龙血量低于阈值，立即石化")
                    VisageFamiliarCoordinator:RecordCast()
                    return true

                else
                    -- if not VisageFamiliarCoordinator:CanCastAgain() then
                    --     self:log(string.format("石化仍在锁定中，剩余锁定时间: %.2f", 
                    --         VisageFamiliarCoordinator.castLockDuration - (currentTime - VisageFamiliarCoordinator.lastCastTime)))
                    --     return false
                    -- end

                    -- if not self.target then
                    --     self:log("没有可用目标")
                    --     return false
                    -- end

                    -- if self:NeedsModifierRefresh(self.target, {"modifier_stunned"}, 0.3) then
                    --     self:log("目标眩晕即将结束，准备刷新石化")
                    --     VisageFamiliarCoordinator:RecordCast()
                    --     return true
                    -- end

                    -- self:log("不满足任何石化条件")
                    return false
                end
            end
        }
    },
    ["npc_dota_hero_visage"] = {
        ["visage_stone_form_self_cast"] = {
            function(self, caster, log)
                -- 检查是否在0.3秒冷却时间内
                if self.lastStoneFormTime and (GameRules:GetGameTime() - self.lastStoneFormTime) < 0.3 then
                    self:log("冷却时间没到")
                    return false
                end
        
                -- 首先检查是否包含"残血坐鸟"策略
                if self:containsStrategy(self.hero_strategy, "残血坐鸟") then
                    if caster:GetHealthPercent()<30 then
                        -- 检查目标是否需要刷新眩晕
                        if self:NeedsModifierRefresh(self.target, {"modifier_stunned"}, 0.5) then
                            -- 检查目标附近是否有维萨吉魔像
                            local units = FindUnitsInRadius(
                                caster:GetTeamNumber(),
                                self.target:GetAbsOrigin(),
                                nil,
                                375,
                                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                DOTA_UNIT_TARGET_ALL,
                                DOTA_UNIT_TARGET_FLAG_NONE,
                                FIND_ANY_ORDER,
                                false
                            )
        
                            for _, unit in pairs(units) do
                                if not unit:IsHero() and string.find(unit:GetUnitName(), "npc_dota_visage_familiar") then
                                    self.lastStoneFormTime = GameRules:GetGameTime()
                                    return true
                                end
                            end
                            return false
                        end
                        return false
                    else
                        return false
                    end
                else
                    -- 不是残血坐鸟策略时，直接检查目标是否需要刷新眩晕和周围是否有魔像
                    if self:NeedsModifierRefresh(self.target, {"modifier_stunned"}, 0.5) then
                        local units = FindUnitsInRadius(
                            caster:GetTeamNumber(),
                            self.target:GetAbsOrigin(),
                            nil,
                            375,
                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                            DOTA_UNIT_TARGET_ALL,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_ANY_ORDER,
                            false
                        )
                
                        for _, unit in pairs(units) do
                            if not unit:IsHero() and string.find(unit:GetUnitName(), "npc_dota_visage_familiar") then
                                self.lastStoneFormTime = GameRules:GetGameTime()
                                self:log("找到范围内的维萨吉魔像，可以使用石化")
                                return true
                            end
                        end
                        self:log("范围内没有找到维萨吉魔像，不使用石化")
                        return false
                    end
                    return false
                end
            end
        },
        ["visage_gravekeepers_cloak"] = {
            function(self, caster, log)
                if self:containsStrategy(self.hero_strategy, "满血石化") then
                    return true
                end
                return caster:GetHealthPercent() < 30
            end
        },
        ["visage_summon_familiars"] = {
            function(self, caster, log)
                -- 如果生命值低于30%直接返回true
                if caster:GetHealthPercent() < 30 then
                    return true
                end
                
                -- 查找周围1200范围内的魔像数量
                local units = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    1200,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_ALL,
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_ANY_ORDER,
                    false
                )
                
                local familiarCount = 0
                for _, unit in pairs(units) do
                    if not unit:IsHero() and string.find(unit:GetUnitName(), "npc_dota_visage_familiar") then
                        familiarCount = familiarCount + 1
                    end
                end
                
                -- 如果魔像数量小于等于1返回true
                return familiarCount <= 1
            end
        }
    },
    ["npc_dota_hero_lone_druid"] = {
        ["lone_druid_spirit_bear"] = {
            function(self, caster, log)
                local units = FindUnitsInRadius(
                    caster:GetTeamNumber(),
                    caster:GetAbsOrigin(),
                    nil,
                    1200,
                    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                    DOTA_UNIT_TARGET_HERO,  -- 已经限定了只搜索英雄单位
                    DOTA_UNIT_TARGET_FLAG_NONE,
                    FIND_CLOSEST,
                    false
                )
                
                local casterPlayer = caster:GetPlayerOwner()
                
                for _, unit in pairs(units) do
                    local unitName = unit:GetUnitName()
                    self:log("找到单位：" .. unitName)
                    
                    -- 添加 not IsIllusion 判断来排除幻象
                    if not unit:IsIllusion() and
                       string.find(unitName, "npc_dota_lone_druid_bear") and
                       unit:GetPlayerOwner() == casterPlayer then
                        -- 找到自己的熊了，如果血量低于10%需要重新召唤
                        if unit:GetHealthPercent() < 10 then
                            self:log("找到熊但血量低于10%，需要重新召唤")
                            return true
                        end
                        -- 熊血量正常，不需要重新召唤
                        self:log("找到熊且血量正常，不需要重新召唤")
                        return false
                    end
                end
                
                -- 没找到熊，需要召唤
                self:log("没找到熊，需要召唤")
                return true
            end
        }
    },
}

function CommonAI:shouldRemoveAbility(index)
    if index == nil then
        return false
    end
    if self:containsStrategy(self.global_strategy, "禁用一技能") and index == 0 then
        return true
    end
    if self:containsStrategy(self.global_strategy, "禁用二技能") and index == 1 then
        return true
    end
    if self:containsStrategy(self.global_strategy, "禁用三技能") and index == 2 then
        return true
    end
    if self:containsStrategy(self.global_strategy, "禁用四技能") and index == 3 then
        return true
    end
    if self:containsStrategy(self.global_strategy, "禁用五技能") and index == 4 then
        return true
    end
    if self:containsStrategy(self.global_strategy, "禁用大招") or self.entity:HasModifier("modifier_morphling_replicate_morphed_illusions_effect") then
        local ability = self.entity:GetAbilityByIndex(index)
        if ability and ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
            return true
        end
    end

    local ability = self.entity:GetAbilityByIndex(index)
    if ability then
        local abilityName = ability:GetAbilityName()
        
        -- 极速冷却
        if self:containsStrategy(self.hero_strategy, "禁用极速冷却") and abilityName == "invoker_cold_snap" then
            return true
        end
        
        -- 幽灵漫步
        if self:containsStrategy(self.hero_strategy, "禁用幽灵漫步") and abilityName == "invoker_ghost_walk" then
            return true
        end
        
        -- 吹风
        if self:containsStrategy(self.hero_strategy, "禁用吹风") and abilityName == "invoker_tornado" then
            return true
        end
        
        -- 磁暴
        if self:containsStrategy(self.hero_strategy, "禁用磁暴") and abilityName == "invoker_emp" then
            return true
        end
        
        -- 灵动迅捷
        if self:containsStrategy(self.hero_strategy, "禁用灵动迅捷") and abilityName == "invoker_alacrity" then
            return true
        end
        
        -- 陨石
        if self:containsStrategy(self.hero_strategy, "禁用陨石") and abilityName == "invoker_chaos_meteor" then
            return true
        end
        
        -- 天火
        if self:containsStrategy(self.hero_strategy, "禁用天火") and abilityName == "invoker_sun_strike" then
            return true
        end
        
        -- 火元素
        if self:containsStrategy(self.hero_strategy, "禁用火元素") and abilityName == "invoker_forge_spirit" then
            return true
        end
        
        -- 冰墙
        if self:containsStrategy(self.hero_strategy, "禁用冰墙") and abilityName == "invoker_ice_wall" then
            return true
        end
    end

    return false
end

function CommonAI:checkAbilities(caster, excludeAbilities)
    self:log("开始检查技能 - 英雄:", caster:GetUnitName())
    
    -- 获取英雄实际的技能数量
    local maxAbilities = caster:GetAbilityCount() - 1
    
    for i = 0, maxAbilities do
        local ability = caster:GetAbilityByIndex(i)
        if ability then
            local abilityName = ability:GetAbilityName()
                        local heroName = caster:GetUnitName()

            if not self:shouldSkipAbility(ability, abilityName, heroName, excludeAbilities, i) then
                self:log("找到可用技能:", abilityName)
                return false
            end
        end
    end
    
    self:log("没有找到可用技能")
    return true
end

function CommonAI:shouldSkipAbility(ability, abilityName, heroName,excludeAbilities, index)
    self:log("检查技能:", abilityName)

    -- 检查是否应该被禁用
    if self:shouldRemoveAbility(index) then
        self:log("  技能被全局策略禁用，跳过")
        return true
    end

    -- 始终排除 morphling_replicate
    if abilityName == "morphling_morph_replicate" or abilityName == "morphling_replicate" then
        self:log("  morphling_morph_replicate 技能，始终排除")
        return true
    end

    self:log("  当前冷却时间:", ability:GetCooldownTimeRemaining())
    self:log("  技能等级:", ability:GetLevel())
    self:log("  是否被动:", bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_PASSIVE) ~= 0)

    if excludeAbilities[abilityName] then
        self:log("  技能在排除列表中，跳过")
        return true
    end

    if self.disabledSkills[heroName] and self:IsDisabledSkill(abilityName, heroName) then
        self:log("  技能被禁用，跳过")
        self:log(string.format("忽略禁用的技能 %s", abilityName))
        return true
    end

    if abilityName == "generic_hidden" or abilityName:find("^special_bonus") then
        self:log("  特殊技能，跳过")
        self:log(string.format("忽略技能 %s", abilityName))
        return true
    end

    if bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_PASSIVE) ~= 0 then
        self:log("  被动技能，跳过")
        self:log(string.format("忽略被动技能 %s", abilityName))
        return true
    end

    if not self:IsSkillReady(ability) then
        self:log("  技能不可用，跳过")
        self:log(string.format("技能 %s 不能使用", abilityName))
        return true
    end

    if self.autoCastSkills[abilityName] or self.toggleSkills[abilityName] then
        self:log("  自动施法或切换技能，跳过")
        self:log(string.format("忽略已经处理过的技能 %s", abilityName))
        return true
    end

    self:log("  技能通过所有检查")
    return false
end

function CommonAI:getMinCooldownOfValidSkills(caster, excludeAbilities)
    local minCooldown = math.huge
    
    local function isValidSkill(ability, abilityName, heroName)
        -- 始终排除 morphling_replicate
        if abilityName == "morphling_morph_replicate" or abilityName == "morphling_replicate" then
            return false
        end

        -- 检查排除列表
        if excludeAbilities[abilityName] then
            return false
        end

        -- 检查禁用技能
        if self.disabledSkills[heroName] and self:IsDisabledSkill(abilityName, heroName) then
            return false
        end

        -- 检查特殊技能
        if abilityName == "generic_hidden" or abilityName:find("^special_bonus") then
            return false
        end

        -- 检查被动技能
        if bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_PASSIVE) ~= 0 then
            return false
        end

        -- 检查自动施法和切换技能
        if self.autoCastSkills[abilityName] or self.toggleSkills[abilityName] then
            return false
        end

        -- 检查技能是否有等级且不是被动
        if ability:GetLevel() <= 0 then
            return false
        end

        -- 只有因为冷却时间而不能释放的技能才是有效的
        local cooldownRemaining = ability:GetCooldownTimeRemaining()
        -- 如果技能在冷却中，且不是因为魔法不足等其他原因
        if cooldownRemaining > 0 and ability:GetManaCost(ability:GetLevel()) <= caster:GetMana() then
            return true
        end

        return false
    end


    for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex(i)
        if ability then
            local abilityName = ability:GetAbilityName()
            local heroName = caster:GetUnitName()
    
            if isValidSkill(ability, abilityName, heroName) then
                local cooldown = ability:GetCooldownTimeRemaining()
                if cooldown < minCooldown then
                    minCooldown = cooldown
                end
            end
        end
    end
    
    return minCooldown ~= math.huge and minCooldown or 0
end

function CommonAI:CheckSkillConditions(entity, heroName)
    local conditionName = string.find(heroName, "npc_dota_brewmaster") 
        and "npc_dota_brewmaster" 
        or (string.find(heroName, "npc_dota_visage_familiar") 
            and "npc_dota_visage_familiar" 
            or heroName)
    
    local isSpecialHero = heroName == "npc_dota_hero_morphling" or heroName == "npc_dota_hero_rubick"
    local heroConditions = isSpecialHero and {} or (HeroSkillConditions[conditionName] or {})

    self:log(string.format("检查英雄 %s 的技能条件", heroName))

    if not self.disabledSkills[heroName] then
        self.disabledSkills[heroName] = {}
    end

    -- 确保 dazzle_nothl_projection_end 始终在禁用列表中
    if not self:tableContains(self.disabledSkills[heroName], "dazzle_nothl_projection_end") then
        table.insert(self.disabledSkills[heroName], "dazzle_nothl_projection_end")
    end

    local abilities = {}
    for i = 0, entity:GetAbilityCount() - 1 do
        local ability = entity:GetAbilityByIndex(i)
        if ability and ability:GetAbilityName() then
            --技能冷却好了并且已经学习过
            if ability:IsCooldownReady() and ability:GetLevel() > 0 then
                table.insert(abilities, ability)
            else
                --self:log(string.format("技能 %s 在冷却中，忽略检查", ability:GetAbilityName()))
            end
        end
    end

    for _, ability in ipairs(abilities) do
        local abilityName = ability:GetAbilityName()
        
        -- 跳过 dazzle_nothl_projection_end 的检查
        if abilityName == "dazzle_nothl_projection_end" then
            goto continue
        end

        local isBelowThreshold = self:IsHPBelowSkillThreshold(ability, entity)
        if not self.disabledSkills_Threshold[heroName] then
            self.disabledSkills_Threshold[heroName] = {}
        end
        if not isBelowThreshold then
            -- 未通过检查的日志
            local currentHp = entity:GetHealthPercent()
            -- 先检查表是否存在，如果不存在则初始化
            if not self:tableContains(self.disabledSkills_Threshold[heroName], abilityName) then
                table.insert(self.disabledSkills_Threshold[heroName], abilityName)
                self:log(string.format("已将 %s 添加到 %s 的禁用列表中", abilityName, heroName))
            else
                self:log(string.format(" %s 已在 %s 的禁用列表中", abilityName, heroName))
            end
            goto continue
        else
            -- 通过检查的日志
            --self:log(string.format("英雄 %s 的大招 %s 通过检查", heroName, abilityName))
            
            -- 检查是否在禁用列表中
            local found = false
            for i, skill in ipairs(self.disabledSkills_Threshold[heroName]) do
                if skill == abilityName then
                    found = true
                    local abilityIndex = ability and ability:GetAbilityIndex() or -1
                    table.remove(self.disabledSkills_Threshold[heroName], i)
                    --self:log(string.format("大招 %s 通过检查,已从禁用列表中移除，技能索引为: %d", abilityName, abilityIndex))
                    break
                end
            end
            if not found then
                --self:log(string.format("大招 %s 不在禁用列表中，无需移除", abilityName))
            end
        end

        local conditions = isSpecialHero and self:FindConditionsForAbility(abilityName) or heroConditions[abilityName]
    
        if conditions then
            if SkillMeetsConditions(self, entity, abilityName, conditions, function(msg) self:log(msg) end) then
                self:log(string.format("技能 %s 条件满足", abilityName))
                for i, skill in ipairs(self.disabledSkills[heroName]) do
                    if skill == abilityName then
                        local ability = entity:FindAbilityByName(abilityName)
                        local abilityIndex = ability and ability:GetAbilityIndex() or -1
                        table.remove(self.disabledSkills[heroName], i)
                        self:log(string.format("技能 %s 已从禁用列表中移除，技能索引为: %d", abilityName, abilityIndex))
                        break
                    end
                end
            else
                if not self:tableContains(self.disabledSkills[heroName], abilityName) then
                    table.insert(self.disabledSkills[heroName], abilityName)
                end
            end
        else
            --self:log(string.format("技能 %s 没有定义的条件", abilityName))
        end
        
        ::continue::
    end
end

-- function CommonAI:CheckUltimateConditions(ability, entity)
--     if not ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
--         return true -- 不是大招直接返回true，不参与检查
--     end

--     local healthPct = entity:GetHealthPercent()
--     self:log("检测到大招:", ability:GetAbilityName(), "当前血量百分比:", healthPct)
    
--     if self:containsStrategy(self.global_strategy, "不到半血绝不放大") and healthPct > 50 then
--         self:log("启用策略:不到半血绝不放大,血量大于50%,禁止释放大招")
--         return false
--     end
    
--     if self:containsStrategy(self.global_strategy, "不到80%血绝不放大") and healthPct > 80 then
--         self:log("启用策略:不到80%血绝不放大,血量大于80%,禁止释放大招") 
--         return false
--     end
--     self:log("可以放大了")
--     return true
-- end

function CommonAI:FindConditionsForAbility(abilityName)
    self:log("正在查找技能条件: " .. abilityName)
    print("正在查找技能条件: " .. abilityName)
    for _, heroConditions in pairs(HeroSkillConditions) do
        if heroConditions[abilityName] then
            return heroConditions[abilityName]
        end
    end
    return nil
end


function GetEnemiesWithinDistance(caster, distance, log)
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                                      caster:GetAbsOrigin(),
                                      nil,
                                      distance,
                                      DOTA_UNIT_TARGET_TEAM_ENEMY,
                                      DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                                      DOTA_UNIT_TARGET_FLAG_NONE,
                                      FIND_ANY_ORDER,
                                      false)
    log(string.format("在 %d 距离内找到 %d 个敌人", distance, #enemies))
    return #enemies
end

function GetRealEnemyHeroesWithinDistance(caster, distance, log)
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
                                      caster:GetAbsOrigin(),
                                      nil,
                                      distance,
                                      DOTA_UNIT_TARGET_TEAM_ENEMY,
                                      DOTA_UNIT_TARGET_HERO,
                                      DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
                                      FIND_ANY_ORDER,
                                      false)
    
    -- 过滤掉可能的召唤物英雄（如熊德的熊）
    local realEnemyHeroes = {}
    for _, enemy in ipairs(enemies) do
        if enemy:IsRealHero() and not enemy:IsTempestDouble() then
            table.insert(realEnemyHeroes, enemy)
        end
    end
    
    log(string.format("在 %d 距离内找到 %d 个真实敌方英雄", distance, #realEnemyHeroes))
    return #realEnemyHeroes
end

function HasHauntIllusions(caster, log)
    -- 查找所有友方英雄单位
    local allies = FindUnitsInRadius(caster:GetTeamNumber(),
                                     caster:GetAbsOrigin(),
                                     nil,
                                     FIND_UNITS_EVERYWHERE,
                                     DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                     DOTA_UNIT_TARGET_HERO,
                                     DOTA_UNIT_TARGET_FLAG_NONE,
                                     FIND_ANY_ORDER,
                                     false)
    log(string.format("找到 %d 个友方英雄单位", #allies))

    for _, ally in ipairs(allies) do
        if ally:IsIllusion() and ally:HasModifier("modifier_spectre_haunt") then
            log("找到带有 modifier_spectre_haunt 的幻象")
            return true
        end
    end
    return false
end


-- function CommonAI:RikiSmokeScreenRecentlyUsed(caster, log)
--     local abilityName = "riki_smoke_screen"
--     local cooldownTime = 2

--     if not self:SkillRecentlyUsed(caster, abilityName, cooldownTime, log) then
--         local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
--                                           caster:GetAbsOrigin(),
--                                           nil,
--                                           FIND_UNITS_EVERYWHERE,
--                                           DOTA_UNIT_TARGET_TEAM_ENEMY,
--                                           DOTA_UNIT_TARGET_HERO,
--                                           DOTA_UNIT_TARGET_FLAG_NONE,
--                                           FIND_ANY_ORDER,
--                                           false)
--         for _, enemy in ipairs(enemies) do
--             if enemy:HasModifier("modifier_riki_smoke_screen") then
--                 log("敌人带有 modifier_riki_smoke_screen")
--                 return false
--             end
--         end
--     end

--     return true
-- end


function CommonAI:SkillRecentlyUsed(caster, abilityName, cooldownTime, log)
    if not self.lastSkillCastTimes then
        self.lastSkillCastTimes = {}
    end

    local currentTime = GameRules:GetGameTime()

    if not self.lastSkillCastTimes[abilityName] then
        self.lastSkillCastTimes[abilityName] = currentTime
        log("第一次运行 " .. abilityName .. "，记录当前时间")
        return true
    end

    if (currentTime - self.lastSkillCastTimes[abilityName] <= cooldownTime) then
        log(abilityName .. " 最近一次释放时间小于" .. cooldownTime .. "秒")
        return false
    else
        self.lastSkillCastTimes[abilityName] = currentTime
    end

    return true
end


function hasHeroesNearby(self,caster, radius)
    local allies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetAbsOrigin(),
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_ALL,
        DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_NOT_SUMMONED, -- 排除幻象和召唤单位
        FIND_CLOSEST,
        false
    )

    -- 确保选中的单位不是自己
    for _, ally in pairs(allies) do
        self:log("找到友方单位: " .. ally:GetUnitName() .. " 位置: " .. tostring(ally:GetOrigin()))
        if ally ~= caster then  -- 排除自身
            return ally
        end
    end
    return false
end


function isBrewmasterUnit(unitName)
    return string.match(unitName, "^npc_dota_brewmaster_")
end


function IsManaPercentageBelowThreshold(caster, threshold)
    local maxMana = caster:GetMaxMana()
    local currentMana = caster:GetMana()
    local manaPercentage = (currentMana / maxMana) * 100
    log(string.format("当前魔法值: %d, 最大魔法值: %d, 魔法值百分比: %.2f%%", currentMana, maxMana, manaPercentage))
    return manaPercentage < threshold
end


function IsHealthBelowValue(caster, thresholdValue, log)
    local currentHealth = caster:GetHealth()
    local maxHealth = caster:GetMaxHealth()
    log(string.format("当前生命值: %d, 最大生命值: %d", currentHealth, maxHealth))
    return currentHealth < thresholdValue
end


function CommonAI:EnemyHeroesInRange(caster, minRange, maxRange, log)
    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        caster:GetOrigin(),
        nil,
        maxRange,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    local count = 0
    for _, enemy in pairs(enemies) do
        local distance = (enemy:GetOrigin() - caster:GetOrigin()):Length2D()
        if distance >= minRange and distance <= maxRange then
            count = count + 1
        end
    end


    self:log(string.format("敌人数量在范围 %d 到 %d: %d", minRange, maxRange, count))


    return count
end

-- 判断技能是否满足条件
function SkillMeetsConditions(self, caster, abilityName, conditions, log)
    for _, condition in ipairs(conditions) do
        local result = condition(self, caster, log)
        log(string.format("技能 %s 条件 %s 结果: %s", abilityName, tostring(condition), tostring(result)))
        if not result then
            return false
        end
    end
    return true
end


function CommonAI:IsHPBelowSkillThreshold(ability, entity)
    local abilityName = ability:GetAbilityName()
    
    -- 定义特殊技能表，这些技能在"卡时间"策略下不受阈值限制
    local timeConstraintSkills = {
        ["storm_spirit_ball_lightning"] = true,
        ["storm_spirit_static_remnant"] = true,

        -- 可以在这里添加更多需要此逻辑的技能
    }

    -- 检查是否是特殊技能且满足"卡时间"策略条件
    if timeConstraintSkills[abilityName] then
        if self:containsStrategy(self.global_strategy, "卡时间") then
            if (Main.start_time + Main.limitTime + Main.duration) - GameRules:GetGameTime() <= 0.89 then
                self:log("[STORM_TEST] 卡时间策略生效，技能 " .. abilityName .. " 血量阈值不再生效")
                --打印差值
                self:log("[STORM_TEST] 差值: " .. (Main.start_time + Main.limitTime + Main.duration) - GameRules:GetGameTime())
                return true -- 血量阈值不再生效，直接返回true
            else
                self:log("[STORM_TEST] 卡时间策略失效，技能 " .. abilityName .. " 受血量阈值限制")
            end
        end
    end

    local skillKey = nil
    

    -- 判断是否是大招
    if ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
        --print("大招")
        skillKey = "skill6" -- 大招对应skill6
    else
        -- 普通技能根据索引判断
        local abilityIndex = ability:GetAbilityIndex() -- 从0开始的技能索引
        
        if abilityIndex == 0 then
            skillKey = "skill1" -- 第一个技能
        elseif abilityIndex == 1 then
            skillKey = "skill2" -- 第二个技能
        elseif abilityIndex == 2 then
            skillKey = "skill3" -- 第三个技能
        elseif abilityIndex == 3 then
            skillKey = "skill4" -- 第四个技能
        elseif abilityIndex == 4 then
            skillKey = "skill5" -- 第五个技能
        else
            -- 如果索引超出范围，直接返回true
            return true
        end
    end
    
    -- 如果没有对应的技能阈值设置或阈值为0，不做限制
    if not self.skillThresholds or not self.skillThresholds[skillKey] then

        return true
    end
    
    local healthPct = entity:GetHealthPercent()
    local hpThreshold = self.skillThresholds[skillKey].hpThreshold
    

    
    -- 当英雄血量低于等于阈值时，返回true，表示可以释放
    if healthPct <= hpThreshold then

        return true
    else

        return false
    end
end


function CommonAI:GetSkillRangeThreshold(ability, entity, range)
    local abilityName = ability:GetAbilityName()

    -- 检查是否是躲避技能，如果是则不做阈值限制
    if self.shouldUseDodgeSkills and self.currentAvailableDodgeSkills then
        for _, dodgeSkillName in ipairs(self.currentAvailableDodgeSkills) do
            if abilityName == dodgeSkillName then
                return range -- 躲避技能不受阈值限制
            end
        end
    end

    -- 定义特殊技能表，这些技能在"卡时间"策略下不受阈值限制
    local timeConstraintSkills = {
        ["storm_spirit_ball_lightning"] = true,

        -- 可以在这里添加更多需要此逻辑的技能
    }

    -- 检查是否是特殊技能且满足"卡时间"策略条件
    if timeConstraintSkills[abilityName] then
        if self:containsStrategy(self.global_strategy, "卡时间") then
            if (Main.start_time + Main.limitTime + Main.duration) - GameRules:GetGameTime() <= 0.89 then
                self:log("[STORM_TEST] 卡时间策略生效，技能 " .. abilityName .. " 不受阈值限制")
                return range -- 不受阈值限制，直接返回原始range
            else
                self:log("[STORM_TEST] 卡时间策略失效，技能 " .. abilityName .. " 受阈值限制")
                --打印差值
                self:log("[STORM_TEST] 差值: " .. (Main.start_time + Main.limitTime + Main.duration) - GameRules:GetGameTime())
            end
        end
    end

    local skillKey = nil
    
    -- 判断是否是大招
    if ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
        skillKey = "skill6" -- 大招对应skill6
    else
        -- 普通技能根据索引判断
        local abilityIndex = ability:GetAbilityIndex() -- 从0开始的技能索引
        
        if abilityIndex == 0 then
            skillKey = "skill1" -- 第一个技能
        elseif abilityIndex == 1 then
            skillKey = "skill2" -- 第二个技能
        elseif abilityIndex == 2 then
            skillKey = "skill3" -- 第三个技能
        elseif abilityIndex == 3 then
            skillKey = "skill4" -- 第四个技能
        elseif abilityIndex == 4 then
            skillKey = "skill5" -- 第五个技能
        else
            -- 如果索引超出范围，直接返回range
            return range
        end
    end
    
    -- 如果没有对应的技能距离阈值设置，返回range
    if not self.skillThresholds or not self.skillThresholds[skillKey] or not self.skillThresholds[skillKey].distThreshold then

        return range
    end
    
    local distThreshold = self.skillThresholds[skillKey].distThreshold
    
    -- 处理range为0的情况
    if range == 0 then
        if distThreshold == 0 then
            return 0
        end
    end
    if distThreshold == 0 then
        return range  -- 阈值为0时不限制，直接使用传入的range
    end

    return distThreshold

    -- 比较阈值和range，返回较小的值
    -- local result = math.min(distThreshold, range)

    
    -- return result
end


















