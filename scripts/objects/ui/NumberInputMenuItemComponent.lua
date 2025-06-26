---@class NumberInputMenuItemComponent: FieldMenuItemComponent
---@overload fun(...) : NumberInputMenuItemComponent
local NumberInputMenuItemComponent, super = Class("FieldMenuItemComponent")

function NumberInputMenuItemComponent:init(options)
    super.init(self, options)
    self.padding[3] = 16
end

function NumberInputMenuItemComponent:textRestriction(char)
    return (tonumber(char)) ~= nil or (char == ".")
end

function NumberInputMenuItemComponent:updateAttached()
    local inp = self.input[1]
    if inp[#inp] == "." then
        inp = inp .. "0"
    end
    if tonumber(inp) and self.setter then
        self.setter(tonumber(inp))
    end
end

function NumberInputMenuItemComponent:onWheelMoved(x,y)
    self.setter(self.getter() + y)
    self.input[1] = tostring(self.getter())
end

return NumberInputMenuItemComponent