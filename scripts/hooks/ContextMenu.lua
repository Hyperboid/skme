---@class ContextMenu : ContextMenu
local ContextMenu, super = Utils.hookScript(ContextMenu)

function ContextMenu:close()
    if Editor.context == self then
        Editor.context = nil
        OVERLAY_OPEN = false
    end
    super.close(self)
end

return ContextMenu