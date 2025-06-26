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
    self.inspector.visible = false
    self.timer:tween(0.25, self, {margins = {200, 20, 20, 120}, music_filter = 1, inspector = {origin_x = 0}}, "out-quad", function ()
        self:selectLayer(self.active_layer)
    end)
    self.stage:addChild(self.inspector)
    self.state_manager = StateManager('TRANSITION', self, true)
    self.objects_editor = EditorObjects() ---@type EditorObjects
    self.state_manager:addState("OBJECTS", self.objects_editor)
    Kristal.showCursor()
end

function Editor:setMargins(left, top, right, bottom)
    self.margins = {left, top, right, bottom}
    self:updateMargins()
end

function Editor:selectLayer(layer)
    self.active_layer = layer
    if self.active_layer:includes(EditorObjectLayer) then
        self:setState("OBJECTS")
    else
        self:setState("INVALID")
    end
end

function Editor:setState(state, ...)
    return self.state_manager:setState(state, ...)
end

function Editor:update()
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
    if is_repeat then return end
    if self.state == "TRANSITION" or self.state == "TRANSITIONOUT" then return end
    if Input.ctrl() and key == "e" then
        self:playtest()
    elseif Input.ctrl() and key == "s" then
        self:saveData()
    elseif key == "pageup" then
        self:selectLayer(self.world.map.layers[Utils.clampWrap(Utils.getIndex(self.world.map.layers, self.active_layer) + 1, #self.world.map.layers)])
    elseif key == "pagedown" then
        self:selectLayer(self.world.map.layers[Utils.clampWrap(Utils.getIndex(self.world.map.layers, self.active_layer) - 1, #self.world.map.layers)])
    end
end

function Editor:saveData()
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
    self.timer:tween(0.25, self, {margins = {0, 0, 0, 0}, inspector = {origin_x = 1}, music_filter = 0}, "out-quad", function()
        Gamestate.pop()
        -- Trick hump into thinking everything is okay (also work around a 1-frame bug with darkfountain)
        love.update(DT)
    end)
end

function Editor:onMousePressed(x, y, button, istouch, presses)
    if self.context then
        if self.context:onMousePressed(x, y, button, istouch, presses) then
            return
        end
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


function Editor:drawLayerList()
    love.graphics.setLineWidth(1)
    love.graphics.translate(SCREEN_WIDTH - self.margins[3] + 2, SCREEN_HEIGHT - 120 - 18)
    for _, layer in ipairs(self.world.map.layers) do
        local icon
        if layer:includes(TileLayer) then
            icon = Assets.getTexture("ui/editor/layer/tiles")
        elseif layer:includes(EditorObjectLayer) then
            icon = Assets.getTexture("ui/editor/layer/objects")
        end
        if self.active_layer == layer then
            love.graphics.rectangle("fill", -2, -2, 20, 20)
        end
        if icon then
            Draw.draw(icon)
        else
            love.graphics.rectangle("line", 1, 1, 15, 15)
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