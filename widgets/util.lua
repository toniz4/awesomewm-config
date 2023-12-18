local awful = require("awful")
local wibox = require("wibox")

local gears = require("gears")
local beautiful = require("beautiful")

local function styled_textarea(text)
   return wibox.widget {
      {
         {
            {
               markup = text,
               id = "main",
               align = "center",
               valign = "center",
               widget = wibox.widget.textbox
            },
            id = "m",
            left   = 10,
            right  = 10,
            widget = wibox.container.margin
         },
         id = "ma",
         layout = wibox.container.background,
         bg = beautiful.bg_focus,
         -- shape_border_color = beautiful.border_color,
         -- shape_border_width = 1,
         shape = gears.shape.rounded_rect,

      },
      top = 5,
      bottom = 5,
      widget = wibox.container.margin,

      set_markup = function(self, val)
         self.ma.m.main.markup = val
      end
   }
end

local function labeled_graph(label, max_value)
   return wibox.widget {
      {
         {
            {
               width = 50,
               id = "graph",
               background_color = "0",
               color = {
                  type = "linear", from = { 0, 0 }, to = { 0, 50 },
                  stops = {
                     { 0.2, "#FF5656" },
                     { 0.3, "#d0bc00" },
                     { 0.5, "#44bc44" }}
               },
               step_width = 3,
               step_spacing = 1,
               max_value = max_value,
               widget = wibox.widget.graph
            },
            {
               text = label,
               align = "center",
               valign = "center",
               widget = wibox.widget.textbox
            },
            id = "m",
            spacing = 2,
            layout = wibox.layout.stack,
         },
         id = "ma",
         layout = wibox.container.background,
         bg = beautiful.bg_focus,
         shape_clip = true,
         shape = gears.shape.rounded_rect,
      },
      top = 5,
      bottom = 5,
      widget = wibox.container.margin,
      set_markup = function(self, val)
         self.ma.m.graph:add_value(val)
      end
   }
end

return {
   labeled_graph = labeled_graph,
   styled_textarea = styled_textarea
}
