local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local widgets = require("vicious.widgets.init")
local util = require("widgets.util")
local db = require("gears.debug")
local beautiful = require("beautiful")
-- local mpdwid = require("widgets.mpd_vicious")

local icon = wibox.widget {
   id = "icon",
   widget = wibox.widget.imagebox
}

local mpd = wibox.widget {
   {
      {
         id = "icon",
         widget = icon,
      },
      id = "m",
      top = 8,
      bottom = 8,
      right = 8,
      widget = wibox.container.margin
   },
   {
      id = "mpd",
      markup = "",
      widget = wibox.widget.textbox
   },
   layout = wibox.layout.align.horizontal,
   set_margin = function(self, val)
      self.m.left = val
      self.m.right = val
   end,
   set_markup = function(self, val)
      if val[2] == "Play" then
         self.m.icon.image = beautiful.mpd_play
      elseif val[2] == "Stop" then
         self.m.icon.image = beautiful.mpd_stop
      else
         self.m.icon.image = beautiful.mpd_pause
      end

      self.mpd.markup = val[1]
   end
}

local update = function (widget, args)
   if args["{state}"] == "Stop" then
      return {
         'Nothing Playing',
         args["{state}"]
      }
   else
      return {
          ('Artists: %s Track: %s Genres: %s'):format(args["{Artists}"], args["{Title}"], args["{Genres}"]),
         args["{state}"]
      }
   end
end

vicious.register(mpd, vicious.widgets.mpd, update, 5)


icon:buttons(
   awful.util.table.join(
      awful.button({}, 1,
         function ()
            vicious.widgets.mpd.playpause()
            vicious.force({mpd})
      end),
      awful.button({}, 9,
         function ()
            vicious.widgets.mpd.next()
            vicious.force({mpd})
      end),
      awful.button({}, 8,
         function ()
            vicious.widgets.mpd.previous()
            vicious.force({mpd})
      end)
   )
)

return mpd
