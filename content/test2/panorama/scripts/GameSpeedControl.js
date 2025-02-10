const slowMotionCmdName = "CustomGameSlowMotion" + Math.floor(Math.random() * 99999999);
const normalSpeedCmdName = "CustomGameNormalSpeed" + Math.floor(Math.random() * 99999999);
const printMousePosCmdName = "CustomGamePrintMousePos" + Math.floor(Math.random() * 99999999);
const printUnitInfoCmdName = "CustomGamePrintUnitInfo" + Math.floor(Math.random() * 99999999);
const printNearbyUnitsInfoCmdName = "CustomGamePrintNearbyUnitsInfo" + Math.floor(Math.random() * 99999999);

function OnSlowMotionPressed() {
    Game.EmitSound("ui_generic_button_click");
    GameEvents.SendCustomGameEventToServer("SetTimescale", { timescale: 0.1 });
}

function OnNormalSpeedPressed() {
    Game.EmitSound("ui_generic_button_click");
    GameEvents.SendCustomGameEventToServer("SetTimescale", { timescale: 1 });
}

function OnPrintMousePosPressed() {
    var cursorPos = GameUI.GetCursorPosition();
    if (!cursorPos) {
        $.Msg("无法获取光标位置。");
        return;
    }

    var worldPos = GameUI.GetScreenWorldPosition(cursorPos);

    if (worldPos) {
        $.Msg("游戏世界坐标：X: " + worldPos[0].toFixed(2) + ", Y: " + worldPos[1].toFixed(2) + ", Z: " + worldPos[2].toFixed(2));
    } else {
        $.Msg("无法获取当前光标位置的游戏世界坐标。");
    }
}

function OnPrintUnitInfoPressed() {
    var selectedEntities = Players.GetSelectedEntities(Players.GetLocalPlayer());
    if (selectedEntities.length === 0) {
        $.Msg("没有选中任何单位。");
        return;
    }

    var unitEntIndex = selectedEntities[0];
    GameEvents.SendCustomGameEventToServer("request_unit_info", { unit_ent_index: unitEntIndex });
}

function OnPrintNearbyUnitsInfoPressed() {
    var cursorPos = GameUI.GetCursorPosition();
    if (!cursorPos) {
        $.Msg("无法获取光标位置。");
        return;
    }

    var worldPos = GameUI.GetScreenWorldPosition(cursorPos);
    if (!worldPos) {
        $.Msg("无法获取当前光标位置的游戏世界坐标。");
        return;
    }

    // 发送请求给服务器，要求获取附近单位信息
    GameEvents.SendCustomGameEventToServer("request_nearby_units_info", { 
        position_x: worldPos[0],
        position_y: worldPos[1],
        position_z: worldPos[2]
    });

}

GameEvents.Subscribe("response_unit_info", OnReceiveUnitInfo);
GameEvents.Subscribe("response_nearby_units_info", OnReceiveNearbyUnitsInfo);

function OnReceiveUnitInfo(data) {
    var unitName = data.unit_name;
    var modifiers = data.modifiers;
    var ownerPlayerID = data.owner_player_id;
    var teamNumber = data.team_number;
    var facetID = data.facet_id;
    var isHero = data.is_hero;
    var isTrueHero = data.is_true_hero;
    var isIllusion = data.is_illusion;
    var isSummoned = data.is_summoned;
    var childUnits = data.child_units;

    var teamName = teamNumber === 2 ? "天辉" : teamNumber === 3 ? "夜魇" : "其他";

    $.Msg("单位信息：");
    $.Msg("单位名称：" + unitName);
    $.Msg("拥有的modifier：");
    
    $.Msg("Debug: Modifiers data type: " + typeof modifiers);
    $.Msg("Debug: Modifiers content: ", JSON.stringify(modifiers));

    if (Array.isArray(modifiers)) {
        for (var i = 0; i < modifiers.length; i++) {
            var modifier = modifiers[i];
            $.Msg("  - 名称：" + modifier.name);
            $.Msg("    层数：" + modifier.stack_count);
            $.Msg("    剩余时间：" + (modifier.remaining_time >= 0 ? modifier.remaining_time.toFixed(2) + " 秒" : "永久"));
            $.Msg("    总持续时间：" + (modifier.duration > 0 ? modifier.duration.toFixed(2) + " 秒" : "永久"));
        }
    } else if (typeof modifiers === 'object') {
        for (var key in modifiers) {
            var modifier = modifiers[key];
            $.Msg("  - 名称：" + modifier.name);
            $.Msg("    层数：" + modifier.stack_count);
            $.Msg("    剩余时间：" + (modifier.remaining_time >= 0 ? modifier.remaining_time.toFixed(2) + " 秒" : "永久"));
            $.Msg("    总持续时间：" + (modifier.duration > 0 ? modifier.duration.toFixed(2) + " 秒" : "永久"));
        }
    } else {
        $.Msg("No modifiers found or invalid modifier data");
    }

    $.Msg("隶属玩家：" + (ownerPlayerID + 1));
    $.Msg("所属阵营：" + teamName);
    $.Msg("FacetID：" + (facetID !== undefined ? facetID : "N/A"));
    
    $.Msg("是否为英雄：" + (isHero ? "是" : "否"));
    $.Msg("是否为真实英雄：" + (isTrueHero ? "是" : "否"));
    $.Msg("是否为幻象：" + (isIllusion ? "是" : "否"));
    $.Msg("是否为召唤物：" + (isSummoned ? "是" : "否"));

    // Print child units information
    if (childUnits && childUnits.length > 0) {
        $.Msg("子单位信息：");
        for (var i = 0; i < childUnits.length; i++) {
            var child = childUnits[i];
            $.Msg("  - 名称：" + child.name);
            $.Msg("    实体索引：" + child.ent_index);
            $.Msg("    是否为召唤物：" + (child.is_summoned ? "是" : "否"));
        }
    } else {
        $.Msg("无子单位");
    }
}

function OnReceiveNearbyUnitsInfo(data) {
    if (!data.units || data.units.length === 0) {
        $.Msg("鼠标附近没有找到任何单位。");
        return;
    }

    $.Msg("鼠标附近的单位信息：");
    $.Msg("发现 " + data.units.length + " 个单位");
    
    for (var i = 0; i < data.units.length; i++) {
        var unit = data.units[i];
        var teamName = unit.team_number === 2 ? "天辉" : unit.team_number === 3 ? "夜魇" : "其他";
        
        $.Msg("\n单位 #" + (i + 1) + "：");
        $.Msg("单位名称：" + unit.unit_name);
        $.Msg("所属阵营：" + teamName);
        $.Msg("隶属玩家：" + (unit.owner_player_id + 1));
        if (unit.facet_id !== undefined) {
            $.Msg("FacetID：" + unit.facet_id);
        }
    }
}

(function() {
    Game.AddCommand(slowMotionCmdName, OnSlowMotionPressed, "", 0);
    Game.AddCommand(normalSpeedCmdName, OnNormalSpeedPressed, "", 0);
    Game.AddCommand(printMousePosCmdName, OnPrintMousePosPressed, "", 0);
    Game.AddCommand(printUnitInfoCmdName, OnPrintUnitInfoPressed, "", 0);
    Game.AddCommand(printNearbyUnitsInfoCmdName, OnPrintNearbyUnitsInfoPressed, "", 0);

    Game.CreateCustomKeyBind("MOUSE4", slowMotionCmdName);
    Game.CreateCustomKeyBind("MOUSE5", normalSpeedCmdName);
    Game.CreateCustomKeyBind("KP_0", printMousePosCmdName);
    Game.CreateCustomKeyBind("KP_1", printUnitInfoCmdName);
    Game.CreateCustomKeyBind("KP_2", printNearbyUnitsInfoCmdName);
})();