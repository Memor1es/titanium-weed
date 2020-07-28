fx_version "bodacious"
games {"gta5"}

client_scripts { 
	"client/config.lua",
    "client/utils.lua",
    "client/main.lua" 
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/config.lua',

	'server/weed.lua',
	'server/utils.lua',
	'server/main.lua'
}

ui_page('html/UI.html')

files({
    'html/UI.html',
    'html/style.css',
	'html/assets/BebasNeue.ttf'
})
