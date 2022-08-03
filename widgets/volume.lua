local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local alsa = require("helpers.alsa")

local beautiful = require("beautiful")

local factory = function(channel)
    local volume = wibox.widget {
        {
            {
	       id               = "pb",
	       max_value        = 100,
	       widget           = wibox.widget.progressbar,
	       color            = beautiful.progress_bar_fg,
	       background_color = beautiful.progress_bar_bg,
	       clip             = false,
	       margins          = 4,
	       paddings         = 5,
            },

	    id            = "div",
            forced_width  = 30,
	    layout = wibox.layout.fixed.horizontal,
        },
	{
	   id           = "tb",
	   text         = alsa.get(channel)["volume"],
	   widget       = wibox.widget.textbox,
	},
	layout = wibox.layout.align.horizontal,
	set_volume = function(self, val)
	   if alsa.get(channel)["muted"] then
	      self.tb.text = "muted"
	      self.div.pb.value = val
	   else
	      self.tb.text = val .. "%"
	      self.div.pb.value = val
	   end
	end,
    }

    gears.timer {
        timeout   = 10,
        call_now  = true,
        autostart = true,
        callback  = function()
	   volume.volume = alsa.get(channel)["volume"]
	end
    }

    return volume
end


return factory
