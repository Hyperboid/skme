---@class EditorWorld: Object
---@overload fun(...): EditorWorld
---@field editor Editor
---@field camera EditorCamera
local EditorWorld, super = Class(Object)

function EditorWorld:init(editor)
    super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    self.editor = assert(editor, "Need to pass editor (self) to EditorWorld!")
    self.player = Character(Game.party[1]:getActor(), Game.world.player:getPosition())
    self.player.persistent = true
    self.player:setFacing(Game.world.player.facing)
    self.world = self
    self.player:setLayer(50)
    self.camera = EditorCamera(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, true)
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
    for _, value in ipairs(self.children) do
        if not value.persistent then
            value:remove()
        end
    end
    self:updateChildList()
    ---@type EditorMap
    self.map = isClass(map) and map or (type(map) == "table" and EditorMap(self, map)) or Registry.createMap(map)
    assert(self.map:includes(EditorMap))
    self.map:loadEditor()
    self.width = self.map.width * self.map.tile_width
    self.height = self.map.height * self.map.tile_height
    self.editor.active_layer = self.map.layers[1]
end

function EditorWorld:resizeMapTo(width, height)
    ---@type EditorTileLayer[]
    local tile_layers = Utils.filter(self.map.layers, function (v) return v:includes(EditorTileLayer) end)
    ---@type table<EditorTileLayer, integer[][]>
    local tile_datas = {}
    for _, layer in ipairs(tile_layers) do
        tile_datas[layer] = {}
        for i = 1, #layer.tile_data do
            local x = ((i - 1) % layer.map_width) + 1
            local y = math.floor((i-1) / layer.map_width)
            tile_datas[layer][y] = tile_datas[layer][y] or {}
            tile_datas[layer][y][x] = layer.tile_data[i]
        end
        layer.tile_data = {}
        layer.map_width = width or self.map.width
        layer.data.width = width or self.map.width
        layer.width = self.map.tile_width * layer.map_width
        layer.height = self.map.tile_height * layer.map_height
    end
    self.map.width = width or self.map.width
    self.map.height = height or self.map.height

    for layer, rows in pairs(tile_datas) do
        ---@cast layer EditorTileLayer
        layer:setTile(0, 0, 0)
        for y, row in ipairs(rows) do
            for x, gid in ipairs(row) do
                if x <= self.map.width then
                    local index = x + (y * layer.map_width)
                    layer:setTile(x-1, y, gid or 0)
                end
            end
        end
        for i = 1, self.map.width * self.map.height do
            layer.tile_data[i] = layer.tile_data[i] or 0
        end
        layer.canvas = love.graphics.newCanvas(layer.map_width * self.map.tile_width, layer.map_height * self.map.tile_height)
    end
    self.width = self.map.width * self.map.tile_width
    self.height = self.map.height * self.map.tile_height
end

function EditorWorld:update()
    super.update(self)
    local px, py = self.player:getRelativePos(0,0)
    local psw, psh = self.player:getScaledSize()
    if Editor.state == "TRANSITIONOUT" or CollisionUtil.rectRectInside(0,0, self.width, self.height, px, py, psw, psh) then
        self.camera.keep_bounds_timer = Utils.approach(self.camera.keep_bounds_timer, 0, DT*2*4)
    else
        self.camera.keep_bounds_timer = Utils.approach(self.camera.keep_bounds_timer, 2, DT*2*4)
    end
end

function EditorWorld:draw()
    super.draw(self)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", -2, -2, self.width+4, self.height+4)
end

return EditorWorld