let GAMETICK = setTick(async() => {
    let AIEvents = GetNumberOfEvents(0)
    if(AIEvents>0){
        for (let eventkey = 0; eventkey < AIEvents; eventkey++) {
            const element = GetEventAtIndex(0, eventkey);
            let buffer = new ArrayBuffer(256);
			let largebuffer = new ArrayBuffer(1024);
            let view = new DataView(buffer);
			let largeview = new DataView(largebuffer);		
            switch(element){
                case 1626561060: // ped destroyed

                break;
                case 735942751: // ped created

                break;
                case 1669410864: // challegne goal stuff

                break;
                case 1640116056://	-- EVENT_LOOT_PLANT_START
                    //36
                    Citizen.invokeNative("0x57EC5FA4D4D6AFCA", 0, eventkey, view, 36, Citizen.returnResultAnyway());
                    let plantlootCalc = new Int32Array(buffer);
                    console.log('plantlootCalc', plantlootCalc)
                    
                break;
                case -2091944374://	-- EVENT_CALCULATE_LOOT
                    // 26
                    Citizen.invokeNative("0x57EC5FA4D4D6AFCA", 0, eventkey, view, 26, Citizen.returnResultAnyway());
                    let lootCalc = new Int32Array(buffer);
                    console.log('lootCalc', lootCalc)
                break;
                case 1376140891:// -- EVENT_LOOT_COMPLETE
                    // 3
                    Citizen.invokeNative("0x57EC5FA4D4D6AFCA", 0, eventkey, view, 3, Citizen.returnResultAnyway());
                    let lootComplete = new Int32Array(buffer);
                    console.log('lootComplete', lootComplete)
                break;
                case -1511724297: // this is the network loot event. so we take EVERYTHING, filter the looted itemhash in the next function.
                    // Citizen.invokeNative("0x57EC5FA4D4D6AFCA", 0, eventkey, view, 36, Citizen.returnResultAnyway());
                    // let lootevent = new Int32Array(buffer);
                    // console.log('herbdata', lootevent)
                break;
                default:
                    // console.log('event', element)
            }
        }
    }
})