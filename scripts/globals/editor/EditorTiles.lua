---@class EditorTiles: SKMEState
---@field clipboard EditorTiles.SingleTile[][] Tiles that will be painted.
local EditorTiles, super = Class("SKMEState")

---@class EditorTiles.SingleTile
---@field set Tileset
---@field tile integer

function EditorTiles:init()
    self.browser = EditorTileBrowser()
    self.tileset = EditorTileset("castle", 0, 20)
    self.state = "DRAW"
    self:setActiveTile(self.tileset.tileset, 1)
end

function EditorTiles:onEnter(prev_state)
    self.browser:setParent(Editor.stage)
    self.tileset:setParent(Editor.stage)
end

function EditorTiles:onLeave(next_state)
    self.browser:setParent()
    self.tileset:setParent()
end

---@param tileset Tileset
---@param tile integer
function EditorTiles:setActiveTile(tileset, tile)
    self:setClipboard({{{set = tileset, tile = tile}}})
end

---@param rows EditorTiles.SingleTile[][]
function EditorTiles:setClipboard(rows)
    self.clipboard = rows
    local active_tiles = {}
    for x, row in ipairs(rows) do
        for y, tile in ipairs(row) do
            local id = tile.set.id .. "#" .. (tile.tile or -1)
            active_tiles[tile.set.id .. "#" .. tile.tile] = true
        end
    end
    self.active_tiles = active_tiles
end

return EditorTiles