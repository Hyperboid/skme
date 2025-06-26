---@class EditorEvent.darkfountain : EditorEvent
local event, super = Class(EditorEvent, "editor/darkfountain")

function event:init(data)
    super.init(self, "darkfountain", DarkFountain, data)
    self.fountain = self:addChild(DarkFountain())
    self:setSize(self.fountain:getSize())
    self:setOrigin(self.fountain:getOrigin())
    self.fountain:setOrigin(0,0)
end

return event