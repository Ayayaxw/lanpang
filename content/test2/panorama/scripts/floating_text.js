(function() {
    let trackedTexts = new Map();
    let updateTimer = null;  // 添加计时器引用

    function getTextPosition(entityId) {
        if (!entityId) return null;
    
        const entityPos = Entities.GetAbsOrigin(entityId);
        if (!entityPos) return null;
    
        const context = $.GetContextPanel();
        const scaleX = context.actualuiscale_x || 1;
        const scaleY = context.actualuiscale_y || 1;
    
        // 转换世界坐标到屏幕坐标
        const screenX = Game.WorldToScreenX(entityPos[0], entityPos[1], entityPos[2]) / scaleX;
        const screenY = Game.WorldToScreenY(entityPos[0], entityPos[1], entityPos[2]) / scaleY;
    
        // 获取面板的宽度和高度（如果需要居中）
        const panel = trackedTexts.get(entityId);
        let offsetX = -1000;
        let offsetY = 0; // 默认向上偏移50像素
    
        if (panel) {
            offsetX = -panel.actuallayoutwidth / 2 + 50; // 水平居中
        }
    
        return {
            x: screenX + offsetX,
            y: screenY + offsetY
        };
    }

    function UpdateAllTextPositions() {
        const mainContainer = $('#FloatingTextContainer');
        if (!mainContainer) {
            $.Msg("[UpdateAllTextPositions] 找不到主容器");
            return;
        }

        // 如果没有需要更新的文本，取消计时器
        if (trackedTexts.size === 0) {
            $.Msg("[UpdateAllTextPositions] 没有需要更新的文本，停止更新");
            updateTimer = null;
            return;
        }

        trackedTexts.forEach((panel, entityId) => {
            if (!panel || !panel.IsValid()) {
                $.Msg(`[UpdateAllTextPositions] 删除无效面板 ${entityId}`);
                trackedTexts.delete(entityId);
                return;
            }

            // 检查实体是否还存在
            if (!Entities.IsValidEntity(entityId)) {
                $.Msg(`[UpdateAllTextPositions] 实体 ${entityId} 已失效，移除面板`);
                panel.DeleteAsync(0.0);
                trackedTexts.delete(entityId);
                return;
            }

            const pos = getTextPosition(entityId);
            if (pos) {
                panel.style.position = `${pos.x}px ${pos.y}px 0`;
            }
        });

        // 只有在还有文本需要更新时才继续更新
        if (trackedTexts.size > 0) {
            updateTimer = $.Schedule(1/144, UpdateAllTextPositions);
        }
    }

    function StartUpdateSystem() {
        // 如果计时器已经在运行，就不要再创建新的
        if (!updateTimer && trackedTexts.size > 0) {
            updateTimer = $.Schedule(1/144, UpdateAllTextPositions);
        }
    }
    
    function OnUpdateFloatingText(data) {
        //$.Msg("[OnUpdateFloatingText] 收到事件:", data);
        
        const mainContainer = $('#FloatingTextContainer');
        if (!mainContainer) {
            $.Msg("[OnUpdateFloatingText] 错误: 找不到容器");
            return;
        }
        
        const entityId = data.entityId;
        const panelId = `FloatingText_${entityId}`;
        
        // 获取或创建面板
        let panel = mainContainer.FindChild(panelId);
        if (!panel) {
            panel = $.CreatePanel('Panel', mainContainer, panelId);
            
            const label = $.CreatePanel('Label', panel, `${panelId}_Label`);

            
            // 设置初始位置
            const pos = getTextPosition(entityId);
            if (pos) {
                panel.style.position = `${pos.x}px ${pos.y}px 0`;
                panel.style.transform = 'translate(-50%, -50%)';
            }
        }
        
        // 更新文本内容
        const label = panel.FindChild(`${panelId}_Label`);
        if (label) {
            label.text = data.text;
            if (data.fontSize) {
                label.style.fontSize = `${data.fontSize}px`;
            }
            if (data.color) {
                label.style.color = data.color;
            }
        }
        
        // 存储面板引用
        trackedTexts.set(entityId, panel);
        
        // 确保更新系统在运行
        StartUpdateSystem();
    }


    function OnClearFloatingText(data) {
        const panel = trackedTexts.get(data.entityId);
        if (panel) {
            panel.DeleteAsync(0.0);
            trackedTexts.delete(data.entityId);
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
    }

    // 初始化
    GameEvents.Subscribe("update_floating_text", OnUpdateFloatingText);
    GameEvents.Subscribe("clear_floating_text", OnClearFloatingText);
    GameEvents.Subscribe("clear_all_floating_text", OnClearAllFloatingText);
})();