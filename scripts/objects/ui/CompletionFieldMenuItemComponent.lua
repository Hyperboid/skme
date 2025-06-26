---@class CompletionFieldMenuItemComponent: FieldMenuItemComponent
---@field completions string[]
local CompletionFieldMenuItemComponent, super = Class("FieldMenuItemComponent")

function CompletionFieldMenuItemComponent:init(options)
    super.init(self, options)
    local comp = self.options.completions
    if type(comp) == "function" then
        comp = comp()
    end
    if type(comp) ~= "table" then
        self.completions = {}
    elseif Utils.isArray(comp) then
        self.completions = comp
    else
        self.completions = {}
        for key in Utils.orderedPairs(comp) do
            if type(key) == "string" then
                table.insert(self.completions, key)
            end
        end
    end
end

function CompletionFieldMenuItemComponent:draw()
    super.draw(self)
    if self:isFocused() then
        love.graphics.push()
        for _, value in ipairs(self.completions) do
            if Utils.contains(value, self:getValue()) then
                love.graphics.translate(0,16)
                Draw.setColor(COLORS.black)
                love.graphics.rectangle("fill", 0,0,self.width, 16)
                Draw.setColor(COLORS.white)
                love.graphics.print(value)
            end
        end
        love.graphics.pop()
    end
end

return CompletionFieldMenuItemComponent