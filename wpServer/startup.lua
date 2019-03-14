if fs.exists("wpServer/bin.lua") then fs.delete("wpServer/bin.lua") end
shell.run("pastebin","get","gCuAFFFh","wpServer/bin.lua")
dofile("wpServer/bin.lua")