(function() {
    var BattleScorePanel1 = $("#BattleScorePanel1");
    $.Msg("BattleScorePanel1: ", BattleScorePanel1 ? BattleScorePanel1.paneltype : "null");
    
    var scoreButton1 = $("#ScoreButton1");  // 确保引用的按钮ID正确
    if (scoreButton1) {
        scoreButton1.SetPanelEvent("onactivate", function() {
            $.Msg("ScoreButton1 被点击");
            if (typeof toggleVisibility === "function") {
                toggleVisibility(BattleScorePanel1);
            } else {
                $.Msg("toggleVisibility 函数未定义");
            }
        });
    } else {
        $.Msg("未找到 ScoreButton1");
    }
    

    
    var timerLabel;
    var endTime;
    var startValue; // 计时器起始值
    var isCountUp = false; // 是否为向上计时（存活时间）
    var interval;
    var keyOrder = {};

    GameEvents.Subscribe("ini_scoreboard", function(event) {
        GameUI.SetCameraDistance(defaultDistance);
        keyOrder = {};
        if (event && event.data && event.order) {
            var orderArray = Object.keys(event.order).map(function(key) {
                return event.order[key];
            });
    
            // 存储键的顺序到全局对象
            for (var i = 0; i < orderArray.length; i++) {
                keyOrder[orderArray[i]] = i + 1; // 序号从1开始
            }
    
            var reorderedData = {};
            $.Msg("开始处理积分板数据并进行本地化...");
            
            for (var i = 0; i < orderArray.length; i++) {
                var key = orderArray[i];
                if (event.data.hasOwnProperty(key)) {
                    var value = event.data[key];
                    
                    // 尝试对键名进行本地化 - 添加"#"前缀
                    var localizedKey = $.Localize("#" + key);
                    if (localizedKey !== "#" + key) {
                        $.Msg("键名已本地化: " + key + " -> " + localizedKey);
                        key = localizedKey;
                    }
                    
                    // 如果值是字符串，尝试本地化 - 添加"#"前缀
                    if (typeof value === 'string') {
                        var localizedValue = $.Localize("#" + value);
                        if (localizedValue !== "#" + value) {
                            $.Msg("值已本地化: " + value + " -> " + localizedValue);
                            value = localizedValue;
                        }
                    }
                    
                    reorderedData[key] = value;
                }
            }
            
            $.Msg("本地化处理完成，更新积分板...");
            updateScoreboard(reorderedData);
        } else {
            $.Msg("Event data or order is missing.");
        }
    });

    GameEvents.Subscribe("start_timer", function(event) {
        startTimer();
        var key = "击杀数量";
        var order = getKeyOrder(key);
        $.Msg("Key: " + key + ", Order: " + order); 
    });

    GameEvents.Subscribe("start_countdown", function(event) {
        startCountdown();

    });

    GameEvents.Subscribe("start_fighting", function(event) {
        startFighting();

    });

    GameEvents.Subscribe("stop_timer", function(event) {   
        // 首先停止计时器
        stopTimer();
        
        // 确保计时器显示停止在当前时间，如果小于0.1秒则显示0
        if (timerLabel) {
            // 打印处理前的值
            $.Msg("停止计时器 - 处理前：" + timerLabel.text);
            
            // 检查是否是倒计时标签
            var isCountdownTimer = !isCountUp; // 使用全局的 isCountUp 变量判断
    
            if (isCountdownTimer) {
                var currentTime = timerLabel.text;
                $.Msg("当前时间格式：" + currentTime);
                
                // 提取实际的秒数值，无论是否有冒号
                var timeNumber;
                var decimalPlaces = 2; // 默认2位小数
                
                if (currentTime.indexOf(':') !== -1) {
                    // 处理带冒号的格式 (如 "0:00.01")
                    var parts = currentTime.split(':');
                    var minutes = parseInt(parts[0]) || 0;
                    var secondsPart = parts[1] || "0";
                    
                    // 提取秒和小数部分
                    var secondsComponents = secondsPart.split('.');
                    var seconds = parseInt(secondsComponents[0]) || 0;
                    var decimal = secondsComponents[1] || "00";
                    
                    // 计算总秒数
                    timeNumber = minutes * 60 + seconds + (parseFloat("0." + decimal) || 0);
                    decimalPlaces = decimal.length;
                    
                    $.Msg("解析的时间组件 - 分钟: " + minutes + ", 秒: " + seconds + ", 小数: " + decimal);
                    $.Msg("计算的总秒数: " + timeNumber);
                } else {
                    // 对于不带冒号的格式(纯数字)
                    decimalPlaces = (currentTime.split('.')[1] || '').length;
                    timeNumber = parseFloat(currentTime);
                }
                
                // 应用统一的逻辑判断时间是否接近0
                if (timeNumber < 0.05) {
                    // 根据原始格式决定输出格式
                    if (currentTime.indexOf(':') !== -1) {
                        // 对于带冒号的格式，保持格式但设置为0
                        timerLabel.text = "0:00." + "0".repeat(decimalPlaces);
                    } else {
                        // 对于不带冒号的格式，使用原来的输出方式
                        timerLabel.text = "0." + "0".repeat(decimalPlaces);
                    }
                    $.Msg("时间接近0，设置为0");
                } else {
                    // 时间不接近0，保持原值
                    timerLabel.text = currentTime;
                    $.Msg("时间不接近0，保持原值");
                }
            }
            // 如果是存活时间，保持当前值不变
            
            // 打印处理后的值
            $.Msg("停止计时器 - 处理后：" + timerLabel.text);
        }
    
        // 更新倒计时显示
        var timeCountdown = $('#TimeCountdown');
        if (timeCountdown && timeCountdown.text) {
            var currentCount = timeCountdown.text;
            var decimalPlaces = (currentCount.split('.')[1] || '').length;
            var countNumber = parseFloat(currentCount);
            if (countNumber < 0.05) {
                timeCountdown.text = "0." + "0".repeat(decimalPlaces);
            } else {
                timeCountdown.text = currentCount;
            }
        }
    
    
    
        // 隐藏 HUD 元素
        var hud = GetHud();
        var panelsToToggle = [
            "ButtonBar",
            "lower_hud"
        ];
        for (var panel of panelsToToggle) {
            var testPanel = hud.FindChildTraverse(panel);
            if (testPanel) {
                testPanel.visible = false;
            }
        }
    
        // 隐藏技能面板
        const leftPanel = $('#LeftHeroAbilities');
        const rightPanel = $('#RightHeroAbilities');
        
        if (leftPanel) {
            leftPanel.AddClass('AbilitiesContainerhidden');
            $.Msg("左方技能面板已隐藏");
        }
        
        if (rightPanel) {
            rightPanel.AddClass('AbilitiesContainerhidden');
            $.Msg("右方技能面板已隐藏");
        }
    
        // 处理相机移动
        if (event && event["1"]) {
            var positionString = event["1"];
            var coordinates = positionString.split(' ');
    
            if (coordinates.length === 3) {
                var jsPosition = coordinates.map(Number);
                
                if (!jsPosition.some(isNaN)) {
                    cinematicCameraMove(jsPosition);
                } else {
                    $.Msg("无效的坐标值:", positionString);
                }
            } else {
                $.Msg("坐标数量不正确:", positionString);
            }
        } else {
            $.Msg("事件中没有收到位置数据:", event);
        }
    });

    GameEvents.Subscribe("move_to_winner", function(event) {
        if (event && event["1"]) {
            var positionString = event["1"];
            var coordinates = positionString.split(' ');
    
            if (coordinates.length === 3) {
                var jsPosition = coordinates.map(Number);
                
                if (!jsPosition.some(isNaN)) {
                    immediateMoveThenLeft(jsPosition);
                } else {
                    console.error("Invalid coordinate values:", positionString);
                }
            } else {
                console.error("Unexpected number of coordinates:", positionString);
            }
        } else {
            console.error("No position data received in the event:", event);
        }
    });

    GameEvents.Subscribe("update_score", function(event) {
        // 遍历事件数据并更新对应的标签
        for (var key in event) {
            if (event.hasOwnProperty(key)) {
                updateLabelByKey(key, event[key]);
            }
        }
    });
    function updateLabelByKey(key, newValue) {
        var keyOrder = getKeyOrder(key);
        var labelId = key + "Value_" + keyOrder;
        $.Msg("Updating label:");
        $.Msg("- Key: " + key);
        $.Msg("- Value: " + newValue);
        $.Msg("- Label ID: " + labelId);
    
    
        var label = $("#"+labelId);
        if (label) {
            // 检查值是否真的发生了变化
            var currentValue = label.text;
            var newValueStr = newValue.toString();
            
            if (currentValue !== newValueStr) {
                // 先移除所有动画类
                label.RemoveClass("ValueIncreased");
                label.RemoveClass("ValueDecreased");
                label.RemoveClass("ValueChanged");
                label.RemoveClass("ValueNormal");
                
                // 根据值的变化确定动画类
                var animClass = "ValueChanged";
                
                // 尝试对可能是数字的值进行数值比较
                if (!isNaN(currentValue) && !isNaN(newValueStr)) {
                    var oldNum = parseFloat(currentValue);
                    var newNum = parseFloat(newValueStr);
                    
                    if (newNum > oldNum) {
                        animClass = "ValueIncreased";
                    } else if (newNum < oldNum) {
                        animClass = "ValueDecreased";
                    }
                }
                
                if (key === "剩余时间") {
                    stopTimer();
                    
                    // 确保 newValue 是字符串
                    newValue = String(newValue);
                    
                    // 解析时间字符串
                    var timeParts = newValue.split(':');
                    var minutes = parseInt(timeParts[0], 10) || 0;
                    var seconds = parseFloat(timeParts[1]) || 0;
                    endTime = minutes * 60 + seconds;
                    startValue = 0; // 剩余时间从0开始倒计时
                    isCountUp = false; // 设置为倒计时模式
                    
                    // 更新 TimeCountdown 元素
                    $('#TimeCountdown').text = Math.ceil(endTime).toString();
                    
                    // 更新标签文本
                    label.text = newValue;
                    
                    // 添加动画类
                    label.AddClass(animClass);
                    
                    // 在过渡完成后恢复正常状态
                    $.Schedule(0.4, function() {
                        if (label) {
                            label.RemoveClass(animClass);
                            label.AddClass("ValueNormal");
                        }
                    });
                } else if (key === "存活时间") {
                    stopTimer();
                    
                    // 调试日志
                    $.Msg("解析存活时间:");
                    $.Msg("- 原始值: " + newValue);
                    
                    // 新的解析逻辑
                    var timeParts = newValue.split(':');
                    var minutePart = parseInt(timeParts[0], 10) || 0;
                    var secondParts = timeParts[1].split('.'); // 处理小数点
                    var secondPart = parseInt(secondParts[0], 10) || 0;
                    var millisPart = parseInt(secondParts[1], 10) || 0;
                    
                    // 转换为秒
                    startValue = minutePart * 60 + secondPart + (millisPart / 100);
                    
                    $.Msg("- 解析结果: " + startValue + " 秒");
                    
                    isCountUp = true;
                    
                    // 更新标签文本
                    label.text = newValue;
                    
                    // 添加动画类
                    label.AddClass(animClass);
                    
                    // 在过渡完成后恢复正常状态
                    $.Schedule(0.4, function() {
                        if (label) {
                            label.RemoveClass(animClass);
                            label.AddClass("ValueNormal");
                        }
                    });
                    
                    // 开始计时器
                    startTimer();
                } else {
                    // 对于普通字段，更新文本并应用动画
                    label.text = newValueStr;
                    
                    // 添加动画类
                    label.AddClass(animClass);
                    
                    // 在过渡完成后恢复正常状态
                    $.Schedule(0.4, function() {
                        if (label) {
                            label.RemoveClass(animClass);
                            label.AddClass("ValueNormal");
                        }
                    });
                }
            }
        } else {
            $.Msg("Label " + labelId + " not found.");
        }
    }

    var initialData = {
        "挑战英雄": "玛西",
        "剩余时间": "300",
        "总得分": "100",

    };
    updateScoreboard(initialData);
    function getKeyOrder(key) {
        return keyOrder[key];
    }
    function createLabelRow(key, value, className = "") {
        var keyOrder = getKeyOrder(key);  // 使用 getKeyOrder 函数获取键的序号
        var rowId = key + "_" + keyOrder;  // 创建基于键和序号的独特ID
        var row = $.CreatePanel("Panel", BattleScorePanel1, rowId);
        row.AddClass("ScorePanel1LabelRow");
    
        var keyLabel = $.CreatePanel("Label", row, "");
        keyLabel.text = key;
        keyLabel.AddClass("ScorePanel1KeyLabel");
    
        var valueLabelId = key + "Value_" + keyOrder;  // 为 valueLabel 也创建独特ID
        var valueLabel = $.CreatePanel("Label", row, valueLabelId);
        valueLabel.text = value;
    
        if (key === "剩余时间") {
            valueLabel.AddClass("ScorePanel1TimeLabel");
        } else {
            valueLabel.AddClass("ScorePanel1ValueLabel");
        }
    
        if (className) {
            row.AddClass(className);
        }
    
        return valueLabel;
    }
    
    function createTimerRow(label, seconds) {
        if (label === "剩余时间") {
            endTime = parseFloat(seconds);
            startValue = 0;
            isCountUp = false;
        } else if (label === "存活时间") {
            startValue = parseFloat(seconds);
            isCountUp = true;
        }
        
        timerLabel = createLabelRow(label, formatTime(isCountUp ? startValue : endTime));
        return timerLabel;
    }

    function formatTime(seconds) {
        var minutes = Math.floor(seconds / 60);
        var remainingSeconds = Math.floor(seconds % 60);
        var centiseconds = Math.floor((seconds % 1) * 100);
        return minutes + ":" + 
               ("0" + remainingSeconds).slice(-2) + "." + 
               ("0" + centiseconds).slice(-2);
    }

    function logPanelStructure(Panel, depth = 0) {
        var indent = "  ".repeat(depth);
        $.Msg(indent + Panel.paneltype + (Panel.id ? (" - ID: " + Panel.id) : ""));
        var children = Panel.Children();
        for (var i = 0; i < children.length; i++) {
            logPanelStructure(children[i], depth + 1);
        }
    }

    // 修改后的startTimer函数
    function startTimer() {
        if ((endTime === undefined && !isCountUp) || !timerLabel) {
            var contentPanel = BattleScorePanel1.FindChild("ContentPanel");
            if (contentPanel) {
                timerLabel = contentPanel.FindChildrenWithClassTraverse("ScorePanel1TimeLabel")[0];
            }
            
            if (!timerLabel) {
                timerLabel = BattleScorePanel1.FindChildrenWithClassTraverse("ScorePanel1TimeLabel")[0];
            }

            if (!timerLabel) {
                return;
            }
        }

        var startTime = Game.Time();
        var lastIntSeconds = -1; // 记录上一次的整数秒，用于检测变化

        function updateTimer() {
            var elapsedTime = Game.Time() - startTime;
            
            if (isCountUp) {
                // 存活时间：向上计时
                var currentTime = startValue + elapsedTime;
                timerLabel.text = formatTime(currentTime);
                
                // 获取当前整数秒，用于检测变化
                var intSeconds = Math.floor(currentTime);
                
                // 只在整数秒变化时检查里程碑
                if (intSeconds !== lastIntSeconds) {
                    checkAndApplyMilestoneEffects(intSeconds, true);
                    lastIntSeconds = intSeconds;
                }
                
                interval = $.Schedule(0.01, updateTimer);
            } else {
                // 剩余时间：倒计时
                var remainingTime = Math.max(0, endTime - elapsedTime);
                
                // 如果剩余时间非常接近0（小于0.01秒），则强制设为0
                if (remainingTime < 0.01) {
                    remainingTime = 0;
                    timerLabel.text = "00:00.00";
                    $('#TimeCountdown').text = "0";
                    $.CancelScheduled(interval);
                    
                    // 倒计时结束时移除所有效果
                    removeAllTimerEffects();
                    return;
                } else {
                    timerLabel.text = formatTime(remainingTime);
                    
                    // 计算向上取整的秒数
                    var ceilingSeconds = Math.ceil(remainingTime);
                    $('#TimeCountdown').text = ceilingSeconds.toString();
                    
                    // 获取当前整数秒，用于检测变化
                    var intSeconds = Math.floor(remainingTime);
                    
                    // 只在整数秒变化时检查里程碑
                    if (intSeconds !== lastIntSeconds) {
                        checkAndApplyMilestoneEffects(intSeconds, false);
                        lastIntSeconds = intSeconds;
                    }
                    
                    interval = $.Schedule(0.01, updateTimer);
                }
            }
        }

        stopTimer();
        updateTimer();
    }
    
    // 新增函数：检查并应用里程碑效果
    function checkAndApplyMilestoneEffects(intSeconds, isCountUp) {
        // 移除之前的效果类
        removeAllTimerEffects();
        
        // 检查是否是10的整数倍（小动画）
        if (intSeconds % 10 === 0 && intSeconds > 0) {
            // 检查是否是60的整数倍（大动画优先）
            if (intSeconds % 60 === 0) {
                timerLabel.AddClass("TimeMajorMilestone");
                
                // 在0.5秒后移除动画效果
                $.Schedule(0.5, function() {
                    if (timerLabel) {
                        timerLabel.RemoveClass("TimeMajorMilestone");
                    }
                });
            } else {
                timerLabel.AddClass("TimeMilestone");
                
                // 在0.3秒后移除动画效果
                $.Schedule(0.3, function() {
                    if (timerLabel) {
                        timerLabel.RemoveClass("TimeMilestone");
                    }
                });
            }
        }
        
        // 检查倒计时是否接近结束（紧急效果）
        // 只有在倒计时模式下才应用紧急效果
        if (!isCountUp && intSeconds <= 10) {
            timerLabel.AddClass("TimeUrgent");
        }
    }
    
    // 移除所有计时器效果
    function removeAllTimerEffects() {
        if (timerLabel) {
            timerLabel.RemoveClass("TimeMilestone");
            timerLabel.RemoveClass("TimeMajorMilestone");
            timerLabel.RemoveClass("TimeUrgent");
        }
    }
    
    function stopTimer() {
        if (interval) {
            $.CancelScheduled(interval);
            interval = null;
        }
        // 停止计时器时移除所有效果
        removeAllTimerEffects();
    }

    function updateScoreboard(data) {
        stopTimer();
        BattleScorePanel1.RemoveAndDeleteChildren();
        timerLabel = null;
        endTime = null;
        isCountUp = false;
        startValue = 0;
    
        var title = $.CreatePanel("Label", BattleScorePanel1, "ScorePanel1TitleLabel");
        title.text = "积分板";
        title.AddClass("ScorePanel1TopRow");
    
        var contentPanel = $.CreatePanel("Panel", BattleScorePanel1, "ContentPanel");
        contentPanel.AddClass("ContentPanel");
    
        for (var key in data) {
            if (data.hasOwnProperty(key)) {
                var value = data[key];
                if (key === "剩余时间") {
                    createTimerRow(key, parseFloat(value).toFixed(2));
                } else if (key === "存活时间") {
                    createTimerRow(key, parseFloat(value).toFixed(2));
                } else {
                    createLabelRow(key, value, "", contentPanel);
                }
            }
        }
    
        $.Msg("Scoreboard updated. Checking for timer label...");
        var foundTimerLabel = BattleScorePanel1.FindChildrenWithClassTraverse("TimeLabel")[0];
        if (foundTimerLabel) {
            $.Msg("Timer label found after update.");
        } else {
            // $.Msg("Timer label not found after update. Panel structure:");
            // logPanelStructure(BattleScorePanel1);
        }
    }

})();