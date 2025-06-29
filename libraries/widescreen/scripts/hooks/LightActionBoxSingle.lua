local LightActionBoxSingle, super = Class(LightActionBoxSingle)

function LightActionBoxSingle:init(x, y, index, battler)
    super.super.init(self, x, y)



    self.index = 1
    self.battler = battler

    self.selected_button = 1
    self.last_button = 1

    self.revert_to = 40

    self.data_offset = 0

    if not Game.battle.encounter.story then
        self:createButtons()
    end
end

function LightActionBoxSingle:drawStatusStrip()
    local x, y = 10 + WidescreenLib.SCREEN_WIDTH_DIST, 130
    local name = self.battler.chara:getName()
    local level = self.battler.chara:getLightLV()

    love.graphics.setFont(Assets.getFont("namelv", 24))
    love.graphics.setColor(COLORS["white"])
    love.graphics.print(name .. "   LV " .. level, x, y)

    love.graphics.draw(Assets.getTexture("ui/lightbattle/hpname"), x + 214, y + 5)

    local max = self.battler.chara:getStat("health")
    local current = self.battler.chara:getHealth()
    if current < 10 then
        current = "0" .. tostring(current) -- do i need to even do this
    end
    local size = max * 1.25

    local length = current
    if type(Game:getFlag("#limit_hp_gauge_length")) == "boolean" and Game:getFlag("#limit_hp_gauge_length") then
        if length >= 99 then
            length = 99
        end

        if size >= 99 then
            size = 99
        end
    elseif type(Game:getFlag("#limit_hp_gauge_length")) == "number" then
        if length >= Game:getFlag("#limit_hp_gauge_length") then
            length = Game:getFlag("#limit_hp_gauge_length")
        end

        if size >= Game:getFlag("#limit_hp_gauge_length") then
            size = Game:getFlag("#limit_hp_gauge_length")
        end
    end

    love.graphics.setColor(COLORS["red"])
    love.graphics.rectangle("fill", x + 245, y, size, 21)
    love.graphics.setColor(COLORS["yellow"])
    love.graphics.rectangle("fill", x + 245, y, length * 1.25, 21)

    love.graphics.setColor(COLORS["white"])
    love.graphics.print(current .. " / " .. max, x + 245 + size + 14, y)
end

function LightActionBoxSingle:getButtons(battler) end

function LightActionBoxSingle:createButtons()
    for _,button in ipairs(self.buttons or {}) do
        button:remove()
    end

    self.buttons = {}

    local btn_types = {"fight", "act", "spell", "item", "mercy"}

    if not self.battler.chara:hasAct() then Utils.removeFromTable(btn_types, "act") end
    if not self.battler.chara:hasSpells() then Utils.removeFromTable(btn_types, "spell") end

    for lib_id,_ in pairs(Mod.libs) do
        btn_types = Kristal.libCall(lib_id, "getActionButtons", self.battler, btn_types) or btn_types
    end
    btn_types = Kristal.modCall("getActionButtons", self.battler, btn_types) or btn_types

    for i,btn in ipairs(btn_types) do
        if type(btn) == "string" then
            local spacing = #btn_types
            local x
            if #btn_types == 4 then
                x = math.floor(67 + ((i - 1) * 156))
                if i == 2 then
                    x = x - 3
                elseif i == 3 then
                    x = x + 1
                end
            else
                x = math.floor(67 + ((i - 1) * 117))
            end
            
            local button = LightActionButton(btn, self.battler, x + WidescreenLib.SCREEN_WIDTH_DIST, 175)
            button.actbox = self
            table.insert(self.buttons, button)
            self:addChild(button)
        else
            btn:setPosition(math.floor(66 + ((i - 1) * 156)) + 0.5, 183)
            btn.battler = self.battler
            btn.actbox = self
            table.insert(self.buttons, btn)
            self:addChild(btn)
        end
    end

    self.selected_button = Utils.clamp(self.selected_button, 1, #self.buttons)

end

if Mod.libs["magical-glass"] then return LightActionBoxSingle else return {} end