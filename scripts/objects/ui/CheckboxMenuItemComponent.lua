---@class CheckboxMenuItemComponent: TextInputMenuItemComponent
---@overload fun(...) : CheckboxMenuItemComponent
local CheckboxMenuItemComponent, super = Class(AbstractMenuItemComponent)

function CheckboxMenuItemComponent:init(options)
    super.init(self, FillSizing(), FixedSizing(22), nil, options)
    options = options or {}
    self.options = options
    self.getter = self.options.getter
    self.setter = self.options.setter
    if self.options.ref then
        local ref = self.options.ref
        self.getter = function () return ref[1][ref[2]] end
        self.setter = function (value) ref[1][ref[2]] = value end
        self.name = ref[2]
    end
    self.name = self.options.name or self.name or "???"
end

---@param char string
function CheckboxMenuItemComponent:textRestriction(char)
    return true
end

function CheckboxMenuItemComponent:getValue()
    if self:isFocused() or not self.getter then
        return self.input[1]
    else
        return self.getter()
    end
end

function CheckboxMenuItemComponent:setValue(value)
    self.input[1] = value
end

function CheckboxMenuItemComponent:updateAttached()
    if self.options.update_callback and self.input[1] then
        self.options.update_callback(self.input[1])
    elseif self.input[1] and self.setter then
        self.setter(self.input[1])
    end
end

function CheckboxMenuItemComponent:onSelected()
    super.onSelected(self)
    self.setter(not self.getter())
end

function CheckboxMenuItemComponent:draw()
    super.super.draw(self)
    if self.name then
        local smallfont = Assets.getFont("small", 16)
        love.graphics.setFont(smallfont)
        love.graphics.print(self.name, 0, 8)
    end
    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", self.width - 32, 5, 16, 16)
    if self.getter() then
        love.graphics.rectangle("fill", self.width - 29, 8, 10, 10)
    end
end

-- Stops text input. Maybe should be part of base TextInputMenuItemComponent?
function CheckboxMenuItemComponent:onRemoveFromStage(stage)
    super.onRemoveFromStage(self, stage)
    if TextInput.input == self.input then
        TextInput.endInput()
    end
end

return CheckboxMenuItemComponent