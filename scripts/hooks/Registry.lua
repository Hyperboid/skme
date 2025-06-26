local self = Registry
---@class Registry : Registry
local Registry, super = Utils.hookScript(Registry)

function Registry.createMap(id, world, ...)
    if self.maps[id] then
        local map = self.maps[id](world, self.map_data[id], ...)
        map.id = id
        return map
    elseif self.map_data[id] then
        local data = self.map_data[id]
        local map
        if data.tiledversion then
            map = Map(world, data, ...)
        elseif data.format == "skme" then
            map = EditorMap(world, data, ...)
        end
        map.id = id
        return map
    else
        error("Attempt to create non existent map \"" .. tostring(id) .. "\"")
    end
end

return Registry
