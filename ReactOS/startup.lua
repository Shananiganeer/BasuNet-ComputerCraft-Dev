local repo = "https://raw.githubusercontent.com/Shananiganeer/BasuNet-ComputerCraft-Dev/master/"
local paths = {}
paths[#paths+1] = "ReactOS/bin.lua"
paths[#paths+1] = "ReactOS/startup.lua"
paths[#paths+1] = "apis/wp.lua"
paths[#paths+1] = "apis/gh.lua"

if not fs.exists(paths[4]) then
  local h, f = http.get(repo..paths[4]), fs.open(paths[4])
  f.write(h.readAll())
  h.close()
  f.close()
end

os.loadAPI("apis/gh.lua")
gh.fetchPaths(repo, paths)
fs.delete("startup")
fs.copy("ReactOS/startup.lua", "startup")
dofile("ReactOS/bin.lua")