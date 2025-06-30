---@class EditorShapeLayer : EditorLayer
local EditorShapeLayer, super = Class("EditorLayer")

function EditorShapeLayer:init(data)
    super.init(self, data)
    self.shapes = {}
    for index, shapedata in ipairs(data and data.shapes or {}) do
        local shape = EditorShape(shapedata.name, nil, shapedata)
        table.insert(self.shapes, shape)
        self:addChild(shape)
    end
    
end

function EditorShapeLayer:save()
    local data = super.save(self)
    data.shapes = {}
    for index, value in pairs(self.shapes) do
        data.shapes[index] = value:save()
    end
    return data
end

return EditorShapeLayer