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
   if tag.selected then
      widget.background.bg = beautiful.bg_focus
   elseif tag.urgent then
      widget.background.bg = beautiful.bg_urgent
   else
      widget.background.bg = beautiful.bg_normal
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
                     id     = 'text',
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
         },
         widget = wibox.container.margin,
         top  = beautiful.widget_margin - 2,
         bottom = beautiful.widget_margin - 2,
         create_callback = function(self, c3, index, objects) --luacheck: no unused args
            update_tag_widget(self, c3)
            -- c3:connect_signal('property::urgent', function()
            --                      self.background.bg = "#FF0000"
            -- end)
            self:connect_signal('mouse::enter', function()
                                   self.background.bg = beautiful.border_focus
            end)
            self:connect_signal('mouse::leave', function()
                                   update_tag_widget(self, c3)
            end)
         end,
         update_callback = function(self, c3, index, objects) --luacheck: no unused args
            update_tag_widget(self, c3)
         end,
      },
   buttons = taglist_buttons
}
end

return taglist

