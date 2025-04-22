// 自动相机控制系统
(function() {
    // 相机状态和配置
    var cameraSystem = {
        // 单位数据
        units: [],                  // 所有单位
        teams: {},                  // 按队伍分组 {[teamId]: {units: [], count: 0, center: {x,y,z}}}
        
        // 配置参数
        outlierThreshold: 2.0,      // 离群单位阈值
        minCameraHeight: 1400,      // 最小相机高度
        maxCameraHeight: 1800,      // 最大相机高度
        marginSpace: 300,           // 画面边缘留白
        smallTeamBonus: 1.8,        // 小队伍权重加成
        heroWeightMultiplier: 2.5,  // 英雄单位权重
        
        // 平滑过渡系统
        currentPosition: {x: 0, y: 0, z: 0},   // 当前位置
        targetPosition: {x: 0, y: 0, z: 0},    // 目标位置
        currentHeight: 1400,                    // 当前高度
        targetHeight: 1400,                     // 目标高度
        smoothFactor: 0.05,                     // 平滑因子（值越小越平滑）
        isFirstUpdate: true,                    // 是否首次更新
        
        // 相机高度锁定系统
        heightLockDuration: 10,                 // 相机高度锁定时间（秒）
        lastMaxHeight: 1400,                    // 上次最高高度
        heightLockTime: 0,                      // 高度锁定时间点
        isHeightLocked: false,                  // 高度是否锁定
        
        // 相机方向锁定系统
        directionLockDuration: 1.0,             // 方向锁定时间（秒）
        lastMoveDirection: {x: 0, y: 0},        // 上次移动方向
        directionLockTime: 0,                   // 方向锁定时间点
        isDirectionLocked: false,               // 方向是否锁定
        significantMoveThreshold: 5,            // 有意义移动的最小距离阈值
        directionChangeThreshold: 90,           // 方向变化阈值（度数）
        
        // 速度限制系统
        maxPositionChangePerFrame: 1,          // 每帧位置最大变化量(单位距离)
        maxHeightChangePerFrame: 1,            // 每帧高度最大变化量(单位高度)
        
        // 防抖动系统
        positionBuffer: [],         // 位置缓冲区
        heightBuffer: [],           // 高度缓冲区
        bufferSize: 10,             // 缓冲区大小(增大以减少抖动)
        
        // 更新相关
        updateInterval: 1/100,       // 更新频率(每秒60次)
        
        // 系统状态
        isActive: false,            // 系统是否激活
        isInitialized: false        // 系统是否已初始化
    };
    
    // 初始化
    function Initialize() {
        // 防止重复初始化
        if (cameraSystem.isInitialized) {
            $.Msg("相机系统已经初始化，跳过重复初始化");
            return;
        }
        
        // 注册事件监听
        $.Msg("初始化相机控制系统");
        $.Msg("正在注册事件监听器...");
        GameEvents.Subscribe("camera_units_update", OnUnitsUpdated);
        GameEvents.Subscribe("camera_unit_removed", OnUnitRemoved);
        GameEvents.Subscribe("camera_initialize", OnCameraInitialize);
        GameEvents.Subscribe("camera_stop", OnCameraStop);
        $.Msg("事件监听器注册完成");
        
        cameraSystem.isInitialized = true;
        $.Msg("相机控制系统初始化完成");
    }
    
    // 处理相机初始化消息
    function OnCameraInitialize(data) {
        $.Msg("收到相机初始化消息");
        $.Msg("开始清空单位数据和重置相机状态...");
        
        // 清空单位数据
        cameraSystem.units = [];
        cameraSystem.teams = {};
        
        // 重置相机状态
        cameraSystem.isFirstUpdate = true;
        cameraSystem.isActive = true;
        
        // 重置相机高度锁定状态
        cameraSystem.isHeightLocked = false;
        cameraSystem.heightLockTime = 0;
        cameraSystem.lastMaxHeight = cameraSystem.minCameraHeight;
        
        // 重置相机方向锁定状态
        cameraSystem.isDirectionLocked = false;
        cameraSystem.directionLockTime = 0;
        cameraSystem.lastMoveDirection = {x: 0, y: 0};
        
        // 清空缓冲区
        cameraSystem.positionBuffer = [];
        cameraSystem.heightBuffer = [];
        $.Msg("缓冲区已清空");
        
        // 开始更新循环
        $.Msg("开始相机更新循环");
        $.Schedule(cameraSystem.updateInterval, UpdateCamera);
        
        $.Msg("相机控制系统已激活");
    }
    
    // 处理相机停止消息
    function OnCameraStop(data) {
        $.Msg("收到相机停止消息");
        $.Msg("正在停止相机控制系统...");
        cameraSystem.isActive = false;
        $.Msg("相机控制系统已停止");
    }
    
    // 从服务器接收单位更新
    function OnUnitsUpdated(data) {
        $.Msg("收到单位更新数据");
        $.Msg("收到的原始数据: " + JSON.stringify(data));
        
        if (!data) {
            $.Msg("收到的数据为空");
            return;
        }
        
        // 处理对象形式的units数据
        var unitsArray = [];
        if (data.units) {
            // 将对象转换为数组
            for (var key in data.units) {
                if (data.units.hasOwnProperty(key)) {
                    unitsArray.push(data.units[key]);
                }
            }
        }
        
        if (unitsArray.length === 0) {
            $.Msg("单位数据无效或为空，数量: " + (data.count || 0));
            return;
        }
        
        $.Msg("开始处理" + unitsArray.length + "个单位的数据");
        
        // 更新单位数据
        for (var i = 0; i < unitsArray.length; i++) {
            var unitInfo = unitsArray[i];
            
            // 检查单位是否已存在
            var exists = false;
            for (var j = 0; j < cameraSystem.units.length; j++) {
                if (cameraSystem.units[j].entityIndex === unitInfo.entityIndex) {
                    // 更新现有单位的team和isHero信息
                    cameraSystem.units[j].team = unitInfo.team;
                    cameraSystem.units[j].isHero = unitInfo.isHero;
                    exists = true;
                    $.Msg("更新已存在的单位: " + unitInfo.entityIndex);
                    break;
                }
            }
            
            // 添加新单位
            if (!exists) {
                cameraSystem.units.push({
                    entityIndex: unitInfo.entityIndex,
                    team: unitInfo.team,
                    isHero: unitInfo.isHero,
                    position: {x: 0, y: 0, z: 0} // 会在UpdateUnitPositions中更新
                });
                $.Msg("添加新单位: " + unitInfo.entityIndex);
            }
        }
        
        $.Msg("单位数据处理完成，当前单位数量: " + cameraSystem.units.length);
        
        // 更新单位位置
        $.Msg("开始更新单位位置...");
        UpdateUnitPositions();
        
        // 重建队伍数据
        $.Msg("开始更新队伍数据...");
        UpdateTeams();
    }
    
    // 处理单位移除消息
    function OnUnitRemoved(data) {
        if (!data || !data.entityIndex) {
            $.Msg("收到无效的单位移除消息");
            return;
        }
        
        $.Msg("准备移除单位: " + data.entityIndex);
        
        // 从单位列表中移除
        var removed = false;
        for (var i = cameraSystem.units.length - 1; i >= 0; i--) {
            if (cameraSystem.units[i].entityIndex === data.entityIndex) {
                cameraSystem.units.splice(i, 1);
                removed = true;
                $.Msg("成功移除单位: " + data.entityIndex);
            }
        }
        
        if (!removed) {
            $.Msg("未找到要移除的单位: " + data.entityIndex);
        }
        
        // 重建队伍数据
        $.Msg("单位移除后，开始更新队伍数据");
        UpdateTeams();
    }
    
    // 更新所有单位的位置
    function UpdateUnitPositions() {
        $.Msg("开始更新所有单位位置，单位数量: " + cameraSystem.units.length);
        var updatedCount = 0;
        
        for (var i = 0; i < cameraSystem.units.length; i++) {
            var unit = cameraSystem.units[i];
            
            // 使用Entities.GetAbsOrigin获取单位位置
            if (Entities.IsValidEntity(unit.entityIndex)) {
                var pos = Entities.GetAbsOrigin(unit.entityIndex);
                if (pos) {
                    $.Msg("单位 " + unit.entityIndex + " 位置获取成功: " + pos[0] + "," + pos[1] + "," + pos[2]);
                    unit.position = {
                        x: pos[0],
                        y: pos[1],
                        z: pos[2]
                    };
                    updatedCount++;
                } else {
                    $.Msg("无法获取单位 " + unit.entityIndex + " 的位置");
                }
            } else {
                $.Msg("单位 " + unit.entityIndex + " 不是有效实体");
            }
        }
        
        $.Msg("单位位置更新完成，成功更新: " + updatedCount + "/" + cameraSystem.units.length);
    }
    
    // 更新队伍分组
    function UpdateTeams() {
        $.Msg("开始更新队伍分组");
        cameraSystem.teams = {};
        
        for (var i = 0; i < cameraSystem.units.length; i++) {
            var unit = cameraSystem.units[i];
            var teamId = unit.team;
            
            // 初始化队伍
            if (!cameraSystem.teams[teamId]) {
                cameraSystem.teams[teamId] = {
                    units: [],
                    count: 0,
                    center: {x: 0, y: 0, z: 0}
                };
                $.Msg("创建新队伍: " + teamId);
            }
            
            // 添加单位到队伍
            cameraSystem.teams[teamId].units.push(unit);
            cameraSystem.teams[teamId].count++;
        }
        
        var teamCount = Object.keys(cameraSystem.teams).length;
        $.Msg("队伍分组完成，共有 " + teamCount + " 个队伍");
        
        // 计算每个队伍的中心点
        $.Msg("开始计算队伍中心点");
        UpdateTeamCenters();
    }
    
    // 更新队伍中心点
    function UpdateTeamCenters() {
        $.Msg("开始更新各队伍中心点");
        
        for (var teamId in cameraSystem.teams) {
            var team = cameraSystem.teams[teamId];
            var center = {x: 0, y: 0, z: 0};
            var count = 0;
            
            $.Msg("计算队伍 " + teamId + " 的中心点，单位数量: " + team.units.length);
            
            for (var i = 0; i < team.units.length; i++) {
                var unit = team.units[i];
                center.x += unit.position.x;
                center.y += unit.position.y;
                center.z += unit.position.z;
                count++;
            }
            
            if (count > 0) {
                center.x /= count;
                center.y /= count;
                center.z /= count;
                team.center = center;
                team.count = count;
                $.Msg("队伍 " + teamId + " 中心点更新为: " + center.x.toFixed(1) + "," + center.y.toFixed(1) + "," + center.z.toFixed(1));
            } else {
                $.Msg("队伍 " + teamId + " 没有单位，无法计算中心点");
            }
        }
        
        $.Msg("所有队伍中心点更新完成");
    }
    
    // 剔除离群单位
    function RemoveOutliers() {
        $.Msg("开始剔除离群单位");
        
        // 对每个队伍处理
        for (var teamId in cameraSystem.teams) {
            var team = cameraSystem.teams[teamId];
            var distances = [];
            var sum = 0;
            
            $.Msg("处理队伍 " + teamId + "，单位数量: " + team.units.length);
            
            // 计算每个单位到中心的距离
            for (var i = 0; i < team.units.length; i++) {
                var unit = team.units[i];
                var distance = CalculateDistance2D(unit.position, team.center);
                distances.push({unit: unit, distance: distance});
                sum += distance;
            }
            
            // 计算平均距离
            var avgDistance = distances.length > 0 ? sum / distances.length : 0;
            var threshold = avgDistance * cameraSystem.outlierThreshold;
            $.Msg("队伍 " + teamId + " 平均距离: " + avgDistance.toFixed(1) + "，阈值: " + threshold.toFixed(1));
            
            // 筛选非离群单位
            var newUnits = [];
            var outlierCount = 0;
            for (var i = 0; i < distances.length; i++) {
                if (distances[i].distance <= threshold) {
                    newUnits.push(distances[i].unit);
                } else {
                    outlierCount++;
                }
            }
            
            $.Msg("队伍 " + teamId + " 剔除了 " + outlierCount + " 个离群单位");
            team.units = newUnits;
            team.count = newUnits.length;
        }
        
        // 更新队伍中心点
        $.Msg("离群单位剔除完成，重新计算队伍中心点");
        UpdateTeamCenters();
    }
    
    // 计算全局中心点(考虑队伍权重)
    function CalculateGlobalCenter() {
        $.Msg("开始计算全局加权中心点");
        var weightedCenter = {x: 0, y: 0, z: 0};
        var totalWeight = 0;
        var totalUnits = 0;
        
        // 计算单位总数
        for (var teamId in cameraSystem.teams) {
            totalUnits += cameraSystem.teams[teamId].count;
        }
        $.Msg("所有队伍单位总数: " + totalUnits);
        
        // 计算加权中心
        for (var teamId in cameraSystem.teams) {
            var team = cameraSystem.teams[teamId];
            if (team.count > 0) {
                // 小队伍获得更高权重
                var teamWeight = (totalUnits / team.count) * cameraSystem.smallTeamBonus;
                teamWeight = Math.min(teamWeight, 5.0); // 限制最大权重
                $.Msg("队伍 " + teamId + " 权重: " + teamWeight.toFixed(2));
                
                // 计算队伍中心，英雄单位获得更高权重
                var teamCenter = {x: 0, y: 0, z: 0};
                var teamUnitWeight = 0;
                
                for (var i = 0; i < team.units.length; i++) {
                    var unit = team.units[i];
                    var unitWeight = unit.isHero ? cameraSystem.heroWeightMultiplier : 1.0;
                    
                    teamCenter.x += unit.position.x * unitWeight;
                    teamCenter.y += unit.position.y * unitWeight;
                    teamCenter.z += unit.position.z * unitWeight;
                    teamUnitWeight += unitWeight;
                }
                
                if (teamUnitWeight > 0) {
                    teamCenter.x /= teamUnitWeight;
                    teamCenter.y /= teamUnitWeight;
                    teamCenter.z /= teamUnitWeight;
                }
                
                weightedCenter.x += teamCenter.x * teamWeight;
                weightedCenter.y += teamCenter.y * teamWeight;
                weightedCenter.z += teamCenter.z * teamWeight;
                totalWeight += teamWeight;
            }
        }
        
        // 计算预测性移动
        var predictionVector = {x: 0, y: 0, z: 0};
        
        // 最终中心点
        if (totalWeight > 0) {
            weightedCenter.x /= totalWeight;
            weightedCenter.y /= totalWeight;
            weightedCenter.z /= totalWeight;
            $.Msg("计算得到全局中心点: " + weightedCenter.x.toFixed(1) + "," + weightedCenter.y.toFixed(1) + "," + weightedCenter.z.toFixed(1));
        } else {
            $.Msg("无法计算全局中心点，没有有效单位");
        }
        
        return weightedCenter;
    }
    
    // 计算所需相机高度
    function CalculateCameraHeight(center) {
        $.Msg("开始计算相机高度");
        var maxDistance = 0;
        var heroes = 0;
        var creeps = 0;
        
        // 找出距离中心点最远的单位
        for (var i = 0; i < cameraSystem.units.length; i++) {
            var unit = cameraSystem.units[i];
            var distance = CalculateDistance2D(unit.position, center);
            
            if (distance > maxDistance) {
                maxDistance = distance;
                $.Msg("发现更远的单位，距离更新为: " + maxDistance.toFixed(1));
            }
            
            // 计算英雄和小兵数量
            if (unit.isHero) {
                heroes++;
            } else {
                creeps++;
            }
        }
        
        $.Msg("场景中英雄数量: " + heroes + "，小兵数量: " + creeps);
        $.Msg("最远单位距离: " + maxDistance.toFixed(1));
        
        // 计算所需高度
        var height = (maxDistance + cameraSystem.marginSpace) * 1.2;
        $.Msg("初步计算的高度: " + height.toFixed(1));
        
        // 自动判断战斗状态
        var combatModifier = 1.0;
        if (creeps > heroes * 3) {
            combatModifier = 1.2;
            $.Msg("检测到大规模战斗，高度修正系数: " + combatModifier);
        }
        
        height = height * combatModifier;
        
        // 限制在最小和最大高度之间
        var originalHeight = height;
        height = Math.max(height, cameraSystem.minCameraHeight);
        height = Math.min(height, cameraSystem.maxCameraHeight);
        
        if (height !== originalHeight) {
            $.Msg("高度已调整到限制范围内，从 " + originalHeight.toFixed(1) + " 调整为 " + height.toFixed(1));
        }
        
        $.Msg("最终计算的相机高度: " + height.toFixed(1));
        return height;
    }
    
    // 辅助函数：限制值的变化速度
    function LimitChangeSpeed(current, target, maxChange) {
        if (Math.abs(target - current) <= maxChange) {
            return target;
        } else if (target > current) {
            return current + maxChange;
        } else {
            return current - maxChange;
        }
    }
    
    // 辅助函数：计算向量角度（度数）
    function CalculateAngleBetweenVectors(vec1, vec2) {
        // 规范化向量
        var len1 = Math.sqrt(vec1.x * vec1.x + vec1.y * vec1.y);
        var len2 = Math.sqrt(vec2.x * vec2.x + vec2.y * vec2.y);
        
        // 避免除以零
        if (len1 < 0.001 || len2 < 0.001) {
            return 0;
        }
        
        var norm1 = {x: vec1.x / len1, y: vec1.y / len1};
        var norm2 = {x: vec2.x / len2, y: vec2.y / len2};
        
        // 计算点积
        var dotProduct = norm1.x * norm2.x + norm1.y * norm2.y;
        
        // 限制点积在[-1, 1]范围内，避免浮点误差
        dotProduct = Math.max(-1, Math.min(1, dotProduct));
        
        // 计算角度（弧度）并转换为度数
        var angleInRadians = Math.acos(dotProduct);
        var angleInDegrees = angleInRadians * 180 / Math.PI;
        
        return angleInDegrees;
    }
    
    // 辅助函数：限制向量变化速度，保持方向一致，同时考虑方向锁定
    function LimitVectorChangeSpeedWithDirectionLock(current, target, maxSpeed, currentTime) {
        // 计算向量差
        var dx = target.x - current.x;
        var dy = target.y - current.y;
        
        // 计算距离
        var distance = Math.sqrt(dx * dx + dy * dy);
        
        // 如果距离太小，不进行方向判断
        if (distance < cameraSystem.significantMoveThreshold) {
            if (distance <= maxSpeed) {
                return {
                    x: target.x,
                    y: target.y
                };
            } else {
                // 按当前方向移动最大速度
                var dirX = dx / distance;
                var dirY = dy / distance;
                return {
                    x: current.x + dirX * maxSpeed,
                    y: current.y + dirY * maxSpeed
                };
            }
        }
        
        // 计算当前移动方向
        var currentDirection = {
            x: dx / distance,
            y: dy / distance
        };
        
        // 检查是否有方向锁定
        if (cameraSystem.isDirectionLocked) {
            var timeSinceLock = currentTime - cameraSystem.directionLockTime;
            
            // 如果锁定时间已过，解除锁定
            if (timeSinceLock >= cameraSystem.directionLockDuration) {
                $.Msg("方向锁定时间结束，经过了 " + timeSinceLock.toFixed(2) + " 秒");
                cameraSystem.isDirectionLocked = false;
            } else {
                // 计算新方向与锁定方向的角度差
                var angle = CalculateAngleBetweenVectors(currentDirection, cameraSystem.lastMoveDirection);
                
                // 如果角度差大于阈值，且在锁定期内，则维持原方向
                if (angle > cameraSystem.directionChangeThreshold) {
                    $.Msg("在方向锁定期内 (剩余: " + (cameraSystem.directionLockDuration - timeSinceLock).toFixed(2) + 
                          " 秒)，阻止方向变化: " + angle.toFixed(1) + "°");
                    
                    // 沿着锁定方向移动
                    return {
                        x: current.x + cameraSystem.lastMoveDirection.x * maxSpeed,
                        y: current.y + cameraSystem.lastMoveDirection.y * maxSpeed
                    };
                }
            }
        }
        
        // 检查是否是一个显著的方向变化
        if (cameraSystem.lastMoveDirection.x !== 0 || cameraSystem.lastMoveDirection.y !== 0) {
            var angle = CalculateAngleBetweenVectors(currentDirection, cameraSystem.lastMoveDirection);
            
            // 如果角度变化大于阈值，记录时间并锁定方向
            if (angle > cameraSystem.directionChangeThreshold) {
                $.Msg("检测到显著方向变化: " + angle.toFixed(1) + "°，锁定当前方向 " + cameraSystem.directionLockDuration + " 秒");
                cameraSystem.isDirectionLocked = true;
                cameraSystem.directionLockTime = currentTime;
                cameraSystem.lastMoveDirection = currentDirection;
            } else {
                // 更新最后移动方向
                cameraSystem.lastMoveDirection = currentDirection;
            }
        } else {
            // 第一次移动，记录方向
            cameraSystem.lastMoveDirection = currentDirection;
        }
        
        // 限制移动速度
        if (distance <= maxSpeed) {
            return {
                x: target.x,
                y: target.y
            };
        } else {
            return {
                x: current.x + currentDirection.x * maxSpeed,
                y: current.y + currentDirection.y * maxSpeed
            };
        }
    }
    
    // 更新相机位置和高度
    function UpdateCamera() {
        // 如果系统未激活或无单位，跳过更新但继续循环
        if (!cameraSystem.isActive) {
            $.Msg("相机系统未激活，停止更新循环");
            return; // 不再继续调度，直接退出循环
        }
        
        if (cameraSystem.units.length === 0) {
            $.Msg("没有单位数据，跳过本次更新");
            $.Schedule(cameraSystem.updateInterval, UpdateCamera);
            return;
        }
        
        // 获取当前时间
        var currentTime = Game.Time();
        
        // 更新所有单位的位置
        $.Msg("--- 开始相机更新 ---");
        UpdateUnitPositions();
        
        // 更新队伍中心点
        UpdateTeamCenters();
        
        // 剔除离群单位
        RemoveOutliers();
        
        // 计算理想的目标位置和高度
        $.Msg("计算新的目标位置和高度");
        var newIdealCenter = CalculateGlobalCenter();
        var newIdealHeight = CalculateCameraHeight(newIdealCenter);
        
        // 检查高度锁定状态
        // 检查当前高度是否高于上次记录的最高高度
        if (newIdealHeight > cameraSystem.lastMaxHeight) {
            $.Msg("相机高度增加: " + cameraSystem.lastMaxHeight.toFixed(1) + " -> " + newIdealHeight.toFixed(1));
            cameraSystem.lastMaxHeight = newIdealHeight;
            cameraSystem.heightLockTime = currentTime;
            cameraSystem.isHeightLocked = true;
            $.Msg("相机高度锁定开启，时间: " + currentTime.toFixed(1) + "，锁定 " + cameraSystem.heightLockDuration + " 秒");
        }
        
        // 检查是否在锁定期内
        if (cameraSystem.isHeightLocked) {
            var timeSinceLock = currentTime - cameraSystem.heightLockTime;
            if (timeSinceLock >= cameraSystem.heightLockDuration) {
                // 锁定时间已过
                $.Msg("相机高度锁定时间结束，经过了 " + timeSinceLock.toFixed(1) + " 秒");
                cameraSystem.isHeightLocked = false;
            } else {
                // 仍在锁定期内，不允许高度降低
                if (newIdealHeight < cameraSystem.lastMaxHeight) {
                    $.Msg("在锁定期内 (剩余: " + (cameraSystem.heightLockDuration - timeSinceLock).toFixed(1) + " 秒)，阻止相机降低: " + 
                          newIdealHeight.toFixed(1) + " -> " + cameraSystem.lastMaxHeight.toFixed(1));
                    newIdealHeight = cameraSystem.lastMaxHeight;
                }
            }
        }
        
        // 应用缓冲平均
        $.Msg("更新缓冲区数据");
        cameraSystem.positionBuffer.push(newIdealCenter);
        cameraSystem.heightBuffer.push(newIdealHeight);
        
        // 保持缓冲区大小
        if (cameraSystem.positionBuffer.length > cameraSystem.bufferSize) {
            cameraSystem.positionBuffer.shift();
        }
        if (cameraSystem.heightBuffer.length > cameraSystem.bufferSize) {
            cameraSystem.heightBuffer.shift();
        }
        
        // 计算缓冲区平均值，使用加权平均让新数据权重较低
        var idealCenter = {x: 0, y: 0, z: 0};
        var idealHeight = 0;
        var totalWeight = 0;
        
        for (var i = 0; i < cameraSystem.positionBuffer.length; i++) {
            // 较旧的数据有更高权重，较新的数据权重较低
            var weight = 1 + i * 0.5;  // 权重递增
            idealCenter.x += cameraSystem.positionBuffer[i].x * weight;
            idealCenter.y += cameraSystem.positionBuffer[i].y * weight;
            idealCenter.z += cameraSystem.positionBuffer[i].z * weight;
            totalWeight += weight;
        }
        
        var heightTotalWeight = 0;
        for (var i = 0; i < cameraSystem.heightBuffer.length; i++) {
            var weight = 1 + i * 0.5;  // 权重递增
            idealHeight += cameraSystem.heightBuffer[i] * weight;
            heightTotalWeight += weight;
        }
        
        idealCenter.x /= totalWeight;
        idealCenter.y /= totalWeight;
        idealCenter.z /= totalWeight;
        idealHeight /= heightTotalWeight;
        
        $.Msg("加权缓冲后的目标中心点: " + idealCenter.x.toFixed(1) + "," + idealCenter.y.toFixed(1) + "," + idealCenter.z.toFixed(1));
        $.Msg("加权缓冲后的目标高度: " + idealHeight.toFixed(1));
        
        // 更新目标位置和高度
        cameraSystem.targetPosition = idealCenter;
        cameraSystem.targetHeight = idealHeight;
        
        // 如果是第一次更新，直接设置当前位置为目标位置
        if (cameraSystem.isFirstUpdate) {
            $.Msg("首次更新，直接设置相机位置到目标位置");
            cameraSystem.currentPosition = {
                x: idealCenter.x,
                y: idealCenter.y,
                z: idealCenter.z
            };
            cameraSystem.currentHeight = idealHeight;
            cameraSystem.isFirstUpdate = false;
        } else {
            // 平滑过渡到目标位置和高度
            $.Msg("平滑过渡到目标位置和高度");
            
            // 先使用平滑因子计算目标变化量
            var desiredPositionX = cameraSystem.currentPosition.x + (cameraSystem.targetPosition.x - cameraSystem.currentPosition.x) * cameraSystem.smoothFactor;
            var desiredPositionY = cameraSystem.currentPosition.y + (cameraSystem.targetPosition.y - cameraSystem.currentPosition.y) * cameraSystem.smoothFactor;
            var desiredPositionZ = cameraSystem.currentPosition.z + (cameraSystem.targetPosition.z - cameraSystem.currentPosition.z) * cameraSystem.smoothFactor;
            var desiredHeight = cameraSystem.currentHeight + (cameraSystem.targetHeight - cameraSystem.currentHeight) * cameraSystem.smoothFactor;
            
            // 保存当前想要的位置
            var desiredPosition = {
                x: desiredPositionX, 
                y: desiredPositionY
            };
            
            // 使用带方向锁定的向量限速函数
            var newPosition = LimitVectorChangeSpeedWithDirectionLock(
                {x: cameraSystem.currentPosition.x, y: cameraSystem.currentPosition.y},
                desiredPosition,
                cameraSystem.maxPositionChangePerFrame,
                currentTime
            );
            
            // 应用新位置
            cameraSystem.currentPosition.x = newPosition.x;
            cameraSystem.currentPosition.y = newPosition.y;
            
            // Z轴和高度仍然单独处理
            cameraSystem.currentPosition.z = LimitChangeSpeed(cameraSystem.currentPosition.z, desiredPositionZ, cameraSystem.maxPositionChangePerFrame);
            cameraSystem.currentHeight = LimitChangeSpeed(cameraSystem.currentHeight, desiredHeight, cameraSystem.maxHeightChangePerFrame);
            
            // 记录实际变化量，用于调试
            var actualDistance = CalculateDistance2D(
                {x: cameraSystem.currentPosition.x, y: cameraSystem.currentPosition.y},
                desiredPosition
            );
            
            if (actualDistance >= cameraSystem.maxPositionChangePerFrame * 0.9 || 
                Math.abs(cameraSystem.currentHeight - desiredHeight) >= cameraSystem.maxHeightChangePerFrame * 0.9) {
                $.Msg("速度限制已生效 - 位置变化距离: " + actualDistance.toFixed(1) + 
                      " 高度变化: " + Math.abs(cameraSystem.currentHeight - desiredHeight).toFixed(1));
            }
        }
        
        // 应用相机位置和高度
        $.Msg("应用相机位置: " + cameraSystem.currentPosition.x.toFixed(1) + "," + cameraSystem.currentPosition.y.toFixed(1) + "," + cameraSystem.currentPosition.z.toFixed(1));
        $.Msg("应用相机高度: " + cameraSystem.currentHeight.toFixed(1));
        
        GameUI.SetCameraTargetPosition([
            cameraSystem.currentPosition.x,
            cameraSystem.currentPosition.y,
            cameraSystem.currentPosition.z
        ], cameraSystem.updateInterval); // 设置为0以立即移动，我们已经自己处理了平滑过渡
        
        GameUI.SetCameraDistance(cameraSystem.currentHeight);
        
        // 继续下一帧
        $.Schedule(cameraSystem.updateInterval, UpdateCamera);
        $.Msg("--- 相机更新完成 ---");
    }
    
    // 辅助函数：计算2D距离
    function CalculateDistance2D(pos1, pos2) {
        var dx = pos1.x - pos2.x;
        var dy = pos1.y - pos2.y;
        var result = Math.sqrt(dx * dx + dy * dy);
        // $.Msg("计算2D距离: " + result.toFixed(1)); // 这一行可能会产生大量日志，取消注释时请谨慎
        return result;
    }
    
    // 立即初始化
    $.Msg("开始初始化自动相机控制系统");
    Initialize();
    $.Msg("自动相机控制系统加载完成");
})();
