---@class CenterLayout: Layout
local CenterLayout, super = Class(Layout)

function CenterLayout:init()
    super.init(self)
end

function CenterLayout:refresh()
    super.refresh(self)

    local x_position = (({self:getInnerArea()})[1] - self:calculateTotalWidth()) / 2
    for _, child in ipairs(self:getComponents()) do
        child.x = child.x + x_position
        local width, _ = child:getScaledSize()
        x_position = x_position + (child.getTotalSize and ({child:getTotalSize()})[1] or width)
        x_position = x_position + self.gap
    end

    local y_position = (({self:getInnerArea()})[2] - self:calculateTotalWidth()) / 2
    for _, child in ipairs(self:getComponents()) do
        child.y = child.y + y_position
        local _, height = child:getScaledSize()
        y_position = y_position + (child.getTotalSize and ({child:getTotalSize()})[2] or height)
        y_position = y_position + self.gap
    end
end

function CenterLayout:calculateTotalWidth()
    local x_position = 0
    for index, child in ipairs(self:getComponents()) do
        local width, _ = child:getScaledSize()
        x_position = x_position + (child.getTotalSize and ({child:getTotalSize()})[1] or width)
        if index ~= #self:getComponents() then
            x_position = x_position + self.gap
        end
    end
    return x_position
end

return CenterLayout