---@class ScrollFillSizing: Sizing
local ScrollFillSizing, super = Class(Sizing)

function ScrollFillSizing:init()
    super.init(self)
end

function ScrollFillSizing:getWidth()
    ---@type Component
    local outer = self.parent.parent
    return math.max(self.parent.parent:getTotalWidth(), 20) - (outer.margins[1] + outer.margins[3])
end

function ScrollFillSizing:getHeight()
    ---@type Component
    local outer = self.parent.parent
    return math.max(self.parent.parent:getTotalHeight(), 20) - (outer.margins[2] + outer.margins[4])
end

return ScrollFillSizing