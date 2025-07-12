-- Inheriting from object because we need them to be.. well... in the editor.
---@class EditorLayer: Object
local EditorLayer, super = Class(Object)

EditorLayer.DEFAULT_NAME = "Layer"
EditorLayer.TYPE = "someone forgot to set the TYPE field when programming the layer..."

function EditorLayer:init(data)
    super.init(self)
    self:editorLayerInit(data)
end

function EditorLayer:editorLayerInit(data)
    self.properties = data and data.properties or {}
    self.name = data and data.name or self.DEFAULT_NAME
    if data then
        self.visible = data.visible ~= false
    end
end

---@param inspector EditorInspector
function EditorLayer:registerProperties(inspector)
    inspector:addToMenu(FieldMenuItemComponent({
        ref = {self, "name"}, name = "Name"
    }))
end

function EditorLayer:save()
    local data = {
        name = self.name,
        visible = self.visible,
        type = self.TYPE,
        properties = self.properties,
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
        Editor:endAction()
    end)
    context:addMenuItem(self.visible and "Hide" or "Show", "Make this layer " .. (self.visible and "in" or "").."visible.", function ()
        self.visible = not self.visible
        Editor:endAction()
    end)
    context:addMenuItem("Mark as party layer", "Mark this layer as the one where the party will appear.", function ()
        Editor.world.map.party_layer = self
        Editor:endAction()
    end)
    context:addMenuItem("Properties", "Open layer's properties in the inspector", function ()
        Editor.inspector.visible = true
        Editor.inspector:onSelectObject(self)
    end)
    return context
end

return EditorLayer