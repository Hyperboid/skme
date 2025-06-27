---@class DropdownMenuComponent: MouseMenuComponent
---@overload fun(...): DropdownMenuComponent
---@field parent DropdownMenuComponent|MenubarItemComponent
---@field open_menu MenubarItemComponent?
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

---@param menu DropdownItemComponent?
function DropdownMenuComponent:setOpenDropdown(menu)
    if self.open_menu then
        self.open_menu.list:remove()
        self.open_menu = nil
    end
    if not menu then return end
    menu.list:setParent(menu)
    menu.list.y = -2
    menu.list.x = self.width
    self.open_menu = menu
    self.open_menu.list:reflow()
end

return DropdownMenuComponent