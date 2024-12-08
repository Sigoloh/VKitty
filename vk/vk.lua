-- VKitty, control Kitty from Neovim
-- Copyright (C) <2024>  <Augusto Sigolo>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local M = {}

local VKittyUI = require("VKitty.vk.ui")

local KittyApi = require("VKitty.vk.kitty_api")
function M.setup()
  M.ui = VKittyUI:new()

  M.KApi = KittyApi:new()

  ---Uses VKittyUI.toggle_vk_window to open a prompt window
  ---@param prompt string The prompt to send to the buffer
  ---@param callback fun(entry: string[]): boolean A fuction that receivesThe returned value must be true in order to vim to delete the autocommand that passes this function as a callback
  ---@param win_opts? VkToggleOptions
  M.open_vk_prompt_window = function (prompt, callback, win_opts)
    local buf_opts = {
      buf_type="prompt",
      prompt_call_back = callback
    }

    M.ui:toggle_vk_window(win_opts, buf_opts, {prompt})
  end

  ---Uses VKittyUI.toggle_vk_window to open a dialog window
  ---@param content string[]
  ---@param win_opts? VkToggleOptions
  M.open_vk_dialog_window =function(content, win_opts)
    M.ui:toggle_vk_window(win_opts, {}, content)
  end

  ---Runs some command in a new kitty window
  ---@param title string The title to give to the new window
  ---@param command string The command to run in the new window
  ---@param args string[] Arguments to send to the command
  ---@param mode string 
  ---| "v" Open the new window in vertical split
  ---| "h" Open the new window in horizontal split
  M.run_command_in_new_window = function (title, command, args, mode)
      M.KApi:spawn_kitty_window(
        title,
        command,
        args,
        nil,
        nil,
        nil,
        mode
      )
  end
  return M
end

return M
