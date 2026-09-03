lua54 'yes'

fx_version 'cerulean'
game 'gta5'

author 'D9_Dev'
description 'D9 item usable: painkiller, armor, AED'

dependencies {
    'es_extended',
    'ox_lib',
    'd9_lib',
}

shared_script {
    '@ox_lib/init.lua',
    '@d9_lib/init.lua',
    'config/config.lua',
    'config/config_function.lua',
    'shared/function.lua',
}

client_scripts {
    'client/dead.lua',
    'client/function.lua',
    'client/client.lua',
}

server_scripts {
    'server/function.lua',
    'server/server.lua',
}
