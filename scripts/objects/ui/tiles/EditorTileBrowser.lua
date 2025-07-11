---@class EditorTileBrowser: Object
local EditorTileBrowser, super = Class(Object)

function EditorTileBrowser:init()
    super.init(self, 200, SCREEN_HEIGHT - 120, SCREEN_WIDTH - 200, 120)
    self:refresh()
end

function EditorTileBrowser:refresh()
    if self.wrapper then self.wrapper:remove() end
    self.wrapper = Component(FixedSizing(SCREEN_WIDTH-200), FixedSizing(120))
    -- self.wrapper.debug_select = false
    self.menu = MouseMenuComponent(ScrollFillSizing(), ScrollFillSizing())
    self.menu:setLayout(GridLayout())
    self.menu:setScrollbar(ScrollbarComponent())
    self.menu.overflow = "scroll"
    self.menu:setScrollType("scroll")
    self.wrapper:setPadding(0,0,8,0)

    ---@type table<string, EditorTilesetButton>
    self.buttons = {}
    self:populateTilesets()
    self.menu:setParent(self.wrapper)
    self.wrapper:setParent(self)
end

function EditorTileBrowser:addTileset(tileset)
    local button = EditorTilesetButton(tileset)
    self.buttons[tileset.id] = button
    self.menu:addChild(button)
    return button
end

function EditorTileBrowser:populateTilesets()
    for _, tileset in pairs(Registry.tilesets) do
        self:addTileset(tileset)
    end
end

return EditorTileBrowser