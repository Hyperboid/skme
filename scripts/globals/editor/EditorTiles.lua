---@class EditorTiles: SKMEState
local EditorTiles, super = Class("SKMEState")

function EditorTiles:init()
    self.browser = EditorTileBrowser()
    self.tileset = EditorTileset("castle", 0, 20)
end

function EditorTiles:onEnter(prev_state)
    self.browser:setParent(Editor.stage)
    self.tileset:setParent(Editor.stage)
end

function EditorTiles:onLeave(next_state)
    self.browser:setParent()
    self.tileset:setParent()
end

return EditorTiles