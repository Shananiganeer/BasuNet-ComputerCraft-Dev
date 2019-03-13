local modem = peripheral.find("modem")
local sID = os.getComputerID()
local pers, chs = {}, {}
for _,v in pairs(peripheral.getNames()) do
  local pT = peripheral.getType(v)
  if pT == "BigReactors-Reactor" then pT = "reactor" end
  pers[pT] = v
end
if modem then
  modem.open(sID)
  print("Wireless server is open on channel "..sID)
else
  print("No modem found.")
  error()
end

function transmit(ch, info)
	modem.transmit(ch, sID, info)
end

function broadcast(info)
  for ch,_ in pairs(chs) do transmit(ch, info) end
end

function openCH(ch)
  chs[ch] = true
end

function closeCH(ch)
  chs[ch] = nil
end

function preq(per)

end

while true do
	event = {os.pullEvent()}
  local mID = event[4]
	if event[1] == "modem_message" and type(event[5]) == "table" then
		local response = {peripheral.call(pers[event[5].per], event[5].call, unpack(event[5].params))}
    openCH(mID)
		transmit(mID, {response, event[5].call})
		print(event[5].per.." response sent to "..mID)
	elseif event[1] == "modem_message" and type(event[5]) == "string" then
		local pm = peripheral.getMethods(pers[event[5]])
    openCH(mID)
		transmit(mID, pm)
		print(event[5]," table sent to "..mID)
  elseif event[1] == "modem_message" and event[3]==65535 then
    if event[5]["pkt"] == "PER_REQ" then
      peripheral.find(event[5]["per"])
    end
  elseif event[1] == "modem_message" then
	else
		broadcast({"wpe", event})
		print(event[1].." event sent")
	end
end