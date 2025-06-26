WidescreenLib = {}

function WidescreenLib:init()
    print("Loaded Kristal Widescreen")
    INIT_SCREEN_WIDTH = SCREEN_WIDTH
    WIDE_SCREEN_WIDTH = math.floor((1920*480)/1080) - 1
    self.widescreen = true
    if self.widescreen then
        SCREEN_WIDTH = WIDE_SCREEN_WIDTH
    else SCREEN_WIDTH = INIT_SCREEN_WIDTH end
    SCREEN_WIDTH_DIST = (SCREEN_WIDTH - INIT_SCREEN_WIDTH) / 2

    if self.widescreen then
        SCREEN_CANVAS = love.graphics.newCanvas(SCREEN_WIDTH * Kristal.Config["windowScale"], SCREEN_HEIGHT * Kristal.Config["windowScale"])
        love.window.setMode(SCREEN_WIDTH*Kristal.Config["windowScale"], SCREEN_HEIGHT*Kristal.Config["windowScale"])
    end

    Utils.hook(DarkStorageMenu, "init", function(orig, self, top_storage, bottom_storage)
        orig(self)
        if WidescreenLib.widescreen then self.x = SCREEN_WIDTH_DIST else self.x = 0 end
        self.description_box_bo = Rectangle(-self.x, 0, SCREEN_WIDTH_DIST, 121)
        self.description_box_bo:setColor(0, 0, 0)
        self.description_box:addChild(self.description_box_bo)

    end)

    Utils.hook(Shopbox, "init", function(orig, self)
        orig(self)
        if WidescreenLib.widescreen then self.x = self.x + SCREEN_WIDTH_DIST end
    end)

    Utils.hook(Shop, "postInit", function(orig, self)
        -- Mutate talks
    
        self:processReplacements()
    
        -- Make a sprite for the background
        if self.background and self.background ~= "" then
            self.background_sprite = Sprite(self.background, 0, 0)
            self.background_sprite:setScale(2, 2)
            self.background_sprite.layer = SHOP_LAYERS["background"]
            self:addChild(self.background_sprite)
        end
    
        -- Construct the UI
        self.large_box = UIBox()
        local left, top = self.large_box:getBorder()
        self.large_box:setOrigin(0, 1)
        self.large_box.x = left
        self.large_box.y = SCREEN_HEIGHT - top + 1
        self.large_box.width = SCREEN_WIDTH - (top * 2) + 1
        self.large_box.height = 213 - 37 + 1
        self.large_box:setLayer(SHOP_LAYERS["large_box"])
    
        self.large_box.visible = false
    
        self:addChild(self.large_box)
    
        self.left_box = UIBox()
        local left, top = self.left_box:getBorder()
        self.left_box:setOrigin(0, 1)
        self.left_box.x = left
        self.left_box.y = SCREEN_HEIGHT - top + 1
        self.left_box.width = 338 + 14 + SCREEN_WIDTH_DIST*2
        self.left_box.height = 213 - 37 + 1
        self.left_box:setLayer(SHOP_LAYERS["left_box"])
    
        self:addChild(self.left_box)
    
        self.right_box = UIBox()
        local left, top = self.right_box:getBorder()
        self.right_box:setOrigin(1, 1)
        self.right_box.x = SCREEN_WIDTH - left + 1
        self.right_box.y = SCREEN_HEIGHT - top + 1
        self.right_box.width = 20 + 156 + 1
        self.right_box.height = 213 - 37 + 1
        self.right_box:setLayer(SHOP_LAYERS["right_box"])
    
        self:addChild(self.right_box)
    
        self.info_box = UIBox()
        local left, top = self.info_box:getBorder()
        local right_left, right_top = self.right_box:getBorder()
        self.info_box:setOrigin(1, 1)
        self.info_box.x = SCREEN_WIDTH - left + 1
        -- find a more elegant way to do this...
        self.info_box.y = SCREEN_HEIGHT - top - self.right_box.height - (right_top * 2) + 16 + 1
        self.info_box.width = 20 + 156 + 1
        self.info_box.height = 213 - 37
        self.info_box:setLayer(SHOP_LAYERS["info_box"])
    
        self.info_box.visible = false
    
        self:addChild(self.info_box)
    
        local emoteCommand = function(text, node)
            self:onEmote(node.arguments[1])
        end
    
        self.dialogue_text = DialogueText(nil, 30, 270, 372, 194)
    
        self.dialogue_text:registerCommand("emote", emoteCommand)
    
        self.dialogue_text:setLayer(SHOP_LAYERS["dialogue"])
        self:addChild(self.dialogue_text)
        self:setDialogueText(self.encounter_text)
    
        self.right_text = DialogueText("", 30 + 420 + SCREEN_WIDTH_DIST * 2, 260, 176, 206)
    
        self.right_text:registerCommand("emote", emoteCommand)
    
        self.right_text:setLayer(SHOP_LAYERS["dialogue"])
        self:addChild(self.right_text)
        self:setRightText("")
    
        self.talk_dialogue = {self.dialogue_text, self.right_text}
    end)

    Utils.hook(SimpleSaveMenu, "init", function(orig, self, save_id, marker)
        orig(self, save_id, marker)
        if WidescreenLib.widescreen then self.x = self.x + SCREEN_WIDTH_DIST end
    end)

    if Mod.libs["magical-glass"] then self:hookMagicalGlass() end

    Utils.hook(TensionBar, "processSlideIn", function(orig, self)
        if self.animating_in then
            self.animation_timer = self.animation_timer + DTMULT
            if self.animation_timer > 12 then
                self.animation_timer = 12
                self.animating_in = false
            end
    
            self.x = Ease.outCubic(self.animation_timer, self.init_x, WidescreenLib.widescreen and 25 + 38 + Utils.round(SCREEN_WIDTH_DIST/3) or 25 + 38, 12)
        end
    end)

end

function WidescreenLib:hookMoreParty()
    -- nevermind, can't overwrite a lib's hook so i guess i can't do this one
end

function WidescreenLib:hookMagicalGlass()

    Utils.hook(LightBattleUI, "init", function(orig, self)
        orig(self)
        if WidescreenLib.widescreen then self.x = SCREEN_WIDTH_DIST end
    end)

    Utils.hook(LightBattleUI, "drawState", function(orig, self)

        local state = Game.battle.state
        if state == "MENUSELECT" then
    
            local page = math.ceil(Game.battle.current_menu_x / Game.battle.current_menu_columns) - 1
            local max_page = math.ceil(#Game.battle.menu_items / (Game.battle.current_menu_columns * Game.battle.current_menu_rows)) - 1
    
            local x = 0
            local y = 0
    
            local menu_offsets = { -- {soul, text}
                ["ACT"] = {12, 16},
                ["ITEM"] = {0, 0},
                ["SPELL"] = {12, 16},
                ["MERCY"] = {0, 0}, --doesn't matter lmao
            }
    
            local extra_offset
            for name, offset in pairs(menu_offsets) do
                if name == Game.battle.state_reason then
                    extra_offset = offset
                end
            end
    
            --Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * 248), 255 + ((Game.battle.current_menu_y) * 31.5))
            Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * (248 + extra_offset[1])) + SCREEN_WIDTH_DIST, 255 + ((Game.battle.current_menu_y) * 31.5))
    
            local font = Assets.getFont("main_mono")
            love.graphics.setFont(font, 32)
    
            local col = Game.battle.current_menu_columns
            local row = Game.battle.current_menu_rows
            local draw_amount = col * row
    
            local page_offset = page * draw_amount
    
            for i = page_offset + 1, math.min(page_offset + (draw_amount), #Game.battle.menu_items) do
                local item = Game.battle.menu_items[i]
    
                Draw.setColor(1, 1, 1, 1)
                local text_offset = 0
                -- Are we able to select this?
                local able = Game.battle:canSelectMenuItem(item)
                if item.party then
                    if not able then
                        -- We're not able to select this, so make the heads gray.
                        Draw.setColor(COLORS.gray)
                    end
    
                    for index, party_id in ipairs(item.party) do
                        local chara = Game:getPartyMember(party_id)
    
                        -- Draw head only if it isn't the currently selected character
                        -- above statement might conflict with deltatraveler -sam
                        if Game.battle:getPartyIndex(party_id) ~= Game.battle.current_selecting then
                            local ox, oy = chara:getHeadIconOffset()
                            Draw.draw(Assets.getTexture(chara:getHeadIcons() .. "/head"), text_offset + 90 + (x * (230 + extra_offset[2])) + ox, 5 + (y * 32) + oy)
                            text_offset = text_offset + 37
                        end
                    end
                end
    
                if item.icons then
                    if not able then
                        -- We're not able to select this, so make the heads gray.
                        Draw.setColor(COLORS.gray)
                    end
    
                    for _, icon in ipairs(item.icons) do
                        if type(icon) == "string" then
                            icon = {icon, false, 0, 0, nil}
                        end
                        if not icon[2] then
                            local texture = Assets.getTexture(icon[1])
                            Draw.draw(texture, text_offset + 100 + (x * (240 + extra_offset[2])) + (icon[3] or 0), 50 + (y * 32) + (icon[4] or 0))
                            text_offset = text_offset + (icon[5] or texture:getWidth())
                        end
                    end
                end
    
                if able then
                    Draw.setColor(item.color or {1, 1, 1, 1})
                else
                    Draw.setColor(COLORS.gray)
                end
    
                local highlight_spare
                for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
                    if enemy.mercy >= 100 then
                        highlight_spare = true
                    end
                end
    
                if highlight_spare and item.name == "Spare" then
                    love.graphics.setColor(Game:getFlag("#name_color"))
                end
    
                local name = item.name
                if item.seriousname and Game:getFlag("#serious_mode") then
                    name = item.seriousname
                elseif item.shortname then
                    name = item.shortname
                end
    
                if #item.party > 0 then
                    love.graphics.print(name, text_offset + 89 + (x * (240 + extra_offset[2])), (y * 32))
                else
                    love.graphics.print("* " .. name, text_offset + 100 + (x * (240 + extra_offset[2])), (y * 32))
                end
    
                text_offset = text_offset + font:getWidth(item.name)
    
                if item.icons then
                    if able then
                        Draw.setColor(1, 1, 1)
                    end
    
                    for _, icon in ipairs(item.icons) do
                        if type(icon) == "string" then
                            icon = {icon, false, 0, 0, nil}
                        end
                        if icon[2] then
                            local texture = Assets.getTexture(icon[1])
                            Draw.draw(texture, text_offset + 30 + (x * 230) + (icon[3] or 0), 50 + (y * 30) + (icon[4] or 0))
                            text_offset = text_offset + (icon[5] or texture:getWidth())
                        end
                    end
                end
    
                if Game.battle.current_menu_columns == 1 then
                    if x == 0 then
                        y = y + 1
                    end
                else
                    if x == 0 then
                        x = 1
                    else
                        x = 0
                        y = y + 1
                    end
                end
    
            end
    
            -- Print information about currently selected item
            local tp_offset = 0
            local current_item = Game.battle.menu_items[Game.battle:getItemIndex()] or Game.battle.menu_items[1] -- crash prevention in case of an invalid option
            if current_item.description then
                Draw.setColor(COLORS.gray)
                local str = current_item.description:gsub('\n', ' ')
                love.graphics.print(str, 100 - 16, 64)
            end
    
            if current_item.tp and current_item.tp ~= 0 then
                Draw.setColor(PALETTE["tension_desc"])
                -- in memoriam of when this wasn't a pager menu
                -- love.graphics.print(math.floor((current_item.tp / Game:getMaxTension()) * 100) .. "% "..Game:getConfig("tpName"), 260 + 208, 64)
                local space = " "
                if current_item.tp >= 100 then
                    space = ""
                end
                love.graphics.print(math.floor((current_item.tp / Game:getMaxTension()) * 100) .. "%"..space..Game:getConfig("tpName"), 260 + 112, 64)
                Game:setTensionPreview(current_item.tp)
            else
                Game:setTensionPreview(0)
            end
    
            Draw.setColor(1, 1, 1, 1)
    
            local offset = 0
            if Game.battle:isPagerMenu() then
                if Game.battle.state_reason == "SPELL" then
                    offset = 96
                end
                love.graphics.print("PAGE " .. page + 1, 388 + offset, 64)
            end
    
        elseif state == "ENEMYSELECT" or state == "XACTENEMYSELECT" then
            local enemies = Game.battle:getActiveEnemies()
            local reason = Game.battle.state_reason
    
            local page = math.ceil(Game.battle.current_menu_y / 3) - 1
            local max_page = math.ceil(#enemies / 3) - 1
            local page_offset = page * 3
    
            Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * 248) + SCREEN_WIDTH_DIST, 255 + ((Game.battle.current_menu_y) * 31.5))
            local font_main = Assets.getFont("main")
            local font_mono = Assets.getFont("main_mono")
    
            local draw_mercy = Game:getConfig("mercyBar")
            local draw_percents = Game:getConfig("enemyBarPercentages")
    
            Draw.setColor(1, 1, 1, 1)
    
            if draw_percents and self.style ~= "undertale" then
                love.graphics.setFont(font_main)
                if Game.battle.state == "ENEMYSELECT" and self.style ~= "undertale" and Game.battle.state_reason ~= "ACT" then
                    love.graphics.print("HP", 400, -10, 0, 1, 0.5)
                end
                if draw_mercy then
                    love.graphics.print("MERCY", 500, -10, 0, 1, 0.5)
                end
            end
    
            love.graphics.setFont(font_mono)
    
            for index = page_offset + 1, math.min(page_offset + 3, #enemies) do
    
                local enemy = enemies[index]
                local y_offset = (index - page_offset - 1) * 32
    
                local name_colors = enemy:getNameColors()
                if type(name_colors) ~= "table" then
                    name_colors = {name_colors}
                end
    
                local name = "* " .. enemy.name
                if #Game.battle.enemies <= 3 then
                    if index == 1 and #Game.battle.enemies > 1 then
                        if #Game.battle.enemies == 3 then
                            if enemy.id == enemies[2].id or enemy.id == enemies[3].id then
                                name = name .. " A"
                            end
                        else
                            if enemy.id == enemies[2].id then
                                name = name .. " A"
                            end
                        end
                    elseif index == 2 and #Game.battle.enemies > 1 then
                        if enemy.id == enemies[1].id then
                            name = name .. " B"
                        end
                    elseif index == 3 and #Game.battle.enemies > 2 then
                        if enemy.id == enemies[2].id then
                            name = name .. " C"
                        end
                    end
                end
                -- yes this DOESN'T account for a different enemy type in the middle
    
                if #name_colors <= 1 then
                    Draw.setColor(name_colors[1] or enemy.selectable and {1, 1, 1} or {0.5, 0.5, 0.5})
                    love.graphics.print(name, 100, 0 + y_offset)
                else
                    local canvas = Draw.pushCanvas(font_mono:getWidth("* " .. enemy.name), font_mono:getHeight())
                    Draw.setColor(1, 1, 1)
                    love.graphics.print("* " .. enemy.name) -- todo: exclude the * from the gradient
                    Draw.popCanvas()
    
                    local color_canvas = Draw.pushCanvas(#name_colors, 1)
                    for i = 1, #name_colors do
                        -- Draw a pixel for the color
                        Draw.setColor(name_colors[i])
                        love.graphics.rectangle("fill", i-1, 0, 1, 1)
                    end
                    Draw.popCanvas()
    
                    Draw.setColor(1, 1, 1)
    
                    local shader = Kristal.Shaders["DynGradient"]
                    love.graphics.setShader(shader)
                    shader:send("colors", color_canvas)
                    shader:send("colorSize", {#name_colors, 1})
                    Draw.draw(canvas, 100, 0 + y_offset)
                    love.graphics.setShader()
                end
    
                Draw.setColor(1, 1, 1)
    
                if self.style == "deltarune" then
                    local spare_icon = false
                    local tired_icon = false
    
                    if enemy.tired and enemy:canSpare() then
                        if enemy:getMercyVisibility() then
                            Draw.draw(self.sparestar, 140 + font_mono:getWidth(enemy.name) + 10, 10 + y_offset)
                            spare_icon = true
                        end
                        
                        Draw.draw(self.tiredmark, 140 + font_mono:getWidth(enemy.name) + 30, 10 + y_offset)
                        tired_icon = true
                    elseif enemy.tired then
                        Draw.draw(self.tiredmark, 140 + font_mono:getWidth(enemy.name) + 30, 10 + y_offset)
                        tired_icon = true
                    elseif enemy.mercy >= 100 and enemy:getMercyVisibility() then
                        Draw.draw(self.sparestar, 140 + font_mono:getWidth(enemy.name) + 10, 10 + y_offset)
                        spare_icon = true
                    end
    
                    for i = 1, #enemy.icons do
                        if enemy.icons[i] then
                            if (spare_icon and (i == 1)) or (tired_icon and (i == 2)) then
                                -- Skip the custom icons if we're already drawing spare/tired ones
                            else
                                Draw.setColor(1, 1, 1, 1)
                                Draw.draw(enemy.icons[i], 80 + font:getWidth(enemy.name) + (i * 20), 60 + y_off)
                            end
                        end
                    end
                end
    
                if Game.battle.state == "XACTENEMYSELECT" then
                    Draw.setColor(Game.battle.party[Game.battle.current_selecting].chara:getXActColor())
                    if Game.battle.selected_xaction.id == 0 then
                        love.graphics.print(enemy:getXAction(Game.battle.party[Game.battle.current_selecting]), 282, 0 + y_offset)
                    else
                        love.graphics.print(Game.battle.selected_xaction.name, 282, 50 + y_offset)
                    end
                end
    
                if Game.battle.state == "ENEMYSELECT" then -- in dr/dt mode, hp and mercy is shown while acting
    
                    if Game.battle.state_reason ~= "ACT" then
                        local namewidth = font_mono:getWidth(enemy.name)
    
                        Draw.setColor(128/255, 128/255, 128/255, 1)
    
                        if Game:getFlag("#gauge_styles") == "deltarune" then
                            if ((80 + namewidth + 110 + (font_mono:getWidth(enemy.comment) / 2)) < 338) then
                                love.graphics.print(enemy.comment, 80 + namewidth + 110, 0 + y_offset)
                            else
                                love.graphics.print(enemy.comment, 80 + namewidth + 110, 0 + y_offset, 0, 0.5, 1)
                            end
                        end
    
                        local hp_percent = enemy.health / enemy.max_health
    
                        local max_width = 0
                        local hp_x = self.style == "undertale" and 190 or 400
    
                        if enemy.selectable then
                            -- I swear, the kristal team using math.ceil for the gauges here despite people asking them to change it to floor
                            -- is an in-joke
    
                            if self.style == "undertale" then
                                if enemy:getHPVisibility() then
                                    hp_x = hp_x + (#enemy.name * 16)
    
                                    Draw.setColor(1,0,0,1)
                                    love.graphics.rectangle("fill", hp_x, 10 + y_offset, 101, 17)
    
                                    Draw.setColor(PALETTE["action_health"])
                                    love.graphics.rectangle("fill", hp_x, 10 + y_offset, math.floor(hp_percent * 101), 17)
                                end
                            else
                                if enemy:getHPVisibility() then
                                    Draw.setColor(PALETTE["action_health_bg"])
                                    love.graphics.rectangle("fill", hp_x, 10 + y_offset, 81, 17)
                
                                    Draw.setColor(PALETTE["action_health"])
                                    love.graphics.rectangle("fill", hp_x, 10 + y_offset, math.floor(hp_percent * 81), 17)
                                else
                                    Draw.setColor(PALETTE["action_health_bg"])
                                    love.graphics.rectangle("fill", hp_x, 10 + y_offset, 81, 17)
                                end
                            end
    
                            if draw_percents and self.style ~= "undertale" then
                                Draw.setColor(PALETTE["action_health_text"])
                                if enemy:getHPVisibility() then
                                    love.graphics.print(math.floor(hp_percent * 100) .. "%", hp_x + 4, 10 + y_offset, 0, 1, 0.5)
                                else
                                    love.graphics.print("???", hp_x + 4, 10 + y_offset, 0, 1, 0.5)
                                end
                            end
                        end
                    end
                end
    
                if draw_mercy and self.style ~= "undertale" then
                    if enemy.selectable then
                        Draw.setColor(PALETTE["battle_mercy_bg"])
                    else
                        Draw.setColor(127/255, 127/255, 127/255, 1)
                    end
                    love.graphics.rectangle("fill", 500, 10 + y_offset, 81, 16)
    
                    if enemy.disable_mercy then
                        Draw.setColor(PALETTE["battle_mercy_text"])
                        love.graphics.setLineWidth(2)
                        love.graphics.line(500, 11 + y_offset, 500 + 81, 10 + y_offset + 16 - 1)
                        love.graphics.line(500, 10 + y_offset + 16 - 1, 500 + 81, 11 + y_offset)
                    else
                        Draw.setColor(1, 1, 0, 1)
                        if enemy:getMercyVisibility() then
                            love.graphics.rectangle("fill", 500, 10 + y_offset, ((enemy.mercy / 100) * 81), 16)
                        end
    
                        if draw_percents and enemy.selectable then
                            Draw.setColor(PALETTE["battle_mercy_text"])
                            if enemy:getMercyVisibility() then
                                love.graphics.print(math.floor(enemy.mercy) .. "%", 504, 10 + y_offset, 0, 1, 0.5)
                            else
                                love.graphics.print("???", 504, 10 + y_offset, 0, 1, 0.5)
                            end
                        end
                    end
                end
            end
        elseif state == "PARTYSELECT" then
            local page = math.ceil(Game.battle.current_menu_y / 3) - 1
            local max_page = math.ceil(#Game.battle.party / 3) - 1
            local page_offset = page * 3
    
            Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * 248) + SCREEN_WIDTH_DIST, 255 + ((Game.battle.current_menu_y) * 31.5))
    
            local font = Assets.getFont("main_mono")
            love.graphics.setFont(font)
    
            for index = page_offset + 1, math.min(page_offset + 3, #Game.battle.party) do
                Draw.setColor(1, 1, 1, 1)
                love.graphics.print("* " .. Game.battle.party[index].chara:getName(), 100, 0 + ((index - page_offset - 1) * 32))
    
                if self.style == "undertale" then
                    Draw.setColor(PALETTE["action_health_bg"])
                    love.graphics.rectangle("fill", 318, 10 + ((index - page_offset - 1) * 32), 101, 17)
    
                    local percentage = Game.battle.party[index].chara:getHealth() / Game.battle.party[index].chara:getStat("health")
                    Draw.setColor(PALETTE["action_health"])
                    love.graphics.rectangle("fill", 318, 10 + ((index - page_offset - 1) * 32), math.ceil(percentage * 101), 17)
                else
                    Draw.setColor(PALETTE["action_health_bg"])
                    love.graphics.rectangle("fill", 400, 10 + ((index - page_offset - 1) * 32), 101, 17)
    
                    local percentage = Game.battle.party[index].chara:getHealth() / Game.battle.party[index].chara:getStat("health")
                    Draw.setColor(PALETTE["action_health"])
                    love.graphics.rectangle("fill", 400, 10 + ((index - page_offset - 1) * 32), math.ceil(percentage * 101), 17)
                end
            end
        elseif state == "FLEEING" or state == "TRANSITIONOUT" then
            local font = Assets.getFont("main_mono")
            love.graphics.setFont(font, 32)
            local message = Game.battle.encounter:getUsedFleeMessage() or ""
    
            Draw.setColor(1, 1, 1, 1)
            love.graphics.print(message, 100, 0)
        end
    end)

    Utils.hook(LightEncounter, "addEnemy", function(orig, self, enemy, x, y, ...)
        local enemy_obj
        if type(enemy) == "string" then
            enemy_obj = MagicalGlassLib:createLightEnemy(enemy, ...)
        else
            enemy_obj = enemy
        end
    
        local enemies = self.queued_enemy_spawns
        if Game.battle and Game.state == "BATTLE" then
            enemies = Game.battle.enemies
        end
    
        if x and y then
            enemy_obj:setPosition(x, y)
        else
            for _,enemy in ipairs(enemies) do
                enemy.x = enemy.x - 80
            end
            local x, y = (SCREEN_WIDTH/2 + (80 * #enemies)) - 15, 240
            enemy_obj:setPosition(x, y)
        end
    
        enemy_obj.encounter = self
        table.insert(enemies, enemy_obj)
        if Game.battle and Game.state == "BATTLE" then
            Game.battle:addChild(enemy_obj)
        end
        return enemy_obj
    end)

    Utils.hook(LightEncounter, "drawBackground", function(orig, self)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Assets.getTexture(self.background_image) or WidescreenLib.widescreen and Assets.getTexture("ui/lightbattle/backgrounds/battle_wide") or Assets.getTexture("ui/lightbattle/backgrounds/battle"), 15, 9)
    end)

    Utils.hook(LightEncounter, "onSoulTransition", function(orig, self)
        Game.battle.fake_player = Game.battle:addChild(FakeClone(Game.world.player, Game.world.player:getScreenPos()))
        Game.battle.fake_player.layer = Game.battle.fader.layer + 1
    
        Game.battle.timer:script(function(wait)
            -- Black bg
            wait(1/30)
            -- Show heart
            Assets.playSound("noise")
            local player = Game.battle.fake_player.ref
            local x, y = Game.world.soul:localToScreenPos()
            Game.battle:spawnSoul(x, y)
            Game.battle.soul.sprite:set("player/heart_menu")
            Game.battle.soul.sprite:setScale(2)
            Game.battle.soul.sprite:setOrigin(0.5)
            Game.battle.soul.layer = Game.battle.fader.layer + 2
            Game.battle.soul.can_move = false
            wait(2/30)
            -- Hide heart
            Game.battle.soul.visible = false
            wait(2/30)
            -- Show heart
            Game.battle.soul.visible = true
            Assets.playSound("noise")
            wait(2/30)
            -- Hide heart
            Game.battle.soul.visible = false
            wait(2/30)
            -- Show heart
            Game.battle.soul.visible = true
            Assets.playSound("noise")
            wait(2/30)
            -- Do transition
            Game.battle.fake_player:remove()
            Assets.playSound("battlefall")
    
            if self.story then
                local center_x, center_y = Game.battle.arena:getCenter()
                local soul_offset_x = self:storyWave().soul_offset_x
                local soul_offset_y = self:storyWave().soul_offset_y
                local soul_x = self:storyWave().soul_start_x or (soul_offset_x and center_x + soul_offset_x)
                local soul_y = self:storyWave().soul_start_y or (soul_offset_y and center_y + soul_offset_y)
                Game.battle.soul:slideTo(soul_x or center_x, soul_y or center_y, 17/30)
            else
                Game.battle.soul:slideTo(WidescreenLib.widescreen and 49 + SCREEN_WIDTH_DIST or 49, 455, 17/30)
            end
    
            wait(17/30)
            -- Wait
            wait(5/30)
            Game.battle.soul.sprite:set("player/heart_light")
            Game.battle.soul.sprite:setScale(1)
            Game.battle.soul.x = Game.battle.soul.x - 1
            Game.battle.soul.y = Game.battle.soul.y - 1
    
            Game.battle.fader:fadeIn(nil, {speed=5/30})
            Game.battle.transitioned = true
            self:onBattleStart()
    
            if self.nobody_came then
                Game.battle:setState("BUTNOBODYCAME")
            elseif self.story then
                Game.battle:setState("ENEMYDIALOGUE")
                Game.battle.soul.can_move = true
            else
                Game.battle:setState("ACTIONSELECT")
            end
        end)
    end)

    Utils.hook(LightEncounter, "init", function(orig, self)
        -- Text that will be displayed when the battle starts
        self.text = "* A skirmish breaks out!"
    
        -- Is a "But Nobody Came"/"Genocide" Encounter
        self.nobody_came = false
    
        -- Is a "story" encounter (can't attack, only hp and lv are shown. a wave is started as soon as the battle starts)
        self.story = false
    
        -- Speeds up the soul transition
        self.fast_transition = false
    
        -- Whether the default grid background is drawn
        self.background = true
        self.background_image = WidescreenLib.widescreen and "ui/lightbattle/backgrounds/battle_wide" or "ui/lightbattle/backgrounds/battle"
    
        -- The music used for this encounter
        self.music = "battleut"
    
        -- Whether characters have the X-Action option in their spell menu
        self.default_xactions = Game:getConfig("partyActions")
    
        -- Should the battle skip the YOU WON! text?
        self.no_end_message = false
    
        -- Table used to spawn enemies when the battle exists, if this encounter is created before
        self.queued_enemy_spawns = {}
    
        -- A copy of battle.defeated_enemies, used to determine how an enemy has been defeated.
        self.defeated_enemies = nil
    
        self.can_flee = true
    
        self.flee_chance = 0
        self.flee_messages = {
            "* I'm outta here.", -- 1/20
            "* I've got better to do.", --1/20
            "* Escaped...", --17/20
            "* Don't slow me down." --1/20
        }
    
        self.used_flee_message = nil
    end)
end

function WidescreenLib:inInitRatio(x, y)
    if x > SCREEN_WIDTH_DIST and x < SCREEN_WIDTH - SCREEN_WIDTH_DIST then return true else return false end
end

function WidescreenLib:toWideScreen()
    SCREEN_WIDTH = WIDE_SCREEN_WIDTH
    SCREEN_WIDTH_DIST = (SCREEN_WIDTH - INIT_SCREEN_WIDTH) / 2
    SCREEN_CANVAS = love.graphics.newCanvas(SCREEN_WIDTH * Kristal.Config["windowScale"], SCREEN_HEIGHT * Kristal.Config["windowScale"])
    love.window.setMode(WidescreenLib.widescreen and SCREEN_WIDTH * Kristal.Config["windowScale"] or INIT_SCREEN_WIDTH * Kristal.Config["windowScale"], SCREEN_HEIGHT * Kristal.Config["windowScale"])

    if (Game.world) then
        for _,tilelayer in ipairs(Game.world.stage:getObjects(TileLayer)) do
            tilelayer.drawn = false
        end
    end
end

function WidescreenLib:toInitScreen()
    SCREEN_WIDTH = INIT_SCREEN_WIDTH
    SCREEN_WIDTH_DIST = (SCREEN_WIDTH - INIT_SCREEN_WIDTH) / 2
    SCREEN_CANVAS = love.graphics.newCanvas(SCREEN_WIDTH * Kristal.Config["windowScale"], SCREEN_HEIGHT * Kristal.Config["windowScale"])
    love.window.setMode(WidescreenLib.widescreen and SCREEN_WIDTH * Kristal.Config["windowScale"] or INIT_SCREEN_WIDTH * Kristal.Config["windowScale"], SCREEN_HEIGHT * Kristal.Config["windowScale"])

    if (Game.world) then
        for _,tilelayer in ipairs(Game.world.stage:getObjects(TileLayer)) do
            tilelayer.drawn = false
        end
    end
end
    
function WidescreenLib:unload()
    SCREEN_WIDTH = INIT_SCREEN_WIDTH
    INIT_SCREEN_WIDTH = nil
    SCREEN_WIDTH_DIST = nil
    SCREEN_CANVAS = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.window.setMode(SCREEN_WIDTH*Kristal.Config["windowScale"], SCREEN_HEIGHT*Kristal.Config["windowScale"])
end

return WidescreenLib