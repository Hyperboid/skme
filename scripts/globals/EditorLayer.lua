-- Inheriting from object because we need them to be.. well... in the editor.
---@class EditorLayer: Object
local EditorLayer, super = Class(Object)

EditorLayer.DEFAULT_NAME = "Layer"

function EditorLayer:init(data)
    super.init(self)
    self.name = data and data.name or self.DEFAULT_NAME
end

function EditorLayer:save()
    return {
        name = self.name
    }
end

---@param context ContextMenu The menu object containing the options that can be used.
---@return ContextMenu context The modified menu object.
function EditorLayer:getContextOptions(context)
    context:addMenuItem("Delete", "Delete this layer", SKME.stub("Layer deletion"))
    context:addMenuItem("Mark as party layer", "Mark this layer as the one where the party will appear.", function ()
        Editor.world.map.party_layer = self
    end)
    return context
end

return EditorLayer