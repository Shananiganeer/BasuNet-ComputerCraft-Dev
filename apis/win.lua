function getLength(tbl)
  local count = 0
  for _ in pairs(tbl) do count = count + 1 end
  return count
end

function init(...)
  local x, y, w, h = unpack(arg)
  assert(tonumber(x), "x must be a number greater than 0")
  assert(tonumber(y), "y must be a number greater than 0")
  assert(tonumber(w), "w must be a number greater than 0")
  assert(tonumber(h), "h must be a number greater than 0")
  local win = window.create(term.current(), x, y, w, h, true)
  win.oldWrite = win.write
  setmetatable(win, {__index = Win})
  win.write = Win.write
  win.btns = {}
  setmetatable(win.btns, {__index = {x = 0, y = 0, w = 0, h = 0, onClick = "", isActive = false}})
  return win
end

function write(self, ...)
  local x, y, text, bColor, tColor = unpack(arg)
  assert(tonumber(x), "x must be a number greater than 0")
  assert(tonumber(y), "y must be a number greater than 0")
  if bColor then self.setBackgroundColor(bColor) end
  if tColor then self.setTextColor(tColor) end
  self.setCursorPos(x, y)
  self.oldWrite(text)
end

function draw(self, ...)
  local x, y, w, h, bColor, isFilled = unpack(arg)
  assert(tonumber(x), "x must be a number greater than 0")
  assert(tonumber(y), "y must be a number greater than 0")
  assert(tonumber(w), "w must be a number greater than 0")
  assert(tonumber(h), "h must be a number greater than 0")
  if bColor then self.setBackgroundColor(bColor) end
  for j=y,y+h-1,1 do
    for i=x,x+w,1 do
      if isFilled or i == x or i == x+w or j == y or j == y+h-1 then
        self.setCursorPos(i, j)
        self.oldWrite(" ")
      end
    end
  end
end

function titlebar(self, ...)
  local minX, maxX, title, bColor, tColor = unpack(arg)
  assert(tonumber(minX), "minX must be a number greater than 0")
  assert(tonumber(maxX), "maxY must be a number greater than 0")
  if bColor then self.setBackgroundColor(bColor) end
  if tColor then self.setTextColor(tColor) end
  self.setCursorPos(minX,1)
  for x=minX,maxX,1 do self.oldWrite(" ") end
  local titleX = math.floor((minX+maxX)/2)-math.floor(#title/2)
  self:write(titleX, 1, title)
  self:write(maxX-1, 1, "><", colors.red, colors.white)
end

function newBtn(self, ...)
  local x, y, w, h, k, func = unpack(arg)
  self.btns[k] = {x = x, y = y, w = w, h = h, onClick = func, isActive = true}
end

function delBtn(self, btn) self.btns[btn] = nil end

function newMenu(self, ...)
  local x, y, title, list, bColor, tColor = unpack(arg)
  local w, h = 0, getLength(list)
  for k in pairs(list) do if #k > w then w = #k end end
  w = w + 2
  assert(tonumber(x), "x must be a number greater than 0")
  assert(tonumber(y), "y must be a number greater than 0")
  assert(type(list)=="table", "list must be a table of item, function")
  assert(bColor, "background color must be defined")
  assert(tColor, "text color must be defined")
  self.write(x, y, " ["..title.."] ", bColor, tColor)
  self.newBtn(x, y, w, h, title, function()
    self.setBackgroundColor(bColor)
    self.setTextColor(tColor)
    self.draw(x, y+1, w, h)
    local cY = 0
    for k, v in pairs(list) do
      cY = cY + 1
      for i=0,w-1,1 do self.write(x+i, y+cY, " ") end
      self:write(x+floor((w-1)/2)-floor(#k/2), y+cY, k)
      self:newBtn(x, y+cY, w, 1, k, v)
    end
  end
  )
end

function close(self, retCode)
  self.clear()
  self = nil
  return retCode
end

function pullEvent(self)
  local e = {os.pullEvent()}
  if e[1] == mouse_up then
    for k, v in pairs(self.btns) do
      if v.isActive and e[3] >= v.x and e[3] < v.x+v.w and e[4] >= v.y and e[4] < y+h then
        v.onClick()
        return "btn_fired", k
      end
    end
  end
  return unpack(e)
end