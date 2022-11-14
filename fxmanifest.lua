fx_version 'cerulean'
game 'gta5'

description 'qw-darkmarket'
version '0.2.0'
author 'qwadebot'

server_script {
	'server/*.lua',
}

client_scripts { 
    'client/*.lua' 
}
shared_scripts { 'config.lua' }

ui_page 'html/index.html'

files {
	'html/*.*',
}

lua54 'yes'