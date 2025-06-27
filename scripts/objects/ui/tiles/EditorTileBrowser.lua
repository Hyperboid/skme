---@class EditorTileBrowser: Object
local EditorTileBrowser, super = Class(Object)

function EditorTileBrowser:init()
    super.init(self, 200, SCREEN_HEIGHT - 120, SCREEN_WIDTH - 200, 120)
    -- self.tiles = self:addChild(EditorTileset(Registry.getTileset('castle')))
end

return EditorTileBrowser