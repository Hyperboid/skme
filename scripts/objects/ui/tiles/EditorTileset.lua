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
            local xpos, ypos = (x - 1) * self.tileset.tile_width, y * self.tileset.tile_height
            if CollisionUtil.pointRect(mx, my, xpos, ypos, self.tileset:getTileSize(tile_id)) then
                return tile_id
            end
        end
    end
end

function EditorTileset:draw()
    super.draw(self)
    for x = 1, self.tileset.columns do
        for y = 0, math.floor(self.tileset.tile_count / self.tileset.columns) - 1 do
            local tile_id = (x + (y * self.tileset.columns)) - 1
            local xpos, ypos = (x - 1) * self.tileset.tile_width, y * self.tileset.tile_height
            self.tileset:drawTile(tile_id, xpos, ypos)
            if Editor.tiles_editor.active_tiles[self.tileset.id .. "#" .. tile_id] then
                local w, h = self.tileset:getTileSize(tile_id)
                love.graphics.setLineWidth(1)
                love.graphics.rectangle("line", xpos + 1, ypos + 1, w - 2, h - 2)
            end
        end
    end
end

function EditorTileset:update()
    super.update(self)
    local mousedown, globalmx, globalmy = Input.mouseDown(1)
    local tile = self:getHoveredTile(globalmx, globalmy)
    if not tile then
    elseif Input.mousePressed(1) then
        Editor.tiles_editor:setActiveTile(self.tileset, tile)
        self.pressed_tile = tile
    elseif mousedown then
        local function id_to_xy(n)
            if type(n) ~= "number" then return n end
            return ((n) % (self.tileset.columns)), math.floor(n / (self.tileset.columns))
        end
        local function xy_to_id(x, y)
            return (x + (y * self.tileset.columns))
        end
        local startx, starty = id_to_xy(self.pressed_tile)
        local endx, endy = id_to_xy(self:getHoveredTile())
        if (not startx) or (not starty) then return end
        if (not endx) or (not endy) then return end
        if startx > endx then
            startx, endx = endx, startx
        end
        if starty > endy then
            starty, endy = endy, starty
        end
        local clipboard = {}
        print("start",startx, starty)
        print("end",endx, endy)
        for y = starty, endy do
            local row = {}
            for x = startx, endx do
                table.insert(row, {tile = xy_to_id(x, y), set = self.tileset})
            end
            table.insert(clipboard, row)
        end
        print("clipboard",#clipboard, #clipboard[1])
        print()
        Editor.tiles_editor:setClipboard(clipboard)
    end
end

return EditorTileset