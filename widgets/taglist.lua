local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local taglist_buttons = gears.table.join(
   awful.button({ }, 1, function(t)
         t:view_only()
   end),
   awful.button({ modkey }, 1, function(t)
         if client.focus then
            client.focus:move_to_tag(t)
         end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
         if client.focus then
            client.focus:toggle_tag(t)
         end
   end)
)

local function update_tag_widget(widget, tag)
   widget:get_children_by_id('text')[1].markup = tag.name
   -- widget.background.shape_border_color = beautiful.fg_normal

   if tag.selected then
      widget.background.bg = beautiful.bg_alt
      widget.background.shape_border_width = beautiful.bar_border_width
   elseif tag.urgent then
      widget.background.bg = beautiful.bg_urgent
      widget.background.shape_border_width = 0
   else
      widget.background.bg = beautiful.bg_focus
      widget.background.shape_border_width = 0
   end
end

local function taglist(s)
   return awful.widget.taglist {
      screen  = s,
      filter  = awful.widget.taglist.filter.noempty,
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
                        id     = 'text',
                        widget = wibox.widget.textbox,
                     },
                     left  = beautiful.widget_margin - 4,
                     right = beautiful.widget_margin - 4,
                     widget = wibox.container.margin
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
         widget = wibox.container.margin,
         left  = beautiful.widget_margin - 2,
         top  = beautiful.widget_margin - 2,
         bottom = beautiful.widget_margin - 2,
         create_callback = function(self, c3, index, objects)
            update_tag_widget(self, c3)
            self:connect_signal('mouse::enter', function()
                                   -- self.background.shape_border_width = beautiful.bar_border_width
                                   self.background.bg = beautiful.border_focus
                                   -- self.background.shape_border_color = beautiful.border_focus
            end)
            self:connect_signal('mouse::leave', function()
                                   update_tag_widget(self, c3)
            end)
         end,
         update_callback = function(self, c3, index, objects)
            update_tag_widget(self, c3)
         end,
      },
   buttons = taglist_buttons
}
end

return taglist

