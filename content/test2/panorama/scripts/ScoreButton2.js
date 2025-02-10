(function () {
    var BattleScorePanel2 = $("#BattleScorePanel2");
    $.Msg("BattleScorePanel2: ", BattleScorePanel2 ? BattleScorePanel2.paneltype : "null");
    
    var scoreButton2 = $("#ScoreButton2");  // 确保引用的按钮ID正确
    if (scoreButton2) {
        scoreButton2.SetPanelEvent("onactivate", function() {
            $.Msg("ScoreButton2 被点击");
            if (typeof toggleVisibility === "function") {
                toggleVisibility(BattleScorePanel2);
            } else {
                $.Msg("toggleVisibility 函数未定义");
            }
        });
    } else {
        $.Msg("未找到 ScoreButton2");
    }

    var heroData = [

    ];

    // 监听初始化英雄数据的事件
    GameEvents.Subscribe("initialize_hero_data", function(data) {
        // 打印接收到的原始数据
        $.Msg("Received data:", data);

        if (data && data.heroData) {
            // 解析接收到的英雄数据
            heroData = JSON.parse(data.heroData);

            // 打印解析后的英雄数据
            $.Msg("Parsed hero data:", heroData);

            // 更新英雄显示
            updateHeroDisplay();
        } else {
            $.Msg("No heroData received");
        }
    });

    // 监听更新英雄数据的事件
    GameEvents.Subscribe("update_hero_data", function(data) {
        // 打印接收到的原始数据

        $.Msg("Received update data:", data);

        if (data && data.heroData) {
            // 解析接收到的英雄数据
            heroData = JSON.parse(data.heroData);

            // 打印解析后的英雄数据
            $.Msg("Parsed updated hero data:", heroData);

            // 更新英雄显示
            updateHeroDisplay();
        } else {
            $.Msg("No updated heroData received");
        }
    });

    function updateHeroDisplay() {
        // 对英雄数据按伤害排序，伤害最高的排在最上面
        heroData.sort((a, b) => b.damage - a.damage);

        // 获取HeroesList和BattleScorePanel2面板
        var heroesListPanel = $.GetContextPanel().FindChildInLayoutFile('BattleScorePanel2HeroesList');
        var BattleScorePanel2 = $.GetContextPanel().FindChildInLayoutFile('BattleScorePanel2');

        // 清空现有的内容
        heroesListPanel.RemoveAndDeleteChildren();

        // 动态生成英雄列表
        heroData.forEach((hero, index) => {
            // 计算margin-top的值
            var marginTopValue = (index-1) * 20+0; // 5px基础间距，每个增加40px

            // 创建BattleScorePanel2HeroNameLabel
            var BattleScorePanel2HeroNameLabel = $.CreatePanel("Label", heroesListPanel, "");
            BattleScorePanel2HeroNameLabel.text = hero.name;
            BattleScorePanel2HeroNameLabel.AddClass("BattleScorePanel2HeroNameLabel");
            BattleScorePanel2HeroNameLabel.style.marginTop = marginTopValue + "px";

            // 设置英雄名字颜色
            if (hero.team === 1 || hero.team === 3) {
              BattleScorePanel2HeroNameLabel.style.color = "#FF3333";
            } else if (hero.team === 2 || hero.team === 4) {
              BattleScorePanel2HeroNameLabel.style.color = "#00FF7F";
            }

            // 创建BattleScorePanel2DamageLabel
            var BattleScorePanel2DamageLabel = $.CreatePanel("Label", heroesListPanel, "");
            BattleScorePanel2DamageLabel.text = hero.damage.toString();
            BattleScorePanel2DamageLabel.AddClass("BattleScorePanel2DamageLabel");
            BattleScorePanel2DamageLabel.style.color = "white"; // 设置造成伤害的字体颜色为白色
            BattleScorePanel2DamageLabel.style.marginTop = marginTopValue + "px"; // 设置与英雄名字相同的margin-top
        });

        // 动态调整BattleScorePanel2的高度
        var newHeight = 120 + heroData.length * 20; // 60px基础高度，每个英雄增加20px
        BattleScorePanel2.style.height = newHeight + "px";
    }
})();
