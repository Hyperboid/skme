assert(CLASS_NAME_GETTER"EditorLayer", {included = "EditorLayer"})
---@class EditorTileLayer : TileLayer
---@class EditorTileLayer : EditorLayer
local EditorTileLayer, super = Class({TileLayer, CLASS_NAME_GETTER"EditorLayer"})

EditorTileLayer.TYPE = "tilelayer"

function EditorTileLayer:init(map, data)
    super.init(self, map, data)
    self.data = data
    self:editorLayerInit(data)
end

function EditorTileLayer:update()
    super.update(self)
    local startx, starty = self:getHoveredTile()
    if not startx then return end
    if Input.mouseDown(1) then
        if Input.shift() then
            self:setTile(startx, starty, 0)
        else
            for y, row in ipairs(Editor.tiles_editor.clipboard) do
                for x, tile in ipairs(row) do
                    self:setTile(startx+x-1, starty+y-1, tile.set.id, tile.tile)
                end
            end
        end
    elseif Input.mouseDown(2) then
        -- TODO: Selection, cut, and copy
    end
end

function EditorTileLayer:getHoveredTile()
    if Editor.active_layer ~= self then return nil end
    local globalmousex, globalmousey = Input.getMousePosition()
    if globalmousex < Editor.margins[1] or globalmousex > (SCREEN_WIDTH - Editor.margins[3]) then return end
    if globalmousey < Editor.margins[2] or globalmousey > (SCREEN_HEIGHT - Editor.margins[4]) then return end
    local mx, my = self:getFullTransform():inverseTransformPoint(globalmousex, globalmousey)
    return math.floor(mx / (self.width / self.map_width)),
        math.floor(my / (self.height / self.map_height))
end

function EditorTileLayer:draw()
    super.draw(self)
end

function EditorTileLayer:save()
    -- not much else to do here?
    local data = super.save(self)
    data.type = "tilelayer"
    data.encoding = "lua"
    data.opacity = 1
    data.data = self.tile_data
    data.parallaxx = self.parallax_x
    data.parallaxy = self.parallax_y
    data.properties = self.properties or {}
    return data
end

function EditorTileLayer:registerProperties(inspector)
    super.registerProperties(self, inspector)
    inspector:addToMenu(NumberInputMenuItemComponent({
        ref = {self, "parallax_x"},
    }))
    inspector:addToMenu(NumberInputMenuItemComponent({
        ref = {self, "parallax_y"},
    }))
end

function EditorTileLayer:getContextOptions(context)
    context = EditorLayer.getContextOptions(self, context)
    return context
end

return EditorTileLayer