---@class EditorMenubar: Object
local EditorMenubar, super = Class(Object)

function EditorMenubar:init()
    super.init(self, 0, 0, SCREEN_WIDTH, 20)
    self.layer = 100
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
            newlayer:addItem("Tile Layer", function ()
                local tiledata = {}
                for i = 1, Editor.world.map.width * Editor.world.map.height do
                    table.insert(tiledata, 0)
                end
                Editor:addLayer(EditorTileLayer(Editor.world.map, {
                    data = tiledata
                }))
            end)
            newlayer:addItem("Object Layer", function ()
                Editor:addLayer(EditorObjectLayer())
            end)
            newlayer:addItem("Controller Layer", function ()
                Editor:addLayer(EditorControllerLayer())
            end)
            newlayer:addItem("Shape Layer", function ()
                Editor:addLayer(EditorShapeLayer())
            end)
        edit:addItem("Map properties", function ()
            Editor.inspector:onSelectObject(Editor.world.map)
        end)
    self:addChild(self.bar)
end

return EditorMenubar