---@class EditorShapeLayer : EditorLayer
local EditorShapeLayer, super = Class("EditorLayer")

function EditorShapeLayer:init(data)
    super.init(self, data)
    self.shapes = {}
    for index, shapedata in ipairs(data and data.shapes or {}) do
        local shape = EditorShape(shapedata)
        table.insert(self.shapes, shape)
        self:addChild(shape)
    end
    self:setType(data and data.type or "collision")
end

function EditorShapeLayer:addShape(shape)
    table.insert(self.shapes, shape)
    self:addChild(shape)
end

function EditorShapeLayer:setType(type)
    self.type = type
    if self.type == "collision" then
        self.ICON = "ui/editor/layer/collision"
        self.color = {0, 0, 1}
    elseif self.type == "battleareas" then
        self.ICON = "ui/editor/layer/battleareas"
        self.color = {1, 0, 0}
    elseif self.type == "enemycollision" then
        self.ICON = "ui/editor/layer/enemycollision"
        self.color = {0.5, 0.5, 1}
    elseif self.type == "markers" then
        self.ICON = "ui/editor/layer/markers"
        self.color = {0.5, 0, 1}
    end
end

function EditorShapeLayer:getContextOptions(context)
    context = super.getContextOptions(self, context) or context
    context:addMenuItem("Convert to collision", "", function ()
        self:setType("collision")
    end)
    context:addMenuItem("Convert to enemy collision", "", function ()
        self:setType("enemycollision")
    end)
    context:addMenuItem("Convert to battle area", "", function ()
        self:setType("battleareas")
    end)
    context:addMenuItem("Convert to markers", "", function ()
        self:setType("markers")
    end)
    return context
end

function EditorShapeLayer:save()
    local data = super.save(self)
    data.shapes = {}
    data.type = self.type
    for index, value in pairs(self.shapes) do
        data.shapes[index] = value:save()
    end
    return data
end

return EditorShapeLayer