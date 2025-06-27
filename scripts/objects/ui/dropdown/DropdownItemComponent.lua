---@class DropdownItemComponent: TextMenuItemComponent
---@field parent DropdownMenuComponent
local DropdownItemComponent, super = Class(TextMenuItemComponent)

function DropdownItemComponent:init(text, callback, options)
    super.init(self, text, callback, options)
    self.text.width = options and options.txtwidth or 320
    self.list = DropdownMenuComponent()
    self.list:setLayout(VerticalLayout())
end

function DropdownItemComponent:addItem(item, ...)
    if type(item) == "string" then
        item = DropdownItemComponent("[font:main,16]"..item, ...)
        item:setPadding(2)
        -- item:setSizing(FillSizing(), item.y_sizing)
    end
    self.list:addChild(item)
    return item
end

function DropdownItemComponent:onSelected()
    super.onSelected(self)
    if #self.list.children == 0 then return end
    if not self.list:isRemoved() then
        self.parent:setOpenDropdown()
        return
    end
    self.parent:setOpenDropdown(self)
end

function DropdownItemComponent:getComponents()
    -- Take the list out of the flow
    local items = {}
    for _, child in ipairs(super.getComponents(self)) do
        if child ~= self.list then
            table.insert(items, child)
        end
    end
    return items
end

return DropdownItemComponent
