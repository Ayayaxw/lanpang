(function() {
    // 固定世界坐标
    const centerPoint = { x: 150, y: 150, z: 141 };
    
    let debugCounter = 0; // 添加计数器用于降低日志频率
    
    // 初始化方法
    function Initialize() {
        $.Msg("[网格面板] 初始化开始");
        
        // 创建网格面板
        CreateGridPanel();
        
        // 启动位置更新系统
        StartPositionUpdateSystem();
        
        $.Msg("[网格面板] 初始化完成");
    }
    
    // 创建网格面板
    function CreateGridPanel() {
        // 获取主容器
        const mainContainer = $('#GridPanelContainer');
        if (!mainContainer) {
            $.Msg("[网格面板] 错误: 找不到主容器");
            return;
        }
        
        // 创建网格面板
        let gridPanel = mainContainer.FindChild('SimplePanel');
        if (!gridPanel) {
            gridPanel = $.CreatePanel('Panel', mainContainer, 'SimplePanel');
            gridPanel.AddClass('SimplePanel');
            
            // 直接设置CSS中定义的尺寸
            gridPanel.style.width = '1000px';
            gridPanel.style.height = '1000px';
            
            $.Msg("[网格面板] 已创建网格面板");
        }
    }
    
    // 获取网格面板位置
    function getGridPanelPosition() {
        debugCounter++;
        
        try {
            // 基础固定高度偏移 - 血条偏移固定为200
            const heightOffset = 100;
            
            // 将3D世界坐标转换为屏幕坐标
            const worldPos = [
                centerPoint.x,
                centerPoint.y,
                centerPoint.z + heightOffset // 添加固定的血条偏移高度
            ];
            
            // 转换为屏幕坐标
            const wx = Game.WorldToScreenX(worldPos[0], worldPos[1], worldPos[2]);
            const wy = Game.WorldToScreenY(worldPos[0], worldPos[1], worldPos[2]);
            
            // 输出调试信息（降低频率）
            if (debugCounter % 60 === 0) {
                $.Msg(`[网格面板] 世界坐标: (${worldPos[0]}, ${worldPos[1]}, ${worldPos[2]}) => 屏幕坐标: (${wx}, ${wy})`);
            }
            
            // 获取屏幕宽高和缩放比例
            const panel = $.GetContextPanel();
            const sw = panel.actuallayoutwidth;
            const sh = panel.actuallayoutheight;
            
            if (debugCounter % 60 === 0) {
                $.Msg(`[网格面板] 屏幕宽高: (${sw}, ${sh})`);
            }
            
            // 计算缩放因子 - 使用1080p作为基准分辨率
            const scale = 1080 / sh;
            
            // 应用偏移和缩放
            const offsetX = 0; // 可以根据需要调整
            const offsetY = 0; // 可以根据需要调整
            
            let x = scale * wx + offsetX;
            let y = scale * wy + offsetY;
            
            // 获取当前面板
            const gridPanel = $('#SimplePanel');

            
            // 获取面板尺寸 - 需要考虑缩放因子
            const pw = gridPanel.actuallayoutwidth;
            const ph = gridPanel.actuallayoutheight;
            $.Msg("[网格面板] 面板尺寸: " + pw + ", " + ph);
            // 应用水平居中对齐 - 使用缩放后的面板宽度
            x -= (pw * scale) / 2;
            
            // 应用垂直底部对齐（文本显示在头顶上方）- 同样考虑缩放
            y -= (ph * scale) / 2;
            
            // 边缘检测逻辑
            const edgePercentage = 5; // 距离边缘的百分比
            const padx = sw * edgePercentage / 100;
            const pady = sh * edgePercentage / 100;
            
            const originalX = x;
            const originalY = y;
            

            
            const isOnEdge = (x !== originalX || y !== originalY);
            
            // 如果在屏幕边缘，记录日志
            if (isOnEdge && debugCounter % 60 === 0) {
                $.Msg("[网格面板] 面板在屏幕边缘");
            }
            
            // 检查坐标是否有效
            if (!isFinite(x) || isNaN(x) || !isFinite(y) || isNaN(y)) {
                if (debugCounter % 60 === 0) {
                    $.Msg("[网格面板] 无效坐标:", x, y);
                }
                return null;
            }
            
            // 计算基于Z轴高度的缩放因子来实现透视效果
            // 获取物体的Z轴高度
            const zHeight = centerPoint.z;
            
            // 基准高度 (地面高度，通常为0，可根据游戏地形调整)
            const baseHeight = 128;
            
            // 最大高度范围 (在此高度及以上，图标将显示最大尺寸)
            const maxHeightRange = 200;
            
            // 计算高度差
            const heightDiff = Math.max(0, zHeight - baseHeight);
            
            // 计算透视缩放因子 (高度越高，缩放因子越大，图标越大)
            // 范围: 1.0 (地面) 到 1.5 (最高处)
            const perspectiveScale = Math.min(1.5, 0.5 + (heightDiff / maxHeightRange) * 0.5);
            
            if (debugCounter % 60 === 0) {
                $.Msg(`[网格面板] 计算位置: ${x}, ${y}, 透视缩放: ${perspectiveScale}`);
            }
            
            return {
                x: x,
                y: y,
                perspectiveScale: perspectiveScale
            };
        } catch (e) {
            $.Msg("[网格面板] 位置计算错误:", e);
            return null;
        }
    }
    
    // 更新面板位置
    function UpdatePosition() {
        const gridPanel = $('#SimplePanel');
        if (!gridPanel) {
            return;
        }
        
        // 获取位置信息
        const pos = getGridPanelPosition();
        if (!pos) {
            return;
        }
        
        // 应用位置
        gridPanel.style.position = `${pos.x}px ${pos.y}px 0px`;
        
        // 应用透视缩放效果
        if (pos.perspectiveScale !== undefined) {
            // 获取原始尺寸
            const originalWidth = gridPanel.originalWidth || parseInt(gridPanel.style.width) || 50;
            const originalHeight = gridPanel.originalHeight || parseInt(gridPanel.style.height) || 50;
            
            // 如果是第一次设置，保存原始尺寸
            if (!gridPanel.originalWidth) {
                gridPanel.originalWidth = originalWidth;
                gridPanel.originalHeight = originalHeight;
            }
            
            // 应用透视缩放
            const newWidth = Math.ceil(gridPanel.originalWidth * pos.perspectiveScale);
            const newHeight = Math.ceil(gridPanel.originalHeight * pos.perspectiveScale);
            
            // 设置新尺寸
            gridPanel.style.width = `${newWidth}px`;
            gridPanel.style.height = `${newHeight}px`;
        }
    }
    
    // 启动位置更新系统
    function StartPositionUpdateSystem() {
        // 立即更新一次
        UpdatePosition();
        
        // 设置循环更新
        $.Schedule(1/60, function() {
            UpdatePosition();
            StartPositionUpdateSystem();
        });
    }
    
    // 等待游戏UI加载完成后初始化
    $.Schedule(0.5, Initialize);
})(); 