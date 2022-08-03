local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")

local colors  = { 
   "#FFFFFF",
   "#FF0000"
}

local factory = function()
   local temp = wibox.widget {
      -- {
      -- 	 id = "tg",
      -- 	 max_value = 100,
      -- 	 forced_width = 30,
      -- 	 color = "linear:0,0:0,20:0,#FF0000:0.25," .. beautiful.graph_fg,
      -- 	 background_color = beautiful.graph_bg,
      -- 	 border_width = 4,
      -- 	 widget = wibox.widget.graph
      -- },
      {
	 id           = "tb",
	 text         = "100°C",
	 widget       = wibox.widget.textbox,
      },
      layout = wibox.layout.align.horizontal,
      
      set_set = function(self, val)
	 -- self.tg:add_value(tonumber(val), 1)
	 self.tb.text  = tonumber(val).."°C"
      end,
   }
   
   gears.timer {
      timeout   = 10,
      call_now  = true,
      autostart = true,
      callback  = function()
	 -- You should read it from `/sys/class/power_supply/` (on Linux)
	 -- instead of spawning a shell. This is only an example.
	 awful.spawn.easy_async(
	    {"sh", "-c", "sed 's/000$//' /sys/class/thermal/thermal_zone0/temp"},
	    function(out)
	       temp.set = out
	    end
	 )
      end
   }

   return temp
end

return factory()
