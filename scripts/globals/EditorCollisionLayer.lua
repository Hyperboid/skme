---@class EditorCollisionLayer : EditorShapeLayer
local EditorCollisionLayer, super = Class("EditorShapeLayer")

EditorCollisionLayer.TYPE = "collision"
EditorCollisionLayer.ICON = "ui/editor/layer/collision"

function EditorCollisionLayer:init(data)
    super.init(self, data)
    self.color = {0,0,1}
end

function EditorCollisionLayer:getDrawColor()
    local r,g,b,a = super.getDrawColor(self)
    return r, g, b, a * (Editor.active_layer == self and 1 or 0.2)
end

return EditorCollisionLayer