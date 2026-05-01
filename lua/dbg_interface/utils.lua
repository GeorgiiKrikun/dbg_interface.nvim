local M = {}

function M.beautify_json(json) 
    if vim.fn.executable("jq") == 1 then
        return vim.fn.system("jq .", json)
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
    list[#list + 1] = element
    return list
end

return M
