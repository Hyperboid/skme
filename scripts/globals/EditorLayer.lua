-- Inheriting from object because we need them to be.. well... in the editor.
---@class EditorLayer: Object
local EditorLayer, super = Class(Object)

EditorLayer.DEFAULT_NAME = "Layer"

function EditorLayer:init(data)
    super.init(self)
    self:editorLayerInit(data)
end

function EditorLayer:editorLayerInit(data)
    self.name = data and data.name or self.DEFAULT_NAME
    if data then
        self.visible = data.visible ~= false
    end
end

function EditorLayer:save()
    local data = {
        name = self.name,
        visible = self.visible,
    }
    self:onSave(data)
    return data
end

function EditorLayer:onSave(data) end

---@param context ContextMenu The menu object containing the options that can be used.
---@return ContextMenu context The modified menu object.
function EditorLayer:getContextOptions(context)
    context:addMenuItem("Delete", "Delete this layer", function ()
        if Editor.world.map.layers then
            
        end
        Utils.removeFromTable(Editor.world.map.layers, self)
        self:remove()
    end)
    context:addMenuItem(self.visible and "Hide" or "Show", "Make this layer " .. (self.visible and "in" or "").."visible.", function ()
        self.visible = not self.visible
    end)
    context:addMenuItem("Mark as party layer", "Mark this layer as the one where the party will appear.", function ()
        Editor.world.map.party_layer = self
    end)
    return context
end

return EditorLayer