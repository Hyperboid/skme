---@class EditorShapes: EditorObjects
local EditorShapes, super = Class("EditorObjects")

function EditorShapes:init()
    -- self.browser = EditorObjectBrowser()
    self.browser = nil
end

function EditorShapes:openContextMenu(obj)
    Editor.context = ContextMenu(Utils.getClassName(obj))
    Editor.context:addMenuItem("Duplicate", "Makes a copy of this object at the same position.", function ()
        local data = Utils.copy(obj:save(), true)
        local layer = obj.parent--[[@as EditorShapeLayer]]
        local newobj =  EditorShape(data.name, nil, data)
        table.insert(layer.shapes, newobj)
        layer:addChild(newobj)
        Editor:endAction()
    end)
    Editor.context:addMenuItem("Delete", "Removes this object.", function ()
        local layer = obj.parent--[[@as EditorShapeLayer?]]
        if not layer then return end
        table.remove(layer.shapes, Utils.getKey(layer.shapes, obj))
        obj:remove()
        Editor:endAction()
    end)
    Editor.context:setPosition(Input.getCurrentCursorPosition())
    Editor.stage:addChild(Editor.context)
end

function EditorShapes:onEnter(prev_state)
    -- self.browser:setParent(Editor.stage)
    Editor.inspector:setHeight(SCREEN_HEIGHT - 20)
end

function EditorShapes:onLeave(next_state)
    -- self.browser:setParent()
    self:selectObject()
end

return EditorShapes