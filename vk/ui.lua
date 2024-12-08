local Buffer = require("VKitty.vk.buffer")

---@class VKittyUI
---@field vk_window_id number? Here to keep track of what to close :)
---@field active_kitty_window_id? number Keep track of the running kitty window
---@field bufnr? number Keep track of the buffer where the window opens
---@field last_command? string[] Store the last lauched command
---@field private is_closing? boolean Just to avoid trying to close a window twice
local VKittyUI = {}
VKittyUI.__index = VKittyUI

-- Stole from harpoon :)
---@class VkToggleOptions
---@field border? any this value is directly passed to nvim_open_win
---@field title_pos? any this value is directly passed to nvim_open_win
---@field title? string this value is directly passed to nvim_open_win
---@field width? number the preseted value of width for the window
---@field ui_fallback_width? number used if we can't get the current window
---@field ui_width_ratio? number this is the ratio of the editor window to use
---@field ui_max_width? number this is the max width the window can be
---@field height_in_lines? number this is the max height in lines that the window can be

---Get fullfilled VkToggleOptions
---@param config VkToggleOptions
---@return VkToggleOptions
local function get_toggle_config(config)
  return vim.tbl_extend("force", {
    ui_fallback_width = 50,
    ui_width_ratio = 0.7
  }, config, {})
end

---@return VKittyUI
function VKittyUI:new()
  return setmetatable({
    vk_window_id = nil,
    active_kitty_window_id = nil,
    bufnr = nil,
    last_command = nil,
    is_closing = false,
  }, self)
end

function VKittyUI:close_window()
  if self.is_closing then
    return
  end

  self.is_closing = true

  if self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr) then
    vim.api.nvim_buf_delete(self.bufnr, {force = true})
  end

  if self.vk_window_id ~= nil and vim.api.nvim_win_is_valid(self.vk_window_id) then
    vim.api.nvim_win_close(self.vk_window_id, true)
  end

  self.bufnr = nil
  self.vk_window_id = nil

  self.is_closing = false
end

function VKittyUI:_create_window(toggle_opts)
  local vk_window = vim.api.nvim_list_uis()

  local width = toggle_opts.width or toggle_opts.ui_fallback_width

  if #vk_window > 0 then
    width = math.floor(vk_window[1].width * 0.2)
  end

  if toggle_opts.ui_max_width and width > toggle_opts.ui_max_width then
    width = toggle_opts.ui_max_width
  end

  local height = toggle_opts.height_in_lines or 10

  local bufnr = vim.api.nvim_create_buf(false, true)

  local vk_window_id = vim.api.nvim_open_win(
    bufnr,
    true,
    {
      relative = "editor",
      title = toggle_opts.title or "VKitty",
      row = math.floor(((vim.o.lines - height) / 2) - 1), -- TODO: Mess with this
      col = math.floor(((vim.o.columns - width) / 2) - 1), -- TODO: Mess with this too
      width = width,
      height = height,
      style = "minimal",
      border = toggle_opts.border or "rounded"
    }
  )

  if vk_window_id == 0 then
    self.bufnr = bufnr
    self:close_window()
    error("Failed to create VKitty windo.")
  end

  self.vk_window_id = vk_window_id

  return vk_window_id, bufnr
end

---Open the Vk window with the contents
---@param win_opts? VkToggleOptions
---@param buf_ops? VkBufferOptions
---@param contents? string[]
function VKittyUI:toggle_vk_window(win_opts, buf_ops, contents)
  if self.vk_window_id ~= nil then
    self:close_window()
    return
  end

  if not contents then
    return
  end

  win_opts = get_toggle_config(win_opts or {})

  if contents then
    local max_cols = 1
    for _, c in pairs(contents) do
      if #c > max_cols then
        max_cols = #c
        win_opts.width = #c
      end
    end
  end

  if buf_ops and buf_ops.buf_type == "prompt" then
    win_opts.height_in_lines = 2
  end

  local vk_window_id, bufnr = self:_create_window(win_opts)

  self.vk_window_id = vk_window_id
  self.bufnr = bufnr

  Buffer.set_contents(self.bufnr, contents or {})
  Buffer.set_options(self.bufnr, buf_ops)
  Buffer.setup_keymaps_and_autocommands(self.bufnr)
end

return VKittyUI

