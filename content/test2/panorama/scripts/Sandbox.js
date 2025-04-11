// 沙盒功能相关变量
let sandboxFunctions = [];
let sandboxModePanel = $('#SandboxModePanelUnique');
let sandboxModeButton = $('#SandboxModeButtonUnique');
let isSandboxModePanelVisible = false;

// 添加全局变量存储用户选择
let userSelections = {
    heroId: null,
    heroName: null, 
    heroIcon: null,
    facetId: 0,
    facetName: null,
    teamId: 2, // DOTA_TEAM_GOODGUYS 默认值
    position: { x: 0, y: 0, z: 0 }, // 默认值
    heroCodeName: null
};

// 添加变量以防止重复处理
let lastProcessedHeroId = -1;
let lastProcessedTime = 0;
let processingHeroSelection = false;
// 添加计数器变量记录触发次数
let heroSelectionTriggerCount = 0;

// 初始化函数
(function() {
    // 请求沙盒功能数据
    GameEvents.SendCustomGameEventToServer("sandbox_custom_event", { "RequestSandboxData": "1" });
    
    // 注册事件监听器，接收沙盒功能数据
    GameEvents.Subscribe("initialize_sandbox_functions", onInitializeSandboxFunctions);
    
    // 设置按钮事件
    sandboxModeButton.SetPanelEvent('onactivate', toggleSandboxModePanel);

    // 注册英雄选择事件
    const debouncedSandboxHandler = debounce(onSandboxHeroSelected, 0.1); // 0.1秒防抖
    $.RegisterEventHandler('DOTAUIHeroPickerHeroSelected', $('#HeroPicker'), debouncedSandboxHandler);

    // 尝试使用一个简单的命令绑定
    const sandbox_toggle = "sandbox_toggle" + Math.floor(Math.random() * 99999999);
    Game.AddCommand(sandbox_toggle, toggleSandboxOnKeyPress, "打开/关闭沙盒模式面板", 0);
    
    // 尝试将F8键绑定到这个命令
    Game.CreateCustomKeyBind("F8", sandbox_toggle);
    
    $.Msg("沙盒模式脚本初始化完成，F8键绑定已设置");
})();

// 简化的键盘快捷键处理函数
function toggleSandboxOnKeyPress() {
    $.Msg("快捷键已触发，正在切换沙盒面板");
    toggleSandboxModePanel();
}

// 防抖函数，限制函数调用频率
function debounce(func, wait) {
    let scheduleId = null;
    return function executedFunction(...args) {
        const later = () => {
            scheduleId = null;
            func(...args);
        };
        if (scheduleId !== null) {
            $.CancelScheduled(scheduleId);
        }
        scheduleId = $.Schedule(wait, later);
    };
}

// 英雄选择处理函数 - 使用独特名称
function onSandboxHeroSelected(heroId, facetId) {
    // 防止重复处理同一个英雄选择
    if (GameEvents.GameSetup.currentAction !== 'SandboxHeroSelect') {
        return;
    }
    if (processingHeroSelection || (heroId === lastProcessedHeroId && Date.now() - lastProcessedTime < 100)) {
        $.Msg("快速重复点击，已阻止");
        return;
    }

    const now = Game.GetGameTime();
    if (heroId === lastProcessedHeroId && now - lastProcessedTime < 1.0) {
        $.Msg("忽略重复的英雄选择事件");
        return;
    }
    
    // 防止并发处理
    if (processingHeroSelection) {
        $.Msg("已有处理中的英雄选择，忽略此次事件");
        return;
    }
    
    processingHeroSelection = true;
    lastProcessedHeroId = heroId;
    lastProcessedTime = now;
    
    // 增加触发计数并获取当前时间，使用Game.GetGameTime()代替Date对象
    heroSelectionTriggerCount++;
    const currentTime = Game.GetGameTime().toFixed(2); // 保留两位小数的游戏时间
    
    $.Msg("沙盒英雄选择触发 - heroId:", heroId, "facetId:", facetId, "第", heroSelectionTriggerCount, "次触发，游戏时间:", currentTime);
    
    const action = GameEvents.GameSetup.currentAction;
    
    try {
        // 检查是否是沙盒模式英雄选择
        if (action === 'SandboxHeroSelect') {
            // 更新用户选择
            userSelections.heroId = heroId;
            userSelections.facetId = facetId;
            
            // 调试输出heroData
            $.Msg("heroData结构:", JSON.stringify(Object.keys(heroData || {})).substring(0, 100) + "...");
            $.Msg("当前英雄ID:", heroId, "是否存在于heroData:", Boolean(heroData && heroData[heroId]));
            
            // 直接从CommonFunction.js中的heroData获取英雄信息
            if (heroData && heroData[heroId]) {
                const hero = heroData[heroId];
                $.Msg("找到的英雄数据:", JSON.stringify(hero));
                
                if (hero.codeName) {
                    const heroToken = "npc_dota_hero_" + hero.codeName;
                    userSelections.heroCodeName = heroToken;
                    $.Msg("生成heroToken:", heroToken);
                    
                    // 新增heroToken有效性检查
                    if (heroesFacets && heroesFacets[heroToken]) {
                        $.Msg("该英雄存在命石数据，数量:", Object.keys(heroesFacets[heroToken].Facets).length);
                    } else {
                        $.Msg("警告：未找到该英雄的命石数据");
                    }
                    
                    userSelections.heroName = $.Localize("#" +heroToken);
                    userSelections.heroIcon = `s2r://panorama/images/heroes/selection/${hero.codeName}.png`;
                } else {
                    $.Msg("警告: hero.codename未定义");
                    userSelections.heroName = hero.name || `英雄 ${heroId}`;
                    userSelections.heroIcon = `s2r://panorama/images/heroes/selection/heroes/default.png`;
                }
            }
            // 从heroesFacets获取命石信息
            const heroToken = userSelections.heroCodeName;
            $.Msg("开始处理命石数据 - heroToken:", heroToken, "facetId:", facetId);
            $.Msg("heroesFacets数据结构:", JSON.stringify({
                hasHeroesFacets: Boolean(heroesFacets),
                heroExists: Boolean(heroesFacets && heroesFacets[heroToken]),
                facetExists: Boolean(heroesFacets && heroesFacets[heroToken] && heroesFacets[heroToken].Facets[facetId])
            }));
            
            if (heroesFacets && heroesFacets[heroToken] && heroesFacets[heroToken].Facets[facetId]) {
                const facet = heroesFacets[heroToken].Facets[facetId];
                $.Msg("找到命石数据:", JSON.stringify(facet, (key, value) => {
                    if (value === undefined) return 'undefined';
                    return value;
                }));
                
                const facetToken = "#DOTA_Tooltip_Facet_" + facet.name;
                const abilityToken = "#DOTA_Tooltip_Ability_" + facet.AbilityName;
                $.Msg("本地化令牌 - facetToken:", facetToken, "abilityToken:", abilityToken);
                
                const facetLocalized = $.Localize(facetToken);
                $.Msg("本地化结果 - raw:", facetToken, "localized:", facetLocalized);
                
                if (facetLocalized !== facetToken) {
                    userSelections.facetName = facetLocalized;
                    $.Msg("使用命石专用本地化:", facetLocalized);
                } else {
                    userSelections.facetName = $.Localize(abilityToken);
                    $.Msg("回退到技能本地化:", abilityToken, "结果:", userSelections.facetName);
                }
            } else {
                $.Msg("未找到命石数据 - heroesFacets:", Boolean(heroesFacets), 
                    "heroToken存在:", Boolean(heroesFacets && heroesFacets[heroToken]), 
                    "facetId存在:", Boolean(heroesFacets && heroesFacets[heroToken] && heroesFacets[heroToken].Facets[facetId]));
                userSelections.facetName = "默认命石";
            }
            
            // 从GameSetup中获取之前保存的功能ID
            const functionId = GameEvents.GameSetup.sandboxFunctionId;
            
            // 如果有功能ID，发送功能执行请求
            if (functionId) {
                GameEvents.SendCustomGameEventToServer("sandbox_custom_event", {
                    functionId: functionId,
                    heroId: heroId,
                    facetId: facetId,
                    teamId: userSelections.teamId,
                    positionX: userSelections.position.x,
                    positionY: userSelections.position.y,
                    positionZ: userSelections.position.z
                });
                
                $.Msg("执行沙盒功能: " + functionId + "，英雄ID: " + heroId);
                
                // 清除功能ID
                GameEvents.GameSetup.sandboxFunctionId = null;
            }
            
            // 最小化英雄选择面板
            const fcHeroPickPanel = $('#FcHeroPickPanel');
            if (fcHeroPickPanel) {
                fcHeroPickPanel.AddClass('minimized');
            }
            
            // 更新沙盒功能面板以反映新选择
            updateSandboxFunctions();
            
            // 确保沙盒面板可见
            if (!isSandboxModePanelVisible) {
                toggleSandboxModePanel();
            }
        }
        GameEvents.GameSetup.currentAction = null; // 新增这行
    } catch (e) {
        $.Msg("英雄选择处理时出错:", e);
    } finally {
        // 设置一个延迟，在一段时间后才允许处理下一个事件
        $.Schedule(0.5, function() {
            processingHeroSelection = false;
        });
    }
}

// 辅助函数：根据ID获取DOTA英雄的内部名称
function getDotaHeroNameByID(id) {
    // 常见DOTA2英雄ID到内部名称的映射
    const heroIDMap = {
        1: "antimage",
        2: "axe",
        3: "bane",
        4: "bloodseeker",
        5: "crystal_maiden",
        // ... 更多英雄
        22: "pudge",  // 根据你的日志，ID是22
        // ... 更多英雄
    };
    
    return heroIDMap[id] || "default";
}

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
    
    // 创建固定的选择面板（除了英雄选择，因为已有专门的英雄选择面板）
    createSelectionPanel(sandboxModePanel);
    
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

// 创建固定的选择面板
function createSelectionPanel(parent) {
    // 创建选择容器
    const selectionContainer = $.CreatePanel('Panel', parent, 'SelectionContainer');
    selectionContainer.AddClass('CategoryContainer');
    
    // 创建分类标题
    const selectionTitle = $.CreatePanel('Label', selectionContainer, '');
    selectionTitle.AddClass('CategoryTitle');
    selectionTitle.text = '基本设置';
    
    // 显示当前选择的英雄（如果有）
    createHeroSelectionSection(selectionContainer);
    
    // 创建队伍选择行
    const teamRow = $.CreatePanel('Panel', selectionContainer, '');
    teamRow.AddClass('ModesRow');
    
    // 队伍选择标签
    const teamLabel = $.CreatePanel('Label', teamRow, '');
    teamLabel.text = '选择队伍：';
    teamLabel.AddClass('SelectionLabel');
    
    // 创建队伍选择按钮
    const teamSelectButton = $.CreatePanel('Button', teamRow, 'TeamSelectButton');
    teamSelectButton.AddClass('GameModeOption');
    const teamButtonLabel = $.CreatePanel('Label', teamSelectButton, 'TeamSelectLabel');
    teamButtonLabel.AddClass('TeamSelectLabel');
    teamButtonLabel.text = getTeamName(userSelections.teamId);
    
    // 设置队伍选择按钮事件
    teamSelectButton.SetPanelEvent('onactivate', function() {
        showCustomTeamSelector(teamSelectButton);
    });
    
    // 创建坐标输入行
    const positionRow = $.CreatePanel('Panel', selectionContainer, '');
    positionRow.AddClass('ModesRow');
    
    // 坐标标签
    const posLabel = $.CreatePanel('Label', positionRow, '');
    posLabel.text = '坐标 (X,Y,Z)：';
    posLabel.AddClass('SelectionLabel');
    
    // X坐标输入
    const xInput = $.CreatePanel('TextEntry', positionRow, 'XInput');
    xInput.text = userSelections.position.x.toString();
    xInput.AddClass('CoordinateInput');
    
    // Y坐标输入
    const yInput = $.CreatePanel('TextEntry', positionRow, 'YInput');
    yInput.text = userSelections.position.y.toString();
    yInput.AddClass('CoordinateInput');
    
    // Z坐标输入
    const zInput = $.CreatePanel('TextEntry', positionRow, 'ZInput');
    zInput.text = userSelections.position.z.toString();
    zInput.AddClass('CoordinateInput');
    
    // 设置坐标输入事件
    xInput.SetPanelEvent('ontextentrychange', function() {
        userSelections.position.x = parseInt(xInput.text) || 0;
    });
    
    yInput.SetPanelEvent('ontextentrychange', function() {
        userSelections.position.y = parseInt(yInput.text) || 0;
    });
    
    zInput.SetPanelEvent('ontextentrychange', function() {
        userSelections.position.z = parseInt(zInput.text) || 0;
    });
}

// 创建英雄选择部分
function createHeroSelectionSection(parent) {
    $.Msg("创建英雄选择部分，当前选择的英雄ID:", userSelections.heroId);
    
    // 英雄选择行
    const heroRow = $.CreatePanel('Panel', parent, '');
    heroRow.AddClass('ModesRow');
    
    const heroSelectLabel = $.CreatePanel('Label', heroRow, '');
    heroSelectLabel.text = '选择英雄：';
    heroSelectLabel.AddClass('SelectionLabel');
    
    const heroSelectButton = $.CreatePanel('Button', heroRow, 'HeroSelectButton');
    heroSelectButton.AddClass('GameModeOption');
    
    const heroButtonLabel = $.CreatePanel('Label', heroSelectButton, '');
    heroButtonLabel.text = userSelections.heroId ? '更改英雄' : '选择英雄';
    
    // 设置选择英雄按钮事件
    heroSelectButton.SetPanelEvent('onactivate', function() {
        openHeroSelectionPanel('SandboxHeroSelect');
    });
    
    // 如果已经选择了英雄，显示英雄信息面板
    if (userSelections.heroId) {
        $.Msg("显示已选择的英雄信息：", 
              "heroId:", userSelections.heroId, 
              "heroName:", userSelections.heroName, 
              "facetName:", userSelections.facetName);
        
        // 创建英雄详情行
        const heroDetailsRow = $.CreatePanel('Panel', parent, '');
        heroDetailsRow.AddClass('HeroDetailsRow');
        
        // 创建英雄图标
        const heroIconPanel = $.CreatePanel('DOTAHeroImage', heroDetailsRow, 'HeroIcon');
        heroIconPanel.AddClass('HeroIcon');
        heroIconPanel.heroname = "npc_dota_hero_" + userSelections.heroIcon.split('/').pop().split('.')[0];
        heroIconPanel.heroimagestyle = "landscape";
        heroIconPanel.scaling = "scale-to-fit-x preserving-aspect";
        
        // 创建英雄信息面板
        const heroInfoPanel = $.CreatePanel('Panel', heroDetailsRow, 'HeroInfo');
        heroInfoPanel.AddClass('HeroInfoPanel');
        
        // 英雄名称
        const heroNameLabel = $.CreatePanel('Label', heroInfoPanel, 'HeroName');
        heroNameLabel.AddClass('HeroName');
        heroNameLabel.text = userSelections.heroName || '未知英雄';
        
        // 命石名称
        const facetLabel = $.CreatePanel('Label', heroInfoPanel, 'FacetName');
        facetLabel.AddClass('FacetName');
        
        if (userSelections.facetId && userSelections.facetId !== 0) {
            facetLabel.text = `命石: ${userSelections.facetName}`;
        } else {
            facetLabel.text = '命石: 默认';
        }
    } else {
        $.Msg("未选择英雄，不显示英雄信息面板");
    }
}

// 执行沙盒功能
function executeSandboxFunction(functionId) {
    $.Msg("执行功能ID: " + functionId);
    
    // 查找对应的功能定义
    const func = sandboxFunctions.find(f => f.id === functionId);
    
    $.Msg("找到的功能: ", func);
    
    if (func) {
        // 检查是否需要额外选择
        if (func.requiresSelection && func.selectionType === "hero" && !userSelections.heroId) {
            $.Msg("该功能需要选择英雄!");
            
            // 打开英雄选择面板
            openHeroSelectionPanel('SandboxHeroSelect');
        } else {
            // 获取当前选中的单位（如果是需要操作选中英雄的功能）
            let selectedEntityId = -1;
            if (["delete_hero", "level_up_hero", "get_all_skills", "reset_cooldowns", "get_items", "infinite_mana", "add_ai", "max_level"].includes(functionId)) {
                selectedEntityId = Players.GetLocalPlayerPortraitUnit();
                $.Msg("获取当前选中单位ID: " + selectedEntityId);
            }
            
            // 准备发送给服务器的数据（新增队伍和坐标）
            const data = { 
                functionId: functionId,
                heroId: userSelections.heroId,
                facetId: userSelections.facetId,
                teamId: userSelections.teamId,    // 新增队伍ID
                positionX: userSelections.position.x,  // 拆分坐标
                positionY: userSelections.position.y,
                positionZ: userSelections.position.z,
                selectedEntityId: selectedEntityId   // 新增选中的实体ID
            };
            
            // 发送请求到服务器
            GameEvents.SendCustomGameEventToServer("sandbox_custom_event", data);
            $.Msg("执行沙盒功能: " + functionId + "，使用用户选择的数据，选中单位ID: " + selectedEntityId);
        }
    }
}

// 打开英雄选择面板
function openHeroSelectionPanel(action) {
    // 不再关闭沙盒面板
    // if (isSandboxModePanelVisible) {
    //     toggleSandboxModePanel();
    // }
    
    // 初始化GameSetup对象（如果不存在）
    if (!GameEvents.GameSetup) {
        GameEvents.GameSetup = {};
    }
    
    // 记录当前行为
    GameEvents.GameSetup.currentAction = action;
    
    $.Msg("准备打开英雄选择面板，当前操作:", action);
    
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
}

// 新增自定义队伍选择器
function showCustomTeamSelector(anchorPanel) {
    // 先移除已存在的选择器
    const existingSelector = $('#CustomTeamSelector');
    if (existingSelector) {
        existingSelector.DeleteAsync(0);
    }

    // 创建容器面板（直接添加到根节点）
    const teamSelector = $.CreatePanel('Panel', $.GetContextPanel(), 'CustomTeamSelector');
    teamSelector.AddClass('CustomTeamSelector');
    teamSelector.hittest = true;
    teamSelector.hittestchildren = true;
    
    // 设置位置（基于按钮的绝对位置）
    const buttonX = anchorPanel.GetPositionWithinWindow().x;
    const buttonY = anchorPanel.GetPositionWithinWindow().y;
    const offsetY = anchorPanel.actuallayoutheight + 5;
    teamSelector.style.position = `${buttonX}px ${buttonY + offsetY}px 0`;
    
    // 添加背景
    const background = $.CreatePanel('Panel', teamSelector, '');
    background.AddClass('TeamSelectorBackground');
    
    // 添加关闭面板的事件处理
    teamSelector.RegisterForReadyEvents(true);
    teamSelector.SetPanelEvent('onactivate', function() {
        teamSelector.DeleteAsync(0);
    });

    // 队伍配置
    const teams = [
        { id: 2, name: "天辉", color: "#4B693D" },
        { id: 3, name: "夜魇", color: "#693D3D" },
        { id: 4, name: "自定义1", color: "#3D5069" },
        { id: 5, name: "自定义2", color: "#693D67" },
        { id: 6, name: "自定义3", color: "#695A3D" },
        { id: 7, name: "自定义4", color: "#3D6969" },
        { id: 1, name: "中立生物", color: "#666666" }
    ];

    // 创建队伍按钮
    teams.forEach(team => {
        const btn = $.CreatePanel('Button', background, '');
        btn.AddClass('TeamOptionButton');
        btn.style.backgroundColor = team.color + "44";
        btn.style.border = `1px solid ${team.color}`;
        
        const label = $.CreatePanel('Label', btn, '');
        label.text = team.name;
        label.AddClass('TeamOptionLabel');
        
        btn.SetPanelEvent('onactivate', function() {
            userSelections.teamId = team.id;
            // 通过更可靠的选择器获取标签
            const label = anchorPanel.FindChildTraverse('TeamSelectLabel');
            if (label) {
                label.text = team.name;
            }
            teamSelector.DeleteAsync(0);
        });
    });
}

function getTeamName(teamId) {
    const teamMap = {
        1: "中立生物",
        2: "天辉",
        3: "夜魇",
        4: "自定义1",
        5: "自定义2", 
        6: "自定义3",
        7: "自定义4"
    };
    return teamMap[teamId] || "未知队伍";
}