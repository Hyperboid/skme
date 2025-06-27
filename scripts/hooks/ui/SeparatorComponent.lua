---@class SeparatorComponent : SeparatorComponent
local SeparatorComponent, super = Utils.hookScript(SeparatorComponent)

---@param options? table
function SeparatorComponent:init(options)
    super.init(self, options)
    self.thickness = options and options.thickness or 4
end

function SeparatorComponent:draw()
    love.graphics.setLineWidth(self.thickness)
    love.graphics.setColor(1, 1, 1, 1)
    if self.vertical then
        love.graphics.line(4, 0, 4, self.height)
    else
        love.graphics.line(0, 4, self.width, 4)
    end
end

return SeparatorComponent