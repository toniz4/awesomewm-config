local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")

local factory = function()
    local battery = wibox.widget {
        {
            {
	       id               = "pb",
	       max_value        = 100,
	       widget           = wibox.widget.progressbar,
	       color            = beautiful.progress_bar_fg,
	       background_color = beautiful.progress_bar_bg,
	       clip             = false,
	       margins          = 3,
	       paddings         = 4,
            },

	    id            = "div",
            forced_width  = 12,
            direction     = 'east',
            layout        = wibox.container.rotate,
        },
        {
	   id           = "tb",
	   text         = "100%",
	   widget       = wibox.widget.textbox,
	},
        layout = wibox.layout.align.horizontal,

        set_set = function(self, val)
            self.tb.text  = tonumber(val).."%"
            self.div.pb.value = tonumber(val)
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
                {"sh", "-c", "cat /sys/class/power_supply/BAT0/capacity"},
                function(out)
                    battery.set = out
                end
            )
        end
    }

    return battery
end

return factory()
