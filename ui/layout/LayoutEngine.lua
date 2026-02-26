local class = require("class")
local Enums = require("ui.layout.Enums")

local Axis = Enums.Axis
local Arrange = Enums.Arrange

local AbsoluteStrategy = require("ui.layout.strategy.AbsoluteStrategy")
local FlexStrategy = require("ui.layout.strategy.FlexStrategy")
local StackStrategy = require("ui.layout.strategy.StackStrategy")

---@class ui.LayoutEngine
---@operator call: ui.LayoutEngine
---@field absolute_strategy ui.AbsoluteStrategy
---@field flex_strategy ui.FlexStrategy
---@field stack_strategy ui.StackStrategy
local LayoutEngine = class()

function LayoutEngine:new()
	self.absolute_strategy = AbsoluteStrategy(self)
	self.flex_strategy = FlexStrategy(self)
	self.stack_strategy = StackStrategy(self)
end

---@param node ui.Node
---@return ui.LayoutStrategy
function LayoutEngine:getStrategy(node)
	local arrange = node.layout_box.arrange

	if arrange == Arrange.Absolute then
		return self.absolute_strategy
	elseif arrange == Arrange.FlexRow or arrange == Arrange.FlexCol then
		return self.flex_strategy
	elseif arrange == Arrange.Stack then
		return self.stack_strategy
	end

	-- Default to Stack
	return self.stack_strategy
end

---@param dirty_nodes ui.Node[]
---@return {[ui.Node]: boolean}? updated_layout_roots
function LayoutEngine:updateLayout(dirty_nodes)
	if #dirty_nodes == 0 then
		return
	end

	---@type {[ui.Node]: boolean}
	local layout_roots = {}

	-- Collect unique layout roots (parents of dirty nodes, or the dirty node itself if it has no parent)
	for _, node in ipairs(dirty_nodes) do
		local root = node.parent or node
		layout_roots[root] = true
	end

	-- If root is a node with no parent, use it as the only layout root
	for node, _ in pairs(layout_roots) do
		if not node.parent then
			layout_roots = {}
			layout_roots[node] = true
			break
		end
	end

	for node, _ in pairs(layout_roots) do
		self:measure(node, Axis.X)
		self:grow(node, Axis.X)

		self:measure(node, Axis.Y)
		self:grow(node, Axis.Y)

		local target = node.parent and node.parent or node
		self:arrange(target)

		self:markValid(node)
	end

	return layout_roots
end

---@param node ui.Node
---@param axis_idx ui.Axis
function LayoutEngine:measure(node, axis_idx)
	local strategy = self:getStrategy(node)
	strategy:measure(node, axis_idx)
end

---@param node ui.Node
---@param axis_idx ui.Axis
function LayoutEngine:grow(node, axis_idx)
	local strategy = self:getStrategy(node)
	strategy:grow(node, axis_idx)
end

---@param node ui.Node
function LayoutEngine:arrange(node)
	local strategy = self:getStrategy(node)
	strategy:arrange(node)
end

---Mark a node and all its children as valid (layout is up-to-date)
---@param node ui.Node
function LayoutEngine:markValid(node)
	node.layout_box:markValid()
	for _, child in ipairs(node.children) do
		self:markValid(child)
	end
end

return LayoutEngine
