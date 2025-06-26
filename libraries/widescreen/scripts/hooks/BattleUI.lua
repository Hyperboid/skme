local BattleUI, super = Class("BattleUI", true)

function BattleUI:init()
    super.super.init(self, 0, 480)

    self.layer = BATTLE_LAYERS["ui"]

    self.current_encounter_text = Game.battle.encounter.text

    self.encounter_text = Textbox(30, 53, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, "main_mono", nil, true)
    self.encounter_text.text.line_offset = 0
    self.encounter_text:setText("")
    self.encounter_text.debug_rect = {-30, -12, SCREEN_WIDTH+1, 124}
    self:addChild(self.encounter_text)

    self.choice_box = Choicebox(56, 49, 529, 103, true)
    self.choice_box.active = false
    self.choice_box.visible = false
    self:addChild(self.choice_box)

    self.short_act_text_1 = DialogueText("", 30, 51, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false, line_offset = 0})
    self.short_act_text_2 = DialogueText("", 30, 51 + 30, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false, line_offset = 0})
    self.short_act_text_3 = DialogueText("", 30, 51 + 30 + 30, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false, line_offset = 0})
    self:addChild(self.short_act_text_1)
    self:addChild(self.short_act_text_2)
    self:addChild(self.short_act_text_3)


    self.action_boxes = {}
    self.attack_boxes = {}

    self.attacking = false

    self.ab_off = 0

    local size_offset = 0
    local box_gap = 0
    if #Game.battle.party == 3 then
        size_offset = 0
        box_gap = 0
    elseif #Game.battle.party == 2 then
        size_offset = 108
        box_gap = 1
        if Game:getConfig("oldUIPositions") then
            size_offset = 106
            box_gap = 7
        end
    elseif #Game.battle.party == 1 then
        size_offset = 213
        box_gap = 0
    end


    for index,battler in ipairs(Game.battle.party) do
        local action_box = ActionBox(size_offset+ (index - 1) * (213 + box_gap) - Game.battle.ab_off, 0, index, battler)
        self:addChild(action_box)
        table.insert(self.action_boxes, action_box)
        battler.chara:onActionBox(action_box, false)
    end

    self.parallax_x = 0
    self.parallax_y = 0

    self.animation_done = true
    self.animation_timer = 0
    self.animate_out = false

    self.shown = false

    self.heart_sprite = Assets.getTexture("player/heart")
    self.arrow_sprite = Assets.getTexture("ui/page_arrow_down")

    self.sparestar = Assets.getTexture("ui/battle/sparestar")
    self.tiredmark = Assets.getTexture("ui/battle/tiredmark")
end

function BattleUI:drawActionStrip()
    -- Draw the top line of the action strip
    Draw.setColor(PALETTE["action_strip"])
    love.graphics.rectangle("fill", 0 - SCREEN_WIDTH_DIST, Game:getConfig("oldUIPositions") and 1 or 0, 640 + SCREEN_WIDTH_DIST*2, Game:getConfig("oldUIPositions") and 3 or 2)
    -- Draw the background of the action strip
    Draw.setColor(PALETTE["action_fill"])
    love.graphics.rectangle("fill", 0 - SCREEN_WIDTH_DIST, Game:getConfig("oldUIPositions") and 4 or 2, 640 + SCREEN_WIDTH_DIST*2, Game:getConfig("oldUIPositions") and 33 or 35)
end

function BattleUI:drawActionArena()
    -- Draw the top line of the action area
    Draw.setColor(PALETTE["action_strip"])
    love.graphics.rectangle("fill", 0 - SCREEN_WIDTH_DIST, 37, 640 + SCREEN_WIDTH_DIST * 2, 3)
    -- Draw the background of the action area
    Draw.setColor(PALETTE["action_fill"])
    love.graphics.rectangle("fill", 0 - SCREEN_WIDTH_DIST, 40, 640 + SCREEN_WIDTH_DIST * 2, 115)
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