---@class EditorObjectBrowser: Object
---@overload fun(regtype:"events"|"controllers"):EditorObjectBrowser
local EditorObjectBrowser, super = Class(Object)

function EditorObjectBrowser:init(regtype)
    ---@type "events"|"controllers"
    self.regtype = regtype or "events"
    super.init(self, 200, SCREEN_HEIGHT-120, SCREEN_WIDTH-200, 120)
    self:refresh()
end
function EditorObjectBrowser:refresh()
    if self.wrapper then self.wrapper:remove() end
    self.wrapper = Component(FixedSizing(SCREEN_WIDTH-200), FixedSizing(120))
    -- self.wrapper.debug_select = false
    self.menu = MouseMenuComponent(ScrollFillSizing(), ScrollFillSizing())
    self.menu:setLayout(GridLayout())
    self.menu:setScrollbar(ScrollbarComponent())
    self.menu.overflow = "scroll"
    self.menu:setScrollType("scroll")
    self.wrapper:setPadding(0,0,8,0)

    ---@type table<string,Event>
    self.buttons = {}
    self:populateEvents()
    self.menu:setParent(self.wrapper)
    self.wrapper:setParent(self)
end

function EditorObjectBrowser:populateEvents()
    local reg = self.regtype == "events" and Registry.events or Registry.controllers
    for id, eventclass in Utils.orderedPairs(reg) do
        if not Utils.startsWith(id, "editor/") then
            local button = EditorEventButton(id, eventclass)
            self.menu:addChild(button)
            self.buttons[id] = button
        end
    end
    local function addbtn(id, ...)
        local button = EditorEventButton(id, ...)
        if reg[id] then return end
        self.menu:addChild(button)
        self.buttons[id] = button
    end
    if self.regtype == "events" then
        addbtn("savepoint", Savepoint)
        addbtn("interactable", Interactable)
        addbtn("script", Script)
        addbtn("transition", Transition)
        addbtn("npc", NPC)
        addbtn("outline", Outline)
        addbtn("silhouette", Silhouette)
        addbtn("slidearea", SlideArea)
        addbtn("mirror", MirrorArea)
        addbtn("chest", TreasureChest)
        addbtn("cameratarget", CameraTarget)
        addbtn("hideparty", HideParty)
        addbtn("setflag", SetFlagEvent)
        addbtn("cybertrash", CyberTrashCan)
        addbtn("forcefield", Forcefield)
        addbtn("pushblock", PushBlock)
        addbtn("tilebutton", TileButton)
        addbtn("magicglass", MagicGlass)
        addbtn("warpdoor", WarpDoor)
        addbtn("darkfountain", DarkFountain)
        addbtn("fountainfloor", FountainFloor)
        addbtn("quicksave", QuicksaveEvent)
    else
        addbtn("toggle", ToggleController)
        addbtn("fountainshadow", FountainShadowController)
    end
end

return EditorObjectBrowser