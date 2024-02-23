local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local util = require("widgets.util")
local wpctl = require("utils.wpctl")

local volume = util.styled_textarea()

local update = function(widget, args)
   local muted = args[2] == "🔈"
   local volume = tonumber(args[1])

   if muted then
      return "󰝟 muted"
   end

   local icon = "󰖀 "

   if volume < 30 then
      icon = "󰕿 "
   elseif volume > 70 then
      icon = "󰕾 "
   end
   return icon .. volume .. "%"
end

vicious.register(volume, vicious.widgets.volume, update, 2, "Master")

volume:buttons(awful.util.table.join(
                  awful.button({}, 1, function ()
                        wpctl.toggle_mute()
                        vicious.force({volume})
                  end),
                  awful.button({}, 3, function () awful.util.spawn("pavucontrol") end),
                  awful.button({}, 4, function ()
                        wpctl.inc(1)
                        vicious.force({volume})
                  end),
                  awful.button({}, 5, function ()
                        wpctl.dec(1)
                        vicious.force({volume})
                  end)))

-- function volume:update()
--    naughty.notify({title = "updated"})
--    vicious.force(self)
-- end

return volume


