function OnLocalizedMessage(data) {
    // 调试输出
    let messageParts = data.message_parts;

    let renderedMessage = renderMessage(messageParts);
    let timeStamp = getCurrentTimeWithMilliseconds();
    
    let finalMessage = renderedMessage.replace("[LanPang_RECORD]", "[LanPang_RECORD][" + timeStamp + "]");
    
    $.Msg(finalMessage);
}

function renderMessage(messageParts) {
    let parts = [];
    
    if (Array.isArray(messageParts)) {
        parts = messageParts;
    } else {
        for (let key in messageParts) {
            if (messageParts.hasOwnProperty(key)) {
                parts.push(messageParts[key]);
            }
        }
    }
    
    parts.sort((a, b) => a.index - b.index);


    return parts.map(part => {
        if (!part.localize) {
            return part.text;
        }

        if (part.facetInfo) {
            let localizedText = "Unknown Facet";
            const facetToken = "#DOTA_Tooltip_Facet_" + part.facetInfo.facetName;
            if (part.facetInfo.facetName) {
                // 优先尝试Facet本地化

                localizedText = $.Localize(facetToken);
                
                // 其次尝试用facetName进行Ability本地化
                if (localizedText === facetToken) {
                    const abilityTokenWithName = "#DOTA_Tooltip_Ability_" + part.facetInfo.facetName;
                    localizedText = $.Localize(abilityTokenWithName);
                }
            }
            
            // 最后尝试用abilityName进行Ability本地化
            if ((localizedText === facetToken || !part.facetInfo.facetName) && part.facetInfo.abilityName) {
                const abilityTokenWithAbilityName = "#DOTA_Tooltip_Ability_" + part.facetInfo.abilityName;
                localizedText = $.Localize(abilityTokenWithAbilityName);
            }
            
            return localizedText;
        }

        const localizedText = $.Localize('#' + part.text);
        return localizedText;
    }).join('');
}


function getCurrentTimeWithMilliseconds() {
    var date = new Date();
    var formattedTime = date.getHours().toString().padStart(2, '0') + ':' +
                        date.getMinutes().toString().padStart(2, '0') + ':' +
                        date.getSeconds().toString().padStart(2, '0') + '.' +
                        date.getMilliseconds().toString().padStart(3, '0');
    return formattedTime;
}

// 注册事件监听器
GameEvents.Subscribe("localized_message", OnLocalizedMessage);

// 添加初始化消息
$.Msg("Localized message script initialized");