---@class GridLayout: Layout
local GridLayout, super = Class(Layout)

function GridLayout:init()
    super.init(self)
end

function GridLayout:refresh()
    local max_width = self.parent:getWorkingSize()
    local x, y = 0, 0
    for i, child in ipairs(self:getComponents()) do
        ---@cast child Component # "Because apparently we weren't already making that assumtion."
        if x + child:getTotalWidth() >= max_width then
            x = 0
            y = y + child:getTotalHeight()
        end

        child.x = ({self.parent:getScaledPadding()})[1] + (child.margins and ({child:getScaledMargins()})[1] or 0) + x
        child.y = ({self.parent:getScaledPadding()})[2] + (child.margins and ({child:getScaledMargins()})[2] or 0) + y
        x = x + child:getTotalWidth()

        if self.parent.overflow == "scroll" then
            child.x = child.x - self.parent.scroll_x
            child.y = child.y - self.parent.scroll_y
        end
    end
end

return GridLayout