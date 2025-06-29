assert(CLASS_NAME_GETTER"MouseMenuComponent", {included = "MouseMenuComponent"})
---@class EditorTileset: Object
---@class EditorTileset: MouseMenuComponent
local EditorTileset, super = Class({Object, CLASS_NAME_GETTER"MouseMenuComponent"})
---@cast super Object|MouseMenuComponent

---@param tileset Tileset
function EditorTileset:init(tileset, x, y)
    super.init(self, x, y)
    self:setTileset(tileset)
end

---@param tileset Tileset
function EditorTileset:setTileset(tileset)
    if type(tileset) == "string" then
        tileset = Registry.getTileset(tileset)
        assert(tileset)
    end
    self.tileset = tileset
    self.width = tileset.tile_width * self.tileset.columns
    self.height = tileset.tile_height * (self.tileset.tile_count / self.tileset.columns)
end

---@return number?
function EditorTileset:getHoveredTile(input_mousex, input_mousey)
    local hovered, mx, my = self:isHovered()
    if not hovered then return end
    -- TODO: Use simple math to optimize this
    for x = 1, self.tileset.columns do
        for y = 0, math.floor(self.tileset.tile_count / self.tileset.columns) - 1 do
            local tile_id = (x + (y * self.tileset.columns)) - 1
            local xpos, ypos = (x - 1) * self.tileset.tile_height, y * self.tileset.tile_width
            if CollisionUtil.pointRect(mx, my, xpos, ypos, self.tileset:getTileSize(tile_id)) then
                return tile_id
            end
        end
    end
end

function EditorTileset:draw()
    super.draw(self)
    local active_tileset, active_tile = unpack(Editor.tiles_editor.active_tile)
    for x = 1, self.tileset.columns do
        for y = 0, math.floor(self.tileset.tile_count / self.tileset.columns) - 1 do
            local tile_id = (x + (y * self.tileset.columns)) - 1
            local xpos, ypos = (x - 1) * self.tileset.tile_height, y * self.tileset.tile_width
            self.tileset:drawTile(tile_id, xpos, ypos)
            if active_tileset == self.tileset and active_tile == tile_id then
                local w, h = self.tileset:getTileSize(tile_id)
                love.graphics.setLineWidth(2)
                love.graphics.rectangle("line", xpos + 1, ypos + 1, w - 2, h - 2)
            end
        end
    end
end

function EditorTileset:update()
    super.update(self)
    local clicked, globalmx, globalmy = Input.mousePressed(1)
    if not clicked then return end
    local tile = self:getHoveredTile(globalmx, globalmy)
    if not tile then return end
    Editor.tiles_editor:setActiveTile(self.tileset, tile)
end

return EditorTileset