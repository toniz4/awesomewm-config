---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme_name = "default"
local local_themes_path = gfs.get_configuration_dir() .. "icons/"
local utils = require("utils")

local theme = {}

-- theme.font          = "cozette 8"
if utils.hostname() == "intus" then
   theme.font          = "Go Mono Nerd Font 10"
   theme.widget_margin = 4
else
   theme.widget_margin = 10
   theme.font          = "Go Mono Nerd Font 14"
end

theme.bg_normal     = "#000000"
theme.bg_focus      = "#1e1e1e"
theme.bg_alt        = "#535353"

theme.bg_urgent     = "#9d1f1f"
theme.bg_minimize   = "#000000"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#FFFFFF"
theme.fg_focus      = "#FFFFFF"
theme.fg_urgent     = "#FFFFFF"
theme.fg_minimize   = "#989898"

theme.useless_gap   = 0
theme.border_width  = dpi(6)
theme.border_normal = "#646464"
theme.border_focus  = "#1640b0"
theme.border_marked = "#c37474"

theme.graph_bg = theme.bg_normal
theme.graph_fg = theme.border_focus
theme.graph_border_color = theme.border_normal

theme.notification_max_width = 450
theme.notification_icon_size = 150
theme.notification_bg = theme.bg_normal
theme.notification_border_width = theme.border_width
theme.notification_border_color = theme.border_focus

theme.bar_border_width = 0
-- theme.notification

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"
theme.tasklist_bg_normal = theme.bg_focus
theme.tasklist_bg_focus = theme.bg_alt
theme.calendar_focus_bg_color = theme.border_focus

theme.calendar_normal_border_width = dpi(2)
theme.calendar_focus_border_width = dpi(2)
theme.calendar_month_border_width = dpi(2)
theme.calendar_weekday_border_width = dpi(2)


-- Generate taglist squares:
--local taglist_square_size = dpi(4)
--theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    --taglist_square_size, theme.fg_normal
--)
--theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    --taglist_square_size, theme.fg_normal
--)

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = themes_path.."default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = themes_path.."default/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = themes_path.."default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path.."default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path.."default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themes_path.."default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path.."default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themes_path.."default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path.."default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themes_path.."default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path.."default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = themes_path.."default/titlebar/maximized_focus_active.png"

theme.wallpaper = gfs.get_configuration_dir() .. "wallpaper"
-- theme.wallpaper = "#707470"

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path..theme_name.."/layouts/fairhw.png"
theme.layout_fairv = themes_path..theme_name.."/layouts/fairvw.png"
theme.layout_floating  = themes_path..theme_name.."/layouts/floatingw.png"
theme.layout_magnifier = themes_path..theme_name.."/layouts/magnifierw.png"
theme.layout_max = themes_path..theme_name.."/layouts/maxw.png"
theme.layout_fullscreen = themes_path..theme_name.."/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path..theme_name.."/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path..theme_name.."/layouts/tileleftww.png"
theme.layout_tile = themes_path..theme_name.."/layouts/tilew.png"
theme.layout_tiletop = themes_path..theme_name.."/layouts/tiletopw.png"
theme.layout_spiral  = themes_path..theme_name.."/layouts/spiralw.png"
theme.layout_dwindle = themes_path..theme_name.."/layouts/dwindlew.png"
theme.layout_cornernw = themes_path..theme_name.."/layouts/cornernww.png"
theme.layout_cornerne = themes_path..theme_name.."/layouts/cornernew.png"
theme.layout_cornersw = themes_path..theme_name.."/layouts/cornersww.png"
theme.layout_cornerse = themes_path..theme_name.."/layouts/cornersew.png"

theme.progress_bar_bg = "#363636"
theme.progress_bar_fg = "#AC8AAC"

theme.mpd_play = local_themes_path.."play.png"
theme.mpd_pause = local_themes_path.."pause.png"
theme.mpd_stop = local_themes_path.."stop.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
