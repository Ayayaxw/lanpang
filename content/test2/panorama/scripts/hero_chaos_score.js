(function() {
    let g_ScoreRoot = null;
    let g_TeamGrid = null;
    let g_CurrentGrid = null;
    let g_PersonalGrid = null;
    let g_ShowCurrentGrid = false;

    function Initialize() {
        // 获取根面板
        g_ScoreRoot = $('#hero_chaos_score_root');
    
        // 创建主面板
        const mainBoard = $.CreatePanel('Panel', g_ScoreRoot, '');
        mainBoard.AddClass('hero_chaos_score_board');
    
        // 创建标题
        const titleLabel = $.CreatePanel('Label', mainBoard, '');
        titleLabel.AddClass('hero_chaos_score_title');
        titleLabel.text = "伤害榜";
    
        // 创建团队伤害部分
        const teamSection = $.CreatePanel('Panel', mainBoard, '');
        teamSection.AddClass('hero_chaos_score_section');
    
        const teamTitle = $.CreatePanel('Label', teamSection, '');
        teamTitle.AddClass('hero_chaos_score_section_title');
        teamTitle.text = "团队伤害";
    
        g_TeamGrid = $.CreatePanel('Panel', teamSection, 'hero_chaos_score_team_grid');
        g_TeamGrid.AddClass('hero_chaos_score_team_grid');
        CreateHeaderRow(g_TeamGrid, ["排名", "队伍", "击杀", "伤害"]);
    
        // 只在g_ShowCurrentGrid为true时创建当前登场部分
        if (g_ShowCurrentGrid) {
            // 添加分隔符
            const divider1 = $.CreatePanel('Panel', mainBoard, '');
            divider1.AddClass('hero_chaos_score_divider');
    
            // 创建当前登场部分
            const currentSection = $.CreatePanel('Panel', mainBoard, '');
            currentSection.AddClass('hero_chaos_score_section');
    
            const currentTitle = $.CreatePanel('Label', currentSection, '');
            currentTitle.AddClass('hero_chaos_score_section_title');
            currentTitle.text = "当前登场";
    
            g_CurrentGrid = $.CreatePanel('Panel', currentSection, 'hero_chaos_score_current_grid');
            g_CurrentGrid.AddClass('hero_chaos_score_current_grid');
            CreateHeaderRow(g_CurrentGrid, ["属性", "英雄", "击杀", "伤害"]);
        }
    
        // 添加分隔符
        const divider2 = $.CreatePanel('Panel', mainBoard, '');
        divider2.AddClass('hero_chaos_score_divider');
    
        // 创建个人伤害部分
        const personalSection = $.CreatePanel('Panel', mainBoard, '');
        personalSection.AddClass('hero_chaos_score_section');
    
        const personalTitle = $.CreatePanel('Label', personalSection, '');
        personalTitle.AddClass('hero_chaos_score_section_title');
        personalTitle.text = "个人伤害";
    
        g_PersonalGrid = $.CreatePanel('Panel', personalSection, 'hero_chaos_score_personal_grid');
        g_PersonalGrid.AddClass('hero_chaos_score_personal_grid');
        CreateHeaderRow(g_PersonalGrid, ["排名", "英雄", "击杀", "伤害"]);
    
        $.Msg("Score board initialized");
    }

    function ShowScoreBoard() {
        $.Msg("Showing score board");
        if (g_ScoreRoot) {
            g_ScoreRoot.RemoveClass("hero_chaos_score_root_hidden");
            $.Msg("Score board shown");
        } else {
            $.Msg("Error: Score root not found");
        }
    }

    function HideScoreBoard() {
        $.Msg("Hiding score board");
        if (g_ScoreRoot) {
            g_ScoreRoot.AddClass("hero_chaos_score_root_hidden");
            ClearPanels();
            $.Msg("Score board hidden");
        } else {
            $.Msg("Error: Score root not found");
        }
    }

    function ClearPanels() {
        if (g_TeamGrid) {
            g_TeamGrid.RemoveAndDeleteChildren();
            CreateHeaderRow(g_TeamGrid, ["排名", "队伍", "击杀", "伤害"]);
        }
        if (g_CurrentGrid && g_ShowCurrentGrid) {
            g_CurrentGrid.RemoveAndDeleteChildren();
            CreateHeaderRow(g_CurrentGrid, ["排名", "英雄", "击杀", "伤害"]);
        }
        if (g_PersonalGrid) {
            g_PersonalGrid.RemoveAndDeleteChildren();
            CreateHeaderRow(g_PersonalGrid, ["排名", "英雄", "击杀", "伤害"]);
        }
    }

    function CreateHeaderRow(parent, headers) {
        const headerRow = $.CreatePanel('Panel', parent, '');
        headerRow.AddClass('hero_chaos_score_header_row');
        
        for (let header of headers) {
            const headerLabel = $.CreatePanel('Label', headerRow, '');
            headerLabel.AddClass('hero_chaos_score_column_header');
            headerLabel.text = header;
        }
    }


    function CreateCurrentHeroItem(parent, hero, index) {  // 添加 index 参数
        const heroItem = $.CreatePanel('Panel', parent, '');
        heroItem.AddClass('hero_chaos_score_personal_item');
    
        // 排名标签（独立的带特殊样式）
        const rankLabel = $.CreatePanel('Label', heroItem, '');
        rankLabel.AddClass('hero_chaos_score_rank');
        rankLabel.AddClass(index < 3 ? ['rank_first', 'rank_second', 'rank_third'][index] : 'rank_normal');
        rankLabel.text = "#" + (index + 1);
    
        // 英雄标签（带特殊属性样式）
        const heroLabel = $.CreatePanel('Label', heroItem, '');
        heroLabel.AddClass('hero_chaos_score_hero');
        heroLabel.AddClass('hero_chaos_' + hero.type);
        heroLabel.text = hero.name;
    
        // 击杀标签
        const killsLabel = $.CreatePanel('Label', heroItem, '');
        killsLabel.AddClass('hero_chaos_score_kills');
        killsLabel.text = hero.kills.toString();
    
        // 伤害标签
        const damageLabel = $.CreatePanel('Label', heroItem, '');
        damageLabel.AddClass('hero_chaos_score_damage');
        damageLabel.text = hero.damage.toString();
    }

    function CreateTeamItem(parent, team, index) {
        const teamItem = $.CreatePanel('Panel', parent, '');
        teamItem.AddClass('hero_chaos_score_team_item');

        const rankLabel = $.CreatePanel('Label', teamItem, '');
        rankLabel.AddClass('hero_chaos_score_rank');
        rankLabel.AddClass(index < 3 ? ['rank_first', 'rank_second', 'rank_third'][index] : 'rank_normal');
        rankLabel.text = "#" + (index + 1);

        const teamLabel = $.CreatePanel('Label', teamItem, '');
        teamLabel.AddClass('hero_chaos_score_team');
        teamLabel.AddClass('hero_chaos_score_team_' + team.type);
        teamLabel.text = g_TeamTypes[team.type]?.name || team.type;

        const killsLabel = $.CreatePanel('Label', teamItem, '');
        killsLabel.AddClass('hero_chaos_score_kills');
        killsLabel.text = team.kills.toString();

        const damageLabel = $.CreatePanel('Label', teamItem, '');
        damageLabel.AddClass('hero_chaos_score_damage');
        damageLabel.text = team.damage.toString();
    }

    function CreateHeroItem(parent, hero, index) {
        const heroItem = $.CreatePanel('Panel', parent, '');
        heroItem.AddClass('hero_chaos_score_personal_item');

        // 排名标签（独立的带特殊样式）
        const rankLabel = $.CreatePanel('Label', heroItem, '');
        rankLabel.AddClass('hero_chaos_score_rank');
        rankLabel.AddClass(index < 3 ? ['rank_first', 'rank_second', 'rank_third'][index] : 'rank_normal');
        rankLabel.text = "#" + (index + 1);

        // 英雄标签（带特殊属性样式）
        const heroLabel = $.CreatePanel('Label', heroItem, '');
        heroLabel.AddClass('hero_chaos_score_hero');
        heroLabel.AddClass('hero_chaos_' + hero.type);
        heroLabel.text = hero.name;

        // 击杀标签
        const killsLabel = $.CreatePanel('Label', heroItem, '');
        killsLabel.AddClass('hero_chaos_score_kills');
        killsLabel.text = hero.kills.toString();

        // 伤害标签
        const damageLabel = $.CreatePanel('Label', heroItem, '');
        damageLabel.AddClass('hero_chaos_score_damage');
        damageLabel.text = hero.damage.toString();
    }

    function UpdateScoreBoard(data) {
        $.Msg("Updating score board with data:", data);
        
        if (!g_TeamGrid || !g_PersonalGrid) {
            $.Msg("Error: Grids not found");
            return;
        }

        if (data.teamTypes) {
            g_TeamTypes = {};
            for (let key in data.teamTypes) {
                g_TeamTypes[data.teamTypes[key].type] = {
                    name: data.teamTypes[key].name
                };
            }
        }
    
        ClearPanels();
    
        if (data.teams) {
            let teamsArray = [];
            for (let key in data.teams) {
                if (data.teams[key]) {
                    teamsArray.push(data.teams[key]);
                }
            }
            
            for (let i = 0; i < teamsArray.length; i++) {
                CreateTeamItem(g_TeamGrid, teamsArray[i], i);
            }
        }
    
        if (data.currentHeroes && g_ShowCurrentGrid) {
            let currentHeroesArray = [];
            for (let key in data.currentHeroes) {
                if (data.currentHeroes[key]) {
                    currentHeroesArray.push(data.currentHeroes[key]);
                }
            }
            
            for (let i = 0; i < currentHeroesArray.length; i++) {
                CreateCurrentHeroItem(g_CurrentGrid, currentHeroesArray[i], i);
            }
        }
    
        if (data.heroes) {
            let heroesArray = [];
            for (let key in data.heroes) {
                if (data.heroes[key]) {
                    heroesArray.push(data.heroes[key]);
                }
            }
            
            const maxHeroes = Math.min(heroesArray.length, 10);
            for (let i = 0; i < maxHeroes; i++) {
                CreateHeroItem(g_PersonalGrid, heroesArray[i], i);
            }
        }
    }

    function TestScoreBoard() {
        // 模拟数据
        const testData = {
            teamTypes: {
                "1": { type: "1", name: "力量" },
                "2": { type: "2", name: "敏捷" },
                "4": { type: "4", name: "智力" },
                "8": { type: "8", name: "全才" }
            },
            teams: [
                { type: "1", typeName: "力量", name: "力量", kills: 15, damage: 2500000 },
                { type: "2", typeName: "敏捷", name: "敏捷", kills: 12, damage: 2000000 },
                { type: "4", typeName: "智力", name: "智力", kills: 8, damage: 1500000 },
                { type: "8", typeName: "全才", name: "全才", kills: 5, damage: 1000000 }
            ],
            currentHeroes: [
                { type: "1", typeName: "力量", name: "军团指挥官", kills: 6, damage: 12000 },
                { type: "2", typeName: "敏捷", name: "幻影刺客", kills: 4, damage: 9000 },
                { type: "4", typeName: "智力", name: "莱恩", kills: 3, damage: 7000 },
                { type: "8", typeName: "全才", name: "沉默术士", kills: 2, damage: 4000 }
            ],
            heroes: [
                { type: "1", typeName: "力量", name: "军团指挥官", kills: 6, damage: 12000 },
                { type: "1", typeName: "力量", name: "斧王", kills: 5, damage: 8000 },
                { type: "2", typeName: "敏捷", name: "幻影刺客", kills: 4, damage: 9000 },
                { type: "4", typeName: "智力", name: "莱恩", kills: 3, damage: 7000 },
                { type: "4", typeName: "智力", name: "宙斯", kills: 3, damage: 6000 },
                { type: "2", typeName: "敏捷", name: "影魔", kills: 2, damage: 5000 },
                { type: "8", typeName: "全才", name: "沉默术士", kills: 2, damage: 4000 },
                { type: "1", typeName: "力量", name: "昆卡", kills: 1, damage: 3000 },
                { type: "2", typeName: "敏捷", name: "幽鬼", kills: 1, damage: 2000 },
                { type: "4", typeName: "智力", name: "风行者", kills: 1, damage: 1000 }
            ]
        };
    
        // 显示面板
        ShowScoreBoard();
    
        // 更新数据
        UpdateScoreBoard(testData);
    }
    // 将测试函数暴露到全局作用域
    
    // 初始化
    Initialize();
    //TestScoreBoard();

    // 注册全局函数
    GameEvents.Subscribe("show_hero_chaos_score", ShowScoreBoard);
    GameEvents.Subscribe("hide_hero_chaos_score", HideScoreBoard);
    GameEvents.Subscribe("update_hero_chaos_score", UpdateScoreBoard);
})();