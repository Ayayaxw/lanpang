(function() {
    let trackedTexts = new Map();
    let updateTimer = null;  // 添加计时器引用
    let debugCounter = 0;  // 添加计数器用于追踪更新频率
    let debugEntity = null;  // 用于追踪第一个添加的实体

    function getTextPosition(entityId) {
        if (!entityId || !Entities.IsValidEntity(entityId)) {
            return null;
        }
        
        // 获取实体世界坐标
        const pos = Entities.GetAbsOrigin(entityId);
        if (!pos) {
            return null;
        }
        
        // 基础固定高度偏移
        let heightOffset = 0;
        
        // 尝试获取单位的血条偏移
        if (typeof Entities.GetHealthBarOffset === 'function') {
            const healthBarOffset = Entities.GetHealthBarOffset(entityId);
            if (healthBarOffset) {
                heightOffset += healthBarOffset;

            }
        }        
        
        // 添加高度偏移
        const worldPos = [
            pos[0],
            pos[1],
            pos[2] + heightOffset // 使用计算后的偏移高度
        ];

        
        // 转换为屏幕坐标
        const wx = Game.WorldToScreenX(worldPos[0], worldPos[1], worldPos[2]);
        const wy = Game.WorldToScreenY(worldPos[0], worldPos[1], worldPos[2]);
        
        // 获取屏幕宽高和缩放比例
        const panel = $.GetContextPanel();
        const sw = panel.actuallayoutwidth;
        const sh = panel.actuallayoutheight;
        
        // 计算缩放因子 - 这是关键!
        // 使用1080p作为基准分辨率
        const scale = 1080 / sh;
        
        // 应用偏移和缩放
        const offsetX = 0; // 可以根据需要调整
        const offsetY = 0; // 可以根据需要调整
        
        let x = scale * wx + offsetX;
        let y = scale * wy + offsetY;
        
        // 获取当前实体的面板
        const textPanel = trackedTexts.get(entityId);
        if (!textPanel || !textPanel.IsValid()) {
            return null;
        }
        
        // 获取面板尺寸 - 需要考虑缩放因子
        // 在高分辨率下，面板可能会更大，但我们需要统一缩放处理
        const pw = textPanel.actuallayoutwidth;
        const ph = textPanel.actuallayoutheight;
        

        // 应用水平居中对齐 - 使用缩放后的面板宽度
        // 如果scale < 1（高分辨率），面板实际上更大，需要减去更多宽度的一半
        // 如果scale > 1（低分辨率），面板实际上更小，需要减去更少宽度的一半
        x -= (pw * scale) / 2;
        
        // 应用垂直底部对齐（文本显示在头顶上方）- 同样考虑缩放
        y -= (ph * scale) - (10 * scale);
        

        
        // 边缘检测逻辑
        const edgePercentage = 5; // 距离边缘的百分比
        const padx = sw * edgePercentage / 100;
        const pady = sh * edgePercentage / 100;
        
        const originalX = x;
        const originalY = y;
        
        // 限制坐标不超出屏幕边缘

        const isOnEdge = (x !== originalX || y !== originalY);
        
        // 如果在屏幕边缘，可以选择调整位置或者直接隐藏
        if (isOnEdge) {
            return null;
        }
        
        // 检查坐标是否有效
        if (!isFinite(x) || isNaN(x) || !isFinite(y) || isNaN(y)) {
            return null;
        }
        
        return {
            x: x,
            y: y
        };
    }

    function UpdateAllTextPositions() {
        debugCounter++;
        if (debugCounter % 20 === 0) {  // 每20帧记录一次，避免日志过多
            
        }

        const mainContainer = $('#FloatingTextContainer');
        if (!mainContainer) {
            // $.Msg("[UpdateAllTextPositions] 找不到主容器");
            return;
        }

        // 如果没有需要更新的文本，取消计时器
        if (trackedTexts.size === 0) {
            // $.Msg("[UpdateAllTextPositions] 没有需要更新的文本，停止更新");
            updateTimer = null;
            return;
        }

        trackedTexts.forEach((panel, entityId) => {
            // 对调试实体进行额外日志记录
            const isDebugEntity = debugEntity === entityId;
            if (isDebugEntity && debugCounter % 20 === 0) {
                
            }

            if (!panel || !panel.IsValid()) {
                
                trackedTexts.delete(entityId);
                return;
            }

            if (!entityId) {
                // $.Msg("[UpdateAllTextPositions] 实体ID为空");
                return;
            }

            // 检查实体是否还存在
            if (!Entities.IsValidEntity(entityId)) {
                
                panel.visible = false;
                panel.DeleteAsync(0.0);
                trackedTexts.delete(entityId);
                return;
            }

            // 检查单位是否存活
            if (!Entities.IsAlive(entityId)) {
                // 单位死亡，隐藏面板
                if (isDebugEntity) {
                    
                }
                panel.visible = false;
                return;
            } else {
                // 单位存活，确保面板可见
                if (panel.visible === false && isDebugEntity) {
                    
                }
                panel.visible = true;
            }

            const pos = getTextPosition(entityId);
            if (pos) {
                if (isDebugEntity && debugCounter % 20 === 0) {
                    
                    
                }
                panel.style.position = `${pos.x}px ${pos.y}px 0`;
                
                // 检查位置是否实际更新
                if (isDebugEntity && debugCounter % 20 === 0) {
                    $.Schedule(0.01, function() {
                        if (panel && panel.IsValid()) {
                            
                        }
                    });
                }
            } else if (isDebugEntity) {
                
            }
        });

        // 只有在还有文本需要更新时才继续更新
        if (trackedTexts.size > 0) {
            updateTimer = $.Schedule(1/200, UpdateAllTextPositions);
        }
    }

    function StartUpdateSystem() {
        // 如果计时器已经在运行，就不要再创建新的
        if (!updateTimer && trackedTexts.size > 0) {
            // $.Msg("[StartUpdateSystem] 开始更新文本位置");
            updateTimer = $.Schedule(1/200, UpdateAllTextPositions);
        }
    }
    
    function OnUpdateFloatingText(data) {
        //$.Msg("[OnUpdateFloatingText] 收到事件:", data);
        
        const mainContainer = $('#FloatingTextContainer');
        if (!mainContainer) {
            // $.Msg("[OnUpdateFloatingText] 错误: 找不到容器");
            return;
        }
        
        const entityId = data.entityId;
        // 如果是首次添加实体，记录为调试实体
        if (trackedTexts.size === 0 && entityId) {
            debugEntity = entityId;
            
        }

        if (!entityId) {
            // $.Msg("[OnUpdateFloatingText] 错误: 实体ID为空");
            return;
        }

        
        
        const panelId = `FloatingText_${entityId}`;
        
        // 获取或创建面板
        let panel = mainContainer.FindChild(panelId);
        if (!panel) {
            
            panel = $.CreatePanel('Panel', mainContainer, panelId);
            
            const label = $.CreatePanel('Label', panel, `${panelId}_Label`);
            
            // 添加向上偏移的CSS样式
            panel.style.marginTop = "-65px"; // 使面板向上偏移50像素
            //$.Msg("更新文本位置");
            // 重要：先将面板存储到trackedTexts中，再获取位置
            trackedTexts.set(entityId, panel);

            // 设置初始位置
            const pos = getTextPosition(entityId);
            if (pos) {
                
                panel.style.position = `${pos.x}px ${pos.y}px 0`;
            } else {
                
            }
        } else {
            
        }
        
        // 确保现有面板也在trackedTexts中
        trackedTexts.set(entityId, panel);
        
        // 更新文本内容
        const label = panel.FindChild(`${panelId}_Label`);
        if (label) {
            // 检查文本是否变化，如果变化了且包含击杀数字，则添加增加动画
            const oldText = label.text;
            const newText = data.text;
            
            label.text = newText;
            
            // 清除所有可能的样式类
            label.RemoveClass("KillCounterText");
            label.RemoveClass("KillCounterIncrement");
            label.RemoveClass("MinionAttributeText");
            label.RemoveClass("strength");
            label.RemoveClass("agility");
            label.RemoveClass("intelligence");
            
            // 移除之前的所有颜色类
            label.RemoveClass('color_red');
            label.RemoveClass('color_green');
            label.RemoveClass('color_blue');
            label.RemoveClass('color_purple');
            label.RemoveClass('color_gold');
            label.RemoveClass('color_orange');
            label.RemoveClass('color_white');
            label.RemoveClass('color_gray');
            
            // 处理字体大小
            if (data.fontSize) {
                label.style.fontSize = `${data.fontSize}px`;
            }
            
            // 样式处理系统
            const textStyle = data.textStyle || "default";
            
            switch (textStyle) {
                case "hero_score":
                    // 英雄得分样式 - 金色闪光效果
                    label.AddClass("KillCounterText");
                    
                    // 检查文本是否变化，如果变化了且有数字增加，则添加增加动画
                    if (oldText && oldText !== newText) {
                        const oldNumber = parseInt(oldText.replace(/\D/g, ''));
                        const newNumber = parseInt(newText.replace(/\D/g, ''));
                        
                        if (!isNaN(oldNumber) && !isNaN(newNumber) && newNumber > oldNumber) {
                            // 数字增加，播放增加动画
                            label.AddClass("KillCounterIncrement");
                            // 动画播放完后移除类
                            $.Schedule(0.5, function() {
                                if (label && label.IsValid()) {
                                    label.RemoveClass("KillCounterIncrement");
                                }
                            });
                        }
                    }
                    break;
                    
                case "minion_strength":
                    // 力量小兵属性样式
                    label.AddClass("MinionAttributeText");
                    label.AddClass("strength");
                    break;
                    
                case "minion_agility":
                    // 敏捷小兵属性样式
                    label.AddClass("MinionAttributeText");
                    label.AddClass("agility");
                    break;
                    
                case "minion_intelligence":
                    // 智力小兵属性样式
                    label.AddClass("MinionAttributeText");
                    label.AddClass("intelligence");
                    break;
                    
                default:
                    // 默认样式处理 - 兼容旧版本
                    // 通过isKillCounter检查是否是击杀计数器
                    const isKillCounter = newText.includes("击杀:") || newText.includes("KILL:") || 
                                      newText.includes("击杀数") || newText.includes("Kills:") ||
                                      data.isKillCounter;
                    
                    if (isKillCounter) {
                        // 应用击杀计数器样式
                        label.AddClass("KillCounterText");
                        
                        // 检查文本是否变化，如果变化了且都是包含数字，检查数字是否增加
                        if (oldText && oldText !== newText) {
                            const oldNumber = parseInt(oldText.replace(/\D/g, ''));
                            const newNumber = parseInt(newText.replace(/\D/g, ''));
                            
                            if (!isNaN(oldNumber) && !isNaN(newNumber) && newNumber > oldNumber) {
                                // 数字增加，播放增加动画
                                label.AddClass("KillCounterIncrement");
                                // 动画播放完后移除类
                                $.Schedule(0.5, function() {
                                    if (label && label.IsValid()) {
                                        label.RemoveClass("KillCounterIncrement");
                                    }
                                });
                            }
                        }
                    } else {
                        // 如果指定了颜色且不是预定义样式，应用颜色
                        if (data.color) {
                            // 检查是否是直接传入的类名
                            if (data.color.startsWith('color_')) {
                                label.AddClass(data.color);
                            } else {
                                // 尝试查找匹配的预定义颜色
                                const colorMap = {
                                    '#ff4d4d': 'color_red',
                                    '#00ff7f': 'color_green',
                                    '#00bfff': 'color_blue',
                                    '#da70d6': 'color_purple',
                                    '#ffd700': 'color_gold',
                                    '#ffa500': 'color_orange',
                                    '#ffffff': 'color_white',
                                    '#a0a0a0': 'color_gray'
                                };
                                
                                const colorClass = colorMap[data.color.toLowerCase()];
                                if (colorClass) {
                                    label.AddClass(colorClass);
                                } else {
                                    // 如果没有匹配的预定义颜色，直接应用传入的颜色
                                    label.style.color = data.color;
                                }
                            }
                            
                            // 只有非预定义样式才使用默认的描边样式
                            // 添加更粗的黑色描边
                            label.style.textShadow = "3px 3px 3px #000000, -3px -3px 3px #000000, 3px -3px 3px #000000, -3px 3px 3px #000000, 2px 2px 5px #000000, -2px -2px 5px #000000, 2px -2px 5px #000000, -2px 2px 5px #000000";
                        }
                    }
                    break;
            }
        } else {
            
        }
        
        // 确保更新系统在运行
        StartUpdateSystem();
        
        // 检查面板是否正确创建和显示
        $.Schedule(0.1, function() {
            if (panel && panel.IsValid()) {
                
                if (label && label.IsValid()) {
                    
                }
            }
        });
    }


    function OnClearFloatingText(data) {
        
        const panel = trackedTexts.get(data.entityId);
        if (panel) {
            panel.DeleteAsync(0.0);
            trackedTexts.delete(data.entityId);
            
            
            // 如果清除的是调试实体，重置调试实体
            if (data.entityId === debugEntity) {
                
                debugEntity = null;
            }
        } else {
            
        }
    }

    function OnClearAllFloatingText() {
        
        trackedTexts.forEach((panel) => {
            if (panel && panel.IsValid()) {
                panel.DeleteAsync(0.0);
            }
        });
        trackedTexts.clear();
        // 确保计时器被清理
        updateTimer = null;
        debugEntity = null;
        
    }

    // 初始化
    // $.Msg("[初始化] 注册浮动文本事件处理程序");
    GameEvents.Subscribe("update_floating_text", OnUpdateFloatingText);
    GameEvents.Subscribe("clear_floating_text", OnClearFloatingText);
    GameEvents.Subscribe("clear_all_floating_text", OnClearAllFloatingText);
    // $.Msg("[初始化] 浮动文本系统已初始化完成");
})();