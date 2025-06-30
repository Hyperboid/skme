---@class EditorNPC: EditorEvent
local EditorNPC, super = Class(EditorEvent)

function EditorNPC:init(data)
    super.init(self, "npc", NPC, data)
    self.data.properties = self.data.properties or {}
    self.data.properties.actor = self.data.properties.actor or "kris"
    self:setScale(2)
    self:setActor(self.data.properties.actor)
end

function EditorNPC:registerProperties(inspector)
    super.registerProperties(self, inspector)
end

function EditorNPC:setActor(actor)
    if type(actor) == "string" then
        actor = Registry.createActor(actor)
    end

    self.actor = actor

    self.width = actor:getWidth()
    self.height = actor:getHeight()

    if self.sprite then
        self.sprite:remove()
    end

    self.sprite = self.actor:createSprite()
    self.sprite.inherit_color = true
    self:addChild(self.sprite)
end

function EditorNPC:onSave(data)
    super.onSave(self, data)
    data.properties.actor = self.actor.id
end

return EditorNPC