function MoonshineCheckServer(pSrc, uuid)
    if GetResourceState("mad-moonshine") == "started" then -- companion mod to herbs will handle the fruit once delivered.
        local moonshinedb = MySQL.single.await('SELECT * FROM _mkMoonshine WHERE uuid = ?', { uuid })
        local settingsdb = json.decode(moonshinedb.Settings)
        local bottlesdb = json.decode(moonshinedb.Moonshine)
        local ingredientdb = json.decode(moonshinedb.Ingredients)
        local missondb = json.decode(moonshinedb.Missions)
        if settingsdb.MoonshineUnlocked then
            TriggerClientEvent('mwg-herbs:moonshinecheck', pSrc, true)
            return true
        else
            TriggerClientEvent('mwg-herbs:moonshinecheck', pSrc, false)
            return false
        end        
    else
        -- set this to call whatever you want to make it...  link it to your "have they got mooonshine" boolean
        TriggerClientEvent('mwg-herbs:moonshinecheck', pSrc, false)
        return false
        ---
    end
end

function HandleIllegalDelivery(FruitType, pSrc)
    if GetResourceState("mad-moonshine") == "started" then
        TriggerEvent('mad-moonshine:fruit', {FruitType, pSrc})
    else
        -- you do you cuz. returns 1-5 as integer for fruit types. 
        -- 1 orange 2 lemon 3 apple 4 pear 5 peach
        -- print('illegal FruitType delivery completed: ', FruitType, pSrc)

        ----
    end
end