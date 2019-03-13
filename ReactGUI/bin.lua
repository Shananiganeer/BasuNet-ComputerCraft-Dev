os.loadAPI("apis/wp")
os.loadAPI("apis/win")
local ch = 0
if fs.exists("/ReactGUI/cfg/ch") then
  local cfg = fs.open("/ReactGUI/cfg/ch", "r")
  ch = tonumber(cfg.readLine())
  cfg.close()
else
  local r = wp.locate("reactor")
  if #r == 1 then ch = r[1]
  elseif #r > 1 then
    print("#     Ch")
    for i=1,i++,i>#r do
      print(i + ":    "+r[i])
    end
    print("Select a ch: ")
    local i = read()
    ch = tonumber(r[i])
  end
  local cfg = fs.open("/ReactGUI/cfg/ch", "w")
  cfg.write(ch)
  cfg.close()
end
local reactor = wp.wrap("reactor", ch)
local maxEnergy = 9000000
local minEnergy = 1000000
local x, y = term.getSize()
local sc1 = Win.init(1, 1, x, y)

local function displayLoop()
  local statusText, statusColor, CoolingText, CoolingColor
  while true do
    sc1:write(18, 9, "Reactor Status", colors.black, colors.white)

    if reactor.getActive() then
      statusText = "Active"
      statusColor = colors.green
    else
      statusText = "Inactive"
      statusColor = colors.red
    end
	
    if reactor.isActivelyCooled() then
      CoolingText = "Output: Steam"
      CoolingColor = colors.blue
    else
      CoolingText = "Output: RF"
      CoolingColor = colors.lightBlue
    end
	
    local EnergyStore = reactor.getEnergyStored()

    sc1:draw(20, 13, 10, 2, statusColor, true)
    sc1:write(22, 13, statusText, statusColor, colors.white)
	  sc1:draw(15, 7, 18, 5, colors.white, false)
    sc1:titlebar(1, x, "ReactOS", colors.lightGray, colors.white)
    term.native().write("testDisplay")
    sc1:newBtn(x-1,1,2,1,"close","derp")
    sc1:write(37, 5, "Case "..reactor.getCasingTemperature(), colors.cyan, colors.black)
    sc1:write(37, 7, "Core "..reactor.getFuelTemperature(), colors.cyan, colors.black)
    sc1:write(3, 15, CoolingText, CoolingColor, colors.black)
    sc1:draw(35, 15, 12, 3, colors.lime, false)
    os.sleep(0.05)
  end
end

local function controlLoop()
  while true do
    local enrg = reactor.getEnergyStored()
    local stat = reactor.getActive()
    if enrg >= maxEnergy and stat then
      reactor.setActive(false)
      term.native().write("testControl")
    elseif enrg <= minEnergy and not stat then
      reactor.setActive(true)
    end
    os.sleep(0.05)
  end
end

local function inputLoop()
  while true do
    local e = {sc1:pullEvent()}
    if e[1] == "mouse_up" then
      local str = sc1.btns
      sc1:write(1,19, str)
    end
    if e[1] == "btn_fired" and e[2] == "close" then
      break
    elseif e[1] == "key" and e[2] == keys.tab then
      break
    end
  end
end

parallel.waitForAny(displayLoop, controlLoop, inputLoop)
term.setCursorPos(1,1)
term.clear()