---@class MouseMenuComponent: AbstractMenuComponent
---@overload fun(...):MouseMenuComponent
local MouseMenuComponent, super = Class(AbstractMenuComponent)

function MouseMenuComponent:init(x_sizing, y_sizing, options)
    super.init(self, x_sizing, y_sizing, options)
end

function MouseMenuComponent:update()
    super.super.update(self)
    if OVERLAY_OPEN or Kristal.DebugSystem.state == "SELECTION" then return end
    local mouse = PointCollider(nil, Input.getMousePosition())
    local cur_hovered
    for _, component in ipairs(self:getComponents()) do
        if component:includes(AbstractMenuItemComponent) then
            ---@cast component AbstractMenuItemComponent
            ---@cast component TextMenuItemComponent
            local collided
            if component.collider then
                collided = component:collidesWith(mouse)
            else
                local mx, my = component:getFullTransform():inverseTransformPoint(mouse.x, mouse.y)
                local rect = component:getDebugRectangle() or { 0, 0, component.width, component.height }
                collided = (mx >= rect[1] and mx < rect[1] + rect[3] and my >= rect[2] and my < rect[2] + rect[4])
            end
            if collided then
                cur_hovered = component
            end
        end
    end
    if cur_hovered ~= self.last_hovered then
        if self.last_hovered then
            self.last_hovered:onHovered(false, false)
        end
        if cur_hovered then
            cur_hovered:onHovered(true, false)
        end
    end
    if cur_hovered and Input.mousePressed(1) and not TextInput.active then
        cur_hovered:onSelected()
    end
    self.last_hovered = cur_hovered
end

function MouseMenuComponent:onWheelMoved(x, y)
    local max_height = self:getInnerHeight() - self:getTotalHeight()
    -- For some reason, this is needed for the inspector.
    if self.buggy_scrolling then
        max_height = self:getInnerHeight() - (self:getTotalHeight() - (self.children[#self.children]:getTotalHeight()))
    end
    self.scroll_y = Utils.clamp(self.scroll_y - (y * 30), 0, max_height)
    self.layout:refresh()
    return self.overflow == "scroll"
end

return MouseMenuComponent