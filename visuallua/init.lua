local lib = {}

local major, minor, rev, codename = love.getVersion()

local instance = {}
instance.__index = instance

local function setColor(r,g,b,a)
  if major >= 11 then
    love.graphics.setColor(r/255,g/255,b/255, (a or 255)/255)
  else
    love.graphics.setColor(r,g,b, a or 255)
  end
end

local random = math.random
local function uuid_seed(t) --t is the seed, which is usually set to os.time()
  math.randomseed(t)
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function (c)
    local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
    return string.format('%x', v)
  end)
end

local function addNewItem(keyTable, myTable, key, value)
  table.insert(keyTable, key)
  myTable[key] = value 
end

local function removeItem(keyTable, myTable, key)
  for i=1, #keyTable do
    if key ==  keyTable[i] then
      table.remove(keyTable, i)
      break
    end
  end
  myTable[key] = nil
end

function instance.new(func)
  local self = setmetatable({}, instance)
  self.type = "visual-node"
  self.time = os.time()
  self.uuid = uuid_seed(self.time)
  self.func = func
  self.children = {}
  self.childkeys = {}
  self.parent = nil
  return self
end

function instance:addChild(child)
  -- self.children[child.uuid] = child
  addNewItem(self.childkeys, self.children, child.uuid, child)
  child.parent = self
end

function instance:removeChild(child)
  child.parent = nil
  for _,k in ipairs(self.childkeys) do
    --k is the child's uuid, self.children[k] is the child
    if k == child.uuid then
      removeItem(self.childkeys, self.children, child.uuid)
    end
  end
end

function instance:run()
  self.func()
  for _,k in ipairs(self.childkeys) do
    --k is the child's uuid, self.children[k] is the child
    self.children[k]:run()
  end
end

local context = {}
context.__index = context

function context.new(root)
  local self = setmetatable({}, context)
  self.type = "context"
  self.root = nil
  if root and root.type and root.type == "visual-node" then
    self.root = root
  end
  return self
end

function context:run()
  if self.root then
    self.root:run()
  end
end

local visualContext = {}
visualContext.__index = visualContext

function visualContext.new(c, x, y, w, h, gridsize)
  local self = setmetatable({}, visualContext)
  self.type = "visual-context"
  self.context = nil
  if c and c.type and c.type == "context" then
    self.context = c
  end
  self.x = x or 0
  self.y = y or 0
  self.w = w or love.graphics.getWidth()
  self.h = h or love.graphics.getHeight()
  self.gridsize = gridsize or 15
  return self
end

function visualContext:draw()
  love.graphics.push()
  setColor(80,80,80,255)
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
  setColor(145,145,145,255)
  for x=self.x, self.x+self.w, self.gridsize do
    love.graphics.line(x, self.y, x, self.y + self.h)
  end
  for y=self.y, self.y+self.h, self.gridsize do
    love.graphics.line(self.x, y, self.x + self.w, y)
  end
  love.graphics.pop()
end

lib.node = instance
lib.context = context
lib.visualContext = visualContext

return lib