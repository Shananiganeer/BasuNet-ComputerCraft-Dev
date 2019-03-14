local Env = {}
setmetatable(Env, {__index = _G})
setfenv(1, Env)
os.loadAPI("apis/wp.lua")
if fs.exists("/ReactOS/ch.cfg") then
  local cfg = fs.open("/ReactOS/ch.cfg", "r")
  ch = tonumber(cfg.readLine())
  cfg.close()
else
  local r = wp.locate("reactor")
  if #r == 1 then ch = r[1]
  elseif #r > 1 then
    print("#     Ch")
    for i=1, 1, i <= #r do
      print(i + ":    " + r[i])
    end
    print("Select a ch: ")
    local i = read()
    ch = tonumber(r[i])
  end
  local cfg = fs.open("/ReactOS/ch.cfg", "w")
  cfg.write(ch)
  cfg.close()
end
keepAlive = true
reactor = wp.wrap("reactor", ch)
maxEnergy, minEnergy = 9, 1
fps, fpsCalc, fCount = true, 0, 0
fTime, lTime = os.epoch("utc"), os.epoch("utc")
tSize = {term.getSize()}
col = math.ceil(tSize[1]/2) - 4
gui = window.create(term.native(), 1, 1, tSize[1], tSize[2], true)
term.redirect(gui)
left, center, right = 3, math.ceil((tSize[1] - col)/2), tSize[1] - col - 2
statX, statY, statPre = center, 2, "Reactor:"
caseX, caseY, casePre = left, statY + 4, "Case:"
coreX, coreY, corePre = left, caseY + 3, "Core:"
enrgX, enrgY, enrgPre = left, coreY + 3, "Energy:"
rfX, rfY, rfPre = right, caseY, "Output:"
fuelX, fuelY, fuelPre = right, coreY, "Fuel:"
effX, effY, effPre = right, enrgY, "RF/Fuel:"
rodX, rodY, rodPre = center, tSize[2] - 3, "Rods:"
cmdX, cmdY, cmdPre = 1, tSize[2] - 1, "Enter command: "
display = {}
display[statY] = "stat"
display[rodY] = "rod"
if (tSize[1] < 51) then
  statX, rodX, col = left, left, 22
  coreY = caseY + 1
  enrgY = coreY + 2
  rfX, rfY = left, enrgY + 1
  fuelX, fuelY = left, rfY + 2
  effX, effY = left, fuelY + 1
  display[caseY] = "case"
  display[rfY] = "rf"
  display[coreY] = "core"
  display[fuelY] = "fuel"
  display[enrgY] = "enrg"
  display[effY] = "eff"
else
  display[caseY] = "case rf"
  display[coreY] = "core fuel"
  display[enrgY] = "enrg eff"
end
cPos = {gui.getCursorPos()}

term.clear()

for n in pairs(display) do
  for word in string.gmatch(display[n], "(%w+)") do
    local x, y, pre, str = Env[word.."X"], Env[word.."Y"], Env[word.."Pre"], Env[word.."Str"]
    gui.setCursorPos(x, y)
    gui.write(pre)
  end
end

function round(x, digit, pad)
  if not type(x) == "number" then return x end
  x = x * math.pow(10, digit)
  if x>=0 then x=math.floor(x+0.5) else x=math.ceil(x-0.5) end
  x = x / math.pow(10, digit)
  if pad and #(""..x) < #(""..pad) then
    local count = #(""..pad) - #(""..x)
    local spaces = ""
    for i = 1, count do
      spaces = spaces.." "
    end
    x = spaces..x
  end
  return x
end

function optimizeRods()
end

function parseCmd(input)
  local arg = {}
  local argCount = 1
  gui.setCursorPos(cmdX, cmdY)
  gui.clearLine()
  for word in string.gmatch(input, "(%w+)") do
    arg[argCount] = word
    argCount = argCount + 1
  end
  if arg[1] == "rod" and argCount > 1 then
    reactor.setAllControlRodLevels(tonumber(arg[2]))
  elseif arg[1] == "optimize" then
    optimizeRods()
  elseif arg[1] == "exit" then
    keepAlive = false
  end
end

function updateStats()
  
  stat = reactor.getActive()
  if stat then statStr = "  Active" else statStr = "Inactive" end
  case = reactor.getCasingTemperature()
  caseStr = string.format("%s C", round(case, 0, 4))
  core = reactor.getFuelTemperature()
  coreStr = string.format("%s C", round(core, 0, 4))
  enrg = reactor.getEnergyStored()/1000000
  enrgStr = string.format("%s MRF", round(enrg, 2, 4))
  rf = reactor.getEnergyProducedLastTick()
  rfStr = string.format("%s RF/t", round(rf, 0, 6))
  fuel = reactor.getFuelConsumedLastTick()
  if not fuel == 0 then fuel = 1000/(fuel*20) end
  fuelStr = string.format("%s mB/s", round(fuel, 2, 3))
  if not fuel == 0 then eff = rf/fuel*1000 else eff = 0 end
  effStr = string.format("%s rf/mB", round(eff, 2, 2))
  rod = reactor.getControlRodLevel(1)
  rodStr = string.format("%s%%", round(rod, 0, 2))
end

function refreshLine(line)
  gui.setCursorPos(1, line)
  for word in string.gmatch(display[line], "(%w+)") do
    local x, y, str = Env[word.."X"], Env[word.."Y"], Env[word.."Str"]
    gui.setCursorPos(x+col-#str, y)
    gui.write(str)
  end
end

function displayLoop()
  os.queueEvent("displayDummy")
  while true do
    cPos = {gui.getCursorPos()}
    fCount = fCount + 1
    updateStats()
    for n in pairs(display) do refreshLine(n) end
    fTime = os.epoch("utc")
    if fps and fCount % 10 == 0 then
      gui.setCursorPos(1, tSize[2])
      fpsCalc = 1000/((fTime-lTime)/10)
      fpsStr = string.format("%f", round(fpsCalc, 2))
      gui.write(fpsStr)
      lTime = fTime
    end
    gui.setCursorPos(tSize[1]-8, tSize[2])
    gui.write(textutils.formatTime((fTime/3600000000) % 24, true))
    
    gui.setCursorPos(cPos[1], cPos[2])
    
    local e = os.pullEvent()
    if e == "displayDummy" then os.queueEvent("displayDummy") end
  end
end

function controlLoop()
  os.startTimer(1)
  while true do
    if enrg >= maxEnergy and stat then
      reactor.setActive(false)
    elseif enrg <= minEnergy and not stat then
      reactor.setActive(true)
    end

    local e = os.pullEvent("timer")
    os.startTimer(1)
    --if e == "controlDummy" then os.queueEvent("controlDummy") end
  end
end

function checkInput()
  while true do
    local e, key = os.pullEvent("key")
    if (e == "key" and key == keys.enter) then break
    elseif (e == "key" and key == keys.f) then fps = not fps end
  end
  gui.setCursorPos(cmdX, cmdY)
  gui.clearLine()
  gui.write(cmdPre)
  cPos = {gui.getCursorPos()}
  local input = read()
  parseCmd(input)
end

updateStats()

while keepAlive do
  parallel.waitForAny(displayLoop, controlLoop, checkInput)
end

term.clear()