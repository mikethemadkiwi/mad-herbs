local deliverySleep = 1000
local missionSleep = 1000
local activeDelivery = nil
local MissionNpc = nil
local MissionBlip = nil
local MissionRoute = nil
local MissionVehicle = nil
local MissionTick = 240000
local MissionCD = 0
local MissionNPCBlips = {}
local MissionText = nil
local MissionTextCenter = nil
local DraftHorseId = nil
local MissionTimeOutOfCart = 0
local FruitScores = {}
local lastItem = -1
local menuItem = 1
local menuTab = 1
local itemSet = CreateItemset(1)
local UIAppHash = 1833066477
local UIAppListen = false
local buttonNameHash = GetHashKey("IB_ACCEPT")
local DataBind = {}
local UIItemList = {}
-- { DELIVERYDATE, DELIVERYSTARTVEC, DELIVERYSTOPVEC, DELIVERY DETAILS}
----------------
local SupplierPromptGroup = GetRandomIntInRange(25500, 0xffffff)
local EndPromptGroup = GetRandomIntInRange(25500, 0xffffff)
local MissionPromptGroup = GetRandomIntInRange(25500, 0xffffff)
Citizen.CreateThread(function()    

	Prompt_SupplierLabel  = CreateVarString(10, 'LITERAL_STRING', "Fruit Supplier")
	Prompt_SupplierString = CreateVarString(10, 'LITERAL_STRING', 'Talk')
	Prompt_Supplier = PromptRegisterBegin()
	PromptSetControlAction(Prompt_Supplier, 0x760A9C6F)
	PromptSetText(Prompt_Supplier, Prompt_SupplierString)
	PromptSetEnabled(Prompt_Supplier, true)
	PromptSetVisible(Prompt_Supplier, true)
	PromptSetHoldMode(Prompt_Supplier, 1)
	PromptSetGroup(Prompt_Supplier, SupplierPromptGroup)
	PromptRegisterEnd(Prompt_Supplier)
    
	Prompt_MissionLabel  = CreateVarString(10, 'LITERAL_STRING', "Fruit Supplier")
	Prompt_MissionString = CreateVarString(10, 'LITERAL_STRING', 'Begin Delivery')
	Prompt_Mission = PromptRegisterBegin()
	PromptSetControlAction(Prompt_Mission, 0x760A9C6F)
	PromptSetText(Prompt_Mission, Prompt_MissionString)
	PromptSetEnabled(Prompt_Mission, true)
	PromptSetVisible(Prompt_Mission, true)
	PromptSetHoldMode(Prompt_Mission, 1)
	PromptSetGroup(Prompt_Mission, MissionPromptGroup)
	PromptRegisterEnd(Prompt_Mission)
    
	Prompt_EndLabel  = CreateVarString(10, 'LITERAL_STRING', "Fruit Supplier")
	Prompt_EndString = CreateVarString(10, 'LITERAL_STRING', 'Deliver Goods')
	Prompt_End = PromptRegisterBegin()
	PromptSetControlAction(Prompt_End, 0x760A9C6F)
	PromptSetText(Prompt_End, Prompt_EndString)
	PromptSetEnabled(Prompt_End, true)
	PromptSetVisible(Prompt_End, true)
	PromptSetHoldMode(Prompt_End, 1)
	PromptSetGroup(Prompt_End, EndPromptGroup)
	PromptRegisterEnd(Prompt_End)

    -- Blips
    CreateNPCBlip("BayouNwaNPC", FruitDelivery.BayouNwaNPC.x, FruitDelivery.BayouNwaNPC.y, FruitDelivery.BayouNwaNPC.z, "Fruit Supplier", "BLIP_STYLE_MISSION", "blip_ambient_vip")
    CreateNPCBlip("CalligaNPC", FruitDelivery.CalligaNPC.x, FruitDelivery.CalligaNPC.y, FruitDelivery.CalligaNPC.z, "Fruit Supplier", "BLIP_STYLE_MISSION", "blip_ambient_vip")
    CreateNPCBlip("BraithwaiteNPC", FruitDelivery.BraithwaiteNPC.x, FruitDelivery.BraithwaiteNPC.y, FruitDelivery.BraithwaiteNPC.z, "Fruit Supplier", "BLIP_STYLE_MISSION", "blip_ambient_vip")

end)
----------------
local FruitTabs = {}
FruitTabs.legal = {}
FruitTabs.legal[1] = {
    ["enabled"] = 1,
    ['textcolor'] = GetHashKey("COLOR_MENU_TEXT"),
    ["rawtext"] = "Deliver Oranges",
    ["price"] = FruitPrices.Legal[1], -- equates to $10.00
}
FruitTabs.legal[2] = {
    ["enabled"] = 1,
    ['textcolor'] = GetHashKey("COLOR_MENU_TEXT"),
    ["rawtext"] = "Deliver Lemons",
    ["price"] = FruitPrices.Legal[2], -- equates to $10.00
}
FruitTabs.legal[3] = {
    ["enabled"] = 1,
    ['textcolor'] = GetHashKey("COLOR_MENU_TEXT"),
    ["rawtext"] = "Deliver Apples",
    ["price"] = FruitPrices.Legal[3], -- equates to $10.00
}
FruitTabs.legal[4] = {
    ["enabled"] = 1,
    ['textcolor'] = GetHashKey("COLOR_MENU_TEXT"),
    ["rawtext"] = "Deliver Pears",
    ["price"] = FruitPrices.Legal[4], -- equates to $10.00
}
FruitTabs.legal[5] = {
    ["enabled"] = 1,
    ['textcolor'] = GetHashKey("COLOR_MENU_TEXT"),
    ["rawtext"] = "Deliver Peaches",
    ["price"] = FruitPrices.Legal[5], -- equates to $10.00
}
FruitTabs.illegal = {}
FruitTabs.illegal[1] = {
    ["enabled"] = 1,
    ['textcolor'] = GetHashKey("COLOR_MENU_TEXT"),
    ["rawtext"] = "Deliver Oranges",
    ["price"] = FruitPrices.Illegal[1], -- equates to $10.00
}
FruitTabs.illegal[2] = {
    ["enabled"] = 1,
    ['textcolor'] = GetHashKey("COLOR_MENU_TEXT"),
    ["rawtext"] = "Deliver Lemons",
    ["price"] = FruitPrices.Illegal[2], -- equates to $10.00
}
FruitTabs.illegal[3] = {
    ["enabled"] = 1,
    ['textcolor'] = GetHashKey("COLOR_MENU_TEXT"),
    ["rawtext"] = "Deliver Apples",
    ["price"] = FruitPrices.Illegal[3], -- equates to $10.00
}
FruitTabs.illegal[4] = {
    ["enabled"] = 1,
    ['textcolor'] = GetHashKey("COLOR_MENU_TEXT"),
    ["rawtext"] = "Deliver Pears",
    ["price"] = FruitPrices.Illegal[4], -- equates to $10.00
}
FruitTabs.illegal[5] = {
    ["enabled"] = 1,
    ['textcolor'] = GetHashKey("COLOR_MENU_TEXT"),
    ["rawtext"] = "Deliver Peaches",
    ["price"] = FruitPrices.Illegal[5], -- equates to $10.00
}
----------------
function UpdateDeliveryScores(pScores)
    activeDelivery = pScores.activeDeliveries
    -- print('oranges', pScores.BayouNwaScores.oranges.value)
    if pScores.BayouNwaScores.oranges.value < 20 then
        FruitTabs.legal[1].enabled = 0
        FruitTabs.illegal[1].enabled = 0
    else
        FruitTabs.legal[1].enabled = 1
        FruitTabs.illegal[1].enabled = 1
    end
    -- print('lemons', pScores.BayouNwaScores.lemons.value)
    if  pScores.BayouNwaScores.lemons.value < 20 then
        FruitTabs.legal[2].enabled = 0
        FruitTabs.illegal[2].enabled = 0
    else
        FruitTabs.legal[2].enabled = 1
        FruitTabs.illegal[2].enabled = 1
    end
    -- print('apples', pScores.BraithwaiteScores.apples.value)
    if  pScores.BraithwaiteScores.apples.value < 20 then
        FruitTabs.legal[3].enabled = 0
        FruitTabs.illegal[3].enabled = 0
    else
        FruitTabs.legal[3].enabled = 1
        FruitTabs.illegal[3].enabled = 1
    end
    -- print('pears', pScores.BraithwaiteScores.pears.value)
    if  pScores.BraithwaiteScores.pears.value < 20 then
        FruitTabs.legal[4].enabled = 0
        FruitTabs.illegal[4].enabled = 0
    else
        FruitTabs.legal[4].enabled = 1
        FruitTabs.illegal[4].enabled = 1
    end
    -- print('peaches', pScores.CalligaHallScores.peaches.value)
    if  pScores.CalligaHallScores.peaches.value < 20 then
        FruitTabs.legal[5].enabled = 0
        FruitTabs.illegal[5].enabled = 0
    else
        FruitTabs.legal[5].enabled = 1
        FruitTabs.illegal[5].enabled = 1
    end
end
----------------
----------------
function CreateBigInt(text)
    local string1 = DataView.ArrayBuffer(16)
    string1:SetInt64(0, text)
    return string1:GetInt64(0)
end
--
function NotifyCenter(text, duration, text_color)
    local structConfig = DataView.ArrayBuffer(8 * 7)
    structConfig:SetInt32(8 * 0, tonumber(duration or 3000))
    local structData = DataView.ArrayBuffer(8 * 4)
    structData:SetInt64(8 * 1, CreateBigInt(VarString(10, "LITERAL_STRING", text)))
    structData:SetInt64(8 * 2, CreateBigInt(joaat(text_color or "COLOR_PURE_WHITE")))
    Citizen.InvokeNative(0x893128CDB4B81FBB, structConfig:Buffer(), structData:Buffer(), 1)
end
function NotifyBottomRight(text, duration)
  local structConfig = DataView.ArrayBuffer(8 * 7)
  structConfig:SetInt32(8 * 0, tonumber(duration or 3000))
  local structData = DataView.ArrayBuffer(8 * 5)
  structData:SetInt64(8 * 1, CreateBigInt(VarString(10, "LITERAL_STRING", text)))
  Citizen.InvokeNative(0x2024F4F333095FB1, structConfig:Buffer(), structData:Buffer(), 1)
end
--
local function LoadModel(modelid)
    if not IsModelInCdimage(modelid) then
        print("invalid model")
        return
    end
    if not HasModelLoaded(modelid) then
        RequestModel(modelid, false)
        repeat Wait(0) until HasModelLoaded(modelid)
    end
end
--
function createMissionBlip(Vectorx, Vectory, Vectorz, bliptxt, blipstyle, blipsprite)
    if MissionBlip == nil then
        MissionBlip = BlipAddForCoords(GetHashKey(blipstyle), Vectorx, Vectory, Vectorz)
        SetBlipSprite(MissionBlip, GetHashKey(blipsprite), true)
        SetBlipScale(MissionBlip, 0.2)
        SetBlipName(MissionBlip, bliptxt)
    end
end
--
function CreateNPCBlip(blipID, Vectorx, Vectory, Vectorz, bliptxt, blipstyle, blipsprite)
    if MissionNPCBlips[blipID] == nil then
        MissionNPCBlips[blipID] = BlipAddForCoords(GetHashKey(blipstyle), Vectorx, Vectory, Vectorz)
        SetBlipSprite(MissionNPCBlips[blipID], GetHashKey(blipsprite), true)
        SetBlipScale(MissionNPCBlips[blipID], 0.2)
        SetBlipName(MissionNPCBlips[blipID], bliptxt)
    end
end
--
function removeMissionBlip()
    if MissionBlip ~= nil then
        RemoveBlip(MissionBlip)
        MissionBlip = nil
    end          
end
--
function removeNPCBlip(blipID)
    if MissionNPCBlips[blipID] ~= nil then
        RemoveBlip(MissionNPCBlips[blipID])
        MissionNPCBlips[blipID] = nil
    end          
end
--
function CreateMissionRoute(dRoute)
    ClearGpsMultiRoute()
    Citizen.Wait(1)
    StartGpsMultiRoute(GetHashKey("COLOR_OBJECTIVE_ROUTE"), false, true)
    AddPointToGpsMultiRoute(dRoute.startVec.x, dRoute.startVec.y, dRoute.startVec.z, false)
    for i=1, #dRoute.routeList do
        AddPointToGpsMultiRoute(dRoute.routeList[i].x, dRoute.routeList[i].y, dRoute.routeList[i].z, false)
    end
    AddPointToGpsMultiRoute(dRoute.endVec.x, dRoute.endVec.y, dRoute.endVec.z, false)
    SetGpsMultiRouteRender(true)
    local missionDistance = GetGpsBlipRouteLength()
    TriggerServerEvent("mwg-herbs:missionDistance", missionDistance)
    MissionRoute = true
end
--
function DestroyMissionRoute()
    ClearGpsMultiRoute()
    ClearGpsCustomRoute()
    ClearGpsPlayerWaypoint()
    MissionRoute = nil
end
--

-- case joaat("HUNTERCART01"):
-- 			return joaat("COACH_TRADER");
-- 		case joaat("WAGONARMOURED01X"):
-- 			return joaat("COACH_BOUNTY_HUNTER");
-- 		default:
-- 			break;
function CreateMissionVehicle()
    LoadModel(FruitDelivery.vehicleHash)
    MissionVehicle = CreateVehicle(FruitDelivery.vehicleHash, activeDelivery[2].x, activeDelivery[2].y, activeDelivery[2].z, activeDelivery[2].w, true, true, false)
    repeat Wait(0) until DoesEntityExist(MissionVehicle)
    SetPlayerOwnsVehicle(PlayerPedId(), MissionVehicle)
    AddAdditionalPropSetForVehicle(MissionVehicle, GetHashKey("pg_mp005_huntingWagonTarp01"))
    AddLightPropSetToVehicle(MissionVehicle, GetHashKey("pg_veh_cart06_lanterns01"))
    SetBatchTarpHeight(MissionVehicle, 1.0, 1)
    -- create blip to track vehicle
    Citizen.InvokeNative(0x77FF8D35EEC6BBC4, MissionVehicle, 1, 0)
    SetPedIntoVehicle(PlayerPedId(), MissionVehicle, -1)
    SetModelAsNoLongerNeeded(FruitDelivery.vehicleHash)
    SetEntityAsNoLongerNeeded(MissionVehicle)
    if debugShow == true then
        print(MissionVehicle, DraftHorseId)
    end
end
--
function DestroyMissionVehicle()
    -- remove blip
    AddAdditionalPropSetForVehicle(MissionVehicle, 0)
    RemoveVehicleLightPropSets(MissionVehicle)
    -- FadeAndDestroyVehicle(MissionVehicle)

    ---
    DeleteEntity(MissionVehicle)
    DeleteEntity(DraftHorseId)
    MissionVehicle = nil
    DraftHorseId = nil
end
----------------
function ShowMissionHelperTextFields(Distance, Time)
    EnableHudContext(-66088566)
    local rootContainer = DatabindingAddDataContainerFromPath("", "helperTextfields")
    DatabindingAddDataString(rootContainer, "rawLabel0", "Distance:")
    DatabindingAddDataString(rootContainer, "rawValue0", Distance)
    DatabindingAddDataString(rootContainer, "rawLabel1", "Time:")
    DatabindingAddDataString(rootContainer, "rawValue1", Time)
end
----------------
function HideMissionHelperTextFields()
    DisableHudContext(-66088566)
end
----------------
----------------
-- buiild menu header
function BuildMenuHeader()
    ---
    local dbPresent = Citizen.InvokeNative("0x1E7130793AAAAB8D", DataBind[1])
    if not dbPresent then
        DataBind[1] =  DatabindingAddDataContainerFromPath("", "FastTravel");
    end
    local clearlist = Citizen.InvokeNative("0xA1F15C1D03DF802D", DataBind[2]); -- empties the locationlist databind
    DataBind[2] = Citizen.InvokeNative("0xFE74FA57E0CE6824", DataBind[1], "locationList");
    ---
    local header = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "header", "Fruit Supplier") 
    local subHeader = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "subHeader", "Legal Deliveries")
    local subFooter = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "subFooter", "")
    local subFooter2 = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "footer", "Select a delivery option.")
    if activeDelivery ~= nil then
        if activeDelivery[4] == 3 then
            local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "Cooldown: "..MissionCD.." seconds remaining.")
        else
            local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "You Have an Active Delivery. Go to the waypoint on your map to begin!")
        end
    else        
        local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", FruitDelivery.legalTxT)
    end
    BuildMenuTab(FruitTabs.legal, GetHashKey("COLOR_MENU_TEXT"))
    ---    
    UIAppListen = true
    Citizen.InvokeNative("0xC8FC7F4E4CF4F581", UIAppHash)
    Citizen.InvokeNative(0x4CC5F2FC1332577F ,GetHashKey("HUD_CTX_IN_FAST_TRAVEL_MENU"))
end
-- build the actual menu based on the tab
function BuildMenuTab(TabTable, TextColor)
    local clearlist = Citizen.InvokeNative("0xA1F15C1D03DF802D", DataBind[2]);
    for k = 1, #TabTable do
        local keySting = "deliveryoption_"..k
        local container = {}        
        container[1] = Citizen.InvokeNative("0xEB4F9A3537EEABCD", DataBind[2], keySting);
        if activeDelivery ~= nil then
            container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 0);
        else
            if menuTab == 2 then
                if MoonshineCheck() then
                    container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", TabTable[k].enabled);
                else
                    container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 0);
                end
            else
                container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", TabTable[k].enabled);
            end
        end
        container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 1);
        if menuTab == 2 then
            if MoonshineCheck() then
                container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", GetHashKey("COLOR_OBJECTIVE"));
            else
                container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", GetHashKey("COLOR_MENU_TEXT_ATTENTION"));
            end
        else
            container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", TextColor);
        end
        container[5] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_link", 0);
        container[6] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_event_channel_hash", UIAppHash);
        container[7] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_select_hash", UIAppHash);
        container[8] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_focus_hash", UIAppHash);
        container[9] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_prompt_text", buttonNameHash); --joaat("ib_select") text eq: "Travel"
        container[10] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_prompt_enabled", 0);
        container[11] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_prompt_visible", 0);
        container[13] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_prompt_option_select_hash", -1); 
        container[15] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_prompt_option_text", buttonNameHash); --joaat("ib_select") text eq: "Travel"
        container[16] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_prompt_option_enabled", 0);
        container[17] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_prompt_option_visible", 0);
        container[18] = Citizen.InvokeNative("0x617FCA1C5652BBAD", container[1], "dynamic_list_item_raw_text_entry", TabTable[k].rawtext)
        container[19] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_prompt_r3_text", buttonNameHash)
        container[20] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_prompt_toggle_text", buttonNameHash)                                    
        container[21] = Citizen.InvokeNative("0x307A3247C5457BDE", container[1], "dynamic_list_item_extra_int_field_one_value", TabTable[k].price)
        container[22] = Citizen.InvokeNative("0x307A3247C5457BDE", container[1], "dynamic_list_item_extra_int_field_two_value", TabTable[k].price)
        local INSERT2UILIST = Citizen.InvokeNative("0x5859E970794D92F3", DataBind[2], k, "ft_dynamic_text_and_price", container[1])
        UIItemList[k] = Citizen.InvokeNative("0x307A3247C5457BDE", container[1], "locationArrayIndex", k);
        if debugShow == true then
            print('menuitemcreate', menuTab, k)
        end
    end
end
function MenuClose()
    local header = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "header", "") 
    local subHeader = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "subHeader", "")
    local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "")
    local subFooter = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "subFooter", "")
    local subFooter = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "footer", "")
    local clearlist = Citizen.InvokeNative("0xA1F15C1D03DF802D", DataBind[2]);
    Citizen.InvokeNative("0xAD7B70F7230C5A12")
    Citizen.InvokeNative("0x0AE9938D0541F2DA", DataBind[1])
    UIAppListen = false
end
-- process selected menu to figure out which item and missioon type to run
function ProcessSelected(menuTab, menuItem, itemContainterID)
    TriggerServerEvent('mwg-herbs:RequestMission', {menuTab, menuItem, itemContainterID})
    if debugShow == true then
        print('herb request mission ', menuTab, menuItem, itemContainterID)
    end
end
-- Tab Page Increment UI Event
function tabPageIncrement()
    if menuTab >= 2 then
        menuTab = 1
    else
        menuTab = menuTab + 1
    end
    if menuTab == 1 then 
        local subHeader = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "subHeader", "Legal Deliveries")
        if activeDelivery ~= nil then        
            if activeDelivery[4] == 3 then
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "Cooldown: "..MissionCD.." seconds remaining.")
            else
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "You Have an Active Delivery. Go to the waypoint on your map to begin!")
            end
        else        
            local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", FruitDelivery.legalTxT)
        end
        BuildMenuTab(FruitTabs.legal, GetHashKey("COLOR_MENU_TEXT")) 
    elseif menuTab == 2 then 
        local subHeader = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "subHeader", "Illegal Deliveries")
        if activeDelivery ~= nil then        
            if activeDelivery[4] == 3 then
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "Cooldown: "..MissionCD.." seconds remaining.")
            else
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "You Have an Active Delivery. Go to the waypoint on your map to begin!")
            end
        else
            if MoonshineCheck() then
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", FruitDelivery.illegalTxT)
            else
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "You do not have the Moonshine Role. You Need it to Perform these Deliveries.")
            end
        end
        BuildMenuTab(FruitTabs.illegal, GetHashKey("COLOR_MENU_TEXT"))
    else 
        print('wtf?') 
    end    
    if debugShow == true then
        print('tabup', menuTab)
    end
    --
    local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", UIAppHash)
end
-- Tab Page Decrement UI Event
function tabPageDecrement()
    if menuTab <= 1 then
        menuTab = 2
    else
        menuTab = menuTab - 1
    end
    if menuTab == 1 then 
        local subHeader = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "subHeader", "Legal Deliveries")
        if activeDelivery ~= nil then        
            if activeDelivery[4] == 3 then
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "Cooldown: "..MissionCD.." seconds remaining.")
            else
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "You Have an Active Delivery. Go to the waypoint on your map to begin!")
            end
        else        
            local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", FruitDelivery.legalTxT)
        end
        BuildMenuTab(FruitTabs.legal) 
    elseif menuTab == 2 then 
        local subHeader = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "subHeader", "Illegal Deliveries")
        if activeDelivery ~= nil then        
            if activeDelivery[4] == 3 then
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "Cooldown: "..MissionCD.." seconds remaining.")
            else
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "You Have an Active Delivery. Go to the waypoint on your map to begin!")
            end
        else        
            if MoonshineCheck() then
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", FruitDelivery.illegalTxT)
            else
                local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", DataBind[1], "description", "You do not have the Moonshine Role. You Need it to Perform these Deliveries.")
            end
        end
        BuildMenuTab(FruitTabs.illegal, GetHashKey("COLOR_MENU_TEXT"))
    else 
        print('wtf?') 
    end    
    if debugShow == true then
        print('tabdown', menuTab)
    end
    --
    local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", UIAppHash)
end
-- Unfocused UI Item Event
function eventUnfocus(eData)
    lastItem = eData[2] + 1 
    if debugShow == true then
        print('unfocus', menuTab, lastItem)
    end
    --
    local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", UIAppHash)
end
-- Focused UI Item Event
function eventFocus(eData)
    menuItem = eData[2] + 1
    if debugShow == true then
        print('focus', menuTab, (eData[2] + 1))
    end
    local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", UIAppHash)
end
-- Selected UI Item Event
function eventSelected(eData)
    local itemContainterID = Citizen.InvokeNative("0x0C827D175F1292F3", DataBind[2], eData[2])    
    local enabledVal = Citizen.InvokeNative("0xA8EDE09FE07BD77F", itemContainterID, "dynamic_list_item_enabled")
    if enabledVal == 1 then        
        if activeDelivery == nil then
            ProcessSelected(menuTab, menuItem, itemContainterID)
        end
    else
        -- yell at the client using a notification

        ---
        -- print('NOPE NOPE. NOOOOPE.')
    end
    MenuClose()
    if debugShow == true then
        print('Selected', menuTab, (eData[2] + 1), "enabled:", enabledVal)
    end
    --
    local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", UIAppHash)
end
----------------
Citizen.CreateThread(function()
    while true do
        local pedCoords = GetEntityCoords(PlayerPedId())        
        if Citizen.InvokeNative("0x67ED5A7963F2F722", UIAppHash) then
            if UIAppListen then
                local view = DataView.ArrayBuffer(256)
                local retval, eType = Citizen.InvokeNative("0x90237103F27F7937", UIAppHash, view:Buffer(), Citizen.ReturnResultAnyway())
                if retval then
                    eData = {view:GetInt32(0),view:GetInt32(8),view:GetInt32(16),view:GetInt32(24)}
                    if eData[3] == -997855324 then -- Exit/prompt Event
                        if eData[1] == GetHashKey("ITEM_SELECTED") then
                            MenuClose()
                            if debugShow == true then
                                print('closed uimenu')
                            end
                        else
                            print('** Unhandled Prompt Evt**', eData[2])
                            print(eData[1],eData[2],eData[3],eData[4])
                            local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", UIAppHash)
                        end               
                        local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", UIAppHash)                    
                    elseif eData[3] == -1517694752 then -- Nav Event
                        if eData[1] == GetHashKey("TAB_PAGE_INCREMENT") then
                            tabPageIncrement(eData)
                        elseif eData[1] == GetHashKey("TAB_PAGE_DECREMENT") then
                            tabPageDecrement(eData)
                        else
                            print('** Unhandled Nav Evt**', eData[2])
                            print(eData[1],eData[2],eData[3],eData[4])
                            local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", UIAppHash) 
                        end
                    elseif eData[3] == 1833066477 then   -- Item List Event
                        if eData[1] == GetHashKey("ITEM_SELECTED") then
                            eventSelected(eData)
                        elseif eData[1] == GetHashKey("ITEM_FOCUSED") then
                            eventFocus(eData)
                        elseif eData[1] == GetHashKey("ITEM_UNFOCUSED") then
                            eventUnfocus(eData)
                        else
                            print('** Unhandled Item Evt**', eData[2])
                            print(eData[1],eData[2],eData[3],eData[4])
                            local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", UIAppHash)
                        end
                    else
                        local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", UIAppHash)
                    end
                end

            end
        end
        -- BayouNwa 2025841068
        if GetMapZoneAtCoords(pedCoords, 10) == 2025841068 then
            if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, FruitTree.BayouNwa.x, FruitTree.BayouNwa.y, FruitTree.BayouNwa.z, false) <= 55 then
                sSleep = 100
                if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, FruitDelivery.BayouNwaNPC.x, FruitDelivery.BayouNwaNPC.y, FruitDelivery.BayouNwaNPC.z, false) <= 2 then
                    deliverySleep = 1
                    if Citizen.InvokeNative("0x25B7A0206BDFAC76", UIAppHash) then            
                        DisableFirstPersonCamThisFrame()
                        DisableAllControlActions(0)
                    else
                        Prompt_SupplierLabel  = CreateVarString(10, 'LITERAL_STRING', "Fruit Supplier")
                        PromptSetActiveGroupThisFrame(SupplierPromptGroup, Prompt_SupplierLabel)
                        if PromptHasHoldModeCompleted(Prompt_Supplier) then
                            if IsPedOnMount(PlayerPedId()) then
                                print('You are mounted')
                            elseif IsPedSittingInAnyVehicle(PlayerPedId()) then
                                print('You are in a vehicle')
                            else                                
                                if IsAnyUiappActive() then
                                    CloseAllUiappsImmediate()
                                    Wait(10)
                                end
                                if Citizen.InvokeNative("0xE555EC27D65EDE80", UIAppHash) then
                                    UpdateDeliveryScores(FruitScores)
                                    Citizen.Wait(10)
                                    BuildMenuHeader()
                                end
                            end
                        end
                    end
                end
            end
        end
        -- Braithwaite Orchard -166839571
        if GetMapZoneAtCoords(pedCoords, 11) == -166839571 then
            if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, FruitTree.Braithwaite.x, FruitTree.Braithwaite.y, FruitTree.Braithwaite.z, false) <= 60 then
                deliverySleep = 100
                if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, FruitDelivery.BraithwaiteNPC.x, FruitDelivery.BraithwaiteNPC.y, FruitDelivery.BraithwaiteNPC.z, false) <= 2 then
                    deliverySleep = 1
                    if Citizen.InvokeNative("0x25B7A0206BDFAC76", UIAppHash) then            
                        DisableFirstPersonCamThisFrame()
                        DisableAllControlActions(0)
                    else
                        Prompt_SupplierLabel  = CreateVarString(10, 'LITERAL_STRING', "Fruit Supplier")
                        PromptSetActiveGroupThisFrame(SupplierPromptGroup, Prompt_SupplierLabel)
                        if PromptHasHoldModeCompleted(Prompt_Supplier) then
                            if IsPedOnMount(PlayerPedId()) then
                                print('You are mounted')
                            elseif IsPedSittingInAnyVehicle(PlayerPedId()) then
                                print('You are in a vehicle')
                            else                                
                                if IsAnyUiappActive() then
                                    CloseAllUiappsImmediate()
                                    Wait(10)
                                end
                                if Citizen.InvokeNative("0xE555EC27D65EDE80", UIAppHash) then
                                    UpdateDeliveryScores(FruitScores)
                                    Citizen.Wait(10)
                                    BuildMenuHeader()
                                end
                            end
                        end
                    end
                end
            end
        end
        -- Calliga hall
        if GetMapZoneAtCoords(pedCoords, 11) == 2084778330 then
            if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, FruitTree.CalligaHall.x, FruitTree.CalligaHall.y, FruitTree.CalligaHall.z, false) <= 25 then
                deliverySleep = 100
                if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, FruitDelivery.CalligaNPC.x, FruitDelivery.CalligaNPC.y, FruitDelivery.CalligaNPC.z, false) <= 2 then
                    deliverySleep = 1
                    if Citizen.InvokeNative("0x25B7A0206BDFAC76", UIAppHash) then            
                        DisableFirstPersonCamThisFrame()
                        DisableAllControlActions(0)
                    else
                        Prompt_SupplierLabel  = CreateVarString(10, 'LITERAL_STRING', "Fruit Supplier")
                        PromptSetActiveGroupThisFrame(SupplierPromptGroup, Prompt_SupplierLabel)
                        if PromptHasHoldModeCompleted(Prompt_Supplier) then
                            if IsPedOnMount(PlayerPedId()) then
                                print('You are mounted')
                            elseif IsPedSittingInAnyVehicle(PlayerPedId()) then
                                print('You are in a vehicle')
                            else                                
                                if IsAnyUiappActive() then
                                    CloseAllUiappsImmediate()
                                    Wait(10)
                                end
                                if Citizen.InvokeNative("0xE555EC27D65EDE80", UIAppHash) then
                                    UpdateDeliveryScores(FruitScores)
                                    Citizen.Wait(10)
                                    BuildMenuHeader()
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(deliverySleep)
    end
end)
----------------
----------------
Citizen.CreateThread(function()
    while true do
        if activeDelivery ~= nil then
            local gameTime = activeDelivery[1]
            local gameState = activeDelivery[4]
            local startVector = activeDelivery[2]
            local stopVector = activeDelivery[3]
            local dRoute = activeDelivery[6]
            missionSleep = 1000
            if gameState ~= nil then
                local pedCoords = GetEntityCoords(PlayerPedId())
                if gameState == 0 then
                    missionSleep = 1
                    createMissionBlip(startVector.x, startVector.y, startVector.z, "Mission: Begin Delivery", "BLIP_STYLE_OBJECTIVE", "blip_objective")
                    if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, startVector.x, startVector.y, startVector.z, false) <= 25 then
                        Citizen.InvokeNative(0x2A32FAA57B937173,0x94FDAE17,startVector.x, startVector.y, startVector.z-1.45,0,0,0,0,0,0,10.0,10.0,1.5,186, 218, 85,250,0, 0, 2, 0, 0, 0, 0)
                    end
                    --
                    if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, startVector.x, startVector.y, startVector.z, false) <= 5 then
                        Prompt_MissionLabel  = CreateVarString(10, 'LITERAL_STRING', "Fruit Supplier")
                        PromptSetActiveGroupThisFrame(MissionPromptGroup, Prompt_MissionLabel)
                        if PromptHasHoldModeCompleted(Prompt_Mission) then
                            if IsPedOnMount(PlayerPedId()) then
                                print('You are mounted')
                            elseif IsPedSittingInAnyVehicle(PlayerPedId()) then
                                print('You are in a vehicle')
                            else                                
                                removeMissionBlip()
                                DestroyMissionRoute()
                                CreateMissionVehicle()
                                --- add barrels to cart based on type.
                                TriggerServerEvent("mwg-herbs:updatemissionsstate", gameState)
                                Citizen.Wait(1000)
                            end
                        end
                    else
                        if MissionText == nil then
                            MissionText = "Head to the Delivery Pickup"
                        end
                    end
                elseif gameState == 1 then
                    missionSleep = 1
                    MissionTick = (MissionTick-1)
                    local displayTick = math.round(MissionTick/100)
                    createMissionBlip(stopVector.x, stopVector.y, stopVector.z, "Mission: Deliver Goods", "BLIP_STYLE_OBJECTIVE", "blip_objective")
                    local MissionVec = GetEntityCoords(MissionVehicle)
                    if MissionRoute == nil then CreateMissionRoute(dRoute) end
                    ShowMissionHelperTextFields(GetGpsBlipRouteLength(), displayTick)   
                    if GetDistanceBetweenCoords(MissionVec.x, MissionVec.y, MissionVec.z, stopVector.x, stopVector.y, stopVector.z, false) <= 25 then
                        Citizen.InvokeNative(0x2A32FAA57B937173,0x94FDAE17,stopVector.x, stopVector.y, stopVector.z-1.45,0,0,0,0,0,0,10.0,10.0,1.5,186, 218, 85,250,0, 0, 2, 0, 0, 0, 0)
                    end
                    
                    DraftHorseId = GetPedInDraftHarness(MissionVehicle, 0)
                    ------------------------------------------------------------
                    -- mission end detection stuff
                    ------------------------------------------------------------

                    -- IS PLAYER IN CART. player defined limit before fails.
                    if IsPedSittingInAnyVehicle(PlayerPedId()) then
                        MissionTimeOutOfCart = 0 
                    else
                        if GetDistanceBetweenCoords(MissionVec.x, MissionVec.y, MissionVec.z, stopVector.x, stopVector.y, stopVector.z, false) > 5 then
                            MissionTimeOutOfCart = (MissionTimeOutOfCart + 1)
                            if MissionTimeOutOfCart >= FruitDelivery.MissionTimeOutOfCart then
                                removeMissionBlip()
                                DestroyMissionRoute()
                                DestroyMissionVehicle()
                                HideMissionHelperTextFields()
                                MissionTimeOutOfCart = 0 
                                TriggerServerEvent("mwg-herbs:vehicledestroyed", gameState)    
                                Citizen.Wait(1000)
                            else
                                local diffT = (FruitDelivery.MissionTimeOutOfCart-MissionTimeOutOfCart)
                                if MissionText == nil then
                                    MissionText = "Return to your Wagon! ("..diffT..")ms"
                                end
                            end                            
                        end
                    end

                    -- IS MISSION TIMER DONE
                    if displayTick <= 0 then
                        removeMissionBlip()
                        DestroyMissionRoute()
                        DestroyMissionVehicle()
                        HideMissionHelperTextFields()
                        TriggerServerEvent("mwg-herbs:vehicledestroyed", gameState)    
                        Citizen.Wait(1000)
                    end

                    -- local inwater = IsEntityInWater(MissionVehicle)
                    -- if IsEntityUnderwater(MissionVehicle, 1) then
                    --     print('Underwater... did it do what you expected?')
                    -- end

                    -- IS HEALTH ABOVE DEATHPOINT
                    if GetEntityHealth(MissionVehicle) <= 0 then
                        removeMissionBlip()
                        DestroyMissionRoute()
                        DestroyMissionVehicle()
                        HideMissionHelperTextFields()
                        TriggerServerEvent("mwg-herbs:vehicledestroyed", gameState)    
                        Citizen.Wait(1000)
                    end

                    -- ARE THE HORSES THERE
                    local retval, expected, HorsesAttached = GetDraftAnimalCount(MissionVehicle)
                    if HorsesAttached < 1 then
                        removeMissionBlip()
                        DestroyMissionRoute()
                        DestroyMissionVehicle()
                        HideMissionHelperTextFields()
                        TriggerServerEvent("mwg-herbs:vehicledestroyed", gameState)
                        Citizen.Wait(1000)
                    end
                    
                    ------------------------------------------------------------
                    ------------------------------------------------------------
                    if GetDistanceBetweenCoords(MissionVec.x, MissionVec.y, MissionVec.z, stopVector.x, stopVector.y, stopVector.z, false) <= 5 then
                        if GetVehiclePedIsIn(PlayerPedId(), false) == MissionVehicle then
                            if MissionText == nil then
                                MissionText = "Exit Vehicle to Deliver"
                            end
                        end
                        Prompt_EndLabel  = CreateVarString(10, 'LITERAL_STRING', "Delivery Location")
                        PromptSetActiveGroupThisFrame(EndPromptGroup, Prompt_EndLabel)
                        if PromptHasHoldModeCompleted(Prompt_End) then
                            removeMissionBlip()
                            DestroyMissionRoute()
                            DestroyMissionVehicle()
                            HideMissionHelperTextFields()
                            TriggerServerEvent("mwg-herbs:updatemissionsstate", gameState)
                            Citizen.Wait(1000)
                        end
                    else
                        -- if illegals, draw npcs to hunt. artificially delfate honopr rating DURING mission to nothing, guarantees sheriffs.

                        --
                    end
                elseif gameState == 2 then
                    print('reward display if needed fireworks tadas')
                    ------ 
                    Citizen.InvokeNative(0x1E5185B72EF5158A, "MP_CELEB_SCREEN_MUSIC")  -- PREPARE_MUSIC_EVENT
                    Citizen.InvokeNative(0x706D57B0F50DA710, "MP_CELEB_SCREEN_MUSIC")  -- TRIGGER_MUSIC_EVENT
                    local trackPlaytime = GetMusicPlaytime()
                    ----
                    TriggerServerEvent("mwg-herbs:updatemissionsstate", gameState)
                    Citizen.Wait(trackPlaytime)
                    CancelMusicEvent("MP_CELEB_SCREEN_MUSIC")
                    if MissionTextCenter == nil then
                        MissionTextCenter = "You Delivered the Goods!"
                    end

                elseif gameState == 3 then
                    TriggerServerEvent("mwg-herbs:cooldownwait", gameState)
                    missionSleep = 60000
                else
                    -- nothing should trigger this gamestate
                end
            end
            --
        end
        Citizen.Wait(missionSleep)
    end
end)
Citizen.CreateThread(function()
    while true do
        local waitimer = 10
        if MissionText ~= nil then
            NotifyBottomRight(MissionText, 5000)
            waitimer = 7000
            MissionText = nil
        end
        if MissionTextCenter ~= nil then
            NotifyCenter(MissionTextCenter, 5000, joaat("COLOR_PURE_WHITE"))
            waitimer = 7000
            MissionTextCenter = nil
        end
        Citizen.Wait(waitimer)
    end
end)
----------------
----------------
RegisterNetEvent("mwg-herbs:pScores")
AddEventHandler("mwg-herbs:pScores", function(pScores)
    FruitScores = pScores
    UpdateDeliveryScores(pScores)
end)
RegisterNetEvent("mwg-herbs:cdTimer")
AddEventHandler("mwg-herbs:cdTimer", function(cdTimer)
    MissionCD = cdTimer    
    print('Cooldown', MissionCD)
end)
RegisterNetEvent("mwg-herbs:moonshinecheck")
AddEventHandler("mwg-herbs:moonshinecheck", function(state)
    MoonshineItem = state    
end)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == 'mad-herbs' then
        removeMissionBlip()
        DestroyMissionRoute()
        DestroyMissionVehicle()
        removeNPCBlip("BayouNwaNPC")
        removeNPCBlip("BraithwaiteNPC")
        removeNPCBlip("CalligaNPC")
        MissionBlip = nil
        MissionRoute = nil
        MissionVehicle = nil
    end
end)