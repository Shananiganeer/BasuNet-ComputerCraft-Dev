local Env = {}
setmetatable(Env, {__index = _G})
setfenv(1, Env)

BD_CH = 65535
modem = peripheral.find("modem")
sID = os.getComputerID()
pers, chs = {}, {}

term.clear()
term.setCursorPos(1, 1)

for _,v in pairs(peripheral.getNames()) do
  local pT = peripheral.getType(v)
  if pT == "BigReactors-Reactor" then pT = "reactor" end
  pers[pT] = v
end

if modem then
  modem.open(sID)
  modem.open(BD_CH)
  print("Wireless Peripheral server is open on channel "..sID)
else
  print("No modem found.")
  error()
end

function openCH(ch)
  chs[ch] = true
end

function closeCH(ch)
  chs[ch] = nil
end

function xmit(ch, info)
	modem.transmit(ch, sID, info)
end

function broadcast(info)
  for ch,_ in pairs(chs) do xmit(ch, info) end
end

function brCall()
  local rVal = {}
  local reactor = peripheral.wrap(pers.reactor)
  rVal[1] = reactor.getActive()
  rVal[2] = reactor.getCasingTemperature()
  rVal[3] = reactor.getFuelTemperature()
  rVal[4] = reactor.getEnergyStored()/1000000
  rVal[5] = reactor.getEnergyProducedLastTick()
  rVal[6] = reactor.getFuelConsumedLastTick()
  rVal[7] = reactor.getControlRodLevel(1)
  return rVal
end

while true do
	event = {os.pullEvent()}
  local mID = event[4]
	if event[1] == "modem_message" and event[3] == sID and event[5].pkt == "PER_REQ" then
    local response = {peripheral.call(pers[event[5].per], event[5].call, unpack(event[5].params))}
    xmit(mID, {response, event[5].call})
    print(event[5].per.." response sent to "..mID)
	elseif event[1] == "modem_message" and event[3] == sID and event[5].pkt == "WRAP_REQ" then
		local pm = peripheral.getMethods(pers[event[5].per])
    if event[5].per == "monitor" then
      openCH(mID)
    end
    xmit(mID, pm)
    print(event[5].per.." table sent to "..mID)
  elseif event[1] == "modem_message" and event[3] == sID and event[5].pkt == "BR_REQ" then
		xmit(mID, brCall())
    print("reactor stats sent to "..mID)
  elseif event[1] == "modem_message" and event[3] == BD_CH and event[5].pkt == "FIND_REQ" then
    if peripheral.find(event[5].per) then xmit(mID, sID) end
  elseif event[1] == "modem_message" then
	elseif event[1] == "monitor_touch" then
		broadcast({"wpe", event})
		print(event[1].." event sent")
	end
end