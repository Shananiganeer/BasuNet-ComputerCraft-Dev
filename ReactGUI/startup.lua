if fs.exists("ReactGUI/bin.lua") then fs.delete("ReactGUI/bin.lua") end
if not fs.exists("apis/wp") then shell.run("pastebin","get","cT9pWVgB","apis/wp") end
if not fs.exists("apis/win") then shell.run("pastebin","get","EPpfCBtT","apis/win") end
shell.run("pastebin","get","vZ9Aj8bA","ReactGUI/bin.lua")
dofile("ReactGUI/bin.lua")