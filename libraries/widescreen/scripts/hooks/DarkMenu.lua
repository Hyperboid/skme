local DarkMenu, super = Class("DarkMenu")

function DarkMenu:init()
    super.init(self)
    self.x = (SCREEN_WIDTH - (640/2))/4
end

function DarkMenu:draw()
    -- Draw the black background
    love.graphics.setColor(PALETTE["world_fill"])
    love.graphics.rectangle("fill", 0 - self.x, 0, SCREEN_WIDTH, 80)

    super.draw(self)
end

return DarkMenu