(function() {
    let trackedTexts = new Map();
    let updateTimer = null;  // 添加计时器引用
    let debugCounter = 0;  // 添加计数器用于追踪更新频率
    let debugEntity = null;  // 用于追踪第一个添加的实体

    // 添加：注册处理物品提示的函数，阻止地上物品显示提示
    $.RegisterForUnhandledEvent("DOTAShowDroppedItemTooltip", function(panel, itemName) {
        // 使用Schedule来在极短时间内显示然后立即隐藏提示，实际效果是不显示提示
        $.Schedule(0, function() {
            $.DispatchEvent("DOTAShowTextTooltip", panel, "");
            $.DispatchEvent("DOTAHideTextTooltip", panel);
        });
        return true; // 返回true表示已处理此事件
    });

    function getTextPosition(entityId) {
        if (!entityId || !Entities.IsValidEntity(entityId)) {
            if (debugCounter % 60 === 0) { // 降低日志频率
                // // $.Msg("[getTextPosition] 实体无效:", entityId);
            }
            return null;
        }
        
        // 获取实体世界坐标
        const pos = Entities.GetAbsOrigin(entityId);
        if (!pos) {
            if (debugCounter % 60 === 0) {
                // // $.Msg("[getTextPosition] 无法获取实体位置:", entityId);
            }
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
            if (debugCounter % 60 === 0) {
                // // $.Msg("[getTextPosition] 找不到有效面板，实体ID:", entityId);
            }
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
            if (debugCounter % 60 === 0) {
                // // $.Msg("[getTextPosition] 实体在屏幕边缘，实体ID:", entityId);
            }
            return null;
        }
        
        // 检查坐标是否有效
        if (!isFinite(x) || isNaN(x) || !isFinite(y) || isNaN(y)) {
            if (debugCounter % 60 === 0) {
                // // $.Msg("[getTextPosition] 无效坐标:", x, y, "实体ID:", entityId);
            }
            return null;
        }
        
        // 计算基于Z轴高度的缩放因子来实现透视效果
        // 获取物体的Z轴高度
        const zHeight = pos[2];
        
        // 基准高度 (地面高度，通常为0，可根据游戏地形调整)
        const baseHeight = 128;
        
        // 最大高度范围 (在此高度及以上，图标将显示最大尺寸)
        const maxHeightRange = 200;
        
        // 计算高度差
        const heightDiff = Math.max(0, zHeight - baseHeight);
        
        // 计算透视缩放因子 (高度越高，缩放因子越大，图标越大)
        // 范围: 1.0 (地面) 到 1.5 (最高处)
        const perspectiveScale = Math.min(1.5, 0.5 + (heightDiff / maxHeightRange) * 0.5);
        
        if (debugCounter % 60 === 0 && entityId === debugEntity) {
            // // $.Msg("[getTextPosition] 计算位置:", x, y, "透视缩放:", perspectiveScale, "实体ID:", entityId);
        }
        
        return {
            x: x,
            y: y,
            perspectiveScale: perspectiveScale // 添加透视缩放因子到返回值
        };
    }

    function UpdateAllTextPositions() {
        debugCounter++;
        if (debugCounter % 60 === 0) {  // 降低日志频率，每60帧记录一次
            // // $.Msg("[UpdateAllTextPositions] 当前跟踪实体数:", trackedTexts.size);
            trackedTexts.forEach((panel, entityId) => {
                const image = panel.FindChild(`FloatingText_${entityId}_Image`);
                if (image && image.IsValid()) {
                    // // $.Msg("[UpdateAllTextPositions] 实体ID:", entityId, "有效图像:", image.itemname);
                }
            });
        }

        const mainContainer = $('#FloatingTextContainer');
        if (!mainContainer) {
            // // $.Msg("[UpdateAllTextPositions] 找不到主容器");
            return;
        }

        // 如果没有需要更新的文本，取消计时器
        if (trackedTexts.size === 0) {
            // // $.Msg("[UpdateAllTextPositions] 没有需要更新的文本，停止更新");
            updateTimer = null;
            return;
        }

        trackedTexts.forEach((panel, entityId) => {
            // 对调试实体进行额外日志记录
            const isDebugEntity = debugEntity === entityId;
            if (isDebugEntity && debugCounter % 60 === 0) {
                // // $.Msg("[UpdateAllTextPositions] 更新调试实体位置:", entityId);
            }

            if (!panel || !panel.IsValid()) {
                
                trackedTexts.delete(entityId);
                return;
            }

            if (!entityId) {
                // // $.Msg("[UpdateAllTextPositions] 实体ID为空");
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
                if (isDebugEntity && debugCounter % 60 === 0) {
                    // // $.Msg("[UpdateAllTextPositions] 更新位置:", pos.x, pos.y);
                }
                
                // 获取正确的panel ID
                const panelId = `FloatingText_${entityId}`;
                
                // 检查是否包含图像元素
                const image = panel.FindChild(`${panelId}_Image`);
                if (image && image.IsValid()) {
                    // 如果是图像，Y坐标减去200
                    panel.style.position = `${pos.x}px ${pos.y + 50}px 0`;
                    if (isDebugEntity && debugCounter % 60 === 0) {
                        // // $.Msg("[UpdateAllTextPositions] 图像位置Y轴减去200:", pos.x, pos.y + 200);
                    }
                } else {
                    // 如果是文本，使用原始位置
                    panel.style.position = `${pos.x}px ${pos.y}px 0`;
                }
                
                // 应用透视缩放效果
                if (pos.perspectiveScale !== undefined) {
                    // 查找并缩放图像元素
                    const image = panel.FindChild(`${panelId}_Image`);
                    if (image && image.IsValid()) {
                        // 获取原始尺寸（如果没有设置，默认为初始尺寸）
                        const originalWidth = image.originalWidth || parseInt(image.style.width) || 40;
                        const originalHeight = image.originalHeight || parseInt(image.style.height) || 40;
                        
                        // 如果是第一次设置，保存原始尺寸
                        if (!image.originalWidth) {
                            image.originalWidth = originalWidth;
                            image.originalHeight = originalHeight;
                        }
                        
                        // 应用透视缩放
                        const newWidth = Math.ceil(image.originalWidth * pos.perspectiveScale);
                        const newHeight = Math.ceil(image.originalHeight * pos.perspectiveScale);
                        
                        // 设置新尺寸
                        image.style.width = `${newWidth}px`;
                        image.style.height = `${newHeight}px`;
                    }
                }
                
                // 检查位置是否实际更新
                if (isDebugEntity && debugCounter % 60 === 0) {
                    $.Schedule(0.01, function() {
                        if (panel && panel.IsValid()) {
                            // // $.Msg("[UpdateAllTextPositions] 位置更新后检查:", panel.style.position);
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
            // // $.Msg("[StartUpdateSystem] 开始更新文本位置");
            updateTimer = $.Schedule(1/200, UpdateAllTextPositions);
        }
    }
    
    function OnUpdateFloatingText(data) {
        // $.Msg("[OnUpdateFloatingText] 收到事件，实体ID:", data.entityId, "图像源:", data.imageSource);
        
        const mainContainer = $('#FloatingTextContainer');
        if (!mainContainer) {
            // $.Msg("[OnUpdateFloatingText] 错误: 找不到容器");
            return;
        }
        
        const entityId = data.entityId;
        const teamId = data.teamId; // 获取团队ID
        
        // 打印当前已跟踪的实体
        // $.Msg("[OnUpdateFloatingText] 当前已跟踪的实体数量:", trackedTexts.size);
        trackedTexts.forEach((panel, id) => {
            // $.Msg("[OnUpdateFloatingText] 已跟踪的实体ID:", id);
        });
        
        // 如果是首次添加实体，记录为调试实体
        if (trackedTexts.size === 0 && entityId) {
            debugEntity = entityId;
            
        }

        if (!entityId) {
            // $.Msg("[OnUpdateFloatingText] 错误: 实体ID为空");
            return;
        }

        
        
        const panelId = `FloatingText_${entityId}`;
        // $.Msg("[OnUpdateFloatingText] 创建/更新面板ID:", panelId);
        
        // 获取或创建面板
        let panel = mainContainer.FindChild(panelId);
        if (!panel) {
            // $.Msg("[OnUpdateFloatingText] 创建新面板，实体ID:", entityId);
            panel = $.CreatePanel('Panel', mainContainer, panelId);
            
            // 检查是否需要显示图像而不是文本
            if (data.imageSource) {
                // $.Msg("[OnUpdateFloatingText] 添加图像，源:", data.imageSource);
                // 使用DOTAItemImage来显示物品图标
                const image = $.CreatePanel('DOTAItemImage', panel, `${panelId}_Image`);
                image.itemname = data.imageSource; // 直接设置物品名称
                image.AddClass('FloatingImage');
                
                // 根据团队ID添加对应的颜色类
                if (teamId === 2) { // 天辉队伍ID
                    image.AddClass('GoodTeam');
                } else if (teamId === 3) { // 夜魇队伍ID
                    image.AddClass('BadTeam');
                }
                
                // 禁用悬停提示
                image.SetPanelEvent('onmouseover', function() {});
                image.SetPanelEvent('onmouseout', function() {});
                

                
                // 设置图像尺寸
                if (data.imageWidth && data.imageHeight) {
                    image.style.width = `${data.imageWidth}px`;
                    image.style.height = `${data.imageHeight}px`;
                    // $.Msg("[OnUpdateFloatingText] 设置图像尺寸:", data.imageWidth, "x", data.imageHeight);
                }
            } else {
                // 原始文本标签创建
                const label = $.CreatePanel('Label', panel, `${panelId}_Label`);
            }
            
            // 添加向上偏移的CSS样式
            panel.style.marginTop = "-65px"; // 使面板向上偏移50像素
            //// $.Msg("更新文本位置");
            // 重要：先将面板存储到trackedTexts中，再获取位置
            trackedTexts.set(entityId, panel);

            // 设置初始位置
            const pos = getTextPosition(entityId);
            if (pos) {
                // $.Msg("[OnUpdateFloatingText] 设置初始位置:", pos.x, pos.y);
                panel.style.position = `${pos.x}px ${pos.y}px 0`;
            } else {
                // $.Msg("[OnUpdateFloatingText] 无法获取初始位置");
            }
        } else {
            // $.Msg("[OnUpdateFloatingText] 更新现有面板，实体ID:", entityId);
        }
        
        // 确保现有面板也在trackedTexts中
        trackedTexts.set(entityId, panel);
        
        // 更新面板内容 (文本或图像)
        if (data.imageSource) {
            // 如果是图像更新
            const image = panel.FindChild(`${panelId}_Image`);
            if (!image) {
                // $.Msg("[OnUpdateFloatingText] 现有面板中找不到图像，创建新图像");
                // 如果之前没有图像，但现在需要显示图像
                const newImage = $.CreatePanel('DOTAItemImage', panel, `${panelId}_Image`);
                newImage.itemname = data.imageSource; // 直接设置物品名称
                newImage.AddClass('FloatingImage');
                
                // 根据团队ID添加对应的颜色类
                if (teamId === 2) { // 天辉队伍ID
                    newImage.AddClass('GoodTeam');
                } else if (teamId === 3) { // 夜魇队伍ID
                    newImage.AddClass('BadTeam');
                }
                
                // 禁用悬停提示
                newImage.SetPanelEvent('onmouseover', function() {});
                newImage.SetPanelEvent('onmouseout', function() {});
                

                // 设置图像尺寸
                if (data.imageWidth && data.imageHeight) {
                    newImage.style.width = `${data.imageWidth}px`;
                    newImage.style.height = `${data.imageHeight}px`;
                    // $.Msg("[OnUpdateFloatingText] 设置新图像尺寸:", data.imageWidth, "x", data.imageHeight);
                }
                
                // 移除现有的文本标签（如果有）
                const existingLabel = panel.FindChild(`${panelId}_Label`);
                if (existingLabel) {
                    // $.Msg("[OnUpdateFloatingText] 移除现有文本标签");
                    existingLabel.DeleteAsync(0.0);
                }
            } else {
                // $.Msg("[OnUpdateFloatingText] 更新现有图像，源:", data.imageSource, "当前源:", image.itemname);
                // 检查是否需要更新现有图像
                if (image.itemname !== data.imageSource) {
                    image.itemname = data.imageSource;
                    // $.Msg("[OnUpdateFloatingText] 已更新图像源为:", data.imageSource);
                    
                    // 更新团队颜色类
                    image.RemoveClass('GoodTeam');
                    image.RemoveClass('BadTeam');
                    
                    if (teamId === 2) { // 天辉队伍ID
                        image.AddClass('GoodTeam');
                    } else if (teamId === 3) { // 夜魇队伍ID
                        image.AddClass('BadTeam');
                    }
                }
                
                // 更新尺寸
                if (data.imageWidth && data.imageHeight) {
                    image.style.width = `${data.imageWidth}px`;
                    image.style.height = `${data.imageHeight}px`;
                    // $.Msg("[OnUpdateFloatingText] 更新现有图像尺寸:", data.imageWidth, "x", data.imageHeight);
                }
            }
        } else {
            // 如果是文本更新 - 原始逻辑
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
            } else if (!panel.FindChild(`${panelId}_Image`)) {
                // 如果既没有文本标签也没有图像，创建一个文本标签
                const newLabel = $.CreatePanel('Label', panel, `${panelId}_Label`);
                newLabel.text = data.text || "";
                
                if (data.fontSize) {
                    newLabel.style.fontSize = `${data.fontSize}px`;
                }
            }
        }
        
        // 确保更新系统在运行
        StartUpdateSystem();
        
        // 检查面板是否正确创建和显示
        $.Schedule(0.1, function() {
            if (panel && panel.IsValid()) {
                const label = panel.FindChild(`${panelId}_Label`);
                const image = panel.FindChild(`${panelId}_Image`);
                if ((label && label.IsValid()) || (image && image.IsValid())) {
                    // $.Msg("[OnUpdateFloatingText] 面板创建成功，图像是否存在:", image && image.IsValid());
                }
            }
        });
    }


    function OnClearFloatingText(data) {
        // $.Msg("[OnClearFloatingText] 清除浮动文本，实体ID:", data.entityId);
        
        // 清理常规文本
        const panel = trackedTexts.get(data.entityId);
        if (panel) {
            panel.DeleteAsync(0.0);
            trackedTexts.delete(data.entityId);
            // $.Msg("[OnClearFloatingText] 已删除面板，实体ID:", data.entityId);
            
            // 如果清除的是调试实体，重置调试实体
            if (data.entityId === debugEntity) {
                // $.Msg("[OnClearFloatingText] 已重置调试实体");
                debugEntity = null;
            }
        } else {
            // $.Msg("[OnClearFloatingText] 找不到要清除的面板，实体ID:", data.entityId);
        }

        // 清理与该实体相关的临时文本
        tempTextPanels.forEach((tempPanel, panelId) => {
            if (tempPanel.entityId === data.entityId) {
                tempPanel.DeleteAsync(0.0);
                tempTextPanels.delete(panelId);
                // $.Msg("[OnClearFloatingText] 已删除临时文本面板，面板ID:", panelId);
            }
        });
    }

    function OnClearAllFloatingText() {
        // 清理所有常规文本
        trackedTexts.forEach((panel) => {
            if (panel && panel.IsValid()) {
                panel.DeleteAsync(0.0);
            }
        });
        trackedTexts.clear();
        
        // 清理所有临时文本
        tempTextPanels.forEach((panel) => {
            if (panel && panel.IsValid()) {
                panel.DeleteAsync(0.0);
            }
        });
        tempTextPanels.clear();
        
        // 确保计时器被清理
        updateTimer = null;
        debugEntity = null;
        
        // $.Msg("[OnClearAllFloatingText] 已清理所有文本，包括临时渐隐文本");
    }

    // 初始化
    // // $.Msg("[初始化] 注册浮动文本事件处理程序");
    GameEvents.Subscribe("update_floating_text", OnUpdateFloatingText);
    GameEvents.Subscribe("clear_floating_text", OnClearFloatingText);
    GameEvents.Subscribe("clear_all_floating_text", OnClearAllFloatingText);
    
    // 添加新的临时浮动文本功能
    GameEvents.Subscribe("show_temp_floating_text", OnShowTempFloatingText);
    
    // // $.Msg("[初始化] 浮动文本系统已初始化完成");
    
    // 用于存储临时文本的Map
    let tempTextPanels = new Map();
    let tempTextCounter = 0;
    
    // 临时文本动画效果
    function AnimateTempText(panelId, elapsed) {
        const panel = tempTextPanels.get(panelId);
        
        if (!panel || !panel.IsValid()) {
            tempTextPanels.delete(panelId);
            return;
        }
        
        // 最大动画时间（秒）
        const maxDuration = 2.0;
        
        if (elapsed >= maxDuration) {
            // 动画结束，删除面板
            panel.DeleteAsync(0);
            tempTextPanels.delete(panelId);
            return;
        }
        
        // 获取实体ID
        const entityId = panel.entityId;
        
        // 如果实体ID无效，中止动画
        if (!entityId || !Entities.IsValidEntity(entityId)) {
            panel.DeleteAsync(0);
            tempTextPanels.delete(panelId);
            return;
        }
        
        // 计算当前动画进度 (0-1)
        const progress = elapsed / maxDuration;
        
        // 计算上升偏移距离（总共上升100像素）
        const riseOffset = 100 * progress;
        
        // 计算透明度（从1减少到0）
        const opacity = 1.0 - progress;
        
        // 获取实体的当前屏幕位置
        const screenPos = GetEntityScreenPosition(entityId);
        if (screenPos) {
            // 应用基础位置（跟随实体）和上升偏移（相对动画）
            panel.style.position = `${screenPos.x}px ${screenPos.y - 50 - riseOffset}px 0`;
            panel.style.opacity = opacity.toString();
        } else {
            // 如果实体不可见，可以选择隐藏或删除面板
            panel.visible = false;
        }
        
        // 继续动画
        $.Schedule(0.016, function() { // 大约60FPS
            AnimateTempText(panelId, elapsed + 0.016);
        });
    }
    
    // 创建并显示临时浮动文本
    function OnShowTempFloatingText(data) {
        const mainContainer = $('#FloatingTextContainer');
        if (!mainContainer) {
            return;
        }
        
        const entityId = data.entityId;
        if (!entityId) {
            return;
        }
        
        // 获取实体的世界坐标
        if (!Entities.IsValidEntity(entityId)) {
            return;
        }
        
        const pos = Entities.GetAbsOrigin(entityId);
        if (!pos) {
            return;
        }
        
        // 创建唯一ID
        const uniqueId = `TempFloatingText_${entityId}_${tempTextCounter++}`;
        
        // 创建临时文本面板
        const tempPanel = $.CreatePanel('Panel', mainContainer, uniqueId);
        tempPanel.AddClass('TempFloatingTextPanel');
        
        // 存储实体ID用于跟踪
        tempPanel.entityId = entityId;
        
        // 创建文本标签
        const label = $.CreatePanel('Label', tempPanel, `${uniqueId}_Label`);
        label.text = data.text || "";
        label.AddClass('TempFloatingText');
        
        // 设置字体大小
        if (data.fontSize) {
            label.style.fontSize = `${data.fontSize}px`;
        }
        
        // 应用颜色
        if (data.color) {
            if (data.color.startsWith('color_')) {
                label.AddClass(data.color);
            } else {
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
                    label.style.color = data.color;
                }
            }
        }
        
        // 设置文本样式
        if (data.textStyle === "minion_intelligence") {
            label.AddClass("MinionAttributeText");
            label.AddClass("intelligence");
        }
        
        // 添加黑色描边效果
        label.style.textShadow = "2px 2px 2px #000000, -2px -2px 2px #000000, 2px -2px 2px #000000, -2px 2px 2px #000000";
        
        // 计算屏幕位置
        const screenPos = GetEntityScreenPosition(entityId);
        if (screenPos) {
            // 设置初始位置（在实体头顶上方）
            tempPanel.style.position = `${screenPos.x}px ${screenPos.y - 50}px 0`;
            
            // 添加到临时面板集合
            tempTextPanels.set(uniqueId, tempPanel);
            
            // 启动动画效果
            AnimateTempText(uniqueId, 0);
        } else {
            // 如果无法获取位置，删除面板
            tempPanel.DeleteAsync(0);
        }
    }
    
    // 获取实体的屏幕位置
    function GetEntityScreenPosition(entityId) {
        if (!entityId || !Entities.IsValidEntity(entityId)) {
            return null;
        }
        
        // 获取实体世界坐标
        const pos = Entities.GetAbsOrigin(entityId);
        // // $.Msg("[GetEntityScreenPosition] 实体ID:", entityId, "世界坐标:", pos);
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
            pos[2] + heightOffset
        ];
        
        // 转换为屏幕坐标
        const wx = Game.WorldToScreenX(worldPos[0], worldPos[1], worldPos[2]);
        const wy = Game.WorldToScreenY(worldPos[0], worldPos[1], worldPos[2]);
        
        // 获取屏幕宽高和缩放比例
        const panel = $.GetContextPanel();
        const sw = panel.actuallayoutwidth;
        const sh = panel.actuallayoutheight;
        
        // 使用1080p作为基准分辨率
        const scale = 1080 / sh;
        
        // 应用缩放
        let x = scale * wx;
        let y = scale * wy;
        
        // 检查坐标是否有效
        if (!isFinite(x) || isNaN(x) || !isFinite(y) || isNaN(y)) {
            return null;
        }
        
        return { x: x, y: y };
    }
})();