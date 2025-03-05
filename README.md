# DOTA 2技能伤害提示板

一个用于显示DOTA 2技能伤害的悬浮提示板，使用Panorama UI实现。

## 文件结构

- `damage_panel.xml` - 定义UI结构的XML文件
- `damage_panel.css` - 样式文件
- `damage_panel.js` - 脚本文件，处理交互和动画

## 安装方法

1. 将这三个文件复制到您的自定义游戏模式的Panorama目录中，通常位于：
   ```
   content/dota_addons/your_addon_name/panorama/
   ```

2. 确保XML文件在适当的位置被引用和加载。

## 功能

- 显示英雄名称和头像
- 显示技能名称和图标
- 显示累计伤害数值
- 美观的伤害增加动画效果
- 根据英雄属性（力量/敏捷/智力/通用）更改颜色
- 自动在5秒无更新后隐藏

## 后端接口

伤害提示板通过GameEvents系统接收后端发送的消息。共有三个消息类型：

### 1. 更新英雄 (damage_panel_update_hero)

```lua
GameEvents.SendCustomGameEventToPlayer("damage_panel_update_hero", PlayerID, {
    hero_name = "幻影刺客",         -- 英雄名称
    hero_id = "phantom_assassin",   -- 英雄ID，用于获取图像
    attribute = "Agility",          -- 英雄属性（Strength/Agility/Intelligence/Universal）
    initial_damage = 500            -- 初始伤害数值（可选）
})
```

### 2. 更新技能 (damage_panel_update_ability)

```lua
GameEvents.SendCustomGameEventToPlayer("damage_panel_update_ability", PlayerID, {
    ability_name = "散射",          -- 技能名称
    ability_id = "phantom_strike"   -- 技能ID，用于获取图像
})
```

### 3. 更新伤害 (damage_panel_update_damage)

```lua
GameEvents.SendCustomGameEventToPlayer("damage_panel_update_damage", PlayerID, {
    damage = 750  -- 当前总伤害值（会自动计算增加值并显示动画）
})
```

## 测试方式

在开发环境中，您可以通过点击伤害面板本身来触发测试功能，这将自动模拟英雄更新和伤害增加。

## 自定义

您可以通过修改CSS文件来自定义面板的外观，包括：

- 修改尺寸和位置
- 调整颜色和动画效果
- 更改字体和布局

## 注意事项

- 面板会在收到更新消息时显示，并在5秒无更新后自动隐藏
- 更新英雄时会暂时隐藏面板，并在更新完成后重新显示，以实现平滑过渡
- 所有动画和过渡都使用Panorama UI的动画系统实现，确保高性能和一致性
- 使用self.SetDamagePanelEnabled(true)来开启最高技能伤害面板的显示