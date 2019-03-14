os.loadAPI("apis/gh.lua")
local repo = "https://raw.githubusercontent.com/Shananiganeer/BasuNet-ComputerCraft-Dev/master/"
local paths = {}
paths[#paths+1] = "ReactOS/bin.lua"
paths[#paths+1] = "ReactOS/startup.lua"
paths[#paths+1] = "apis/wp.lua"
paths[#paths+1] = "apis/gh.lua"
gh.fetchPaths(repo, paths)
fs.delete("startup")
fs.copy("ReactOS/startup.lua", "startup")
dofile("ReactOS/bin.lua")