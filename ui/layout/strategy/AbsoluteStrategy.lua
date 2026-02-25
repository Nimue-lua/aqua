local LayoutStrategy = require("ui.layout.strategy.LayoutStrategy")
local Enums = require("ui.layout.Enums")
local math_util = require("math_util")

local Axis = Enums.Axis
local SizeMode = Enums.SizeMode
local math_clamp = math_util.clamp
local math_max = math.max

---@class ui.AbsoluteStrategy: ui.LayoutStrategy
---@operator call: ui.AbsoluteStrategy
local AbsoluteStrategy = LayoutStrategy + {}

---@param node ui.Node
---@param axis_idx ui.Axis
function AbsoluteStrategy:measure(node, axis_idx)
	local axis = self:getAxis(node, axis_idx)
	local min_s = axis.min_size
	local max_s = axis.max_size

	-- Fixed or Percent: use predefined size
	if axis.mode == SizeMode.Fixed or axis.mode == SizeMode.Percent then
		local s = axis.preferred_size
		if axis.mode == SizeMode.Percent and node.parent then
			local parent_axis = self:getAxis(node.parent, axis_idx)
			s = s * parent_axis:getLayoutSize()
		end
		axis.size = math_clamp(s, min_s, max_s)

		for _, child in ipairs(node.children) do
			self.engine:measure(child, axis_idx)
		end
		return
	end

	-- Auto/Fit: For absolute containers, default to 0 or use intrinsic size
	-- Absolute containers do NOT shrink-wrap around children dynamically
	local s = 0.0

	if #node.children == 0 then
		-- Leaf node: use intrinsic size if available
		local constraint = nil
		if axis_idx == Axis.Y then
			-- For Y axis, pass width as constraint (for text wrapping)
			local x_axis = node.layout_box.x
			if x_axis.mode == SizeMode.Auto or x_axis.mode == SizeMode.Fit then
				-- Node's X is not fixed - check parent for constraint
				if node.parent then
					local parent_x = node.parent.layout_box.x
					if parent_x.mode == SizeMode.Fixed or parent_x.mode == SizeMode.Percent then
						constraint = parent_x.size - parent_x.padding_start - parent_x.padding_end
							- x_axis.margin_start - x_axis.margin_end
					end
					-- else: constraint = nil (infinite width, no wrap)
				end
			else
				-- Node's X is fixed/percent - use its own size
				constraint = x_axis.size
			end
		end
		s = self:getIntrinsicSize(node, axis_idx, constraint) or 0
	else
		-- For containers with children, measure children but don't calculate size from them
		-- Absolute containers have explicit sizes or default to 0
		for _, child in ipairs(node.children) do
			self.engine:measure(child, axis_idx)
		end
	end

	s = axis.padding_start + s + axis.padding_end
	axis.size = math_clamp(s, min_s, max_s)
end

---Absolute items do not "grow" to fill available space
---@param node ui.Node
---@param axis_idx ui.Axis
function AbsoluteStrategy:grow(node, axis_idx)
	-- Empty - absolute items do NOT grow to fill available space
	-- Just recurse into children for their own grow phase
	for _, child in ipairs(node.children) do
		self.engine:grow(child, axis_idx)
	end
end

---Position all children using pure coordinate positioning
---Ignores all alignments (justify_content, align_items)
---@param node ui.Node
function AbsoluteStrategy:arrange(node)
	for _, child in ipairs(node.children) do
		local child_x = child.layout_box.x
		local child_y = child.layout_box.y
		-- Position is strictly: left/top + margin_start
		child_x.pos = child.layout_box.left + child_x.margin_start
		child_y.pos = child.layout_box.top + child_y.margin_start

		self:arrangeChild(child)
	end
end

return AbsoluteStrategy
