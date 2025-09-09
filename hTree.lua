local sSleep = 1000
-----------------
local BayouNwaScores = {
    [0] = {
        label = "Orange Crates:",
        value = 0
    },
    [1] = {
        label = "Lemon Crates:",
        value = 0
    }
}
local CalligaHallScores = {
    [0] = {
        label = "Peach Crates:",
        value = 0
    },
    [1] = {
        label = "",
        value = ""
    }
}
local BraithwaiteScores = {
    [0] = {
        label = "Apple Crates:",
        value = 0
    },
    [1] = {
        label = "Pear Crates:",
        value = 0
    }
}
-----------------
local pPickedTrees = {}
local customObjects = {}
local vItemSet = CreateItemset(1)
local BayouNwaVolume = nil
local BraithwaiteVolume = nil
local CaligaVolume = nil
local CustomVolume = nil
local CurrentVolume = nil
local CurrentReward = nil
----------------
local HerbPromptGroup = GetRandomIntInRange(25500, 0xffffff)
Citizen.CreateThread(function()
	Prompt_OrangesLabel  = CreateVarString(10, 'LITERAL_STRING', "Fruit Tree")
	Prompt_OrangesString = CreateVarString(10, 'LITERAL_STRING', 'Harvest')
	Prompt_Oranges = PromptRegisterBegin()
	PromptSetControlAction(Prompt_Oranges, 0x760A9C6F)
	PromptSetText(Prompt_Oranges, Prompt_OrangesString)
	PromptSetEnabled(Prompt_Oranges, true)
	PromptSetVisible(Prompt_Oranges, true)
	PromptSetHoldMode(Prompt_Oranges, TreePickPromptSpeed)
	PromptSetGroup(Prompt_Oranges, HerbPromptGroup)
	PromptRegisterEnd(Prompt_Oranges)
end)
----------------
function ShowHelperTextFields(fields)
    EnableHudContext(-66088566)
    local rootContainer = DatabindingAddDataContainerFromPath("", "helperTextfields")
    for key, field in pairs(fields) do
        local valueTxT = ''..field.value..''
        DatabindingAddDataString(rootContainer, "rawLabel" .. key, field.label)
        DatabindingAddDataString(rootContainer, "rawValue" .. key, valueTxT)
    end
end
----------------
function HideHelperTextFields()
    DisableHudContext(-66088566)
end
----------------
function processPrompts(tableId, ItemHash, ItemCoords)
    Prompt_OrangesLabel  = CreateVarString(10, 'LITERAL_STRING', "Fruit Tree")
    PromptSetActiveGroupThisFrame(HerbPromptGroup, Prompt_OrangesLabel)
    if PromptHasHoldModeCompleted(Prompt_Oranges) then
        if IsPedOnMount(PlayerPedId()) then
            print('You are mounted')
        elseif IsPedSittingInAnyVehicle(PlayerPedId()) then
            print('You are in a vehicle')
        else
            table.insert(pPickedTrees, ItemCoords)
            TriggerServerEvent("mwg-herbs:pickfruittree", {tableId, ItemHash, ItemCoords, CurrentVolume, pPickedTrees})
        end
    end
end
----------------
function ProcessTrees(prophash)
    local objects = GetGamePool('CObject')
    local pedCoords = GetEntityCoords(PlayerPedId())
    for i = 1, #objects do
        if GetEntityModel(objects[i]) == prophash then
            local plantCoords = GetEntityCoords(objects[i])
            if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, plantCoords.x, plantCoords.y, plantCoords.z, false) <= 2 then
                local shouldPick = true
                for j = 1, #pPickedTrees do
                    if GetDistanceBetweenCoords(pPickedTrees[j].x, pPickedTrees[j].y, pPickedTrees[j].z, plantCoords.x, plantCoords.y, plantCoords.z, false) <= 2 then
                        shouldPick = false
                    end
                end
                if shouldPick == true then
                    processPrompts(i, objects[i], plantCoords)
                    sSleep = 1
                end
            end
        end
    end
end
----------------
function ProcessMapPoints(mapTable)
    local pedCoords = GetEntityCoords(PlayerPedId())
    for i = 1, #mapTable do
        if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, mapTable[i].x, mapTable[i].y, mapTable[i].z, false) <= 2 then
            local shouldPick = true
            for j = 1, #pPickedTrees do
                if GetDistanceBetweenCoords(pPickedTrees[j].x, pPickedTrees[j].y, pPickedTrees[j].z, mapTable[i].x, mapTable[i].y, mapTable[i].z, false) <= 2 then
                    shouldPick = false
                end
            end
            if shouldPick == true then
                processPrompts(i, -1, mapTable[i])
                sSleep = 1
            end
        end
    end
end
----------------
function ProcessCustomPoints(mapTable)
    local pedCoords = GetEntityCoords(PlayerPedId())
    for i = 1, #mapTable do
        if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, mapTable[i][2].x, mapTable[i][2].y, mapTable[i][2].z, false) <= 2 then
            local shouldPick = true
            for j = 1, #pPickedTrees do
                if GetDistanceBetweenCoords(pPickedTrees[j].x, pPickedTrees[j].y, pPickedTrees[j].z, mapTable[i][2].x, mapTable[i][2].y, mapTable[i][2].z, false) <= 2 then
                    shouldPick = false
                end
            end
            if shouldPick == true then
                CurrentReward = mapTable[i][3]
                processPrompts(i, -1, mapTable[i][2])
                sSleep = 1
            end
        end
    end
end
----------------
function UpdateScores(pScores)
    BayouNwaScores[0].label = pScores.BayouNwaScores.oranges.label
    BayouNwaScores[0].value = pScores.BayouNwaScores.oranges.value
    BayouNwaScores[1].label = pScores.BayouNwaScores.lemons.label
    BayouNwaScores[1].value = pScores.BayouNwaScores.lemons.value
    CalligaHallScores[0].label = pScores.CalligaHallScores.peaches.label
    CalligaHallScores[0].value = pScores.CalligaHallScores.peaches.value
    BraithwaiteScores[0].label = pScores.BraithwaiteScores.apples.label
    BraithwaiteScores[0].value = pScores.BraithwaiteScores.apples.value
    BraithwaiteScores[1].label = pScores.BraithwaiteScores.pears.label
    BraithwaiteScores[1].value = pScores.BraithwaiteScores.pears.value
end
----------------
Citizen.CreateThread(function()
    while true do
        local pedCoords = GetEntityCoords(PlayerPedId())
        -- BayouNwa Orchard
        if GetMapZoneAtCoords(pedCoords, 10) == 2025841068 then
            if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, FruitTree.BayouNwa.x, FruitTree.BayouNwa.y, FruitTree.BayouNwa.z, false) <= 55 then
                sSleep = 100
                if BayouNwaVolume == nil then
                    BayouNwaVolume = CreateVolumeCylinderWithCustomName(FruitTree.BayouNwa.x, FruitTree.BayouNwa.y, FruitTree.BayouNwa.z, 0.0, 0.0, 0.0, 55.0, 55.0, 3.0, 'BayouNwaVolume')
                else
                    CurrentVolume = 'BayouNwaVolume'
                    ProcessTrees(FruitTree.modelHash)
                    ShowHelperTextFields(BayouNwaScores)
                end
            else
                if BayouNwaVolume ~= nil then                    
                    HideHelperTextFields()
                    DeleteVolume(BayouNwaVolume)
                    BayouNwaVolume = nil
                    CurrentVolume = nil
                end
            end
        end
        -- Braithwaite Orchard -166839571
        if GetMapZoneAtCoords(pedCoords, 11) == -166839571 then
            if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, FruitTree.Braithwaite.x, FruitTree.Braithwaite.y, FruitTree.Braithwaite.z, false) <= 60 then
                sSleep = 100
                if BraithwaiteVolume == nil then
                    BraithwaiteVolume = CreateVolumeCylinderWithCustomName(FruitTree.Braithwaite.x, FruitTree.Braithwaite.y, FruitTree.Braithwaite.z, 0.0, 0.0, 0.0, 60.0, 60.0, 3.0, 'BraithwaiteVolume')
                else
                    CurrentVolume = 'BraithwaiteVolume'
                    ProcessMapPoints(BraithwaiteTrees)
                    ShowHelperTextFields(BraithwaiteScores)
                end
            else
                if BraithwaiteVolume ~= nil then                    
                    HideHelperTextFields()
                    DeleteVolume(BraithwaiteVolume)
                    BraithwaiteVolume = nil
                    CurrentVolume = nil
                end
            end
        end
        -- Calliga Hall 2084778330
        if GetMapZoneAtCoords(pedCoords, 11) == 2084778330 then
            if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, FruitTree.CalligaHall.x, FruitTree.CalligaHall.y, FruitTree.CalligaHall.z, false) <= 25 then
                sSleep = 100
                if CaligaVolume == nil then
                    CaligaVolume = CreateVolumeCylinderWithCustomName(FruitTree.CalligaHall.x, FruitTree.CalligaHall.y, FruitTree.CalligaHall.z, 0.0, 0.0, 0.0, 25.0, 25.0, 3.0, 'CaligaVolume')
                else
                    CurrentVolume = 'CaligaVolume'
                    ProcessMapPoints(CaligaTrees)
                    ShowHelperTextFields(CalligaHallScores)
                end
            else
                if CaligaVolume ~= nil then                    
                    HideHelperTextFields()
                    DeleteVolume(CaligaVolume)
                    CaligaVolume = nil
                    CurrentVolume = nil
                end
            end
        end
        -- custom tree plantations
        for i = 1, #CustomTrees do
            if GetMapZoneAtCoords(pedCoords, 10) == CustomTrees[i][1] then
                if GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, CustomTrees[i][2].x, CustomTrees[i][2].y, CustomTrees[i][2].z, false) <= 99 then
                    sSleep = 100
                    if CustomVolume == nil then
                        CustomVolume = CreateVolumeCylinderWithCustomName(CustomTrees[i][2].x, CustomTrees[i][2].y, CustomTrees[i][2].z, 0.0, 0.0, 0.0, 25.0, 25.0, 3.0, 'CustomVolume')
                        local newtree = CreateObject(CustomTrees[i][4], CustomTrees[i][2].x, CustomTrees[i][2].y, CustomTrees[i][2].z, false, false, false)
                        customObjects[i] = newtree
                        print('newtree', newtree)
                    else
                        CurrentVolume = 'CustomVolume'
                        ProcessCustomPoints(CustomTrees)
                    end
                else
                    if CustomVolume ~= nil then
                        if customObjects[i] ~= nil then
                            DeleteObject(customObjects[i])
                            print('deltree', customObjects[i])
                            customObjects[i] = nil
                        end
                        HideHelperTextFields()
                        DeleteVolume(CustomVolume)
                        CustomVolume = nil
                        CurrentVolume = nil
                    end
                end
            end
        end
        --
        Citizen.Wait(sSleep)
    end
end)
----------------
RegisterNetEvent("mwg-herbs:pScores")
AddEventHandler("mwg-herbs:pScores", function(pScores)
    UpdateScores(pScores)
end)
----------------
RegisterNetEvent("mwg-herbs:pPicked")
AddEventHandler("mwg-herbs:pPicked", function(pPicked)
    pPickedTrees = pPicked
end)
----------------
RegisterNetEvent("mwg-herbs:pickcustomtree")
AddEventHandler("mwg-herbs:pickcustomtree", function(treeInfo)
    PickCustomTree(treeInfo[4], treeInfo, CurrentReward)
end)
----------------
RegisterNetEvent("mwg-herbs:pickfruittree")
AddEventHandler("mwg-herbs:pickfruittree", function(treeInfo)
    if treeInfo[4] == "CaligaVolume" then
        UpdateScores(treeInfo[6])
        HideHelperTextFields()
        Citizen.Wait(1)
        ShowHelperTextFields(CalligaHallScores)
        PickFruitTree(treeInfo[4], treeInfo)
    elseif treeInfo[4] == "BraithwaiteVolume" then
        UpdateScores(treeInfo[6])
        HideHelperTextFields()
        Citizen.Wait(1)
        ShowHelperTextFields(BraithwaiteScores)
        PickFruitTree(treeInfo[4], treeInfo)
    end
end)
----------------
RegisterNetEvent("mwg-herbs:pickcitrus")
AddEventHandler("mwg-herbs:pickcitrus", function(treeInfo)
    UpdateScores(treeInfo[6])
    HideHelperTextFields()
    Citizen.Wait(1)
    ShowHelperTextFields(BayouNwaScores)
    PickCitrusTree(treeInfo)
end)