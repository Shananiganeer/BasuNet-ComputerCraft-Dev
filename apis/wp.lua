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
  local chs = {}
  modem.transmit(BD_CH, mID, {pkt = "FIND_REQ", per = per})
  local timeout = os.startTimer(4)
  while true do
    local e = {os.pullEvent()}
    if e[1] == "timer" then
      return chs
    elseif e[1] == "modem_message" and e[3] == mID then
      chs[#chs+1] = e[4]
    end
  end
end

function wrap(per, sID)
  local p = {
    per = per,
    sID = sID,
    mID = mID,
  }
  modem.transmit(sID, mID, {pkt = "WRAP_REQ", per = per})
  local timeout = startTimer(4)
  local e = {os.pullEvent()}
  if e[1] == "timer" then
  print()
  elseif e[1] == "modem_message" then
    for k, v in pairs(e[5]) do
      p[v] = function(...)
        modem.transmit(sID, mID, {pkt = "PER_REQ", per = per, call = v, params = {...}})
        local timeout = os.startTimer(4)
        while true do
          local e = {os.pullEvent()}
          if e[1] == "modem_message" then
            if e[5][2] == v then
              os.cancelTimer(timeout)
              return unpack(e[5][1])
            else
              os.queueEvent(unpack(e))
            end
          elseif e[1] == "timer" and e[2] == timeout then
            print("Timeout on "..per.."."..v)
            break
          end
        end
      end
    end
    if per == "reactor" then
      p.getBundledStats = function()
        while true do
          modem.transmit(sID, mID, {pkt = "BR_REQ"})
          local timeout = os.startTimer(4)
          e = {os.pullEvent()}
          if e[1] == "timer" then
          elseif e[1] == "modem_message" then
            return e[5]
          end
        end
      end
    end
  end
  
  setmetatable(p, {__index = p})
  return p
end