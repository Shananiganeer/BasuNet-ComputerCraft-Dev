local Env = {}
setmetatable(Env, {__index = _G})
setfenv(1, Env)
os.loadAPI("apis/wp")
if fs.exists("/ReactOS/cfg/ch") then
  local cfg = fs.open("/ReactOS/cfg/ch", "r")
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
  local cfg = fs.open("/ReactOS/cfg/ch", "w")
  cfg.write(ch)
  cfg.close()
end
os.startTimer(1)
keepAlive = true
reactor = wp.wrap("reactor", ch)
maxEnergy = 9
minEnergy = 1
fTime = os.epoch("local")
lTime = os.epoch("local")
tSize = {term.getSize()}
gui = window.create(term.native(), 1, 1, tSize[1], tSize[2], true)
term.redirect(gui)
left, center, right = 3, math.floor(tSize[1]/2)-12, math.floor(tSize[1]/2)+2
statX, statY = center, 2
statPre = "Reactor:"
caseX, caseY = left, statY+4
casePre = "Case temp:"
coreX, coreY = left, caseY+3
corePre = "Core temp:"
enrgX, enrgY = left, coreY+3
enrgPre = "Energy:"
rfX, rfY = right, statY+4
rfPre = "Output:"
fuelX, fuelY = right, rfY+3
fuelPre = "Fuel use:"
effX, effY = right, fuelY+3
effPre = "Efficiency:"
rodX, rodY = center, tSize[2]-3
rodPre = "Rod insertion:"
cmdX, cmdY = 1, 18
display = {}
display[statY] = "stat"
display[rodY] = "rod"
if (tSize[1] < 51) then
  statX = left
  coreY = caseY+1
  enrgY = coreY+1
  rfX, rfY = left, enrgY + 2
  fuelX, fuelY = left, rfY + 1
  effX, effY = left, fuelY + 1
  rodX = left
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
fps = true
cPos = {gui.getCursorPos()}

term.clear()

for n in pairs(display) do
  for word in string.gmatch(display[n], "(%w+)") do
    local x, y, pre, str = Env[word.."X"], Env[word.."Y"], Env[word.."Pre"], Env[word.."Str"]
    gui.setCursorPos(x, y)
    gui.write(pre)
  end
end

function round(x, digit)
  if not type(x) == "number" or x == "inf" then return x end
  x = x * math.pow(10, digit)
  if x>=0 then x=math.floor(x+0.5) else x=math.ceil(x-0.5) end
  x = x / math.pow(10, digit)
  return x
end

function exitOS()
  keepAlive = false
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
    exitOS()
  end
end

function updateStats()
  stat = reactor.getActive()
  if stat then statStr = "Active" else statStr = "Inactive" end
  case = reactor.getCasingTemperature()
  caseStr = string.format("%3d C", case)
  core = reactor.getFuelTemperature()
  coreStr = string.format("%3d C", core)
  enrg = reactor.getEnergyStored()/1000000
  enrgStr = string.format("%2.2f MRF", enrg)
  rf = reactor.getEnergyProducedLastTick()
  rfStr = string.format("%d RF/t", rf)
  fuel = 1000/(reactor.getFuelConsumedLastTick()*20)
  fuelStr = string.format("%1.2f mB/s", fuel)
  eff = rf/fuel*1000
  effStr = string.format("%3.2f rf/mB", eff)
  rod = reactor.getControlRodLevel(1)
  rodStr = string.format("%d%%", rod)
end

function refreshLine(line)
  gui.setCursorPos(1, line)
  for word in string.gmatch(display[line], "(%w+)") do
    local x, y, pre, str = Env[word.."X"], Env[word.."Y"], Env[word.."Pre"], Env[word.."Str"]
    gui.setCursorPos(x+22-#str, y)
    gui.write(str)
  end
end

function displayLoop()
  os.queueEvent("displayDummy")
  while true do
    cPos = {gui.getCursorPos()}
    updateStats()
    for n in pairs(display) do refreshLine(n) end
    fTime = os.epoch("local")
    if fps then
      gui.setCursorPos(1, tSize[2])
      gui.write(string.format("%2.2f", 1000/(fTime-lTime)))
    end
    lTime = fTime
    gui.setCursorPos(tSize[1]-4, tSize[2])
    gui.write(textutils.formatTime(fTime, true))
    
    gui.setCursorPos(cPos[1], cPos[2])
    
    local e = os.pullEvent()
    if e == "displayDummy" then os.queueEvent("displayDummy") end
    --os.sleep(0.05)
  end
end

function controlLoop()
  os.queueEvent("controlDummy")
  while true do
    if enrg >= maxEnergy and stat then
      reactor.setActive(false)
    elseif enrg <= minEnergy and not stat then
      reactor.setActive(true)
    end

    local e = os.pullEvent()
    if e == "controlDummy" then os.queueEvent("controlDummy") end
    --os.sleep(0.05)
  end
end

function checkInput()
  while true do
    local e, key = os.pullEvent()
    if (e == "key" and key == keys.enter) then break end
  end
  gui.setCursorPos(cmdX, cmdY)
  gui.clearLine()
  gui.write("Enter command: ")
  cPos = {gui.getCursorPos()}
  local input = read()
  parseCmd(input)
end

updateStats()

while keepAlive do
  parallel.waitForAny(displayLoop, controlLoop, checkInput)
end

term.clear()