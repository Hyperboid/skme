---@class EditorMenubar: Object
local EditorMenubar, super = Class(Object)

function EditorMenubar:init()
    super.init(self, 0, 0, SCREEN_WIDTH, 20)
    self:refresh()
end

function EditorMenubar:refresh()
    if self.bar then self.bar:remove() end
    self.bar = MenubarComponent(FixedSizing(SCREEN_WIDTH), FixedSizing(20))
    self.bar:setLayout(HorizontalLayout())
    local file = self.bar:addChild(MenubarItemComponent("File"))
        file:addItem("New", SKME.stub("New file"))
        file:addItem("Open", SKME.stub("Open"))
        file:addItem(SeparatorComponent({thickness = 2})):setMargins(0,2,0,0)
        file:addItem("Save", function () Editor:saveData() end)
        file:addItem("Import Tiled Map (maybe)", SKME.stub("Import Tiled Map"))
    local edit = self.bar:addChild(MenubarItemComponent("Edit"))
        local newlayer = edit:addItem("New Layer")
            newlayer:addItem("Tile Layer", SKME.stub("New Tile Layer"))
            newlayer:addItem("Object Layer", function ()
                Editor:addLayer(EditorObjectLayer())
            end)
            newlayer:addItem("Controller Layer", SKME.stub("New Controller Layer"))
            newlayer:addItem("Shape Layer", SKME.stub("New Shape Layer"))
    self:addChild(self.bar)
end

return EditorMenubar