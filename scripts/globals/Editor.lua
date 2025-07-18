---@class Editor
---@field state string
---@field active_layer EditorLayer
---@field context ContextMenu?
local Editor, super = Class(Object)

local dumper = libRequire("skme", "lib.dumper")

function Editor:enter(previous_state)
    self.previous_state = previous_state
    self.world = EditorWorld(self)
    self.music_filter = 0
    self.stage = Stage()
    self.timer = self.stage.timer
    self.border = ImageBorder("castle")
    self:setMargins(0,0,0,0)
    self.world:loadMap(Game.world.map.id)
    self.fader = Fader()
    self.fader.layer = 1000
    self.fader:setParent(self.stage)
    self.stage:addChild(self.world)
    self.inspector = EditorInspector(self)
    self.inspector.origin_x = 1
    self.inspector.layer = 10
    self.menubar = EditorMenubar()
    self.menubar.origin_y = 1
    self.timer:tween(0.25, self, {
        music_filter = 1,
        margins = {200, 20, 20, 120},
        inspector = {origin_x = 0},
        menubar = {origin_y = 0},
    }, "out-quad", function ()
        self:selectLayer(self.active_layer)
    end)
    self.stage:addChild(self.inspector)
    self.stage:addChild(self.menubar)
    self.state_manager = StateManager('TRANSITION', self, true)
    self.controllers_editor = EditorControllers() ---@type EditorControllers
    self.objects_editor = EditorObjects() ---@type EditorObjects
    self.tiles_editor = EditorTiles() ---@type EditorTiles
    self.shapes_editor = EditorShapes() ---@type EditorShapes
    self.state_manager:addState("CONTROLLERS", self.controllers_editor)
    self.state_manager:addState("OBJECTS", self.objects_editor)
    self.state_manager:addState("TILES", self.tiles_editor)
    self.state_manager:addState("SHAPES", self.shapes_editor)
    self.inspector:onSelectObject(self.active_layer)
    Kristal.showCursor()
    if (not self.undos) or (self.last_map ~= self.world.map.id) then
        self.last_map = self.world.map.id
        self.undos = {n = 1, Utils.copy(self.world.map:save(), true)}
    end
end

function Editor:endAction()
    self:_saveUndo()
end

---@private
function Editor:_saveUndo()
    self.undos.n = self.undos.n + 1
    self.undos[self.undos.n] = Utils.copy(self.world.map:save(), true)
    self.undos[self.undos.n + 1] = nil
    if self.undos.n > 500 then
        self.undos.n = self.undos.n - 1
        table.remove(self.undos, 1)
    end
end

function Editor:redo()
    local data = self.undos[self.undos.n + 1]
    if not data then return false end
    self.undos.n = self.undos.n + 1
    local selected_layer_id = Utils.getIndex(self.world.map.layers, self.active_layer)
    Registry.registerMapData(self.world.map.id, data)
    self.world:loadMap(self.world.map.id)
    self:selectLayer(self.world.map.layers[selected_layer_id])
    return true
end

function Editor:undo()
    local data = self.undos[self.undos.n - 1]
    if not data then return false end
    self.undos.n = self.undos.n - 1
    local selected_layer_id = Utils.getIndex(self.world.map.layers, self.active_layer)
    Registry.registerMapData(self.world.map.id, data)
    self.world:loadMap(self.world.map.id)
    self:selectLayer(self.world.map.layers[selected_layer_id])
    return true
end

function Editor:setMargins(left, top, right, bottom)
    self.margins = {left, top, right, bottom}
    self:updateMargins()
end

function Editor:selectLayer(layer)
    self.active_layer = layer
    self:setState("INVALID")
    if not self.active_layer then return end
    self.inspector:onSelectObject(self.active_layer)
    if self.active_layer:includes(EditorControllerLayer) then
        self:setState("CONTROLLERS")
    elseif self.active_layer:includes(EditorObjectLayer) then
        self:setState("OBJECTS")
    elseif self.active_layer:includes(EditorTileLayer) then
        self:setState("TILES")
    elseif self.active_layer:includes(EditorShapeLayer) then
        self:setState("SHAPES")
    end
end

function Editor:swapLayers(a, b)
    local layer_a, layer_b = self.world.map.layers[a], self.world.map.layers[b]
    layer_a.layer, layer_b.layer = layer_b.layer, layer_a.layer
    self.world.map.layers[a], self.world.map.layers[b] = self.world.map.layers[b], self.world.map.layers[a]
    self.world.update_child_list = true
end

function Editor:setState(state, ...)
    return self.state_manager:setState(state, ...)
end

function Editor:update()
    -- Because a ton of other things hide the cursor, we show it every frame.
    Kristal.showCursor()
    if self.state ~= "TRANSITION" and self.state ~= "TRANSITIONOUT" then
        if not OVERLAY_OPEN and not TextInput.active then
            if Input.down("w") then
                self.world.player.y = self.world.player.y - (DTMULT*8)
            end
            if Input.down("s") then
                self.world.player.y = self.world.player.y + (DTMULT*8)
            end
            if Input.down("a") then
                self.world.player.x = self.world.player.x - (DTMULT*8)
            end
            if Input.down("d") then
                self.world.player.x = self.world.player.x + (DTMULT*8)
            end
        end
    end
    if Game.world.music.source then
        Game.world.music.source:setFilter({
            type = "lowpass",
            highgain = Utils.clampMap(self.music_filter, 0, 1, 1, 0.35) ^ 4,
        })
    end
    self.stage:update()
    self.state_manager:update()
    self:updateMargins()
end

function Editor:updateMargins()
    local left, top, right, bottom = unpack(self.margins)
    left = Utils.floor(left)
    top = Utils.floor(top)
    right = Utils.floor(right)
    bottom = Utils.floor(bottom)
    self.world.x = left
    self.world.y = top
    self.world.camera.width = SCREEN_WIDTH - (left + right)
    self.world.camera.height = SCREEN_HEIGHT - (top + bottom)
    self.world.camera:update()
end

function Editor:leave()
    Kristal.hideCursor()
    self:setMargins(0,0,0,0)
    if Game.world.music.source then
        Game.world.music.source:setFilter()
    end
end


function Editor:onKeyPressed(key, is_repeat)
    if self.state == "TRANSITION" or self.state == "TRANSITIONOUT" then return end
    if Input.ctrl() then
        if not is_repeat and key == "e" then
            self:playtest()
        elseif not is_repeat and key == "s" then
            self:saveData()
            Input.clear(key, true)
        elseif key == "z" and not Input.shift() then
            Assets.stopAndPlaySound(self:undo() and "noise" or "ui_cant_select")
        elseif key == "y" or key == "z" then
            Assets.stopAndPlaySound(self:redo() and "noise" or "ui_cant_select")
        end
    end
    if is_repeat then return end
    if key == "pageup" then
        local cur_index = Utils.getIndex(self.world.map.layers, self.active_layer)
        local next_index = Utils.clampWrap(cur_index + 1, #self.world.map.layers)
        if Input.shift() then
            self:swapLayers(cur_index, next_index)
        else
            self:selectLayer(self.world.map.layers[next_index])
        end
    elseif key == "pagedown" then
        local cur_index = Utils.getIndex(self.world.map.layers, self.active_layer)
        local prev_index = Utils.clampWrap(cur_index - 1, #self.world.map.layers)
        if Input.shift() then
            self:swapLayers(cur_index, prev_index)
        else
            self:selectLayer(self.world.map.layers[prev_index])
        end
    end
end

function Editor:saveData(no_sound)
    if not no_sound then
        Assets.stopAndPlaySound("save")
    end
    local data = "return " .. dumper(self.world.map:save())
    local filepath = Mod.info.path .. "/scripts/world/maps/"..self.world.map.id
    if (love.filesystem.getInfo(filepath) or {}).type == "directory" then
        love.filesystem.write(filepath .. "/data.lua", data)
    else
        love.filesystem.write(filepath .. ".lua", data)
    end
end

function Editor:onWheelMoved(x, y)
    local mx, my = Input.getMousePosition()
    local object_size = math.huge
    local hierarchy_size = -1
    ---@type MouseMenuComponent?
    local object = nil
    -- Basically DebugSystem:detectObject
    for key, instance in pairs(self.stage:getObjects()) do
        ---@cast instance MouseMenuComponent
        if instance.onWheelMoved and instance:canDebugSelect() and instance:isFullyVisible() then
            local lmx, lmy = instance:getFullTransform():inverseTransformPoint(mx, my)
            local rect = instance:getDebugRectangle() or { 0, 0, instance.width, instance.height }
            if lmx >= rect[1] and lmx < rect[1] + rect[3] and lmy >= rect[2] and lmy < rect[2] + rect[4] then
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
    if object then
        object:onWheelMoved(x, y)
    end
end

function Editor:playtest()
    Registry.registerMapData(self.world.map.id, self.world.map:save())
    Game.world:loadMap(self.world.map.id, self.world.player:getPosition())
    self.state_manager:setState("TRANSITIONOUT")
    self.timer:tween(0.25, self, {
        music_filter = 0,
        margins = {0, 0, 0, 0},
        inspector = {origin_x = 1},
        menubar = {origin_y = 1},
    }, "out-quad", function()
        Gamestate.pop()
        -- Trick hump into thinking everything is okay (also work around a 1-frame bug with darkfountain)
        love.update(DT)
    end)
end

function Editor:onClickLayer(index, button)
    self:selectLayer(self.world.map.layers[index])
    if button == 2 then
        Editor.context = self.active_layer:getContextOptions(ContextMenu(Utils.getClassName(self.active_layer)))
        
        Editor.context:setPosition(Input.getCurrentCursorPosition())
        Editor.stage:addChild(Editor.context)
    end
end

function Editor:onMousePressed(x, y, button, istouch, presses)
    if self.context then
        if self.context:onMousePressed(x, y, button, istouch, presses) then
            return
        end
    end
    if x > (SCREEN_WIDTH - self.margins[3]) then
        local rw, rh = 20, 20
        local rx = SCREEN_WIDTH - self.margins[3]
        for index, layer in ipairs(self.world.map.layers) do
            local ry = ((SCREEN_HEIGHT) - self.margins[4]) - (index * rh)
            if CollisionUtil.pointRect(x, y, rx, ry, rw, rh) then
                self:onClickLayer(index, button)
            end
        end
        return
    end
    -- local mouse = PointCollider(nil, x, y)
    if x < self.margins[1] or x > (SCREEN_WIDTH - self.margins[3]) then return end
    if y < self.margins[2] or y > (SCREEN_HEIGHT - self.margins[4]) then return end
    if self.state_manager:call("mousepressed", x, y, button, istouch, presses) then
        return
    end
end

function Editor:onMouseReleased(x, y, button, istouch, presses)
    self.state_manager:call("mousereleased", x, y, button, istouch, presses)

    if self.context then
        self.context:onMouseReleased(x, y, button, istouch, presses)
    end
end

---@param layer EditorLayer
function Editor:addLayer(layer)
    table.insert(self.world.map.layers, layer)
    layer.layer = self.world.map.next_layer
    self.world.map.next_layer = self.world.map.next_layer + self.world.map.depth_per_layer
    layer:setParent(self.world)
end

function Editor:drawLayerList()
    love.graphics.setLineWidth(1)
    love.graphics.translate(SCREEN_WIDTH - self.margins[3] + 2, SCREEN_HEIGHT - 120 - 18)
    for _, layer in ipairs(self.world.map.layers) do
        love.graphics.setColor(1,1,1)
        local icon
        if layer.ICON then
            icon = Assets.getTexture(layer.ICON)
        elseif layer:includes(TileLayer) then
            icon = Assets.getTexture("ui/editor/layer/tiles")
        elseif layer:includes(EditorObjectLayer) then
            icon = Assets.getTexture("ui/editor/layer/objects")
        end
        if self.active_layer == layer then
            love.graphics.rectangle("fill", -2, -2, 20, 20)
        end
        if not layer.visible then
            love.graphics.setColor(1, 1, 1, 0.5)
        end
        if icon then
            Draw.draw(icon)
        else
            love.graphics.rectangle("line", 1, 1, 15, 15)
        end
        if layer == self.world.map.party_layer then
            love.graphics.setColor(1,0,1)
            love.graphics.rectangle("line", -1, -1, 19, 19)
        end
        love.graphics.translate(0, -20)
    end
end

function Editor:draw()
    love.graphics.clear(0.1,0.1,0.1)
    love.graphics.push()
    self:drawLayerList()
    love.graphics.pop()
    self.stage:draw()
end

return Editor