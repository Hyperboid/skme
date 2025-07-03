---@class EditorCamera : Camera
local EditorCamera, super = Class(Camera)

function EditorCamera:init(parent, x, y, width, height, keep_in_bounds)
    self.keep_bounds_timer = 0
    super.init(self, parent, x, y, width, height, keep_in_bounds)
end

---@param bx number
---@param by number
---@param bw number
---@param bh number
---@return number x, number y
---@overload fun() : x:number, y:number
function EditorCamera:getMinPosition(bx, by, bw, bh)
    if not self.keep_in_bounds or self.keep_bounds_timer >= 2 then
        return -math.huge, -math.huge
    else
        if not bx then
            bx, by, bw, bh = self:getBounds()
        end
        local minx, miny = bx + (self.width / self.zoom_x) / 2, by + (self.height / self.zoom_y) / 2
        return Utils.lerp(minx, by, self.keep_bounds_timer, true), Utils.lerp(miny, by, self.keep_bounds_timer, true)
    end
end

---@param bx number
---@param by number
---@param bw number
---@param bh number
---@return number x, number y
---@overload fun() : x:number, y:number
function EditorCamera:getMaxPosition(bx, by, bw, bh)
    if not self.keep_in_bounds or self.keep_bounds_timer >= 2 then
        return math.huge, math.huge
    else
        if not bx then
            bx, by, bw, bh = self:getBounds()
        end
        local maxx, maxy = bx + bw - (self.width / self.zoom_x) / 2, by + bh - (self.height / self.zoom_y) / 2
        return Utils.lerp(maxx, bx + bw, self.keep_bounds_timer, true), Utils.lerp(maxy, by + bh, self.keep_bounds_timer, true)
    end
end


return EditorCamera