---@class EditorInspector: Object
---@overload fun(...):EditorInspector
local EditorInspector, super = Class(Object)

---@param editor Editor
function EditorInspector:init(editor)
    super.init(self,0,20,200,SCREEN_HEIGHT - 20)
    self.editor = editor
    self:resetUI()
    
end

function EditorInspector:resetUI()
    if self.container then self.container:remove() end
    self.container = Component(FixedSizing(200), FixedSizing(SCREEN_HEIGHT - 20))
    self.menu = MouseMenuComponent(FixedSizing(200 - 32), ScrollFillSizing())
    self.menu.overflow = 'scroll'
    self.menu:setLayout(VerticalLayout())
    self.menu:setMargins(16)
    self.menu:setPadding(0,0,8,0)
    self.menu:setScrollbar(ScrollbarComponent())
    ---@param obj Component
    local function wide(obj)
        obj:setSizing(FillSizing, obj.y_sizing)
        return obj
    end
    wide(self.menu:addChild(TextMenuItemComponent("Nothing\nselected...")))
    self:addChild(self.container)
    self.container:addChild(self.menu)
end

---@param object EditorEvent
function EditorInspector:onSelectObject(object)
    self:resetUI()
    if object then
        object:registerProperties(self)
    end
    local comp = self.menu:getComponents()
    if #comp > 1 then
        comp[1]:remove()
        self.container:update()
    end
end

function EditorInspector:addToMenu(component)
    self.menu:addChild(component)
end

function EditorInspector:setHeight(height)
    self.height = height
    self.container.y_sizing.height = height - (
        self.container.margins[2] + self.container.margins[4]
        + self.menu.padding[2] + self.menu.padding[4]
    )
end


return EditorInspector