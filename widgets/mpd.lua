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

local function mpd_widget()
   local child = {
      {
         {
            id = "icon",
            widget = icon,
         },
         id = "m",
         top = 3,
         bottom = 3,
         right = 8,
         widget = wibox.container.margin
      },
      {
         id = "main",
         markup = "",
         widget = wibox.widget.textbox
      },
      layout = wibox.layout.align.horizontal,

   }

   local markup_fn = function(self, val)
      text = self:get_children_by_id("main")[1]
      icon = self:get_children_by_id("icon")[1]
      if val[2] == "Play" then
         icon.image = beautiful.mpd_play
      elseif val[2] == "Stop" then
         icon.image = beautiful.mpd_stop
      else
         icon.image = beautiful.mpd_pause
      end
      text.markup = val[1]
   end

   return wibox.widget(util.container(child, 8, 10, markup_fn))
end

local mpd = mpd_widget()

local update = function (widget, args)
   if args["{state}"] == "Stop" then
      return {
         'Nothing Playing',
         args["{state}"]
      }
   else
      return {
          ('%s - %s'):format(args["{Artists}"], args["{Title}"]),
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
