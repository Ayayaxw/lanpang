(function() {
    // 团队数据定义
    const g_TeamData = {
        1: { // 力量
            icon: "s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_strength_psd.vtex",
            className: "hero_chaos_1",
            kills: 0,
            remainingHeroes: 0,
            currentHero: "npc_dota_hero_axe",
            nextHero: "npc_dota_hero_axe"
        },
        2: { // 敏捷
            icon: "s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_agility_psd.vtex",
            className: "hero_chaos_2",
            kills: 0,
            remainingHeroes: 0,
            currentHero: "npc_dota_hero_antimage",
            nextHero: "npc_dota_hero_antimage"
        },
        4: { // 智力
            icon: "s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_intelligence_psd.vtex",
            className: "hero_chaos_4",
            kills: 0,
            remainingHeroes: 0,
            currentHero: "npc_dota_hero_crystal_maiden",
            nextHero: "npc_dota_hero_crystal_maiden"
        },
        8: { // 全才
            icon: "s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_all_psd.vtex",
            className: "hero_chaos_8",
            kills: 0,
            remainingHeroes: 0,
            currentHero: "npc_dota_hero_marci",
            nextHero: "npc_dota_hero_marci"
        }
    };

    // 存储面板数据
    let g_TeamPanels = {};

    function CreateTeamPanel(type) {
        const container = $('#hero_chaos_TeamPanelsContainer');
        if (!container) {
            $.Msg("Error: Cannot find TeamPanelsContainer!");
            return;
        }
    
        const panel = $.CreatePanel('Panel', container, '');
        panel.AddClass('hero_chaos_TeamPanel');
        panel.AddClass(g_TeamData[type].className);
    
        // 创建所有正常内容
        const upperSection = $.CreatePanel('Panel', panel, '');
        upperSection.AddClass('hero_chaos_UpperSection');

        // 创建属性图标
        const icon = $.CreatePanel('Image', upperSection, '');
        icon.AddClass('hero_chaos_TeamTitle');
        icon.SetImage(g_TeamData[type].icon);

        // 创建英雄部分
        const heroesSection = $.CreatePanel('Panel', upperSection, '');
        heroesSection.AddClass('hero_chaos_HeroesSection');

        // 创建主英雄头像
        const mainHero = $.CreatePanel('DOTAHeroImage', heroesSection, '');
        mainHero.AddClass('hero_chaos_HeroPortrait');
        mainHero.heroname = g_TeamData[type].currentHero;
        mainHero.heroimagestyle = "landscape";
        mainHero.scaling = "stretch-to-fit-preserve-aspect";

        // 创建次要部分
        const secondarySection = $.CreatePanel('Panel', heroesSection, '');
        secondarySection.AddClass('hero_chaos_SecondarySection');
    
        // Add wrapper panel
        const secondaryWrapper = $.CreatePanel('Panel', secondarySection, '');
        secondaryWrapper.AddClass('hero_chaos_SecondaryWrapper');
    
        const secondaryHero = $.CreatePanel('DOTAHeroImage', secondaryWrapper, '');
        secondaryHero.AddClass('hero_chaos_HeroPortrait');
        secondaryHero.AddClass('hero_chaos_Secondary');
        secondaryHero.heroname = g_TeamData[type].nextHero;
        secondaryHero.heroimagestyle = "landscape";
        secondaryHero.scaling = "stretch-to-fit-preserve-aspect";
    
        // Add overlay panel as a sibling
        const secondaryOverlay = $.CreatePanel('Panel', secondaryWrapper, '');
        secondaryOverlay.AddClass('hero_chaos_SecondaryOverlay');

        const remainingCount = $.CreatePanel('Label', secondarySection, '');
        remainingCount.AddClass('hero_chaos_RemainingCount');
        const remainingIcon = $.CreatePanel('Image', secondarySection, '');
        remainingIcon.AddClass('hero_chaos_RemainingIcon');
        remainingIcon.SetImage("s2r://panorama/images/hud/reborn/heart_psd.vtex");
        remainingCount.text = g_TeamData[type].remainingHeroes;

        // 修改下半部分代码
        const lowerSection = $.CreatePanel('Panel', panel, '');
        lowerSection.AddClass('hero_chaos_LowerSection');

        // 添加血条容器
        const healthContainer = $.CreatePanel('Panel', lowerSection, '');
        healthContainer.AddClass('hero_chaos_HealthContainer');

        const healthBar = $.CreatePanel('Panel', healthContainer, '');
        healthBar.AddClass('hero_chaos_HealthBar');

        const healthFill = $.CreatePanel('Panel', healthBar, '');
        healthFill.AddClass('hero_chaos_HealthFill');

        // 创建右侧统计面板容器
        const statsContainer = $.CreatePanel('Panel', lowerSection, '');
        statsContainer.AddClass('hero_chaos_StatsContainer');

        // 死亡计数部分
        const deathsCount = $.CreatePanel('Panel', statsContainer, '');
        deathsCount.AddClass('hero_chaos_DeathsCount');

        const deathsIcon = $.CreatePanel('Image', deathsCount, '');
        deathsIcon.AddClass('hero_chaos_DeathsIcon');
        deathsIcon.SetImage("s2r://panorama/images/hud/reborn/icon_death_psd.vtex");

        const deathsLabel = $.CreatePanel('Label', deathsCount, '');
        deathsLabel.AddClass('hero_chaos_DeathsCountLabel');
        deathsLabel.text = '0';

        // 击杀计数部分
        const killsCount = $.CreatePanel('Panel', statsContainer, '');
        killsCount.AddClass('hero_chaos_KillsCount');

        const killsIcon = $.CreatePanel('Image', killsCount, '');
        killsIcon.AddClass('hero_chaos_KillsIcon');
        killsIcon.SetImage("s2r://panorama/images/hud/reborn/icon_damage_psd.vtex");

        const killsLabel = $.CreatePanel('Label', killsCount, '');
        killsLabel.AddClass('hero_chaos_KillsCountLabel');
        killsLabel.text = g_TeamData[type].kills;

        // 更新面板引用
        const outWrapper = $.CreatePanel('Panel', panel, '');
        outWrapper.AddClass('hero_chaos_OutWrapper');
        
        const outLabel = $.CreatePanel('Label', outWrapper, '');
        outLabel.AddClass('hero_chaos_OutLabel');
        outLabel.text = "OUT";
    
        g_TeamPanels[type] = {
            panel: panel,
            mainHero: mainHero,
            secondaryHero: secondaryHero,
            remainingCount: remainingCount,
            killsLabel: killsLabel,
            deathsLabel: deathsLabel,
            healthFill: healthFill,
            outWrapper: outWrapper
        };
    
        return panel;
    }


    function ShowContainer() {
        const container = $('#hero_chaos_TeamPanelsContainer');
        if (container) {
            container.RemoveClass('hero_chaos_hidden');
            $.Msg("Container shown");
        }
    }

    // 隐藏容器
    function HideContainer() {
        const container = $('#hero_chaos_TeamPanelsContainer');
        if (container) {
            container.AddClass('hero_chaos_hidden');
            $.Msg("Container hidden");
        }
    }

    function SetupPanels(types) {
        const container = $('#hero_chaos_TeamPanelsContainer');
        if (!container) {
            $.Msg("Error: Container not found!");
            return;
        }
    
        $.Msg("Creating panels for types:", types);
        container.RemoveAndDeleteChildren();
        g_TeamPanels = {};
    
        for (let type of types) {
            const panel = CreateTeamPanel(type);
            if (panel) {
                $.Msg("Successfully created panel for type:", type);
            } else {
                $.Msg("Failed to create panel for type:", type);
            }
        }
    }

    // 更新单个面板数据
    function UpdateTeamPanel(type, data) {
        const panelData = g_TeamPanels[type];
        if (!panelData) return;
    
        if (data.currentHero) {
            panelData.mainHero.heroname = data.currentHero;
        }
        if (data.nextHero) {
            panelData.secondaryHero.heroname = data.nextHero;
            panelData.secondaryHero.RemoveClass('no_next_hero');
        } else {
            panelData.secondaryHero.AddClass('no_next_hero');
        }
        
        if (data.remainingHeroes !== undefined && data.totalHeroes !== undefined) {
            panelData.remainingCount.text = "剩余:" + data.remainingHeroes;
            const healthPercentage = (data.remainingHeroes / data.totalHeroes) * 100;
            panelData.healthFill.style.width = healthPercentage + "%";
            
            // 检查是否所有英雄都已阵亡
            if (data.remainingHeroes <= 0) {
                panelData.panel.AddClass('team_eliminated');
                panelData.outWrapper.AddClass('show_team_overlay');
            } else {
                panelData.panel.RemoveClass('team_eliminated');
                panelData.outWrapper.RemoveClass('show_team_overlay');
            }
        }
        
        if (data.kills !== undefined) {
            panelData.killsLabel.text = data.kills;
        }
        if (data.deadHeroes !== undefined) {
            panelData.deathsLabel.text = data.deadHeroes;
        }
    }

    // 注册事件处理函数
    GameEvents.Subscribe("show_hero_chaos_container", function() {
        $.Msg("Showing container");
        ShowContainer();
    });

    GameEvents.Subscribe("hide_hero_chaos_container", function() {
        $.Msg("Hiding container");
        HideContainer();
    });

    GameEvents.Subscribe("setup_hero_chaos_panels", function(data) {
        $.Msg("Setting up panels, received data:", data);
        
        // 转换类型数组
        const types = [];
        if (data && data.types) {
            // 如果是对象，提取所有值
            if (typeof data.types === 'object') {
                for (let key in data.types) {
                    types.push(data.types[key]);
                }
            }
            // 排序以确保顺序正确 (1,2,4,8)
            types.sort((a, b) => a - b);
        }
        
        $.Msg("Processed types array:", types);
        SetupPanels(types);
    });

    GameEvents.Subscribe("update_team_data", function(data) {
        $.Msg("Updating team data:", data);
        UpdateTeamPanel(data.type, data);
    });


    const testData = {
        1: {
            type: 1,
            currentHero: "npc_dota_hero_axe",
            nextHero: "npc_dota_hero_pudge",
            remainingHeroes: 8,
            totalHeroes: 10,
            kills: 3,
            deadHeroes: 2
        },
        2: {
            type: 2,
            currentHero: "npc_dota_hero_antimage",
            nextHero: "npc_dota_hero_drow_ranger",
            remainingHeroes: 7,
            totalHeroes: 10,
            kills: 2,
            deadHeroes: 3
        }
    };
    
    // 测试函数
    function TestPanels() {
        $.Msg("Starting panel test...");
        
        // 确保容器可见
        ShowContainer();
        
        // 只创建两个面板
        const types = Object.keys(testData).map(Number);  // 只获取testData中定义的类型
        SetupPanels(types);
        
        // 使用测试数据更新面板
        $.Msg("Updating panels with test data...");
        for (let type of types) {
            UpdateTeamPanel(type, testData[type]);
        }
    
        // 3秒后测试动态更新
        $.Schedule(3, function() {
            $.Msg("Testing dynamic updates...");
            // 测试第二个队伍的状态变化
            UpdateTeamPanel(2, {
                type: 2,
                currentHero: "npc_dota_hero_antimage",
                nextHero: null,
                remainingHeroes: 3,
                totalHeroes: 10,
                kills: 4,
                deadHeroes: 7
            });
        });
    
        // 6秒后测试更多状态
        $.Schedule(6, function() {
            $.Msg("Testing more states...");
            // 测试第一个队伍的状态变化
            UpdateTeamPanel(1, {
                type: 1,
                currentHero: "npc_dota_hero_axe",
                nextHero: null,
                remainingHeroes: 2,
                totalHeroes: 10,
                kills: 5,
                deadHeroes: 8
            });
        });
    
        // 9秒后测试恢复状态
        $.Schedule(9, function() {
            $.Msg("Testing recovery states...");
            // 恢复两个队伍的状态
            for (let type of types) {
                UpdateTeamPanel(type, testData[type]);
            }
        });
    }
    
    // 立即执行测试
    //TestPanels();


})();