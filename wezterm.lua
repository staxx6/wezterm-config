local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28
config.window_background_opacity = 0.98

config.font_size = 12
config.color_scheme = 'GruvboxDark'

config.default_prog = { 'pwsh' }
config.default_cwd = 'C:\\'

-- Tab bar
config.window_frame = {
  font_size = 12.0,
  active_titlebar_bg = '#333333', -- Not working? maybe windows ...
  inactive_titlebar_bg = '#313030'
}

-- Set tab title to last folder
wezterm.on("format-tab-title", function(tab, tabs, panes, config2, hover, max_width)
  -- Don't override own title
  local manual_title = tab.tab_title
  if manual_title and manual_title ~= "" then
    return manual_title
  end

  local title = tostring(tab.active_pane.current_working_dir)

  if title then
    -- Entferne das "file:///" Prefix
    local path = title:gsub("^file:///", "")

    -- Windows: Pfad-Trenner ersetzen
    path = path:gsub("/", "\\")

    -- Extrahiere letzten Ordner
    local last_folder = path:match("([^\\]+)\\?$") or path

    return last_folder
  end

  return "Shell"
end)

-- Windows stuff
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

-- config.leader = { key = 'space', mods = 'CTRL', timeout_milliseconds = 1000 }
local act = wezterm.action
config.keys = {

  -- This will create a new split and run your default program inside it
  {
    key = 'h',
    mods = 'CTRL|ALT',
    action = act.SplitPane { direction = 'Left' },
  },
  {
    key = 'j',
    mods = 'CTRL|ALT',
    action = act.SplitPane { direction = 'Down' },
  },
  {
    key = 'k',
    mods = 'CTRL|ALT',
    action = act.SplitPane { direction = 'Up' },
  },
  {
    key = 'l',
    mods = 'CTRL|ALT',
    action = act.SplitPane { direction = 'Right' },
  },

  -- change pane size
  {
    key = 'H',
    mods = 'ALT|SHIFT',
    action = act.AdjustPaneSize { 'Left', 5 },
  },
  {
    key = 'J',
    mods = 'ALT|SHIFT',
    action = act.AdjustPaneSize { 'Down', 5 },
  },
  {
    key = 'K',
    mods = 'ALT|SHIFT',
    action = act.AdjustPaneSize { 'Up', 5 } },
  {
    key = 'L',
    mods = 'ALT|SHIFT',
    action = act.AdjustPaneSize { 'Right', 5 },
  },

  -- Pane selection
  {
    key = 'f',
    mods = 'ALT',
    action = act.PaneSelect
  },
  {
    key = 'h',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'l',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Right',
  },
  {
    key = 'k',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'j',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Down',
  },

  {
    key = 'd',
    mods = 'ALT',
    action = act.CloseCurrentPane { confirm = false }
  },

  -- Change current tab title
  {
    key = 'r',
    mods = 'ALT',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  {
    key = 't',
    mods = 'ALT',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
}

return config
