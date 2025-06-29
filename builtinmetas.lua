---@type table<Class, table>
local m = setmetatable({}, {__mode = "k"})

local cutscene_prop = {
    id = "cutscene",
    type = "string",
    name = "Cutscene",
    delete_empty = true,
    completions = function ()
        local completions = {}
        for group, cutscene in pairs(Registry.world_cutscenes) do
            if type(cutscene) == "table" then
                for id, _ in pairs(cutscene) do
                    table.insert(completions, group .. "." .. id)
                end
            else
                table.insert(completions, group)
            end
        end
        return completions
    end,
}

local script_prop = {
    id = "script",
    type = "string",
    name = "Script",
    delete_empty = true,
    completions = function ()
        local completions = {}
        for group, script in pairs(Registry.event_scripts) do
            if type(script) == "table" then
                for id, _ in pairs(script) do
                    table.insert(completions, group .. "." .. id)
                end
            else
                table.insert(completions, group)
            end
        end
        return completions
    end,
}

m[Savepoint] = {
    origin = {0.5},
    sprite = "world/events/savepoint",
    point = true,
    properties = {
        cutscene_prop,
    }
}

m[TreasureChest] = {
    origin = {0.5},
    sprite = "world/events/treasure_chest",
    point = true,
    properties = {
        cutscene_prop,
    }
}

m[CyberTrashCan] = {
    origin = {0.5, 1},
    point = true,
    sprite = "world/events/cyber_trash",
}

m[NPC] = {
    point = true,
    origin = {0.5, 1},
    properties = {
        {id = "actor", type = "string", name = "Actor"},
        cutscene_prop,
    }
}

m[Interactable] = {
    properties = {
        cutscene_prop,
        script_prop,
    }
}

m[Script] = {
    properties = {
        cutscene_prop,
        script_prop,
    }
}

m[PushBlock] = {
    sprite = "world/events/push_block",
    point = true,
}

m[TileButton] = {
    sprite = "world/events/glowtile/idle_02",
    point = true,
    origin = {0, 0},
    properties = {
        {type = "string", id = "group", delete_empty = true},
        {type = "boolean", id = "blocks", delete_empty = true},
        script_prop,
        cutscene_prop,
    },
}

m[DarkFountain] = {
    point = true,
    origin = {0.5, 1}
}

m[Transition] = {
    properties = {
        {id = "map", type = "string", name = "Map", completions = Registry.map_data},
        {id = "marker", type = "string", delete_empty = true},
    },
}

return m