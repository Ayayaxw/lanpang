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
            for (var i = 0; i < orderArray.length; i++) {
                var key = orderArray[i];
                if (event.data.hasOwnProperty(key)) {
                    reorderedData[key] = event.data[key];
                }
            }
    
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
        
        // 确保计时器显示停止在当前时间
        if (timerLabel) {
            var currentTime = timerLabel.text;
            timerLabel.text = currentTime;
        }
    
        // 更新倒计时显示
        var timeCountdown = $('#TimeCountdown');
        if (timeCountdown && timeCountdown.text) {
            var currentCount = timeCountdown.text;
            timeCountdown.text = currentCount;
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
    
        var label = $("#"+labelId);
        if (label) {
            if (key === "剩余时间") {
                stopTimer();
                
                // 解析时间字符串
                var timeParts = newValue.split(':');
                var minutes = parseInt(timeParts[0], 10);
                var seconds = parseFloat(timeParts[1]);
                endTime = minutes * 60 + seconds;
    
                //$.Msg(endTime + " endTime ");
                
                // 更新 TimeCountdown 元素
                $('#TimeCountdown').text = Math.ceil(endTime).toString();
                
                // 更新标签文本
                label.text = newValue;
                

            } else {
                label.text = newValue.toString();
            }
            //$.Msg("Updated label " + labelId + " with new value: " + newValue);
        } else {
            //$.Msg("Label " + labelId + " not found.");
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
        endTime = parseFloat(seconds);
        timerLabel = createLabelRow(label, formatTime(endTime));
        return timerLabel;
    }

    function formatTime(seconds) {
        var minutes = Math.floor(seconds / 60);
        var remainingSeconds = Math.floor(seconds % 60);
        var centiseconds = Math.floor((seconds % 1) * 100);
        return ("0" + minutes).slice(-2) + ":" + 
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

    function startTimer() {
        if (endTime === undefined || !timerLabel) {
            var contentPanel = BattleScorePanel1.FindChild("ContentPanel");
            if (contentPanel) {
                timerLabel = contentPanel.FindChildrenWithClassTraverse("ScorePanel1TimeLabel")[0];
            }
            
            if (!timerLabel) {
                timerLabel = BattleScorePanel1.FindChildrenWithClassTraverse("ScorePanel1TimeLabel")[0];
            }
    
            if (!timerLabel) {
                // $.Msg("Timer label not found. Panel structure:");
                // logPanelStructure(BattleScorePanel1);
                return;
            }
        }
    
        var startTime = Game.Time();
    
        function updateTimer() {
            var elapsedTime = Game.Time() - startTime;
            var remainingTime = Math.max(0, endTime - elapsedTime);
        
            if (remainingTime <= 0) {
                timerLabel.text = "00:00.00";
                $('#TimeCountdown').text = "0";
                $.CancelScheduled(interval);
            } else {
                timerLabel.text = formatTime(remainingTime);
                
                // 计算向上取整的秒数
                var ceilingSeconds = Math.ceil(remainingTime);
                $('#TimeCountdown').text = ceilingSeconds.toString();
                
                interval = $.Schedule(0.01, updateTimer);
            }
        }
    
        stopTimer();
        updateTimer();
    }
    
    function stopTimer() {
        if (interval) {
            $.CancelScheduled(interval);
            interval = null;
        }
    }

    function updateScoreboard(data) {
        stopTimer();
        BattleScorePanel1.RemoveAndDeleteChildren();
        timerLabel = null;
        endTime = null;
    
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