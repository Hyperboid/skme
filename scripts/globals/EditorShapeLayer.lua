---@class EditorShapeLayer : EditorLayer
local EditorShapeLayer, super = Class("EditorLayer")

function EditorShapeLayer:init(data)
    super.init(self, data)
    self.shapes = data.shapes or {}
    
end

function EditorShapeLayer:mouseIntersectsShape(shape, mx, my)
    if not mx or not my then
        mx, my = self:getFullTransform():inverseTransformPoint(Input.getMousePosition())
    end
    if shape.shape == "rectangle" then
        return CollisionUtil.pointRect(mx, my, shape.x - 2, shape.y - 2, shape.width + 4, shape.height + 4)
    elseif shape.shape == "polygon" then
        return CollisionUtil.rectPolygon(mx-1, my-1, 2, 2, shape.polygon)
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

function EditorShapeLayer:drawShape(shape)
    local oldr, oldg, oldb, olda = love.graphics.getColor()
    if shape.shape == "rectangle" then
        love.graphics.rectangle("line", shape.x, shape.y, shape.width, shape.height)
        Draw.setColor(oldr, oldg, oldb, olda / 2)
        love.graphics.rectangle("fill", shape.x, shape.y, shape.width, shape.height)
    elseif shape.shape == "polygon" then
        love.graphics.push()
        love.graphics.translate(shape.x, shape.y)
        local unpacked = {}
        for _,point in ipairs(shape.polygon) do
            table.insert(unpacked, point.x)
            table.insert(unpacked, point.y)
        end
        love.graphics.polygon("line", unpacked)
        Draw.setColor(oldr, oldg, oldb, olda / 2)
        local triangles = love.math.triangulate(unpacked)
        for _,triangle in ipairs(triangles) do
            love.graphics.polygon("fill", triangle)
        end
        love.graphics.pop()
    else
        love.graphics.setColor(1,0,0)
        love.graphics.points(shape.x, shape.y)
    end
    Draw.setColor(oldr, oldg, oldb, olda)
end

function EditorShapeLayer:save()
    local data = super.save(self)
    data.shapes = self.shapes
    return data
end

return EditorShapeLayer