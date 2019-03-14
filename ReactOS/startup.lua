local REPO = "https://raw.githubusercontent.com/Shananiganeer/BasuNet-ComputerCraft-Dev/master/"
local GH_DEP = "apis/gh.lua"
local paths = {}
paths[#paths+1] = "ReactOS/bin.lua"
paths[#paths+1] = "ReactOS/startup.lua"
paths[#paths+1] = "apis/wp.lua"

local h, f = http.get(REPO..GH_DEP), fs.open(GH_DEP, "w")
f.write(h.readAll())
h.close()
f.close()

os.loadAPI("apis/gh.lua")
gh.fetchPaths(REPO, paths)
fs.delete("startup")
fs.copy("ReactOS/startup.lua", "startup")
dofile("ReactOS/bin.lua")