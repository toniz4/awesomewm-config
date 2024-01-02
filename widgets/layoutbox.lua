local awful = require("awful")
local wibox = require("wibox")
local util = require("widgets.util")


local function layoutbox(s)
   return wibox.widget {
      awful.widget.layoutbox(s),
      top = 8,
      bottom = 8,
      right = 10,

      layout = wibox.container.margin
   }
end

return layoutbox
