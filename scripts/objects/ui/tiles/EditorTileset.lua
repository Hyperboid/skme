---@class EditorTileset: Object
local EditorTileset, super = Class(Object)

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
end

module

function EditorTileset:draw()
    super.draw(self)
    Draw.draw(self.tileset.texture)
end

return EditorTileset