local M = {}

---@param tbl table
---@return string
function M.json_encode(tbl)
    return require('dbg_interface.plugin_config').get().json.encode(tbl)
end

---@param str string
---@return any
function M.json_decode(str)
    return require('dbg_interface.plugin_config').get().json.decode(str)
end

---@param json string
---@return string
function M.beautify_json(json)
    if vim.fn.executable("jq") == 1 then
        return vim.fn.system("jq --sort-keys .", json)
    else
        vim.notify_once("`jq` is absent from a system. Json will not be human readable.")
    end

    return json
end

---@param list    any[]
---@param element any
---@return any[]
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

---@param list    any[]
---@param element any
---@return any[]
function M.append_to_list(list, element)
    table.insert(list, element)
    return list
end

---@param list    any[]
---@param element any
---@return integer|nil
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

---@param list        any[]
---@param old_element any
---@param new_element any
function M.replace_in_list(list, old_element, new_element)
    local idx = M.find_element_idx(list, old_element)
    if idx then
        list[idx] = new_element
    else
        vim.notify("Error: cannot replace element because can't find an old element")
    end
end

---@param callback fun(config: DebugConfig|nil)|nil
---@param payload  DebugConfig|nil
M.done = function(callback, payload)
    if callback then
        callback(payload)
    else
        vim.notify("Callback is empty", vim.log.levels.ERROR)
    end
end

return M
