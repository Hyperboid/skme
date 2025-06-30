local function dumpKey(key)
    if type(key) == 'table' then
        return '('..tostring(key)..')'
    elseif type(key) == 'string' and (not key:find("[^%w_]") and not tonumber(key:sub(1,1)) and key ~= "") then
        return key
    else
        return '['..Utils.dump(key)..']'
    end
end

local function dump(o, indent)
    indent = indent or 1
    if isClass(o) then
        error("Attempt to dump class "..Utils.getClassName(o))
    end
    if type(o) == 'table' then
        local s = '{'
        if next(o) ~= nil then
            s = s .. '\n'
        end
        for k,v in Utils.orderedPairs(o) do
            s = s .. ("    "):rep(indent) .. dumpKey(k) .. ' = ' .. dump(v, indent + 1) .. ',\n'
        end
        if next(o) ~= nil then
            s = s .. ("    "):rep(indent-1)
        end
        return s .. '}'
    elseif type(o) == "number" then
        return tostring(o)
    elseif type(o) == "string" then
        return ("%q"):format(o)
    else
        return tostring(o)
    end
end

return dump