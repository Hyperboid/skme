---@class EditorTiles: SKMEState
---@field private active_tile {[1]:Tileset,[2]:integer} Deprecated, single-tile variant of clipboard
---@field clipboard EditorTiles.SingleTile[][] Tiles that will be painted.
local EditorTiles, super = Class("SKMEState")

---@class EditorTiles.SingleTile
---@field set Tileset
---@field tile integer

function EditorTiles:init()
    self.browser = EditorTileBrowser()
    self.tileset = EditorTileset("castle", 0, 20)
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
    ---@deprecated
    self.active_tile = {tileset, tile}
    self.clipboard = {{{set = tileset, tile = tile}}}
end

return EditorTiles