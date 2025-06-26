local HealthBar, super = Utils.hookScript("HealthBar")


function HealthBar:draw()
    -- Draw the black background
    Draw.setColor(PALETTE["world_fill"])
    love.graphics.rectangle("fill", -120, 2, SCREEN_WIDTH+(SCREEN_WIDTH/16), 61)

    super.super.draw(self)
end

return HealthBar