fx_version 'adamant'

game 'gta5'

author 'santos#0069'
description 'Simple Vehicle Auction Script'

shared_script 'config.lua'
shared_script 'notifications.lua'

server_scripts {
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	
	'server/*.lua',
}

client_scripts {
	'client/utils.lua',
	'client/enumerators.lua',
	'client/client.lua',
}



lua54 'yes'
shared_script '@rbSafeEvents/shared.lua'
