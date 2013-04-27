#!/bin/sh

LUA_PATH="/opt/local/share/luarocks/share/lua/5.1//?.lua;/opt/local/share/luarocks/share/lua/5.1//?/init.lua;/opt/local/share/lua/5.1//?.lua;/opt/local/share/lua/5.1//?/init.lua;/opt/local/share/lua/5.1//?.lua;/opt/local/share/lua/5.1//?/init.lua;./?.lua;/opt/local/share/lua/5.1/?.lua;/opt/local/share/lua/5.1/?/init.lua;/opt/local/lib/lua/5.1/?.lua;/opt/local/lib/lua/5.1/?/init.lua;$LUA_PATH"
LUA_CPATH="/opt/local/share/luarocks/lib/lua/5.1//?.so;./?.so;/opt/local/lib/lua/5.1/?.so;/opt/local/lib/lua/5.1/loadall.so;$LUA_CPATH"
export LUA_PATH LUA_CPATH
exec "/opt/local/bin/lua" -lluarocks.loader "/opt/local/share/luarocks/lib/luarocks/rocks/luaprofiler/2.0.2-2/bin/summary.lua" "$@"
