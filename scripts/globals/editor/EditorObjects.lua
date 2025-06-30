---@class EditorObjects: SKMEState
local EditorObjects, super = Class("SKMEState")

function EditorObjects:init()
    self.browser = EditorObjectBrowser()
end

function EditorObjects:onEnter(prev_state)
    self.browser:setParent(Editor.stage)
    Editor.inspector:setHeight(SCREEN_HEIGHT - 20)
end

function EditorObjects:onLeave(next_state)
    self.browser:setParent()
    self:selectObject()
end

---@return EditorEvent?
function EditorObjects:detectObject(x, y)
    -- TODO: Z-Order should take priority!!
    local object_size = math.huge
    local hierarchy_size = -1
    local object = nil

    local objects = Editor.active_layer and Editor.active_layer.children or {}
    Object.startCache()
    for _, instance in ipairs(objects) do
        if (instance:includes(EditorEvent) or instance["USE_IN_EDITOR"]) and instance:isFullyVisible() then
            local mx, my = instance:getFullTransform():inverseTransformPoint(x, y)
            local rect = instance:getDebugRectangle() or { 0, 0, instance.width, instance.height }
            if mx >= rect[1] and mx < rect[1] + rect[3] and my >= rect[2] and my < rect[2] + rect[4] then
                local new_hierarchy_size = #instance:getHierarchy()
                local new_object_size = math.sqrt(rect[3] * rect[4])
                if new_hierarchy_size > hierarchy_size or (new_hierarchy_size == hierarchy_size and new_object_size < object_size) then
                    hierarchy_size = new_hierarchy_size
                    object_size = new_object_size
                    object = instance
                end
            end
        end
    end
    Object.endCache()
    return object
end

function EditorObjects:openContextMenu(obj)
    Editor.context = ContextMenu(Utils.getClassName(obj))
    Editor.context:addMenuItem("Duplicate", "Makes a copy of this object at the same position.", function ()
        local data = Utils.copy(obj:save(), true)
        local layer = obj.parent--[[@as EditorObjectLayer]]
        local newobj =  layer:loadObject(data.type, data)
        table.insert(layer.objects, newobj)
        layer:addChild(newobj)
    end)
    Editor.context:addMenuItem("Delete", "Removes this object.", function ()
        local layer = obj.parent--[[@as EditorObjectLayer?]]
        if not layer then return end
        layer.objects[Utils.getKey(layer.objects, obj)] = nil
        obj:remove()
    end)
    Editor.context:setPosition(Input.getCurrentCursorPosition())
    Editor.stage:addChild(Editor.context)
end

function EditorObjects:onMousePressed(x, y, button)
    local obj = self:detectObject(x, y)
    self:selectObject(obj)
    if obj and button == 2 then
        self:openContextMenu(obj)
    elseif obj then
        self.grabbing = true
        local screen_x, screen_y = obj:getScreenPos()
        self.grab_offset_x = x - screen_x
        self.grab_offset_y = y - screen_y
    end
end

function EditorObjects:selectObject(obj)
    if self.selected_object then
        self.selected_object:removeFX("editor_vfx")
    end
    self.selected_object = obj
    if self.selected_object then
        self.selected_object:addFX(OutlineFX({1,1,1,0.8}), "editor_vfx")
    end
    Editor.inspector:onSelectObject(obj or Editor.active_layer)
end

function EditorObjects:update()
    if self.grabbing and self.selected_object then
        local x, y = Input.getCurrentCursorPosition()
        self.selected_object:setScreenPos(x - self.grab_offset_x, y - self.grab_offset_y)
        local roundx, roundy = 1,1
        if Input.ctrl() then
            roundx, roundy = Editor.world.map.tile_width, Editor.world.map.tile_height
            if Input.shift() then
                roundx, roundy = roundx / 2, roundy / 2
            end
        end
        self.selected_object.x = Utils.round(self.selected_object.x, roundx)
        self.selected_object.y = Utils.round(self.selected_object.y, roundy)
    end
end

function EditorObjects:onMouseReleased()
    if self.grabbing then
        Editor:endAction()
    end
    self.grabbing = false
end

return EditorObjects