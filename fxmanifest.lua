--[[ FX Information ]]--
fx_version   'cerulean'
lua54        'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game         'rdr3'
use_fxv2_oal 'yes'
--[[ Resource Information ]]--
name 'mwg_herbs'
author 'mikethemadkiwi'
description 'Herb Picking For RedM Using Native RDR3 Interfaces'
version '0.0.1'
--[[ Dependancies ]]--
dependencies {
    '/onesync',
}
--[[ Shared Scripts ]]--
shared_scripts {
    'hConfig.lua'
}
--[[ Client Scripts ]]--
client_scripts {
    'dataview.lua',
    'hClientFunctions.lua', -- player editable//
    'hClient.lua', -- handles basic composite herb conversions.
    'hTree.lua', -- handles tree picking
    'hDelivery.lua', -- handles fruit deliveries
    'hSpecial.lua' -- handles special herb missions for orchids  rare flowers etc
    -- 'herb.js'
}
--[[ Server Scripts ]]--
server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'hServerFunctions.lua', -- player editable//
    'hServer.lua'
}
--[[ Editable Files ]]--
escrow_ignore {
    'hConfig.lua',
    'hServerFunctions.lua',
    'hClientFunctions.lua'
}