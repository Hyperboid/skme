-- Inheriting from object because we need them to be.. well... in the editor.
---@class EditorLayer: Object
local EditorLayer, super = Class(Object)

EditorLayer.DEFAULT_NAME = "Layer"

function EditorLayer:init(data)
    super.init(self)
    self.name = data.name or self.DEFAULT_NAME
end

function EditorLayer:save()
    return {
        name = self.name
    }
end

---@param context ContextMenu The menu object containing the options that can be used.
---@return ContextMenu context The modified menu object.
function EditorLayer:getContextOptions(context)
    context:addMenuItem("Delete", "Delete this layer", function()
        Kristal.Console:log("Not yet implemented")
    end)
    return context
end

return EditorLayer