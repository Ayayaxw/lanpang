(function() {
    let trackedHeroes = new Map(); // {entityId: panelId}
    let isAvoiding = false;

    const PANEL_CONFIG = {
        ICON_WIDTH: 20,
        BORDER_WIDTH: 2,
        CONTAINER_PADDING: 4,
        MINIMUM_GAP: 5,
        VERTICAL_OFFSET: 20,
        PANEL_HEIGHT: 10,
        VERTICAL_GAP: 10
    };

    const TEAM_COLORS = {
        2: '#1BC05B',     // 天辉(GOOD)绿色
        3: '#F33030',     // 夜魇(BAD)红色
        6: '#3D8DFF',     // CUSTOM_1蓝色
        7: '#BF47FF',     // CUSTOM_2紫色
        8: '#FF9200',     // CUSTOM_3橙色
        9: '#41FFFF'      // CUSTOM_4青色
    };
    

    function UpdateAbilityState(container, abilityData) {
        const cooldownPanel = container.FindChildrenWithClassTraverse('AbilityCooldown')[0];
        const cooldownText = container.FindChildrenWithClassTraverse('AbilityCooldownText')[0];
        const chargeCounter = container.FindChildrenWithClassTraverse('AbilityChargeCounter')[0];
        const noManaPanel = container.FindChildrenWithClassTraverse('AbilityNoMana')[0];
        const abilityIcon = container.FindChildrenWithClassTraverse('AbilityIcon')[0];
    
        if (abilityData.isPassive) {
            cooldownPanel.style.visibility = 'collapse';
            noManaPanel.style.visibility = 'collapse';
            chargeCounter.style.visibility = 'collapse';
            abilityIcon.RemoveClass('Disabled');
        } else {
            // 处理充能显示
            if (abilityData.maxCharges > 0) {
                // 始终显示充能计数器
                chargeCounter.style.visibility = 'visible';
                chargeCounter.text = abilityData.charges.toString();
                cooldownPanel.style.visibility = 'collapse';
    
                // 如果充能为0，显示灰色效果
                if (abilityData.charges === 0) {
                    abilityIcon.AddClass('Disabled');
                    cooldownPanel.style.visibility = 'visible'; // 显示灰色蒙版
                    cooldownText.style.visibility = 'collapse'; // 但不显示CD文字
                } else {
                    abilityIcon.RemoveClass('Disabled');
                }
            } else {
                // 非充能技能的处理
                chargeCounter.style.visibility = 'collapse';
                if (abilityData.cooldown > 0) {
                    cooldownPanel.style.visibility = 'visible';
                    cooldownText.text = abilityData.cooldown.toFixed(1);
                    cooldownText.style.visibility = 'visible';
                    abilityIcon.AddClass('Disabled');
                } else {
                    cooldownPanel.style.visibility = 'collapse';
                    abilityIcon.RemoveClass('Disabled');
                }
            }
    
            // 魔法不足显示
            if (!abilityData.hasEnoughMana && abilityData.manaCost > 0) {
                noManaPanel.style.visibility = 'visible';
                abilityIcon.AddClass('Disabled');
            } else {
                noManaPanel.style.visibility = 'collapse';
                // 只有在没有其他禁用条件时才移除Disabled类
                if (!(abilityData.cooldown > 0 || (abilityData.maxCharges > 0 && abilityData.charges === 0))) {
                    abilityIcon.RemoveClass('Disabled');
                }
            }
        }
    }
    function calculatePanelWidth(panel) {
        if (!panel) return 0;
        const childCount = panel.Children().length;
        return PANEL_CONFIG.CONTAINER_PADDING + 
               childCount * (PANEL_CONFIG.ICON_WIDTH + PANEL_CONFIG.BORDER_WIDTH);
    }

    function getNormalPosition(entityId, panel) {
        if (!entityId || !panel) return null;

        const context = $.GetContextPanel();
        const scaleX = context.actualuiscale_x;
        const scaleY = context.actualuiscale_y;

        const heroPos = Entities.GetAbsOrigin(entityId);
        if (!heroPos) return null;

        const screenX = Game.WorldToScreenX(heroPos[0], heroPos[1], heroPos[2]) * (1/scaleX);
        const screenY = Game.WorldToScreenY(heroPos[0], heroPos[1], heroPos[2]) * (1/scaleY);

        const panelWidth = calculatePanelWidth(panel);
        
        return {
            x: screenX - (panelWidth / 2),
            y: screenY + PANEL_CONFIG.VERTICAL_OFFSET,
            width: panelWidth
        };
    }

    function checkOverlap(pos1, pos2) {
        if (!pos1 || !pos2) return false;
        
        // X轴方向的重叠检测
        const left = pos1.x < pos2.x ? pos1 : pos2;
        const right = pos1.x < pos2.x ? pos2 : pos1;
        const xOverlap = (right.x - (left.x + left.width)) < PANEL_CONFIG.MINIMUM_GAP;
        
        // Y轴方向的重叠检测
        const yDistance = Math.abs(pos1.y - pos2.y);
        const yOverlap = yDistance < (PANEL_CONFIG.PANEL_HEIGHT + PANEL_CONFIG.VERTICAL_GAP);
        
        return xOverlap && yOverlap;
    }

    function resolveOverlap(positions) {
        const n = positions.length;
        if (n < 2) return positions;
    
        // 按X坐标排序
        positions.sort((a, b) => a.x - b.x);
    
        // 创建一个映射来记录需要移动的面板索引
        let needsAdjustment = new Set();
    
        // 检查重叠
        for (let i = 0; i < n - 1; i++) {
            for (let j = i + 1; j < n; j++) {
                if (checkOverlap(positions[i], positions[j])) {
                    // 将发生重叠的面板及其之间的所有面板加入集合
                    for (let k = i; k <= j; k++) {
                        needsAdjustment.add(k);
                    }
                }
            }
        }
    
        // 如果有需要调整的面板
        if (needsAdjustment.size > 0) {
            // 将需要调整的面板索引转换为数组并排序
            const adjustIndices = Array.from(needsAdjustment).sort((a, b) => a - b);
            
            // 找出需要调整的连续面板组
            let groups = [];
            let currentGroup = [adjustIndices[0]];
            
            for (let i = 1; i < adjustIndices.length; i++) {
                if (adjustIndices[i] === adjustIndices[i-1] + 1) {
                    currentGroup.push(adjustIndices[i]);
                } else {
                    groups.push(currentGroup);
                    currentGroup = [adjustIndices[i]];
                }
            }
            groups.push(currentGroup);
    
            // 对每组重叠的面板进行调整
            groups.forEach(group => {
                const startIdx = group[0];
                const endIdx = group[group.length - 1];
                
                // 计算这组面板的总重叠量
                let totalOverlap = 0;
                for (let i = startIdx; i < endIdx; i++) {
                    const overlap = PANEL_CONFIG.MINIMUM_GAP - 
                        (positions[i + 1].x - (positions[i].x + positions[i].width));
                    if (overlap > 0) totalOverlap += overlap;
                }
    
                if (totalOverlap > 0) {
                    const offsetPerPanel = totalOverlap / (group.length);
                    
                    // 只调整这组中的面板
                    for (let i = 0; i < group.length; i++) {
                        const idx = group[i];
                        // 前半部分向左移动
                        if (i < group.length / 2) {
                            positions[idx].x -= offsetPerPanel * (group.length / 2 - i);
                        }
                        // 后半部分向右移动
                        else {
                            positions[idx].x += offsetPerPanel * (i - group.length / 2 + 1);
                        }
                    }
                }
            });
        }
    
        return positions;
    }

    function UpdatePanelPositions() {
        const mainContainer = $('#AbilitiesContainer');
        let allPositions = [];

        // 收集所有面板的位置信息
        trackedHeroes.forEach((panelId, entityId) => {
            const panel = mainContainer.FindChild(panelId);
            if (panel) {
                const pos = getNormalPosition(entityId, panel);
                if (pos) {
                    allPositions.push({
                        panel: panel,
                        ...pos
                    });
                }
            }
        });

        // 解决重叠问题
        const adjustedPositions = resolveOverlap(allPositions);

        // 应用新位置
        adjustedPositions.forEach(pos => {
            pos.panel.style.position = `${pos.x}px ${pos.y}px 0px`;
        });

        $.Schedule(1/144, UpdatePanelPositions);
    }

    function CreateAbilityIcon(abilityData, container, entityId, index, teamId) {
        const abilityId = `hero${entityId}_ability${index}`;
        
        const abilityContainer = $.CreatePanel('Panel', container, abilityId);
        abilityContainer.AddClass('AbilityIconContainer');
        
        // 使用队伍颜色
        const teamColor = TEAM_COLORS[teamId];
        if (teamColor) {
            abilityContainer.style.borderColor = teamColor;
        } else {
            // 如果没有对应的队伍颜色，使用默认颜色
            abilityContainer.style.borderColor = '#FFFFFF';
        }
        
        
        if (abilityData.isPassive) {
            abilityContainer.AddClass('PassiveAbility');
        }
    
        const abilityIcon = $.CreatePanel('DOTAAbilityImage', abilityContainer, '');
        abilityIcon.AddClass('AbilityIcon');
        abilityIcon.abilityname = abilityData.id;
    
        const cooldownPanel = $.CreatePanel('Panel', abilityContainer, '');
        cooldownPanel.AddClass('AbilityCooldown');
        
        const cooldownText = $.CreatePanel('Label', cooldownPanel, '');
        cooldownText.AddClass('AbilityCooldownText');
    
        // 新增：充能计数器
        const chargeCounter = $.CreatePanel('Label', abilityContainer, '');
        chargeCounter.AddClass('AbilityChargeCounter');
    
        const noManaPanel = $.CreatePanel('Panel', abilityContainer, '');
        noManaPanel.AddClass('AbilityNoMana');
    
        UpdateAbilityState(abilityContainer, abilityData);
    }

    function UpdateHeroAbilities(data) {
        const mainContainer = $('#AbilitiesContainer');
        const entityId = data.entityId;
        const abilities = data.abilities;
        const teamId = data.teamId; // 修改：使用teamId替代heroType
        
        let panelId = `HeroAbilities_${entityId}`;
        let heroPanel = mainContainer.FindChild(panelId);
        
        if (!heroPanel) {
            heroPanel = $.CreatePanel('Panel', mainContainer, panelId);
            heroPanel.AddClass('HeroAbilitiesPanel');
        }
        trackedHeroes.set(entityId, panelId);

        let needsReinit = false;
        let abilitiesArray = Object.values(abilities);

        if (heroPanel.GetChildCount() !== abilitiesArray.length) {
            needsReinit = true;
        } else {
            for (let i = 0; i < abilitiesArray.length; i++) {
                const abilityId = `hero${entityId}_ability${i}`;
                const abilityPanel = heroPanel.FindChild(abilityId);
                if (!abilityPanel) {
                    needsReinit = true;
                    break;
                }
                
                const abilityIcon = abilityPanel.FindChildrenWithClassTraverse('AbilityIcon')[0];
                if (abilityIcon.abilityname !== abilitiesArray[i].id) {
                    needsReinit = true;
                    break;
                }
            }
        }

        if (needsReinit) {
            heroPanel.RemoveAndDeleteChildren();
            abilitiesArray.forEach((abilityData, index) => {
                CreateAbilityIcon(abilityData, heroPanel, entityId, index, teamId);
            });
        } else {
            abilitiesArray.forEach((abilityData, index) => {
                const abilityId = `hero${entityId}_ability${index}`;
                const abilityPanel = heroPanel.FindChild(abilityId);
                if (abilityPanel) {
                    UpdateAbilityState(abilityPanel, abilityData);
                }
            });
        }
    }

    function OnUpdateAbilitiesStatus(data) {
        UpdateHeroAbilities(data);
        $('#AbilitiesContainer').RemoveClass('AbilitiesContainerhidden');
    }


    function ClearAllPanels() {
        const mainContainer = $('#AbilitiesContainer');
        if (!mainContainer) {
            $.Msg("错误: 清理面板时无法找到技能容器");
            return;
        }
    
        // 立即隐藏容器
        mainContainer.AddClass('AbilitiesContainerhidden');
    
        // 获取所有子面板，不仅仅依赖trackedHeroes
        const children = mainContainer.Children();
        const childCount = children.length;
        
        $.Msg(`开始清理面板，当前子面板数量: ${childCount}`);
        $.Msg(`当前已追踪的英雄数量: ${trackedHeroes.size}`);
    
        // 清理所有子面板
        for (let i = 0; i < childCount; i++) {
            const panel = children[i];
            if (panel) {
                panel.RemoveAndDeleteChildren();
                panel.DeleteAsync(0.0);
                $.Msg(`删除面板 ${i + 1}/${childCount}`);
            }
        }
    
        // 强制清空容器
        mainContainer.RemoveAndDeleteChildren();
        
        // 清空追踪Map
        trackedHeroes.clear();
    
        // 确保容器保持隐藏
        $.Schedule(0.1, () => {
            if (mainContainer) {
                mainContainer.RemoveAndDeleteChildren();
                mainContainer.AddClass('AbilitiesContainerhidden');
                $.Msg("延迟检查：确保容器被隐藏");
            }
        });
    
        $.Msg("所有技能面板清理完成");
    }

    function RemoveHeroPanel(entityId) {
        $.Msg("[RemoveHeroPanel] Starting removal for entity:", entityId);
    
        const mainContainer = $('#AbilitiesContainer');
        if (!mainContainer) {
            $.Msg("[RemoveHeroPanel] Error: Cannot find AbilitiesContainer");
            return;
        }
    
        const panelId = trackedHeroes.get(entityId);
        $.Msg("[RemoveHeroPanel] Panel ID for entity", entityId, "is:", panelId);
    
        if (panelId) {
            const heroPanel = mainContainer.FindChild(panelId);
            if (heroPanel) {
                $.Msg("[RemoveHeroPanel] Found hero panel, removing children...");
                heroPanel.RemoveAndDeleteChildren();
                
                $.Msg("[RemoveHeroPanel] Deleting panel...");
                heroPanel.DeleteAsync(0.0);
            } else {
                $.Msg("[RemoveHeroPanel] Error: Could not find hero panel with ID:", panelId);
            }
    
            $.Msg("[RemoveHeroPanel] Removing from tracked heroes...");
            trackedHeroes.delete(entityId);
            
            $.Msg("[RemoveHeroPanel] Current tracked heroes count:", trackedHeroes.size);
        } else {
            $.Msg("[RemoveHeroPanel] No panel ID found for entity:", entityId);
        }
    
        if (trackedHeroes.size === 0) {
            $.Msg("[RemoveHeroPanel] No more tracked heroes, hiding container");
            mainContainer.AddClass('AbilitiesContainerhidden');
        }
    }
    
    function ForceRemoveHeroPanel(entityId) {
        $.Msg("[强制移除英雄面板] 开始强制移除实体:", entityId);
    
        const mainContainer = $('#AbilitiesContainer');
        if (!mainContainer) {
            $.Msg("[强制移除英雄面板] 错误: 无法找到技能容器");
            return;
        }
    
        const panelId = `HeroAbilities_${entityId}`;
        $.Msg("[强制移除英雄面板] 查找面板:", panelId);
    
        const heroPanel = mainContainer.FindChild(panelId);
        if (heroPanel) {
            $.Msg("[强制移除英雄面板] 已找到面板，正在移除...");
            heroPanel.RemoveAndDeleteChildren();
            heroPanel.DeleteAsync(0.0);
        } else {
            $.Msg("[强制移除英雄面板] 未找到面板");
        }
        
        $.Msg("[强制移除英雄面板] 从追踪列表中移除");
        trackedHeroes.delete(entityId);
        
        $.Msg("[强制移除英雄面板] 当前追踪的英雄数量:", trackedHeroes.size);
        
        if (trackedHeroes.size === 0) {
            $.Msg("[强制移除英雄面板] 没有更多追踪的英雄，隐藏容器");
            mainContainer.AddClass('AbilitiesContainerhidden');
        }
    }
    
    // 事件监听器也添加日志
    GameEvents.Subscribe("remove_hero_abilities_panel", function(event) {
        $.Msg("[事件] 收到移除英雄技能面板事件");
        $.Msg("[事件] 事件数据:", event);
    
        if (event && event.entityId) {
            $.Msg("[事件] 调用移除英雄面板函数");
            RemoveHeroPanel(event.entityId);
            
            $.Msg("[事件] 调用强制移除英雄面板函数");
            ForceRemoveHeroPanel(event.entityId);
        } else {
            $.Msg("[事件] 错误: 无效的事件数据");
        }
    });

    // 在初始化部分添加事件订阅
    GameEvents.Subscribe("clear_abilities_panels", function(event) {
        ClearAllPanels();
    });

    GameEvents.Subscribe("update_abilities_status", OnUpdateAbilitiesStatus);
    UpdatePanelPositions();
})();