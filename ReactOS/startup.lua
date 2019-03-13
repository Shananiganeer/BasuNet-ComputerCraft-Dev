if fs.exists("ReactOS/bin.lua") then fs.delete("ReactOS/bin.lua") end
if not fs.exists("apis/wp") then shell.run("pastebin","get","cT9pWVgB","apis/wp") end
shell.run("pastebin","get","gCuAFFFh","ReactOS/bin.lua")
dofile("ReactOS/bin.lua")