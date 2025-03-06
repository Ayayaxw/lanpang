// 沙盒功能相关变量
let sandboxFunctions = [];
let sandboxModePanel = $('#SandboxModePanelUnique');
let sandboxModeButton = $('#SandboxModeButtonUnique');
let isSandboxModePanelVisible = false;

// 初始化函数
(function() {
    // 请求沙盒功能数据
    GameEvents.SendCustomGameEventToServer("sandbox_custom_event", { "RequestSandboxData": "1" });
    
    // 注册事件监听器，接收沙盒功能数据
    GameEvents.Subscribe("initialize_sandbox_functions", onInitializeSandboxFunctions);
    
    // 设置按钮事件
    sandboxModeButton.SetPanelEvent('onactivate', toggleSandboxModePanel);
})();


// 切换沙盒模式面板可见性
function toggleSandboxModePanel() {
    GameEvents.SendCustomGameEventToServer("sandbox_custom_event", { "RequestSandboxData": "1" });
    isSandboxModePanelVisible = !isSandboxModePanelVisible;
    if (isSandboxModePanelVisible) {
        sandboxModePanel.AddClass('Visible');
        // 如果有其他面板是可见的，可以在这里隐藏它们
    } else {
        sandboxModePanel.RemoveClass('Visible');
    }
}

// 接收到服务器发送的沙盒功能数据
function onInitializeSandboxFunctions(event) {
    sandboxFunctions = Object.values(event);
    updateSandboxFunctions();
}

// 更新沙盒功能面板
function updateSandboxFunctions() {
    // 清除现有的按钮
    sandboxModePanel.RemoveAndDeleteChildren();
    
    // 添加标题
    const title = $.CreatePanel('Label', sandboxModePanel, '');
    title.text = '沙盒模式';
    
    // 按category对功能进行分组
    const categorizedFunctions = {};
    sandboxFunctions.forEach(func => {
        if (!categorizedFunctions[func.category]) {
            categorizedFunctions[func.category] = [];
        }
        categorizedFunctions[func.category].push(func);
    });
    
    // 定义category的显示顺序和显示名称
    const categoryOrder = {
        "hero": { order: 1, name: "英雄操作" },
        "resource": { order: 2, name: "游戏资源" },
        "creep": { order: 3, name: "小兵控制" },
        "environment": { order: 4, name: "环境设置" }
    };
    
    // 按照定义的顺序创建分类
    Object.entries(categorizedFunctions)
        .sort(([catA], [catB]) => {
            const orderA = categoryOrder[catA]?.order || 999;
            const orderB = categoryOrder[catB]?.order || 999;
            return orderA - orderB;
        })
        .forEach(([category, functions]) => {
            // 创建分类容器
            const categoryContainer = $.CreatePanel('Panel', sandboxModePanel, '');
            categoryContainer.AddClass('CategoryContainer');
            
            // 创建分类标题
            const categoryTitle = $.CreatePanel('Label', categoryContainer, '');
            categoryTitle.AddClass('CategoryTitle');
            categoryTitle.text = categoryOrder[category]?.name || category;
            
            // 创建一行用于放置功能按钮
            let currentRow = $.CreatePanel('Panel', categoryContainer, '');
            currentRow.AddClass('ModesRow');
            
            // 每行最多放置4个功能按钮
            const FUNCTIONS_PER_ROW = 4;
            functions.forEach((func, index) => {
                if (index > 0 && index % FUNCTIONS_PER_ROW === 0) {
                    currentRow = $.CreatePanel('Panel', categoryContainer, '');
                    currentRow.AddClass('ModesRow');
                }
                
                const button = $.CreatePanel('Button', currentRow, '');
                button.AddClass('GameModeOption');
                
                const label = $.CreatePanel('Label', button, '');
                label.text = func.name;
                
                button.SetPanelEvent('onactivate', () => {
                    executeSandboxFunction(func.id);
                });
            });
        });
}

// 执行沙盒功能
// 执行沙盒功能
// 执行沙盒功能
function executeSandboxFunction(functionId) {
    $.Msg("执行功能ID: " + functionId);
    
    // 查找对应的功能定义
    const func = sandboxFunctions.find(f => f.id === functionId);
    
    $.Msg("找到的功能: ", func);
    
    if (func) {
        // 检查是否需要额外选择
        if (func.requiresSelection && func.selectionType === "hero") {
            $.Msg("该功能需要选择英雄!");
            
            // 关闭沙盒面板
            if (isSandboxModePanelVisible) {
                toggleSandboxModePanel();
            }
            
            // 初始化GameSetup对象（如果不存在）
            if (!GameEvents.GameSetup) {
                GameEvents.GameSetup = {};
            }
            
            // 记录我们正在执行一个沙盒功能
            GameEvents.GameSetup.currentAction = 'SandboxHeroSelect';
            GameEvents.GameSetup.sandboxFunctionId = functionId;
            
            $.Msg("GameSetup设置完成，准备打开英雄选择面板");
            
            // 检查并获取英雄选择面板
            const fcHeroPickPanel = $('#FcHeroPickPanel');
            if (!fcHeroPickPanel) {
                $.Msg("错误：找不到FcHeroPickPanel!");
                return;
            }
            
            // 检查面板是否已最小化
            if (fcHeroPickPanel.BHasClass('minimized')) {
                fcHeroPickPanel.RemoveClass('minimized');
                $.Msg("英雄选择面板已打开");
            } else {
                $.Msg("英雄选择面板已经是打开状态");
            }
        } else {
            // 不需要选择，直接发送请求
            GameEvents.SendCustomGameEventToServer("sandbox_custom_event", { functionId: functionId });
            $.Msg("执行沙盒功能: " + functionId);
        }
    }
}