---@class EditorObjectLayer: EditorLayer
local EditorObjectLayer, super = Class("EditorLayer")

EditorObjectLayer.DEFAULT_NAME = "Object Layer"
EditorObjectLayer.TYPE = "objectgroup"

function EditorObjectLayer:init(data, map)
    super.init(self, data)
    self.world = Editor.world
    self.objects = {}
    self.data = data
    if data then
        for index, value in pairs(data.objects) do
            self.objects[index] = self:loadObject(value.type, value)
            if value.gid then
                self.objects[index]:applyEditorTileObject(value, map)
            end
            self:addChild(self.objects[index])
        end
    end
end

function EditorObjectLayer:addObject(object)
    self:addChild(object)
    table.insert(self.objects, object)
end

function EditorObjectLayer:update()
    self.update_child_list = true
    super.update(self)
end

function EditorObjectLayer:sortChildren()
    Utils.pushPerformance("EditorWorld#sortChildren")
    Object.startCache()
    local positions = {}
    for _,child in ipairs(self.children) do
        local x, y = child:getSortPosition()
        positions[child] = {x = x, y = y}
    end
    table.stable_sort(self.children, function(a, b)
        local a_pos, b_pos = positions[a], positions[b]
        local ax, ay = a_pos.x, a_pos.y
        local bx, by = b_pos.x, b_pos.y
        -- Sort children by Y position, or by follower index if it's a follower/player (so the player is always on top)
        return a.layer < b.layer or
              (a.layer == b.layer and (math.floor(ay) < math.floor(by) or
              (math.floor(ay) == math.floor(by) and (b == self.koafweplayer or
              (a:includes(Follower) and b:includes(Follower) and b.index < a.index)))))
    end)
    Object.endCache()
    Utils.popPerformance()
end

function EditorObjectLayer:loadObject(name, data)
    local eventtype = Registry.getEvent(name)
    if eventtype and (eventtype:includes(EditorEvent) or eventtype["USE_IN_EDITOR"]) then -- multi-inherit or dedicated
        local event = eventtype(data)
        event.type = event.type or name
        event.object_id = data.id
        return event
    end
    if not eventtype then
        if name == "savepoint" then eventtype = Savepoint end
        if name == "interactable" then eventtype = Interactable end
        if name == "script" then eventtype = Script end
        if name == "transition" then eventtype = Transition end
        if name == "npc" then eventtype = NPC end
        if name == "outline" then eventtype = Outline end
        if name == "silhouette" then eventtype = Silhouette end
        if name == "slidearea" then eventtype = SlideArea end
        if name == "mirror" then eventtype = MirrorArea end
        if name == "chest" then eventtype = TreasureChest end
        if name == "cameratarget" then eventtype = CameraTarget end
        if name == "hideparty" then eventtype = HideParty end
        if name == "setflag" then eventtype = SetFlagEvent end
        if name == "cybertrash" then eventtype = CyberTrashCan end
        if name == "forcefield" then eventtype = Forcefield end
        if name == "pushblock" then eventtype = PushBlock end
        if name == "tilebutton" then eventtype = TileButton end
        if name == "magicglass" then eventtype = MagicGlass end
        if name == "warpdoor" then eventtype = WarpDoor end
        if name == "darkfountain" then eventtype = DarkFountain end
        if name == "fountainfloor" then eventtype = FountainFloor end
        if name == "quicksave" then eventtype = QuicksaveEvent end
    end
    local eventtype_shadow = Registry.getEvent("editor/"..name)--[[@as EditorEvent]]
    if eventtype_shadow then -- dedicated other object
        local event = eventtype_shadow(data, name, eventtype)--[[@as EditorEvent]]
        event.type = event.type or name
        return event
    end
    return EditorEvent(name, eventtype, data)
end

function EditorObjectLayer:save()
    local data = super.save(self)
    data.objects = {}
    for index, value in pairs(self.objects) do
        data.objects[index] = value:save()
    end
    return data
end

return EditorObjectLayer