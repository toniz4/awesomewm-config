local awful = require("awful")
local wibox = require("wibox")

local mode = wibox.widget {
   {
      id = "main",
      markup = "",
      widget = wibox.widget.textbox
   },
   layout = wibox.layout.align.horizontal,
   set_markup = function(self, val)
      if val == "normal" then
         self.main.markup = ""
      else
         self.main.markup = " " .. val .. " "
      end
   end
}

return mode
