// 改进的屏幕闪白效果函数，使用贝塞尔曲线实现平滑过渡
function TriggerWhiteFlash(duration = 0.3, opacity = 0.5) {
    $.Msg("TriggerWhiteFlash");
    var whiteFlashPanel = $('#WhiteFlashFilter');
    
    var riseTime = duration * 0.01; // 上升时间
    whiteFlashPanel.style.transitionDuration = riseTime + "s";
    
    // 执行闪白效果，添加active类并直接设置不透明度
    whiteFlashPanel.AddClass('active');
    // 直接设置不透明度覆盖CSS中的默认值
    whiteFlashPanel.style.opacity = opacity;
    
    // 达到峰值后开始淡出
    $.Schedule(riseTime, function() {
        // 设置较长的淡出时间
        var fallTime = duration * 0.99; // 下降时间
        whiteFlashPanel.style.transitionDuration = fallTime + "s";
        
        // 直接设置不透明度为0，开始淡出
        whiteFlashPanel.style.opacity = 0;
        
        // 在淡出完成后移除active类
        $.Schedule(fallTime, function() {
            whiteFlashPanel.RemoveClass('active');
        });
    });
}

// 示例调用，传入持续时间和闪白强度
GameEvents.Subscribe("FlashWhite", function() {   
    $.Msg("FlashWhite");
    
    TriggerWhiteFlash(1, 0.05);
});

