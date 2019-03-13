local modem = peripheral.wrap("back")
local wModem = peripheral.wrap("left")
local sID = os.getComputerID()
local pNames = modem.getNamesRemote()
local eCells = {}
local energy, maxEnergy = 0, 0
for i,name in ipairs(pNames) do eCells[i] = peripheral.wrap(name) end
for _,eCell in ipairs(eCells) do maxEnergy = maxEnergy + eCell.getMaxEnergyStored() end
wModem.open(sID)
print("Battery bank open on channel "..sID)

function updateEnergy()
  local temp, e = 0
  for _,eCell in ipairs(eCells) do temp = temp + eCell.getEnergyStored() end
  energy = temp
end

local e
while true do
  os.queueEvent("dummy")
  while true do
    e = {os.pullEvent()}
    if e[1] == "key" and e[2] == keys.tab then error()
    elseif e[1] == "modem_message" and e[5] == "getEnergy" then
      updateEnergy()
      wModem.transmit(e[4],sID,{"battbank","getEnergy",energy})
      print("sent energy reading to ",e[4])
    elseif e[1] == "modem_message" and e[5] == "getMaxEnergy" then
      wModem.transmit(e[4],sID,{"battbank","getMaxEnergy",maxEnergy})
      print("sent max energy to ",e[4])
    elseif e[1] == "dummy" then break end
  end
end