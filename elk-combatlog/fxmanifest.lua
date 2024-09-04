fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'elk'
description 'F8 Combat Log Info System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua' 
}

client_scripts {
    'client/client.lua' 
}

server_scripts {
    'server/server.lua' 
}

files {
    'html/index.html',
    'html/script.js'
}

ui_page 'html/index.html'
