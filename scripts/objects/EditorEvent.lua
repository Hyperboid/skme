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
    if not (self.meta and (self.meta.sprite or self.meta.point)) then
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
            name = propdata.name or propdata.id,
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
        elseif dattype == "boolean" then
            component = CheckboxMenuItemComponent(options)
        elseif dattype == "number" then
            self.properties[propdata.id] = self.properties[propdata.id] or 0
            component = NumberInputMenuItemComponent(options)
        end

        if component then
            inspector:addToMenu(component)
        end

    end
end

---@param context ContextMenu
function EditorEvent:registerEditorContext(context)
    
end

function EditorEvent:draw()
    super.draw(self)
    Draw.setColor(1,0,1)
    self:drawOverlay()
end

function EditorEvent:drawOverlay(force, fill)
    if not force and Gamestate.current() ~= Editor then return end
    local alpha = Editor.active_layer == self.parent and 1 or 0.2
    local r, g, b = love.graphics.getColor()
    love.graphics.setPointSize(1)
    love.graphics.points(0, 0)
    love.graphics.push()
    love.graphics.scale(1 / self.scale_x)
    love.graphics.setFont(Assets.getFont("main",16))
    Draw.setColor(0,0,0,alpha^2)
    love.graphics.push()
        local textx, texty = love.graphics.transformPoint((self.width/2) + 1,0 - 16)
        textx = Utils.clamp(textx, Editor.margins[1], SCREEN_WIDTH-Editor.margins[3])
        texty = Utils.clamp(texty, Editor.margins[2]-10, SCREEN_HEIGHT-Editor.margins[4] - 10)
        love.graphics.origin()
        Draw.setColor(0,0,0,alpha^2)
        Draw.printAlign(self.type or "", textx + 0,0 + texty, "center")
        Draw.printAlign(self.type or "", textx + 2,0 + texty, "center")
        Draw.printAlign(self.type or "", textx + 1,-1 + texty, "center")
        Draw.printAlign(self.type or "", textx + 1,1 + texty, "center")
        Draw.setColor(r+.5,g+.5,b+.5,alpha)
        Draw.printAlign(self.type or "", textx + 1,0 + texty, "center")
    love.graphics.pop()
    Draw.setColor(r, g, b, alpha)
    love.graphics.pop()
    love.graphics.setLineWidth(2 / self.scale_x)
    if self.collider then
        if self.collider:includes(PolygonCollider) then
            local unpacked = {}
            for _,point in ipairs(self.collider.points) do
                table.insert(unpacked, point[1])
                table.insert(unpacked, point[2])
            end
            table.insert(unpacked, unpacked[1])
            table.insert(unpacked, unpacked[2])
            love.graphics.line(unpack(unpacked))
            if (Editor.objects_editor.state == "POINTS" and Editor.objects_editor.selected_object == self)
            or (Editor.shapes_editor.state == "POINTS" and Editor.shapes_editor.selected_object == self)
             then
                love.graphics.setPointSize(10)
                for _,point in ipairs(self.collider.points) do
                    love.graphics.points(point[1], point[2])
                end
            end
            Draw.setColor(1, 1, 1, 1)
        elseif self.collider:includes(Hitbox) then
            love.graphics.rectangle("line", self.collider.x, self.collider.y, self.collider.width, self.collider.height)
        else
            self.collider:draw(r,g,b)
        end
        if fill then
            self.collider:drawFill(r,g,b,alpha*0.5)
        end
    else
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
        if fill then
            Draw.setColor(r, g, b, alpha*0.5)
            love.graphics.rectangle("fill", 0, 0, self.width, self.height)
            
        end
    end
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
        shape = "rectangle",
    }
    if self.collider and self.collider:includes(PolygonCollider) then
        data.shape = "polygon"
        data.polygon = {}
        for _, p in ipairs(self.collider.points) do
            table.insert(data.polygon, {x = p[1], y = p[2]})
        end
    end
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