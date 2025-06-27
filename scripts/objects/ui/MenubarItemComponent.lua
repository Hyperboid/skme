---@class MenubarItemComponent: TextMenuItemComponent
---@field parent MenubarComponent
---@overload fun(...): MenubarItemComponent
local MenubarItemComponent, super = Class(TextMenuItemComponent)

function MenubarItemComponent:init(text, ...)
    if type(text) == "string" then
        text = "[font:main,16]" .. text
    end
    super.init(self, text, ...)
    self:setPadding(2, 0)
    self.list = DropdownMenuComponent()
    self.list:setLayout(VerticalLayout())
end

function MenubarItemComponent:getComponents()
    -- Take the list out of the flow
    local items = {}
    for _, child in ipairs(super.getComponents(self)) do
        if child ~= self.list then
            table.insert(items, child)
        end
    end
    return items
end

---@generic T
---@param item string|T
---@return T|DropdownItemComponent
function MenubarItemComponent:addItem(item, ...)
    if type(item) == "string" then
        item = DropdownItemComponent("[font:main,16]"..item, ...)
        item:setPadding(2)
        -- item:setSizing(FillSizing(), item.y_sizing)
    end
    self.list:addChild(item)
    return item
end

function MenubarItemComponent:onSelected()
    super.onSelected(self)
    if not self.list:isRemoved() then
        self.parent:setOpenDropdown()
        return
    end
    self.parent:setOpenDropdown(self)
end


return MenubarItemComponent