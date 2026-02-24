local LayoutEngine = require("ui.layout.LayoutEngine")
local LayoutBox = require("ui.layout.LayoutBox")
local Enums = require("ui.layout.Enums")

local Axis = Enums.Axis

local test = {}

---@return ui.Node
local function new_node()
	return {
		children = {},
		layout_box = LayoutBox(),
		add = function(self, node)
			table.insert(self.children, node)
			node.parent = self
			return node
		end
	}
end

---@param width number
---@param height number
---@return ui.Node
local function new_node_with_intrinsic_size(width, height)
	return {
		children = {},
		layout_box = LayoutBox(),
		add = function(self, node)
			table.insert(self.children, node)
			node.parent = self
			return node
		end,
		---@param axis_idx ui.Axis
		---@param constraint number?
		---@return number
		getIntrinsicSize = function(self, axis_idx, constraint)
			if axis_idx == Axis.X then
				return width
			else
				return height
			end
		end
	}
end

---@param t testing.T
function test.flex_row_basic(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box.arrange = LayoutBox.Arrange.FlexRow

	local c1 = container:add(new_node())
	c1.layout_box:setDimensions(100, 100)

	local c2 = container:add(new_node())
	c2.layout_box:setDimensions(50, 100)

	local c3 = container:add(new_node())
	c3.layout_box:setDimensions(100, 100)

	engine:updateLayout(container.children)

	t:eq(c1.layout_box.x.pos, 0)
	t:eq(c2.layout_box.x.pos, 100)
	t:eq(c3.layout_box.x.pos, 150)

	t:eq(c1.layout_box.y.pos, 0)
	t:eq(c2.layout_box.y.pos, 0)
	t:eq(c3.layout_box.y.pos, 0)

	t:eq(c1.layout_box.x.size, 100)
	t:eq(c1.layout_box.y.size, 100)

	t:eq(c2.layout_box.x.size, 50)
	t:eq(c2.layout_box.y.size, 100)

	t:eq(c3.layout_box.x.size, 100)
	t:eq(c3.layout_box.y.size, 100)
end

---@param t testing.T
function test.flex_col_basic(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box.arrange = LayoutBox.Arrange.FlexCol

	local c1 = container:add(new_node())
	c1.layout_box:setDimensions(100, 100)

	local c2 = container:add(new_node())
	c2.layout_box:setDimensions(50, 50)

	local c3 = container:add(new_node())
	c3.layout_box:setDimensions(100, 100)

	engine:updateLayout(container.children)

	t:eq(c1.layout_box.x.pos, 0)
	t:eq(c2.layout_box.x.pos, 0)
	t:eq(c3.layout_box.x.pos, 0)

	t:eq(c1.layout_box.y.pos, 0)
	t:eq(c2.layout_box.y.pos, 100)
	t:eq(c3.layout_box.y.pos, 150)
end

---@param t testing.T
function test.justify_content(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box:setDimensions(100, 100)
	container.layout_box.arrange = LayoutBox.Arrange.FlexRow

	local c1 = container:add(new_node())
	c1.layout_box:setDimensions(10, 10)

	local c2 = container:add(new_node())
	c2.layout_box:setDimensions(10, 10)

	container.layout_box.justify_content = LayoutBox.JustifyContent.Start
	engine:updateLayout(container.children)
	t:eq(c1.layout_box.x.pos, 0)
	t:eq(c2.layout_box.x.pos, 10)

	container.layout_box.justify_content = LayoutBox.JustifyContent.Center
	engine:updateLayout(container.children)
	t:eq(c1.layout_box.x.pos, 40)
	t:eq(c2.layout_box.x.pos, 50)

	container.layout_box.justify_content = LayoutBox.JustifyContent.End
	engine:updateLayout(container.children)
	t:eq(c1.layout_box.x.pos, 80)
	t:eq(c2.layout_box.x.pos, 90)

	container.layout_box.justify_content = LayoutBox.JustifyContent.SpaceBetween
	engine:updateLayout(container.children)
	t:eq(c1.layout_box.x.pos, 0)
	t:eq(c2.layout_box.x.pos, 90)
end

---@param t testing.T
function test.align_items(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box:setDimensions(100, 100)
	container.layout_box.arrange = LayoutBox.Arrange.FlexRow

	local c1 = container:add(new_node())
	c1.layout_box:setDimensions(10, 10)
	c1.layout_box.align_self = LayoutBox.AlignItems.Start

	local c2 = container:add(new_node())
	c2.layout_box:setDimensions(10, 10)
	c2.layout_box.align_self = LayoutBox.AlignItems.Center

	local c3 = container:add(new_node())
	c3.layout_box:setDimensions(10, 10)
	c3.layout_box.align_self = LayoutBox.AlignItems.End

	local c4 = container:add(new_node())
	c4.layout_box:setDimensions(10, 10)
	c4.layout_box.align_self = LayoutBox.AlignItems.Stretch

	engine:updateLayout(container.children)

	t:eq(c1.layout_box.y.pos, 0)
	t:eq(c2.layout_box.y.pos, 45)
	t:eq(c3.layout_box.y.pos, 90)
	t:eq(c4.layout_box.y.pos, 0)
end

---@param t testing.T
function test.percent_size(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box:setDimensions(200, 200)
	container.layout_box.arrange = LayoutBox.Arrange.FlexRow

	local c1 = container:add(new_node())
	c1.layout_box:setWidthPercent(0.5)
	c1.layout_box:setHeightPercent(0.25)

	local c2 = container:add(new_node())
	c2.layout_box:setWidthPercent(0.3)
	c2.layout_box:setHeight(50)

	engine:updateLayout({c1, c2})

	t:eq(c1.layout_box.x.size, 100)
	t:eq(c1.layout_box.y.size, 50)

	t:eq(c2.layout_box.x.size, 60)
	t:eq(c2.layout_box.y.size, 50)
end

---@param t testing.T
function test.flex_row_reversed(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box:setArrange(LayoutBox.Arrange.FlexRow)
	container.layout_box:setReversed(true)

	local c1 = container:add(new_node())
	c1.layout_box:setDimensions(100, 100)

	local c2 = container:add(new_node())
	c2.layout_box:setDimensions(50, 100)

	local c3 = container:add(new_node())
	c3.layout_box:setDimensions(100, 100)

	engine:updateLayout(container.children)

	-- Visual order should be c3, c2, c1
	t:eq(c3.layout_box.x.pos, 0)
	t:eq(c2.layout_box.x.pos, 100)
	t:eq(c1.layout_box.x.pos, 150)
end

---@param t testing.T
function test.flex_col_reversed(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box:setArrange(LayoutBox.Arrange.FlexCol)
	container.layout_box:setReversed(true)

	local c1 = container:add(new_node())
	c1.layout_box:setDimensions(100, 100)

	local c2 = container:add(new_node())
	c2.layout_box:setDimensions(100, 50)

	local c3 = container:add(new_node())
	c3.layout_box:setDimensions(100, 100)

	engine:updateLayout(container.children)

	-- Visual order should be c3, c2, c1
	t:eq(c3.layout_box.y.pos, 0)
	t:eq(c2.layout_box.y.pos, 100)
	t:eq(c1.layout_box.y.pos, 150)
end

---@param t testing.T
function test.margins(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box:setDimensions(200, 200)
	container.layout_box.arrange = LayoutBox.Arrange.FlexRow

	local c1 = container:add(new_node())
	c1.layout_box:setDimensions(50, 50)
	c1.layout_box:setMargins({10, 20, 10, 20}) -- top, right, bottom, left

	engine:updateLayout({c1})

	-- Position should include left margin
	t:eq(c1.layout_box.x.pos, 20)
	t:eq(c1.layout_box.y.pos, 10)
end

---@param t testing.T
function test.intrinsic_size_flex_row(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box.arrange = LayoutBox.Arrange.FlexRow

	-- Node with intrinsic size (e.g., texture 64x48)
	local intrinsic_node = container:add(new_node_with_intrinsic_size(64, 48))
	intrinsic_node.layout_box:setWidthAuto()
	intrinsic_node.layout_box:setHeightAuto()

	engine:updateLayout(container.children)

	-- Should use intrinsic size
	t:eq(intrinsic_node.layout_box.x.size, 64)
	t:eq(intrinsic_node.layout_box.y.size, 48)
end

---@param t testing.T
function test.intrinsic_size_flex_col(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box.arrange = LayoutBox.Arrange.FlexCol

	-- Node with intrinsic size (e.g., texture 64x48)
	local n1 = container:add(new_node_with_intrinsic_size(64, 48))
	local n2 = container:add(new_node_with_intrinsic_size(64, 48))
	n1.layout_box:setWidthAuto()
	n1.layout_box:setHeightAuto()
	n2.layout_box:setWidthAuto()
	n2.layout_box:setHeightAuto()

	engine:updateLayout(container.children)

	-- Should use intrinsic size
	t:eq(n1.layout_box.x.size, 64)
	t:eq(n1.layout_box.y.size, 48)
	t:eq(n2.layout_box.x.size, 64)
	t:eq(n2.layout_box.y.size, 48)
	t:eq(container.layout_box.x.size, 64)
	t:eq(container.layout_box.y.size, 96)
end

---@param t testing.T
function test.intrinsic_size_with_fixed_width(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box:setDimensions(100, 100)
	container.layout_box.arrange = LayoutBox.Arrange.FlexRow
	container.layout_box:setAlignItems(LayoutBox.AlignItems.Start) -- Don't stretch

	-- Node with intrinsic size but fixed width
	local intrinsic_node = container:add(new_node_with_intrinsic_size(64, 48))
	intrinsic_node.layout_box:setWidth(50) -- Fixed width
	intrinsic_node.layout_box:setHeightAuto() -- Auto height from intrinsic

	engine:updateLayout(container.children)

	-- Width should be fixed, height from intrinsic
	t:eq(intrinsic_node.layout_box.x.size, 50)
	t:eq(intrinsic_node.layout_box.y.size, 48)
end

---@param t testing.T
function test.intrinsic_size_absolute(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box.arrange = LayoutBox.Arrange.Absolute

	-- Node with intrinsic size in absolute layout
	local intrinsic_node = container:add(new_node_with_intrinsic_size(100, 200))
	intrinsic_node.layout_box:setWidthAuto()
	intrinsic_node.layout_box:setHeightAuto()

	engine:updateLayout(container.children)

	-- Should use intrinsic size
	t:eq(intrinsic_node.layout_box.x.size, 100)
	t:eq(intrinsic_node.layout_box.y.size, 200)
end

---@param t testing.T
function test.intrinsic_size_container_sizing(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box.arrange = LayoutBox.Arrange.FlexRow
	container.layout_box:setWidthAuto()
	container.layout_box:setHeightAuto()

	-- Add node with intrinsic size
	container:add(new_node_with_intrinsic_size(80, 60))

	engine:updateLayout({container})

	-- Container should size to fit the intrinsic size of child
	t:eq(container.layout_box.x.size, 80)
	t:eq(container.layout_box.y.size, 60)
end

---@param t testing.T
function test.intrinsic_size_mixed_with_fixed(t)
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box.arrange = LayoutBox.Arrange.FlexRow
	container.layout_box:setAlignItems(LayoutBox.AlignItems.Start) -- Don't stretch

	-- Node with intrinsic size
	local intrinsic_node = container:add(new_node_with_intrinsic_size(64, 48))
	intrinsic_node.layout_box:setWidthAuto()
	intrinsic_node.layout_box:setHeightAuto()

	-- Node with fixed size
	local fixed_node = container:add(new_node())
	fixed_node.layout_box:setDimensions(50, 100)

	engine:updateLayout(container.children)

	-- Both should have correct sizes
	t:eq(intrinsic_node.layout_box.x.size, 64)
	t:eq(intrinsic_node.layout_box.y.size, 48)
	t:eq(fixed_node.layout_box.x.size, 50)
	t:eq(fixed_node.layout_box.y.size, 100)

	-- Positions should be sequential
	t:eq(intrinsic_node.layout_box.x.pos, 0)
	t:eq(fixed_node.layout_box.x.pos, 64)
end

---@param t testing.T
function test.percent_child_with_changing_intrinsic_size(t)
	-- Test that parent with Auto height correctly shrinks when intrinsic child shrinks
	-- This tests the fix for the bug where Percent children used stale parent size
	-- Root (FlexRow, 100% width)
	--   └── container (Absolute, Auto height)
	--         ├── percent_child (100% height - should follow container)
	--         └── intrinsic_child (Auto - determines container size)
	local engine = LayoutEngine()

	-- Root with fixed dimensions
	local root = new_node()
	root.layout_box:setDimensions(200, 200)
	root.layout_box.arrange = LayoutBox.Arrange.FlexRow
	root.layout_box:setAlignItems(LayoutBox.AlignItems.Start) -- Don't stretch container

	-- Container with Auto height
	local container = root:add(new_node())
	container.layout_box:setWidth(100)
	container.layout_box:setHeightAuto()
	container.layout_box.arrange = LayoutBox.Arrange.Absolute

	-- Percent height child
	local percent_child = container:add(new_node())
	percent_child.layout_box:setWidth(50)
	percent_child.layout_box:setHeightPercent(1.0) -- 100% of parent

	-- Intrinsic size child that determines container height
	local intrinsic_child = container:add(new_node_with_intrinsic_size(50, 100))
	intrinsic_child.layout_box:setWidth(50)
	intrinsic_child.layout_box:setHeightAuto()

	-- First layout: intrinsic child has height 100
	engine:updateLayout(container.children)
	t:eq(container.layout_box.y.size, 100, "container height should be 100 from intrinsic child")
	t:eq(percent_child.layout_box.y.size, 100, "percent child should be 100% of 100")

	-- Simulate intrinsic child shrinking (like text unwrapping)
	intrinsic_child.getIntrinsicSize = function(self, axis_idx, constraint)
		if axis_idx == Axis.X then
			return 50
		else
			return 32 -- Height shrunk from 100 to 32
		end
	end
	intrinsic_child.layout_box:markDirty(Axis.Both)

	-- Second layout: intrinsic child now has height 32
	engine:updateLayout(container.children)
	t:eq(container.layout_box.y.size, 32, "container height should shrink to 32")
	t:eq(percent_child.layout_box.y.size, 32, "percent child should be 100% of 32")
end

---@param t testing.T
function test.absolute_container_auto_size_from_positioned_children(t)
	-- Test that an absolute container with Auto size correctly calculates
	-- its size based on children's left/top positions
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box.arrange = LayoutBox.Arrange.Absolute
	container.layout_box:setWidthAuto()
	container.layout_box:setHeightAuto()

	-- Child positioned at (50, 30) with size (100, 80)
	local child1 = container:add(new_node())
	child1.layout_box:setDimensions(100, 80)
	child1.layout_box.left = 50
	child1.layout_box.top = 30

	-- Child positioned at (200, 100) with size (50, 50)
	local child2 = container:add(new_node())
	child2.layout_box:setDimensions(50, 50)
	child2.layout_box.left = 200
	child2.layout_box.top = 100

	engine:updateLayout({container})

	-- Container should size to fit all children
	-- Width: max(50 + 100, 200 + 50) = 250
	-- Height: max(30 + 80, 100 + 50) = 150
	t:eq(container.layout_box.x.size, 250)
	t:eq(container.layout_box.y.size, 150)

	-- Children should have correct positions
	t:eq(child1.layout_box.x.pos, 50)
	t:eq(child1.layout_box.y.pos, 30)
	t:eq(child2.layout_box.x.pos, 200)
	t:eq(child2.layout_box.y.pos, 100)
end

---@param t testing.T
function test.absolute_container_with_margins(t)
	-- Test that margins are correctly accounted for in absolute layout
	local engine = LayoutEngine()
	local container = new_node()
	container.layout_box.arrange = LayoutBox.Arrange.Absolute
	container.layout_box:setWidthAuto()
	container.layout_box:setHeightAuto()

	-- Child at (10, 20) with size (100, 50) and margins (5, 10)
	local child = container:add(new_node())
	child.layout_box:setDimensions(100, 50)
	child.layout_box.left = 10
	child.layout_box.top = 20
	child.layout_box.x.margin_start = 5
	child.layout_box.x.margin_end = 10
	child.layout_box.y.margin_start = 3
	child.layout_box.y.margin_end = 7

	engine:updateLayout({container})

	-- Container size should include the child's position + size + margins
	-- Width: 10 + 100 + 5 + 10 = 125
	-- Height: 20 + 50 + 3 + 7 = 80
	t:eq(container.layout_box.x.size, 125)
	t:eq(container.layout_box.y.size, 80)

	-- Child position should include margin_start
	t:eq(child.layout_box.x.pos, 15)  -- 10 + 5
	t:eq(child.layout_box.y.pos, 23)  -- 20 + 3
end

---@param t testing.T
function test.intrinsic_size_in_nested_auto_container(t)
	-- This test reproduces the bug where a Label inside nested containers
	-- gets width=0 because parent size is 0 during measurement
	local engine = LayoutEngine()

	-- Root with fixed size (like Screen)
	local root = new_node()
	root.layout_box:setDimensions(800, 600)
	root.layout_box.arrange = LayoutBox.Arrange.FlexCol

	-- Row container (flex_row, auto size)
	local row = root:add(new_node())
	row.layout_box.arrange = LayoutBox.Arrange.FlexRow
	row.layout_box:setWidthAuto()
	row.layout_box:setHeightAuto()
	row.layout_box:setChildGap(10)

	-- Panel with padding (absolute by default, auto size)
	local panel = row:add(new_node())
	panel.layout_box:setWidthAuto()
	panel.layout_box:setHeightAuto()
	panel.layout_box:setPaddings({5, 20, 5, 20}) -- top, right, bottom, left

	-- Label with intrinsic size
	local label = panel:add(new_node_with_intrinsic_size(100, 20))
	label.layout_box:setWidthAuto()
	label.layout_box:setHeightAuto()

	engine:updateLayout(root.children)

	-- Label should have its intrinsic width, not 0
	t:eq(label.layout_box.x.size, 100, "label should have intrinsic width")
	t:eq(label.layout_box.y.size, 20, "label should have intrinsic height")

	-- Panel should size to fit label + padding
	t:eq(panel.layout_box.x.size, 140, "panel width should be label + padding")  -- 100 + 20 + 20
	t:eq(panel.layout_box.y.size, 30, "panel height should be label + padding")  -- 20 + 5 + 5

	-- Row should stretch to fill root width (flex_col default align_items = Stretch)
	t:eq(row.layout_box.x.size, 800, "row width should stretch to root width")
	t:eq(row.layout_box.y.size, 30, "row height should fit panel")
end

---@param t testing.T
function test.intrinsic_size_after_parent_resize(t)
	-- This test reproduces the bug where a Label stays wrapped after parent is resized
	-- Root (FlexCol, fixed size)
	--   Row (FlexRow, Auto size)
	--     Panel (Absolute, Auto size, padding)
	--       Label (intrinsic size)
	local engine = LayoutEngine()

	local root = new_node()
	root.layout_box:setDimensions(800, 600)
	root.layout_box.arrange = LayoutBox.Arrange.FlexCol
	root.layout_box:setAlignItems(LayoutBox.AlignItems.Start) -- Don't stretch children

	local row = root:add(new_node())
	row.layout_box.arrange = LayoutBox.Arrange.FlexRow
	row.layout_box:setWidthAuto()
	row.layout_box:setHeightAuto()

	local panel = row:add(new_node())
	panel.layout_box:setWidthAuto()
	panel.layout_box:setHeightAuto()
	panel.layout_box:setPaddings({5, 20, 5, 20})

	local label = panel:add(new_node_with_intrinsic_size(100, 20))
	label.layout_box:setWidthAuto()
	label.layout_box:setHeightAuto()

	-- First layout: normal size
	engine:updateLayout(root.children)
	t:eq(label.layout_box.x.size, 100, "initial label width should be intrinsic")

	-- Simulate resize to small width
	root.layout_box:setWidth(1)
	root.layout_box:markDirty(Axis.X)
	row.layout_box:markDirty(Axis.X)
	panel.layout_box:markDirty(Axis.X)
	label.layout_box:markDirty(Axis.X)

	engine:updateLayout(root.children)
	-- Label should still have intrinsic width since parent has Auto mode
	t:eq(label.layout_box.x.size, 100, "label width should still be intrinsic after shrink")

	-- Simulate resize back to large width
	root.layout_box:setWidth(1374)
	root.layout_box:markDirty(Axis.X)
	row.layout_box:markDirty(Axis.X)
	panel.layout_box:markDirty(Axis.X)
	label.layout_box:markDirty(Axis.X)

	engine:updateLayout(root.children)
	t:eq(label.layout_box.x.size, 100, "label width should be intrinsic after expand")
end

return test
