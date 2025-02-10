(function() {
    function initUI() {
        var scoreButton1 = $("#ScoreButton1");
        var scoreButton2 = $("#ScoreButton2");
        var modeMenuButton = $("#ModeMenuButton");
        
        var BattleScorePanel2 = $("#BattleScorePanel2");
        var GameModeMainPanel = $("#GameModeMainPanel");

        // 日志输出
        $.Msg("Initializing UI...");
        $.Msg("scoreButton1: ", scoreButton1 ? scoreButton1.id : "null");
        $.Msg("scoreButton2: ", scoreButton2 ? scoreButton2.id : "null");
        $.Msg("modeMenuButton: ", modeMenuButton ? modeMenuButton.id : "null");
        
        $.Msg("BattleScorePanel2: ", BattleScorePanel2 ? BattleScorePanel2.paneltype : "null");
        $.Msg("GameModeMainPanel: ", GameModeMainPanel ? GameModeMainPanel.paneltype : "null");

        // 检查是否成功获取到元素
        if (!scoreButton1 || !scoreButton2 || !modeMenuButton || !BattleScorePanel1 || !BattleScorePanel2) {
            $.Msg("Error: Failed to get one or more essential elements");
            return;
        }


        // 监听"积分版1"按钮点击事件


        // 监听"积分版2"按钮点击事件
        scoreButton2.SetPanelEvent("onactivate", function() {
            $.Msg("ScoreButton2 clicked");
            toggleVisibility(BattleScorePanel2);
        });

        // 监听"模式菜单"按钮点击事件
        modeMenuButton.SetPanelEvent("onactivate", function() {
            $.Msg("ModeMenuButton clicked");
            toggleVisibility(GameModeMainPanel);
        });

        $.Msg("UI initialized successfully");
    }


})();