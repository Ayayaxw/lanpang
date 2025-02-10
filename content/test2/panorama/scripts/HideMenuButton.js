(function () {

    var rootPanel = $.GetContextPanel().GetParent().GetParent();


    // 修改Dota HUD元素的显示状态并切换按钮文本
    function ToggleDotaHudAndButtonText() {
        var mainButtonContainer = $("#MainButtonContainer");
        var hideDefaultButton = $("#HideMenuButton");
        var buttonLabel = hideDefaultButton.FindChildTraverse("HideMenuButtonLabel");

        // 切换主面板的可见性
        var isHidden = mainButtonContainer.BHasClass("hidden");

        // 使用类来控制可见性
        if (isHidden) {
            mainButtonContainer.RemoveClass("hidden");
            $.Msg("移除hidden类");
        } else {
            mainButtonContainer.AddClass("hidden");
            $.Msg("添加hidden类");
        }
        
        if (buttonLabel.text === "隐藏菜单") {
            buttonLabel.text = "显示菜单";
        } else {
            buttonLabel.text = "隐藏菜单";
        }   
    }

    // 为"隐藏主面板"按钮绑定点击事件
    $("#HideMenuButton").SetPanelEvent("onactivate", ToggleDotaHudAndButtonText);

})();
