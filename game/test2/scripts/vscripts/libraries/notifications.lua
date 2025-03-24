NOTIFICATIONS_VERSION = "1.00"

--[[
  样本全景UI通知库 由BMD开发

  安装方法
  -在您的代码中"require"此文件以访问Notifications类，用于向玩家、团队或所有客户端发送通知
  -确保您的全景UI内容文件夹中有barebones_notifications.xml、barebones_notifications.js和barebones_notifications.css文件
  -确保在custom_ui_manifest.xml中包含barebones_notifications.xml
    <CustomUIElement type="Hud" layoutfile="file://{resources}/layout/custom_game/barebones_notifications.xml" />

  使用方法
  -通知可以发送到单个玩家、整个团队或所有客户端的顶部或底部通知面板
  -通知可以由标签、图像、英雄图像和技能图像等部分组成
  -通知由一个表指定，该表有4个潜在参数:
    -duration: 屏幕上显示通知的持续时间。对于"继续"之前通知行的通知会忽略此参数
    -class: 可选参数（默认为nil），将作为添加到通知部分的类名
    -style: 可选参数（默认为nil），添加到此通知的css属性表，如{["font-size"]="60px", color="green"}
    -continue: 可选布尔值（默认为false），如果为'true'则告诉通知系统将此通知添加到当前通知行
      这允许您在同一个整体通知中放置多个单独的通知部分
  -对于标签，还有一个必填参数:
    -text: 在通知中显示的文本。可以提供本地化令牌("#addonname")或非本地化文本
  -对于英雄图像，有两个额外参数:
    -hero: (必填)英雄名称，如"npc_dota_hero_axe"
    -imagestyle: (可选)此英雄图像的显示风格。默认为'icon'。'portrait'和'landscape'是其他两个选项
  -对于技能图像，有一个额外必填参数:
    -ability: 技能名称，如"lina_fiery_soul"
  -对于图像，有一个额外必填参数:
    -image: 图像src字符串，如"file://{images}/status_icons/dota_generic.psd"
  -对于物品图像，有一个额外必填参数:
    -item: 物品名称，如"item_force_staff"

  -通知可以从顶部/底部移除或清除

  -调用Notifications:Top、Notifications:TopToAll或Notifications:TopToTeam向相应玩家发送顶部区域通知
  -调用Notifications:Bottom、Notifications:BottomToAll或Notifications:BottomToTeam向相应玩家发送底部区域通知
  -调用Notifications:ClearTop、Notifications:ClearTopFromAll或Notifications:ClearTopFromTeam清除相应玩家的所有现有顶部区域通知
  -调用Notifications:ClearBottom、Notifications:ClearBottomFromAll或Notifications:ClearBottomFromTeam清除相应玩家的所有现有底部区域通知
  -调用Notifications:RemoveTop、Notifications:RemoveTopFromAll或Notifications:RemoveTopFromTeam移除相应玩家的所有现有顶部区域通知，最多提供的通知计数
  -调用Notifications:RemoveBottom、Notifications:RemoveBottomFromAll或Notifications:RemoveBottomFromTeam移除相应玩家的所有现有底部区域通知，最多提供的通知计数
  
  示例:

  -- 向所有玩家发送一个在顶部显示5秒钟的通知
  Notifications:TopToAll({text="顶部通知，持续5秒", duration=5.0})
  -- 向玩家ID为0的玩家发送一个在顶部显示9秒钟的绿色通知，与前一通知在同一行
  Notifications:Top(0, {text="绿色文本", duration=9, style={color="green"}, continue=true})

  -- 在同一行显示3种风格的英雄图标，持续5秒钟
  Notifications:TopToAll({hero="npc_dota_hero_axe", duration=5.0})
  Notifications:TopToAll({hero="npc_dota_hero_axe", imagestyle="landscape", continue=true})
  Notifications:TopToAll({hero="npc_dota_hero_axe", imagestyle="portrait", continue=true})

  -- 显示一个通用图像，然后在同一行显示2个技能图标和一个物品，持续5秒钟
  Notifications:TopToAll({image="file://{images}/status_icons/dota_generic.psd", duration=5.0})
  Notifications:TopToAll({ability="nyx_assassin_mana_burn", continue=true})
  Notifications:TopToAll({ability="lina_fiery_soul", continue=true})
  Notifications:TopToAll({item="item_force_staff", continue=true})


  -- 向天辉队(GOODGUYS)所有玩家发送一个在屏幕底部显示10秒钟的通知，使用NotificationMessage类显示
  Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, {text="AAAAAAAAAAAAAA", duration=10, class="NotificationMessage"})
  -- 向玩家0发送一个在底部显示的大红色通知，带有蓝色实线边框，持续5秒钟
  Notifications:Bottom(PlayerResource:GetPlayer(0), {text="超大红色文本", duration=5, style={color="red", ["font-size"]="110px", border="10px solid blue"}})


  -- 2秒后移除1个底部和2个顶部通知
  Timers:CreateTimer(2,function()
    Notifications:RemoveTop(0, 2)
    Notifications:RemoveBottomFromTeam(DOTA_TEAM_GOODGUYS, 1)

    -- 在底部添加1个新通知
    Notifications:BottomToAll({text="再次显示绿色文本", duration=9, style={color="green"}})
  end)

  -- 清除底部的所有通知
  Timers:CreateTimer(7, function()
    Notifications:ClearBottomFromAll()
  end)
]]

if Notifications == nil then
  Notifications = class({})
end

function Notifications:ClearTop(player)
  Notifications:RemoveTop(player, 50)
end

function Notifications:ClearBottom(player)
  Notifications:RemoveBottom(player, 50)
end

function Notifications:ClearTopFromAll()
  Notifications:RemoveTopFromAll(50)
end

function Notifications:ClearBottomFromAll()
  Notifications:RemoveBottomFromAll(50)
end

function Notifications:ClearTopFromTeam(team)
  Notifications:RemoveTopFromTeam(team, 50)
end

function Notifications:ClearBottomFromTeam(team)
  Notifications:RemoveBottomFromTeam(team, 50)
end


function Notifications:RemoveTop(player, count)
  if type(player) == "number" then
    player = PlayerResource:GetPlayer(player)
  end

  CustomGameEventManager:Send_ServerToPlayer(player, "top_remove_notification", {count=count} )
end

function Notifications:RemoveBottom(player, count)
  if type(player) == "number" then
    player = PlayerResource:GetPlayer(player)
  end

  CustomGameEventManager:Send_ServerToPlayer(player, "bottom_remove_notification", {count=count})
end

function Notifications:RemoveTopFromAll(count)
  CustomGameEventManager:Send_ServerToAllClients("top_remove_notification", {count=count} )
end

function Notifications:RemoveBottomFromAll(count)
  CustomGameEventManager:Send_ServerToAllClients("bottom_remove_notification", {count=count})
end

function Notifications:RemoveTopFromTeam(team, count)
  CustomGameEventManager:Send_ServerToTeam(team, "top_remove_notification", {count=count} )
end

function Notifications:RemoveBottomFromTeam(team, count)
  CustomGameEventManager:Send_ServerToTeam(team, "bottom_remove_notification", {count=count})
end


function Notifications:Top(player, table)
  if type(player) == "number" then
    player = PlayerResource:GetPlayer(player)
  end

  if table.text ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "top_notification", {text=table.text, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.hero ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "top_notification", {hero=table.hero, imagestyle=table.imagestyle, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.image ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "top_notification", {image=table.image, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.ability ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "top_notification", {ability=table.ability, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.item ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "top_notification", {item=table.item, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  else
    CustomGameEventManager:Send_ServerToPlayer(player, "top_notification", {text="No TEXT provided.", duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  end
end

function Notifications:TopToAll(table)
  if table.text ~= nil then
    CustomGameEventManager:Send_ServerToAllClients("top_notification", {text=table.text, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.hero ~= nil then
    CustomGameEventManager:Send_ServerToAllClients("top_notification", {hero=table.hero, imagestyle=table.imagestyle, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.image ~= nil then
    CustomGameEventManager:Send_ServerToAllClients("top_notification", {image=table.image, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.ability ~= nil then
    CustomGameEventManager:Send_ServerToAllClients("top_notification", {ability=table.ability, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.item ~= nil then
    CustomGameEventManager:Send_ServerToAllClients("top_notification", {item=table.item, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  else
    CustomGameEventManager:Send_ServerToAllClients("top_notification", {text="No TEXT provided.", duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  end
end

function Notifications:TopToTeam(team, table)
  if table.text ~= nil then
    CustomGameEventManager:Send_ServerToTeam(team, "top_notification", {text=table.text, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.hero ~= nil then
    CustomGameEventManager:Send_ServerToTeam(team, "top_notification", {hero=table.hero, imagestyle=table.imagestyle, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.image ~= nil then
    CustomGameEventManager:Send_ServerToTeam(team, "top_notification", {image=table.image, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.ability ~= nil then
    CustomGameEventManager:Send_ServerToTeam(team, "top_notification", {ability=table.ability, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.item ~= nil then
    CustomGameEventManager:Send_ServerToTeam(team, "top_notification", {item=table.item, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  else
    CustomGameEventManager:Send_ServerToTeam(team, "top_notification", {text="No TEXT provided.", duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  end
end


function Notifications:Bottom(player, table)
  if type(player) == "number" then
    player = PlayerResource:GetPlayer(player)
  end

  if table.text ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "bottom_notification", {text=table.text, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.hero ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "bottom_notification", {hero=table.hero, imagestyle=table.imagestyle, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.image ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "bottom_notification", {image=table.image, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.ability ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "bottom_notification", {ability=table.ability, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.item ~= nil then
    CustomGameEventManager:Send_ServerToPlayer(player, "bottom_notification", {item=table.item, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  else
    CustomGameEventManager:Send_ServerToPlayer(player, "bottom_notification", {text="No TEXT provided.", duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  end
end

function Notifications:BottomToAll(table)
  if table.text ~= nil then
    CustomGameEventManager:Send_ServerToAllClients("bottom_notification", {text=table.text, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.hero ~= nil then
    CustomGameEventManager:Send_ServerToAllClients("bottom_notification", {hero=table.hero, imagestyle=table.imagestyle, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.image ~= nil then
    CustomGameEventManager:Send_ServerToAllClients("bottom_notification", {image=table.image, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.ability ~= nil then
    CustomGameEventManager:Send_ServerToAllClients("bottom_notification", {ability=table.ability, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.item ~= nil then
    CustomGameEventManager:Send_ServerToAllClients("bottom_notification", {item=table.item, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  else
    CustomGameEventManager:Send_ServerToAllClients("bottom_notification", {text="No TEXT provided.", duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  end
end

function Notifications:BottomToTeam(team, table)
  if table.text ~= nil then
    CustomGameEventManager:Send_ServerToTeam(team, "bottom_notification", {text=table.text, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.hero ~= nil then
    CustomGameEventManager:Send_ServerToTeam(team, "bottom_notification", {hero=table.hero, imagestyle=table.imagestyle, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.image ~= nil then
    CustomGameEventManager:Send_ServerToTeam(team, "bottom_notification", {image=table.image, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.ability ~= nil then
    CustomGameEventManager:Send_ServerToTeam(team, "bottom_notification", {ability=table.ability, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  elseif table.item ~= nil then
    CustomGameEventManager:Send_ServerToTeam(team, "bottom_notification", {item=table.item, duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  else
    CustomGameEventManager:Send_ServerToTeam(team, "bottom_notification", {text="No TEXT provided.", duration=table.duration, class=table.class, style=table.style, continue=table.continue} )
  end
end