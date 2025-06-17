local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28

config.font_size = 12
config.color_scheme = 'GruvboxDark'


-- Windows stuff
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

return config
