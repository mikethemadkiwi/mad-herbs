-- -guarma
-- vector3(1399.016, -6742.748, 54.09695)	136.59405517578
-- vector3(1263.848, -6431.619, 48.29469)	130.1630859375
-- vector3(1762.043, -5957.885, 64.49547)	138.02792358398
-- vector3(1286.281, -7255.122, 73.7643)	332.74407958984
-- vector3(665.8596, -7241.807, 164.527)	237.53912353516

-- doctors byu herbs and give rare herb missions. sell to them or give to moonshine


local SpecialSleep = 1000

Prompt_Special_Group = nil
Prompt_Special_Label  = nil
Prompt_Special_String = nil
Prompt_Special = nil

local lastItem = -1
local herbItem = 1
local herbTab = 1
local itemSet = CreateItemset(1)
local uiherbmenu = 1833066477
local UIAppHerbListen = false
local buttonNameHash = GetHashKey("IB_ACCEPT")
local HerbDataBind = {}
local HerbUIItemList = {}
HerbNpcPed = nil
HerbNpcBlips = {}
HerbNPC = {}
HerbNPC[1] = vector4(744.67053222656,1828.3260498047,238.01692199707,39.290027618408)
HerbNPC[2] = vector4(2085.4592285156,-1821.8099365234,42.942516326904,133.08609008789)
HerbNPC[3] = vector4(-4365.3115234375,-2415.7150878906,20.41188621521,298.28475952148)


RareHerbMission = nil
RareHerbCull = {}
CurrentComp = nil
CurrentCompBlip = nil
CurrentRareHerbName = ""
CurrentRareHerbDesc = ""
CurrentRareHerbInvHash = -1
MissionEndCompCheck = false

MenuItems = {}
SellList = {}
MenuItems[1] = {
    ["enabled"] = 1,
    ["rawtext"] = "Purchase Collectors Bag",
    ["color"] = GetHashKey("COLOR_MENU_TEXT"),
    ["button"] = GetHashKey("IB_BUY"),
    ["price"] = 25000,
}
MenuItems[2] = {
    ["enabled"] = 0,
    ["rawtext"] = "Sell Rare Herb Collection",
    ["color"] = GetHashKey("COLOR_MENU_TEXT"),
    ["button"] = GetHashKey("IB_SELECT"),
    ["price"] = 31100,
}
MenuItems[3] = {
    ["enabled"] = 1,
    ["rawtext"] = "",
    ["color"] = GetHashKey("COLOR_MENU_TEXT"),
    ["button"] = GetHashKey("IB_SELECT"),
    ["price"] = 100,
}
RareHerbHashes = {
    -589542533,
    1338475089,
    1071702353,
    -1183422860,
    -1957546791,
    -1776738559,
    2605459,
    1602215994,
    -396757268
}

function CreateSpecialPrompt()
    Prompt_Special_Group = GetRandomIntInRange(25500, 0xffffff)
    Prompt_Special_Label  = CreateVarString(10, 'LITERAL_STRING', "Herbalist")
    Prompt_Special_String = CreateVarString(10, 'LITERAL_STRING', 'Talk')
    Prompt_Special = PromptRegisterBegin()
    PromptSetControlAction(Prompt_Special, 0x760A9C6F)
    PromptSetText(Prompt_Special, Prompt_Special_String)
    PromptSetEnabled(Prompt_Special, true)
    PromptSetVisible(Prompt_Special, true)
    PromptSetHoldMode(Prompt_Special, 1)
    PromptSetGroup(Prompt_Special, Prompt_Special_Group)
    PromptRegisterEnd(Prompt_Special)
end

function CreatNpcBlips(blipID, Vectorx, Vectory, Vectorz, bliptxt, blipstyle, blipsprite)
    if HerbNpcBlips[blipID] == nil then
        HerbNpcBlips[blipID] = BlipAddForCoords(GetHashKey(blipstyle), Vectorx, Vectory, Vectorz)
        SetBlipSprite(HerbNpcBlips[blipID], GetHashKey(blipsprite), true)
        SetBlipScale(HerbNpcBlips[blipID], 0.2)
        SetBlipName(HerbNpcBlips[blipID], bliptxt)
    end
end
--
function RemoveNpcBlips()
    if HerbNpcBlips ~= nil then
        for key, value in pairs(HerbNpcBlips) do
            RemoveBlip(HerbNpcBlips[key])
        end
        HerbNpcBlips = nil
    end     
end

function CreateBigInt(text)
    local string1 = DataView.ArrayBuffer(16)
    string1:SetInt64(0, text)
    return string1:GetInt64(0)
end

function CreateSpecialComposite(iHash, mHash, compHash, district, intown)

end

function RemoveSpecialComposites()

end

function BuildHerbHeader()    
    local dbPresent = Citizen.InvokeNative("0x1E7130793AAAAB8D", HerbDataBind[1])
    if not dbPresent then
        HerbDataBind[1] = DatabindingAddDataContainerFromPath("", "FastTravel");
    end
    HerbDataBind[2] = Citizen.InvokeNative("0xFE74FA57E0CE6824", HerbDataBind[1], "locationList");
    local clearlist = Citizen.InvokeNative("0xA1F15C1D03DF802D", HerbDataBind[2]); -- empties the locationlist Herbdatabind

    local header = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "header", "Herbalist") 
    local subHeader = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "subHeader", "Select an Option")
    local subFooter = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "subFooter", "")
    local subFooter2 = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "footer", "Herbalist Menu")
    if CollectorCheck() == 0 then
        local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "description", "Herbalism is cool. If you wanna join the collectors league. lemme know. There's a fee to join. But TRUST me it's worth it.")
    else
        local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "description", "Welcome fellow Collector! I've got some tips for some rare flowers, Cost ya a buck. Cos we're mates!")
    end
    BuildHerbTab()
    UIAppHerbListen = true
    Citizen.InvokeNative("0xC8FC7F4E4CF4F581", uiherbmenu)
    Citizen.InvokeNative(0x4CC5F2FC1332577F ,GetHashKey("HUD_CTX_IN_FAST_TRAVEL_MENU"))
end

function BuildHerbTab()
    for k = 1, #MenuItems do
        local keySting = "herboption_"..k
        local container = {}        
        container[1] = Citizen.InvokeNative("0xEB4F9A3537EEABCD", HerbDataBind[2], keySting)
        if CollectorCheck() == 0 then
            if k == 1 then
                if CanAfford(MenuItems[k].price) then
                    container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 1)
                    container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 1)
                    container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", MenuItems[k].color)
                else
                    container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 0)
                    container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 1)
                    container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", GetHashKey('COLOR_MENU_ITEM_ATTENTION'))
                end
            else
                container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 0)
                container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 0)
                container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", GetHashKey('COLOR_MENU_TEXT_DISABLED'))
            end
        else
            if k == 1 then
                container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 0)
                container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 1)
                container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", GetHashKey('COLOR_MENU_TEXT_DISABLED'))
            elseif k == 2 then
                if IsCollectionComplete() then
                    container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 1)
                    container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 1)
                    container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", MenuItems[k].color)
                else
                    container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 0)
                    container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 1)
                    container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", GetHashKey('COLOR_MENU_TEXT_DISABLED'))
                end
            else
                if CanAfford(MenuItems[k].price) then
                    if RareHerbMission ~= nil then
                        container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 0)
                        container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 1)
                        container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", GetHashKey('COLOR_MENU_TEXT_DISABLED'))
                    else
                        local itemNum = CollectableGetNumFound(CurrentRareHerbInvHash)
                        if itemNum < 10 then
                            container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", MenuItems[k].enabled)
                            container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 1)
                            container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", MenuItems[k].color)
                        else
                            container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 0)
                            container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 1)
                            container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", GetHashKey('COLOR_MENU_ITEM_ATTENTION'))
                        end
                    end
                else
                    container[2] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_enabled", 0)
                    container[3] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_visible", 1)
                    container[4] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_main_color", GetHashKey('COLOR_MENU_ITEM_ATTENTION'))
                end
            end
        end
        container[5] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_link", 0);
        container[6] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_event_channel_hash", uiherbmenu);
        container[7] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_select_hash", uiherbmenu);
        container[8] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_focus_hash", uiherbmenu);
        container[9] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_prompt_text", MenuItems[k].button); --joaat("ib_select") text eq: "Travel"
        container[10] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_prompt_enabled", 0);
        container[11] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_prompt_visible", 0);
        container[13] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_prompt_option_select_hash", -1); 
        container[15] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_prompt_option_text", MenuItems[k].button); --joaat("ib_select") text eq: "Travel"
        container[16] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_prompt_option_enabled", 0);
        container[17] = Citizen.InvokeNative("0x58BAA5F635DA2FF4", container[1], "dynamic_list_item_prompt_option_visible", 0);
        container[18] = Citizen.InvokeNative("0x617FCA1C5652BBAD", container[1], "dynamic_list_item_raw_text_entry", MenuItems[k].rawtext)
        container[19] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_prompt_r3_text", MenuItems[k].button)
        container[20] = Citizen.InvokeNative("0x8538F1205D60ECA6", container[1], "dynamic_list_item_prompt_toggle_text", MenuItems[k].button)                                    
        container[21] = Citizen.InvokeNative("0x307A3247C5457BDE", container[1], "dynamic_list_item_extra_int_field_one_value", MenuItems[k].price)
        container[22] = Citizen.InvokeNative("0x307A3247C5457BDE", container[1], "dynamic_list_item_extra_int_field_two_value", MenuItems[k].price)
        local INSERT2UILIST = Citizen.InvokeNative("0x5859E970794D92F3", HerbDataBind[2], k, "ft_dynamic_text_and_price", container[1])
        HerbUIItemList[k] = Citizen.InvokeNative("0x307A3247C5457BDE", container[1], "locationArrayIndex", k);
        if debugShow == true then
            print('menuitemcreate', container[1])
        end
    end
end
--
function MenuClose()
    local header = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "header", "") 
    local subHeader = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "subHeader", "")
    local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "description", "")
    local subFooter = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "subFooter", "")
    local subFooter = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "footer", "")
    local clearlist = Citizen.InvokeNative("0xA1F15C1D03DF802D", HerbDataBind[2]);
    Citizen.InvokeNative("0xAD7B70F7230C5A12")
    Citizen.InvokeNative("0x0AE9938D0541F2DA", HerbDataBind[1])
    UIAppHerbListen = false
end
-- process selected menu to figure out which item and mission type to run
function hProcessSelected(herbTab, herbItem, itemContainterID)
    if herbTab == 1 then
        if herbItem == 1 then -- buy player satchel
            PuchasedCollectorBag()
            BuildHerbHeader()
        end
        if herbItem == 2 then
            PlayerCollectionTrigger(RareHerbHashes, (MenuItems[2].price/100))
        end
        if herbItem == 3 then
            TriggerServerEvent('mwg-herbs:requestherbmission')            
        end
    end
end
-- Tab Page Increment UI Event
function htabPageIncrement()
    local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", uiherbmenu)
end
-- Tab Page Decrement UI Event
function htabPageDecrement()
    local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", uiherbmenu)
end
-- Unfocused UI Item Event
function heventUnfocus(eData)
    lastItem = eData[2] + 1 
    if debugShow == true then
        print('unfocus', herbTab, lastItem)
    end
    local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", uiherbmenu)
end
-- Focused UI Item Event
function heventFocus(eData)
    herbItem = eData[2] + 1
    if herbItem == 3 then
        local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "description", CurrentRareHerbDesc)
    else
        local description = Citizen.InvokeNative("0x617FCA1C5652BBAD", HerbDataBind[1], "description", "Welcome fellow Collector! I've got some tips for some rare flowers, Cost ya a buck. Cos we're mates!")
    end
    if debugShow == true then
        print('focus', herbTab, (eData[2] + 1))
    end
    local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", uiherbmenu)
end
-- Selected UI Item Event
function heventSelected(eData)
    local itemContainterID = Citizen.InvokeNative("0x0C827D175F1292F3", HerbDataBind[2], eData[2])    
    local enabledVal = Citizen.InvokeNative("0xA8EDE09FE07BD77F", itemContainterID, "dynamic_list_item_enabled")
    if enabledVal == 1 then
        MenuClose()
        hProcessSelected(herbTab, herbItem, itemContainterID)
    end
    if debugShow == true then
        print('Selected', herbTab, (eData[2] + 1), "enabled:", enabledVal)
    end
    local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", uiherbmenu)
end
----------------
Citizen.CreateThread(function()
    while true do 
        local ticksleep = 1
        if Citizen.InvokeNative("0x67ED5A7963F2F722", uiherbmenu) then
            if UIAppHerbListen then
                local view = DataView.ArrayBuffer(256)
                local retval, eType = Citizen.InvokeNative("0x90237103F27F7937", uiherbmenu, view:Buffer(), Citizen.ReturnResultAnyway())
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
                            local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", uiherbmenu)
                        end               
                        local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", uiherbmenu)                    
                    elseif eData[3] == -1517694752 then -- Nav Event
                        if eData[1] == GetHashKey("TAB_PAGE_INCREMENT") then
                            htabPageIncrement(eData)
                        elseif eData[1] == GetHashKey("TAB_PAGE_DECREMENT") then
                           htabPageDecrement(eData)
                        else
                            print('** Unhandled Nav Evt**', eData[2])
                            print(eData[1],eData[2],eData[3],eData[4])
                            local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", uiherbmenu) 
                        end
                    elseif eData[3] == 1833066477 then   -- Item List Event
                        if eData[1] == GetHashKey("ITEM_SELECTED") then
                            heventSelected(eData)
                        elseif eData[1] == GetHashKey("ITEM_FOCUSED") then
                            heventFocus(eData)
                        elseif eData[1] == GetHashKey("ITEM_UNFOCUSED") then
                            heventUnfocus(eData)
                        else
                            print('** Unhandled Item Evt**', eData[2])
                            print(eData[1],eData[2],eData[3],eData[4])
                            local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", uiherbmenu)
                        end
                    else
                        local popeventmsg = Citizen.InvokeNative("0x8E8A2369F48EC839", uiherbmenu)
                    end
                end

            end
        end
        Citizen.Wait(ticksleep)
    end
end)
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
function IsCollectionComplete()
    -- CollectableGetCategoryItemSetBuyAward(GetHashKey('WILD_FLOWERS'), 3000)
    for i=1, #RareHerbHashes do
        local numfound = CollectableGetNumFound(RareHerbHashes[i])
        if numfound < 1 then
            print('Missing Item:', RareHerbHashes[i])
            return false
        else
            -- Citizen.InvokeNative("0xEC3959E9950BF56B", RareHerbHashes[i])
            print('Collectable Amount:', RareHerbHashes[i], numfound)
        end
    end
    return true
end

function RareHerbBlipCreate()
    if CurrentCompBlip == nil then
        CurrentCompBlip = BlipAddForCoords(GetHashKey('BLIP_STYLE_OBJECTIVE_MINOR'), RareHerbMission.HerbLocation[2].x, RareHerbMission.HerbLocation[2].y, RareHerbMission.HerbLocation[2].z)
        SetBlipSprite(CurrentCompBlip, -675651933, true)
        SetBlipScale(CurrentCompBlip, 0.2)
        SetBlipName(CurrentCompBlip, 'Herb')
    end
end
--
function RareHerbBlipRemove()
    if CurrentCompBlip ~= nil then
        RemoveBlip(CurrentCompBlip)
        CurrentCompBlip = nil
    end
end
--
function cullPlantsNearRareComp(itemHash, tCoords, veg_radius)
    if RareHerbCull[itemHash] == nil or RareHerbCull[itemHash] == 0 then
        local veg_radius = veg_radius
        local veg_Flags =  1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256   -- implement to all debris, grass, bush, etc...
        local veg_ModType = 1 	-- 1 | VMT_Cull
        RareHerbCull[itemHash] = Citizen.InvokeNative(0xFA50F79257745E74, tCoords.x, tCoords.y, tCoords.z, veg_radius, veg_ModType, veg_Flags, 0);
    end
end
--
function uncullPlantsNearRareComp(itemHash)
    Citizen.InvokeNative(0x9CF1836C03FB67A2,Citizen.PointerValueIntInitialized(RareHerbCull[itemHash]), 0);    -- REMOVE_VEG_MODIFIER_SPHERE
    RareHerbCull[itemHash] = 0
end
--
function RareHerbCompCreate()
    if CurrentComp == nil then
        local cHash = GetHashKey(RareHerbMission.HerbType.comphash)
        Citizen.InvokeNative(0x73F0D0327BFA0812, cHash);  -- request COMPOSITE
        local i = 1
        while not Citizen.InvokeNative(0x5E5D96BE25E9DF68, cHash) and i < 250 do  -- has COMPOSITE loaded
            i = i + 1
            Citizen.Wait(0)
        end
        if Citizen.InvokeNative(0x5E5D96BE25E9DF68, cHash) then -- has COMPOSITE loaded
            CurrentComp = Citizen.InvokeNative(0x5B4BBE80AD5972DC, cHash, RareHerbMission.HerbLocation[2].x, RareHerbMission.HerbLocation[2].y, RareHerbMission.HerbLocation[2].z, 0.0, 0, Citizen.PointerValueInt(), -1,Citizen.ReturnResultAnyway())
            -- print('composite created', CurrentComp)
            cullPlantsNearRareComp(CurrentComp, RareHerbMission.HerbLocation[2], 1.5)
            RegisterEagleEyeForEntity(PlayerPedId(), CurrentComp, 0)
            EagleEyeSetCustomEntityTint(CurrentComp, 186, 218, 85)
        end
    end
end
--
function RareHerbCompRemove()
    if CurrentComp ~= nil then
        uncullPlantsNearRareComp(CurrentComp)
        Citizen.InvokeNative(0x5758B1EE0C3FD4AC,CurrentComp,0)  -- delete COMPOSITE scenario
        -- print('removed:', CurrentComp)
        CurrentComp = nil
    end
end
--
function EndRareMission()
    RareHerbBlipRemove()
    MissionEndCompCheck = true
end
--
function UpdatePlayerStats(comptype)

end
--
local eventType = {
    [`EVENT_LOOT_PLANT_START`] = {
        name = "EVENT_LOOT_PLANT_START",
        size = 36,
        members = {"Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32"}
    },    
    [`EVENT_LOOT`] = {
        name = "EVENT_LOOT",
        size = 36,
        members = {"Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32", "Int32"}
    }
}
--
Citizen.CreateThread(function()
    while true do
        local size = GetNumberOfEvents(0) -- SCRIPT_EVENT_QUEUE_AI)
        for i = 0, size - 1 do
            if size > 0 then
                local event = GetEventAtIndex(0, i)
                if eventType[event] then
                    local dataInfo = eventType[event]                    
                    local dataSize = dataInfo.size
                    local dataStruct = DataView.ArrayBuffer(dataSize * 8)
                    for i = 0, dataSize - 1 do
                        dataStruct:SetInt32(8 * i, 0) -- Set all members to zero
                    end
                    -- Retrieve the data, passing the pointer to our buffer
                    Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, i, dataStruct:Buffer(), dataSize)
                    -- Simple lua array
                    local data = {}
                    -- Copy the data struct members
                    for i = 0, dataSize - 1 do
                        -- Insert function named after member data type. E.g., "GetInt32", "GetFloat32", etc
                        local label = "Get" .. dataInfo.members[i + 1]
                        local dataMember = dataStruct[label](dataStruct, 8 * i)
                        table.insert(data, dataMember)
                    end                    
                    if RareHerbMission ~= nil then  
                        pPed = PlayerPedId() 
                        pedCoords = GetEntityCoords(pPed)
                        if GetMapZoneAtCoords(pedCoords, 10) == RareHerbMission.HerbLocation[1] then
                            if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, RareHerbMission.HerbLocation[2].x, RareHerbMission.HerbLocation[2].y, RareHerbMission.HerbLocation[2].z, false) <= 1.5 then
                                if dataInfo.name == "EVENT_LOOT_PLANT_START" then
                                    TriggerServerEvent('mwg-herbs:finishherbmission')
                                    UpdatePlayerStats(RareHerbMission.HerbType.comphash)
                                else
                                    TriggerServerEvent('mwg-herbs:finishherbmission')
                                    UpdatePlayerStats(RareHerbMission.HerbType.comphash)
                                    local invID = data[3]
                                    print('Inventory Item for:', RareHerbMission.HerbType.comphash, invID)
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(0)
    end     
end)
------ SCRIPT LOAD INIT
CreateThread(function()
    for key, value in pairs(HerbNPC) do
        CreatNpcBlips(key, HerbNPC[key].x, HerbNPC[key].y, HerbNPC[key].z, "Herbalist", "BLIP_STYLE_MISSION", "blip_plant")
        CreateSpecialPrompt()
        if RareHerbMission ~= nil then
            RareHerbBlipCreate()
        end
        IsCollectionComplete()
    end
end)
--
CreateThread(function()
    while true do
        SpecialSleep = 1000
        pPed = PlayerPedId()
        pedCoords = GetEntityCoords(pPed)
        for key, value in pairs(HerbNPC) do
            local farfrom = GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, 0, HerbNPC[key].x, HerbNPC[key].y, 0, false)
            if farfrom < 25 then
                SpecialSleep = 1
                if farfrom < 3 then
                    if Citizen.InvokeNative("0x25B7A0206BDFAC76", uiherbmenu) then            
                        DisableFirstPersonCamThisFrame()
                        DisableAllControlActions(0)
                    else
                        Prompt_Special_String  = CreateVarString(10, 'LITERAL_STRING', "Herbalist")
                        PromptSetActiveGroupThisFrame(Prompt_Special_Group, Prompt_Special_String)
                        if PromptHasHoldModeCompleted(Prompt_Special) then
                            if IsPedOnMount(PlayerPedId()) then
                                print('You are mounted')
                            elseif IsPedSittingInAnyVehicle(PlayerPedId()) then
                                print('You are in a vehicle')
                            else
                                if IsAnyUiappActive() then
                                    CloseAllUiappsImmediate()
                                    Wait(10)
                                end
                                if Citizen.InvokeNative("0xE555EC27D65EDE80", uiherbmenu) then
                                    BuildHerbHeader()
                                    Wait(1000)
                                end
                            end
                        end
                    end
                end
            end
        end
        ------------------------------------------------------------------------------------------------        
        if MissionEndCompCheck == true then
            if GetMapZoneAtCoords(pedCoords, 10) == RareHerbMission.HerbLocation[1] then
                if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, RareHerbMission.HerbLocation[2].x, RareHerbMission.HerbLocation[2].y, RareHerbMission.HerbLocation[2].z, false) >= 25 then
                    RareHerbCompRemove()                    
                    MissionEndCompCheck = false
                    RareHerbMission = nil
                end
            end
        else
            if RareHerbMission ~= nil then
                RareHerbBlipCreate()            
                if GetMapZoneAtCoords(pedCoords, 10) == RareHerbMission.HerbLocation[1] then
                    if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, RareHerbMission.HerbLocation[2].x, RareHerbMission.HerbLocation[2].y, RareHerbMission.HerbLocation[2].z, false) <= 25 then
                        RareHerbCompCreate()
                    end
                end
            end
        end
        ------------------------------------------------------------------------------------------------
        Citizen.Wait(SpecialSleep)
    end
end)
--
RegisterNetEvent('mwg-herbs:rareinfo')
AddEventHandler('mwg-herbs:rareinfo', function(rareinfo)
    -- print(rareinfo[1], rareinfo[2])
    CurrentRareHerbName = rareinfo[1]
    MenuItems[3]["rawtext"] = "Hint: "..CurrentRareHerbName.." location"
    CurrentRareHerbDesc = rareinfo[2]
    CurrentRareHerbInvHash = rareinfo[3]
end)

RegisterNetEvent('mwg-herbs:acceptmission')
AddEventHandler('mwg-herbs:acceptmission', function(rareM)
    RareHerbMission = rareM
    -- print('accepted', RareHerbMission.HerbType.name, RareHerbMission.HerbLocation)
end)
--
RegisterNetEvent('mwg-herbs:endmission')
AddEventHandler('mwg-herbs:endmission', function(endInfo)
    if endInfo then
        EndRareMission()
    end
end)
--
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == 'mad-herbs' then
        RemoveNpcBlips()
        MenuClose()
        RareHerbBlipRemove()
        RareHerbCompRemove()
    end
end)
-- -- occultist ( use for card sales instead )
-- local District = -120156735
-- local LocationName = vector4(1190.0969238281,2030.5723876953,322.84048461914,133.50958251953)
-- --orchid guy algernon whateverthefugg
-- local District = 2025841068
-- local LocationName = vector4(2587.9321289062,-1010.7984619141,44.2399559021,108.21829986572)

		-- case 0:
		-- 	return "HERB_TYPE_INVALID";
		-- case 1:
		-- 	return "HERB_ACUNAS_STAR_ORCHID";
		-- case 2:
		-- 	return "HERB_ALASKAN_GINSENG";
		-- case 3:
		-- 	return "HERB_AMERICAN_GINSENG";
		-- case 4:
		-- 	return "HERB_BAY_BOLETE";
		-- case 5:
		-- 	return "HERB_BLACK_BERRY";
		-- case 6:
		-- 	return "HERB_BLACK_CURRANT";
		-- case 7:
		-- 	return "HERB_BURDOCK_ROOT";
		-- case 8:
		-- 	return "HERB_CHANTERELLES";
		-- case 9:
		-- 	return "HERB_CIGAR_ORCHID";
		-- case 10:
		-- 	return "HERB_CLAMSHELL_ORCHID";
		-- case 11:
		-- 	return "HERB_COMMON_BULRUSH";
		-- case 12:
		-- 	return "HERB_CREEPING_THYME";
		-- case 13:
		-- 	return "HERB_DESERT_SAGE";
		-- case 14:
		-- 	return "HERB_DRAGONS_MOUTH_ORCHID";
		-- case 15:
		-- 	return "HERB_ENGLISH_MACE";
		-- case 16:
		-- 	return "HERB_EVERGREEN_HUCKLEBERRY";
		-- case 17:
		-- 	return "HERB_GHOST_ORCHID";
		-- case 18:
		-- 	return "HERB_GOLDEN_CURRANT";
		-- case 19:
		-- 	return "HERB_HARRIETUM_OFFICINALIS";
		-- case 20:
		-- 	return "HERB_HUMMINGBIRD_SAGE";
		-- case 21:
		-- 	return "HERB_INDIAN_TOBACCO";
		-- case 22:
		-- 	return "HERB_LADY_OF_NIGHT_ORCHID";
		-- case 23:
		-- 	return "HERB_LADY_SLIPPER_ORCHID";
		-- case 24:
		-- 	return "HERB_MILKWEED";
		-- case 25:
		-- 	return "HERB_MOCCASIN_FLOWER_ORCHID";
		-- case 26:
		-- 	return "HERB_NIGHT_SCENTED_ORCHID";
		-- case 27:
		-- 	return "HERB_OLEANDER_SAGE";
		-- case 28:
		-- 	return "HERB_OREGANO";
		-- case 29:
		-- 	return "HERB_PARASOL_MUSHROOM";
		-- case 30:
		-- 	return "HERB_PRAIRIE_POPPY";
		-- case 31:
		-- 	return "HERB_QUEENS_ORCHID";
		-- case 32:
		-- 	return "HERB_RAMS_HEAD";
		-- case 33:
		-- 	return "HERB_RAT_TAIL_ORCHID";
		-- case 34:
		-- 	return "HERB_RED_RASPBERRY";
		-- case 35:
		-- 	return "HERB_RED_SAGE";
		-- case 36:
		-- 	return "HERB_SPARROWS_EGG_ORCHID";
		-- case 37:
		-- 	return "HERB_SPIDER_ORCHID";
		-- case 38:
		-- 	return "HERB_VANILLA_FLOWER";
		-- case 39:
		-- 	return "HERB_VIOLET_SNOWDROP";
		-- case 40:
		-- 	return "HERB_WILD_FLWR_AGARITA";
		-- case 41:
		-- 	return "HERB_WILD_FLWR_BLUE_BONNET";
		-- case 42:
		-- 	return "HERB_WILD_FLWR_BITTERWEED";
		-- case 43:
		-- 	return "HERB_WILD_FLWR_BLOOD_FLOWER";
		-- case 44:
		-- 	return "HERB_WILD_FLWR_CARDINAL_FLOWER";
		-- case 45:
		-- 	return "HERB_WILD_FLWR_CHOCOLATE_DAISY";
		-- case 46:
		-- 	return "HERB_WILD_FLWR_CREEK_PLUM";
		-- case 47:
		-- 	return "HERB_WILD_FLWR_RHUBARB";
		-- case 48:
		-- 	return "HERB_WILD_FLWR_WISTERIA";
		-- case 49:
		-- 	return "HERB_WILD_CARROTS";
		-- case 50:
		-- 	return "HERB_WILD_FEVERFEW";
		-- case 51:
		-- 	return "HERB_WILD_MINT";
		-- case 52:
		-- 	return "HERB_WINTERGREEN_BERRY";
		-- case 53:
		-- 	return "HERB_YARROW";