-- http://lua-users.org/wiki/SaveTableToFile
local M = {}

-- Export string: returns a "Lua" portable version of the string
local function export_string(s)
    return string.format("%q", s)
end

-- Save table to file
function M.save(tbl, filename)
    local charS, charE = "   ", "\n"
    local file, err = io.open(filename, "wb")
    if not file then return nil, err end

    local tables, lookup = { tbl }, { [tbl] = 1 }
    file:write("return {" .. charE)

    for idx, t in ipairs(tables) do
        file:write("-- Table: {" .. idx .. "}" .. charE)
        file:write("{" .. charE)
        local handled = {}

        for i, v in ipairs(t) do
            handled[i] = true
            local vType = type(v)
            if vType == "table" then
                if not lookup[v] then
                    table.insert(tables, v)
                    lookup[v] = #tables
                end
                file:write(charS .. "{" .. lookup[v] .. "}," .. charE)
            elseif vType == "string" then
                file:write(charS .. export_string(v) .. "," .. charE)
            elseif vType == "number" then
                file:write(charS .. tostring(v) .. "," .. charE)
            end
        end

        for i, v in pairs(t) do
            if not handled[i] then
                local str = ""
                local iType = type(i)
                if iType == "table" then
                    if not lookup[i] then
                        table.insert(tables, i)
                        lookup[i] = #tables
                    end
                    str = charS .. "[{" .. lookup[i] .. "}]="
                elseif iType == "string" then
                    str = charS .. "[" .. export_string(i) .. "]="
                elseif iType == "number" then
                    str = charS .. "[" .. tostring(i) .. "]="
                end

                if str ~= "" then
                    local vType = type(v)
                    if vType == "table" then
                        if not lookup[v] then
                            table.insert(tables, v)
                            lookup[v] = #tables
                        end
                        file:write(str .. "{" .. lookup[v] .. "}," .. charE)
                    elseif vType == "string" then
                        file:write(str .. export_string(v) .. "," .. charE)
                    elseif vType == "number" then
                        file:write(str .. tostring(v) .. "," .. charE)
                    end
                end
            end
        end
        file:write("}," .. charE)
    end
    file:write("}")
    file:close()
    return true
end

-- Load table from file
function M.load(filename)
    local ftables, err = loadfile(filename)
    if not ftables then return nil, err end

    local tables = ftables()
    for idx = 1, #tables do
        local to_link = {}
        for i, v in pairs(tables[idx]) do
            if type(v) == "table" then
                tables[idx][i] = tables[v[1]]
            end
            if type(i) == "table" and tables[i[1]] then
                table.insert(to_link, { i, tables[i[1]] })
            end
        end
        for _, v in ipairs(to_link) do
            tables[idx][v[2]], tables[idx][v[1]] = tables[idx][v[1]], nil
        end
    end
    return tables[1]
end

return M
