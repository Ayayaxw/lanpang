(function() {
    // 隐藏顶部栏
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false); 
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_MENU_BUTTONS, false);

    // 隐藏小地图
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false);
    // GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false);
    
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_QUICK_STATS, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_KILLCAM, false);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FIGHT_RECAP, false);
    
    // 隐藏右下角商店栏
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false);

    // 设置延时函数，2秒后执行
    (function () {
        // 打印脚本加载信息
        $.Msg("Script loaded and execution started.");
    
        // 获取Dota HUD面板的引用
        function GetHud() {
            var panel = $.GetContextPanel().GetParent();
            for (var i = 0; i < 100; i++) {
                if (panel.id != "Hud") {
                    panel = panel.GetParent();
                } else {
                    break;
                }
            }
            return panel;
        }
    
        // 隐藏不需要的Dota HUD元素
        function ConfigureDotaHud() {
            var hud = GetHud();
            var panelsToHide = [
                "quickstats", // 左上角的K/D显示
                "player_performance_container",
                "combat_events", // 左侧的死亡信息显示
                "SpectatorToastManager",//右侧的技能升级提醒
                "stackable_side_panels"
            ];
    
            for (var panel of panelsToHide) {
                var testPanel = hud.FindChildTraverse(panel);
                if (testPanel) { 
                    testPanel.visible = false;
                    $.Msg("Hiding panel: " + panel);
                } else {
                    $.Msg("Panel not found: " + panel);
                }
            }
        }
    
        // 设置延时执行隐藏面板函数
        $.Schedule(2.0, ConfigureDotaHud);

        // 获取自定义UI根面板并设置zIndex
        // let customRoot = $.GetContextPanel();
        // while(customRoot.id != 'CustomUIRoot') customRoot = customRoot.GetParent();
        // customRoot.style.zIndex = -1;
    
    })();
    function FindHeroFacetSnippetContainer() {
        // 获取初始面板
        var panel = $.GetContextPanel().GetParent();
        
        // 最大循环次数设为100以防止无限循环
        for (var i = 0; i < 100; i++) {
            // 如果找到目标面板，打印并返回
            if (panel.id === "HeroFacetSnippetContainer") {
                $.Msg("Found HeroFacetSnippetContainer panel!");
                return panel;
            }
            // 如果已经到达根节点还没找到，终止搜索
            if (!panel.GetParent()) {
                $.Msg("Could not find HeroFacetSnippetContainer - reached root panel");
                return null;
            }
            // 继续向上层寻找
            panel = panel.GetParent();
        }
        
        // 如果超过最大循环次数还没找到，返回null
        $.Msg("Could not find HeroFacetSnippetContainer - max iterations reached");
        return null;
    }
    
    // 使用示例：
    $.Schedule(2.0, function() {
        var facetPanel = FindHeroFacetSnippetContainer();
        if (facetPanel) {
            $.Msg("Panel ID: " + facetPanel.id);
            // 这里可以对找到的面板进行操作
        }
    });
})();
