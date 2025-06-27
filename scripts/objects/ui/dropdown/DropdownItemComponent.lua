---@class DropdownItemComponent: TextMenuItemComponent
local DropdownItemComponent, super = Class(TextMenuItemComponent)

function DropdownItemComponent:init(text, callback, options)
    super.init(self, text, callback, options)
    self.text.width = options and options.txtwidth or 320
end

return DropdownItemComponent