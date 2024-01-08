local awful = require("awful")
local wibox = require("wibox")
local util = require("widgets.util")
local beautiful = require("beautiful")

local function layoutbox(s)
   return wibox.widget {
      awful.widget.layoutbox(s),
      top = beautiful.widget_margin - 2,
      bottom = beautiful.widget_margin - 2,
      right = beautiful.widget_margin,

      layout = wibox.container.margin
   }
end

return layoutbox
