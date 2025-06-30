assert(CLASS_NAME_GETTER"EditorLayer", {included = "EditorLayer"})
---@class EditorTileLayer : TileLayer
---@class EditorTileLayer : EditorLayer
local EditorTileLayer, super = Class({TileLayer, CLASS_NAME_GETTER"EditorLayer"})

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
        for y, row in ipairs(Editor.tiles_editor.clipboard) do
            for x, tile in ipairs(row) do
                self:setTile(startx+x-1, starty+y-1, tile.set.id, tile.tile)
            end
        end
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
    return Utils.mergeMultiple(self.data, super.save(self), {type = "tilelayer"})
end

function EditorTileLayer:getContextOptions(context)
    context = EditorLayer.getContextOptions(self, context)
    return context
end

return EditorTileLayer