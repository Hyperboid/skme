---@class EditorWorld: Object
---@overload fun(...): EditorWorld
---@field editor Editor
local EditorWorld, super = Class(Object)

function EditorWorld:init(editor)
    super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    self.editor = assert(editor, "Need to pass editor (self) to EditorWorld!")
    self.player = Character(Game.party[1]:getActor(), Game.world.player:getPosition())
    self.player:setFacing(Game.world.player.facing)
    self.player:setLayer(50)
    self.camera = Camera(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, true)
    self.camera.target_getter = function () return self.player end
    self:addChild(self.player)
end

function EditorWorld:fullDraw(...)
    local canvas = Draw.pushCanvas()
    love.graphics.clear(COLORS.black)
    super.fullDraw(self, ...)
    Draw.popCanvas()
    local left, top, right, bottom = unpack(self.editor.margins)
    Draw.pushScissor()
    Draw.scissorPoints(left, top, SCREEN_WIDTH - right, SCREEN_HEIGHT - bottom)
    Draw.drawCanvas(canvas)
    Draw.popScissor()
end

function EditorWorld:loadMap(map)
    ---@type EditorMap
    self.map = isClass(map) and map or (type(map) == "table" and EditorMap(self, map)) or Registry.createMap(map)
    assert(self.map:includes(EditorMap))
    self.map:loadEditor()
    self.width = self.map.width * self.map.tile_width
    self.height = self.map.height * self.map.tile_height
    self.editor.active_layer = self.map.layers[1]
end

return EditorWorld