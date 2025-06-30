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
    local pady = (outer.padding[2] + outer.padding[4]) + (self.parent.margins[2] + self.parent.margins[4])
    local height = math.max(self.parent.parent.height - pady)
    print('sfs height', height, outer.height)
    return height
end

return ScrollFillSizing