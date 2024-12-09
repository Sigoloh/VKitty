--- This is a simple CTRL+C CTRL+V from harpoon

local M = {}

function M.trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end
function M.remove_duplicate_whitespace(str)
    return str:gsub("%s+", " ")
end

---@param str string
---@param sep string
---@return table
function M.split(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, s)
    end
    return t
end

function M.is_white_space(str)
    return str:gsub("%s", "") == ""
end

---@generic T
---@generic K
---@param value `T`
---@param tb {[`K`]: `T`}
function M.index_of(tb, value)
  for idx, v in pairs(tb) do
    if value == v then
      return idx
    end
  end

  return -1
end

---@param arr any[]
---@param char string
---@return string
function M.join(arr, char)
  local res = ""

  for _, str in pairs(arr) do
    res = res..str..char
  end

  return res
end

return M


