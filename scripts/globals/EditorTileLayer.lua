assert(CLASS_NAME_GETTER"EditorLayer", {included = "EditorLayer"})
---@class EditorTileLayer : TileLayer
---@class EditorTileLayer : EditorLayer
local EditorTileLayer, super = Class({TileLayer, CLASS_NAME_GETTER"EditorLayer"})

function EditorTileLayer:init(map, data)
    super.init(self, map, data)
    self.data = data
end

function EditorTileLayer:save()
    -- not much else to do here?
    return self.data
end

function EditorTileLayer:getContextOptions(context)
    context = EditorLayer.getContextOptions(self, context)
    return context
end

return EditorTileLayer