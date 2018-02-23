local vl = require "visuallua"

local context = nil
local graph_context = nil

function love.load()
  --Create 2 nodes, and make 'node2' a child of 'node1'
  local node1 = vl.node.new(function() print("test1") end)
  local node2 = vl.node.new(function() print("test2") end)
  node1:addChild(node2)
  
  --Create context with 'node1' as the root node
  context = vl.context.new(node1)
  
  --Create graphical context for 'context'
  graph_context = vl.visualContext.new(context)
end

function love.draw()
  graph_context:draw()
end