local Path = require("plenary.path")
local utils= require("VKitty.vk.utils")

local data_path = string.format("%s/vkitty", vim.fn.stdpath("data"))

local ensured_data_path = false

local filename = vim.loop.cwd()

---@param path string
---@return string
local function hash(path)
  return vim.fn.sha256(path)
end

local function fullpath()

  if not filename then
    error("VKitty: could not get your cwd")
  end

  local hashed = hash(filename)
  return string.format("%s/%s.json", data_path, hashed)
end

local function ensure_data_path()
  if ensured_data_path then
    return
  end
  local path = Path:new(data_path)

  if not path:exists() then
    path:mkdir()
  end

  ensured_data_path = true
end

local function write_data(data)
  Path:new(fullpath()):write(vim.json.encode(data), 'w')
end

local M = {}

function M.__dangereously_clear_data()
  write_data({})
end

---@alias VkittyRawData {[number]: {[string]: string[]}}

---@class VKittyData
---@field _data VkittyRawData
---@field has_error boolean
local VKittyData = {}
VKittyData.__index = VKittyData

---@param provided_path string?
---@return VkittyRawData
local function read_data(provided_path)
  ensure_data_path()

  provided_path = fullpath()

  local path = Path:new(provided_path)

  local exists = path:exists()

  if not exists then
    write_data({})
  end

  local out_data = path:read()

  if not out_data or out_data == "" then
    write_data({})
    out_data = "{}"
  end

  local data = vim.json.decode(out_data)

  return data
end


---@return VKittyData
function VKittyData:new()
  local ok, data = pcall(read_data)

  return setmetatable({
      _data = data,
      has_error = not ok,
  }, self)
end


---@param idx number
---@return {[string]: string[]}
function VKittyData:_get_data(idx)
  if not self._data[idx] then
    self._data[idx] = {}
  end

  return self._data[idx] or {}
end

---@return VkittyRawData
function VKittyData:get_all()
  return self._data
end

---@param alias_name string
function VKittyData:delete_alias_by_name(alias_name)
  local alias_idx = self:get_index_by_alias_name(alias_name)

  if alias_idx == -1 then
    return
  end

  table.remove(self._data, alias_idx)
end

---@param aliases {[string]: string[]}
function VKittyData:bulk_update(aliases)
  self._data = {}
  M.__dangereously_clear_data()

  for alias_name, alias_comm in pairs(aliases) do
    self:update(alias_name, alias_comm)
  end
end

---@param alias_name string
---@return number
function VKittyData:get_index_by_alias_name(alias_name)
  for idx, alias_def in pairs(self._data) do
    for name, _ in pairs(alias_def) do
      if name == alias_name then
        return idx
      end
    end
  end

  local last_index = self:_get_last_idx()

  self._data[last_index] = {}

  return last_index
end

---@param alias string
---@return string[]
function VKittyData:data(alias)
  if self.has_error then
    error(
      "VKitty: there was an error reading the data file, cannot read data"
    )
  end

  local alias_idx = self:get_index_by_alias_name(alias)

  if alias_idx == -1 then
    error("VKitty: Could not find alias"..alias)
  end

  return self:_get_data(alias_idx)
end

function VKittyData:_get_last_idx()
  local last = 0
  for idx,_ in pairs(self._data) do
    if idx > last then
      last = idx
    end
  end

  return last + 1
end

---@param alias_name string
---@param command string[]
function VKittyData:update(alias_name, command)
    if self.has_error then
        error(
            "VKitty: there was an error reading the data file, cannot update"
        )
    end

    local alias_idx = self:get_index_by_alias_name(alias_name)

    self:_get_data(alias_idx)
    self._data[alias_idx][alias_name] = command
end

function VKittyData:sync()
    if self.has_error then
        return
    end

    local ok, data = pcall(read_data)
    if not ok then
        error("VKitty: unable to sync data, error reading data file")
    end

    for alias_idx, alias_def in pairs(self._data) do
        data[alias_idx] = alias_def
    end

    pcall(write_data, data)
end

M.VKittyData = VKittyData

return M

