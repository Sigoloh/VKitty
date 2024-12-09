local VkGroup = require("VKitty.vk.vk_group")
local Buffer = {}

local map = vim.keymap.set

local VK_WINDOW = "VK_WINDOW"

local vk_window_id = math.random(1000)


local function get_vk_window_name()
  vk_window_id = vk_window_id + 1

  return VK_WINDOW .. vk_window_id
end

---This options set the behavior of the buffer in the VkWindow
---@class (exact) VkBufferOptions
---@field buf_type string? The the of butter to open in the window. Default: noemal buffer
---|"acwrite" Buffer will always be written with BufWriteCmds
---|"help" Help buffer
---|"prompt" Buffer where only the last line can be edited
---@field prompt_call_back? fun(entries: string[]): boolean Required when buf_type=`prompt`. The returned value must be true in order to vim to delete the autocommand that passes this function as a callback

---Get fullfilled VkBufferOptions
---@param config? VkBufferOptions
---@return VkBufferOptions
local function get_vk_buffer_option(config)
  return vim.tbl_extend(
    "force",
    {
      buf_type = "",
      line_number = false
    },
    config or {}
  )
end

function Buffer.run_toggle_command()
  local vk = require("VKitty.vk.vk")

  vk.ui:toggle_vk_window()

  vim.api.nvim_input('<Esc>')
end

---@param keys string[]
local function map_close_window_keys(keys, bufnr)
  for _, key in pairs(keys) do
    map(
      "n",
      key,
      function ()
        Buffer.run_toggle_command()
      end,
      {
        buffer = bufnr
      }
    )
  end
end

---@param lines string[]
---@return string[]
local function get_prompt_response(lines)
  if #lines == 0 then
    return {}
  end

  local input_line = lines[#lines]:gsub("󱞩 ", ""):gsub("󱞩", "")

  local split_comm = {}

  for str in string.gmatch(input_line, '%S+') do
    table.insert(split_comm, str)
  end

  return split_comm
end


---@param bufnr number The buffer to set the options to
---@param opts? VkBufferOptions Defaults to the defaults :X
function Buffer.set_options(bufnr, opts)
  opts = get_vk_buffer_option(opts)

  if opts.buf_type == "prompt" and opts.prompt_call_back == nil then
    error("When buftype is set to \"prompt\", prompt_call_back is required!")
  end

  -- Just reseting in case something goes wrong :D
  vim.api.nvim_set_option_value("buftype", "", {
    buf = bufnr
  })

  if opts.buf_type == "prompt" then
    vim.cmd('norm! o󱞩 ')
    vim.cmd('startinsert!')
    map(
      "i",
      "<CR>",
      function ()
        opts.prompt_call_back(
          get_prompt_response(
            Buffer.get_contents(bufnr)
          )
        )
        Buffer.run_toggle_command()
      end,
      {
        buffer = bufnr,
      }
    )
  end
end

---@param bufnr number
---@param is_select? boolean Defines if it has to set the <Enter> as a select or just close
---@param select_call_back? fun() Callback to call when enter is pressed. Only required when is_select is set to `true`
function Buffer.setup_keymaps_and_autocommands(bufnr, is_select, select_call_back)
  if vim.api.nvim_buf_get_name(bufnr) == "" then
    vim.api.nvim_buf_set_name(bufnr, get_vk_window_name())
  end

  vim.api.nvim_set_option_value("filetype", "vk", {
    buf = bufnr
  })

  map_close_window_keys({"q", "<Esc>"}, bufnr)

  if is_select then

    if not select_call_back then
      error("VKitty: select_call_back is required when is_select is set to `true`")
    end

    map(
      "n",
      "<CR>",
      function()
        select_call_back()
        Buffer.run_toggle_command()
      end
    )
  else
    map_close_window_keys({"<CR>"}, bufnr)
  end

  vim.api.nvim_create_autocmd({ "BufLeave" },{
    buffer = bufnr,
    group = VkGroup,
    callback = function()
      require("VKitty.vk.vk").ui:toggle_vk_window()
    end
  })
end

function Buffer.get_contents(bufnr)
  local lines = vim.api.nvim_buf_get_lines(
    bufnr,
    0,
    -1,
    true
  )

  local indices = {}
  for _, line in pairs(lines) do
    table.insert(indices, line)
  end

  return indices
end

---@param bufnr number
---@param contents string[]
function Buffer.set_contents(bufnr, contents)
  local splited_content = {}

  if contents then
    for _, c in pairs(contents or {}) do
      for w in string.gmatch(c, "[^\n]+") do
        table.insert(splited_content, w)
      end
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, splited_content)
end

return Buffer
