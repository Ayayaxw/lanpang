(function() {
    // 常量定义
    const HIDE_TIMEOUT = 5000; // 面板自动隐藏的时间（毫秒）
    
    // 全局变量
    let currentDisplayValue = 0;      // 当前实际显示的数值
    let targetDamage = 0;             // 当前动画目标值
    let animationHandle = null;       // 动画定时器句柄
    let currentDamage = 0;
    let lastDamage = 0;
    let hideTimeout = null;
    let panelRoot = null;
    let abilityDamagePanel = null;
    
    // 日志函数
    function logMessage(message) {
        $.Msg("[技能伤害面板] " + message);
    }
    
    // 模拟的技能数据，用于测试
    const testHeroes = [
        { ability: "storm_spirit_ball_lightning", attribute: "Agility" },
        { ability: "lina_dragon_slave", attribute: "Intelligence" },
        { ability: "axe_culling_blade", attribute: "Strength" },
        { ability: "invoker_deafening_blast", attribute: "All" }
    ];
    
    /**
     * 初始化函数
     */
    function initialize() {
        logMessage("=== 技能伤害面板初始化开始 ===");
        
        try {
            // 首先检查我们的上下文
            panelRoot = $.GetContextPanel();
            logMessage("当前上下文面板ID: " + panelRoot.id);
            logMessage("当前上下文面板类型: " + panelRoot.paneltype);
            
            // 打印面板层次结构，帮助调试
            logMessage("打印顶层面板结构:");
            logPanelHierarchy(panelRoot, 0);
            
            // 尝试直接通过遍历查找DamagePanelRoot
            const damagePanelRoot = findPanelWithClass(panelRoot, "DamagePanelRoot");
            if (damagePanelRoot) {
                logMessage("成功找到DamagePanelRoot面板!");
                
                // 直接查找AbilityDamagePanel
                abilityDamagePanel = damagePanelRoot.FindChildTraverse("AbilityDamagePanel");
                if (abilityDamagePanel) {
                    logMessage("通过DamagePanelRoot找到AbilityDamagePanel面板!");
                } else {
                    logMessage("错误: 无法在DamagePanelRoot下找到AbilityDamagePanel面板");
                }
            } else {
                logMessage("错误: 无法找到DamagePanelRoot面板");
            }
            
            // 如果上面的方法找不到，尝试全局搜索作为备选
            if (!abilityDamagePanel) {
                abilityDamagePanel = $("#AbilityDamagePanel"); // 经典的jQuery风格选择器
                if (abilityDamagePanel && abilityDamagePanel.IsValid()) {
                    abilityDamagePanel.RemoveClass("Visible");
                    logMessage("通过jQuery选择器找到AbilityDamagePanel面板");
                } else {
                    // 最后尝试从根节点遍历查找
                    abilityDamagePanel = findPanelWithID(panelRoot, "AbilityDamagePanel");
                    if (abilityDamagePanel) {
                        logMessage("通过递归查找找到AbilityDamagePanel面板");
                    } else {
                        logMessage("严重错误: 无法找到AbilityDamagePanel面板，初始化失败");
                        return;
                    }
                }
            }
            
            // 确保面板初始可见，便于调试
            abilityDamagePanel.RemoveClass("Visible");
            // $.Schedule(0.5, function() {
            //     abilityDamagePanel.AddClass("Visible");
            //     logMessage("已强制设置面板为可见（测试用）");
            // });
            
            // 检查其他关键元素

            const abilityIcon = findChild(abilityDamagePanel, "AbilityDamageAbilityIcon");
            const abilityName = findChild(abilityDamagePanel, "AbilityDamageAbilityName");
            const damageValue = findChild(abilityDamagePanel, "AbilityDamageValue");
            const glowEffect = findChild(abilityDamagePanel, "AbilityDamageGlow");
            
            logMessage("UI元素检查:");
            logMessage("- AbilityIcon: " + (abilityIcon ? "已找到" : "未找到"));
            logMessage("- AbilityName: " + (abilityName ? "已找到" : "未找到"));
            logMessage("- DamageValue: " + (damageValue ? "已找到" : "未找到"));
            logMessage("- GlowEffect: " + (glowEffect ? "已找到" : "未找到"));
            
            // 如果无法找到关键元素，停止初始化
            if (!abilityIcon || !abilityName || !damageValue) {
                logMessage("严重错误: 缺少关键UI元素，无法继续初始化");
                return;
            }
            
            // 订阅GameEvents消息
            GameEvents.Subscribe("damage_panel_update_initial", OnUpdateInitial);
            GameEvents.Subscribe("damage_panel_update_ability", OnUpdateAbility);
            GameEvents.Subscribe("damage_panel_update_damage", OnUpdateDamage);
            
            logMessage("已订阅所有事件");
            
            // // 添加测试按钮（仅用于测试）
            // if (abilityDamagePanel) {
            //     abilityDamagePanel.SetPanelEvent("onactivate", RunTest);
            //     logMessage("已设置面板点击测试事件");
            // }
            
            logMessage("初始化完成");
            
            // 立即运行测试
            //RunTest();
        } catch (e) {
            logMessage("初始化过程中发生错误: " + e.toString());
        }
    }
    
    /**
     * 辅助函数：通过类名查找面板
     */
    function findPanelWithClass(parent, className) {
        if (!parent) return null;
        
        // 检查当前面板
        if (parent.BHasClass && parent.BHasClass(className)) {
            return parent;
        }
        
        // 递归检查子面板
        let children = parent.Children();
        if (children) {
            for (let i = 0; i < children.length; i++) {
                let result = findPanelWithClass(children[i], className);
                if (result) return result;
            }
        }
        
        return null;
    }
    
    /**
     * 辅助函数：通过ID查找面板
     */
    function findPanelWithID(parent, id) {
        if (!parent) return null;
        
        // 检查当前面板
        if (parent.id === id) {
            return parent;
        }
        
        // 递归检查子面板
        let children = parent.Children();
        if (children) {
            for (let i = 0; i < children.length; i++) {
                let result = findPanelWithID(children[i], id);
                if (result) return result;
            }
        }
        
        return null;
    }
    
    /**
     * 辅助函数：查找子面板
     */
    function findChild(parent, id) {
        if (!parent) return null;
        
        // 先尝试直接查找
        let child = parent.FindChildTraverse(id);
        if (child) return child;
        
        // 如果直接查找失败，尝试递归查找
        return findPanelWithID(parent, id);
    }
    
    /**
     * 打印面板层次结构，用于调试
     */
    function logPanelHierarchy(panel, depth, maxDepth = 3) {
        if (!panel || depth > maxDepth) return;
        
        let indent = "";
        for (let i = 0; i < depth; i++) {
            indent += "  ";
        }
        
        let panelInfo = indent + "- " + (panel.id || "(无ID)");
        if (panel.paneltype) {
            panelInfo += " [" + panel.paneltype + "]";
        }
        
        let classes = "";
        if (panel.GetClasses) {
            let classList = panel.GetClasses();
            if (classList && classList.length > 0) {
                classes = " class='" + classList.join(" ") + "'";
            }
        }
        panelInfo += classes;
        
        logMessage(panelInfo);
        
        // 遍历子面板
        let children = panel.Children();
        if (children) {
            for (let i = 0; i < children.length && i < 10; i++) { // 限制每层最多显示10个子元素
                logPanelHierarchy(children[i], depth + 1, maxDepth);
            }
            
            if (children.length > 10) {
                logMessage(indent + "  ... 还有 " + (children.length - 10) + " 个元素");
            }
        }
    }
    
    /**
     * 显示技能伤害面板
     */
    function showDamagePanel() {
        logMessage("显示技能伤害面板");
        
        // 检查面板是否有效
        if (!abilityDamagePanel || !abilityDamagePanel.IsValid()) {
            logMessage("错误: 无法显示技能伤害面板，面板对象无效");
            return;
        }
        
        abilityDamagePanel.AddClass("Visible");
        logMessage("已添加Visible类");
        
        // 检查面板的可见性
        if (abilityDamagePanel.BHasClass("Visible")) {
            logMessage("面板已设置为可见");
        } else {
            logMessage("警告: 设置可见类失败");
        }
        
        // 重置隐藏计时器
        resetHideTimer();
    }
    
    /**
     * 隐藏技能伤害面板
     */
    function hideDamagePanel() {
        logMessage("隐藏技能伤害面板");
        
        // 检查面板是否有效
        if (!abilityDamagePanel || !abilityDamagePanel.IsValid()) {
            logMessage("错误: 无法隐藏技能伤害面板，面板对象无效");
            return;
        }
        
        abilityDamagePanel.RemoveClass("Visible");
        
        // 检查面板的可见性
        if (!abilityDamagePanel.BHasClass("Visible")) {
            logMessage("面板已设置为隐藏");
        } else {
            logMessage("警告: 移除可见类失败");
        }
        
        // 清除隐藏计时器
        if (hideTimeout) {
            $.CancelScheduled(hideTimeout);
            hideTimeout = null;
            logMessage("已取消隐藏计时器");
        }
    }
    
    /**
     * 重置隐藏计时器
     */
    function resetHideTimer() {
        logMessage("重置隐藏计时器");
        
        // 清除现有的计时器
        if (hideTimeout) {
            $.CancelScheduled(hideTimeout);
            logMessage("已取消旧的隐藏计时器");
        }
        
        // 设置新的计时器
        hideTimeout = $.Schedule(HIDE_TIMEOUT / 1000, function() {
            logMessage("计时器触发 - 即将隐藏面板");
            hideDamagePanel();
        });
        
        logMessage("已设置新的隐藏计时器: " + (HIDE_TIMEOUT / 1000) + "秒");
    }
    
    /**
     * 更新英雄信息
     * @param {Object} data - 包含英雄信息的数据对象
     */
    function OnUpdateInitial(data) {
        logMessage("收到英雄更新事件");
        
        if (!data) {
            logMessage("错误: 更新英雄数据为空");
            return;
        }
        
        logMessage("更新英雄属性: " + data.attribute);
        OnUpdateAbility(data);
        
        // 检查面板是否有效
        if (!abilityDamagePanel || !abilityDamagePanel.IsValid()) {
            logMessage("错误: 无法更新英雄信息，面板对象无效");
            return;
        }
        
        const glowEffect = $("#AbilityDamageGlow");
        if (!glowEffect || !glowEffect.IsValid()) {
            logMessage("错误: 无法找到光效面板");
        }
        
        // 隐藏面板并执行动画
        abilityDamagePanel.RemoveClass("Visible");
        logMessage("面板暂时隐藏以执行动画");
        
        // 延时更新面板内容
        $.Schedule(0.4, function() {
            logMessage("开始更新英雄面板内容");
            // 更新属性类型
            if (abilityDamagePanel.IsValid() && glowEffect && glowEffect.IsValid()) {
                // 使用SetHasClass代替AddClass/RemoveClass组合
                abilityDamagePanel.SetHasClass("Strength", data.attribute === "Strength");
                abilityDamagePanel.SetHasClass("Agility", data.attribute === "Agility");
                abilityDamagePanel.SetHasClass("Intelligence", data.attribute === "Intelligence");
                abilityDamagePanel.SetHasClass("All", data.attribute === "All");
            
                glowEffect.SetHasClass("Strength", data.attribute === "Strength");
                glowEffect.SetHasClass("Agility", data.attribute === "Agility");
                glowEffect.SetHasClass("Intelligence", data.attribute === "Intelligence");
                glowEffect.SetHasClass("All", data.attribute === "All");
            } else {
                logMessage("错误: 无法设置属性样式，面板或光效无效");
            }
            
            // 重置伤害值
            lastDamage = 0;
            currentDamage = data.initial_damage || 0;
            
            const damageValue = $("#AbilityDamageValue");
            if (damageValue && damageValue.IsValid()) {
                damageValue.text = currentDamage.toString();
                logMessage("已设置初始伤害值: " + currentDamage);
            } else {
                logMessage("错误: 无法找到伤害值标签");
            }
            
            // 显示面板
            showDamagePanel();
        });
    }
    
    /**
     * 更新技能信息
     * @param {Object} data - 包含技能信息的数据对象
     */
    function OnUpdateAbility(data) {
        logMessage("收到技能更新事件");
        
        if (!data) {
            logMessage("错误: 更新技能数据为空");
            return;
        }
        
        // 检查面板是否有效
        if (!abilityDamagePanel || !abilityDamagePanel.IsValid()) {
            logMessage("错误: 无法更新技能信息，面板对象无效");
            return;
        }
        
        logMessage("更新技能: " + data.ability_name + ", ID: " + data.ability_name);
        
        // 更新技能名称
        const abilityName = $("#AbilityDamageAbilityName");
        if (!abilityName || !abilityName.IsValid()) {
            logMessage("错误: 无法找到技能名称标签");
        } else {
            abilityName.text = $.Localize("#DOTA_Tooltip_Ability_" + data.ability_name);
            logMessage("已设置技能名称: " + data.ability_name);
        }
        
        // 更新技能图标 - 修复方法
        const abilityIcon = $("#AbilityDamageAbilityIcon");
        if (abilityIcon && abilityIcon.IsValid()) {
            // 如果已经是DOTAAbilityImage元素
            if (abilityIcon.paneltype === "DOTAAbilityImage") {
                abilityIcon.abilityname = data.ability_name;
                abilityIcon.AddClass("AbilityDamage_AbilityImageFull");
                logMessage("已更新技能图标: " + data.ability_name);
            } else {
                // 需要先清除现有内容
                abilityIcon.RemoveAndDeleteChildren();
                // 创建DOTAAbilityImage元素
                const abilityImage = $.CreatePanel('DOTAAbilityImage', abilityIcon, '');
                abilityImage.abilityname = data.ability_name;
                abilityImage.AddClass("AbilityDamage_AbilityImageFull");

                logMessage("已创建并设置技能图标: " + data.ability_name);
            }
        } else {
            logMessage("错误: 无法找到技能图标面板");
            return;
        }
        
        // 显示面板并重置计时器
        showDamagePanel();
    }
    
    /**
     * 更新伤害数值
     * @param {Object} data - 包含伤害信息的数据对象
     */

    function OnUpdateDamage(data) {
        logMessage("收到伤害更新事件");
        
        if (!data || !data.damage) {
            logMessage("错误: 更新伤害数据为空或无效");
            return;
        }
    

        // 保存目标值
        const newTarget = data.damage;
        
        // 立即更新当前目标
        targetDamage = newTarget;
        currentDamage = newTarget; // 保持currentDamage为最新值
        
        // 如果已有动画正在运行，取消之前的动画
        if (animationHandle) {
            $.CancelScheduled(animationHandle);
            animationHandle = null;
            logMessage("取消进行中的动画");
        }
    
        // 计算增量（基于当前显示值）
        const damageIncrease = $("#AbilityDamageIncrease");
        if (damageIncrease && damageIncrease.IsValid()) {
            const increase = targetDamage - currentDisplayValue;
            damageIncrease.text = "+" + increase;
            damageIncrease.AddClass("Show");
            
            // 自动隐藏增量提示
            $.Schedule(1.7, () => damageIncrease.RemoveClass("Show"));
        }
    
        // 开始新的动画
        startNumberAnimation();
        
        // 显示面板并重置计时器
        showDamagePanel();
    }

    
    function startNumberAnimation() {
        const damageValue = $("#AbilityDamageValue");
        if (!damageValue || !damageValue.IsValid()) return;

        const startTime = Game.GetGameTime();
        const initialValue = currentDisplayValue; // 动画起始值
        const duration = 0.6;

        // 清除旧动画类，添加新动画类
        damageValue.RemoveClass("Updating");
        damageValue.AddClass("Updating");

        function update() {
            const currentTime = Game.GetGameTime();
            const elapsed = currentTime - startTime;
            let progress = elapsed / duration;

            // 如果已经超过目标值或动画被取消
            if (progress >= 1 || !animationHandle) {
                currentDisplayValue = targetDamage;
                damageValue.text = targetDamage.toString();
                damageValue.RemoveClass("Updating");
                logMessage("动画最终值: " + targetDamage);
                animationHandle = null;
                return;
            }

            // 应用缓动函数
            progress = 1 - Math.pow(1 - progress, 3);
            currentDisplayValue = Math.floor(initialValue + (targetDamage - initialValue) * progress);
            damageValue.text = currentDisplayValue.toString();

            // 继续更新
            animationHandle = $.Schedule(0.01, update);
        }

        animationHandle = $.Schedule(0.01, update);
    }

    
    /**
     * 数值动画函数
     * @param {Object} element - 要动画的元素
     * @param {number} start - 起始值
     * @param {number} end - 结束值
     * @param {number} duration - 动画持续时间（秒）
     */
    function animateNumber(element, start, end, duration) {
        logMessage("开始数值动画: 从 " + start + " 到 " + end + " (持续: " + duration + "秒)");
        
        const startTime = Game.GetGameTime();
        const endTime = startTime + duration;
        const difference = end - start;
        
        function updateValue() {
            const currentTime = Game.GetGameTime();
            if (currentTime >= endTime) {
                element.text = end.toString();
                logMessage("数值动画完成: 最终值 = " + end);
                return;
            }
            
            const elapsed = currentTime - startTime;
            const progress = elapsed / duration;
            
            // 缓动函数
            const easeOut = function(t) {
                return 1 - Math.pow(1 - t, 3);
            };
            
            const currentValue = Math.floor(start + difference * easeOut(progress));
            element.text = currentValue.toString();
            
            $.Schedule(0.01, updateValue);
        }
        
        updateValue();
    }
    
    /**
     * 运行测试函数
     * 此函数模拟后端发送消息，用于测试面板功能
     */
    function RunTest() {
        logMessage("=== 开始运行测试序列 ===");
        
        // 模拟更新英雄
        logMessage("测试: 即将模拟英雄更新");
        simulateHeroUpdate();
        
        // 定时模拟更新伤害
        logMessage("测试: 计划2秒后模拟伤害更新");
        $.Schedule(2, function() {
            logMessage("测试: 执行第一次伤害更新");
            simulateDamageUpdate();
        });
        
        logMessage("测试: 计划5秒后模拟伤害更新");
        $.Schedule(5, function() {
            logMessage("测试: 执行第二次伤害更新");
            simulateDamageUpdate();
        });
        
        logMessage("测试: 计划8秒后模拟伤害更新");
        $.Schedule(8, function() {
            logMessage("测试: 执行第三次伤害更新");
            simulateDamageUpdate();
        });
        
        // 一段时间后模拟切换英雄
        logMessage("测试: 计划12秒后模拟英雄切换");
        $.Schedule(12, function() {
            logMessage("测试: 执行英雄切换");
            simulateHeroUpdate();
        });
        
        logMessage("测试: 计划14秒后模拟伤害更新");
        $.Schedule(14, function() {
            logMessage("测试: 执行第四次伤害更新");
            simulateDamageUpdate();
        });
        
        logMessage("测试: 计划17秒后模拟伤害更新");
        $.Schedule(17, function() {
            logMessage("测试: 执行第五次伤害更新");
            simulateDamageUpdate();
        });
        
        logMessage("=== 测试序列已安排 ===");
    }
    
    /**
     * 模拟英雄更新
     */
    function simulateHeroUpdate() {
        logMessage("模拟英雄更新开始");
        
        // 定义不同属性的测试数据
        const testHeroes = [
            { ability: "storm_spirit_ball_lightning", attribute: "Agility" },
            { ability: "lina_dragon_slave", attribute: "Intelligence" },
            { ability: "axe_culling_blade", attribute: "Strength" },
            { ability: "invoker_deafening_blast", attribute: "All" }
        ];
        
        // 随机选择一个英雄数据
        const randomHero = testHeroes[Math.floor(Math.random() * testHeroes.length)];
        
        // 创建模拟数据
        const data = {
            ability_name: randomHero.ability,
            attribute: randomHero.attribute,
            initial_damage: Math.floor(Math.random() * 1000) + 500
        };
        
        logMessage("模拟英雄属性: " + data.attribute);
        logMessage("模拟技能: " + data.ability_name + ", 初始伤害: " + data.initial_damage);
        
        // 调用更新函数
        OnUpdateInitial(data);
        
        // // 延迟更新技能
        // logMessage("计划0.5秒后更新技能信息");
        // $.Schedule(0.5, function() {
        //     OnUpdateAbility({
        //         ability_name: data.ability_name
        //     });
        // });
    }
    
    /**
     * 模拟伤害更新
     */
    function simulateDamageUpdate() {
        // 生成随机增加的伤害
        const increase = Math.floor(Math.random() * 9000) + 999;
        
        logMessage("模拟伤害更新: 当前伤害 " + currentDamage + ", 增加 " + increase);
        
        // 创建模拟数据
        const data = {
            damage: currentDamage + increase
        };
        
        // 调用更新函数
        OnUpdateDamage(data);
    }
    
    // 页面加载完成后初始化
    $.Schedule(0, function() {
        logMessage("=== 技能伤害面板(AbilityDamagePanel)脚本开始加载 ===");
        // 延迟初始化，确保DOM已加载
        $.Schedule(0.5, initialize);
    });
})(); 




/*

// 示例：初始化面板
GameEvents.Send("damage_panel_update_initial", {
    attribute: "Intelligence",
    initial_damage: 500
});

// 示例：更新技能
GameEvents.Send("damage_panel_update_ability", {
    ability_name: "lina_dragon_slave"
});

// 示例：更新伤害
GameEvents.Send("damage_panel_update_damage", {
    damage: 750  // 会自动计算与显示伤害增量
});


// 更换技能
GameEvents.Send("damage_panel_update_initial", {
    ability_name: "lina_dragon_slave",
    attribute: "Intelligence",
    initial_damage: 500
});








*/ 