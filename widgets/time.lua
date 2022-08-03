
local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")

local factory = function()
    local time = wibox.widget {
        {
	   id           = "tb",
	   text         = "100%",
	   widget       = wibox.widget.textbox,
	},
        layout = wibox.layout.align.horizontal,

        set_set = function(self, val)
            self.tb.text  = val
        end,
    }

    gears.timer {
        timeout   = 10,
        call_now  = true,
        autostart = true,
        callback  = function()
	   time.set = os.date( "%d/%m/%y %H:%M")
        end
    }

    return time
end

return factory()
