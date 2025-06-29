---@class WorldCutscene : Cutscene
---@overload fun(...) : WorldCutscene
local WorldCutscene, super = Utils.hookScript(WorldCutscene)

local function _true() return true end

local function waitForTextbox(self) return not self.textbox or self.textbox:isDone() end
function WorldCutscene:text(text, portrait, actor, options)
    if type(actor) == "table" and not isClass(actor) then
        options = actor
        actor = nil
    end
    if type(portrait) == "table" then
        options = portrait
        portrait = nil
    end

    options = options or {}

    self:closeText()

    local width, height = 529, 103
    if Game:isLight() then
        width, height = 530, 104
    end

    self.textbox = Textbox(WidescreenLib.widescreen and 56 + WidescreenLib.SCREEN_WIDTH_DIST or 56, 344, width, height)
    self.textbox.text.hold_skip = false
    self.textbox.layer = WORLD_LAYERS["textbox"]
    Game.world:addChild(self.textbox)
    self.textbox:setParallax(0, 0)

    local speaker = self.textbox_speaker
    if not speaker and isClass(actor) and actor:includes(Character) then
        speaker = actor.sprite
    end

    if options["talk"] ~= false then
        self.textbox.text.talk_sprite = speaker
    end

    actor = actor or self.textbox_actor
    if isClass(actor) and actor:includes(Character) then
        actor = actor.actor
    end
    if actor then
        self.textbox:setActor(actor)
    end

    if options["top"] == nil and self.textbox_top == nil then
        local _, player_y = Game.world.player:localToScreenPos()
        options["top"] = player_y > 260
    end
    if options["top"] or (options["top"] == nil and self.textbox_top) then
    local bx, by = self.textbox:getBorder()
    self.textbox.y = by + 2
    end

    self.textbox.active = true
    self.textbox.visible = true
    self.textbox:setFace(portrait, options["x"], options["y"])

    if options["reactions"] then
        for id,react in pairs(options["reactions"]) do
            self.textbox:addReaction(id, react[1], react[2], react[3], react[4], react[5])
        end
    end

    if options["functions"] then
        for id,func in pairs(options["functions"]) do
            self.textbox:addFunction(id, func)
        end
    end

    if options["font"] then
        if type(options["font"]) == "table" then
            -- {font, size}
            self.textbox:setFont(options["font"][1], options["font"][2])
        else
            self.textbox:setFont(options["font"])
        end
    end

    if options["align"] then
        self.textbox:setAlign(options["align"])
    end

    self.textbox:setSkippable(options["skip"] or options["skip"] == nil)
    self.textbox:setAdvance(options["advance"] or options["advance"] == nil)
    self.textbox:setAuto(options["auto"])

    if false then -- future feature
        self.textbox:setText("[wait:2]"..text, function()
            self.textbox:remove()
            self:tryResume()
        end)
    else
        self.textbox:setText(text, function()
            self.textbox:remove()
            self:tryResume()
        end)
    end

    local wait = options["wait"] or options["wait"] == nil
    if not self.textbox.text.can_advance then
        wait = options["wait"] -- By default, don't wait if the textbox can't advance
    end

    if wait then
        return self:wait(waitForTextbox)
    else
        return waitForTextbox, self.textbox
    end
end

local function waitForChoicer(self) return self.choicebox.done, self.choicebox.selected_choice end
function WorldCutscene:choicer(choices, options)
    self:closeText()

    local width, height = 529, 103
    if Game:isLight() then
        width, height = 530, 104
    end

    self.choicebox = Choicebox(WidescreenLib.widescreen and 56 + WidescreenLib.SCREEN_WIDTH_DIST or 56, 344, width, height, false, options)
    self.choicebox.layer = WORLD_LAYERS["textbox"]
    Game.world:addChild(self.choicebox)
    self.choicebox:setParallax(0, 0)

    for _,choice in ipairs(choices) do
        self.choicebox:addChoice(choice)
    end

    options = options or {}
    if options["top"] == nil and self.textbox_top == nil then
        local _, player_y = Game.world.player:localToScreenPos()
        options["top"] = player_y > 260
    end
    if options["top"] or (options["top"] == nil and self.textbox_top) then
        local bx, by = self.choicebox:getBorder()
        self.choicebox.y = by + 2
    end

    self.choicebox.active = true
    self.choicebox.visible = true

    if options["wait"] or options["wait"] == nil then
        return self:wait(waitForChoicer)
    else
        return waitForChoicer, self.choicebox
    end
end

local function waitForTextChoicer(self) return not self.textchoicebox or self.textchoicebox:isDone(), self.textchoicebox.selected_choice end
function WorldCutscene:textChoicer(text, choices, portrait, actor, options)
    if type(actor) == "table" and not isClass(actor) then
        options = actor
        actor = nil
    end
    if type(portrait) == "table" then
        options = portrait
        portrait = nil
    end

    options = options or {}

    self:closeText()

    local width, height = 529, 103
    if Game:isLight() then
        width, height = 530, 104
    end

    self.textchoicebox = TextChoicebox(WidescreenLib.widescreen and 56 + WidescreenLib.SCREEN_WIDTH_DIST or 56, 344, width, height)
    self.textchoicebox.layer = WORLD_LAYERS["textbox"]
    Game.world:addChild(self.textchoicebox)
    self.textchoicebox:setParallax(0, 0)

    for _,choice in ipairs(choices) do
        self.textchoicebox:addChoice(choice)
    end

    local speaker = self.textbox_speaker
    if not speaker and isClass(actor) and actor:includes(Character) then
        speaker = actor.sprite
    end

    if options["talk"] ~= false then
        self.textchoicebox.text.talk_sprite = speaker
    end

    actor = actor or self.textbox_actor
    if isClass(actor) and actor:includes(Character) then
        actor = actor.actor
    end
    if actor then
        self.textchoicebox:setActor(actor)
    end

    if options["top"] == nil and self.textbox_top == nil then
        local _, player_y = Game.world.player:localToScreenPos()
        options["top"] = player_y > 260
    end
    if options["top"] or (options["top"] == nil and self.textbox_top) then
       local bx, by = self.textchoicebox:getBorder()
       self.textchoicebox.y = by + 2
    end

    self.textchoicebox.active = true
    self.textchoicebox.visible = true
    self.textchoicebox:setFace(portrait, options["x"], options["y"])

    if options["reactions"] then
        for id,react in pairs(options["reactions"]) do
            self.textchoicebox:addReaction(id, react[1], react[2], react[3], react[4], react[5])
        end
    end

    if options["functions"] then
        for id,func in pairs(options["functions"]) do
            self.textchoicebox:addFunction(id, func)
        end
    end

    if options["font"] then
        if type(options["font"]) == "table" then
            -- {font, size}
            self.textchoicebox:setFont(options["font"][1], options["font"][2])
        else
            self.textchoicebox:setFont(options["font"])
        end
    end

    if options["align"] then
        self.textchoicebox:setAlign(options["align"])
    end

    self.textchoicebox:setSkippable(options["skip"] or options["skip"] == nil)

    self.textchoicebox:setText(text, function()
        self.textchoicebox:remove()
        self:tryResume()
    end)

    if options["wait"] or options["wait"] == nil then
        return self:wait(waitForTextChoicer)
    else
        return waitForTextChoicer, self.textchoicebox
    end
end

--[[
local hook, super = Utils.hookScript(ActorSprite)
local _, value = debug.getupvalue(super.super.draw, 3, 1)
value = value.draw
local _, value = debug.getupvalue(super.super.draw, 1, 1)
print(_, value)
--]]
return WorldCutscene