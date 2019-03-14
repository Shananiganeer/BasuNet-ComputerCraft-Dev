function github(repo, path)
  local h, file = http.get(repo..path), fs.open(path, "w")
  if not (h == nil) then
    file.write(h.readAll())
    h.close()
    print("Wrote "..repo..path.."to "..path)
  else
    print("Error obtaining: "..repo..path)
  end
  file.close()
end

local path = "ReactOS/bin.lua"
local repo = "https://raw.githubusercontent.com/Shananiganeer/BasuNet-ComputerCraft-Dev/master/"
github(repo, path)
path = "apis/wp.lua"
github(repo, path)
dofile("ReactOS/bin.lua")

