---@class TileLayer : TileLayer
---@class TileLayer : EditorLayer
local TileLayer, super = Utils.hookScript(TileLayer)

function TileLayer:init(map, data)
    super.init(self, map, data)
    self.data = data
end

function TileLayer:save()
    -- not much else to do here?
    return self.data
end

function TileLayer:getContextOptions(context)
    context = EditorLayer.getContextOptions(self, context)
    return context
end

return TileLayer