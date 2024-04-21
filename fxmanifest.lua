fx_version "cerulean"
lua54 "yes"
game "gta5"
author "Writer"
description "Prisons system"

shared_scripts {
	"@ox_lib/init.lua",
	"shared/*.lua"
}

client_scripts {
	"activities/*.lua",
	"client/*.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"server/*.lua"
}

files {
	"locales/*.json"
}