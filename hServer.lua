local HerbRates = 990
local currentUUID = {}
local UserIdentificationList = {}
local PlayerScores = {}
local PlayerPicked = {}
local dDistance = {}
local RareHerbMission = {}
local lastUpdatedRare = (os.time()-1300)
----------------------------------------
RareHerbLocations = { -- district, vec4
    {1835499550, vector4(446.59112548828,1644.8245849609,197.30169680715,266.87396240234)},
    {178647645, vector4(2349.8676757812,1451.4598388672,143.27624511719,124.52094268799)},
    {178647645, vector4(3401.3002929688,1413.7205810547,48.87451171875,188.85461425781)},
    {178647645, vector4(3013.1831054688,2207.5417480469,165.82879638672,311.85772705078)},
    {178647645, vector4(2319.1669921875,406.28619384766,48.71936416626,132.54579162598)},
    {1645618177, vector4(-997.71313476562,2126.1179199219,369.45718383789,332.14642333984)},
    {1645618177, vector4(-433.19891357422,2739.7055664062,328.5495300293,135.70375061035)},
    {1645618177, vector4(-2097.5603027344,1845.7261962891,254.37907409668,181.2370300293)},
    {822658194, vector4(-1592.2553710938,847.79016113281,156.74044799805,335.75537109375)},
    {822658194, vector4(-2030.7261962891,262.33151245117,177.7144317627,344.39575195312)},
    {131399519, vector4(302.15628051758,295.55059814453,156.21104434133,28.430452346802)},
    {178647645, vector4(2414.6997070312,845.42864990234,72.693283081055,214.62690734863)},
    {822658194, vector4(-519.0830078125,-859.68310546875,41.410621643066,333.78237915039)},
    {822658194, vector4(-2646.5554199219,-466.384765625,172.38444519043,230.7251739502)},
    {822658194, vector4(-1844.3957519531,-1125.1640625,86.005912780762,288.31072998047)},
    {1684533001, vector4(-2449.5268554688,-1118.3778076172,182.43663024902,284.43646240234)},
    {476637847, vector4(-1073.2702636719,-1926.4235839844,41.503940612078,262.68524169922)},
    {892930832, vector4(-1387.9361572266,-2582.1711425781,77.234985351562,280.50256347656)},
    {892930832, vector4(-2179.7529296875,-2289.0270996094,88.94327545166,329.25485229492)},
    {892930832, vector4(-2191.4633789062,-3001.2026367188,-3.6250678002834,297.28155517578)},
    {892930832, vector4(-2895.4357910156,-2160.6916503906,72.884506225586,334.09671020508)},
    {892930832, vector4(-3181.2150878906,-2461.3532714844,72.811836242676,26.909809112549)},
    {892930832, vector4(-2702.4826660156,-3259.0825195312,-14.852433174849,280.52661132812)},
    {-2145992129, vector4(-3662.0166015625,-3576.5329589844,47.168670654297,161.17570495605)},
    {-108848014, vector4(-3364.6533203125,-3506.9797363281,8.2483739852905,9.1657705307007)},
    {-108848014, vector4(-4395.5849609375,-2775.5834960938,-7.136550873518,311.25802612305)},
    {-2066240242, vector4(-6052.255859375,-2979.4118652344,5.4457779228687,103.15992736816)},
    {-2066240242, vector4(-5850.5322265625,-3851.2646484375,-29.849000930786,111.04582214355)}
}
-- test locations
-- RareHerbLocations[1] = {-120156735, vector4(677.38214111328,1877.2119140625,238.46310424805,119.61061096191)}
-- RareHerbLocations[2] = {-120156735, vector4(703.03723144531,1899.8489990234,240.39736938477,303.44918823242)}
-- RareHerbLocations[3] = {-120156735, vector4(714.36486816406,1866.8763427734,239.51264953613,329.83410644531)}
-- RareHerbLocations[4] = {-120156735, vector4(725.01483154297,1894.2000732422,238.83828735352,3.4901630878448)}
----------------------------------------
RareHerbList = {}
RareHerbList[1] = {}
RareHerbList[1].name = 'Chocolate Daisy'
RareHerbList[1].invhash = -589542533
RareHerbList[1].desc = 'Cocoa Scented Yellow Daisy'
RareHerbList[1].comphash = 'COMPOSITE_LOOTABLE_CHOC_DAISY_DEF'
RareHerbList[2] = {}
RareHerbList[2].name = 'Agarita'
RareHerbList[2].invhash = 1338475089
RareHerbList[2].desc = 'Pointed Thorns and Berries'
RareHerbList[2].comphash = 'COMPOSITE_LOOTABLE_AGARITA_DEF'
RareHerbList[3] = {}
RareHerbList[3].name = 'BitterWeed'
RareHerbList[3].invhash = 1071702353
RareHerbList[3].desc = 'Small Yellow Leaves & Flowers'
RareHerbList[3].comphash = 'COMPOSITE_LOOTABLE_BITTERWEED_DEF'
RareHerbList[4] = {}
RareHerbList[4].name = 'Blood Flower'
RareHerbList[4].invhash = -1183422860
RareHerbList[4].desc = 'Orange Flowers with bleeds of Red'
RareHerbList[4].comphash = 'COMPOSITE_LOOTABLE_BLOODFLOWER_DEF'
RareHerbList[5] = {}
RareHerbList[5].name = 'Cardinal Flower'
RareHerbList[5].invhash = -1957546791
RareHerbList[5].desc = 'Herbaceous Plant, Bright Red Blossoms'
RareHerbList[5].comphash = 'COMPOSITE_LOOTABLE_CARDINAL_FLOWER_DEF'
RareHerbList[6] = {}
RareHerbList[6].name = 'Creek Plum'
RareHerbList[6].invhash = -1776738559
RareHerbList[6].desc = 'Plums. from Creeks. Creekplums.'
RareHerbList[6].comphash = "COMPOSITE_LOOTABLE_CREEKPLUM_DEF"
RareHerbList[7] = {}
RareHerbList[7].name = 'Texas Blue Bonnet'
RareHerbList[7].invhash = 2605459
RareHerbList[7].desc = 'Wild Blue Flowered Desert Dweller'
RareHerbList[7].comphash = "COMPOSITE_LOOTABLE_TEXAS_BONNET_DEF"
RareHerbList[8] = {}
RareHerbList[8].name = 'Wild Rhubarb'
RareHerbList[8].invhash = 1602215994
RareHerbList[8].desc = 'Poisonous until Blanced. Tasty in Jellies and Jams!'
RareHerbList[8].comphash = "COMPOSITE_LOOTABLE_WILD_RHUBARB_DEF"
RareHerbList[9] = {}
RareHerbList[9].name = 'Wisteria Flower'
RareHerbList[9].invhash = -396757268
RareHerbList[9].desc = 'Resilient Vine with Purple Flowers'
RareHerbList[9].comphash = "COMPOSITE_LOOTABLE_WISTERIA_DEF"
RareHerbList[10] = {}
RareHerbList[10].name = 'Harrietum Officianalis'
RareHerbList[10].invhash = -241666815
RareHerbList[10].desc = 'Naturalist Discovered Hallucinogenic Herb'
RareHerbList[10].comphash = "COMPOSITE_LOOTABLE_HARRIETUM_OFFICINALIS_DEF"
----------------------------------------
CurrentRareHerb = RareHerbList[1]
CurrentRareLoc = RareHerbLocations[1]
----------------------------------------
getUserIdentifiers = function(source)
   local ids = {}  
   ids.fivem = nil
   ids.steamid  = nil
   ids.license  = nil
   ids.license2  = nil
   ids.discord  = nil
   ids.xbl      = nil
   ids.liveid   = nil
   ids.ip       = nil
   ids.other = {}
   ids.lastlogin = os.time()
   for k,v in pairs(GetPlayerIdentifiers(source))do  
       if string.sub(v, 1, string.len("steam:")) == "steam:" then
           ids.steamid = v      
       elseif string.sub(v, 1, string.len("fivem:")) == "fivem:" then
           ids.fivem = v
       elseif string.sub(v, 1, string.len("license:")) == "license:" then
           ids.license = v
       elseif string.sub(v, 1, string.len("license2:")) == "license2:" then
           ids.license2 = v
       elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
           ids.xbl  = v
       elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
           ids.ip = v
       elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
           ids.discord = v
       elseif string.sub(v, 1, string.len("live:")) == "live:" then
           ids.liveid = v
       else
           table.insert(ids.other, v)
       end    
   end
   return ids
end
----------------------------------------
execQuery = function(fn, query, parameters)
    local result = fn(query, parameters)
    return result
end
----------------------------------------
function refreshDB(pSrc)    
    local pIds = getUserIdentifiers(pSrc)
    if UserIdentificationList[pIds.license] == nil then
        UserIdentificationList[pIds.license] = LoadUser(pSrc, pIds.license, pIds)
        currentUUID[pSrc] = UserIdentificationList[pIds.license].current_uuid
    end
    if PlayerScores[currentUUID[pSrc]] == nil then
        PlayerScores[currentUUID[pSrc]] = LoadScores(pSrc, pIds.license, pIds, currentUUID[pSrc])
    end
    if RareHerbMission[currentUUID[pSrc]] == nil then
        local dbData = LoadRareHerbs(pSrc, pIds.license, pIds, currentUUID[pSrc])
        -- parse player data in dbdata1 to player's collection table

        --
        RareHerbMission[currentUUID[pSrc]] = dbData[2]
    end
end
----------------------------------------
LoadUser = function(pSrc, license, pIds)
    local userData = nil
    local resultList = MySQL.single.await('SELECT * FROM _mkAccount WHERE license = ?', { license })
    if resultList then
        return resultList
    end
end
----------------------------------------
LoadScores = function(pSrc, license, pIds, current_uuid)    
    local Fruitdb = MySQL.single.await('SELECT * FROM _mkFruit WHERE uuid = ?', { currentUUID[pSrc] })  
    if Fruitdb then
        local retData = json.decode(Fruitdb.fruitData)
        return retData
    else
        local Fruitdb = {}
        Fruitdb.activeDeliveries = nil
        Fruitdb.BayouNwaScores = {}
        Fruitdb.BayouNwaScores.oranges = {}
        Fruitdb.BayouNwaScores.oranges.label = "Orange Crates:"
        Fruitdb.BayouNwaScores.oranges.value = 0
        Fruitdb.BayouNwaScores.lemons = {}
        Fruitdb.BayouNwaScores.lemons.label = "Lemon Crates:"
        Fruitdb.BayouNwaScores.lemons.value = 0
        Fruitdb.BraithwaiteScores = {}
        Fruitdb.BraithwaiteScores.apples = {}
        Fruitdb.BraithwaiteScores.apples.label = "Apple Crates:"
        Fruitdb.BraithwaiteScores.apples.value = 0
        Fruitdb.BraithwaiteScores.pears = {}
        Fruitdb.BraithwaiteScores.pears.label = "Pear Crates:"
        Fruitdb.BraithwaiteScores.pears.value = 0
        Fruitdb.CalligaHallScores = {}
        Fruitdb.CalligaHallScores.peaches = {}
        Fruitdb.CalligaHallScores.peaches.label = "Peach Crates:"
        Fruitdb.CalligaHallScores.peaches.value = 0
        local fruitData = json.encode(Fruitdb)
        execQuery(MySQL.single.await,'INSERT INTO _mkFruit (license, uuid, FruitData) VALUES (?, ?, ?)', { pIds.license, currentUUID[pSrc], fruitData })
        local Fruitdb = MySQL.single.await('SELECT * FROM _mkFruit WHERE uuid = ?', { currentUUID[pSrc] }) 
        local retData = json.decode(Fruitdb.fruitData)
        return retData
    end
end
----------------------------------------
LoadRareHerbs = function(pSrc, license, pIds, current_uuid)    
    local RareDB = MySQL.single.await('SELECT * FROM _mkRareHerbs WHERE uuid = ?', { currentUUID[pSrc] })  
    if RareDB then
        local retData = json.decode(RareDB.Collection)
        local ret2Data = json.decode(RareDB.Missions)
        return {retData, ret2Data}
    else
        execQuery(MySQL.single.await,'INSERT INTO _mkRareHerbs (license, uuid) VALUES (?, ?)', { pIds.license, currentUUID[pSrc] })
        return {nil, nil}
    end
end
----------------------------------------
function GetRandomLegalDelivery(PointA, PointB)
    local dData = {}
    local rngs = math.random(1, #PointA)
    local rnge = math.random(1, #PointB)
    dData.legality = true
    dData.startVec = PointA[rngs]
    dData.endVec = PointB[rnge]
    dData.routeList = RouteTable.legal[rnge]
    return dData
end
----------------------------------------
function GetRandomIllegalDelivery(PointA, PointB)
    local dData = {}
    local rngs = math.random(1, #PointA)
    local rnge = math.random(1, #PointB)
    dData.legality = false
    dData.startVec = PointA[rngs]
    dData.endVec = PointB[rnge]
    dData.routeList = RouteTable.illegal[rnge]
    return dData
end
----------------------------------------
function updatePlayer(pSrc)
    refreshDB(pSrc)
    local hasShine = MoonshineCheckServer(pSrc, currentUUID[pSrc])
    --
    if PlayerPicked[currentUUID[pSrc]] == nil then
        PlayerPicked[currentUUID[pSrc]] = {}
    end
    TriggerClientEvent('mwg-herbs:pScores', pSrc, PlayerScores[currentUUID[pSrc]])
    TriggerClientEvent('mwg-herbs:pPicked', pSrc, PlayerPicked[currentUUID[pSrc]])
    TriggerClientEvent('mwg-herbs:acceptmission', pSrc, RareHerbMission[currentUUID[pSrc]])
end
----------------------------------------
RegisterNetEvent('MK_NISS')
AddEventHandler('MK_NISS', function(niss)  
    local pSrc = source
    updatePlayer(pSrc)  
end)
----------------------------------------
RegisterNetEvent('mwg-herbs:pickfruittree')
AddEventHandler('mwg-herbs:pickfruittree', function(fruitTree)
    local pSrc = source
    refreshDB(pSrc)
    PlayerPicked[currentUUID[pSrc]] = fruitTree[5]
    if fruitTree[4] == "BayouNwaVolume" then
        local IntroducedRNG = math.random(1, RollMaximum)
        if IntroducedRNG <= TreeRates then
            local newvalue = (PlayerScores[currentUUID[pSrc]]['BayouNwaScores'].oranges.value+1)
            PlayerScores[currentUUID[pSrc]]['BayouNwaScores'].oranges.value = newvalue
            if debugShow then
                print('Citrus:', pSrc, 'Orange', newvalue)
            end
        else           
            local newvalue = (PlayerScores[currentUUID[pSrc]]['BayouNwaScores'].lemons.value+1)
            PlayerScores[currentUUID[pSrc]]['BayouNwaScores'].lemons.value = newvalue
            print('Citrus:', pSrc, 'Lemon', newvalue)
        end
        fruitTree[6] = PlayerScores[currentUUID[pSrc]]
        TriggerClientEvent('mwg-herbs:pickcitrus', pSrc, fruitTree)
    end
    if fruitTree[4] == "BraithwaiteVolume" then
        local IntroducedRNG = math.random(1, RollMaximum)
        if IntroducedRNG <= TreeRates then
            local newvalue = (PlayerScores[currentUUID[pSrc]]['BraithwaiteScores'].apples.value+1)
            PlayerScores[currentUUID[pSrc]]['BraithwaiteScores'].apples.value = newvalue
            fruitTree[6] = PlayerScores[currentUUID[pSrc]]
            fruitTree[7] = 'consumable_apple'
            if debugShow then
                print('Fruit:', pSrc, 'Apple', newvalue)
            end
        else 
            local newvalue = (PlayerScores[currentUUID[pSrc]]['BraithwaiteScores'].pears.value+1)
            PlayerScores[currentUUID[pSrc]]['BraithwaiteScores'].pears.value = newvalue
            fruitTree[6] = PlayerScores[currentUUID[pSrc]]
            fruitTree[7] = 'consumable_pear'
            if debugShow then
                print('Fruit:', pSrc, 'Pear', newvalue)
            end
        end
        TriggerClientEvent('mwg-herbs:pickfruittree', pSrc, fruitTree)
    end
    if fruitTree[4] == "CaligaVolume" then
        local IntroducedRNG = math.random(1, RollMaximum)
        if IntroducedRNG <= TreeRates then
            local newvalue = (PlayerScores[currentUUID[pSrc]]['CalligaHallScores'].peaches.value+1)
            PlayerScores[currentUUID[pSrc]]['CalligaHallScores'].peaches.value = newvalue
            fruitTree[6] = PlayerScores[currentUUID[pSrc]]
            fruitTree[7] = 'consumable_peach'
            if debugShow then
                print('Fruit:', pSrc, 'Peach', newvalue)
            end
        else 
            local newvalue = (PlayerScores[currentUUID[pSrc]]['CalligaHallScores'].peaches.value+2)
            PlayerScores[currentUUID[pSrc]]['CalligaHallScores'].peaches.value = newvalue
            fruitTree[6] = PlayerScores[currentUUID[pSrc]]
            fruitTree[7] = 'consumable_peach'
            if debugShow then
                print('Fruit:', pSrc, 'PeachX2', newvalue)
            end
        end
        TriggerClientEvent('mwg-herbs:pickfruittree', pSrc, fruitTree)
    end  
    if fruitTree[4] == "CustomVolume" then
        if debugShow then
            print('Custom:', pSrc, 'Picked', 1)
        end
        fruitTree[6] = PlayerScores[currentUUID[pSrc]]
        TriggerClientEvent('mwg-herbs:pickcustomtree', pSrc, fruitTree)
    end
    local fruitJSON = json.encode(PlayerScores[currentUUID[pSrc]])
    local updatecurrentplayer = execQuery(MySQL.query.await, 'UPDATE `_mkFruit` SET `fruitData` = ? WHERE `uuid` = ?', { fruitJSON, currentUUID[pSrc] })
    TriggerClientEvent('mwg-herbs:pScores', pSrc, PlayerScores[currentUUID[pSrc]])
    if debugShow == true then
        print('Fruit Tree', pSrc, fruitTree[1], fruitTree[2], fruitTree[3], fruitTree[4])
    end
end)
----------------------------------------
RegisterCommand("herbrates", function(source, args, rcom)
    HerbRates = tonumber(args[1])
	TriggerClientEvent('mwg-herbs:rateset', -1, HerbRates)
end,false)
RegisterCommand("showherbdebug", function(source, args, rcom)
    show = tonumber(args[1])
	TriggerClientEvent('mwg-herbs:dbshow', -1, show)
end,false)
----------------------------------------
RegisterNetEvent('mwg-herbs:RequestMission')
AddEventHandler('mwg-herbs:RequestMission', function(menuDetails)
    local pSrc = source
    refreshDB(pSrc)    
    local hasShine = MoonshineCheckServer(pSrc, currentUUID[pSrc])

    if PlayerScores[currentUUID[pSrc]].activeDeliveries ~= nil then
        -- print('yus', PlayerScores[currentUUID[pSrc]].activeDeliveries[1])
        -- check how long ago the mission is, if more thaqn maxtime expire and let them have a new one
        TriggerClientEvent('mwg-herbs:pScores', pSrc, PlayerScores[currentUUID[pSrc]])
    else
        -- { DELIVERYDATE, DELIVERYSTARTVEC, DELIVERYSTOPVEC, DELIVERY DETAILS, HASMOONSHINE, DELIVERYITEM}
        -----------------------------------------------------------------------------------------------------------
        local DeliveryStart = os.time()
        local DeliveryType = menuDetails[1]
        local DeliveryItem = menuDetails[2]
        -- defaults in case something borks
        local DeliveryStartVec = vector4(955.068481, -1758.196777, 46.176147, 346.498840)
        local DeliveryStopVec = vector3(972.281128, -1676.661255, 47.928902)
        local DeliveryRoute = {}
        --  random picks
        if DeliveryItem == 1 then
            -- oranges
            if DeliveryType == 1 then
                DeliveryRoute = GetRandomLegalDelivery(FruitDelivery.StartVector.BayouNwa, FruitDelivery.EndVector.legal)
            else
                DeliveryRoute = GetRandomIllegalDelivery(FruitDelivery.StartVector.BayouNwa, FruitDelivery.EndVector.illegal)
            end
        elseif DeliveryItem == 2 then
            -- lemons 
            if DeliveryType == 1 then
                DeliveryRoute = GetRandomLegalDelivery(FruitDelivery.StartVector.BayouNwa, FruitDelivery.EndVector.legal)
            else
                DeliveryRoute = GetRandomIllegalDelivery(FruitDelivery.StartVector.BayouNwa, FruitDelivery.EndVector.illegal)
            end
        elseif DeliveryItem == 3 then
            -- apples
            if DeliveryType == 1 then
                DeliveryRoute = GetRandomLegalDelivery(FruitDelivery.StartVector.Braithwaite, FruitDelivery.EndVector.legal)
            else
                DeliveryRoute = GetRandomIllegalDelivery(FruitDelivery.StartVector.Braithwaite, FruitDelivery.EndVector.illegal)
            end
        elseif DeliveryItem == 4 then
            -- pears
            if DeliveryType == 1 then
                DeliveryRoute = GetRandomLegalDelivery(FruitDelivery.StartVector.Braithwaite, FruitDelivery.EndVector.legal)
            else
                DeliveryRoute = GetRandomIllegalDelivery(FruitDelivery.StartVector.Braithwaite, FruitDelivery.EndVector.illegal)
            end
        elseif DeliveryItem == 5 then
            --peaches
            if DeliveryType == 1 then
                DeliveryRoute = GetRandomLegalDelivery(FruitDelivery.StartVector.CalligaHall, FruitDelivery.EndVector.legal)
            else
                DeliveryRoute = GetRandomIllegalDelivery(FruitDelivery.StartVector.CalligaHall, FruitDelivery.EndVector.illegal)
            end
        else
            -- all others, which shouldnt be any.
        end
        -----------------------------------------------------------------------------------------------------------
        PlayerScores[currentUUID[pSrc]].activeDeliveries = {DeliveryStart, DeliveryRoute.startVec, DeliveryRoute.endVec, 0, DeliveryItem, DeliveryRoute}
        if debugShow then
            print('Mission Request', pSrc, menuDetails[1], menuDetails[2], menuDetails[3], DeliveryStart, DeliveryStartVec, DeliveryStopVec, DeliveryItem)
        end
        -- save playerscores
        local fruitJSON = json.encode(PlayerScores[currentUUID[pSrc]])
        local updatecurrentplayer = execQuery(MySQL.query.await, 'UPDATE `_mkFruit` SET `fruitData` = ? WHERE `uuid` = ?', { fruitJSON, currentUUID[pSrc] })
        ---- send player thier new mission.        
        TriggerClientEvent('mwg-herbs:pScores', pSrc, PlayerScores[currentUUID[pSrc]])
    end
end)
--
RegisterNetEvent('mwg-herbs:updatemissionsstate')
AddEventHandler('mwg-herbs:updatemissionsstate', function(gamestate)
    local pSrc = source
    refreshDB(pSrc) 
    PlayerScores[currentUUID[pSrc]].activeDeliveries[4] = (PlayerScores[currentUUID[pSrc]].activeDeliveries[4] + 1)
    -- print("Player Mission Stage:", PlayerScores[currentUUID[pSrc]].activeDeliveries[4])
    if PlayerScores[currentUUID[pSrc]].activeDeliveries[4] == 3 then
        local hasShine = MoonshineCheckServer(pSrc, currentUUID[pSrc])
        if debugShow then        
            print('Mission Ended', PlayerScores[currentUUID[pSrc]].activeDeliveries[5], dDistance[currentUUID[pSrc]], 'legal:', PlayerScores[currentUUID[pSrc]].activeDeliveries[6].legality, "Has Moonshine unlock:", hasShine)
        end
        --- REWARD SECTION
        local legality = PlayerScores[currentUUID[pSrc]].activeDeliveries[6].legality
        local baseprice = 0
        local addonprice = (dDistance[currentUUID[pSrc]]/1000)
        local decprice = 0
        if legality then
            baseprice = (FruitPrices.Legal[PlayerScores[currentUUID[pSrc]].activeDeliveries[5]]/100)
            if debugShow then
                print('Legal Delivery:', PlayerScores[currentUUID[pSrc]].activeDeliveries[5], baseprice, addonprice)
            end
        else
            baseprice = (FruitPrices.Illegal[PlayerScores[currentUUID[pSrc]].activeDeliveries[5]]/100)
            if debugShow then
                print('Illegal Delivery:', PlayerScores[currentUUID[pSrc]].activeDeliveries[5], baseprice, addonprice)
            end
        end
        ---
        local rewardPrice = (baseprice+addonprice)-decprice
        TriggerEvent("mad:sv_giveMoneytoID", pSrc, rewardPrice)
        --
        if PlayerScores[currentUUID[pSrc]].activeDeliveries[5] == 1 then
            local newval = (PlayerScores[currentUUID[pSrc]].BayouNwaScores.oranges.value-20)
            PlayerScores[currentUUID[pSrc]].BayouNwaScores.oranges.value = newval
        elseif PlayerScores[currentUUID[pSrc]].activeDeliveries[5] == 2 then
            local newval = (PlayerScores[currentUUID[pSrc]].BayouNwaScores.lemons.value-20)
            PlayerScores[currentUUID[pSrc]].BayouNwaScores.lemons.value = newval
        elseif PlayerScores[currentUUID[pSrc]].activeDeliveries[5] == 3 then
            local newval = (PlayerScores[currentUUID[pSrc]].BraithwaiteScores.apples.value-20)
            PlayerScores[currentUUID[pSrc]].BraithwaiteScores.apples.value = newval
        elseif PlayerScores[currentUUID[pSrc]].activeDeliveries[5] == 4 then
            local newval = (PlayerScores[currentUUID[pSrc]].BraithwaiteScores.pears.value-20)
            PlayerScores[currentUUID[pSrc]].BraithwaiteScores.pears.value = newval
        elseif PlayerScores[currentUUID[pSrc]].activeDeliveries[5] == 5 then
            local newval = (PlayerScores[currentUUID[pSrc]].CalligaHallScores.peaches.value-20)
            PlayerScores[currentUUID[pSrc]].CalligaHallScores.peaches.value = newval
        end
        -- send to moonshine script if the delivery was moonshine.TriggerServerEvent('mad-moonshine:fruit', )
        if not legality then HandleIllegalDelivery(PlayerScores[currentUUID[pSrc]].activeDeliveries[5], pSrc) end
        --
        PlayerScores[currentUUID[pSrc]].activeDeliveries[1] = (os.time() + (60 * FruitDelivery.MissionCoolDownInMinutes))
        local fruitJSON = json.encode(PlayerScores[currentUUID[pSrc]])
        local updatecurrentplayer = execQuery(MySQL.query.await, 'UPDATE `_mkFruit` SET `fruitData` = ? WHERE `uuid` = ?', { fruitJSON, currentUUID[pSrc] })
    end
    TriggerClientEvent('mwg-herbs:pScores', pSrc, PlayerScores[currentUUID[pSrc]])
end)
----------------------------------------
RegisterNetEvent('mwg-herbs:vehicledestroyed')
AddEventHandler('mwg-herbs:vehicledestroyed', function(gamestate)
    local pSrc = source
    PlayerScores[currentUUID[pSrc]].activeDeliveries[4] = 0
    TriggerClientEvent('mwg-herbs:pScores', pSrc, PlayerScores[currentUUID[pSrc]])
end)
----------------------------------------
RegisterNetEvent('mwg-herbs:missionDistance')
AddEventHandler('mwg-herbs:missionDistance', function(distance)
    local pSrc = source
    dDistance[currentUUID[pSrc]] = distance
    TriggerClientEvent('mwg-herbs:pScores', pSrc, PlayerScores[currentUUID[pSrc]])
end)
----------------------------------------
RegisterNetEvent('mwg-herbs:cooldownwait')
AddEventHandler('mwg-herbs:cooldownwait', function(gamestate)
    local pSrc = source
    if debugShow then
        print('CoolDown', pSrc, PlayerScores[currentUUID[pSrc]].activeDeliveries[1])
    end
    local cooldownEnd = PlayerScores[currentUUID[pSrc]].activeDeliveries[1]
    if cooldownEnd <= os.time() then
        if debugShow then
            print('releasing cooldown on:', pSrc, cooldownEnd)
        end
        PlayerScores[currentUUID[pSrc]].activeDeliveries = nil
        local fruitJSON = json.encode(PlayerScores[currentUUID[pSrc]])
        local updatecurrentplayer = execQuery(MySQL.query.await, 'UPDATE `_mkFruit` SET `fruitData` = ? WHERE `uuid` = ?', { fruitJSON, currentUUID[pSrc] })
    else
        local difftime = (cooldownEnd - os.time())
        TriggerClientEvent('mwg-herbs:cdTimer', pSrc, difftime)
    end
    TriggerClientEvent('mwg-herbs:pScores', pSrc, PlayerScores[currentUUID[pSrc]])
end)
---------------------------------------------------------------------------------------------------------------------------------------
-- THIS PART IS THE SPECIAL HERB MISSION TRACKER
---------------------------------------------------------------------------------------------------------------------------------------
function updateHerbType()
    local diffT = (os.time() - lastUpdatedRare)
    if diffT >= 1200 then
        local randRareHerb = math.random(1, #RareHerbList)
        CurrentRareHerb = RareHerbList[randRareHerb]
        local randRareLoc = math.random(1, #RareHerbLocations)
        CurrentRareLoc = RareHerbLocations[randRareLoc]
        lastUpdatedRare = os.time()
        print('Mission Type Updated:', CurrentRareHerb.name, CurrentRareLoc[2].x, CurrentRareLoc[2].y)
    end
    TriggerClientEvent('mwg-herbs:rareinfo', -1, {CurrentRareHerb.name, CurrentRareHerb.desc, CurrentRareHerb.invhash})
end
CreateThread(function()
    while true do
        updateHerbType()  
        Citizen.Wait(10000)
    end
end)
----------------------------------------
RegisterNetEvent('mwg-herbs:requestherbmission')
AddEventHandler('mwg-herbs:requestherbmission', function()
    local pSrc = source
    refreshDB(pSrc)
    if RareHerbMission[currentUUID[pSrc]] == nil then
        RareHerbMission[currentUUID[pSrc]] = {}
        RareHerbMission[currentUUID[pSrc]].inittime = os.time()
        RareHerbMission[currentUUID[pSrc]].HerbType = CurrentRareHerb
        RareHerbMission[currentUUID[pSrc]].HerbLocation = CurrentRareLoc
        TriggerClientEvent('mwg-herbs:acceptmission', pSrc, RareHerbMission[currentUUID[pSrc]])
        TriggerEvent("mad:sv_giveMoneytoID", pSrc, -1)
        local missJSON = json.encode(RareHerbMission[currentUUID[pSrc]])
        local updatecurrentplayer = execQuery(MySQL.query.await, 'UPDATE `_mkRareHerbs` SET `Missions` = ? WHERE `uuid` = ?', { missJSON, currentUUID[pSrc] })
    else
        TriggerClientEvent('mwg-herbs:acceptmission', pSrc, RareHerbMission[currentUUID[pSrc]])
    end
end)
----------------------------------------
RegisterNetEvent('mwg-herbs:finishherbmission')
AddEventHandler('mwg-herbs:finishherbmission', function()
    local pSrc = source
    refreshDB(pSrc)
    RareHerbMission[currentUUID[pSrc]] = nil
    TriggerClientEvent('mwg-herbs:endmission', pSrc, true)
    local updatecurrentplayer = execQuery(MySQL.query.await, 'UPDATE `_mkRareHerbs` SET `Missions` = ? WHERE `uuid` = ?', { nil, currentUUID[pSrc] })
end)