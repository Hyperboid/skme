---@class EditorMarkerLayer: EditorLayer
---@field markers table<string, {[1]: number, [2]:number}>
local EditorMarkerLayer, super = Class("EditorLayer")

function EditorMarkerLayer:init(data)
    super.init(self, data)
    self.markers = {}
end

return EditorMarkerLayer