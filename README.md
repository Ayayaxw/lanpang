# LanPang Dota2 MOD  
  
![Dota2](https://img.shields.io/badge/Dota2-MOD-orange)
![License](https://img.shields.io/badge/License-Non--Commercial-blue)
  
蓝胖超人斗蛐蛐地图  
  
## 目录结构  
lanpang  
├── content/ # 全景UI资源  
│ └── test2/ # Dota2内容目录  
│ ├── panorama/ # 界面脚本  
│ └── maps/ # 游戏地图  
├── game/ # 游戏逻辑  
│ └── test2/ # Dota2游戏目录  
│ ├── scripts/ # Lua脚本  
│ └── npc/ # 单位定义  
├── LICENSE # 开源协议  
└── README.md # 项目文档  
  
## 快速开始  
  
### 环境配置  
1. 创建符号链接（管理员权限运行）：
```dos
mklink /J "D:\APP\Steam\steamapps\common\dota 2 beta\content\dota_addons\test2" "E:\Dep\lanpang\content\test2"
```
:: 游戏逻辑目录  
```dos
mklink /J "D:\APP\Steam\steamapps\common\dota 2 beta\game\dota_addons\test2" "E:\Dep\lanpang\game\test2"  
```

## 斗蛐蛐模式开发指南  

# 一 初始化函数  
这里的每一个小点全都需要，一个都不能少。  
  
初始化函数命名为 `Init_[模式名]`，接收 `event` 和 `playerID` 两个参数：  
## 1. 基础参数初始化  
  
每个模式都需要以下基础参数初始化：  
```lua
-- 比赛ID初始化  
self.currentMatchID = self:GenerateUniqueID()      
  
-- 游戏速度初始化  
SendToServerConsole("host_timescale 1")  
  
-- 计时器ID初始化  
self.currentTimer = (self.currentTimer or 0) + 1   
local timerId = self.currentTimer  
  
-- 设置初始金钱  
PlayerResource:SetGold(playerID, 0, false)  
  
--根据有几个队伍设置几个队伍的视野  
local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍  
self:CreateTrueSightWards(teams)  
  
-- 定义时间参数  
self.duration = 10         -- 赛前准备时间  
self.endduration = 10      -- 赛后庆祝时间  
self.limitTime = 60        -- 比赛时间  
hero_duel.EndDuel = false  -- 标记战斗是否结束  
  
-- 设置摄像机位置  
self:SendCameraPositionToJS(Main.largeSpawnCenter, 1)  
```

### 重要说明：  
  
- 计数类参数建议使用 `hero_duel.xxx` ，而不是 `self.xxx`  
- 例如击杀计数初始化：`hero_duel.killCount = 0`  
  
  
## 2 英雄配置  
  
标准的英雄配置结构：  
```lua
    local teams = {DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS} -- 或其他你需要的队伍  
  
    self:CreateTrueSightWards(teams)  
    self.HERO_CONFIG = {  
	ALL = {  
		function(hero)  
			hero:AddNewModifier(hero, nil, "modifier_kv_editor", {})  
			hero:AddNewModifier(hero, nil, "modifier_disarmed", {duration = 5})  
			hero:AddNewModifier(hero, nil, "modifier_item_aghanims_shard", {})  
			hero:AddNewModifier(hero, nil, "modifier_item_ultimate_scepter_consumed", {})  
			HeroMaxLevel(hero)  
		end,  
	},  
	FRIENDLY = {  
		function(hero)  
			hero:SetForwardVector(Vector(1, 0, 0))  
			-- 可以在这里添加更多友方英雄特定的操作  
		end,  
	},  
	ENEMY = {  
		function(hero)  
			hero:SetForwardVector(Vector(-1, 0, 0))  
			-- 可以在这里添加敌方英雄特定的操作  
		end,  
	},  
	BATTLEFIELD = {  
		function(hero)  
			hero:AddNewModifier(hero, nil, "modifier_auto_elevation_large", {})  
		end,  
	}  
}  
```

## 3. 数据获取  
  
根据模式类型选择适当的数据获取方式：  
  
### 单人模式数据获取：  
```lua
local selfHeroId = event.selfHeroId or -1  
local selfFacetId = event.selfFacetId or -1  
local selfAIEnabled = (event.selfAIEnabled == 1)  
local selfEquipment = event.selfEquipment or {}  
local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)  
local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)  
  
-- 获取英雄名称  
local heroName, heroChineseName = self:GetHeroNames(selfHeroId)  
```
  
### 双人模式数据获取：
```lua
-- 玩家数据  
local selfHeroId = event.selfHeroId or -1  
local selfFacetId = event.selfFacetId or -1  
local selfAIEnabled = (event.selfAIEnabled == 1)  
local selfEquipment = event.selfEquipment or {}  
local selfOverallStrategy = self:getDefaultIfEmpty(event.selfOverallStrategies)  
local selfHeroStrategy = self:getDefaultIfEmpty(event.selfHeroStrategies)  
  
-- 对手数据  
local opponentHeroId = event.opponentHeroId or -1  
local opponentFacetId = event.opponentFacetId or -1  
local opponentAIEnabled = (event.opponentAIEnabled == 1)  
local opponentEquipment = event.opponentEquipment or {}  
local opponentOverallStrategy = self:getDefaultIfEmpty(event.opponentOverallStrategies)  
local opponentHeroStrategy = self:getDefaultIfEmpty(event.opponentHeroStrategies)  
  
-- 获取双方英雄名称  
local heroName, heroChineseName = self:GetHeroNames(selfHeroId)  
local opponentHeroName, opponentChineseName = self:GetHeroNames(opponentHeroId)  
```
  
## 4. 播报系统  
  
播报系统分为两种：裁判控制台播报和观众前端播报  
  
### 4.1 裁判控制台播报  
  
使用 `createLocalizedMessage` 方法，基本格式：  

```lua
-- 基础播报  
self:createLocalizedMessage(  
    "[LanPang_RECORD][",  
    self.currentMatchID,  
    "]",  
    "[新挑战]"  
)  
  
-- 英雄选择播报（单人模式）  
self:createLocalizedMessage(  
    "[LanPang_RECORD][",  
    self.currentMatchID,  
    "]",  
    "[选择绿方]",  
    {localize = true, text = heroName},  
    ",",  
    {localize = true, text = "facet", facetInfo = self:getFacetTooltip(heroName, selfFacetId)}  
)  
  
-- 双人模式额外添加红方播报  
self:createLocalizedMessage(  
    "[LanPang_RECORD][",  
    self.currentMatchID,  
    "]",  
    "[选择红方]",  
    {localize = true, text = opponentHeroName},  
    ",",  
    {localize = true, text = "facet", facetInfo =self:getFacetTooltip(opponentHeroName, opponentFacetId)}  
)
```
  
### 4.2 观众前端播报  
  
使用 `SendInitializationMessage` 方法，根据模式类型设置不同的显示内容：  

```lua
-- 双人对战模式示例  
local data = {  
    ["挑战英雄"] = heroChineseName,  
    ["对手英雄"] = opponentChineseName,  
    ["剩余时间"] = self.limitTime,  
}  
local order = {"挑战英雄", "对手英雄", "剩余时间"}  
SendInitializationMessage(data, order)  
  
-- 单人计分模式示例  
local data = {  
    ["挑战英雄"] = heroChineseName,  
    ["击杀数量"] = "0",  
    ["最高僵尸攻击"] = "1",  
    ["最高僵尸生命"] = "100",  
    ["剩余时间"] = self.limitTime,  
    ["当前得分"] = "0",  
}  
local order = {"挑战英雄", "击杀数量", "最高僵尸攻击","最高僵尸生命","剩余时间", "当前得分"}  
SendInitializationMessage(data, order)
```
  
### 播报系统注意事项：  
  
1. 控制台播报主要用于记录比赛过程和结果  
2. 前端播报决定了观众能看到的信息  
3. 前端播报的 `order` 数组决定了信息显示的顺序  
4. 数值型数据初始显示建议使用字符串"0"  
5. 所有中文信息使用中文名称，便于观众理解  
  
## 5. 英雄创建  
  
英雄创建分为玩家英雄和对手英雄两部分：  
  
### 5.1 玩家英雄创建（通用）  
```lua
CreateHero(playerID, heroName, selfFacetId, self.smallDuelAreaLeft, DOTA_TEAM_GOODGUYS, false, function(playerHero)  
    self:ConfigureHero(playerHero, true, playerID)  
    self:EquipHeroItems(playerHero, selfEquipment)  
    self.leftTeamHero1 = playerHero  
    self.currentArenaHeroes[1] = playerHero  
      
    -- AI功能（如果启用）  
    if selfAIEnabled then  
        Timers:CreateTimer(self.duration - 0.7, function()  
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
            CreateAIForHero(self.leftTeamHero1, selfOverallStrategy, selfHeroStrategy,"leftTeamHero1")  
            return nil  
        end)  
    end  
end)  
```

### 5.2 对手英雄创建（双人模式）  
```lua
CreateHero(playerID, opponentHeroName, opponentFacetId, self.smallDuelAreaRight, DOTA_TEAM_BADGUYS, false, function(opponentHero)  
    self:ConfigureHero(opponentHero, false, playerID)  
    self:EquipHeroItems(opponentHero, opponentEquipment)  
    self.rightTeamHero1 = opponentHero  
    self:ListenHeroHealth(self.rightTeamHero1)  
    self.currentArenaHeroes[2] = self.rightTeamHero1  
  
    -- AI功能（如果启用）  
    if opponentAIEnabled then  
        Timers:CreateTimer(self.duration - 0.7, function()  
            if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
            CreateAIForHero(self.rightTeamHero1, opponentOverallStrategy, opponentHeroStrategy,"rightTeamHero1")  
            return nil  
        end)  
    end  
end)  
```
  
## 6. 赛前准备阶段  
  
### 6.1 基础准备时间  
```lua
--赛前自由准备时间  
Timers:CreateTimer(2, function()  
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
    self.leftTeam = {self.leftTeamHero1}  
    self.rightTeam = {self.rightTeamHero1}  
    self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })  
    self.leftTeamHero1:AddNewModifier(self.leftTeamHero1, nil, "modifier_no_cooldown_all", { duration = 3 })  
end)  
  
-- 英雄特殊加成（所有英雄都得有）  
    Timers:CreateTimer(2, function()  
	if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
	self:HeroPreparation(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)  
	self:HeroPreparation(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)  
end)  
--给英雄添加小礼物所有英雄都得有）  
Timers:CreateTimer(self.duration - 0.5, function()  
	if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
	self:HeroBenefits(heroName, self.leftTeamHero1, selfOverallStrategy,selfHeroStrategy)  
	self:HeroBenefits(opponentHeroName, self.rightTeamHero1, opponentOverallStrategy,opponentHeroStrategy)  
end)
```

6.2 英雄限制和重置  
```lua
Timers:CreateTimer(5, function()  
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
      
    --准备左侧英雄  
    local ability_modifiers = {  
    }  
    self:UpdateAbilityModifiers(ability_modifiers)  
        self:PrepareHeroForDuel(  
            self.leftTeamHero1,                     -- 英雄单位  
            self.smallDuelAreaLeft,      -- 左侧决斗区域坐标  
            self.duration - 5,                      --   
            Vector(1, 0, 0)          -- 朝向右侧  
        )  
	--准备右侧英雄（如果是多人模式）  
        self:PrepareHeroForDuel(  
            self.rightTeamHero1,          
            self.smallDuelAreaRight,      
            self.duration - 5,            
            Vector(-1, 0, 0)          
        )  
end)  
```  
  
  
## 7. 入场动画和比赛开始  
  
### 7.1 双人模式入场动画  
```lua
Timers:CreateTimer(self.duration - 6, function()  
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
  
    Timers:CreateTimer(0.1, function()  
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
        self:MonitorUnitsStatus()  
        return 0.01  
    end)  
  
    self:SendHeroAndFacetData(heroName, opponentHeroName, selfFacetId, opponentFacetId, self.limitTime)  
      
    -- 慢动作效果  
    Timers:CreateTimer(2, function()  
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
        SendToServerConsole("host_timescale 0.5")  
    end)  
    Timers:CreateTimer(3, function()  
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
        SendToServerConsole("host_timescale 1")  
    end)  
end)  
```

### 7.2 单人模式入场动画 
```lua
Timers:CreateTimer(self.duration - 6, function()  
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
  
    self:SendLeftHeroData(heroName, selfFacetId)  
      
    -- 慢动作效果  
    Timers:CreateTimer(2, function()  
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
        SendToServerConsole("host_timescale 0.5")  
    end)  
    Timers:CreateTimer(3, function()  
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
        SendToServerConsole("host_timescale 1")  
    end)  
end)  
```
  
# 8. 比赛开始信号  
  
### 8.1 开始信号发送 
```lua
Timers:CreateTimer(self.duration - 1, function()  
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
    CustomGameEventManager:Send_ServerToAllClients("start_fighting", {})  
end)  
```

## 8.2 单人模式开始  
```lua
Timers:CreateTimer(self.duration, function()  
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
    hero_duel.startTime = GameRules:GetGameTime() -- 记录开始时间  
    CustomGameEventManager:Send_ServerToAllClients("start_timer", {})  
  
    self:createLocalizedMessage(  
        "[LanPang_RECORD][",  
        self.currentMatchID,  
        "]",  
        "[正式开始]"  
    )  
end)
```
  
### 8.3 双人模式开始  
```lua
Timers:CreateTimer(self.duration, function()  
    if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
    self.startTime = GameRules:GetGameTime() -- 记录开始时间  
    CustomGameEventManager:Send_ServerToAllClients("start_timer", {})  
    self:MonitorUnitsStatus()  
    self:StartAbilitiesMonitor(self.rightTeamHero1)  
    self:StartAbilitiesMonitor(self.leftTeamHero1)  
    self:createLocalizedMessage(  
        "[LanPang_RECORD][",  
        self.currentMatchID,  
        "]",  
        "[正式开始]"  
    )  
end)  
```
  
## 9. 比赛结束判定  
  
### 9.1 单人模式倒计时结束  
  
取决于用户，用户希望倒计时结束是胜利还是失败  
失败：  
```lua
    Timers:CreateTimer(self.limitTime + self.duration, function()  
  
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
  
        hero_duel.EndDuel = true  

        self:PlayDefeatAnimation(self.leftTeamHero1)  
  
        self:createLocalizedMessage(  
            "[LanPang_RECORD][",  
            self.currentMatchID,  
            "]",  
            "[挑战失败],最终得分:" .. hero_duel.finalScore  
        )  
  
        self:gradual_slow_down(self.leftTeamHero1:GetOrigin(), self.leftTeamHero1:GetOrigin())  
  
        CustomGameEventManager:Send_ServerToAllClients("update_score", {  
            ["剩余时间"] = "0",  
            ["当前得分"] = tostring(hero_duel.finalScore)  
        })  
    end)  
```
  
如果是胜利：  
就是这个 `PlayVictoryEffects` 
  
  
### 9.2 双人模式倒计时结束（血量比较）  
```lua
    Timers:CreateTimer(self.limitTime + self.duration, function()  
  
        if self.currentTimer ~= timerId or hero_duel.EndDuel then return end  
  
        hero_duel.EndDuel = true  
  
        -- 停止计时  
        CustomGameEventManager:Send_ServerToAllClients("stop_timer", {})  
  
        self:DisableHeroWithModifiers(self.leftTeamHero1, self.endduration)  
  
        self:DisableHeroWithModifiers(self.rightTeamHero1, self.endduration)  

    end)  
```

# 三、死亡判定函数编写指南  
## 1. 多人模式死亡判定  
  
简单的多人模式可以直接使用标准判定：  

```lua
function Main:OnUnitKilled_[模式名](killedUnit, args)  
    local killedUnit = EntIndexToHScript(args.entindex_killed)  
  
    if hero_duel.EndDuel or not killedUnit:IsRealHero() then  
        print("Unit killed: " .. killedUnit:GetUnitName() .. " (not processed)")  
        return  
    end  
  
    self:ProcessHeroDeath(killedUnit)  
end  
```

### 2. 单人模式死亡判定  
单人模式需要更详细的判定逻辑，基本结构为：  
一般来说玩家死亡就是失败，如果是其他单位死亡，可以有不同的逻辑，根据用户的需求来定  
  

```lua
function Main:OnUnitKilled_[模式名](killedUnit, args)  
  
    local killedUnit = EntIndexToHScript(args.entindex_killed)  
  
    local killer = EntIndexToHScript(args.entindex_attacker)  
  
    if not killedUnit or killedUnit:IsNull() then return end  
  
    -- 判断是否是玩家英雄死亡  
    if killedUnit:IsRealHero() and killedUnit:GetTeamNumber() == DOTA_TEAM_GOODGUYS then  
  
        -- 计算最终得分 (使用当前累积的分数，取整)  
        local finalScore = math.floor(hero_duel.finalScore)  
  
        -- 发送记录消息  
        self:createLocalizedMessage(  
            "[LanPang_RECORD][",  
            self.currentMatchID,  
            "]",  
            "[挑战失败],最终得分:" .. finalScore  
        )  
  
        -- 发送最终结果给前端  
        self:PlayDefeatAnimation(self.leftTeamHero1)  
  
        self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_invulnerable", {})  
  
        self.rightTeamHero1:AddNewModifier(self.rightTeamHero1, nil, "modifier_rooted", {})  
  
        -- 计算并格式化剩余时间  
  
        local endTime = GameRules:GetGameTime()  
  
        local timeSpent = endTime - hero_duel.startTime  
  
        local remainingTime = self.limitTime - timeSpent  
  
        local formattedTime = string.format("%02d:%02d.%02d",  
            math.floor(remainingTime / 60),  
            math.floor(remainingTime % 60),  
            math.floor((remainingTime * 100) % 100))  
  
        CustomGameEventManager:Send_ServerToAllClients("update_score", {["剩余时间"] = formattedTime})  
  
        hero_duel.EndDuel = true  
  
        return  
    end  
end  
```
  
# 四：其他  
如果有需要的话，还有一些，比如，所有英雄单位都需要给与模式的指定modifier（需要才加，不需要就不管）  

```lua
function Main:OnNPCSpawned_[模式名](spawnedUnit, event)  
    if not self:isExcludedUnit(spawnedUnit) then  
        self:ApplyConfig(spawnedUnit, "BATTLEFIELD")  
    end  
end  
```
