local BattleUI, super = Utils.hookScript(BattleUI)

function BattleUI:init()
    super.init(self)

    for index,box in ipairs(self.action_boxes) do
        box.x = box.x - Game.battle.ab_off
    end

    self.parallax_x = 0
    self.parallax_y = 0

    self.animation_done = true
    self.animation_timer = 0
    self.animate_out = false

    self.animation_y = 0
    self.animation_y_lag = 0

    self.shown = false

    self.heart_sprite = Assets.getTexture("player/heart")
    self.arrow_sprite = Assets.getTexture("ui/page_arrow_down")

    self.sparestar = Assets.getTexture("ui/battle/sparestar")
    self.tiredmark = Assets.getTexture("ui/battle/tiredmark")
    
    self:resetXACTPosition()
end

function BattleUI:drawActionStrip()
    -- Draw the top line of the action strip
    Draw.setColor(PALETTE["action_strip"])
    love.graphics.rectangle("fill", 0 - WidescreenLib.SCREEN_WIDTH_DIST, Game:getConfig("oldUIPositions") and 1 or 0, 640 + WidescreenLib.SCREEN_WIDTH_DIST*2, Game:getConfig("oldUIPositions") and 3 or 2)
    -- Draw the background of the action strip
    Draw.setColor(PALETTE["action_fill"])
    love.graphics.rectangle("fill", 0 - WidescreenLib.SCREEN_WIDTH_DIST, Game:getConfig("oldUIPositions") and 4 or 2, 640 + WidescreenLib.SCREEN_WIDTH_DIST*2, Game:getConfig("oldUIPositions") and 33 or 35)
end

function BattleUI:drawActionArena()
    -- Draw the top line of the action area
    Draw.setColor(PALETTE["action_strip"])
    love.graphics.rectangle("fill", 0 - WidescreenLib.SCREEN_WIDTH_DIST, 37, 640 + WidescreenLib.SCREEN_WIDTH_DIST * 2, 3)
    -- Draw the background of the action area
    Draw.setColor(PALETTE["action_fill"])
    love.graphics.rectangle("fill", 0 - WidescreenLib.SCREEN_WIDTH_DIST, 40, 640 + WidescreenLib.SCREEN_WIDTH_DIST * 2, 115)
    self:drawState()
end

function BattleUI:beginAttack()
    local attack_order = Utils.pickMultiple(Game.battle.normal_attackers, #Game.battle.normal_attackers)

    for _,box in ipairs(self.attack_boxes) do
        box:remove()
    end
    self.attack_boxes = {}

    local last_offset = -1
    local offset = 0
    for i = 1, #attack_order do
        offset = offset + last_offset

        local battler = attack_order[i]
        local index = Game.battle:getPartyIndex(battler.chara.id)
        local attack_box = AttackBox(battler, 30 + offset, index, 0, 40 + (38 * (index - 1)))
        attack_box.layer = -10 + (index * 0.01)
        self:addChild(attack_box)
        table.insert(self.attack_boxes, attack_box)

        if i < #attack_order and last_offset ~= 0 then
            last_offset = Utils.pick{0, 10, 15}
        else
            last_offset = Utils.pick{10, 15}
        end
    end

    self.attacking = true
end

function BattleUI:endAttack()
    Game.battle.cancel_attack = false
    for _,box in ipairs(self.attack_boxes) do
        box:endAttack()
    end
end

return BattleUI