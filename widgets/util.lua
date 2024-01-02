local awful = require("awful")
local wibox = require("wibox")

local gears = require("gears")
local beautiful = require("beautiful")

function add_margin(widget, margins, markup_fn)
    return {
        widget,
        top = margins and margins.top or 0,
        bottom = margins and margins.bottom or 0,
        left = margins and margins.left or 0,
        right = margins and margins.right or 0,
        layout = wibox.container.margin,
        set_markup = markup_fn
    }
end

local function container(child, outer_margin, inner_margin, set_markup_fn)
   local round = {
      add_margin(child, {left = inner_margin, right = inner_margin}),
      layout = wibox.container.background,
      bg = beautiful.bg_focus,
      shape = gears.shape.rounded_rect,
   }
   return add_margin(
      round,
      {
         top = outer_margin,
         bottom = outer_margin
      },
      set_markup_fn)
end


local function styled_textarea(text)
   local child_widget = {
      markup = "cu",
      id = "main",
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
   }

   local markup_fn = function(self, val)
      self:get_children_by_id("main")[1].markup = val
   end

   return wibox.widget(container(child_widget, 8, 10, markup_fn))
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
      top = 8,
      bottom = 8,
      widget = wibox.container.margin,
      set_markup = function(self, val)
         self.ma.m.graph:add_value(val)
      end
   }
end

return {
   labeled_graph = labeled_graph,
   styled_textarea = styled_textarea,
   container = container
}
