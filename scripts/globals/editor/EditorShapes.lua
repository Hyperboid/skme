---@class EditorShapes: EditorObjects
local EditorShapes, super = Class("EditorObjects")

function EditorShapes:init()
    -- self.browser = EditorObjectBrowser()
    self.browser = MouseMenuComponent(FixedSizing(SCREEN_WIDTH - 200 - 20), FixedSizing(120))
    self.browser.x = 200
    self.browser.y = SCREEN_HEIGHT - 120
    for _, value in ipairs({
        {
            name = "Rectangle",
            constructor = function() return EditorShape({width = 40, height = 40}) end
        },
    }) do
        self.browser:addChild(TextMenuItemComponent(value.name, function ()
            local layer = Editor.active_layer--[[@as EditorShapeLayer]]
            local shape = value.constructor()
            shape:setPosition(Editor.world.player:getPosition())
            layer:addShape(shape)
            Editor.objects_editor:selectObject(shape)
            Editor:endAction()
        end))
    end
end

function EditorShapes:openContextMenu(obj)
    Editor.context = ContextMenu(Utils.getClassName(obj))
    Editor.context:addMenuItem("Duplicate", "Makes a copy of this object at the same position.", function ()
        local data = Utils.copy(obj:save(), true)
        local layer = obj.parent--[[@as EditorShapeLayer]]
        local newobj =  EditorShape(data)
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
    if obj.registerEditorContext then
        obj:registerEditorContext(Editor.context)
    end
    Editor.context:setPosition(Input.getCurrentCursorPosition())
    Editor.stage:addChild(Editor.context)
end

function EditorShapes:onEnter(prev_state)
    self.browser:setParent(Editor.stage)
    Editor.inspector:setHeight(SCREEN_HEIGHT - 20)
    self.state = "MAIN"
end

function EditorShapes:onLeave(next_state)
    self.browser:setParent()
    self:selectObject()
    self.state = "MAIN"
end

return EditorShapes