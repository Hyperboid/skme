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

function EditorShapeLayer:mouseIntersectsShape(shape, mx, my)
    if not mx or not my then
        mx, my = self:getFullTransform():inverseTransformPoint(Input.getMousePosition())
    end
    if shape.shape == "rectangle" then
        return CollisionUtil.pointRect(mx, my, shape.x - 2, shape.y - 2, shape.width + 4, shape.height + 4)
    elseif shape.shape == "polygon" then
        local repacked = {}
        for index, value in ipairs(shape.polygon) do
            repacked[index] = {value.x, value.y}
        end
        return CollisionUtil.rectPolygon(mx-1, my-1, 2, 2, repacked)
    end
end

function EditorShapeLayer:getHoveredShape(mx, my)
    if not mx or not my then
        mx, my = self:getFullTransform():inverseTransformPoint(Input.getMousePosition())
    end
    local sorted = Utils.copy(self.shapes, false)
    table.stable_sort(sorted, function (a, b) return a.y > b.y end)
    for index, shape in ipairs(sorted) do
        if self:mouseIntersectsShape(shape, mx, my) then
            return shape
        end
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