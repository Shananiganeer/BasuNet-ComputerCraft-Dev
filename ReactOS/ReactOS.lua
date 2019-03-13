local Env = {}
setmetatable(Env, {__index = _G})
setfenv(1, Env)
os.loadAPI("apis/wpMaster")
keepAlive = true
reactor = wpMaster.wrap("reactor", 4)
maxEnergy = 9
minEnergy = 1
frameCount = 0
gui = window.create(term.native(), 1, 1, 51, 19, true)
term.redirect(gui)
left, center, right = 3, 16, 27
statX, statY = center, 2
caseX, caseY = left, statY+4
coreX, coreY = left, caseY+3
enrgX, enrgY = left, coreY+3
rfX, rfY = right, statY+4
fuelX, fuelY = right, rfY+3
effX, effY = right, fuelY+3
rodX, rodY = center-4, statY+14
cmdX, cmdY = 1, 18
display = {}
display[statY] = "stat"
display[caseY] = "case rf"
display[coreY] = "core fuel"
display[enrgY] = "enrg eff"
display[rodY] = "rod"

term.clear()

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
  gui.write("                                ")
  gui.setCursorPos(cmdX, cmdY)
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
  if stat then statStr = "Reactor is active" else statStr = "Reactor is inactive" end
  case = reactor.getCasingTemperature()
  case = round(case, 2)
  caseStr = string.format("Case temp: %s C", case)
  core = reactor.getFuelTemperature()
  core = round(core, 2)
  coreStr = string.format("Core temp: %s C", core)
  enrg = reactor.getEnergyStored()/1000000
  enrg = round(enrg, 2)
  enrgStr = string.format("Energy stored: %s mRF", enrg)
  rf = reactor.getEnergyProducedLastTick()
  rf = round(rf, 2)
  rfStr = string.format("Output: %s RF/t", rf)
  fuel = reactor.getFuelConsumedLastTick()
  fuel = round(1000/(fuel*20), 0)
  fuelStr = "Fuel use: "..fuel.." s per ingot"
  eff = rf/reactor.getFuelConsumedLastTick()
  eff = round(eff, 2)
  effStr = "Efficiency: "..eff.." rf/mB"
  rod = reactor.getControlRodLevel(1)
  rodStr = "Control rod insertion: "..rod
end

function refreshLine(line)
  gui.setCursorPos(1, line)
  gui.clearLine()
  for word in string.gmatch(display[line], "(%w+)") do
    local x, y, str = word.."X", word.."Y", word.."Str"
    gui.setCursorPos(Env[x], Env[y])
    gui.write(Env[str])
  end
end

function displayLoop()
  --os.queueEvent("displayDummy")
  while true do
    updateStats()
    for n in pairs(display) do refreshLine(n) end
    --local e = os.pullEvent()
    --if e == "displayDummy" then os.queueEvent("displayDummy") end
    frameCount = frameCount + 1
    gui.setCursorPos(1,19)
    gui.write(frameCount)
    os.sleep(0.05)
  end
end

function controlLoop()
  --os.queueEvent("controlDummy")
  while true do
    if enrg >= maxEnergy and stat then
      reactor.setActive(false)
    elseif enrg <= minEnergy and not stat then
      reactor.setActive(true)
    end
    --local e = os.pullEvent()
    --if e == "controlDummy" then os.queueEvent("controlDummy") end
    os.sleep(0.05)
  end
end

function checkInput()
  while true do
    local event, key = os.pullEvent()
    if (event == "key" and key == keys.enter) then break end
  end
  gui.setCursorPos(cmdX, cmdY)
  gui.clearLine()
  gui.write("Enter command: ")
  local input = read()
  parseCmd(input)
end

updateStats()

while keepAlive do
  parallel.waitForAny(displayLoop, controlLoop, checkInput)
end

term.clear()