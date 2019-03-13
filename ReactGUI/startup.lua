if fs.exists("ReactGUI.lua") then fs.delete("ReactGUI.lua") end
if not fs.exists("apis/wpMaster") then shell.run("pastebin","get","cT9pWVgB","apis/wpMaster") end
if not fs.exists("apis/Win") then shell.run("pastebin","get","EPpfCBtT","apis/Win") end
shell.run("pastebin","get","vZ9Aj8bA","ReactGUI.lua")
dofile("ReactGUI.lua")