local BD_CH = 65535
local modem = peripheral.find("modem")
local mID = os.getComputerID()
if modem then
  modem.open(mID)
  modem.open(BD_CH)
else
  print("No modem found.")
  error()
end

local oldos = {}
for k, v in pairs(os) do
  oldos[k] = v
end

function os.pullEventRaw(...)
  local args = {...}
  local event = {oldos.pullEventRaw(unpack(args))}
  if event[1] == "modem_message" and type(event[5]) == "table" and event[5][1] == "wpe" then
    return unpack(event[5][2])
  else
    return unpack(event)
  end
end

function locate(per)
  local msg = {}
  local rVal = {}
  msg["pkt"] = "PER_REQ"
  msg["per"] = per
  modem.transmit(BD_CH, mID, msg)
  local timeout = os.startTimer(0.25)
  while true do
    local e = {os.pullEvent()}
    if e[1] == "timer" then
      return rVal
    elseif e[1] == "modem_message" and e[3] == mID then
      rVal[#rVal+1] = e[4]
    end
  end
end

function wrap(per, sID)
  local p = {
    per = per,
    sID = sID,
    mID = mID,
  }
  modem.transmit(sID, mID, per)
  msg = {os.pullEvent("modem_message")}
  for k, v in pairs(msg[5]) do
    p[v] = function(...)
      modem.transmit(sID, mID, {per = per, call = v, params = {...}})
      os.startTimer(1)
      while true do
        local e = {os.pullEvent()}
        if e[1] == "modem_message" then
          if e[5][2] == v then
            return unpack(e[5][1])
          else
            os.queueEvent(unpack(e))
          end
        elseif e[1] == "timer" then
          print("Timeout on "..per.."."..v)
          break
        end
      end
    end
  end
  --p._index = p
  --setmetatable(p, {_index = p})
  return p
end