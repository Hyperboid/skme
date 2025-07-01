---@class EditorObjects: SKMEState
local EditorObjects, super = Class("SKMEState")

function EditorObjects:init()
    self.browser = EditorObjectBrowser()
end

function EditorObjects:onEnter(prev_state)
    self.browser:setParent(Editor.stage)
    Editor.inspector:setHeight(SCREEN_HEIGHT - 20)
    ---@type "MAIN"|"POINTS"
    self.state = "MAIN"
end

function EditorObjects:onLeave(next_state)
    if self.state == "POINTS" then
        Editor:endAction()
    end
    self.state = "MAIN"
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
    local mouse_collider = Hitbox(Editor.stage, (x)-2, (y)-2, 4, 4)
    for _, instance in ipairs(objects) do
        if (instance:includes(EditorEvent) or instance["USE_IN_EDITOR"]) and instance:isFullyVisible() then
            local mx, my = instance:getFullTransform():inverseTransformPoint(x, y)
            local rect = instance:getDebugRectangle() or { 0, 0, instance.width, instance.height }
            if (instance.collider) or (mx >= rect[1] and mx < rect[1] + rect[3] and my >= rect[2] and my < rect[2] + rect[4]) then
                local new_hierarchy_size = #instance:getHierarchy()
                local new_object_size = math.sqrt(rect[3] * rect[4])
                if instance.collider then
                    if instance.collider:collidesWith(mouse_collider) then
                        hierarchy_size = new_hierarchy_size
                        object_size = new_object_size
                        object = instance
                    end
                elseif new_hierarchy_size > hierarchy_size or (new_hierarchy_size == hierarchy_size and new_object_size < object_size) then
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
        Editor:endAction()
    end)
    Editor.context:addMenuItem("Delete", "Removes this object.", function ()
        local layer = obj.parent--[[@as EditorObjectLayer?]]
        if not layer then return end
        layer.objects[Utils.getKey(layer.objects, obj)] = nil
        obj:remove()
        Editor:endAction()
    end)
    Editor.context:setPosition(Input.getCurrentCursorPosition())
    Editor.stage:addChild(Editor.context)
end

function EditorObjects:onMousePressed(x, y, button, touch, presses)
    if self.state == "POINTS" then
        self:onMousePressedPoints(x, y, button, touch, presses)
        return
    end
    local obj = self:detectObject(x, y)
    self:selectObject(obj)
    if obj and button == 2 then
        self:openContextMenu(obj)
    elseif obj then
        if presses == 2 and obj.collider and obj.collider:includes(PolygonCollider) then
            self.state = "POINTS"
            return
        end
        self.grabbing = true
        local screen_x, screen_y = obj:getScreenPos()
        self.grab_offset_x = x - screen_x
        self.grab_offset_y = y - screen_y
    end
end

function EditorObjects:updateSelectedObjectPoints()
    self.points_colliders = {}
    self.lines_colliders = {}
    local selected_object_collider = self.selected_object.collider--[[@as PolygonCollider]]
    for _, value in pairs(selected_object_collider.points) do
        self.points_colliders[value] = PointCollider(self.selected_object, value[1], value[2])
    end
    for i = 1, #selected_object_collider.points do
        local line = {selected_object_collider.points[i], selected_object_collider.points[Utils.clampWrap(i+1, #selected_object_collider.points)]}
        local point = {(line[1][1] + line[2][1])/2, (line[1][2] + line[2][2])/2}
        self.lines_colliders[i] = {point=point, col=LineCollider(self.selected_object, line[1][1], line[1][2], line[2][1], line[2][2])}
    end
end

function EditorObjects:onMousePressedPoints(x, y, button, touch, presses)
    self:updateSelectedObjectPoints()
    local p = 10
    local mouse_collider = Hitbox(Editor.stage, (x)-p, (y)-p, p+p, p+p)
    for point, collider in pairs(self.points_colliders) do
        if mouse_collider:collidesWith(collider) then
            if button == 2 and #self.selected_object.collider.points > 3 then
                Utils.removeFromTable(self.selected_object.collider.points, point)
                return
            end
            self.selected_point = point
            self.grabbing = true
            self.grab_offset_x = (Editor.world.camera.x+x)-point[1]
            self.grab_offset_y = (Editor.world.camera.y+y)-point[2]
            return
        end
    end

    if presses == 2 then
        for index, line_collider in ipairs(self.lines_colliders) do
            if mouse_collider:collidesWith(line_collider.col) then
                table.insert(self.selected_object.collider.points, index+1, line_collider.point)
                return
            end
        end
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
    if self.state == "POINTS" then
        return self:updatePoints()
    end
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

function EditorObjects:updatePoints()
    if self.grabbing and self.selected_point then
        local x, y = Input.getCurrentCursorPosition()
        self.selected_point[1], self.selected_point[2] = (Editor.world.camera.x+x) - self.grab_offset_x, (Editor.world.camera.y+y) - self.grab_offset_y
        local roundx, roundy = 1,1
        if Input.ctrl() then
            roundx, roundy = Editor.world.map.tile_width, Editor.world.map.tile_height
            if Input.shift() then
                roundx, roundy = roundx / 2, roundy / 2
            end
        end
        self.selected_point[1] = Utils.round(self.selected_point[1], roundx)
        self.selected_point[2] = Utils.round(self.selected_point[2], roundy)
    end
    if Input.pressed("confirm") then
        self.state = "MAIN"
        Editor:endAction()
    end
end

function EditorObjects:onMouseReleased()
    if self.grabbing and self.state == "MAIN" then
        Editor:endAction()
    end
    self.grabbing = false
end

return EditorObjects