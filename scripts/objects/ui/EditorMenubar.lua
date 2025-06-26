---@class EditorMenubar: Object
local EditorMenubar, super = Class(Object)

function EditorMenubar:init()
    super.init(self, 0, 0, SCREEN_WIDTH, 20)
    
end

return EditorMenubar