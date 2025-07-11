---@class EditorTilesetButton: AbstractMenuItemComponent
local EditorTilesetButton, super = Class(AbstractMenuItemComponent)

---@param tileset Tileset
function EditorTilesetButton:init(tileset)
    super.init(self, FixedSizing(60), FixedSizing(60))
    self.hovered = false
    self.name = tileset.id
    self.tileset = tileset
    self:setMargins(4, 4, 0, 0)
    local layout = VerticalLayout()
    layout.align = "end"
    self:setLayout(layout)
    self:addFX(MaskFX(self))
end

function EditorTilesetButton:drawMask()
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    love.graphics.rectangle("fill", -4, -4, self.width, self.height)
end

function EditorTilesetButton:draw()
    love.graphics.setFont(Assets.getFont("main", 16))
    super.draw(self)
    love.graphics.printf(self.name, 0, 0, self.width)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
end

function EditorTilesetButton:onSelected()
    Assets.playSound("ui_select")
    local ed = Editor.tiles_editor.tileset
    ed:setTileset(self.tileset)
    
end

function EditorTilesetButton:onHovered(hovered)
    self.hovered = not not hovered
end

return EditorTilesetButton