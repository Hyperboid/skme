---@class FieldMenuItemComponent: TextInputMenuItemComponent
---@overload fun(...) : FieldMenuItemComponent
local FieldMenuItemComponent, super = Class(TextInputMenuItemComponent)

function FieldMenuItemComponent:init(options)
    options = options or {}
    options.height = 16 + 20 + 4
    super.init(self, options)
    self.getter = self.options.getter
    self.setter = self.options.setter
    if self.options.ref then
        local ref = self.options.ref
        self.getter = function () return ref[1][ref[2]] end
        self.setter = function (value) ref[1][ref[2]] = value end
        self.input[1] = tostring(self.getter())
        self.name = ref[2]
    end
    self.name = self.options.name or self.name or "???"
end

---@param char string
function FieldMenuItemComponent:textRestriction(char)
    return true
end

function FieldMenuItemComponent:getValue()
    if self:isFocused() or not self.getter then
        return self.input[1]
    else
        return self.getter()
    end
end

function FieldMenuItemComponent:setValue(value)
    self.input[1] = value
end

function FieldMenuItemComponent:updateAttached()
    if self.options.update_callback and self.input[1] then
        self.options.update_callback(self.input[1])
    elseif self.input[1] and self.setter then
        self.setter(self.input[1])
    end
end

function FieldMenuItemComponent:onSelected()
    if self.getter then
        self.input[1] = tostring(self.getter())
    end
    Assets.playSound("ui_select")
    self:setFocused()

    TextInput.attachInput(self.input, self.options.input_settings or {
        enter_submits = true,
        multiline = false,
        clear_after_submit = false
    })
    TextInput.text_callback = function (text)
        self:updateAttached()
    end
    TextInput.text_restriction = function (char)
        return self:textRestriction(char)
    end
    TextInput.submit_callback = self.options.submit_callback or function()
        self:updateAttached()
        if self.getter then
            self.input[1] = tostring(self.getter())
        end
        Editor:endAction()
        self:setUnfocused()
        TextInput.endInput()
        Input.clear("return")
        Assets.playSound("ui_select")
    end

    self.up_limit_callback = self.options.up_limit_callback or nil
    self.down_limit_callback = self.options.down_limit_callback or nil
    self.pressed_callback = self.options.pressed_callback or nil
    self.text_callback = self.options.text_callback or nil
end

function FieldMenuItemComponent:draw()
    super.super.draw(self)

    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.line(0, self.height - 4, self.width - 16, self.height - 4)
    if self.name then
        local smallfont = Assets.getFont("small", 16)
        love.graphics.setFont(smallfont)
        love.graphics.print(self.name, 0, 8)
    end
    love.graphics.translate(0, 20)

    local font = Assets.getFont(self.options.font or "main", 16)
    love.graphics.setFont(font)

    if self:isFocused() then
        TextInput.draw({
            x = 0,
            y = 0,
            font = font,
            print = function(text, x, y) love.graphics.print(text, x, y) end,
        })
    else
        love.graphics.setFont(font)
        love.graphics.print(tostring(self:getValue()), 0, 0)
    end
end

-- Stops text input. Maybe should be part of base TextInputMenuItemComponent?
function FieldMenuItemComponent:onRemoveFromStage(stage)
    super.onRemoveFromStage(self, stage)
    if TextInput.input == self.input then
        TextInput.endInput()
    end
end

return FieldMenuItemComponent