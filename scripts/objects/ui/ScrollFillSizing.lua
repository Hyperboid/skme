---@class ScrollFillSizing: Sizing
local ScrollFillSizing, super = Class(Sizing)

function ScrollFillSizing:init()
    super.init(self)
end

function ScrollFillSizing:getWidth()
    ---@type Component
    local outer = self.parent.parent
    local padx = (outer.padding[1] + outer.padding[3]) + (self.parent.margins[1] + self.parent.margins[3])
    local width = math.max(self.parent.parent.width - padx)
    return width
end

function ScrollFillSizing:getHeight()
    ---@type Component
    local outer = self.parent.parent
    local pady = (outer.padding[2] + outer.padding[4]) + (self.parent.margins[2] + self.parent.margins[4])
    local height = math.max(self.parent.parent.height - pady)
    return height
end

return ScrollFillSizing