---@class SKMEState: StateClass
local SKMEState, super = Class(StateClass)

function SKMEState:registerEvents()
    self:registerEvent("enter", self.onEnter)
    self:registerEvent("leave", self.onLeave)
    self:registerEvent("mousepressed", self.onMousePressed)
    self:registerEvent("mousereleased", self.onMouseReleased)
    self:registerEvent("wheelmoved", self.onWheelMoved)
    self:registerEvent("keypressed", self.onKeyPressed)
    self:registerEvent("update", self.update)
    self:registerEvent("draw", self.draw)
end

function SKMEState:onEnter(prev_state, ...) end
function SKMEState:onLeave(...) end
function SKMEState:update() end
function SKMEState:draw() end

---@param x integer
---@param y integer
---@param button integer
---@param istouch boolean
---@param presses integer
function SKMEState:onMousePressed(x, y, button, istouch, presses) end

---@param x integer
---@param y integer
---@param button integer
---@param istouch boolean
---@param presses integer
function SKMEState:onMouseReleased(x, y, button, istouch, presses) end

---@param x integer
---@param y integer
function SKMEState:onWheelMoved(x, y) end

---@param key love.KeyConstant
---@param is_repeat boolean
function SKMEState:onKeyPressed(key, is_repeat) end

return SKMEState