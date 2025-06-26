---@class EditorEvent: Object
---@field eventtype Event?
---@field meta table?
local EditorEvent, super = Class(Object)

function EditorEvent:init(name, eventtype, data)
    self.object_id = data.id
    self.type = name
    ---@type Event
    self.eventtype = eventtype
    self.meta = self.eventtype and self.eventtype["EDITOR_METADATA"] or {}
    print(Utils.dump(eventtype))
    self.data = data
    super.init(self, data.x, data.y, data.width, data.height)
    if data.polygon then
        self.collider = Utils.colliderFromShape(self, {shape = "polygon", polygon = data.polygon})
    end
    self.properties = data.properties or {}
    
    if self.meta.origin then
        local ox, oy = unpack(type(self.meta.origin) == "number" and {self.meta.origin, self.meta.origin} or self.meta.origin)
        if self.meta.origin.exact then
            self:setOriginExact(ox, oy or ox)
        else
            self:setOrigin(ox, oy or ox)
        end
    end

    if self.meta.sprite then
        self.sprite = Sprite(self.meta.sprite)
        self.sprite:setScale(2)
        self:addChild(self.sprite)
        if not data.width or data.width == 0 then
            self.width = self.sprite:getScaledWidth()
        end
        if not data.height or data.height == 0 then
            self.height = self.sprite:getScaledHeight()
        end
    end
end

---@param inspector EditorInspector
function EditorEvent:registerProperties(inspector)
    inspector:addToMenu(NumberInputMenuItemComponent({
        ref = {self, "x"},
    }))
    inspector:addToMenu(NumberInputMenuItemComponent({
        ref = {self, "y"},
    }))
    if not (self.meta and self.meta.sprite) then
        inspector:addToMenu(NumberInputMenuItemComponent({
            ref = {self, "width"},
        }))
        inspector:addToMenu(NumberInputMenuItemComponent({
            ref = {self, "height"},
        }))
    end

    for _, propdata in ipairs(self.meta and self.meta.properties or {}) do
        local options = {
            ref = {self.properties, propdata.id},
            name = propdata.name,
            completions = propdata.completions,
        }
        ---@type type
        local dattype = propdata.type
        ---@type Component?
        local component
        if dattype == "string" then
            self.properties[propdata.id] = self.properties[propdata.id] or ""
            if options.completions then
                component = CompletionFieldMenuItemComponent(options)
            else
                component = FieldMenuItemComponent(options)
            end
        elseif dattype == "number" then
            self.properties[propdata.id] = self.properties[propdata.id] or 0
            component = NumberInputMenuItemComponent(options)
        end

        if component then
            inspector:addToMenu(component)
        end

    end
end

function EditorEvent:draw()
    local alpha = Editor.active_layer == self.parent and 1 or 0.2
    super.draw(self)
    love.graphics.push()
    love.graphics.scale(1 / self.scale_x)
    love.graphics.setFont(Assets.getFont("main",16))
    Draw.setColor(0,0,0,alpha^2)
    love.graphics.printf(self.type or "", 0,0,(self.width * self.scale_x) - 4)
    love.graphics.printf(self.type or "", 2,0,(self.width * self.scale_x) - 4)
    love.graphics.printf(self.type or "", 1,-1,(self.width * self.scale_x) - 4)
    love.graphics.printf(self.type or "", 1,1,(self.width * self.scale_x) - 4)
    Draw.setColor(1,.5,1,alpha)
    love.graphics.printf(self.type or "", 1,0,(self.width * self.scale_x) - 4)
    Draw.setColor(1,0,1,alpha)
    love.graphics.pop()
    love.graphics.setLineWidth(2 / self.scale_x)
    love.graphics.rectangle("line", -1, -1, self.width+2, self.height+2)
end

function EditorEvent:getDebugRectangle()
    local rect = super.getDebugRectangle(self)
    local padding = 4
    rect[1] = rect[1] - padding
    rect[2] = rect[2] - padding
    rect[3] = rect[3] + (padding * 2)
    rect[4] = rect[4] + (padding * 2)
    return rect
end

function EditorEvent:save()
    local data = {
        type = self.type,
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height,
        properties = self.properties and Utils.copy(self.properties, true),
        id = self.object_id,
    }
    if self.meta and self.meta.point then
        data.width = 0
        data.height = 0
    end
    for _, prop in pairs(self.meta and self.meta.properties or {}) do
        local key = prop.id
        local value = data.properties[key]
        if prop.delete_empty and (value == "" or value == 0) then
            data.properties[key] = nil
        end
    end
    self:onSave(data)
    return data
end

function EditorEvent:onSave(data) end

return EditorEvent