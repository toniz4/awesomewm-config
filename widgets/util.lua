local awful = require("awful")
local wibox = require("wibox")

local function labeled_graph (label, max_value)
   local graph = wibox.widget {
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
      spacing = 2,
      layout = wibox.layout.stack,
      set_markup = function(self, val)
         self.graph:add_value(val)
      end
   }
   return graph
end

return {
   labeled_graph = labeled_graph
}
