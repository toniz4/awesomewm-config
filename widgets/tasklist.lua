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

local function tasklist(s)
   return awful.widget.tasklist {
      screen   = s,
      filter   = awful.widget.tasklist.filter.currenttags,
      buttons  = tasklist_buttons,
      style    = {
         shape  = gears.shape.rounded_rect,
      },
      layout   = {
         spacing = 10,
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
                     top = 3,
                     bottom = 3,
                     right = 8,
                     widget  = wibox.container.margin,
                  },
                  {
                     id     = 'text_role',
                     widget = wibox.widget.textbox,
                  },
                  layout = wibox.layout.fixed.horizontal,
               },
               left  = 10,
               right = 10,
               widget = wibox.container.margin
            },
            id     = 'background_role',
            -- color = "#FF0000",
            widget = wibox.container.background,
         },
         top = 8,
         bottom = 8,
         widget  = wibox.container.margin,
      },
   }
end

return tasklist
