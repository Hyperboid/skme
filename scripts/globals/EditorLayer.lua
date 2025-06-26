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

return EditorLayer