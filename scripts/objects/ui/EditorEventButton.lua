---@class EditorEventButton: AbstractMenuItemComponent
local EditorEventButton, super = Class(AbstractMenuItemComponent)

function EditorEventButton:init(name, eventclass)
    super.init(self, FixedSizing(60), FixedSizing(60))
    self.hovered = false
    self.name = name
    self:setMargins(4, 4, 0, 0)
    self.meta = eventclass and eventclass.EDITOR_METADATA or {}
    local layout = VerticalLayout()
    layout.align = "end"
    self:setLayout(layout)
    if self.meta.sprite then
        self:addChild(Sprite(self.meta.sprite))
    end
end

function EditorEventButton:draw()
    love.graphics.setFont(Assets.getFont("main", 16))
    super.draw(self)
    love.graphics.printf(self.name, 0, 0, self.width)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
end

function EditorEventButton:onSelected()
    Assets.playSound("grab")
    ---@type EditorObjectLayer
    local layer = Editor.active_layer
    local event = layer:loadObject(self.name, {
        type = self.name,
        width = 40,
        height = 40,
    })
    event:setPosition(Editor.world.player:getPosition())
    layer:addObject(event)
    Editor.objects_editor:selectObject(event)
    Editor:endAction()
end

function EditorEventButton:onHovered(hovered)
    self.hovered = not not hovered
end

return EditorEventButton