local M = {}

function M.json_encode(tbl)
    return require('dbg_interface.plugin_config').get().json.encode(tbl)
end

function M.json_decode(str)
    return require('dbg_interface.plugin_config').get().json.decode(str)
end

function M.beautify_json(json)
    if vim.fn.executable("jq") == 1 then
        return vim.fn.system("jq --sort-keys .", json)
    else
        vim.notify_once("`jq` is absent from a system. Json will not be human readable.")
    end

    return json
end

function M.remove_from_list(list, element)
    local idx = nil
    for i, a in ipairs(list) do
        if a == element then
            idx = i
            break
        end
    end
    table.remove(list, idx)
    return list
end

function M.append_to_list(list, element)
    table.insert(list, element)
    return list
end

function M.find_element_idx(list, element)
    local idx = nil
    for i,v in ipairs(list) do
        if v == element then
            idx = i
            break
        end
    end

    return idx
end

function M.replace_in_list(list, old_element, new_element)
    local idx = M.find_element_idx(list, old_element)
    if idx then
        list[idx] = new_element
    else
        vim.notify("Error: cannot replace element because can't find an old element")
    end
end

return M
