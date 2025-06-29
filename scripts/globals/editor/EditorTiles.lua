---@class EditorTiles: SKMEState
---@field active_tile {[1]:Tileset,[2]:integer}
local EditorTiles, super = Class("SKMEState")

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
    self.active_tile = {tileset, tile}
end

return EditorTiles