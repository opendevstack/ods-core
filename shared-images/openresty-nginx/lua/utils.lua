function isBearer(s)
    return s:find("Bearer ") == 1
end

function isBasic(s)
    return s:find("Basic ") == 1
end

function isEmpty(s)
    return s == nil or s == ''
end

function getUserFromBasic(str)
    local splitted = string.gmatch(str, '([^:]+)')
    return splitted()
end

function string.startsWith(String, Start)
    return string.sub(String,1,string.len(Start)) == Start
end

function string.splitBy(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1

    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(Table,cap)
        end

        last_end = e + 1
        s, e, cap = pString:find(fpat, last_end)
    end

    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end

    return Table
end
