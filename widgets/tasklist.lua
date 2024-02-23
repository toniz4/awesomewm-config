local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local tasklist_buttons = gears.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            c:emit_signal(
               "request::activate",
               "tasklist",
               {raise = true}
            )
         end
   end),
   awful.button({ }, 3, function()
         awful.menu.client_list({ theme = { width = 250 } })
end))

local function update_tasklist(widget, c)
   local bg = widget.background
   if client.focus == c then
      bg.bg = beautiful.bg_alt
      bg.shape_border_width = 3
   elseif c.minimized then
      bg.bg = beautiful.bg_minimize
      bg.shape_border_width = 0
   else
      bg.bg = beautiful.bg_focus
      bg.shape_border_width = 0
   end
end

local function tasklist(s)
   return awful.widget.tasklist {
      screen   = s,
      filter   = awful.widget.tasklist.filter.currenttags,
      buttons  = tasklist_buttons,
      style    = {

      },
      layout   = {
         spacing = beautiful.widget_margin -2,
         layout  = wibox.layout.flex.horizontal
      },
      widget_template = {
         {
            {
               {
                  {
                     {
                        id     = 'icon_role',
                        widget = wibox.widget.imagebox,
                     },
                     top = 2,
                     bottom = 2,
                     right = beautiful.widget_margin -2,
                     widget  = wibox.container.margin,
                  },
                  {
                     id     = 'text_role',
                     widget = wibox.widget.textbox,
                  },
                  layout = wibox.layout.fixed.horizontal,
               },
               left  = beautiful.widget_margin,
               right = beautiful.widget_margin,
               widget = wibox.container.margin
            },
            id     = 'background',
            widget = wibox.container.background,
            shape  = gears.shape.rounded_rect,
            shape_clip = true,
         },
         top = beautiful.widget_margin - 2,
         bottom = beautiful.widget_margin - 2,
         widget  = wibox.container.margin,
         update_callback = function(self, c3, index, objects)
            update_tasklist(self, c3)
         end
      },
   }
end

return tasklist
