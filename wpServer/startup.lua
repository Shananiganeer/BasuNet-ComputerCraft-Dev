local REPO = "https://raw.githubusercontent.com/Shananiganeer/BasuNet-ComputerCraft-Dev/master/"
local GH_DEP = "apis/gh.lua"
local paths = {}
paths[#paths+1] = "wpServer/bin.lua"
paths[#paths+1] = "wpServer/startup.lua"

local h, f = http.get(REPO..GH_DEP), fs.open(GH_DEP, "w")
f.write(h.readAll())
h.close()
f.close()

os.loadAPI("apis/gh.lua")
gh.fetchPaths(REPO, paths)
fs.delete("startup")
fs.copy("wpServer/startup.lua", "startup")
dofile("wpServer/bin.lua")