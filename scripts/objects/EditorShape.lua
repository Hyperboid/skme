---@class EditorShape : EditorEvent
local EditorShape, super = Class("EditorEvent")
---@cast super EditorEvent

function EditorShape:draw()
    super.super.draw(self)
    Draw.setColor(self.parent:getDrawColor())
    self:drawOverlay(false, true)
end


---@param context ContextMenu
function EditorShape:registerEditorContext(context)
    if not (self.collider and self.collider:includes(PolygonCollider)) then
        Editor.context:addMenuItem("Convert to polygon", "Converts this shape to a polygon, allowing free-form editing.", function ()
            self.collider = PolygonCollider(self, {{0,0}, {self.width, 0}, {self.width, self.height}, {0, self.height}})
        end)
    end
end


return EditorShape