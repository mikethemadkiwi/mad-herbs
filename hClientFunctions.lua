-- THIS IS MY INVENTORY CORE STUFF. REPLACE IT WITH YOURS --
MK = exports["mad-core"]:Get()
AddEventHandler("mad:cl_onOutdated", function()
	MK = exports["mad-core"]:Get()
end)
function GetInventoryItemGuid(item, pGuid, slotId)
	local outGuid = DataView.ArrayBuffer(8 * 13)
	local result = Citizen.InvokeNative(0x886DFD3E185C8A89, 1, pGuid, item, slotId, outGuid:Buffer(), Citizen.ResultAsInteger());
    if result ~= 1 then
        return nil
    end
	return outGuid:Buffer();
end
function GetCharacterInventoryGuid()
    return GetInventoryItemGuid(`CHARACTER`, 0, `SLOTID_NONE`)
end
function GetWardrobeInventoryGuid()
    return GetInventoryItemGuid(`WARDROBE`, GetCharacterInventoryGuid(), `SLOTID_WARDROBE`)
end
function GetWeaponInventoryGuid()
    return GetInventoryItemGuid(`CARRIED_WEAPONS`, GetCharacterInventoryGuid(), `SLOTID_CARRIED_WEAPONS`)
end
function GetItemGroup(item)
	local info = DataView.ArrayBuffer(8 * 7)
    info:SetInt32(0, 0)
    info:SetInt32(8, 0)
    info:SetInt32(16, 0)
    info:SetInt32(24, 0)
    info:SetInt32(32, 0)
    info:SetInt32(40, 0)
    info:SetInt32(48, 0)
	if false == Citizen.InvokeNative(0xFE90ABBCBFDC13B2, item, info:Buffer()) then
		return 0
    end
	return info:GetInt32(16);
end
function GetItemInventoryInfo(item)
    local inventoryGuid = GetCharacterInventoryGuid()
    local slotId = `SLOTID_SATCHEL`
    local group = GetItemGroup(item)
    if group == `WEAPON` then
        inventoryGuid = GetWeaponInventoryGuid()
        slotId = `SLOTID_WEAPON_0`        
    elseif group == `CLOTHING` then
        inventoryGuid = GetWardrobeInventoryGuid()
        slotId = `SLOTID_WARDROBE_LOADOUT_1`
    elseif group == `UPGRADE` then
        if InventoryFitsSlotId(item, `SLOTID_UPGRADE`) == 1 then
            slotId = `SLOTID_UPGRADE`
        end
    elseif group == `HORSE` then
        slotId = `SLOTID_ACTIVE_HORSE` -- Unresearched area
    else
        if InventoryFitsSlotId(item, `SLOTID_SATCHEL`) == 1 then
            slotId = `SLOTID_SATCHEL`
        elseif InventoryFitsSlotId(item, `SLOTID_WARDROBE`) == 1 then
            slotId = `SLOTID_WARDROBE`
        elseif InventoryFitsSlotId(item, `SLOTID_CURRENCY`) == 1 then
            slotId = `SLOTID_CURRENCY`
        elseif InventoryFitsSlotId(item, `SLOTID_PROGRESSION`) == 1 then
            slotId = `SLOTID_PROGRESSION`
        else
            slotId = GetDefaultItemSlotInfo(item, `CHARACTER`)            
        end
    end
    return inventoryGuid, slotId
end
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER CUSTOMIZED FUNCTIONS. THESE ARE CORE SPECIFIC, ADD YOUR FRAMEWORK HERE
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
-- Give Item from Picking Trees.
function PickFruitTree(volName, treeInfo)
    -- caLC XP
    if treeInfo[7] ~= -1 then
        local rewardData = GetHashKey(treeInfo[7])
        local max = 0
        local count = 0
        if MK.Satchel then
            count = MK.Satchel.GetItemCount(rewardData)
            max = MK.Satchel.GetItemMaxCount(rewardData)
            if count < max then
                -- TriggerServerEvent("mad:sv_giveMoney", GetPlayerName(PlayerId()), 1)
                MK.Satchel.AddItem(rewardData, 1)
            else
                print('You have too Many: ', treeInfo[7])
            end
        end

    end
end
-- give custom items from the custom trees
function PickCustomTree(volName, treeInfo, rewardData)
    local max = 0
    local count = 0
    if MK.Satchel then
        count = MK.Satchel.GetItemCount(rewardData)
        max = MK.Satchel.GetItemMaxCount(rewardData)
        if count < max then
            TriggerServerEvent("mad:sv_giveMoney", GetPlayerName(PlayerId()), 1)
            MK.Satchel.AddItem(rewardData, 1)
        end
    end
end
-- Give items on citrus pick.
function PickCitrusTree(citrus)
    TriggerServerEvent("mad:sv_giveMoney", GetPlayerName(PlayerId()), 0.05)
end
-- checks if the player has a moonshine item.
function MoonshineCheck()
    return MoonshineItem
end
function CollectorCheck()
    if MK.Satchel then
        local permnumber = MK.Satchel.SatchelGetUnlock(-1733092640)
        return permnumber
    end
end
function PuchasedCollectorBag()
    if MK.Satchel then
        if MK.Satchel.SatchelGetUnlock(-1733092640)>0 then return false end
        MK.Satchel.AddPermItem(-1733092640, 1)
        MK.Satchel.AddItem(-1733092640, 1)
    end
end
function CanAfford(amount)
    local cashfromdisplayamount = (amount /100)
    local cAff = false
    -- check your framework for playercash
    if MK.GetPlayerMoney() > cashfromdisplayamount then
        cAff = true
    end
    --
    return cAff
end
-- what to do when selling a collection, remove 1 of each item.
function PlayerCollectionTrigger(RareHerbHashes, collectionprice)
    -- iterate thru hash table removing one of each item.
    for i=1, #RareHerbHashes do
        local inventoryGuid, slotId = GetItemInventoryInfo(RareHerbHashes[i])
        local itemGuid = GetInventoryItemGuid(RareHerbHashes[i], inventoryGuid, slotId)  
        local removed = Citizen.InvokeNative(0x3E4E811480B3AE79, 1, itemGuid, 1, `REMOVE_REASON_DEFAULT`)
        print('removed =', removed, RareHerbHashes[i])
    end
    TriggerServerEvent("mad:sv_giveMoney", GetPlayerName(PlayerId()), collectionprice)
end