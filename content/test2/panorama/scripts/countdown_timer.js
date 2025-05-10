// 倒计时效果函数，实现3-2-1倒计时动画
function TriggerCountdown(callback = null) {
    var countdownTimer = $('#CountdownTimer');
    var countdownNumber = $('#CountdownNumber');
    var countdownReadyText = $('#CountdownReadyText');
    
    // 激活倒计时面板
    countdownTimer.AddClass('active');
    
    // 初始隐藏所有元素
    countdownNumber.RemoveClass('visible');
    countdownNumber.RemoveClass('hide');
    countdownReadyText.RemoveClass('visible');
    countdownReadyText.RemoveClass('hide');
    
    // 显示数字3
    countdownNumber.text = '3';
    countdownNumber.AddClass('visible');
    
    // 1秒后显示数字2
    $.Schedule(1.0, function() {
        countdownNumber.text = '2';
    });
    
    // 2秒后显示数字1
    $.Schedule(2.0, function() {
        countdownNumber.text = '1';
    });
    
    // 3秒后显示"开始!"文本
    $.Schedule(3.0, function() {
        countdownNumber.RemoveClass('visible');
        countdownReadyText.AddClass('visible');
        
        // 1.5秒后隐藏"开始!"文本和倒计时面板
        $.Schedule(1.5, function() {
            countdownReadyText.RemoveClass('visible');
            countdownTimer.RemoveClass('active');
            
            // 如果有回调函数，则执行
            if (callback) {
                callback();
            }
        });
    });
}

// 只显示"时间到"的函数，不显示倒计时
function ShowTimeUp(duration = 2.0, callback = null) {
    var countdownTimer = $('#CountdownTimer');
    var countdownNumber = $('#CountdownNumber');
    var countdownReadyText = $('#CountdownReadyText');
    
    // 激活倒计时面板
    countdownTimer.AddClass('active');
    
    // 确保数字隐藏，只显示文本 
    countdownNumber.RemoveClass('visible');
    countdownNumber.RemoveClass('hide');
    countdownReadyText.RemoveClass('visible');
    countdownReadyText.RemoveClass('hide');
    
    // 直接显示"开始!"文本
    $.Schedule(0, function() {
        countdownReadyText.AddClass('visible');
        
        // 指定时间后隐藏文本和面板
        $.Schedule(duration, function() {
            countdownReadyText.RemoveClass('visible');
            
            // 0.5秒后完全隐藏面板
            $.Schedule(0.5, function() {
                countdownTimer.RemoveClass('active');
                
                // 如果有回调函数，则执行
                if (callback) {
                    callback();
                }
            });
        });
    });
}

// 注册游戏事件监听器
GameEvents.Subscribe("ShowCountdown", function() {
    TriggerCountdown();
});

// 注册只显示"时间到"的事件监听器
GameEvents.Subscribe("ShowTimeUp", function() {
    ShowTimeUp();
});

