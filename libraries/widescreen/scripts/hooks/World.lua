local World, super = Class("World")

function World:showHealthBars()
    if Game.light then return end

    if self.healthbar then
        self.healthbar. x = SCREEN_WIDTH_DIST
        self.healthbar:transitionIn()
        
    else
        self.healthbar = HealthBar()
        self.healthbar.layer = WORLD_LAYERS["ui"]
        self:addChild(self.healthbar)
        self.healthbar.x = SCREEN_WIDTH_DIST
    end
end

function World:update()
    if self.healthbar then if WidescreenLib.widescreen then self.healthbar.x = SCREEN_WIDTH_DIST else self.healthbar.x = 0 end end
    super.update(self)
end

return World