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
            
            if (part.facetInfo.facetName) {
                const facetToken = "#DOTA_Tooltip_Facet_" + part.facetInfo.facetName;
                const facetLocalized = $.Localize(facetToken);
                
                if (facetLocalized !== facetToken) {
                    return facetLocalized;
                }
            }
            
            if (part.facetInfo.abilityName) {
                const abilityToken = "#DOTA_Tooltip_Ability_" + part.facetInfo.abilityName;
                const abilityLocalized = $.Localize(abilityToken);
                return abilityLocalized;
            }
            
            return "Unknown Facet";
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