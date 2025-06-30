---@class EditorShape : EditorEvent
local EditorShape, super = Class("EditorEvent")
---@cast super EditorEvent

function EditorShape:draw()
    super.super.draw(self)
    Draw.setColor(0,0,1)
    self:drawOverlay()
end

return EditorShape