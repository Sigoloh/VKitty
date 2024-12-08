---Abstraction (prr) of the kitten actions
---@class (exact) VkAction
---@field name string Cannonical name of the action
---@field desc string Cannonical description of the action
---@field enabled boolean Tells VKitten to enable this acition or not in the kitty session. Defaults to false
local VkAction = {}

---Creates a new VKitten action based on definitions provided by kitten @ --help
---@param action_name string Cannonical name of the action
---@param action_desc string Cannonical description of the action
---@param enabled? boolean Tells VKitten wether this acition should be enabled in the kitty session of not. Defaults to false
function VkAction:new(action_name, action_desc, enabled)
  self.name = action_name
  self.desc = action_desc
  self.enabled = enabled or false
  return self
end

---Enables this action in the next run of VKitten
function VkAction:enable()
  self.enabled = true
end

---Disables this action in the next run of VKitten
function VkAction:disable()
  self.enabled = false
end

---@type { [string]: VkAction }
local actions = {
  action = VkAction:new("action", "Run the specified mappable action", true),
  detach_window = VkAction:new("detach-window", "Detach the specified windows and place them in a different/new tab", true),
  close_window = VkAction:new("close-window", "Close the specified windows", true),
  create_marker = VkAction:new("create-marker", "Create a marker that highlights specified text", true),
  env = VkAction:new("env", "Change environment variables seen by future children", true),
  focus_window = VkAction:new("focus-window", "Focus the specified window", true),
  launch = VkAction:new("launch", "Run an arbitrary process in a new window/tab", true),
  new_window = VkAction:new("new-window", "Open new window", true),
  send_key = VkAction:new("send_key", "Send arbitrary key presses to the specified windows", true),
  send_text = VkAction:new("send-text", "Send arbitrary text to specified windows", true), ls = VkAction:new("ls", "List tabs/windows", true),
  signal_child = VkAction:new("signal-child", "Send a signal to the foreground process in the specified windows", true),

  close_tab = VkAction:new("close-tab", "Close the specified tabs", false),
  detach_tab = VkAction:new("detach-tab", "Detach the specified tabs and place them in a different/new OS window", false),
  disable_ligatures = VkAction:new("disable-ligatures", "Control ligature rendering", false),
  focus_tab = VkAction:new("focus-tab", "Focus the specified tab", false),
  get_colors = VkAction:new("get-colors", "Get terminal colors", false),
  get_text = VkAction:new("get-text", "Get text from the specified window", false),
  goto_layout = VkAction:new("goto-layout", "Set the window layout", false),
  kitten = VkAction:new("kitten", "Run a kitten", false),
  last_used_layout = VkAction:new("last-used-layout", "Switch to the last used layout", false),
  load_config = VkAction:new("load-config", "(Re)load a config file", false),
  remove_marker = VkAction:new("remove-marker", "Remove the currently set marker if any", false),
  resize_os_window = VkAction:new("resize-os-window", "Resize the specified OS Windows", false),
  resize_window = VkAction:new("resize-window", "Resize the specified windows", false),
  run = VkAction:new("run", "Run a program on the computer in which kitty is running and get the output", false),
  scroll_window = VkAction:new("scroll-window", "Scroll the specified windows", false),
  select_window = VkAction:new("select-window", "Visually select a window in the specified tab", false),
  set_background_image = VkAction:new("set_background-image", "Set the background image", false),
  set_background_opacity = VkAction:new("set-background-opacity", "Set the background opacity", false),
  set_colors = VkAction:new("set-colors", "Set terminal colors", false),
  set_enabled_layouts = VkAction:new("set-enabled-layouts", "Set the enabled layouts in tabs", false),
  set_font_size = VkAction:new("set-font-size", "Set the font size in the active top - level OS window", false),
  set_spacing = VkAction:new("set-spacing", "Set window paddings and margins", false),
  set_tab_color = VkAction:new("set-tab-color", "Change the color of the specified tabs in the tab bar", false),
  set_tab_title = VkAction:new("set-tab-title", "Set the tab title", false),
  set_user_vars = VkAction:new("set-user-vars", "Set user variables on a window", false),
  set_window_logo = VkAction:new("set-window-logo", "Set the window logo", false),
  set_window_title = VkAction:new("set-window-title", "Set the window title", false),
}


---Iterates in the actions table to get all enabled actions
---@return string[]
local function generate_actions_set()
  local action_set
  for _, vk_act in pairs(actions) do
    if vk_act.enabled then
      action_set.insert(vk_act)
    end
  end

  return action_set
end

return {
  actions = actions,
  generate_actions_set = generate_actions_set
}
