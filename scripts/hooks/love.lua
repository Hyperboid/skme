---@class love : love
local love, super = Utils.hookScript(love)

function love.mousepressed(win_x, win_y, button, istouch, presses)
    if not (button == 3 and Gamestate.current() == Editor) then
        return super.mousepressed(win_x, win_y, button, istouch, presses)
    end
    Input.active_gamepad = nil
    local x, y = Input.getMousePosition(win_x, win_y)
    Input.onMousePressed(x, y, button, istouch, presses)
    Kristal.callEvent(KRISTAL_EVENT.onMousePressed, x, y, button, istouch, presses)
end

return love