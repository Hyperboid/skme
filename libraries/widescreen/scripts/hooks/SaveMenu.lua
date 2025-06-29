local SaveMenu, super = Class("SaveMenu")

function SaveMenu:init(marker)
    super.super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    if WidescreenLib.widescreen then self.x = WidescreenLib.SCREEN_WIDTH_DIST else self.x = 0 end

    self.parallax_x = 0
    self.parallax_y = 0

    self.draw_children_below = 0

    self.font = Assets.getFont("main")

    self.ui_select = Assets.newSound("ui_select")

    self.heart_sprite = Assets.getTexture("player/heart")
    self.divider_sprite = Assets.getTexture("ui/box/dark/top")

    self.main_box = UIBox(124, 130, 391, 154)
    self.main_box.layer = -1
    self:addChild(self.main_box)

    self.save_box = Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    self.save_box:setColor(0, 0, 0, 0.8)
    self.save_box.layer = -1
    self.save_box.visible = false
    self:addChild(self.save_box)

    self.save_header = UIBox(92, 44, 457, 42)
    self.save_blackout = Rectangle(-self.x, 0, WidescreenLib.SCREEN_WIDTH_DIST, SCREEN_HEIGHT)
    self.save_blackout:setColor(0, 0, 0, 0.8)
    self.save_box:addChild(self.save_header)
    if WidescreenLib.widescreen then self.save_box:addChild(self.save_blackout) end

    self.save_list = UIBox(92, 156, 457, 258)
    self.save_box:addChild(self.save_list)

    self.overwrite_box = Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    self.overwrite_box:setColor(0, 0, 0, 0.8)
    self.overwrite_box.layer = 1
    self.overwrite_box.visible = false
    self:addChild(self.overwrite_box)

    self.overwrite_box:addChild(UIBox(42, 132, 557, 217))

    self.marker = marker

    -- MAIN, SAVE, SAVED, OVERWRITE
    self.state = "MAIN"

    self.selected_x = 1
    self.selected_y = 1

    self.saved_file = nil

    self.saves = {}
    for i = 1, 3 do
        self.saves[i] = Kristal.getSaveFile(i)
    end
end

return SaveMenu