GameEvents.Subscribe("send_item_list", onReceiveItemList);
let itemSelectionDialogInitialized = false;
function onReceiveItemList(event) {
    let allItems = [];

    if (event && event.items) {
        if (typeof event.items === 'object' && !Array.isArray(event.items)) {
            allItems = Object.values(event.items);
        } else if (Array.isArray(event.items)) {
            allItems = event.items;
        }
    }

    if (allItems.length > 0) {
        itemList = {
            NeutralItems: [],
            NormalItems: [],
            CustomItems: [],
            SpecialItems: []
        };

        // 修改排序函数
        const sortItems = (items) => {
            return items.sort((a, b) => {
                // 如果两个物品都有价格，按价格排序（从高到低）
                if (a.cost && b.cost) {
                    return b.cost - a.cost;
                }
                // 如果只有一个物品有价格，有价格的排在前面
                if (a.cost) return -1;
                if (b.cost) return 1;
                // 如果都没有价格，按名字排序
                const nameA = a.name || '';
                const nameB = b.name || '';
                if (nameA < nameB) return -1;
                if (nameA > nameB) return 1;
                return 0;
            });
        };

        // 分类物品
        allItems.forEach(item => {
            if (item.isNeutralDrop) {
                itemList.NeutralItems.push(item);
            } else if (item.isCustomItem) {
                itemList.CustomItems.push(item);
            } else if (item.isSpecialItem) {
                itemList.SpecialItems.push(item);
            } else {
                itemList.NormalItems.push(item);
            }
        });

        // 对每个分类进行排序
        itemList.NeutralItems = sortItems(itemList.NeutralItems);
        itemList.NormalItems = sortItems(itemList.NormalItems);
        itemList.CustomItems = sortItems(itemList.CustomItems);
        itemList.SpecialItems = sortItems(itemList.SpecialItems);

        itemDataRequested = false;
    }
    initializeItemSelectionDialog();
}


function initializeItemSelectionDialog() {
    if (itemSelectionDialogInitialized) {
        return;  // 已经初始化，避免重复创建
    }
    itemSelectionDialogInitialized = true;

    const grids = ['NormalItemsGrid', 'NeutralItemsGrid', 'CustomItemsGrid', 'SpecialItemsGrid'];
    grids.forEach(gridId => {
        const grid = $(`#${gridId}`);
        if (!grid) {
            $.Msg(`Error: ${gridId} not found`);
            return;
        }
        // 创建物品条目
        const items = itemList[gridId.replace('Grid', '')];
        if (items) {
            items.forEach(item => createItemEntry(item, grid));
        }
    });
}

function createItemEntry(item, itemGrid) {
    if (!itemGrid) {
        $.Msg("Error: itemGrid is null in createItemEntry");
        return;
    }

    const itemEntry = $.CreatePanel('Panel', itemGrid, '');
    itemEntry.AddClass('ItemEntry');

    const itemIcon = $.CreatePanel('DOTAItemImage', itemEntry, '');
    itemIcon.AddClass('ItemIcon');
    itemIcon.itemname = item.name;

    const itemNameLabel = $.CreatePanel('Label', itemEntry, '');
    itemNameLabel.AddClass('ItemName');
    itemNameLabel.text = $.Localize(`#DOTA_Tooltip_ability_${item.name}`);

    // 添加价格标签（如果有价格）
    if (item.cost > 0) {
        const costLabel = $.CreatePanel('Label', itemEntry, '');
        costLabel.AddClass('ItemCost');
        costLabel.text = item.cost;
    }

    const quantityEntry = $.CreatePanel('TextEntry', itemEntry, '');
    quantityEntry.AddClass('ItemQuantityEntry');
    quantityEntry.SetAttributeString('itemName', item.name);
    quantityEntry.SetAttributeString('itemId', item.id);
    quantityEntry.text = '0';

    itemEntry.quantityEntry = quantityEntry;

    return itemEntry;
}