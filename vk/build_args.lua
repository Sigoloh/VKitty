local actions = require("actions")

---Build a `-o <var_name> = <new_value>` flag to kitty
---@param var_name string The name of the variable to overwrite
---@param new_value string The new value for the overwrited variable
local function build_overwrite(var_name, new_value)
  return "-o"..var_name.."="..new_value.." "
end

---Generate arguments for the kitty spawn command
local function build_args()
  local args = ""

  local remote_controll_pass = "123"

  local enable_actions = actions.generate_actions_set()

  args = args .. build_overwrite("allow_remote_control", "password")

  args = args .. build_overwrite("remote_control_password", "\""..remote_controll_pass.."\"")

  for action in enable_actions do
    args = args .. action
  end
end

return build_args
