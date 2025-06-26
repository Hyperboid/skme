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
        {id = "actor", type = "string", name = "Actor"},
        cutscene_prop,
    }
}

m[PushBlock] = {
    sprite = "world/events/push_block"
}

m[DarkFountain] = {
    point = true,
    progin = {0.5, 1}
}

return m