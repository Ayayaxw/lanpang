var isCameraLocked = false; // 用于跟踪相机锁定状态
var cameraLockInterval; // 用于存储定时器的引用
var defaultDistance = 1400
var cinematicAnimationInterval; // 用于存储cinematicCameraMove的计时器引用

GameUI.SetCameraDistance(defaultDistance);

// var targetPosition = [
//     1400,
//     1000,
//     128.00,
// ];
// $.Schedule(3, function() {
//     GameUI.SetCameraTargetPosition(targetPosition, -1); // 将相机平滑移动到目标位置
// });

// GameUI.SetCameraTargetPosition(targetPosition, 40)
// GameUI.SetCameraLookAtPosition(targetPosition);




function cinematicCameraMove(heroPosition, cameraData) {
    // 如果存在之前的动画，立即停止
    if (cinematicAnimationInterval) {
        $.CancelScheduled(cinematicAnimationInterval);
        cinematicAnimationInterval = null;
        $.Msg("已停止之前的相机运镜");
    }

    // 处理heroPosition，可能是字符串格式的坐标
    if (typeof heroPosition === 'string') {
        var coordinates = heroPosition.split(' ');
        if (coordinates.length === 3) {
            heroPosition = coordinates.map(Number);
            if (heroPosition.some(isNaN)) {
                $.Msg("无效的坐标值:", heroPosition);
                return;
            }
        } else {
            $.Msg("坐标数量不正确:", heroPosition);
            return;
        }
    }

    var animationDuration = cameraData && cameraData.animationDuration !== undefined ? cameraData.animationDuration : 10; // 总动画时间为10秒
    var updateInterval = 0.01; // 每0.01秒更新一次

    var animationInterval;
    
    // 初始相机参数和目标参数
    var startPitch = cameraData && cameraData.startPitch !== undefined ? cameraData.startPitch : 40;
    var endPitch = cameraData && cameraData.endPitch !== undefined ? cameraData.endPitch : 20;
    var startYaw = cameraData && cameraData.startYaw !== undefined ? cameraData.startYaw : 10;
    var endYaw = cameraData && cameraData.endYaw !== undefined ? cameraData.endYaw : -10;
    var startDistance = cameraData && cameraData.startDistance !== undefined ? cameraData.startDistance : 800;
    var endDistance = cameraData && cameraData.endDistance !== undefined ? cameraData.endDistance : 800;
    // 添加高度偏移参数
    var startHeightOffset = cameraData && cameraData.startHeightOffset !== undefined ? cameraData.startHeightOffset : 0;
    var endHeightOffset = cameraData && cameraData.endHeightOffset !== undefined ? cameraData.endHeightOffset : 0;
    
    var totalSteps = Math.floor(animationDuration / updateInterval);
    var currentStep = 0;
    GameUI.SetCameraDistance(startDistance);
    // 设置初始高度偏移
    GameUI.SetCameraLookAtPositionHeightOffset(startHeightOffset);
    
    function startCameraAnimation() {
        // 取消可能存在的旧计时器
        if (animationInterval) {
            $.CancelScheduled(animationInterval);
        }
        
        $.Msg("开始运镜：从Pitch " + startPitch + "到" + endPitch + "，从Yaw " + startYaw + "到" + endYaw + "，从Distance " + startDistance + "到" + endDistance + "，从高度偏移 " + startHeightOffset + "到" + endHeightOffset);
        
        // 计算每步移动的距离
        var pitchStep = (endPitch - startPitch) / totalSteps;
        var yawStep = (endYaw - startYaw) / totalSteps;
        var distanceStep = (endDistance - startDistance) / totalSteps;
        var heightOffsetStep = (endHeightOffset - startHeightOffset) / totalSteps;
        
        // 如果提供了位置，立即将相机移动到该位置

        
        // 重置步数计数
        currentStep = 0;
        
        // 开始线性动画
        animateCameraLinear(pitchStep, yawStep, distanceStep, heightOffsetStep);
    }

    function animateCameraLinear(pitchStep, yawStep, distanceStep, heightOffsetStep) {
        // 计算当前值
        if (heroPosition) {
            var targetPosition = [
                heroPosition[0],
                heroPosition[1] + 200,
                heroPosition[2]
            ];

            GameUI.SetCameraTargetPosition(targetPosition, -1);
        }
        var currentPitch = startPitch + (pitchStep * currentStep);
        var currentYaw = startYaw + (yawStep * currentStep);
        var currentDistance = startDistance + (distanceStep * currentStep);
        var currentHeightOffset = startHeightOffset + (heightOffsetStep * currentStep);
        
        // 应用到相机
        GameUI.SetCameraPitchMin(currentPitch);
        GameUI.SetCameraPitchMax(currentPitch);
        GameUI.SetCameraYaw(currentYaw);
        GameUI.SetCameraDistance(currentDistance);
        GameUI.SetCameraLookAtPositionHeightOffset(currentHeightOffset);
        
        // 增加步数
        currentStep++;
        
        // 检查是否完成动画
        if (currentStep <= totalSteps) {
            // 安排下一帧
            animationInterval = $.Schedule(updateInterval, function() {
                animateCameraLinear(pitchStep, yawStep, distanceStep, heightOffsetStep);
            });
            // 将计时器引用保存到全局变量
            cinematicAnimationInterval = animationInterval;
        } else {
            // 动画完成，设置最终值确保精确
            GameUI.SetCameraPitchMin(endPitch);
            GameUI.SetCameraPitchMax(endPitch);
            GameUI.SetCameraYaw(endYaw);
            GameUI.SetCameraDistance(endDistance);
            GameUI.SetCameraLookAtPositionHeightOffset(endHeightOffset);
            $.Msg("相机运镜完成");
            // 清除全局计时器引用
            cinematicAnimationInterval = null;
        }
    }
    
    // 直接开始相机动画
    startCameraAnimation();
}

//cinematicCameraMove()
function toggleCameraLock() {
    if (!isCameraLocked) {
        // 锁定镜头到英雄
        cameraLockInterval = $.Schedule(0.01, function smoothPanCamera() {
            var heroEntityIndex = Players.GetPlayerHeroEntityIndex(0); // 获取玩家0的英雄实体索引
            var heroPosition = Entities.GetAbsOrigin(heroEntityIndex); // 获取英雄的绝对位置
            if (heroPosition) {
                GameUI.SetCameraTargetPosition(heroPosition, 0.3); // 将相机平滑移动到英雄位置
            }
            cameraLockInterval = $.Schedule(0.01, smoothPanCamera);
        });
        isCameraLocked = true;
    } else {
        // 解锁镜头
        $.CancelScheduled(cameraLockInterval);
        isCameraLocked = false;
    }
}


function immediateMoveThenLeft(targetPosition) {
    $.Msg("相机正在移动到胜利者的位置");

    function moveToTarget() {
        // 立即将相机移动到目标位置
        GameUI.SetCameraTargetPosition(targetPosition, 0.01);
        
        // 1秒后向左移动
        $.Schedule(2, moveLeft);

        
    }

    function moveLeft() {
        var leftPosition = [
            targetPosition[0] - 200,
            targetPosition[1],
            targetPosition[2]
        ];
        GameUI.SetCameraTargetPosition(leftPosition, 1); // 将相机平滑移动到左侧位置
        $.Msg("相机已经向左移动");
        // 在这里可以添加移动完成后的其他操作
    }

    moveToTarget(); // 开始移动相机
}

function zoomAndPanCamera(unitPosition) {
    $.Msg("相机正在移动到失败者的位置");
    var targetDistance = 800;
    var zoomDuration = 0.5; // 放大的时间
    var lockDuration = 4;
    var startTime;
    var cameraLockInterval;


    function moveCamera() {
        cameraLockInterval = $.Schedule(0, function smoothPanCamera() {
            if (unitPosition) {
                // 计算单位北方100码的位置
                var targetPosition = [
                    unitPosition[0],
                    unitPosition[1] + 100, // 在Y轴上加100单位，表示北方100码
                    unitPosition[2]
                ];
                GameUI.SetCameraTargetPosition(targetPosition, 0.5); // 将相机平滑移动到目标位置
            }
            cameraLockInterval = $.Schedule(0.01, smoothPanCamera);
        });

        $.Schedule(0, function() {
            // 停止相机移动
            if (cameraLockInterval) {
                $.CancelScheduled(cameraLockInterval);
            }
            startTime = Game.GetGameTime(); // 重置开始时间为放大阶段
            zoomCamera();
        });
    }

    function zoomCamera() {
        var currentTime = Game.GetGameTime();
        var elapsedTime = currentTime - startTime;
        var t = Math.min(elapsedTime / zoomDuration, 1);
        
        t = easeInOutQuad(t);
        
        var newDistance = defaultDistance + (targetDistance - defaultDistance) * t;
        
        GameUI.SetCameraDistance(newDistance);
        
        if (t < 1) {
            $.Schedule(0, zoomCamera);
        } else if (elapsedTime < zoomDuration + lockDuration) {
            $.Schedule(0, zoomCamera); // 保持锁定状态
        } else {
            // 放大完成后，可以在这里添加其他操作
        }
    }

    function easeInOutQuad(t) {
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
    }

    moveCamera(); // 开始相机移动
}

GameEvents.Subscribe("move_camera_position", OnMoveCameraPosition);

GameEvents.Subscribe("cinematic_camera_move", function(event) {
    cinematicCameraMove(event.heroPosition, event.cameraData);
});


function OnMoveCameraPosition(data) {
    // 取消cinematicCameraMove的所有后续移动
    if (cinematicAnimationInterval) {
        $.CancelScheduled(cinematicAnimationInterval);
        cinematicAnimationInterval = null;
        $.Msg("已停止之前的相机运镜");
    }
    
    var position = [data.x, data.y, data.z];
    var duration = data.duration;
    GameUI.SetCameraTargetPosition(position, duration);
    GameUI.SetCameraPitchMin(60);
    GameUI.SetCameraPitchMax(60);
    GameUI.SetCameraYaw(0);

    $.Msg("相机正在移动到新位置: ", position, " 持续时间: ", duration);
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
}


(function() {
    class CameraController {
        constructor() {
            this.isPositionChanged = false;
            this.isAngleChanged = false;
            this.initializeValues();
            this.setupEventListeners();
            this.recordedPositions = [null, null, null, null, null, null]; // 用于存储六个记录的位置
            this.setupHotkeys();
            this.updateButtonStates(); // 初始化时更新按钮状态
            this.startPositionUpdate();
            this.initializeDefaultSettings();
            
        }

        initializeDefaultSettings() {
            const defaultDistanceInput = $('#DefaultDistanceValue');
            const applyButton = $('#ApplyDistanceButton');
            
            // 点击确认按钮时应用更改
            applyButton.SetPanelEvent('onactivate', () => {
                const value = Number(defaultDistanceInput.text);
                if (!isNaN(value) && value >= 100 && value <= 6000) {
                    defaultDistance = value;
                    GameUI.SetCameraDistance(value);
                    defaultDistanceInput.text = value.toString();
                    Game.EmitSound("ui_generic_button_click");
                } else {
                    defaultDistanceInput.text = defaultDistance.toString();
                }
            });
        
            // 如果用户按下回车键也会触发确认
            defaultDistanceInput.SetPanelEvent('ontextsubmitted', () => {
                applyButton.ActivateButton(false);
            });
        
            const fogToggle = $('#FogToggle');
            fogToggle.SetPanelEvent('onactivate', () => {
                const isSelected = fogToggle.BHasClass('Selected');
                if (isSelected) {
                    fogToggle.RemoveClass('Selected');
                    fogToggle.GetChild(0).text = "开启";
                    // 发送事件到 Lua 开启迷雾
                    Game.EmitSound("ui_generic_button_click");
                    GameEvents.SendCustomGameEventToServer("SetFogOverride", { enable: 1 });
                } else {
                    fogToggle.AddClass('Selected');
                    fogToggle.GetChild(0).text = "关闭";
                    // 发送事件到 Lua 关闭迷雾
                    Game.EmitSound("ui_generic_button_click");
                    GameEvents.SendCustomGameEventToServer("SetFogOverride", { enable: 0 });
                }
            });
        }





        startPositionUpdate() {
            const updateInterval = 0.03; // 30fps
        
            const updatePosition = () => {
                if (!$('#CameraControlPanel').BHasClass('hidden')) {
                    // 更新位置坐标
                    const currentPos = GameUI.GetCameraLookAtPosition();
                    if (currentPos) {
                        // 更新XYZ坐标显示
                        ['X', 'Y', 'Z'].forEach((axis, index) => {
                            const valueInput = $(`#Camera${axis}Value`);
                            if (valueInput && !valueInput.BHasKeyFocus()) {
                                valueInput.text = Math.round(currentPos[index]);
                                this.currentValues[axis.toLowerCase()] = currentPos[index];
                            }
                        });
                    }
        
                    // 更新相机角度和距离
                    const currentYaw = GameUI.GetCameraYaw();
                    // 更新水平角
                    const yawValue = $('#CameraYawValue');
                    const yawSlider = $('#CameraYaw');
                    if (yawValue && !yawValue.BHasKeyFocus()) {
                        yawValue.text = Math.round(currentYaw);
                        yawSlider.value = (currentYaw + 180) / 360;
                        this.currentValues.yaw = currentYaw;
                    }
                    const cameraPos = GameUI.GetCameraPosition();
                    const lookAtPos = GameUI.GetCameraLookAtPosition();
                    const dx = cameraPos[0] - lookAtPos[0];
                    const dy = cameraPos[1] - lookAtPos[1];
                    const dz = cameraPos[2] - lookAtPos[2];
                    const currentDistance = Math.sqrt(dx * dx + dy * dy + dz * dz);
        
                    // 更新距离显示
                    const distanceValue = $('#CameraDistanceValue');
                    const distanceSlider = $('#CameraDistance');
                    if (distanceValue && !distanceValue.BHasKeyFocus()) {
                        distanceValue.text = Math.round(currentDistance);
                        distanceSlider.value = (currentDistance - 100) / (6000 - 100);
                        this.currentValues.distance = currentDistance;
                    }
        

                }
                
                // 继续下一次更新
                $.Schedule(updateInterval, updatePosition);
            };
        
            // 开始更新循环
            updatePosition();
        }

        updateButtonStates() {
            // 更新所有位置按钮的状态
            for (let i = 1; i <= 6; i++) {
                const recordButton = $(`#RecordPosition${i}`);
                const playButton = $(`#PlayPosition${i}`);
                
                if (this.recordedPositions[i - 1]) {
                    // 该位置已记录
                    recordButton.AddClass('Recorded');
                    playButton.RemoveClass('Disabled');
                } else {
                    // 该位置未记录
                    recordButton.RemoveClass('Recorded');
                    playButton.AddClass('Disabled');
                }
            }
        }

        setupHotkeys() {
            // Generate command names for all six positions
            this.positionCmdNames = Array(6).fill(0).map((_, i) => 
                `PlayCameraPosition${i + 1}${Math.floor(Math.random() * 99999999)}`
            );
        
            // Add commands for all positions
            this.positionCmdNames.forEach((cmdName, index) => {
                Game.AddCommand(cmdName, () => this.playTransition(index), "", 0);
            });
        
            // Bind hotkeys (4-9)
            this.positionCmdNames.forEach((cmdName, index) => {
                Game.CreateCustomKeyBind(`KP_${index + 4}`, cmdName);
            });
        
            // Distance control commands remain the same
            this.increaseDistanceCmdName = "IncreaseCameraDistance" + Math.floor(Math.random() * 99999999);
            this.decreaseDistanceCmdName = "DecreaseCameraDistance" + Math.floor(Math.random() * 99999999);
            Game.AddCommand(this.increaseDistanceCmdName, () => this.adjustDistance(50), "", 0);
            Game.AddCommand(this.decreaseDistanceCmdName, () => this.adjustDistance(-50), "", 0);
            Game.CreateCustomKeyBind("KP_PLUS", this.increaseDistanceCmdName);
            Game.CreateCustomKeyBind("KP_MINUS", this.decreaseDistanceCmdName);
        }
        adjustDistance(delta) {
            // 获取相机位置和目标位置
            const cameraPos = GameUI.GetCameraPosition();
            const lookAtPos = GameUI.GetCameraLookAtPosition();
            
            // 计算当前距离
            const dx = cameraPos[0] - lookAtPos[0];
            const dy = cameraPos[1] - lookAtPos[1];
            const dz = cameraPos[2] - lookAtPos[2];
            const currentDistance = Math.sqrt(dx * dx + dy * dy + dz * dz);
            
            // 计算新的距离
            const newDistance = Math.max(100, Math.min(6000, currentDistance + delta));
            
            // 设置新的相机距离
            GameUI.SetCameraDistance(newDistance);
            
            // 更新当前值
            this.currentValues.distance = newDistance;
            
            // 更新滑块
            const distanceSlider = $('#CameraDistance');
            if (distanceSlider) {
                distanceSlider.value = (newDistance - 100) / (6000 - 100);
            }
            
            // 更新数值显示
            const distanceValue = $('#CameraDistanceValue');
            if (distanceValue) {
                distanceValue.text = Math.round(newDistance);
            }
        }

        initializeValues() {
            this.currentValues = {
                x: 0,
                y: 0,
                z: 1200,
                pitch: 60,
                yaw: 0,
                distance: defaultDistance,
                // 添加新的初始值
                heightOffset: 0,
            };
        }

        setupEventListeners() {
            // 打开/关闭面板
            $('#CameraControlButton').SetPanelEvent('onactivate', () => {
                const panel = $('#CameraControlPanel');
                if (panel.BHasClass('hidden')) {
                    panel.RemoveClass('hidden');
                } else {
                    panel.AddClass('hidden');
                }
            });
        
            $('#CloseCameraPanel').SetPanelEvent('onactivate', () => {
                $('#CameraControlPanel').AddClass('hidden');
            });
        
            // 位置控制按钮事件
            this.setupPositionButtons('X');
            this.setupPositionButtons('Y');
            this.setupPositionButtons('Z');
        
            // 角度和距离滑块事件
            this.setupSliderEvents('CameraPitch', 'pitch');
            this.setupSliderEvents('CameraYaw', 'yaw');
            this.setupSliderEvents('CameraDistance', 'distance');

            this.setupHeightOffsetControl();
        
            // 记录和播放位置按钮
            // 使用循环设置三组按钮的事件
            for (let i = 1; i <= 6; i++) {
                const recordButton = $(`#RecordPosition${i}`);
                const playButton = $(`#PlayPosition${i}`);
                
                if (recordButton && playButton) {
                    recordButton.SetPanelEvent('onactivate', () => this.recordCurrentPosition(i - 1));
                    playButton.SetPanelEvent('onactivate', () => this.playTransition(i - 1));
                }
            }
        
            // 预设按钮
            $('#PresetTop').SetPanelEvent('onactivate', () => this.setPreset('top'));
            $('#PresetSide').SetPanelEvent('onactivate', () => this.setPreset('side'));
            $('#PresetDefault').SetPanelEvent('onactivate', () => this.setPreset('default'));
        }

        setupHeightOffsetControl() {
            const heightSlider = $('#CameraHeightOffset');
            const heightValue = $('#CameraHeightOffsetValue');
            const MAX_OFFSET = 5000; // 只需修改这个常量即可调整范围
            
            if (heightSlider && heightValue) {
                // 初始化高度偏移值
                const currentOffset = GameUI.GetCameraLookAtPositionHeightOffset();
                this.currentValues.heightOffset = currentOffset;
                heightValue.text = Math.round(currentOffset);
                heightSlider.value = (currentOffset + MAX_OFFSET) / (MAX_OFFSET * 2);
        
                heightSlider.SetPanelEvent('onvaluechanged', () => {
                    const offset = (heightSlider.value * MAX_OFFSET * 2) - MAX_OFFSET;
                    GameUI.SetCameraLookAtPositionHeightOffset(offset);
                    heightValue.text = Math.round(offset);
                    this.currentValues.heightOffset = offset;
                });
        
                heightValue.SetPanelEvent('ontextsubmitted', () => {
                    const value = Number(heightValue.text);
                    if (!isNaN(value)) {
                        const clampedOffset = Math.max(-MAX_OFFSET, Math.min(MAX_OFFSET, value));
                        heightSlider.value = (clampedOffset + MAX_OFFSET) / (MAX_OFFSET * 2);
                        GameUI.SetCameraLookAtPositionHeightOffset(clampedOffset);
                        this.currentValues.heightOffset = clampedOffset;
                        heightValue.text = Math.round(clampedOffset);
                    }
                });
            }
        }




        setupInsetControl(elementId, callback) {
            const slider = $(`#${elementId}`);
            const valueInput = $(`#${elementId}Value`);
            
            if (slider && valueInput) {
                slider.SetPanelEvent('onvaluechanged', () => {
                    const value = Math.round(slider.value * 100);
                    valueInput.text = value;
                    this.currentValues[elementId.toLowerCase()] = value;
                    callback(slider.value);
                });
        
                valueInput.SetPanelEvent('ontextsubmitted', () => {
                    const value = Number(valueInput.text);
                    if (!isNaN(value)) {
                        const clampedValue = Math.max(0, Math.min(100, value));
                        slider.value = clampedValue / 100;
                        valueInput.text = clampedValue;
                        this.currentValues[elementId.toLowerCase()] = clampedValue;
                        callback(clampedValue / 100);
                    }
                });
            }
        }

        // 修改记录位置的方法，确保记录原始角度
        recordCurrentPosition(index) {
            // 获取当前相机状态，不对角度进行规范化
            const currentYaw = GameUI.GetCameraYaw();
            
            this.recordedPositions[index] = {
                position: GameUI.GetCameraLookAtPosition(),
                pitch: this.currentValues.pitch,
                yaw: currentYaw,
                distance: this.currentValues.distance,
                // 添加新的属性
                heightOffset: this.currentValues.heightOffset,
            };

            // 更新当前值
            this.currentValues.x = this.recordedPositions[index].position[0];
            this.currentValues.y = this.recordedPositions[index].position[1];
            this.currentValues.z = this.recordedPositions[index].position[2];
            this.currentValues.yaw = currentYaw; // 使用原始角度

            // 更新按钮状态
            this.updateButtonStates();

            // 提示信息
            $.Msg(`已记录位置 ${index + 1}`);
        }

    
        playTransition(index) {
            if (!this.recordedPositions[index]) {
                $.Msg(`位置 ${index + 1} 还未记录`);
                return;
            }
        
            // Get transition time from the corresponding input
            const transitionTime = Number($(`#TransitionTime${index + 1}`).text);
            if (isNaN(transitionTime) || transitionTime <= 0) {
                $.Msg("请输入有效的过渡时间");
                return;
            }
        
            // 隐藏控制面板
            $('#CameraControlPanel').AddClass('hidden');
        
            // 设置相机位置
            GameUI.SetCameraTarget(-1);
            
            // 使用Schedule来设置角度和距离
            const updateInterval = 1/144; // 144fps
            const steps = Math.ceil(transitionTime / updateInterval);
            let currentStep = 0;
        
            // 获取初始值和目标值
            const initialPitch = this.currentValues.pitch;
            const initialYaw = this.currentValues.yaw;
            const initialDistance = this.currentValues.distance;
            const initialHeightOffset = this.currentValues.heightOffset;
            const initialPosition = GameUI.GetCameraLookAtPosition();
        
            const targetPos = this.recordedPositions[index];
            const pitchDiff = targetPos.pitch - initialPitch;
            const targetHeightOffset = targetPos.heightOffset;
            const heightOffsetDiff = targetHeightOffset - initialHeightOffset;
            const distanceDiff = targetPos.distance - initialDistance;
        
            // 计算最短的旋转角度
            let yawDiff = targetPos.yaw - initialYaw;
            if (yawDiff > 180) {
                yawDiff -= 360;
            } else if (yawDiff < -180) {
                yawDiff += 360;
            }
        
            const updateCamera = () => {
                currentStep++;
                const progress = currentStep / steps;
        
                // 线性插值计算当前值
                const currentPitch = initialPitch + (pitchDiff * progress);
                const currentYaw = initialYaw + (yawDiff * progress);
                const currentDistance = initialDistance + (distanceDiff * progress);
                const currentHeightOffset = initialHeightOffset + (heightOffsetDiff * progress);
        
                // 在最后一步时直接使用目标角度
                const finalYaw = (currentStep === steps) ? targetPos.yaw : currentYaw;
                
                // 计算当前位置
                const currentPosition = [
                    initialPosition[0] + (targetPos.position[0] - initialPosition[0]) * progress,
                    initialPosition[1] + (targetPos.position[1] - initialPosition[1]) * progress,
                    initialPosition[2] + (targetPos.position[2] - initialPosition[2]) * progress
                ];
        
                // 更新相机参数
                GameUI.SetCameraTargetPosition(currentPosition, -1);
                GameUI.SetCameraYaw(finalYaw);
                GameUI.SetCameraPitchMin(currentPitch);
                GameUI.SetCameraPitchMax(currentPitch);
                GameUI.SetCameraDistance(currentDistance);
                GameUI.SetCameraLookAtPositionHeightOffset(currentHeightOffset);
        
                // 更新UI值
                this.currentValues.pitch = currentPitch;
                this.currentValues.yaw = finalYaw;
                this.currentValues.distance = currentDistance;
                this.currentValues.heightOffset = currentHeightOffset;
        
                // 更新滑块位置
                this.updateSliders();
        
                // 如果还没完成，继续下一步
                if (currentStep < steps) {
                    $.Schedule(updateInterval, () => updateCamera());
                }
            };
        
            // 开始更新
            updateCamera();
        }
        
        // 添加缓动函数
        easeInOutQuad(t) {
            return t < 0.5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;
        }

        clearPosition(index) {
            this.recordedPositions[index] = null;
            this.updateButtonStates();
            $.Msg(`已清除位置 ${index + 1}`);
        }

        setupPositionButtons(axis) {
            const valueInput = $('#Camera' + axis + 'Value');
            
            // 添加一个计时器属性
            this[`${axis}Timer`] = null;
            const stepSize = 10;
            const initialDelay = 400;
            const repeatInterval = 50;
    
            // 值更新函数
            const updateValue = (increment) => {
                // 获取当前相机位置
                const currentPos = GameUI.GetCameraLookAtPosition();
                const axisIndex = axis.toLowerCase() === 'x' ? 0 : axis.toLowerCase() === 'y' ? 1 : 2;
                const newPos = [...currentPos];
                newPos[axisIndex] += (increment ? stepSize : -stepSize);
                
                // 设置新的相机位置
                GameUI.SetCameraTargetPosition(newPos, 0.1);
    
                // valueInput 的更新现在由 startPositionUpdate 处理
            };
        
            // 开始重复更新的函数
            const startRepeating = (increment) => {
                // 先清除可能存在的计时器
                if (this[`${axis}Timer`]) {
                    $.CancelScheduled(this[`${axis}Timer`]);
                }
                
                // 设置重复计时器
                const repeat = () => {
                    updateValue(increment);
                    this[`${axis}Timer`] = $.Schedule(repeatInterval/1000, () => repeat());
                };
                
                // 初始延迟后开始重复
                this[`${axis}Timer`] = $.Schedule(initialDelay/1000, () => repeat());
            };
        
            // 停止重复的函数
            const stopRepeating = () => {
                if (this[`${axis}Timer`]) {
                    $.CancelScheduled(this[`${axis}Timer`]);
                    this[`${axis}Timer`] = null;
                }
            };
        
            // 上箭头按钮
            const upButton = $('#' + axis + 'Up');
            upButton.SetPanelEvent('onmousedown', () => {
                updateValue(true); // 立即更新一次
                startRepeating(true);
            });
            upButton.SetPanelEvent('onmouseup', stopRepeating);
            upButton.SetPanelEvent('onmouseout', stopRepeating);
        
            // 下箭头按钮
            const downButton = $('#' + axis + 'Down');
            downButton.SetPanelEvent('onmousedown', () => {
                updateValue(false); // 立即更新一次
                startRepeating(false);
            });
            downButton.SetPanelEvent('onmouseup', stopRepeating);
            downButton.SetPanelEvent('onmouseout', stopRepeating);
        
            // 文本框直接输入
            valueInput.SetPanelEvent('ontextsubmitted', () => {
                const value = Number(valueInput.text);
                if (!isNaN(value)) {
                    const currentPos = GameUI.GetCameraLookAtPosition();
                    const axisIndex = axis.toLowerCase() === 'x' ? 0 : axis.toLowerCase() === 'y' ? 1 : 2;
                    const newPos = [...currentPos];
                    newPos[axisIndex] = value;
                    GameUI.SetCameraTargetPosition(newPos, 0.1);
                }
            });
        }

        setupSliderEvents(sliderId, property) {
            const slider = $('#' + sliderId);
            const valueInput = $('#' + sliderId + 'Value');
    
            // 定义每个属性的范围
            const ranges = {
                pitch: { min: 1, max: 180 },  
                yaw: { min: -180, max: 180 },  
                distance: { min: 100, max: 6000 }
            };
    
            // 将0-1之间的值转换为实际值
            const denormalizeValue = (normalized, range) => {
                return normalized * (range.max - range.min) + range.min;
            };
    
            // 将实际值转换为0-1之间的值
            const normalizeValue = (value, range) => {
                return (value - range.min) / (range.max - range.min);
            };
    
            slider.SetPanelEvent('onvaluechanged', () => {
                const normalizedValue = slider.value;
                const range = ranges[property];
                const actualValue = denormalizeValue(normalizedValue, range);
                valueInput.text = Math.round(actualValue);
                this.currentValues[property] = actualValue;
                this.isAngleChanged = true;
                this.updateCamera();
            });
    
            valueInput.SetPanelEvent('ontextsubmitted', () => {
                const value = Number(valueInput.text);
                if (!isNaN(value)) {
                    const range = ranges[property];
                    // 确保输入值在范围内
                    const clampedValue = Math.max(range.min, Math.min(range.max, value));
                    const normalizedValue = normalizeValue(clampedValue, range);
                    slider.value = normalizedValue;
                    this.currentValues[property] = clampedValue;
                    valueInput.text = Math.round(clampedValue);
                    this.isAngleChanged = true;
                    this.updateCamera();
                }
            });
        }
        
        updateSliders() {
            // 更新俯仰角滑块
            const pitchSlider = $('#CameraPitch');
            const pitchValue = $('#CameraPitchValue');
            if (pitchSlider && pitchValue) {
                // 使用新的范围1-180
                const normalizedPitch = (this.currentValues.pitch - 1) / (180 - 1);
                pitchSlider.value = normalizedPitch;
                pitchValue.text = Math.round(this.currentValues.pitch);
            }
        
            // 更新水平角滑块，使用原始角度
            const yawSlider = $('#CameraYaw');
            const yawValue = $('#CameraYawValue');
            if (yawSlider && yawValue) {
                // 确保显示的是原始角度
                const yaw = this.currentValues.yaw;
                // 将实际值转换为0-1之间的值，但保持原始角度的显示
                const normalizedYaw = ((yaw + 180) % 360) / 360;
                yawSlider.value = normalizedYaw;
                yawValue.text = Math.round(yaw);
            }
        
            // 更新距离滑块 - 修改这里的范围为100-6000
            const distanceSlider = $('#CameraDistance');
            const distanceValue = $('#CameraDistanceValue');
            if (distanceSlider && distanceValue) {
                // 使用新的范围100-6000
                const normalizedDistance = (this.currentValues.distance - 100) / (6000 - 100);
                distanceSlider.value = normalizedDistance;
                distanceValue.text = Math.round(this.currentValues.distance);
            }
        }



        updateCamera() {
            // 解除相机目标锁定
            GameUI.SetCameraTarget(-1);

            // 只有当位置值改变时才更新位置
            if (this.isPositionChanged) {
                const position = [this.currentValues.x, this.currentValues.y, this.currentValues.z];
                GameUI.SetCameraTargetPosition(position, 0.1);
                this.isPositionChanged = false;
            }

            // 只有当角度或距离改变时才更新相应值
            if (this.isAngleChanged) {
                GameUI.SetCameraYaw(this.currentValues.yaw);
                GameUI.SetCameraPitchMin(this.currentValues.pitch);
                GameUI.SetCameraPitchMax(this.currentValues.pitch);
                GameUI.SetCameraDistance(this.currentValues.distance);
                this.isAngleChanged = false;
            }
        }

        setPreset(preset) {
            switch(preset) {
                case 'top':
                    this.setValues({
                        pitch: 90,
                        distance: 2000,
                        yaw: 0,
                        heightOffset: 0  // 添加高度偏移重置
                    });
                    break;
                case 'side':
                    this.setValues({
                        pitch: 30,
                        distance: 1500,
                        yaw: 90,
                        heightOffset: 0  // 添加高度偏移重置
                    });
                    break;
                case 'default':
                    this.setValues({
                        pitch: 60,
                        distance: defaultDistance,
                        yaw: 0,
                        heightOffset: 0  // 添加高度偏移重置
                    });
                    break;
            }
        
            // 更新高度偏移的UI
            const heightSlider = $('#CameraHeightOffset');
            const heightValue = $('#CameraHeightOffsetValue');
            if (heightSlider && heightValue) {
                heightSlider.value = 0.5; // 因为-100到100的范围映射到0-1，所以0对应0.5
                heightValue.text = '0';
                // 实际应用高度偏移
                GameUI.SetCameraLookAtPositionHeightOffset(0);
            }
        }

        setValues(values) {
            Object.assign(this.currentValues, values);
            this.isAngleChanged = true;
            this.updateSliders();
            this.updateCamera();
        }


    }

    // 初始化相机控制器
    GameUI.CameraController = new CameraController();
})();