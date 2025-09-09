-- local VorpCore = exports.vorp_core:GetCore()

------------------------------------------
local herbCHeckZone = Citizen.InvokeNative(0xB3FB80A32BAE3065, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 40.0, 40.0, 2.0)
local itemSet = CreateItemset(1)
local herbBlips = {}
local herbComps = {}
local PlantCull = {}
--
function GetClosestObject(coords, prophash)
    local ped = PlayerPedId()
    local objects = GetGamePool('CObject')
    local closestDistance = -1
    local closestObject = nil
    coords = coords or GetEntityCoords(ped)
    for i = 1, #objects do
        if GetEntityModel(objects[i]) == prophash then
            local objectCoords = GetEntityCoords(objects[i])
            local distance = #(objectCoords - coords)
            if closestDistance == -1 or closestDistance > distance then
                closestObject = objects[i]
            end
        end
    end
    return closestObject
end
--
function cullPlantsNearComp(itemHash, tCoords, veg_radius)
    if PlantCull[itemHash] == nil or PlantCull[itemHash] == 0 then
        local veg_radius = veg_radius
        local veg_Flags =  1 + 2 + 4 + 8 + 16 + 32 + 64 + 128 + 256   -- implement to all debris, grass, bush, etc...
        local veg_ModType = 1 	-- 1 | VMT_Cull
        PlantCull[itemHash] = Citizen.InvokeNative(0xFA50F79257745E74, tCoords.x, tCoords.y, tCoords.z, veg_radius, veg_ModType, veg_Flags, 0);
    end
end
--
function uncullPlantsNearComp(itemHash)
    Citizen.InvokeNative(0x9CF1836C03FB67A2,Citizen.PointerValueIntInitialized(PlantCull[itemHash]), 0);    -- REMOVE_VEG_MODIFIER_SPHERE
    PlantCull[itemHash] = 0
end
--
function RandomPlantFromCategory(plantCategory)
    local ranIndex = math.random(1, #plantCategory)
    local SelectedComp = plantCategory[ranIndex]
    return SelectedComp
end
--
function CreateComp(iHash, mHash, compHash, district, intown)
    if herbComps[iHash] == nil then
        if IsEntityVisible(iHash) then
            local IntroducedRNG = math.random(1, RollMaximum)
            local plantCoords = GetEntityCoords(iHash)
            if intown ~= 0 then
                herbComps[iHash] = {}
                herbComps[iHash].name = -1
                herbComps[iHash].plantCoords = plantCoords
                herbComps[iHash].district = district                
                -- player is in a town do not drawn
                if debugShow == true then 
                    print('Player is in town, Bypassing herb composite draw')
                end
            else
                if IntroducedRNG < HerbRates then
                    herbComps[iHash] = {}
                    herbComps[iHash].name = -1
                    herbComps[iHash].plantCoords = plantCoords
                    herbComps[iHash].district = district
                    if debugShow == true then
                        print('Herb Bypassed', iHash, ''..IntroducedRNG..'/'..RollMaximum..'')   
                    end
                else
                    SetEntityVisible(iHash, false)
                    local composite_name = compHash
                    local composite_name_hash = GetHashKey(composite_name)
                    if herbComps[iHash] == nil then
                        Citizen.InvokeNative(0x73F0D0327BFA0812,composite_name_hash);  -- request COMPOSITE
                        local i = 1
                        while not Citizen.InvokeNative(0x5E5D96BE25E9DF68,composite_name_hash) and i < 250 do  -- has COMPOSITE loaded
                            i = i + 1
                            Citizen.Wait(0)
                        end
                        if Citizen.InvokeNative(0x5E5D96BE25E9DF68,composite_name_hash) then -- has COMPOSITE loaded
                            herbComps[iHash] = {}
                            herbComps[iHash].name = composite_name
                            herbComps[iHash].namehash = composite_name_hash
                            herbComps[iHash].plantHash = iHash
                            herbComps[iHash].plantCoords = plantCoords
                            herbComps[iHash].district = district
                            herbComps[iHash].comp = Citizen.InvokeNative(0x5B4BBE80AD5972DC,composite_name_hash, plantCoords.x, plantCoords.y, plantCoords.z, 0.0, 0, Citizen.PointerValueInt(), -1,Citizen.ReturnResultAnyway())
                            cullPlantsNearComp(iHash, plantCoords, 0.5)
                            -- EAGLE_EYE_SET_CUSTOM_ENTITY_TINT
                            RegisterEagleEyeForEntity(PlayerPedId(), iHash, 0)
                            EagleEyeSetCustomEntityTint(iHash, 186, 218, 85)
                            -- blip stuff
                            herbBlips[iHash] = BlipAddForCoords(GetHashKey('BLIP_STYLE_DEBUG_GREEN'), plantCoords.x, plantCoords.y, plantCoords.z)
                            SetBlipSprite(herbBlips[iHash], -675651933, true)
                            SetBlipScale(herbBlips[iHash], 0.2)
                            SetBlipName(herbBlips[iHash], 'Herb')                            
                            --
                            if debugShow == true then
                                print('Herb Blip: ', iHash)
                                print('Herb Created from: '..mHash, herbComps[iHash].comp, iHash, plantCoords.x, plantCoords.y, plantCoords.z, ''..IntroducedRNG..'/'..RollMaximum..'')
                                print('numcomps:', #herbComps)
                            end
                        end
                    end
                end
            end
        end
    end
end
----------------
CreateThread(function()
    local notconnectedyet = true
    while notconnectedyet do
        if NetworkIsSessionStarted() then
            notconnectedyet = false
            TriggerServerEvent("MK_NISS", 'NISS')
        end
        Citizen.Wait(100)
    end
end)
--
CreateThread(function()
    while true do
        local sleep = 100
        local pPed = PlayerPedId()
        if not IsEntityDead(pPed) then
            local pedCoords = GetEntityCoords(pPed)            
            local current_district = GetMapZoneAtCoords(pedCoords.x, pedCoords.y, pedCoords.z, 10)
            local isintown = GetMapZoneAtCoords(pedCoords.x, pedCoords.y, pedCoords.z, 1)
            if isintown == 0 then
                if herbCHeckZone then
                    Citizen.InvokeNative(0x541B8576615C33DE, herbCHeckZone, pedCoords.x, pedCoords.y, pedCoords.z)
                    local itemsFound = Citizen.InvokeNative(0x886171A12F400B89, herbCHeckZone, itemSet, 3)
                    if itemsFound then
                        n = 0
                        -------------------------------------------------------------------------------------------
                        local randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.herb)
                        local randBushFromRegion = RandomPlantFromCategory(CompositeTypes.bush)
                        --   ZoneName = "ChollaSprings",
                        if current_district == -108848014 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.ChollaSprings.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.ChollaSprings.bush)
                        end
                        --   ZoneName = "GrizzliesEast",
                        if current_district == -120156735 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.GrizzliesEast.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.GrizzliesEast.bush)
                        end
                        --   ZoneName = "GaptoothRidge",
                        if current_district == -2066240242 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.GaptoothRidge.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.GaptoothRidge.bush)
                        end
                        --   ZoneName = "RioBravo",
                        if current_district == -2145992129 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.RioBravo.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.RioBravo.bush)
                        end
                        --   ZoneName = "HennigansStead",
                        if current_district == 892930832 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.HennigansStead.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.HennigansStead.bush)
                        end
                        --   ZoneName = "GuarmaD",
                        if current_district ==-512529193 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.GuarmaD.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.GuarmaD.bush)
                        end
                        --   ZoneName = "ScarlettMeadows",
                        if current_district == -864275692 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.ScarlettMeadows.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.ScarlettMeadows.bush)
                        end
                        --   ZoneName = "BluewaterMarsh",
                        if current_district == 1308232528 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.BluewaterMarsh.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.BluewaterMarsh.bush)                                
                        end
                        --   ZoneName = "BayouNwa",
                        if current_district == 2025841068 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.BayouNwa.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.BayouNwa.bush)           
                        end
                        --   ZoneName = "Heartlands",
                        if current_district == 131399519 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.Heartlands.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.Heartlands.bush)
                        end
                        --   ZoneName = "GrizzliesWest",
                        if current_district == 1645618177 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.GrizzliesWest.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.GrizzliesWest.bush)
                        end
                        --   ZoneName = "TallTrees",
                        if current_district == 1684533001 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.TallTrees.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.TallTrees.bush)
                        end
                        --   ZoneName = "Roanoke",
                        if current_district == 178647645 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.Roanoke.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.Roanoke.bush)
                        end
                        --   ZoneName = "Cumberland",
                        if current_district == 1835499550 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.Cumberland.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.Cumberland.bush)
                        end
                        --   ZoneName = "GreatPlains",
                        if current_district == 476637847 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.GreatPlains.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.GreatPlains.bush)
                        end
                        --   ZoneName = "BigValley",
                        if current_district == 822658194 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.BigValley.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.BigValley.bush)                                
                        end
                        -- MEXICO LOCALTIONS
                        --   ZoneName = "Perdido",
                        if current_district == -1319956120 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.bush)                            
                        end
                        --   ZoneName = "PuntaOrgullo",
                        if current_district == 1453836102 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.bush)                 
                        end
                        --   ZoneName = "DiezCoronas",
                        if current_district == 426773653 then
                            randHerbFromRegion = RandomPlantFromCategory(CompositeTypes.herb)
                            randBushFromRegion = RandomPlantFromCategory(CompositeTypes.bush)
                        end                          
                        while n < itemsFound do
                            local itemHash = (GetIndexedItemInItemset(n, itemSet))                      
                            local modelhash = GetEntityModel(itemHash)
                            -- BullRush Plants                            
                            for _, watermodel in pairs(ModelTypes.water) do
                                if watermodel == modelhash then
                                    CreateComp(itemHash, watermodel, RandomPlantFromCategory(CompositeTypes.water), current_district, isintown)
                                    break
                                end
                            end
                            -- bush models for replacement in regions
                            for _, bushmodel in pairs(ModelTypes.bush) do
                                if bushmodel == modelhash then
                                    CreateComp(itemHash, bushmodel, randBushFromRegion, current_district, isintown)
                                end
                            end                            
                            -- herb models for replacement in regions
                            for _, herbmodel in pairs(ModelTypes.herb) do
                                if herbmodel == modelhash then
                                    CreateComp(itemHash, herbmodel, randHerbFromRegion, current_district, isintown)
                                end
                            end
                            -------------------------------------------------------------------------------------------
                            n = n + 1
                        end
                        Citizen.InvokeNative(0x20A4BF0E09BEE146, itemSet)
                    end
                end
            end
            --            
            for k, v in pairs(herbComps) do
                if #(pedCoords - vector3(herbComps[k].plantCoords.x,herbComps[k].plantCoords.y,herbComps[k].plantCoords.z)) > 50 then  -- if distance from ped bigger then 40 meters
                    if herbComps[k].name ~= -1 then
                        Citizen.InvokeNative(0x5758B1EE0C3FD4AC,herbComps[k].comp,0)  -- delete COMPOSITE scenario
                        uncullPlantsNearComp(herbComps[k].plantHash)
                        SetEntityVisible(herbComps[k].plantHash, true)
                        --remove  Blip
                        RemoveBlip(herbBlips[k])
                        herbBlips[k] = nil
                        if debugShow == true then
                            print('Herb Removed', herbComps[k].comp)
                        end
                    end
                    herbComps[k] = nil
                end
            end
        end
        Wait(sleep)
    end
end)
--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        for k, v in pairs(herbComps) do
            -- if unlocakble relating to the collection bag isnt present then fail
            -- "KIT_COLLECTORS_BAG"
            if not UnlockIsUnlocked(HerbItemRequired) then
                DisableCompositePickPromptThisFrame(herbComps[k].comp, true)
            end
            --
            DisableLootingCompositeLootableThisFrame(herbComps[k].comp, true) -- removes eat ability from composite herbs
        end
    end
end)
--
RegisterNetEvent("mwg-herbs:rateset")
AddEventHandler("mwg-herbs:rateset", function(rate)
    print('Setting Herb Rate to:', rate)
    HerbRates = tonumber(rate)
end)

RegisterNetEvent("mwg-herbs:dbshow")
AddEventHandler("mwg-herbs:dbshow", function(ds)
    if tonumber(ds) == 1 then
        debugShow = true
    else
        debugShow = false    
    end
    print('Setting debugshow to:', debugShow)
end)
--
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == 'mad-herbs' then
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        for k, v in pairs(herbComps) do
            if herbComps[k].name ~= -1 then
                Citizen.InvokeNative(0x5758B1EE0C3FD4AC,herbComps[k].comp,0)  -- delete COMPOSITE scenario
                uncullPlantsNearComp(herbComps[k].plantHash)
                SetEntityVisible(herbComps[k].plantHash, true)
                -- remove blips
                RemoveBlip(herbBlips[k])
                herbBlips[k] = nil
                if debugShow == true then
                    print('Herb Removed', herbComps[k].comp)
                end
            end
            herbComps[k] = nil
        end
    end
end)