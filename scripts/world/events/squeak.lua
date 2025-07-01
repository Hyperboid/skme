---@class Event.squeak : Event
---@class Event.squeak : EditorEvent
---@field world World
local Squeak, super = Class({Event, EditorEvent})

function Squeak:init(data)
    self.meta = {
        point = true,
        sprite = "party/susie/dark/t_pose",
    }
    super.init(self, data)
    self:setSprite("party/susie/dark/t_pose")
    self:setScaleOrigin(0.5)
    self:setRotationOrigin(0.5)
    self.sprite:setScaleOrigin(0.5)
    self.sprite:setRotationOrigin(0.5)
    self.funnysound = Assets.newSound("suslaugh")
end
local function normalize(x,y, target_len)
    target_len = target_len or 1
    local len = math.sqrt((x*x) + (y*y))
    x = x / (len / target_len)
    y = y / (len / target_len)
    return x, y
end

function Squeak:draw()
    local x, y = self.world.player:getRelativePosFor(self)
    x, y = x - self.width/2, y - self.height/2
    local len = Utils.clamp(math.sqrt((x*x) + (y*y)), 0, 80)
    x, y = normalize(x, y, len)
    love.graphics.setLineWidth(2)
    love.graphics.line(self.width/2, self.height/2, x + self.width/2, y + self.height/2)
    super.draw(self)
    Draw.setColor(1,0,1)
    self:drawOverlay()
end

function Squeak:update()
    super.update(self)
    if not self.funnysound:isPlaying() then
        self:setScale(1)
        self.rotation = 0
        self.sprite:setScale(2)
        self.sprite.rotation = 0
        self.sprite.x = self.width/4
        self.sprite.y = self.height/4
    end
end

function Squeak:onInteract(player, dir)
    self:setFlag("interact_count", self:getFlag("interact_count", 0) + 1)
    local count = self:getFlag("interact_count", 0)
    local pitch = Utils.random(0.5, 2)
    -- pitch = 1.0
    self.funnysound:stop()
    self.funnysound:setPitch(pitch)
    self.funnysound:play()
    self.rotation = Utils.random(math.pi * 2)
    self:setScale(Utils.random(0, 2 + (count / 10)), Utils.random(0, 2 + (count / 10)))
    self.sprite.rotation = Utils.random(math.pi * 2)
    return false
end

return Squeak