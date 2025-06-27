---@class MenubarComponent: MouseMenuComponent
---@overload fun(...): MenubarComponent
---@field open_menu MenubarItemComponent?
local MenubarComponent, super = Class("MouseMenuComponent")

function MenubarComponent:init(x_sizing, y_sizing, options)
    super.init(self, x_sizing, y_sizing, options)
end

---@param menu MenubarItemComponent?
function MenubarComponent:setOpenDropdown(menu)
    if self.open_menu then
        self.open_menu.list:remove()
        self.open_menu = nil
    end
    if not menu then return end
    menu.list:setParent(menu)
    menu.list.y = menu.height
    self.open_menu = menu
    self.open_menu.list:reflow()
end

return MenubarComponent