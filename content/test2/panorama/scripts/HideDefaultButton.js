(function () {
    // 获取Dota HUD面板的引用


    // 修改Dota HUD元素的显示状态并切换按钮文本
    function ToggleDotaHudAndButtonText() {
        
        var hideDefaultButton = $("#HideDefaultButton");
        var buttonLabel = hideDefaultButton.FindChildTraverse("HideDefaultButtonLabel");
        var hud = GetHud();
        var panelsToToggle = [
            "ButtonBar",
            "lower_hud",

        ];

        // 切换主面板的可见性
        var newVisibility = true;
        for (var panel of panelsToToggle) {
            var testPanel = hud.FindChildTraverse(panel);
            if (testPanel) {
                testPanel.visible = !testPanel.visible;
                newVisibility = testPanel.visible;
                $.Msg(testPanel.visible ? "显示面板: " + panel : "隐藏面板: " + panel);
            } else {
                $.Msg("找不到面板: " + panel);
            }
        }

    
        if (buttonLabel.text === "隐藏主面板") {
            buttonLabel.text = "显示主面板";
        } else {
            buttonLabel.text = "隐藏主面板";
        }   
    }

    // 为"隐藏主面板"按钮绑定点击事件
    $("#HideDefaultButton").SetPanelEvent("onactivate", ToggleDotaHudAndButtonText);

})();

function GetHud() {
    var panel = $.GetContextPanel().GetParent();
    for (var i = 0; i < 100; i++) {
        if (panel.id !== "Hud") {
            panel = panel.GetParent();
        } else {
            break;
        }
    }
    return panel;
}