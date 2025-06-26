local lib = {}
Registry.registerGlobal("SKME", lib)
SKME = lib

function lib:init()
    for class, meta in pairs(libRequire("skme", "builtinmetas")) do
        Utils.hook(class, "EDITOR_METADATA", meta, true)
    end
end

function lib:onKeyPressed(key)
    if Input.ctrl() and key == "e" then
        self:openEditor()
    end
end

function lib:openEditor()
    if Gamestate.current() == Game then
        if Game.state == "OVERWORLD" and Game.world.state == "GAMEPLAY" and Game.world.map.data.format == "skme" then
            return Gamestate.push(Editor)
        end
        return false, "Must be in the overworld, during normal gameplay, on an SKME map."
    end
end

function lib:unload()
    if Gamestate.current() == Editor then
        Gamestate.pop()
    -- Try to pop the state anyway.
    elseif pcall(Gamestate.pop) then
        -- If succeded, we're probably now in Game. Not good!
        Gamestate.switch({})
    end
end

function lib:onMousePressed(x, y, button, istouch, presses)
    local state = Gamestate.current()
    if state.onMousePressed then
        state:onMousePressed(x, y, button, istouch, presses)
    end
end

function lib:onMouseReleased(x, y, button, istouch, presses)
    local state = Gamestate.current()
    if state.onMouseReleased then
        state:onMouseReleased(x, y, button, istouch, presses)
    end
end

return lib