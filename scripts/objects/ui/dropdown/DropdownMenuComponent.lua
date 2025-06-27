---@class DropdownMenuComponent: MouseMenuComponent
---@field parent DropdownMenuComponent|MenubarItemComponent
local DropdownMenuComponent, super = Class("MouseMenuComponent")

function DropdownMenuComponent:init(x_sizing, y_sizing, options)
    super.init(self, x_sizing or FillSizing(), y_sizing or FillSizing(), options)
    self:setPadding(2)
end

function DropdownMenuComponent:draw()
    Draw.setColor(COLORS.black)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    super.draw(self)
end

return DropdownMenuComponent