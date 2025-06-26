---@class MenubarItemComponent: TextMenuItemComponent
local MenubarItemComponent, super = Class(TextMenuItemComponent)

function MenubarItemComponent:init(text, ...)
    super.init(self, text, ...)
    
end

return MenubarItemComponent