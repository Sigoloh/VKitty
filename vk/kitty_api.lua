---@class KittyApi
---@field rc_pass string The password to use in kitty connections
local KittyApi = {}
KittyApi.__index = KittyApi


---@return KittyApi
function KittyApi:new()
  local v_kitty_rc_pass = os.getenv("VKITTY_PASS")

  if not v_kitty_rc_pass then
    error("Unable to get the $VKITTY_PASS. See :h VKitty.kitty_pass")
  end

  return setmetatable({
    rc_pass = v_kitty_rc_pass,
  }, self)
end

---Spawn new kitty window AFTER the current
---@param title string Title of the new window
---@param comm? string The command to launch in the new window. Default: `$SHELL`
---@param comm_args? string[] Arguments to pipe to the command spawned in the new window. Default: `[]`
---@param cwd? string Working directory to the new window. Default: `true`
---@param env? string Environment variables to set in the child process.
---Syntax: name=value
---Default: Copy the environment variables from the currently active window
---@param hold? boolean Keep the window open even after the command being executed exits, at a shell prompt. Default: `true`
---@param  split_mode? string Default: `"v"`
---| "v" #Create the new window in vertical split
---| "h" #Create the new in horizontal split
---@return number
function KittyApi:spawn_kitty_window(
  title,
  comm,
  comm_args,
  cwd,
  env,
  hold,
  split_mode
)
  local comm_arg = comm or "$SHELL"

  comm_args = comm_args or {}

  local comm_args_arg = table.concat(comm_args, " ")

  local title_arg = "--title="..title

  local cwd_arg = "--cwd="..(cwd or ".")

  local env_arg = env and "--env="..(env) or "--copy-env"

  local hold_arg = ""

  if hold then
    hold_arg = "--hold"
  end

  local split_mode_arg = "--location=vsplit"

  if split_mode == "h" then
    split_mode_arg = "--location=split"
  end

  local kitty_command = {'kitten', '@', '--password='..self.rc_pass, 'launch', '--hold', split_mode_arg ,comm_arg, comm_args_arg,}

  local exec_result = vim.system(kitty_command, {text = true}):wait()

  local contents = {
      "Exit code: "..exec_result.code,
      "Exited in signal:"..exec_result.signal,
      "Stdout: "..exec_result.stdout,
      "Stderr: "..exec_result.stderr
  }

  local vk = require("VKitty.vk.vk")

  if exec_result.stderr or not exec_result.stdout then
    vk.open_vk_dialog_window(kitty_command)
  end

  local kitty_win_id = tonumber(exec_result.stdout)

  if not kitty_win_id then
    vk.open_vk_dialog_window({
      "Well, something went wrong!",
      "VKitty could not retrieve the openeded window id",
      "Received:",
      exec_result.stdout,
      "Expected:",
      "<number>"
    })
  end

  return kitty_win_id or -1
end

return KittyApi
