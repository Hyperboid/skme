---@class EditorControllers : EditorObjects
local EditorControllers, super = Class("EditorObjects")

function EditorControllers:init()
    self.browser = EditorObjectBrowser("controllers")
end

return EditorControllers