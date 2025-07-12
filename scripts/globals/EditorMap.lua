---@class EditorMap: Map
---@field layers EditorLayer[]
---@field party_layer EditorLayer?
local EditorMap, super = Class(Map)

function EditorMap:init(world, data)
    super.init(self, world, data)
    self.properties = data and data.properties or {
        light = false,
        keepmusic = false,
        music = nil,
        name = nil,
    }
    self.layers = {}
    for index, layerdata in ipairs(self.data and self.data.layers or {}) do
        self.layers[index] = self:createLayer(layerdata.type or "what", layerdata)
        if index == data.party_layer then
            self.party_layer = self.layers[index]
        end
    end
    if data then
        self.id = data.id
    end
end

---@param inspector EditorInspector
function EditorMap:registerProperties(inspector)
    inspector:addToMenu(FieldMenuItemComponent({
        ref = {self.properties, "name"}, name = "Name"
    }))
    inspector:addToMenu(CompletionFieldMenuItemComponent({
        ref = {self.properties, "music"}, name = "Music", completions = Assets.data.music
    }))
    inspector:addToMenu(CompletionFieldMenuItemComponent({
        ref = {self.properties, "border"}, name = "Border", completions = function ()
            local borders = Utils.getFilesRecursive("assets/sprites/borders", ".png")
            if Mod then
                Utils.merge(borders, Utils.getFilesRecursive(Mod.info.path.."/assets/sprites/borders", ".png"))
                for _,mod_lib in pairs(Mod.libs) do
                    Utils.merge(borders, Utils.getFilesRecursive(mod_lib.info.path.."/assets/sprites/borders", ".png"))
                end
            end

            for key, value in pairs(Registry.borders) do
                table.insert(borders, key)
            end
            return Utils.removeDuplicates(borders)
        end
    }))
end

---@param ltype string
---@param data table
---@return EditorLayer
function EditorMap:createLayer(ltype, data)
    assert(self.tile_width)
    if ltype:lower() == "objectgroup" then
        return EditorObjectLayer(data, self)
    elseif ltype:lower() == "controllers" then
        return EditorControllerLayer(data, self)
    elseif ltype:lower() == "tilelayer" then
        local layer = EditorTileLayer(self, data)
        table.insert(self.tile_layers, layer)
        return layer
    -- Should always be last
    elseif type(data.shapes) == "table" then
        local layer = EditorShapeLayer(data, map)
        return layer
    end
    error("Invalid layer type: "..ltype)
end

function EditorMap:save()
    local data = {
        width = self.width,
        height = self.height,
        id = self.id,
        format = "skme",
        properties = self.properties,
        layers = {},
        tilesets = {},
        party_layer = self.party_layer and Utils.getKey(self.layers, self.party_layer)
    }
    for index, layer in ipairs(self.layers) do
        data.layers[index] = layer:save()
    end

    for index, tileset in ipairs(self.tilesets) do
        data.tilesets[index] = {
            firstgid = self.tileset_gids[tileset],
            id = tileset.id
        }
    end

    return data
end

function EditorMap:loadMapData(data)
    local object_depths = {}
    local tile_depths = {}
    local indexed_layers = {}
    local has_battle_border = false

    local layers = {}

    self.next_layer = self.depth_per_layer

    for i,layer in ipairs(self.layers) do
        -- self.layers[layer.name] = self.next_layer
        indexed_layers[i] = self.next_layer
        self:loadLayer(layer)
        self.next_layer = self.next_layer + self.depth_per_layer
    end

    if self.party_layer then
        self.object_layer = self.party_layer.layer
    end

    -- old behavior, ideally should not be used
    if not self.object_layer then
        self.object_layer = self.layers[#self.layers].layer
    end

    -- Set the tile layer depth to the closest tile layer below the object layer
    self.tile_layer = 0
    for _,depth in ipairs(tile_depths) do
        if depth >= self.object_layer then break end

        self.tile_layer = depth
    end

    -- If no battleborder layer, set the battle fader layer depth to be below the object layer
    if not has_battle_border then
        self.battle_fader_layer = self.object_layer - (self.depth_per_layer/2)
    end
end

function EditorMap:populateTilesets(data)
    ---@type Tileset[]
    self.tilesets = {}
    for _,tileset_data in ipairs(data) do
        local id = tileset_data.id
        local tileset_path = id
        local tileset
        tileset = Registry.getTileset(tileset_path)
        if not tileset then
            error("Failed to load map \""..self.data.id.."\", tileset not found: \""..id.."\"")
        end
        table.insert(self.tilesets, tileset)
        local gid = tileset_data.firstgid or (self.max_gid + 1)
        self.tileset_gids[tileset] = gid
        self.max_gid = math.max(self.max_gid, gid + tileset.id_count - 1)
    end
end

---@param layer EditorLayer
function EditorMap:loadLayer(layer)
    -- TODO: Some people think 1000 isn't enough. It will be for us.
    local layer_id_component = ((Utils.getKey(self.layers, layer) - 1) * 1000)
    if layer:includes(EditorControllerLayer) then
        layer.layer = self.next_layer
        ---@cast layer EditorControllerLayer
        for i, data in pairs(layer.data.objects) do
            data.width = data.width or 0
            data.height = data.height or 0
            data.center_x = data.x + data.width/2
            data.center_y = data.y + data.height/2
            local object = self:loadController(data.type, data)
            if object then
                object.object_id = object.object_id or ((i - 1) + layer_id_component)
                table.insert(self.events, object)
                object.layer = self.next_layer
                self.world:addChild(object)
            end
        end
    elseif layer:includes(EditorObjectLayer) then
        layer.layer = self.next_layer
        ---@cast layer EditorObjectLayer
        for i, data in pairs(layer.data.objects) do
            data.width = data.width or 0
            data.height = data.height or 0
            data.center_x = data.x + data.width/2
            data.center_y = data.y + data.height/2
            local object = self:loadObject(data.type, data)
            if object then
                object.object_id = object.object_id or ((i - 1) + layer_id_component)
                table.insert(self.events, object)
                object.layer = self.next_layer
                self.world:addChild(object)
            end
        end
    elseif layer:includes(EditorTileLayer) then
        local reallayer = TileLayer(self, layer.data)
        reallayer.layer = self.next_layer
        reallayer:setParent(self.world)
    elseif layer:includes(EditorShapeLayer) then
        ---@cast layer EditorShapeLayer
        if layer.type == "collision" then
            Utils.merge(self.collision, self:loadHitboxes(layer))
        elseif layer.type == "battleareas" then
            Utils.merge(self.battle_areas, self:loadHitboxes(layer))
        elseif layer.type == "markers" then
            self:loadMarkers(layer)
        end
    end
end

---@param layer EditorShapeLayer
function EditorMap:loadMarkers(layer)
    for _,v in ipairs(layer.shapes) do
        v.width = v.width or 0
        v.height = v.height or 0
        v.center_x = v.x + v.width/2
        v.center_y = v.y + v.height/2

        local marker = Utils.copy(v, true)

        marker.x = marker.x + (layer.offsetx or 0)
        marker.y = marker.y + (layer.offsety or 0)
        marker.center_x = marker.center_x + (layer.offsetx or 0)
        marker.center_y = marker.center_y + (layer.offsety or 0)

        self.markers[marker.name or marker.type or ""] = marker
    end
end

---@param layer EditorShapeLayer
function EditorMap:loadHitboxes(layer)
    if not isClass(layer) then
        return super.loadHitboxes(self, layer)
    end
    local hitboxes = {}
    for _,v in ipairs(layer.shapes) do
        v = v:save()
        local hitbox = Utils.colliderFromShape(self.world, v, v.x, v.y, v.properties)
        if hitbox then
            table.insert(hitboxes, hitbox)
            if v.name then
                self.hitboxes_by_name[v.name] = self.hitboxes_by_name[v.name] or {}
                table.insert(self.hitboxes_by_name[v.name], hitbox)
            end
        end
    end
    return hitboxes
end

---@param layer EditorLayer
function EditorMap:loadEditorLayer(layer)
    layer:setLayer(self.next_layer)
    if layer:includes(EditorObjectLayer) then
        -- TODO: Some people think 1000 isn't enough. It will be for us.
        local layer_id_component = ((Utils.getKey(self.layers, layer) - 1) * 1000)
        layer.layer = self.next_layer
        ---@cast layer EditorObjectLayer
        for i, object in pairs(layer.objects) do
            object.object_id = object.object_id or ((i - 1) + layer_id_component)
        end
    elseif layer:includes(EditorTileLayer) then
        layer:setParent(self.world)
    end
    layer:setParent(Editor.world)
end

function EditorMap:loadEditor()
    self.next_layer = self.depth_per_layer
    for i,layer in ipairs(self.layers) do
        self:loadEditorLayer(layer)
        self.next_layer = self.next_layer + self.depth_per_layer
    end
end

return EditorMap