local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local isWindows = false
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  isWindows = true
end
  isWindows = false

-- local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

config.initial_cols = 120
config.initial_rows = 28
config.window_background_opacity = 0.98

config.font_size = 12
config.color_scheme = 'GruvboxDark'

config.default_prog = isWindows and { 'pwsh' } or { 'bash' }
config.default_cwd = isWindows and 'C:\\' or '/'

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
  local currProg = tostring(tab.active_pane.foreground_process_name)

  if title then
    -- Entferne das "file:///" Prefix
    local path = title:gsub("^file:///", "")

    -- Windows: Pfad-Trenner ersetzen
    path = isWindows and path:gsub("/", "\\") or path

    -- Extrahiere letzten Ordner
    local last_folder
    if isWindows then
      last_folder = path:match("([^\\]+)\\?$") or path
    else
      last_folder = path:match("([^/]+)/?$") or path
    end

    if currProg then
      local isNvim = isWindows and currProg:find("nvim.exe", 1, true) or currProg:find("nvim", 1, true)
      if isNvim then
        last_folder = "nvim " .. last_folder
      end
    end

    if last_folder == '' then
      return '/'
    end
    return last_folder
  end

  return "Shell"
end)

-- Show current workspace
wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace())
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
    action = act.AdjustPaneSize { 'Up', 5 }
  },
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

  -- New tab
  {
    key = 't',
    mods = 'ALT',
    action = act.SpawnTab 'CurrentPaneDomain',
  },

  -- Workspace handling
  {
    key = 'w',
    mods = 'ALT',
    action = act.ShowLauncherArgs {
      flags = 'WORKSPACES',
      title = '> Workspaces',
    },
  },
  {
    key = 'w',
    mods = 'CTRL|ALT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            act.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    }
  },

  --
  -- Plugins
  --

  -- Resurrect
  --[[
  {
    key = "s",
    mods = "CTRL|ALT",
    action = wezterm.action_callback(function(window, pane)
      local tab = window:active_tab()
      local title = tab:get_title() or "unnamed"
      if tab == nil then
        print('tab has NO value')
      end
      if title == nil then
        print('title has NO value')
      end
      if resurrect.tab_state == nil then
        print('tab state has NO value')
      end

      print("title" .. title)
      resurrect.tab_state.save_tab_action(tab, title .. ".tab.json")
      wezterm.log_info("Saved tab as: " .. title)
    end),
  },

  {
    key = "g",
    mods = "ALT",
    action = wezterm.action_callback(function(win, pane)
        print(win)
        print(pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
        print(win)
        print(pane)
        local state = resurrect.state_manager.load_state(id, "tab")
        if state then
          resurrect.tab_state.restore_tab(pane:tab(), state, {
            restore_text = true,
            on_pane_restore = resurrect.tab_state.default_on_pane_restore,
          })
        end
      end)
    end),
  },
  ]]--
}

return config
