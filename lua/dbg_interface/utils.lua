local M = {}

---@param json string
---@return string
function M.beautify_json(json) 
    if vim.fn.executable("jq") == 1 then
        return vim.fn.system("jq .", json)
    else
        vim.notify_once("`jq` is absent from a system. Json will not be human readable.")
    end

    return json
end

---@generic T
---@param list T[]
---@param element T
---@return T[]
function M.remove_from_list(list, element)
    local idx = nil
    for i, a in ipairs(list) do
        if a == element then
            idx = i
            break
        end
    end
    if idx then
        table.remove(list, idx)
    end
    return list
end

---@generic T
---@param list T[]
---@param element T
---@return T[]
function M.append_to_list(list, element)
    list[#list + 1] = element
    return list
end

---@generic T
---@param list T[]
---@param element T
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

---@generic T
---@param list T[]
---@param old_element T
---@param new_element T
function M.replace_in_list(list, old_element, new_element)
    local idx = M.find_element_idx(list, old_element)
    if idx then
        list[idx] = new_element
    else
        vim.notify("Error: cannot replace element because can't find an old element")
    end
end

return M
